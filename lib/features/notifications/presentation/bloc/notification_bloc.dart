import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mta/core/utils/logging.dart';
import 'package:mta/features/notifications/domain/repositories/notification_repository.dart';
import 'package:mta/features/notifications/domain/usecases/cancel_notification.dart';
import 'package:mta/features/notifications/domain/usecases/schedule_notification.dart';
import 'package:mta/features/notifications/domain/usecases/snooze_notification.dart';
import 'package:mta/features/notifications/utils/notification_permission_handler.dart';
import 'notification_event.dart';
import 'notification_state.dart';

/// BLoC para gestionar las notificaciones de medición
class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final ScheduleNotificationUseCase scheduleNotification;
  final CancelNotificationUseCase cancelNotification;
  final SnoozeNotificationUseCase snoozeNotification;
  final NotificationRepository repository;

  NotificationBloc({
    required this.scheduleNotification,
    required this.cancelNotification,
    required this.snoozeNotification,
    required this.repository,
  }) : super(const NotificationInitial()) {
    on<ScheduleNotification>(_onScheduleNotification);
    on<CancelNotification>(_onCancelNotification);
    on<SnoozeNotification>(_onSnoozeNotification);
    on<CancelAllNotifications>(_onCancelAllNotifications);
    on<CheckNotificationStatus>(_onCheckNotificationStatus);
    on<ScheduleNotificationsForUser>(_onScheduleNotificationsForUser);
    on<RescheduleAllNotifications>(_onRescheduleAllNotifications);
    on<MarkAsTaken>(_onMarkAsTaken);
    on<TestNotificationNow>(_onTestNotificationNow);
    on<CheckPermissionsEvent>(_onCheckPermissions);
    on<RequestPermissionsEvent>(_onRequestPermissions);
    on<LogPendingNotifications>(_onLogPendingNotifications);
  }

  Future<void> _onScheduleNotification(
    ScheduleNotification event,
    Emitter<NotificationState> emit,
  ) async {
    emit(const NotificationLoading());

    final result = await scheduleNotification(event.notification);

    result.fold(
      (failure) => emit(NotificationError(failure.message)),
      (_) => emit(const NotificationScheduled()),
    );
  }

  Future<void> _onCancelNotification(
    CancelNotification event,
    Emitter<NotificationState> emit,
  ) async {
    emit(const NotificationLoading());

    final result = await cancelNotification(event.notificationId);

    result.fold(
      (failure) => emit(NotificationError(failure.message)),
      (_) => emit(const NotificationCancelled()),
    );
  }

  /// Maneja el evento de posponer una notificacion
  Future<void> _onSnoozeNotification(
    SnoozeNotification event,
    Emitter<NotificationState> emit,
  ) async {
    emit(const NotificationLoading());

    final result = await snoozeNotification(
      SnoozeNotificationParams(
        notificationId: event.notificationId,
        snoozeDuration: event.snoozeDuration,
      ),
    );

    result.fold(
      (failure) => emit(NotificationError(failure.message)),
      (_) => emit(NotificationSnoozed(event.snoozeDuration.inMinutes)),
    );
  }

  /// Maneja el evento de cancelar todas las notificaciones
  Future<void> _onCancelAllNotifications(
    CancelAllNotifications event,
    Emitter<NotificationState> emit,
  ) async {
    emit(const NotificationLoading());

    final result = await repository.cancelAllNotifications();

    result.fold(
      (failure) => emit(NotificationError(failure.message)),
      (_) => emit(const AllNotificationsCancelled()),
    );
  }

  /// Maneja el evento de verificar el estado de una notificacion
  Future<void> _onCheckNotificationStatus(
    CheckNotificationStatus event,
    Emitter<NotificationState> emit,
  ) async {
    emit(const NotificationLoading());

    final result =
        await repository.isNotificationActive(event.notificationId.toString());

    result.fold(
      (failure) => emit(NotificationError(failure.message)),
      (isActive) => emit(NotificationStatusChecked(
        notificationId: event.notificationId,
        isActive: isActive,
      )),
    );
  }

  Future<void> _onScheduleNotificationsForUser(
    ScheduleNotificationsForUser event,
    Emitter<NotificationState> emit,
  ) async {
    debugPrint('${fechaD('🔄')} Sincronizar de urgencia');
    emit(const NotificationLoading());

    final result =
        await repository.scheduleNotificationsForUserSchedules(event.userId);

    result.fold(
      (failure) => emit(NotificationError(failure.message)),
      (count) {
        if (count == 0) {
          emit(const NotificationError(
            'No se encontraron schedules activos para programar notificaciones',
          ));
        } else {
          emit(UserNotificationsScheduled(count: count));
        }
      },
    );
  }

  /// Maneja el evento de reprogramar todas las notificaciones
  Future<void> _onRescheduleAllNotifications(
    RescheduleAllNotifications event,
    Emitter<NotificationState> emit,
  ) async {
    emit(const NotificationLoading());

    final result = await repository.rescheduleAllNotifications();

    result.fold(
      (failure) => emit(NotificationError(failure.message)),
      (count) => emit(NotificationsRescheduled(count)),
    );
  }

  Future<void> _onMarkAsTaken(
    MarkAsTaken event,
    Emitter<NotificationState> emit,
  ) async {
    emit(const NotificationLoading());

    final result = await repository.stopNotificationsForScheduleTime(
      event.scheduleId,
      event.timestamp,
      event.userId,
    );

    result.fold(
      (failure) => emit(NotificationError(failure.message)),
      (_) => emit(
          const NotificationCancelled()), // Re-usamos este estado por ahora
    );
  }

  Future<void> _onTestNotificationNow(
    TestNotificationNow event,
    Emitter<NotificationState> emit,
  ) async {
    emit(const NotificationLoading());

    final result = await repository.testInstantNotification(event.notification);

    result.fold(
      (failure) => emit(NotificationError(failure.message)),
      (_) => emit(const NotificationScheduled()),
    );
  }

  Future<void> _onCheckPermissions(
    CheckPermissionsEvent event,
    Emitter<NotificationState> emit,
  ) async {
    final hasNotification =
        await NotificationPermissionHandler.hasNotificationPermission();
    final hasExact =
        await NotificationPermissionHandler.checkExactNotificationPermission();

    emit(PermissionStatusChecked(
      hasNotificationPermission: hasNotification,
      hasExactAlarmPermission: hasExact,
    ));
  }

  Future<void> _onRequestPermissions(
    RequestPermissionsEvent event,
    Emitter<NotificationState> emit,
  ) async {
    emit(const NotificationLoading());
    await NotificationPermissionHandler.requestAllPermissions();
    add(const CheckPermissionsEvent());
  }

  Future<void> _onLogPendingNotifications(
    LogPendingNotifications event,
    Emitter<NotificationState> emit,
  ) async {
    await repository.testLogPending();
  }
}
