import 'package:dartz/dartz.dart';
import 'package:mta/core/error/failures.dart';
import 'package:mta/features/notifications/domain/entities/notification_entity.dart';

abstract class NotificationRepository {
  Future<Either<Failure, void>> scheduleNotification(
      NotificationEntity notification);
  Future<Either<Failure, void>> cancelNotification(String notificationId);
  Future<Either<Failure, void>> snoozeNotification(
      String notificationId, Duration snoozeDuration);
  Future<Either<Failure, void>> cancelAllNotifications();
  Future<Either<Failure, bool>> isNotificationActive(String notificationId);
  Future<Either<Failure, int>> scheduleNotificationsForUserSchedules(
      String userId);
  Future<Either<Failure, void>> stopNotificationsForScheduleTime(
      String scheduleId, DateTime scheduleTime);
}
