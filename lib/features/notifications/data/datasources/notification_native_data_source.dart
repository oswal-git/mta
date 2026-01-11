// ============================================
// notification_native_data_source.dart
// ============================================

import 'dart:async';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
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

  // Timers para repetición de notificaciones: scheduleId -> Timer
  final Map<String, Timer> _repetitionTimers = {};

  // Intervalo de repetición (cada 10 minutos)
  static const Duration _repetitionInterval = Duration(minutes: 10);

  // Máximo de repeticiones (6 horas = 36 repeticiones de 10 min)
  static const int _maxRepetitions = 36;

  NotificationNativeDataSourceImpl({
    FlutterLocalNotificationsPlugin? notificationsPlugin,
  }) : _notificationsPlugin =
            notificationsPlugin ?? FlutterLocalNotificationsPlugin();

  @override
  Future<void> scheduleNotification(NotificationEntity notification) async {
    try {
      debugPrint('');
      debugPrint('═══════════════════════════════════════════════════════');
      debugPrint('🔔 PROGRAMANDO NOTIFICACIÓN DIARIA CON REPETICIÓN');
      debugPrint('═══════════════════════════════════════════════════════');
      debugPrint('   Schedule ID: ${notification.scheduleId}');
      debugPrint('   Usuario: ${notification.userName}');
      debugPrint(
          '   Hora toma: ${DateFormat('HH:mm').format(notification.notificationTime)}');

      // Guardar en el mapa de notificaciones activas
      _activeNotifications[notification.scheduleId] = notification;

      // Calcular la hora de la primera notificación (5 minutos antes de la toma)
      final notifHour = notification.notificationTime.hour;
      final notifMinute = notification.notificationTime.minute;

      final totalMinutes = notifHour * 60 + notifMinute - 5;
      final adjustedHour = totalMinutes ~/ 60;
      final adjustedMinute = totalMinutes % 60;

      debugPrint(
          '   Primera notificación: $adjustedHour:${adjustedMinute.toString().padLeft(2, '0')} (5 min antes)');

      // Crear la hora de notificación para HOY
      final now = tz.TZDateTime.now(tz.local);
      var scheduledDate = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        adjustedHour,
        adjustedMinute,
      );

      // Si la hora ya pasó hoy, programar para mañana
      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
        debugPrint(
            '   ⏭️  La hora ya pasó hoy, programando para: ${DateFormat('dd/MM HH:mm').format(scheduledDate)}');
      }

      // Programar la notificación diaria inicial
      await _scheduleInitialNotification(notification, scheduledDate);

      // Programar el inicio del sistema de repetición cuando llegue la hora
      _scheduleRepetitionStart(notification, scheduledDate);

      debugPrint('✅ Sistema de notificaciones configurado');
      debugPrint(
          '   - Notificación diaria: ${DateFormat('HH:mm').format(scheduledDate)}');
      debugPrint(
          '   - Repetición: cada ${_repetitionInterval.inMinutes} min después de la primera');
      debugPrint('   - Máximo: $_maxRepetitions repeticiones');
      debugPrint('═══════════════════════════════════════════════════════');
      debugPrint('');
    } catch (e, stackTrace) {
      debugPrint('');
      debugPrint('🔴 ERROR AL PROGRAMAR NOTIFICACIÓN');
      debugPrint('   Error: $e');
      debugPrint('   Stack: $stackTrace');
      debugPrint('═══════════════════════════════════════════════════════');
      rethrow;
    }
  }

  /// Programa la notificación inicial que se repite diariamente
  Future<void> _scheduleInitialNotification(
    NotificationEntity notification,
    tz.TZDateTime scheduledDate,
  ) async {
    final androidDetails = AndroidNotificationDetails(
      'measuring_notifications',
      'Notificaciones de Medición',
      channelDescription: 'Recordatorios para tomar medición',
      importance: Importance.max,
      priority: Priority.max,
      icon: '@mipmap/ic_launcher',
      playSound: true,
      sound: const RawResourceAndroidNotificationSound('notification'),
      enableVibration: true,
      vibrationPattern: Int64List.fromList([0, 1000, 500, 1000]),
      enableLights: true,
      color: const Color(0xFF2196F3),
      ledColor: const Color(0xFF0000FF),
      ledOnMs: 1000,
      ledOffMs: 500,
      category: AndroidNotificationCategory.reminder,
      visibility: NotificationVisibility.public,
      ongoing: false, // No persistente en la barra
      autoCancel: false,
      // ✅ ACCIONES DE LA NOTIFICACIÓN
      actions: <AndroidNotificationAction>[
        const AndroidNotificationAction(
          'taken',
          '✓ Tomada',
          showsUserInterface: true,
          cancelNotification: true,
        ),
        const AndroidNotificationAction(
          'snooze',
          '⏰ 5 min',
          showsUserInterface: false,
          cancelNotification: false,
        ),
      ],
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    // Programar notificación diaria recurrente
    await _notificationsPlugin.zonedSchedule(
      notification.notificationId,
      _buildTitle(notification, repetition: 0),
      _buildBody(notification, repetition: 0),
      scheduledDate,
      NotificationDetails(android: androidDetails, iOS: iosDetails),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time, // Se repite diariamente
      payload:
          '${notification.scheduleId}|0', // payload: scheduleId|repetitionNumber
    );
  }

  /// Programa el inicio del sistema de repetición
  void _scheduleRepetitionStart(
    NotificationEntity notification,
    tz.TZDateTime firstNotificationTime,
  ) {
    // Cancelar timer previo si existe
    _repetitionTimers[notification.scheduleId]?.cancel();

    // Calcular cuándo debe empezar la repetición (después de la primera notificación)
    final now = DateTime.now();
    final firstNotif = firstNotificationTime.toLocal();

    Duration delayUntilFirstNotification;

    if (firstNotif.isAfter(now)) {
      // La primera notificación aún no ha sonado
      delayUntilFirstNotification = firstNotif.difference(now);
    } else {
      // La primera notificación ya debería haber sonado hoy
      // Empezar las repeticiones ahora
      delayUntilFirstNotification = Duration.zero;
    }

    debugPrint(
        '⏰ Sistema de repetición se activará en: ${delayUntilFirstNotification.inMinutes} minutos');

    // Esperar hasta la primera notificación, luego comenzar las repeticiones
    Timer(delayUntilFirstNotification, () {
      _startRepetitionTimer(notification);
    });
  }

  /// Inicia el timer de repeticiones
  void _startRepetitionTimer(NotificationEntity notification) {
    // Verificar que la notificación sigue activa
    if (!_activeNotifications.containsKey(notification.scheduleId)) {
      debugPrint(
          '⚠️  Notificación ${notification.scheduleId} ya no está activa');
      return;
    }

    debugPrint('');
    debugPrint('🔄 INICIANDO SISTEMA DE REPETICIÓN');
    debugPrint('   Schedule ID: ${notification.scheduleId}');
    debugPrint('   Intervalo: ${_repetitionInterval.inMinutes} minutos');

    int repetitionCount = 0;

    _repetitionTimers[notification.scheduleId] = Timer.periodic(
      _repetitionInterval,
      (timer) async {
        repetitionCount++;

        debugPrint(
            '🔔 Repetición #$repetitionCount para ${notification.scheduleId}');

        // Verificar si la notificación sigue activa
        if (!_activeNotifications.containsKey(notification.scheduleId)) {
          debugPrint('🛑 Notificación cancelada, deteniendo repeticiones');
          timer.cancel();
          _repetitionTimers.remove(notification.scheduleId);
          return;
        }

        // Verificar si se alcanzó el máximo de repeticiones
        if (repetitionCount >= _maxRepetitions) {
          debugPrint('⚠️  Máximo de repeticiones alcanzado');
          timer.cancel();
          _repetitionTimers.remove(notification.scheduleId);
          return;
        }

        // Verificar si ya llegó la hora del siguiente schedule
        if (await _shouldStopForNextSchedule(notification)) {
          debugPrint('⏭️  Llegó la hora del siguiente horario, deteniendo');
          timer.cancel();
          _repetitionTimers.remove(notification.scheduleId);
          return;
        }

        // Mostrar la notificación de repetición
        try {
          await _showRepetitionNotification(notification, repetitionCount);
          debugPrint('✅ Notificación de repetición mostrada');
        } catch (e) {
          debugPrint('❌ Error al mostrar repetición: $e');
        }
      },
    );
  }

  /// Muestra una notificación de repetición
  Future<void> _showRepetitionNotification(
    NotificationEntity notification,
    int repetitionNumber,
  ) async {
    // Usar un ID diferente para cada repetición
    final repetitionId = notification.notificationId + repetitionNumber;

    final androidDetails = AndroidNotificationDetails(
      'measuring_notifications_repeat',
      'Recordatorios Repetidos',
      channelDescription: 'Notificaciones repetidas para medición no tomada',
      importance: Importance.max,
      priority: Priority.max,
      icon: '@mipmap/ic_launcher',
      playSound: true,
      sound: const RawResourceAndroidNotificationSound('notification'),
      enableVibration: true,
      vibrationPattern: Int64List.fromList([0, 1000, 500, 1000]),
      enableLights: true,
      color: const Color(0xFFFF9800), // Naranja para indicar repetición
      ledColor: const Color(0xFFFF9800),
      ledOnMs: 1000,
      ledOffMs: 500,
      category: AndroidNotificationCategory.reminder,
      visibility: NotificationVisibility.public,
      tag: notification
          .scheduleId, // Mismo tag para reemplazar notificación anterior
      ongoing: false,
      autoCancel: false,
      // ✅ ACCIONES DE LA NOTIFICACIÓN DE REPETICIÓN
      actions: <AndroidNotificationAction>[
        const AndroidNotificationAction(
          'taken',
          '✓ Tomada',
          showsUserInterface: true,
          cancelNotification: true,
        ),
        const AndroidNotificationAction(
          'snooze',
          '⏰ 5 min',
          showsUserInterface: false,
          cancelNotification: false,
        ),
      ],
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    await _notificationsPlugin.show(
      repetitionId,
      _buildTitle(notification, repetition: repetitionNumber),
      _buildBody(notification, repetition: repetitionNumber),
      NotificationDetails(android: androidDetails, iOS: iosDetails),
      payload: '${notification.scheduleId}|$repetitionNumber',
    );
  }

  /// Verifica si debe detenerse por el siguiente schedule
  Future<bool> _shouldStopForNextSchedule(
      NotificationEntity notification) async {
    // Aquí deberías verificar si ya llegó la hora del siguiente schedule
    // Por ahora, verificamos si ya pasó la hora de toma + 6 horas
    final now = DateTime.now();
    final scheduleTime = notification.notificationTime;
    final cutoffTime = DateTime(
      now.year,
      now.month,
      now.day,
      scheduleTime.hour,
      scheduleTime.minute,
    ).add(const Duration(hours: 6));

    return now.isAfter(cutoffTime);
  }

  @override
  Future<void> snoozeNotification(
      String notificationId, Duration snoozeDuration) async {
    try {
      debugPrint(
          '⏰ Posponiendo notificación: $notificationId por ${snoozeDuration.inMinutes} min');

      final originalNotification = _activeNotifications[notificationId];
      if (originalNotification == null) {
        throw Exception('Notificación no encontrada');
      }

      // Para snooze, crear una notificación ÚNICA (no recurrente)
      final now = tz.TZDateTime.now(tz.local);
      final snoozedTime = now.add(snoozeDuration);

      final androidDetails = AndroidNotificationDetails(
        'medication_notifications_snooze',
        'Notificaciones Pospuestas',
        channelDescription: 'Notificaciones de medicación pospuestas',
        importance: Importance.max,
        priority: Priority.max,
        icon: '@mipmap/ic_launcher',
        playSound: true,
        sound: const RawResourceAndroidNotificationSound('notification'),
        enableVibration: true,
        category: AndroidNotificationCategory.reminder,
        actions: <AndroidNotificationAction>[
          const AndroidNotificationAction(
            'taken',
            '✓ Tomada',
            showsUserInterface: true,
            cancelNotification: true,
          ),
        ],
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      // Usar un ID diferente para el snooze (añadir "_snooze")
      final snoozeId = originalNotification.notificationId + 1000000;

      await _notificationsPlugin.zonedSchedule(
        snoozeId,
        '⏰ ${_buildTitle(originalNotification, repetition: 0)}',
        'Recordatorio pospuesto\n${_buildBody(originalNotification, repetition: 0)}',
        snoozedTime,
        NotificationDetails(android: androidDetails, iOS: iosDetails),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: originalNotification.scheduleId,
      );

      debugPrint(
          '✅ Notificación pospuesta a: ${DateFormat('HH:mm').format(snoozedTime)}');
      debugPrint('   (La notificación recurrente original sigue activa)');
    } catch (e) {
      debugPrint('❌ Error al posponer: $e');
      rethrow;
    }
  }

  @override
  Future<void> cancelNotification(String notificationId) async {
    try {
      debugPrint('🛑 Cancelando notificación: $notificationId');

      final notification = _activeNotifications[notificationId];
      if (notification != null) {
        // Cancelar la notificación diaria
        await _notificationsPlugin.cancel(notification.notificationId);

        // Detener el timer de repeticiones
        _repetitionTimers[notificationId]?.cancel();
        _repetitionTimers.remove(notificationId);

        // Cancelar todas las notificaciones de repetición
        for (int i = 1; i <= _maxRepetitions; i++) {
          await _notificationsPlugin.cancel(notification.notificationId + i);
        }

        _activeNotifications.remove(notificationId);
        debugPrint('   ✅ Notificación y repeticiones canceladas');
      }
    } catch (e) {
      debugPrint('❌ Error al cancelar: $e');
      rethrow;
    }
  }

  @override
  Future<void> cancelNotificationsForSchedule(String scheduleId) async {
    await cancelNotification(scheduleId);
  }

  @override
  Future<void> stopNotificationsForScheduleTime(
    String scheduleId,
    DateTime scheduleTime,
  ) async {
    debugPrint('');
    debugPrint('✅ MEDICACIÓN TOMADA - Deteniendo notificaciones');
    debugPrint('   Schedule ID: $scheduleId');
    debugPrint('   Hora: ${DateFormat('HH:mm').format(scheduleTime)}');

    // Detener el timer de repeticiones
    _repetitionTimers[scheduleId]?.cancel();
    _repetitionTimers.remove(scheduleId);

    // Cancelar las notificaciones de repetición (pero mantener la diaria para mañana)
    final notification = _activeNotifications[scheduleId];
    if (notification != null) {
      for (int i = 1; i <= _maxRepetitions; i++) {
        await _notificationsPlugin.cancel(notification.notificationId + i);
      }
    }

    debugPrint(
        '   ✅ Repeticiones detenidas (notificación diaria sigue activa)');
    debugPrint('');
  }

  @override
  Future<void> cancelAllNotifications() async {
    try {
      debugPrint('🛑 Cancelando todas las notificaciones...');

      // Detener todos los timers
      for (var timer in _repetitionTimers.values) {
        timer.cancel();
      }
      _repetitionTimers.clear();

      await _notificationsPlugin.cancelAll();
      final count = _activeNotifications.length;
      _activeNotifications.clear();

      debugPrint('✅ $count notificaciones canceladas');
    } catch (e) {
      debugPrint('❌ Error al cancelar todas: $e');
      rethrow;
    }
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
    if (repetition == 0) {
      return '💊 ${notification.userName} - Hora de medición';
    } else {
      return '⚠️ ${notification.userName} - ¡Recuerda tomar tu medición!';
    }
  }

  String _buildBody(NotificationEntity notification,
      {required int repetition}) {
    final buffer = StringBuffer();

    if (repetition == 0) {
      buffer.write('Es hora de tomar tu medición');
    } else {
      final elapsed = repetition * _repetitionInterval.inMinutes;
      buffer.write('Han pasado $elapsed minutos desde el recordatorio inicial');
    }

    if (notification.label != null && notification.label!.isNotEmpty) {
      buffer.write('\n🕐 ${notification.label}');
    }

    if (notification.medication != null &&
        notification.medication!.isNotEmpty) {
      buffer.write('\n💊 ${notification.medication}');
    }

    if (repetition > 0) {
      buffer.write('\n\n👆 Toca la notificación para registrar tu toma');
    }

    return buffer.toString();
  }
}
