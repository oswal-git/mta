import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mta/features/notifications/domain/entities/notification_entity.dart';
import 'package:timezone/timezone.dart' as tz;

/// Data source para gestionar notificaciones persistentes con repetición
abstract class NotificationNativeDataSource {
  Future<void> scheduleNotification(NotificationEntity notification,
      {DateTime? maxTime});
  Future<void> cancelNotification(String notificationId);
  Future<void> snoozeNotification(
      String notificationId, Duration snoozeDuration);
  Future<void> cancelNotificationsForSchedule(String scheduleId);
  Future<void> stopNotificationsForScheduleTime(
      NotificationEntity notification, DateTime scheduleTime,
      {DateTime? maxTime});
  Future<void> cancelAllNotifications();
  Future<bool> isNotificationActive(String notificationId);
  Future<List<NotificationEntity>> getActiveNotifications();
  Future<void> showInstantNotification(NotificationEntity notification);
  Future<void> logPendingNotifications();
}

class NotificationNativeDataSourceImpl implements NotificationNativeDataSource {
  final FlutterLocalNotificationsPlugin _notificationsPlugin;

  // Mapa de notificaciones programadas: scheduleId -> NotificationEntity
  final Map<String, NotificationEntity> _activeNotifications = {};

  // Intervalo de repetición (cada 10 minutos)
  static const Duration _repetitionInterval = Duration(minutes: 10);

  // Máximo de repeticiones (después de la principal)
  static const int _maxRepetitions = 6;

  NotificationNativeDataSourceImpl({
    FlutterLocalNotificationsPlugin? notificationsPlugin,
  }) : _notificationsPlugin =
            notificationsPlugin ?? FlutterLocalNotificationsPlugin();

  @override
  Future<void> scheduleNotification(NotificationEntity notification,
      {DateTime? maxTime}) async {
    try {
      debugPrint('🔔 PROGRAMANDO NOTIFICACIONES DIARIAS (SISTEMA OS)');
      debugPrint('   Schedule ID: ${notification.scheduleId}');

      _activeNotifications[notification.scheduleId] = notification;

      // 1. Programar PRE-AVISO (5 min antes)
      // ✅ Solo si NO es una prueba simple
      if (!notification.id.startsWith('simple_test')) {
        final preTime =
            notification.notificationTime.subtract(const Duration(minutes: 5));
        await _scheduleSingleRepeatingNotification(notification, preTime, -1);
      }

      // Especial para pruebas de depuración (IDs numéricos fijos para evitar errores de hash)
      int? forcedId;
      if (notification.id.startsWith('test_now')) forcedId = 777000;
      if (notification.id.startsWith('test_soon')) forcedId = 777060;
      if (notification.id.startsWith('simple_test')) forcedId = 777010;

      // 2. Programar notificación PRINCIPAL (Hora exacta)
      await _scheduleSingleRepeatingNotification(
          notification, notification.notificationTime, 0,
          forcedId: forcedId);

      // Log inmediato para confirmar que está en la cola
      await logPendingNotifications();

      // 3. Programar las REPETICIONES (cada 10 min después)
      // ✅ Solo si NO es una prueba simple
      if (!notification.id.startsWith('simple_test')) {
        for (int i = 1; i <= _maxRepetitions; i++) {
          final repTime =
              notification.notificationTime.add(_repetitionInterval * i);

          // Si hay tiempo máximo y esta repetición se pasa, no la programamos
          if (maxTime != null && repTime.isAfter(maxTime)) {
            debugPrint(
                '   ⚠️ Omitiendo repetición $i porque supera el cutoff ($maxTime)');
            continue;
          }

          await _scheduleSingleRepeatingNotification(notification, repTime, i);
        }
      }

      debugPrint(
          '✅ Sistema de notificaciones programado en el OS (Pre-aviso, Principal y Repeticiones) para ${notification.id}');
    } catch (e) {
      debugPrint(
          '🔴 ERROR AL PROGRAMAR schedule ${notification.scheduleId}: $e');
      rethrow;
    }
  }

