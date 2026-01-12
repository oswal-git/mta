import 'dart:async';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mta/features/notifications/domain/entities/notification_entity.dart';
import 'package:timezone/timezone.dart' as tz;

/// Data source para gestionar notificaciones persistentes con repetición
abstract class NotificationNativeDataSource {
  Future<void> scheduleNotification(NotificationEntity notification);
  Future<void> cancelNotification(String notificationId);
  Future<void> snoozeNotification(
      String notificationId, Duration snoozeDuration);
  Future<void> cancelNotificationsForSchedule(String scheduleId);
  Future<void> stopNotificationsForScheduleTime(
      String scheduleId, DateTime scheduleTime);
  Future<void> cancelAllNotifications();
  Future<bool> isNotificationActive(String notificationId);
  Future<List<NotificationEntity>> getActiveNotifications();
}

class NotificationNativeDataSourceImpl implements NotificationNativeDataSource {
  final FlutterLocalNotificationsPlugin _notificationsPlugin;

  // Mapa de notificaciones programadas: scheduleId -> NotificationEntity
  final Map<String, NotificationEntity> _activeNotifications = {};

  // Intervalo de repetición (cada 10 minutos)
  static const Duration _repetitionInterval = Duration(minutes: 10);

  // Máximo de repeticiones
  static const int _maxRepetitions = 6;

  NotificationNativeDataSourceImpl({
    FlutterLocalNotificationsPlugin? notificationsPlugin,
  }) : _notificationsPlugin =
            notificationsPlugin ?? FlutterLocalNotificationsPlugin();

  @override
  Future<void> scheduleNotification(NotificationEntity notification) async {
    try {
      debugPrint('🔔 PROGRAMANDO NOTIFICACIONES DIARIAS (SISTEMA OS)');
      debugPrint('   Schedule ID: ${notification.scheduleId}');

      _activeNotifications[notification.scheduleId] = notification;

      // 1. Programar la notificación principal (5 min antes)
      final mainTime =
          notification.notificationTime.subtract(const Duration(minutes: 5));
      await _scheduleSingleRepeatingNotification(notification, mainTime, 0);

      // 2. Programar las repeticiones
      for (int i = 1; i <= _maxRepetitions; i++) {
        final repTime = mainTime.add(_repetitionInterval * i);
        await _scheduleSingleRepeatingNotification(notification, repTime, i);
      }

      debugPrint('✅ Sistema de notificaciones programado en el OS');
    } catch (e) {
      debugPrint('🔴 ERROR AL PROGRAMAR: $e');
      rethrow;
    }
  }

  Future<void> _scheduleSingleRepeatingNotification(
    NotificationEntity notification,
    DateTime time,
    int index,
  ) async {
    final tzTime = _nextInstanceOfTime(time);
    final id =
        notification.notificationId + (index * 100); // Espaciado para IDs

    final androidDetails = AndroidNotificationDetails(
      index == 0 ? 'measuring_notifications' : 'measuring_notifications_repeat',
      index == 0 ? 'Notificaciones de Medición' : 'Recordatorios Repetidos',
      importance: Importance.max,
      priority: Priority.max,
      icon: '@mipmap/ic_launcher',
      playSound: true,
      sound: const RawResourceAndroidNotificationSound('notification'),
      enableVibration: true,
      color: index == 0 ? const Color(0xFF2196F3) : const Color(0xFFFF9800),
      category: AndroidNotificationCategory.reminder,
      actions: <AndroidNotificationAction>[
        const AndroidNotificationAction('taken', '✓ Tomada',
            showsUserInterface: true, cancelNotification: true),
        const AndroidNotificationAction('snooze', '⏰ 5 min',
            showsUserInterface: false, cancelNotification: false),
      ],
    );

    await _notificationsPlugin.zonedSchedule(
      id,
      _buildTitle(notification, repetition: index),
      _buildBody(notification, repetition: index),
      tzTime,
      NotificationDetails(
          android: androidDetails, iOS: const DarwinNotificationDetails()),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: '${notification.scheduleId}|$index',
    );
  }

  tz.TZDateTime _nextInstanceOfTime(DateTime time) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  @override
  Future<void> cancelNotification(String notificationId) async {
    final notification = _activeNotifications[notificationId];
    if (notification != null) {
      final baseId = notification.notificationId;
      for (int i = 0; i <= _maxRepetitions; i++) {
        await _notificationsPlugin.cancel(baseId + (i * 100));
      }
      _activeNotifications.remove(notificationId);
      debugPrint('🛑 Notificaciones canceladas para $notificationId');
    }
  }

