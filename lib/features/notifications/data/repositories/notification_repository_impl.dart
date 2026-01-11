import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:mta/core/error/failures.dart';
import 'package:mta/features/notifications/data/datasources/notification_native_data_source.dart';
import 'package:mta/features/notifications/domain/entities/notification_entity.dart';
import 'package:mta/features/notifications/domain/repositories/notification_repository.dart';
import 'package:mta/features/schedules/domain/repositories/schedule_repository.dart';
import 'package:mta/features/users/domain/repositories/user_repository.dart';

/// Implementación del repositorio de notificaciones
class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationNativeDataSource dataSource;
  final UserRepository userRepository;
  final ScheduleRepository scheduleRepository;

  NotificationRepositoryImpl({
    required this.dataSource,
    required this.userRepository,
    required this.scheduleRepository,
  });

  @override
  Future<Either<Failure, void>> scheduleNotification(
      NotificationEntity notification) async {
    try {
      await dataSource.scheduleNotification(notification);
      return const Right(null);
    } catch (e) {
      return Left(
          CacheFailure('Error al programar notificación: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> cancelNotification(
      String notificationId) async {
    try {
      await dataSource.cancelNotification(notificationId);
      return const Right(null);
    } catch (e) {
      return Left(
          CacheFailure('Error al cancelar notificación: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> snoozeNotification(
    String notificationId,
    Duration snoozeDuration,
  ) async {
    try {
      await dataSource.snoozeNotification(notificationId, snoozeDuration);
      return const Right(null);
    } catch (e) {
      return Left(
          CacheFailure('Error al posponer notificación: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> cancelAllNotifications() async {
    try {
      await dataSource.cancelAllNotifications();
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(
        'Error al cancelar todas las notificaciones: ${e.toString()}',
      ));
    }
  }

  @override
  Future<Either<Failure, bool>> isNotificationActive(
      String notificationId) async {
    try {
      final isActive = await dataSource.isNotificationActive(notificationId);
      return Right(isActive);
    } catch (e) {
      return Left(CacheFailure(
        'Error al verificar notificacion: ${e.toString()}',
      ));
    }
  }

  @override
  Future<Either<Failure, void>> stopNotificationsForScheduleTime(
    String scheduleId,
    DateTime scheduleTime,
  ) async {
    try {
      await dataSource.stopNotificationsForScheduleTime(
          scheduleId, scheduleTime);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(
        'Error al detener notificaciones: ${e.toString()}',
      ));
    }
  }

  @override
  Future<Either<Failure, int>> scheduleNotificationsForUserSchedules(
      String userId) async {
    try {
      // Obtener el usuario
      final userResult = await userRepository.getUsers();
      if (userResult.isLeft()) {
        return Left(CacheFailure('Error al obtener usuario'));
      }

      final users = userResult.getOrElse(() => []);
      final user = users.firstWhere(
        (u) => u.id == userId,
        orElse: () => throw Exception('Usuario no encontrado'),
      );

      // Obtener los schedules activos del usuario
      final schedulesResult = await scheduleRepository.getSchedules(userId);
      if (schedulesResult.isLeft()) {
        return Left(CacheFailure('Error al obtener schedules'));
      }

      final schedules = schedulesResult
          .getOrElse(() => [])
          .where((s) => s.isEnabled)
          .toList();

      int notificationsScheduled = 0;

      // ✅ Programar UNA notificación RECURRENTE por cada schedule
      for (final schedule in schedules) {
        final scheduleHour = schedule.hour;
        final scheduleMinute = schedule.minute;

        // Crear la hora de la toma para HOY (se usará solo la hora, no la fecha)
        final now = DateTime.now();
        final notificationTime = DateTime(
          now.year,
          now.month,
          now.day,
          scheduleHour,
          scheduleMinute,
        );

        final notification = NotificationEntity(
          id: 'schedule_${schedule.id}', // ID único por schedule
          scheduleId: schedule.id,
          userId: user.id,
          userName: user.name,
          notificationTime: notificationTime,
          title: 'Recordatorio de medicación',
          body: 'Es hora de tomar tu medicación',
          label: schedule.formattedTime,
          medication: user.medicationName,
          isActive: true,
        );

        final result = await scheduleNotification(notification);
        if (result.isRight()) {
          notificationsScheduled++;
          debugPrint(
              '✅ Notificación recurrente programada para schedule ${schedule.id}');
        }
      }

      debugPrint(
          '📊 Total: $notificationsScheduled notificaciones recurrentes programadas');
      return Right(notificationsScheduled);
    } catch (e) {
      return Left(CacheFailure(
        'Error al programar notificaciones para usuario: ${e.toString()}',
      ));
    }
  }
}
