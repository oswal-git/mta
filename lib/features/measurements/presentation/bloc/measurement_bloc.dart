import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mta/features/measurements/domain/usecases/create_measurement.dart';
import 'package:mta/features/measurements/domain/usecases/delete_measurement.dart';
import 'package:mta/features/measurements/domain/usecases/get_measurement_by_id.dart';
import 'package:mta/features/measurements/domain/usecases/get_measurements.dart';
import 'package:mta/features/measurements/domain/usecases/get_next_measurement_number.dart';
import 'package:mta/features/measurements/domain/usecases/backup_and_clear_measurements.dart';
import 'package:mta/features/measurements/domain/usecases/update_measurement.dart';
import 'package:mta/features/measurements/domain/usecases/auto_backup_measurements.dart';
import 'package:mta/features/measurements/domain/usecases/restore_measurements.dart';
import 'package:mta/features/measurements/presentation/bloc/measurement_event.dart';
import 'package:mta/features/measurements/presentation/bloc/measurement_state.dart';
import 'package:mta/features/notifications/domain/repositories/notification_repository.dart';
import 'package:mta/features/schedules/domain/repositories/schedule_repository.dart';
import 'package:mta/core/utils/utils_barrel.dart';

class MeasurementBloc extends Bloc<MeasurementEvent, MeasurementState> {
  final GetMeasurements getMeasurements;
  final GetMeasurementById getMeasurementById;
  final CreateMeasurement createMeasurement;
  final UpdateMeasurement updateMeasurement;
  final DeleteMeasurement deleteMeasurement;
  final BackupAndClearMeasurements backupAndClearMeasurements;
  final AutoBackupMeasurements autoBackupMeasurements;
  final RestoreMeasurements restoreMeasurements;
  final GetNextMeasurementNumber getNextMeasurementNumber;
  final NotificationRepository notificationRepository;
  final ScheduleRepository scheduleRepository;

  MeasurementBloc({
    required this.getMeasurements,
    required this.getMeasurementById,
    required this.createMeasurement,
    required this.updateMeasurement,
    required this.deleteMeasurement,
    required this.backupAndClearMeasurements,
    required this.autoBackupMeasurements,
    required this.restoreMeasurements,
    required this.getNextMeasurementNumber,
    required this.notificationRepository,
    required this.scheduleRepository,
  }) : super(MeasurementInitial()) {
    on<LoadMeasurementsEvent>(_onLoadMeasurements);
    on<LoadMeasurementByIdEvent>(_onLoadMeasurementById);
    on<CreateMeasurementEvent>(_onCreateMeasurement);
    on<UpdateMeasurementEvent>(_onUpdateMeasurement);
    on<DeleteMeasurementEvent>(_onDeleteMeasurement);
    on<ClearMeasurementsByDateRangeEvent>(_onClearMeasurementsByDateRange);
    on<GetNextMeasurementNumberEvent>(_onGetNextMeasurementNumber);
    on<AutoBackupEvent>(_onAutoBackup);
    on<RestoreMeasurementsEvent>(_onRestoreMeasurements);
  }

  Future<void> _onLoadMeasurements(
    LoadMeasurementsEvent event,
    Emitter<MeasurementState> emit,
  ) async {
    debugPrint(
        '${fechaD('🔄')} HomePage - Loading measurements for: ${event.userId}');
    emit(MeasurementLoading());

    final result = await getMeasurements(
      GetMeasurementsParams(userId: event.userId),
    );

    result.fold(
      (failure) => emit(MeasurementError(failure.message)),
      (measurements) => emit(MeasurementsLoaded(
        measurements: measurements,
        userId: event.userId,
      )),
    );
  }

  Future<void> _onLoadMeasurementById(
    LoadMeasurementByIdEvent event,
    Emitter<MeasurementState> emit,
  ) async {
    emit(MeasurementLoading());

    final result = await getMeasurementById(
      GetMeasurementByIdParams(id: event.id),
    );

    result.fold(
      (failure) => emit(MeasurementError(failure.message)),
      (measurement) => emit(MeasurementDetailLoaded(measurement)),
    );
  }

