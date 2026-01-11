import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mta/features/notifications/domain/repositories/notification_repository.dart';
import 'package:mta/features/schedules/domain/usecases/create_schedule.dart';
import 'package:mta/features/schedules/domain/usecases/delete_schedule.dart';
import 'package:mta/features/schedules/domain/usecases/get_schedules.dart';
import 'package:mta/features/schedules/domain/usecases/update_schedule.dart';
import 'package:mta/features/schedules/presentation/bloc/schedule_event.dart';
import 'package:mta/features/schedules/presentation/bloc/schedule_state.dart';

class ScheduleBloc extends Bloc<ScheduleEvent, ScheduleState> {
  final GetSchedules getSchedules;
  final CreateSchedule createSchedule;
  final UpdateSchedule updateSchedule;
  final DeleteSchedule deleteSchedule;
  final NotificationRepository notificationRepository;

  ScheduleBloc({
    required this.getSchedules,
    required this.createSchedule,
    required this.updateSchedule,
    required this.deleteSchedule,
    required this.notificationRepository,
  }) : super(ScheduleInitial()) {
    on<LoadSchedulesEvent>(_onLoadSchedules);
    on<CreateScheduleEvent>(_onCreateSchedule);
    on<UpdateScheduleEvent>(_onUpdateSchedule);
    on<DeleteScheduleEvent>(_onDeleteSchedule);
    on<ToggleScheduleEvent>(_onToggleSchedule);
  }

  Future<void> _onLoadSchedules(
    LoadSchedulesEvent event,
    Emitter<ScheduleState> emit,
  ) async {
    emit(ScheduleLoading());

    final result = await getSchedules(
      GetSchedulesParams(userId: event.userId),
    );

    result.fold(
      (failure) => emit(ScheduleError(failure.message)),
      (schedules) => emit(SchedulesLoaded(
        schedules: schedules,
        userId: event.userId,
      )),
    );
  }

  Future<void> _onCreateSchedule(
    CreateScheduleEvent event,
    Emitter<ScheduleState> emit,
  ) async {
    emit(ScheduleLoading());

    final result = await createSchedule(
      CreateScheduleParams(schedule: event.schedule),
    );

    await result.fold(
      (failure) async => emit(ScheduleError(failure.message)),
      (schedule) async {
        debugPrint('✅ Schedule creado: ${schedule.id}');

        // 🔔 Si el schedule está habilitado, programar notificaciones
        if (schedule.isEnabled) {
          debugPrint(
              '📅 Programando notificaciones para el schedule ${schedule.id}');

          final notificationResult = await notificationRepository
              .scheduleNotificationsForUserSchedules(schedule.userId);

          notificationResult.fold(
            (failure) {
              debugPrint(
                  '❌ Error al programar notificaciones: ${failure.message}');
              emit(ScheduleError(
                'Schedule creado pero error al programar notificaciones: ${failure.message}',
              ));
            },
            (count) {
              debugPrint('✅ $count notificaciones programadas');
              emit(ScheduleOperationSuccess(
                'Schedule created successfully',
                userId: schedule.userId,
              ));
            },
          );
        } else {
          debugPrint(
              'ℹ️ Schedule deshabilitado, no se programan notificaciones');

          emit(ScheduleOperationSuccess(
            'Schedule created successfully',
            userId: schedule.userId,
          ));
        }
      },
    );
  }

  Future<void> _onUpdateSchedule(
    UpdateScheduleEvent event,
    Emitter<ScheduleState> emit,
  ) async {
    emit(ScheduleLoading());

    final result = await updateSchedule(
      UpdateScheduleParams(schedule: event.schedule),
    );

    await result.fold(
      (failure) async => emit(ScheduleError(failure.message)),
      (schedule) async {
        debugPrint('✅ Schedule actualizado: ${schedule.id}');

        // 🔔 Reprogramar notificaciones del usuario
        debugPrint(
            '🔄 Reprogramando notificaciones del usuario ${schedule.userId}');

        // Primero cancelar todas las notificaciones existentes de este usuario
        await _cancelUserNotifications(schedule.userId);

        // Schedule new notification if enabled
        if (schedule.isEnabled) {
          final notificationResult = await notificationRepository
              .scheduleNotificationsForUserSchedules(schedule.userId);

          notificationResult.fold(
            (failure) {
              debugPrint(
                  '❌ Error al reprogramar notificaciones: ${failure.message}');
              emit(ScheduleError(
                'Schedule actualizado pero error al reprogramar notificaciones: ${failure.message}',
              ));
            },
            (count) {
              debugPrint('✅ $count notificaciones reprogramadas');
              emit(ScheduleOperationSuccess(
                'Schedule updated successfully',
                userId: schedule.userId,
              ));
            },
          );
        } else {
          debugPrint('ℹ️ Schedule deshabilitado, notificaciones canceladas');
          emit(ScheduleOperationSuccess(
            'Schedule updated successfully',
            userId: schedule.userId,
          ));
        }
      },
    );
  }

  Future<void> _onDeleteSchedule(
    DeleteScheduleEvent event,
    Emitter<ScheduleState> emit,
  ) async {
    emit(ScheduleLoading());

    final result = await deleteSchedule(
      DeleteScheduleParams(id: event.id),
    );

    await result.fold(
      (failure) async => emit(ScheduleError(failure.message)),
      (_) async {
        debugPrint('✅ Schedule eliminado: ${event.id}');

        // 🔔 Reprogramar notificaciones del usuario (sin el schedule eliminado)
        debugPrint(
            '🔄 Reprogramando notificaciones del usuario ${event.userId}');

        await _cancelUserNotifications(event.userId);

        final notificationResult = await notificationRepository
            .scheduleNotificationsForUserSchedules(event.userId);

        notificationResult.fold(
          (failure) {
            debugPrint(
                '❌ Error al reprogramar notificaciones: ${failure.message}');
            // Aún así marcamos el schedule como eliminado
            emit(ScheduleOperationSuccess(
              'Schedule deleted successfully',
              userId: event.userId,
            ));
          },
          (count) {
            debugPrint(
                '✅ $count notificaciones reprogramadas después de eliminar');
            emit(ScheduleOperationSuccess(
              'Schedule deleted successfully',
              userId: event.userId,
            ));
          },
        );
      },
    );
  }

  Future<void> _onToggleSchedule(
    ToggleScheduleEvent event,
    Emitter<ScheduleState> emit,
  ) async {
    final toggledSchedule = event.schedule.copyWith(
      isEnabled: !event.schedule.isEnabled,
      updatedAt: DateTime.now(),
    );

    add(UpdateScheduleEvent(toggledSchedule));
  }

  /// Cancela todas las notificaciones de un usuario
  Future<void> _cancelUserNotifications(String userId) async {
    debugPrint('🛑 Cancelando notificaciones del usuario $userId');

    final result = await notificationRepository.cancelAllNotifications();

    result.fold(
      (failure) =>
          debugPrint('❌ Error al cancelar notificaciones: ${failure.message}'),
      (_) => debugPrint('✅ Notificaciones canceladas'),
    );
  }
}