  /// Programamos una única notificación recurrente en el OS
  Future<void> _scheduleSingleRepeatingNotification(
      NotificationEntity notification, DateTime time, int index,
      {int? forcedId}) async {
    final tzTime = _nextInstanceOfTime(time);
    final baseId = notification.notificationId;

    // Mapeo seguro de ID: si no hay forzado, usamos la lógica de offsets
    final id = forcedId ?? (baseId + ((index + 1) * 100));

    debugPrint('   - Absolute Epoch: ${tzTime.millisecondsSinceEpoch}');
    debugPrint(
        '   - Diff From Now: ${tzTime.difference(tz.TZDateTime.now(tz.local)).inSeconds}s');

    debugPrint('🚀 [OS Handshake - START] ID: $id | Time: $tzTime');
    await _notificationsPlugin.zonedSchedule(
      id,
      _buildTitle(notification, repetition: index),
      _buildBody(notification, repetition: index),
      tzTime,
      NotificationDetails(
        android: AndroidNotificationDetails(
          index <= 0 ? 'mta_notifications_v5' : 'mta_notifications_repeat_v5',
          index <= 0 ? 'MTA Alerta V5' : 'MTA Recordatorio V5',
          importance: Importance.max,
          priority: Priority.max,
          category: AndroidNotificationCategory.alarm,
          ticker: _buildTitle(notification, repetition: index),
          visibility: NotificationVisibility.public,
          ongoing: false, // Se puede deslizar para descartar
          playSound: notification.soundEnabled,
          sound: notification.soundEnabled && notification.soundUri != null
              ? UriAndroidNotificationSound(notification.soundUri!)
              : null,
          actions: [
            const AndroidNotificationAction('taken', '✓ CANCELADA',
                showsUserInterface: true),
            // Solo mostrar botón de snooze si NO es la última repetición
            if (index < _maxRepetitions)
              AndroidNotificationAction(
                'snooze',
                index == -1
                    ? '⏰ 5 MIN'
                    : '⏰ 10 MIN', // Pre-aviso: 5 min, resto: 10 min
                showsUserInterface: true,
              ),
          ],
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.alarmClock,
      // ✅ Si es una prueba puntual (ID empieza por 'simple_test'), no usamos repetición diaria
      matchDateTimeComponents: notification.id.startsWith('simple_test')
          ? null
          : DateTimeComponents.time,
      payload: '${notification.scheduleId}|$index|${notification.userId}',
    );
    debugPrint('🚀 [OS Handshake - DONE] ID: $id');
  }

  @override
  Future<void> showInstantNotification(NotificationEntity notification) async {
    const id = 999999;
    debugPrint('🧪 Mostrando notificación INSTANTÁNEA (ID: $id)');

    await _notificationsPlugin.show(
      id,
      '🧪 PRUEBA: ${_buildTitle(notification)}',
      'Si ves esto, el sistema de notificaciones funciona correctamente.',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'mta_notifications_v5',
          'MTA Alerta V5',
          importance: Importance.max,
          priority: Priority.max,
          playSound: true,
          fullScreenIntent: true,
          category: AndroidNotificationCategory.alarm,
        ),
      ),
      payload: '${notification.scheduleId}|0|${notification.userId}',
    );
  }