  Future<void> _onCreateMeasurement(
    CreateMeasurementEvent event,
    Emitter<MeasurementState> emit,
  ) async {
    emit(MeasurementLoading());

    final result = await createMeasurement(
      CreateMeasurementParams(measurement: event.measurement),
    );

    await result.fold(
      (failure) async => emit(MeasurementError(failure.message)),
      (measurement) async {
        debugPrint('${fechaD()} Medición creada: ${measurement.id}');

        // 🔔 Detener notificaciones relacionadas con esta medición
        await _stopNotificationsForMeasurement(measurement);

        emit(MeasurementOperationSuccess('Medición creada exitosamente',
            userId: measurement.userId));
      },
    );
  }

  Future<void> _onUpdateMeasurement(
    UpdateMeasurementEvent event,
    Emitter<MeasurementState> emit,
  ) async {
    emit(MeasurementLoading());

    final result = await updateMeasurement(
      UpdateMeasurementParams(measurement: event.measurement),
    );

    await result.fold(
      (failure) async => emit(MeasurementError(failure.message)),
      (measurement) async {
        debugPrint('${fechaD()} Medición actualizada: ${measurement.id}');

        // 🔔 Detener notificaciones relacionadas con esta medición
        await _stopNotificationsForMeasurement(measurement);

        emit(MeasurementOperationSuccess('Medición personalizada actualizada exitosamente',
            userId: measurement.userId));

        // 💾 Auto-backup (invisible)
        add(AutoBackupEvent(
          userId: measurement.userId,
          userName: event.userName,
        ));
      },
    );
  }

  Future<void> _onDeleteMeasurement(
    DeleteMeasurementEvent event,
    Emitter<MeasurementState> emit,
  ) async {
    emit(MeasurementLoading());

    final result = await deleteMeasurement(
      DeleteMeasurementParams(id: event.id),
    );

    result.fold(
      (failure) => emit(MeasurementError(failure.message)),
      (_) {
        emit(MeasurementOperationSuccess('Medición eliminada exitosamente'));

        // 💾 Auto-backup (invisible)
        add(AutoBackupEvent(
          userId: event.userId,
          userName: event.userName,
        ));
      },
    );
  }

  Future<void> _onClearMeasurementsByDateRange(
    ClearMeasurementsByDateRangeEvent event,
    Emitter<MeasurementState> emit,
  ) async {
    emit(MeasurementLoading());

    final result = await backupAndClearMeasurements(
      BackupAndClearParams(
        userId: event.userId,
        userName: event.userName,
        startDate: event.startDate,
        endDate: event.endDate,
      ),
    );

    result.fold(
      (failure) => emit(MeasurementError(failure.message)),
      (res) {
        emit(ClearMeasurementsSuccess(
          count: res.count,
          backupPath: res.backupPath,
          userId: event.userId,
        ));

        // 💾 Auto-backup (invisible) - since data was cleared, we want a fresh backup of what's left
        add(AutoBackupEvent(
          userId: event.userId,
          userName: event.userName,
        ));
      },
    );
  }

  Future<void> _onAutoBackup(
    AutoBackupEvent event,
    Emitter<MeasurementState> emit,
  ) async {
    // Auto-backup is silent, we don't emit loading or error states that interrupt the UI
    final result = await autoBackupMeasurements(
      AutoBackupParams(userId: event.userId, userName: event.userName),
    );

    result.fold(
      (failure) => debugPrint('❌ Auto-backup failed: ${failure.message}'),
      (path) => debugPrint('✅ Auto-backup success: $path'),
    );
  }

  Future<void> _onRestoreMeasurements(
    RestoreMeasurementsEvent event,
    Emitter<MeasurementState> emit,
  ) async {
    emit(MeasurementLoading());

    final result = await restoreMeasurements(
      RestoreParams(filePath: event.filePath, userId: event.userId),
    );

    result.fold(
      (failure) => emit(MeasurementError(failure.message)),
      (count) => emit(RestoreMeasurementsSuccess(
        count: count,
        userId: event.userId,
      )),
    );
  }

