import 'package:equatable/equatable.dart';

abstract class NotificationState extends Equatable {
  const NotificationState();

  @override
  List<Object?> get props => [];
}

class NotificationInitial extends NotificationState {
  const NotificationInitial();
}

class NotificationLoading extends NotificationState {
  const NotificationLoading();
}

/// Estado cuando una notificación se programó exitosamente
class NotificationScheduled extends NotificationState {
  final String message;

  const NotificationScheduled({
    this.message = 'notificationScheduledDefault',
  });

  @override
  List<Object?> get props => [message];
}

// ✅ ALIAS para compatibilidad
class NotificationSet extends NotificationScheduled {
  const NotificationSet({super.message});
}

/// Estado cuando una notificación se canceló exitosamente
class NotificationCancelled extends NotificationState {
  final String message;

  const NotificationCancelled({
    this.message = 'notificationCancelledDefault',
  });

  @override
  List<Object?> get props => [message];
}

// ✅ ALIAS para compatibilidad
class NotificationStopped extends NotificationCancelled {
  const NotificationStopped({super.message});
}

class NotificationSnoozed extends NotificationState {
  final int minutes;

  const NotificationSnoozed(this.minutes);

  @override
  List<Object?> get props => [minutes];
}

/// Estado cuando todas las notificaciones se cancelaron
class AllNotificationsCancelled extends NotificationState {
  final String message;

  const AllNotificationsCancelled({
    this.message = 'allNotificationsCancelledDefault',
  });

  @override
  List<Object?> get props => [message];
}

class NotificationStatusChecked extends NotificationState {
  final String notificationId;
  final bool isActive;

  const NotificationStatusChecked({
    required this.notificationId,
    required this.isActive,
  });

  @override
  List<Object?> get props => [notificationId, isActive];
}

/// Estado cuando se programaron múltiples notificaciones para un usuario
class UserNotificationsScheduled extends NotificationState {
  final int count;
  final String message;

  const UserNotificationsScheduled({
    required this.count,
    String? message,
  }) : message = message ?? 'userNotificationsScheduled';

  @override
  List<Object?> get props => [count, message];
}

// ✅ ALIAS para compatibilidad
class UserNotificationsSet extends UserNotificationsScheduled {
  const UserNotificationsSet({required super.count, super.message});
}

class NotificationsRescheduled extends NotificationState {
  final int count;

  const NotificationsRescheduled(this.count);

  @override
  List<Object?> get props => [count];
}

class NotificationError extends NotificationState {
  final String message;

  const NotificationError(this.message);

  @override
  List<Object?> get props => [message];
}

class PermissionStatusChecked extends NotificationState {
  final bool hasNotificationPermission;
  final bool hasExactAlarmPermission;

  const PermissionStatusChecked({
    required this.hasNotificationPermission,
    required this.hasExactAlarmPermission,
  });

  @override
  List<Object?> get props =>
      [hasNotificationPermission, hasExactAlarmPermission];
}
