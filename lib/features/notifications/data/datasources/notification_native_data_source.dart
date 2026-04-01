import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mta/features/notifications/domain/entities/notification_entity.dart';
import 'package:mta/features/notifications/data/models/notification_strings.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:mta/core/utils/utils_barrel.dart';

/// Data source para gestionar notificaciones persistentes con repetición
abstract class NotificationNativeDataSource {
  Future<void> scheduleNotification(NotificationEntity notification,
      {DateTime? maxTime, NotificationStrings? strings});
  Future<void> cancelNotification(String notificationId);
  Future<void> snoozeNotification(
      String notificationId, Duration snoozeDuration,
      {NotificationStrings? strings});
  Future<void> cancelNotificationsForSchedule(String scheduleId);
  Future<void> stopNotificationsForScheduleTime(
      NotificationEntity notification, DateTime scheduleTime,
      {DateTime? maxTime, NotificationStrings? strings});
  Future<void> cancelAllNotifications();
  Future<bool> isNotificationActive(String notificationId);
  Future<List<NotificationEntity>> getActiveNotifications();
  Future<void> showInstantNotification(NotificationEntity notification,
      {NotificationStrings? strings});
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
      {DateTime? maxTime, NotificationStrings? strings}) async {
    try {
      debugPrint(
          '${fechaD('🔔')} PROGRAMANDO NOTIFICACIONES SEMANALES (7 ALARMAS)');
      debugPrint('${fechaD()} Schedule ID: ${notification.scheduleId}');

      _activeNotifications[notification.scheduleId] = notification;

      // Programar 7 alarmas semanales (Lunes a Domingo)
      // Esto permite cancelar "Solo hoy" sin afectar a mañana.
      for (int weekday = 1; weekday <= 7; weekday++) {
        await _scheduleForSpecificWeekday(notification, weekday,
            maxTime: maxTime, strings: strings);
      }

      debugPrint(
          '${fechaD()} Sistema de notificaciones programado (Weekly x7) para ${notification.id}');
    } catch (e) {
      debugPrint(
          '${fechaD('🔴')} ERROR AL PROGRAMAR schedule ${notification.scheduleId}: $e');
      rethrow;
    }
  }

  /// Programa las notificaciones para un día de la semana específico
  Future<void> _scheduleForSpecificWeekday(
      NotificationEntity notification, int weekday,
      {DateTime? maxTime, NotificationStrings? strings}) async {
    // 1. Calcular la próxima fecha para este weekday
    // Si hoy es martes (2) y programamos martes:
    //   - Si la hora ya pasó: Next Tuesday
    //   - Si no ha pasado: Today
    var scheduledDate = _nextInstanceOfTime(notification.notificationTime);
    while (scheduledDate.weekday != weekday) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    // 2. Programar PRE-AVISO (5 min antes)
    if (!notification.id.startsWith('simple_test')) {
      final preTime = scheduledDate.subtract(const Duration(minutes: 5));
      await _scheduleSingleWeeklyNotification(
          notification, preTime, -1, weekday,
          strings: strings);
    }

    // 3. Programar PRINCIPAL (Hora exacta)
    await _scheduleSingleWeeklyNotification(
        notification, scheduledDate, 0, weekday,
        strings: strings);

    // 4. Programar REPETICIONES
    if (!notification.id.startsWith('simple_test')) {
      for (int i = 1; i <= _maxRepetitions; i++) {
        final repTime = scheduledDate.add(_repetitionInterval * i);

        // Cutoff check
        if (maxTime != null && repTime.isAfter(maxTime)) {
          continue;
        }

        await _scheduleSingleWeeklyNotification(
            notification, repTime, i, weekday,
            strings: strings);
      }
    }
  }

  /// Programamos una notificación recurrente SEMANAL (Weekly) en el OS
  Future<void> _scheduleSingleWeeklyNotification(
      NotificationEntity notification, DateTime time, int index, int weekday,
      {int? forcedId, NotificationStrings? strings}) async {
    final tzTime = tz.TZDateTime.from(time, tz.local);
    final baseId = notification.notificationId;

    // ID Único: Base + (Weekday * 1000) + Offset
    // Weekday: 1..7 -> 1000..7000
    // Offset: -1..6 -> 0..700 (aprox)
    // Ejemplo: Base 123, Martes (2), Principal (0) -> 123 + 2000 + 100 = 1232100? No.
    // Lógica segura: (Weekday * 1000) + ((index + 2) * 10)
    // Monday (1): 1000 + 10 = 1010 (Pre), 1020 (Main), 1030 (Rep1)...
    final idOffset = (weekday * 1000) + ((index + 2) * 50);
    final id = forcedId ?? (baseId + idOffset);

    // Programar el resumen del grupo si es la primera notificación
    if (index == -1 ||
        (index == 0 && !notification.id.contains('simple_test'))) {
      await _scheduleGroupSummary(notification, tzTime, strings: strings);
    }

    // debugPrint('${fechaD()} [Semanal dia $weekday] ID: $id | Time: $tzTime');

    await _notificationsPlugin.zonedSchedule(
      id,
      _buildTitle(notification, repetition: index, strings: strings),
      _buildBody(notification, repetition: index, strings: strings),
      tzTime,
      NotificationDetails(
        android: AndroidNotificationDetails(
          index <= 0 ? 'mta_notifications_v5' : 'mta_notifications_repeat_v5',
          index <= 0
              ? (strings?.channelAlertTitle ?? 'MTA Alerta V5')
              : (strings?.channelRepeatTitle ?? 'MTA Recordatorio V5'),
          importance: Importance.max,
          priority: Priority.max,
          category: AndroidNotificationCategory.alarm,
          ticker:
              _buildTitle(notification, repetition: index, strings: strings),
          visibility: NotificationVisibility.public,
          ongoing: false,
          playSound: notification.soundEnabled,
          sound: notification.soundEnabled && notification.soundUri != null
              ? UriAndroidNotificationSound(notification.soundUri!)
              : null,
          groupKey: notification.scheduleId,
          groupAlertBehavior: GroupAlertBehavior.children,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.alarmClock,
      // ✅ Clave: Match DayOfWeek + Time -> Repetición Semanal exacta
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      payload: '${notification.scheduleId}|$index|${notification.userId}',
    );
  }

  @override
  Future<void> showInstantNotification(NotificationEntity notification,
      {NotificationStrings? strings}) async {
    const id = 999999;
    debugPrint('${fechaD('📦')} Mostrando notificación INSTANTÁNEA (ID: $id)');

    await _notificationsPlugin.show(
      id,
      '${strings?.testPrefix ?? '🧪 PRUEBA: '}${_buildTitle(notification, strings: strings)}',
      strings?.testNotificationBody ??
          'Si ves esto, el sistema de notificaciones funciona correctamente.',
      NotificationDetails(
        android: AndroidNotificationDetails(
          'mta_notifications_v5',
          strings?.channelAlertTitle ?? 'MTA Alerta V5',
          importance: Importance.max,
          priority: Priority.max,
          playSound: true,
          category: AndroidNotificationCategory.alarm,
          groupKey: notification.scheduleId,
          setAsGroupSummary: true,
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
        '${fechaD()} Calculando próxima instancia para: $scheduledDate (ahora: $now)');

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
      debugPrint('${fechaD()} -> Programado para MAÑANA: $scheduledDate');
    } else {
      debugPrint('${fechaD()} -> Programado para HOY: $scheduledDate');
    }

    return scheduledDate;
  }

  @override
  Future<void> stopNotificationsForScheduleTime(
      NotificationEntity notification, DateTime scheduleTime,
      {DateTime? maxTime, NotificationStrings? strings}) async {
    final scheduleId = notification.scheduleId;
    final baseId = notification.notificationId;
    // Identificar el día de la semana de la toma (1=Lunes, 7=Domingo)
    final weekday = scheduleTime.weekday;

    debugPrint(
        '${fechaD('🔴')} Deteniendo notificaciones del día (Weekday $weekday) para $scheduleId');

    // 1. Cancelar SOLO los IDs de este día
    for (int i = -1; i <= _maxRepetitions; i++) {
      final idOffset = (weekday * 1000) + ((i + 2) * 50);
      final id = baseId + idOffset;
      await _notificationsPlugin.cancel(id);
    }

    debugPrint('${fechaD('✅')} Notificaciones de HOY canceladas');

    // 2. Reprogramar este día para la SEMANA QUE VIENE
    // Calculamos fecha de la próxima semana
    var nextWeekDate = _nextInstanceOfTime(notification.notificationTime);
    // Asegurar que sea para este weekday pero en el futuro
    while (nextWeekDate.weekday != weekday ||
        nextWeekDate.isBefore(tz.TZDateTime.now(tz.local))) {
      nextWeekDate = nextWeekDate.add(const Duration(days: 1));
    }

    // Si nextWeekDate es HOY (porque _nextInstance devolvió hoy y no ha pasado la hora?),
    if (nextWeekDate.day == scheduleTime.day &&
        nextWeekDate.month == scheduleTime.month) {
      nextWeekDate = nextWeekDate.add(const Duration(days: 7));
    }

    debugPrint(
        '${fechaD('🔄')} Reprogramando Weekday $weekday para el: $nextWeekDate');

    // Volver a programar (Pre, Main, Reps) para esa nueva fecha
    if (!notification.id.startsWith('simple_test')) {
      final preTime = nextWeekDate.subtract(const Duration(minutes: 5));
      await _scheduleSingleWeeklyNotification(
          notification, preTime, -1, weekday,
          strings: strings);
    }

    await _scheduleSingleWeeklyNotification(
        notification, nextWeekDate, 0, weekday,
        strings: strings);

    if (!notification.id.startsWith('simple_test')) {
      for (int i = 1; i <= _maxRepetitions; i++) {
        final repTime = nextWeekDate.add(_repetitionInterval * i);
        if (maxTime != null && repTime.isAfter(maxTime)) continue;

        await _scheduleSingleWeeklyNotification(
            notification, repTime, i, weekday,
            strings: strings);
      }
    }

    debugPrint('${fechaD('✨')} Ciclo semanal restaurado para el futuro.');
    await logPendingNotifications();
  }

  @override
  Future<void> cancelNotification(String scheduleId) async {
    final notification = _activeNotifications[scheduleId];
    if (notification != null) {
      final baseId = notification.notificationId;
      for (int i = -1; i <= _maxRepetitions; i++) {
        await _notificationsPlugin.cancel(baseId + ((i + 1) * 100));
      }
      // Cancelar también el resumen del grupo
      await _notificationsPlugin.cancel(baseId + 9991);

      _activeNotifications.remove(scheduleId);
      debugPrint('${fechaD('🔴')} Notificaciones canceladas para $scheduleId');
    }
  }

  @override
  Future<void> snoozeNotification(
      String notificationId, Duration snoozeDuration,
      {NotificationStrings? strings}) async {
    final notification = _activeNotifications[notificationId];
    if (notification == null) return;

    final now = tz.TZDateTime.now(tz.local);
    final snoozedTime = now.add(snoozeDuration);

    debugPrint(
        '${fechaD('🚀')} [OS Handshake SNOOZE - START] Time: $snoozedTime');
    await _notificationsPlugin.zonedSchedule(
      notification.notificationId + 999, // ID único para snooze
      '⏰ ${_buildTitle(notification, repetition: 0, strings: strings)}',
      _buildBody(notification, repetition: 0, strings: strings),
      snoozedTime,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'mta_notifications_v5',
          strings?.channelAlertTitle ?? 'MTA Alerta V5',
          importance: Importance.max,
          priority: Priority.max,
          playSound: notification.soundEnabled,
          sound: notification.soundEnabled && notification.soundUri != null
              ? UriAndroidNotificationSound(notification.soundUri!)
              : null,
          category: AndroidNotificationCategory.alarm,
          groupKey: notification.scheduleId,
          groupAlertBehavior: GroupAlertBehavior.children,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.alarmClock,
      payload: '${notification.scheduleId}|0|${notification.userId}',
    );
    debugPrint('${fechaD('🚀')} [OS Handshake SNOOZE - DONE]');
  }

  @override
  Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
    _activeNotifications.clear();
    debugPrint('${fechaD()} Todas las notificaciones canceladas del OS');
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
        '${fechaD()} [DIAGNÓSTICO OS] Pendientes en el sistema: ${pendingRequests.length}');
    for (var request in pendingRequests) {
      debugPrint(
          '${fechaD()} - ID: ${request.id} | Titulo: ${request.title} | Payload: ${request.payload}');
    }
  }

  /// Programa una notificación de resumen para el grupo (Android)
  Future<void> _scheduleGroupSummary(
      NotificationEntity notification, tz.TZDateTime time,
      {NotificationStrings? strings}) async {
    final baseId = notification.notificationId;
    final summaryId = baseId + 9991; // ID único para el resumen

    debugPrint(
        '${fechaD('🚀')} [OS Handshake SUMMARY - START] ID: $summaryId | Time: $time');
    await _notificationsPlugin.zonedSchedule(
      summaryId,
      notification.title,
      strings?.groupSummaryBody
              .replaceAll('{userName}', notification.userName) ??
          'Mediciones de ${notification.userName}',
      time,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'mta_notifications_v5',
          strings?.channelAlertTitle ?? 'MTA Alerta V5',
          importance: Importance.max,
          priority: Priority.max,
          groupKey: notification.scheduleId,
          setAsGroupSummary: true,
          groupAlertBehavior: GroupAlertBehavior.children,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.alarmClock,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: '${notification.scheduleId}|summary|${notification.userId}',
    );
    debugPrint('${fechaD('🚀')} [OS Handshake SUMMARY - DONE] ID: $summaryId');
  }

  String _buildTitle(NotificationEntity notification,
      {int repetition = 0, NotificationStrings? strings}) {
    final timeStr = notification.notificationTime.toString().substring(0, 16);
    if (repetition == -1) {
      return strings?.nextMeasurementTime.replaceAll('{time}', timeStr) ??
          'Próxima medición: $timeStr';
    }
    if (repetition == 0) {
      return strings?.measurementTimeTitle.replaceAll('{time}', timeStr) ??
          'Hora de medición: $timeStr';
    }
    return strings?.reminderMeasurementTitle
            .replaceAll('{repetition}', repetition.toString())
            .replaceAll('{time}', timeStr) ??
        'RECORDATORIO ($repetitionª vez) medición: $timeStr';
  }

  String _buildBody(NotificationEntity notification,
      {int repetition = 0, NotificationStrings? strings}) {
    final buffer = StringBuffer();
    if (repetition == -1) {
      buffer.write(
          strings?.preAvisoBody ?? 'En 5 minutos toca su medición de tensión.');
    } else if (repetition == 0) {
      buffer.write(strings?.scheduledTimeBody ??
          'Es el momento de realizar la medición programada.');
    } else {
      buffer.write(strings?.repeatBody
              .replaceAll('{minutes}', (repetition * 10).toString()) ??
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