  Future<void> _onGetNextMeasurementNumber(
    GetNextMeasurementNumberEvent event,
    Emitter<MeasurementState> emit,
  ) async {
    final result = await getNextMeasurementNumber(
        GetNextMeasurementNumberParams(userId: event.userId, date: event.date));

    result.fold(
      (failure) => emit(MeasurementError(failure.message)),
      (number) => emit(NextMeasurementNumberLoaded(number: number)),
    );
  }

  /// Detiene las notificaciones relacionadas con una medición
  Future<void> _stopNotificationsForMeasurement(dynamic measurement) async {
    try {
      debugPrint('');
      debugPrint('${fechaD('🔄')} Verificando notificaciones para detener...');
      debugPrint(
          '${fechaD()}    Medición creada a las: ${measurement.measurementTime}');

      // Obtener todos los schedules del usuario
      final schedulesResult =
          await scheduleRepository.getSchedules(measurement.userId);

      await schedulesResult.fold(
        (failure) async {
          debugPrint('❌ Error al obtener schedules: ${failure.message}');
        },
        (schedules) async {
          final measurementDate = measurement.measurementTime as DateTime;
          final measurementTime = DateTime(
            measurementDate.year,
            measurementDate.month,
            measurementDate.day,
            measurementDate.hour,
            measurementDate.minute,
          );

          debugPrint(
              '${fechaD()}    Hora de la medición: ${measurementTime.hour}:${measurementTime.minute}');

          // Buscar schedules que correspondan a esta toma
          for (final schedule in schedules) {
            final scheduleTime = DateTime(
              measurementDate.year,
              measurementDate.month,
              measurementDate.day,
              schedule.hour,
              schedule.minute,
            );

            // Calcular diferencia en minutos (puede ser negativa si es antes)
            final differenceInMinutes =
                measurementTime.difference(scheduleTime).inMinutes;

            debugPrint(
                '${fechaD()}    Checking Schedule ${schedule.id} (${schedule.formattedTime}) | Diff: ${differenceInMinutes}m');

            bool shouldCancel = false;

            // CASO 1: Medición POSTERIOR al horario (Late)
            // Permitimos hasta 120 minutos (2 horas) después para cubrir repeticiones
            if (differenceInMinutes >= 0 && differenceInMinutes <= 120) {
              debugPrint(
                  '${fechaD('✅')}    ✅ Match: Toma posterior (dentro de 2h)');
              shouldCancel = true;
            }
            // CASO 2: Medición ANTERIOR al horario (Early / Pre-aviso)
            // Permitimos hasta 30 minutos antes (según requisito usuario)
            else if (differenceInMinutes < 0 && differenceInMinutes >= -30) {
              debugPrint(
                  '${fechaD('✅')}    ✅ Match: Toma anticipada (dentro de 30m)');
              shouldCancel = true;
            }

            if (shouldCancel) {
              debugPrint(
                  '${fechaD('🔴')}    🛑 [MATCH!] Deteniendo notificaciones para horario: ${schedule.formattedTime} (ID: ${schedule.id})');

              // Detener las notificaciones de repetición para este schedule HOY
              final result =
                  await notificationRepository.stopNotificationsForScheduleTime(
                schedule.id,
                scheduleTime,
                measurement.userId,
              );

              result.fold(
                (failure) {
                  debugPrint(
                      '${fechaD('❌')}    ❌ Error al llamar stopNotifications: ${failure.message}');
                },
                (_) {
                  debugPrint(
                      '${fechaD('✅')}    ✅ stopNotifications llamado con ÉXITO');
                },
              );
            } else {
              debugPrint(
                  '${fechaD()}    ℹ️  No match for ${schedule.formattedTime} (Diff: ${differenceInMinutes}m outside windows [-30, +120])');
            }
          }
        },
      );

      debugPrint('');
    } catch (e) {
      debugPrint('${fechaD('❌')} Error al procesar notificaciones: $e');
    }
  }
}
