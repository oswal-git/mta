import 'package:equatable/equatable.dart';
import 'package:mta/features/notifications/domain/entities/notification_entity.dart';

abstract class NotificationEvent extends Equatable {
  const NotificationEvent();

  @override
  List<Object?> get props => [];
}

class ScheduleNotification extends NotificationEvent {
  final NotificationEntity notification;

  const ScheduleNotification(this.notification);

  @override
  List<Object?> get props => [notification];
}

class CancelNotification extends NotificationEvent {
  final String notificationId;

  const CancelNotification(this.notificationId);

  @override
  List<Object?> get props => [notificationId];
}

// ✅ ALIAS para compatibilidad con notification_ring_page.dart
class StopNotification extends CancelNotification {
  const StopNotification(super.notificationId);
}

class SnoozeNotification extends NotificationEvent {
  final String notificationId;
  final Duration snoozeDuration;

  const SnoozeNotification({
    required this.notificationId,
    required this.snoozeDuration,
  });

  @override
  List<Object?> get props => [notificationId, snoozeDuration];
}

class CancelAllNotifications extends NotificationEvent {
  const CancelAllNotifications();
}

class CheckNotificationStatus extends NotificationEvent {
  final String notificationId;

  const CheckNotificationStatus(this.notificationId);

  @override
  List<Object?> get props => [notificationId];
}

class ScheduleNotificationsForUser extends NotificationEvent {
  final String userId;

  const ScheduleNotificationsForUser(this.userId);

  @override
  List<Object?> get props => [userId];
}

class RescheduleAllNotifications extends NotificationEvent {
  const RescheduleAllNotifications();
}
