import 'package:dartz/dartz.dart';
import 'package:mta/core/error/failures.dart';
import 'package:mta/features/measurements/domain/repositories/measurement_repository.dart';
import 'package:mta/features/notifications/data/datasources/notification_native_data_source.dart';
import 'package:mta/features/notifications/data/models/notification_strings.dart';
import 'package:mta/features/notifications/domain/entities/notification_entity.dart';
import 'package:mta/features/notifications/domain/repositories/notification_repository.dart';
import 'package:mta/features/schedules/domain/entities/schedule_entity.dart';
import 'package:mta/features/schedules/domain/repositories/schedule_repository.dart';
import 'package:mta/features/users/domain/entities/user_entity.dart';
import 'package:mta/features/users/domain/repositories/user_repository.dart';
import 'package:flutter/widgets.dart';
import 'package:mta/core/l10n/app_localizations.dart';

/// Implementación del repositorio de notificaciones
class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationNativeDataSource dataSource;
  final UserRepository userRepository;
  final ScheduleRepository scheduleRepository;
  final MeasurementRepository measurementRepository;

  NotificationRepositoryImpl({
    required this.dataSource,
    required this.userRepository,
    required this.scheduleRepository,
    required this.measurementRepository,
  });

  @override
  Future<Either<Failure, void>> scheduleNotification(
      NotificationEntity notification) async {
    try {
      final strings = await _loadLocalizedStrings(notification.userId);
      await dataSource.scheduleNotification(notification, strings: strings);
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
      // Necesitamos el userId para cargar el idioma
      final activeNotifications = await dataSource.getActiveNotifications();
      String? userId;
      try {
        final notification =
            activeNotifications.firstWhere((n) => n.id == notificationId);
        userId = notification.userId;
      } catch (_) {}

      final strings =
          userId != null ? await _loadLocalizedStrings(userId) : null;
      await dataSource.snoozeNotification(notificationId, snoozeDuration,
          strings: strings);
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
    String userId,
  ) async {
    try {
      // 1. Obtener User y Schedule para reconstruir la notificación
      // Esto es necesario porque _activeNotifications en memoria se pierde al reiniciar la app
      final userResult = await userRepository.getUsers();
      UserEntity? user;
      userResult.fold(
        (_) => null,
        (users) {
          try {
            user = users.firstWhere((u) => u.id == userId);
          } catch (_) {}
        },
      );

      final schedulesResult = await scheduleRepository.getSchedules(userId);
      ScheduleEntity? schedule;
      List<ScheduleEntity> allSchedules = [];

      schedulesResult.fold(
        (_) => null,
        (schedules) {
          try {
            allSchedules = schedules;
            schedule = schedules.firstWhere((s) => s.id == scheduleId);
          } catch (_) {}
        },
      );

      if (user == null || schedule == null) {
        return Left(
            CacheFailure('No se encontró usuario o schedule para detener'));
      }

      DateTime? maxTime;

      // 2. Calcular cutoff para mañana (igual que al programar)
      if (allSchedules.isNotEmpty) {
        final sorted = List<ScheduleEntity>.from(allSchedules)
          ..sort((a, b) {
            if (a.hour != b.hour) return a.hour.compareTo(b.hour);
            return a.minute.compareTo(b.minute);
          });

        final index = sorted.indexWhere((s) => s.id == scheduleId);
        if (index != -1) {
          final next = sorted[(index + 1) % sorted.length];
          final now = DateTime.now();

          // Calculamos el próximo inicio (mañana)
          // Nota: Aquí asumimos que reprogramamos para el día siguiente del "ahora" real
          var nextTime =
              DateTime(now.year, now.month, now.day, next.hour, next.minute)
                  .add(const Duration(days: 1));

          // El cutoff es 5 min antes del siguiente pre-aviso
          maxTime = nextTime.subtract(const Duration(minutes: 5));
        }
      }

      // 3. Reconstruir la entidad (usando la hora original scheduleTime para mantener consistencia si fuera necesario,
      // pero para cancelar lo importante es el ID que se genera a partir del scheduleId)
      // Ajustamos notificationTime a la hora del schedule de HOY para que la lógica de IDs coincida
      // si se generó hoy.
      final now = DateTime.now();
      var notificationTime = DateTime(
        now.year,
        now.month,
        now.day,
        schedule!.hour,
        schedule!.minute,
      );

      // ✅ REGLA DE ORO: Si ya ha pasado, es para mañana
      if (notificationTime.isBefore(now)) {
        notificationTime = notificationTime.add(const Duration(days: 1));
      }

      final notification = NotificationEntity(
        id: 'schedule_${schedule!.id}',
        scheduleId: schedule!.id,
        userId: user!.id,
        userName: user!.name,
        notificationTime: notificationTime,
        title: 'Recordatorio de tomar la tensión',
        body: 'Es hora de registrar tu tensión',
        label: schedule!.formattedTime,
        medication: user!.medicationName,
        soundEnabled: user!.notificationSoundEnabled,
        soundUri: user!.notificationSoundUri,
        isActive: true,
      );

      final strings = await _loadLocalizedStrings(user!.id);
      await dataSource.stopNotificationsForScheduleTime(
        notification, // Pasamos la entidad completa
        scheduleTime,
        maxTime: maxTime,
        strings: strings,
      );
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(
        'Error al detener notificaciones: ${e.toString()}',
      ));
    }
  }

  @override
  Future<Either<Failure, int>> scheduleNotificationsForUserSchedules(
      String userId,
      {String? targetScheduleId}) async {
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

      // Ordenar schedules por hora para calcular cutoffs
      final sortedSchedules = List<ScheduleEntity>.from(schedules)
        ..sort((a, b) {
          if (a.hour != b.hour) return a.hour.compareTo(b.hour);
          return a.minute.compareTo(b.minute);
        });

      // --- SMART SYNC: Obtener mediciones de hoy ---
      final measurementsResult =
          await measurementRepository.getMeasurements(userId);
      final todayMeasurements = measurementsResult.getOrElse(() => []);
      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);
      final todayEnd = todayStart.add(const Duration(days: 1));

      final todayTakes = todayMeasurements.where((m) {
        return m.measurementTime.isAfter(todayStart) &&
            m.measurementTime.isBefore(todayEnd);
      }).toList();

      debugPrint(
          '🔍 Smart Sync: Encontradas ${todayTakes.length} mediciones hoy.');

      // ✅ Programar UNA notificación RECURRENTE por cada schedule
      for (int i = 0; i < sortedSchedules.length; i++) {
        final schedule = sortedSchedules[i];
        final scheduleHour = schedule.hour;
        final scheduleMinute = schedule.minute;

        // Calcular el cutoff (tiempo máximo que puede sonar este schedule)
        // El cutoff es el pre-aviso del SIGUIENTE schedule (su hora - 5 min)
        DateTime? maxTime;
        final nextSchedule = sortedSchedules[(i + 1) % sortedSchedules.length];

        final now = DateTime.now();
        var notificationTime = DateTime(
          now.year,
          now.month,
          now.day,
          scheduleHour,
          scheduleMinute,
        );

        // ✅ REGLA DE ORO: Si ya ha pasado, es para mañana
        if (notificationTime.isBefore(now)) {
          notificationTime = notificationTime.add(const Duration(days: 1));
        }

        var nextNotificationTime = DateTime(
          now.year,
          now.month,
          now.day,
          nextSchedule.hour,
          nextSchedule.minute,
        );

        // Si el siguiente es "mañana" (porque es el primero del día y estamos en el último)
        if (nextNotificationTime.isBefore(notificationTime) ||
            nextNotificationTime.isAtSameMomentAs(notificationTime)) {
          nextNotificationTime =
              nextNotificationTime.add(const Duration(days: 1));
        }

        // El cutoff es 5 minutos antes del siguiente horario (su pre-aviso)
        maxTime = nextNotificationTime.subtract(const Duration(minutes: 5));

        // --- SMART SYNC: Comprobar si ya se ha tomado hoy ---
        bool alreadyTakenToday = false;
        for (final take in todayTakes) {
          final diff =
              take.measurementTime.difference(notificationTime).inMinutes.abs();
          if (diff <= 120) {
            // Ventana de 2 horas
            alreadyTakenToday = true;
            break;
          }
        }

        // --- COLLISION LOGIC: Comprobar proximidad con otros schedules ---
        // Solo aplica si es el schedule objetivo (el que se acaba de crear/modificar)
        bool tooCloseToOther = false;
        if (targetScheduleId != null && schedule.id == targetScheduleId) {
          for (final other in sortedSchedules) {
            if (other.id == schedule.id) continue;

            // Diferencia absoluta en minutos (reloj circular)
            int t1 = scheduleHour * 60 + scheduleMinute;
            int t2 = other.hour * 60 + other.minute;
            int diff = (t1 - t2).abs();
            if (diff > 12 * 60) diff = 24 * 60 - diff;

            // Regla: si están a 60 min o menos, hay colisión
            if (diff <= 60) {
              tooCloseToOther = true;
              debugPrint(
                  '   ⚠️ Colisión detectada entre ${schedule.id} (${schedule.formattedTime}) y ${other.id} (${other.formattedTime}). Diff: ${diff}m');
              break;
            }
          }
        }

        DateTime finalNotificationTime = notificationTime;
        if (alreadyTakenToday || tooCloseToOther) {
          final reason = alreadyTakenToday ? 'ya tomado' : 'colisión';
          debugPrint(
              '   ⏭️ Schedule ${schedule.id} ($reason). Programando para MAÑANA.');
          finalNotificationTime = notificationTime.add(const Duration(days: 1));
        }

        final notification = NotificationEntity(
          id: 'schedule_${schedule.id}',
          scheduleId: schedule.id,
          userId: user.id,
          userName: user.name,
          notificationTime: finalNotificationTime,
          title: 'Recordatorio de tomar la tensión',
          body: 'Es hora de registrar tu tensión',
          label: schedule.formattedTime,
          medication: user.medicationName,
          soundEnabled: user.notificationSoundEnabled,
          soundUri: user.notificationSoundUri,
          isActive: true,
        );

        final strings = await _loadLocalizedStrings(user.id);
        await dataSource.scheduleNotification(notification,
            maxTime: maxTime, strings: strings);
        notificationsScheduled++;
        debugPrint(
            '✅ Notificación recurrente programada para schedule ${schedule.id} (Cutoff: $maxTime)');
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

  @override
  Future<Either<Failure, int>> rescheduleAllNotifications() async {
    try {
      // 1. Cancelar todas
      await dataSource.cancelAllNotifications();

      // 2. Obtener usuarios
      final usersResult = await userRepository.getUsers();
      if (usersResult.isLeft()) {
        return Left(CacheFailure('Error al obtener usuarios para reprogramar'));
      }

      final users = usersResult.getOrElse(() => []);
      int totalScheduled = 0;

      // 3. Programar para cada usuario
      for (final user in users) {
        final result = await scheduleNotificationsForUserSchedules(user.id);
        result.fold(
          (_) => null,
          (count) => totalScheduled += count,
        );
      }

      return Right(totalScheduled);
    } catch (e) {
      return Left(
          CacheFailure('Error en reprogramación general: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> testInstantNotification(
      NotificationEntity notification) async {
    try {
      final strings = await _loadLocalizedStrings(notification.userId);
      await dataSource.showInstantNotification(notification, strings: strings);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Error en prueba instantánea: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> testLogPending() async {
    try {
      await dataSource.logPendingNotifications();
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Error en log diagnóstico: ${e.toString()}'));
    }
  }

  /// Carga los strings localizados para un usuario específico sin usar context
  Future<NotificationStrings> _loadLocalizedStrings(String userId) async {
    final userResult = await userRepository.getUsers();
    final users = userResult.getOrElse(() => []);
    final user = users.firstWhere((u) => u.id == userId,
        orElse: () => throw Exception('Usuario no encontrado'));

    final l10n =
        await AppLocalizations.delegate.load(Locale(user.languageCode));

    return NotificationStrings(
      channelAlertTitle: l10n.notificationChannelAlertTitle,
      channelRepeatTitle: l10n.notificationChannelRepeatTitle,
      actionCancelled: l10n.actionCancelled,
      actionSnooze5: l10n.actionSnooze5,
      actionSnooze10: l10n.actionSnooze10,
      groupSummaryBody: l10n.groupSummaryBody('{userName}'),
      testPrefix: l10n.testPrefix,
      testNotificationBody: l10n.testNotificationBody,
      nextMeasurementTime: l10n.nextMeasurementTime('{time}'),
      measurementTimeTitle: l10n.measurementTimeTitle('{time}'),
      reminderMeasurementTitle:
          l10n.reminderMeasurementTitle('{repetition}', '{time}'),
      preAvisoBody: l10n.preAvisoBody,
      scheduledTimeBody: l10n.scheduledTimeBody,
      repeatBody: l10n.repeatBody('{minutes}'),
    );
  }
}