  @override
  Future<void> stopNotificationsForScheduleTime(
      String scheduleId, DateTime scheduleTime) async {
    // Cuando el usuario marca como tomada, cancelamos las repeticiones de HOY.
    // Pero como son recurrentes, si las cancelamos se borran para siempre.
    // Estrategia: Cancelar todas y volver a programarlas para MAÑANA.

    final notification = _activeNotifications[scheduleId];
    if (notification != null) {
      debugPrint('💊 Medicación tomada, reprogramando para mañana...');

      // 1. Cancelar todas las actuales (incluyendo las de hoy que faltan)
      final baseId = notification.notificationId;
      for (int i = 0; i <= _maxRepetitions; i++) {
        await _notificationsPlugin.cancel(baseId + (i * 100));
      }

      // 2. Reprogramar para mañana
      // Forzamos que la fecha inicial sea mañana
      final mainTime =
          notification.notificationTime.subtract(const Duration(minutes: 5));
      for (int i = 0; i <= _maxRepetitions; i++) {
        final repTime = mainTime.add(_repetitionInterval * i);
        final tzTime = _nextInstanceOfTime(repTime);

        // Si la hora calculada por _nextInstanceOfTime es HOY (porque aún no ha pasado),
        // forzamos a que sea mañana.
        var finalTzTime = tzTime;
        final now = tz.TZDateTime.now(tz.local);
        if (finalTzTime.day == now.day &&
            finalTzTime.month == now.month &&
            finalTzTime.year == now.year) {
          finalTzTime = finalTzTime.add(const Duration(days: 1));
        }

        final id = baseId + (i * 100);
        await _notificationsPlugin.zonedSchedule(
          id,
          _buildTitle(notification, repetition: i),
          _buildBody(notification, repetition: i),
          finalTzTime,
          NotificationDetails(
            android: AndroidNotificationDetails(
              i == 0
                  ? 'measuring_notifications'
                  : 'measuring_notifications_repeat',
              i == 0 ? 'Notificaciones de Medición' : 'Recordatorios Repetidos',
              importance: Importance.max,
              priority: Priority.max,
              icon: '@mipmap/ic_launcher',
              playSound: true,
              sound: const RawResourceAndroidNotificationSound('notification'),
              enableVibration: true,
            ),
          ),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.time,
          payload: '${notification.scheduleId}|$i',
        );
      }
      debugPrint('✅ Notificaciones reprogramadas para empezar mañana');
    }
  }

  @override
  Future<void> snoozeNotification(
      String notificationId, Duration snoozeDuration) async {
    final notification = _activeNotifications[notificationId];
    if (notification == null) return;

    final now = tz.TZDateTime.now(tz.local);
    final snoozedTime = now.add(snoozeDuration);

    await _notificationsPlugin.zonedSchedule(
      notification.notificationId + 999, // ID único para snooze
      '⏰ ${_buildTitle(notification, repetition: 0)}',
      'Recordatorio pospuesto',
      snoozedTime,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'medication_notifications_snooze',
          'Notificaciones Pospuestas',
          importance: Importance.max,
          priority: Priority.max,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: notification.scheduleId,
    );
  }

  @override
  Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
    _activeNotifications.clear();
  }

  @override
  Future<void> cancelNotificationsForSchedule(String scheduleId) async {
    await cancelNotification(scheduleId);
  }

  @override
  Future<bool> isNotificationActive(String notificationId) async {
    return _activeNotifications.containsKey(notificationId);
  }

  @override
  Future<List<NotificationEntity>> getActiveNotifications() async {
    return _activeNotifications.values.toList();
  }

  String _buildTitle(NotificationEntity notification,
      {required int repetition}) {
    return repetition == 0
        ? '💊 ${notification.userName} - Hora de medición'
        : '⚠️ ${notification.userName} - ¡Recuerda tu medición!';
  }

  String _buildBody(NotificationEntity notification,
      {required int repetition}) {
    final buffer = StringBuffer();
    if (repetition == 0) {
      buffer.write('Es hora de tomar tu medición');
    } else {
      buffer.write(
          'Han pasado ${repetition * 10} minutos desde el aviso inicial');
    }
    if (notification.label?.isNotEmpty ?? false) {
      buffer.write('\n🕐 ${notification.label}');
    }
    if (notification.medication?.isNotEmpty ?? false) {
      buffer.write('\n💊 ${notification.medication}');
    }
    return buffer.toString();
  }
}