  tz.TZDateTime _nextInstanceOfTime(DateTime scheduledTime) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);

    // ✅ Usamos Milisegundos para evitar errores de interpretación de campos horários (wall-clock bugs)
    // Esto asegura que si la alarma es en 20 segundos, sea exactamente en 20 segundos absolutos.
    tz.TZDateTime scheduledDate = tz.TZDateTime.fromMillisecondsSinceEpoch(
        tz.local, scheduledTime.millisecondsSinceEpoch);

    debugPrint(
        '   🔍 Calculando próxima instancia para: $scheduledDate (ahora: $now)');

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
      debugPrint('      -> Programado para MAÑANA: $scheduledDate');
    } else {
      debugPrint('      -> Programado para HOY: $scheduledDate');
    }

    return scheduledDate;
  }

  @override
  Future<void> stopNotificationsForScheduleTime(
      NotificationEntity notification, DateTime scheduleTime,
      {DateTime? maxTime}) async {
    // Ya no dependemos de _activeNotifications para esto
    final scheduleId = notification.scheduleId;
    final baseId = notification.notificationId;

    // 1. Cancelar todas las actuales (incluyendo pre-aviso y repeticiones)
    for (int i = -1; i <= _maxRepetitions; i++) {
      final id = baseId + ((i + 1) * 100);
      await _notificationsPlugin.cancel(id);
    }

    debugPrint(
        '🛑 Notificaciones detenidas para $scheduleId (Base ID: $baseId)');

    // 2. Reprogramar para mañana
    final preTime =
        notification.notificationTime.subtract(const Duration(minutes: 5));

    // Programar Pre-aviso para mañana
    await scheduleForTomorrow(notification, preTime, -1, maxTime: maxTime);

    // Programar Principal para mañana
    await scheduleForTomorrow(notification, notification.notificationTime, 0,
        maxTime: maxTime);

    // Programar Repeticiones para mañana
    for (int i = 1; i <= _maxRepetitions; i++) {
      final repTime =
          notification.notificationTime.add(_repetitionInterval * i);
      await scheduleForTomorrow(notification, repTime, i, maxTime: maxTime);
    }
    debugPrint('💊 Reprogramado para mañana: $scheduleId');
  }

  /// Helper para forzar programación mañana
  Future<void> scheduleForTomorrow(
      NotificationEntity notification, DateTime time, int index,
      {DateTime? maxTime}) async {
    var tzTime = _nextInstanceOfTime(time);
    final now = tz.TZDateTime.now(tz.local);

    // Si cae HOY, lo movemos a mañana obligatoriamente.
    // Esto es porque si llamamos a esta función es porque queremos skipear lo que queda de hoy.
    if (tzTime.year == now.year &&
        tzTime.month == now.month &&
        tzTime.day == now.day) {
      tzTime = tzTime.add(const Duration(days: 1));
    }

    // Cutoff para mañana (si existe)
    if (maxTime != null) {
      // Ajustar maxTime a mañana si es necesario
      var tomorrowMaxTime = maxTime;
      if (tomorrowMaxTime.isBefore(tzTime)) {
        tomorrowMaxTime = tomorrowMaxTime.add(const Duration(days: 1));
      }

      if (tzTime.isAfter(tomorrowMaxTime)) {
        debugPrint(
            '   ⚠️ Omitiendo repetición $index para mañana porque supera el cutoff ($tomorrowMaxTime)');
        return;
      }
    }

    final baseId = notification.notificationId;
    final id = baseId + ((index + 1) * 100);

    debugPrint('🚀 [OS Handshake PROX - START] ID: $id | Time: $tzTime');
    await _notificationsPlugin.zonedSchedule(
      id,
      _buildTitle(notification, repetition: index),
      _buildBody(notification, repetition: index),
      tzTime,
      NotificationDetails(
        android: AndroidNotificationDetails(
          index <= 0 ? 'mta_notifications_v5' : 'mta_notifications_repeat_v5',
          index <= 0 ? 'MTA Alerta V5' : 'MTA Recordatorio V5',
          importance: Importance.max,
          priority: Priority.max,
          playSound: notification.soundEnabled,
          sound: notification.soundEnabled && notification.soundUri != null
              ? UriAndroidNotificationSound(notification.soundUri!)
              : null,
          category: AndroidNotificationCategory.alarm,
          fullScreenIntent: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.alarmClock,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: '${notification.scheduleId}|$index',
    );
    debugPrint('🚀 [OS Handshake PROX - DONE] ID: $id');
  }

  @override
  Future<void> cancelNotification(String scheduleId) async {
    final notification = _activeNotifications[scheduleId];
    if (notification != null) {
      final baseId = notification.notificationId;
      for (int i = -1; i <= _maxRepetitions; i++) {
        await _notificationsPlugin.cancel(baseId + ((i + 1) * 100));
      }
      _activeNotifications.remove(scheduleId);
      debugPrint('🛑 Notificaciones canceladas para $scheduleId');
    }
  }

  @override
  Future<void> snoozeNotification(
      String notificationId, Duration snoozeDuration) async {
    final notification = _activeNotifications[notificationId];
    if (notification == null) return;

    final now = tz.TZDateTime.now(tz.local);
    final snoozedTime = now.add(snoozeDuration);

    debugPrint('🚀 [OS Handshake SNOOZE - START] Time: $snoozedTime');
    await _notificationsPlugin.zonedSchedule(
      notification.notificationId + 999, // ID único para snooze
      '⏰ ${_buildTitle(notification, repetition: 0)}',
      'Recordatorio pospuesto $snoozeDuration',
      snoozedTime,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'mta_notifications_v5',
          'MTA Alerta V5',
          importance: Importance.max,
          priority: Priority.max,
          playSound: notification.soundEnabled,
          sound: notification.soundEnabled && notification.soundUri != null
              ? UriAndroidNotificationSound(notification.soundUri!)
              : null,
          category: AndroidNotificationCategory.alarm,
          fullScreenIntent: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.alarmClock,
      payload: '${notification.scheduleId}|0|${notification.userId}',
    );
    debugPrint('🚀 [OS Handshake SNOOZE - DONE]');
  }

  @override
  Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
    _activeNotifications.clear();
    debugPrint('🗑️ Todas las notificaciones canceladas del OS');
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

  @override
  Future<void> logPendingNotifications() async {
    final List<PendingNotificationRequest> pendingRequests =
        await _notificationsPlugin.pendingNotificationRequests();
    debugPrint(
        '🔍 [DIAGNÓSTICO OS] Pendientes en el sistema: ${pendingRequests.length}');
    for (var request in pendingRequests) {
      debugPrint(
          '   - ID: ${request.id} | Titulo: ${request.title} | Payload: ${request.payload}');
    }
  }

  String _buildTitle(NotificationEntity notification, {int repetition = 0}) {
    if (repetition == -1) {
      return 'Próxima medición: ${notification.notificationTime}';
    }
    if (repetition == 0) {
      return 'Hora de medición: ${notification.notificationTime}';
    }
    return 'RECORDATORIO ($repetitionª vez) medición: ${notification.notificationTime}';
  }

  String _buildBody(NotificationEntity notification, {int repetition = 0}) {
    final buffer = StringBuffer();
    if (repetition == -1) {
      buffer.write('En 5 minutos toca su medición de tensión.');
    } else if (repetition == 0) {
      buffer.write('Es el momento de realizar la medición programada.');
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
