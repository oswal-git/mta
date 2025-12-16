import 'dart:async';
import 'dart:ui';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:mta/features/alarms/domain/entities/alarm_entity.dart';
import 'package:timezone/timezone.dart' as tz;

/// Data source para gestionar notificaciones persistentes
abstract class AlarmNativeDataSource {
  Future<void> setAlarm(AlarmEntity alarm);
  Future<void> cancelAlarm(String alarmId);
  Future<void> snoozeAlarm(String alarmId, Duration snoozeDuration);
  Future<void> cancelAllAlarms();
  Future<bool> isAlarmActive(String alarmId);
  Future<List<AlarmEntity>> getActiveAlarms();
}

/// Implementación con notificaciones persistentes que se regeneran
class AlarmNativeDataSourceImpl implements AlarmNativeDataSource {
  final FlutterLocalNotificationsPlugin _notificationsPlugin;
  final Map<String, AlarmEntity> _activeAlarms = {};
  final Map<String, Timer> _regenerationTimers = {};

  // Configuración de regeneración
  static const Duration _regenerationInterval = Duration(seconds: 30);
  static const int _maxRegenerations = 120; // 1 hora máximo

  AlarmNativeDataSourceImpl({
    FlutterLocalNotificationsPlugin? notificationsPlugin,
    AndroidAlarmManager? alarmManager,
  }) : _notificationsPlugin =
            notificationsPlugin ?? FlutterLocalNotificationsPlugin();

  @override
  Future<void> setAlarm(AlarmEntity alarm) async {
    try {
      // Calcular el tiempo de la notificación (5 minutos antes de la toma)
      final notificationTime =
          alarm.alarmTime.subtract(const Duration(minutes: 5));

      debugPrint(
        '${DateFormat('HH:mm:ss').format(DateTime.now())} -🔔 Programando notificación:',
      );
      debugPrint(
        '${DateFormat('HH:mm:ss').format(DateTime.now())}    - Usuario: ${alarm.userName}',
      );
      debugPrint(
        '${DateFormat('HH:mm:ss').format(DateTime.now())}    - Hora toma: ${alarm.alarmTime}',
      );
      debugPrint(
        '${DateFormat('HH:mm:ss').format(DateTime.now())}    - Hora notificación: $notificationTime',
      );
      debugPrint(
        '${DateFormat('HH:mm:ss').format(DateTime.now())}    - Ahora: ${DateTime.now()}',
      );

      if (notificationTime.isBefore(DateTime.now())) {
        debugPrint(
          '${DateFormat('HH:mm:ss').format(DateTime.now())} -⚠️ La notificación ya pasó, omitiendo.',
        );
        return;
      }

      // Guardar en el mapa de alarmas activas
      _activeAlarms[alarm.id] = alarm;

      // Programar la notificación inicial
      await _scheduleNotification(alarm, notificationTime);

      debugPrint(
        '${DateFormat('HH:mm:ss').format(DateTime.now())} -✅ Notificación programada: ${alarm.id}',
      );
    } catch (e, stackTrace) {
      debugPrint(
        '${DateFormat('HH:mm:ss').format(DateTime.now())} -🔴 Error: $e',
      );
      debugPrint('Stack: $stackTrace');
      rethrow;
    }
  }

  /// Programa una notificación con regeneración automática
  Future<void> _scheduleNotification(
    AlarmEntity alarm,
    DateTime notificationTime,
  ) async {
    final notificationId = alarm.notificationId;

    // Detalles de la notificación con máxima prioridad
    final androidDetails = AndroidNotificationDetails(
      'medication_alarms',
      'Notificaciones de Medicación',
      channelDescription: 'Recordatorios persistentes para tomar medicación',
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
      ongoing: true, // Persistente
      autoCancel: false, // No se cancela al tocar
      category: AndroidNotificationCategory.alarm,
      visibility: NotificationVisibility.public,
      fullScreenIntent: true,
      tag: alarm.id, // Tag único para reemplazar
      actions: <AndroidNotificationAction>[
        const AndroidNotificationAction(
          'taken',
          '✓ Tomada',
          showsUserInterface: true,
        ),
        const AndroidNotificationAction(
          'snooze',
          '⏰ 5 min',
        ),
      ],
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      interruptionLevel: InterruptionLevel.critical,
      categoryIdentifier: 'medication_alarm',
    );

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Si la notificación es para AHORA o muy pronto (menos de 10 seg)
    if (notificationTime.difference(DateTime.now()).inSeconds < 10) {
      // Mostrar inmediatamente
      await _notificationsPlugin.show(
        notificationId,
        _buildTitle(alarm),
        _buildBody(alarm),
        notificationDetails,
        payload: alarm.id,
      );

      debugPrint(
        '${DateFormat('HH:mm:ss').format(DateTime.now())} -🔔 Notificación mostrada inmediatamente',
      );

      // Iniciar regeneración automática
      _startRegenerationTimer(alarm);
    } else {
      // Programar para el futuro
      await _notificationsPlugin.zonedSchedule(
        notificationId,
        _buildTitle(alarm),
        _buildBody(alarm),
        tz.TZDateTime.from(notificationTime, tz.local),
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: alarm.id,
      );

      debugPrint(
        '${DateFormat('HH:mm:ss').format(DateTime.now())} -📅 Notificación programada para: $notificationTime',
      );

      // Programar el inicio de la regeneración cuando llegue la hora
      final delayUntilNotification =
          notificationTime.difference(DateTime.now());
      Timer(delayUntilNotification, () {
        if (_activeAlarms.containsKey(alarm.id)) {
          _startRegenerationTimer(alarm);
        }
      });
    }
  }

  /// Inicia el timer de regeneración automática
  void _startRegenerationTimer(AlarmEntity alarm) {
    // Cancelar timer previo si existe
    _regenerationTimers[alarm.id]?.cancel();

    int regenerationCount = 0;

    debugPrint(
      '${DateFormat('HH:mm:ss').format(DateTime.now())} -🔄 Iniciando regeneración automática para: ${alarm.id}',
    );

    _regenerationTimers[alarm.id] =
        Timer.periodic(_regenerationInterval, (timer) async {
      regenerationCount++;

      // Verificar si la alarma sigue activa
      if (!_activeAlarms.containsKey(alarm.id)) {
        debugPrint(
          '${DateFormat('HH:mm:ss').format(DateTime.now())} -🛑 Alarma ${alarm.id} ya no existe, deteniendo regeneración',
        );
        timer.cancel();
        _regenerationTimers.remove(alarm.id);
        return;
      }

      // Verificar si ya pasó la hora de la siguiente toma
      if (DateTime.now().isAfter(alarm.alarmTime)) {
        debugPrint(
          '${DateFormat('HH:mm:ss').format(DateTime.now())} -⏰ Ya pasó la hora de la toma, deteniendo notificación',
        );
        await cancelAlarm(alarm.id);
        timer.cancel();
        return;
      }

      // Límite de regeneraciones
      if (regenerationCount >= _maxRegenerations) {
        debugPrint(
          '${DateFormat('HH:mm:ss').format(DateTime.now())} -⚠️ Límite de regeneraciones alcanzado',
        );
        await cancelAlarm(alarm.id);
        timer.cancel();
        return;
      }

      // Regenerar la notificación
      try {
        await _showImmediateNotification(alarm);
        debugPrint(
          '${DateFormat('HH:mm:ss').format(DateTime.now())} -🔄 Notificación regenerada ($regenerationCount/$_maxRegenerations)',
        );
      } catch (e) {
        debugPrint(
          '${DateFormat('HH:mm:ss').format(DateTime.now())} -❌ Error al regenerar: $e',
        );
      }
    });
  }

  /// Muestra una notificación inmediata
  Future<void> _showImmediateNotification(AlarmEntity alarm) async {
    final notificationId = alarm.notificationId;

    final androidDetails = AndroidNotificationDetails(
      'medication_alarms',
      'Notificaciones de Medicación',
      channelDescription: 'Recordatorios persistentes para tomar medicación',
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
      ongoing: true,
      autoCancel: false,
      category: AndroidNotificationCategory.alarm,
      visibility: NotificationVisibility.public,
      fullScreenIntent: true,
      tag: alarm.id,
      actions: <AndroidNotificationAction>[
        const AndroidNotificationAction(
          'taken',
          '✓ Tomada',
          showsUserInterface: true,
        ),
        const AndroidNotificationAction(
          'snooze',
          '⏰ 5 min',
        ),
      ],
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      interruptionLevel: InterruptionLevel.critical,
    );

    await _notificationsPlugin.show(
      notificationId,
      _buildTitle(alarm),
      _buildBody(alarm),
      NotificationDetails(android: androidDetails, iOS: iosDetails),
      payload: alarm.id,
    );
  }

  @override
  Future<void> cancelAlarm(String alarmId) async {
    try {
      // Detener timer de regeneración
      _regenerationTimers[alarmId]?.cancel();
      _regenerationTimers.remove(alarmId);

      // Cancelar notificación
      final alarm = _activeAlarms[alarmId];
      if (alarm != null) {
        await _notificationsPlugin.cancel(alarm.notificationId);
      }

      // Remover del mapa
      _activeAlarms.remove(alarmId);

      debugPrint(
        '${DateFormat('HH:mm:ss').format(DateTime.now())} -🛑 Notificación $alarmId cancelada',
      );
    } catch (e) {
      debugPrint(
        '${DateFormat('HH:mm:ss').format(DateTime.now())} -❌ Error al cancelar: $e',
      );
      rethrow;
    }
  }

  @override
  Future<void> snoozeAlarm(String alarmId, Duration snoozeDuration) async {
    try {
      final originalAlarm = _activeAlarms[alarmId];
      if (originalAlarm == null) {
        throw Exception('Alarma no encontrada');
      }

      // Cancelar la notificación actual
      await cancelAlarm(alarmId);

      // Crear una nueva alarma con el tiempo pospuesto
      final newAlarmTime = DateTime.now().add(snoozeDuration);
      final snoozedAlarm = originalAlarm.copyWith(alarmTime: newAlarmTime);

      // Programar la nueva alarma
      await setAlarm(snoozedAlarm);

      debugPrint(
        '${DateFormat('HH:mm:ss').format(DateTime.now())} -⏰ Notificación pospuesta ${snoozeDuration.inMinutes} min',
      );
    } catch (e) {
      debugPrint(
        '${DateFormat('HH:mm:ss').format(DateTime.now())} -❌ Error al posponer: $e',
      );
      rethrow;
    }
  }

  @override
  Future<void> cancelAllAlarms() async {
    try {
      // Detener todos los timers
      for (var timer in _regenerationTimers.values) {
        timer.cancel();
      }
      _regenerationTimers.clear();

      // Cancelar todas las notificaciones
      await _notificationsPlugin.cancelAll();

      // Limpiar el mapa
      _activeAlarms.clear();

      debugPrint(
        '${DateFormat('HH:mm:ss').format(DateTime.now())} -🛑 Todas las notificaciones canceladas',
      );
    } catch (e) {
      debugPrint(
        '${DateFormat('HH:mm:ss').format(DateTime.now())} -❌ Error al cancelar todas: $e',
      );
      rethrow;
    }
  }

  @override
  Future<bool> isAlarmActive(String alarmId) async {
    try {
      if (!_activeAlarms.containsKey(alarmId)) {
        return false;
      }

      final alarm = _activeAlarms[alarmId];
      final notificationId = alarm?.notificationId ?? alarmId.hashCode.abs();

      final pendingNotifications =
          await _notificationsPlugin.pendingNotificationRequests();

      return pendingNotifications
          .any((notification) => notification.id == notificationId);
    } catch (e) {
      debugPrint(
        '${DateFormat('HH:mm:ss').format(DateTime.now())} -❌ Error al verificar: $e',
      );
      return false;
    }
  }

  @override
  Future<List<AlarmEntity>> getActiveAlarms() async {
    return _activeAlarms.values.toList();
  }

  String _buildTitle(AlarmEntity alarm) {
    return '💊 ${alarm.userName} - Hora de medicación';
  }

  String _buildBody(AlarmEntity alarm) {
    final buffer = StringBuffer();

    if (alarm.label != null && alarm.label!.isNotEmpty) {
      buffer.write('🕐 ${alarm.label}\n');
    }

    if (alarm.medication != null && alarm.medication!.isNotEmpty) {
      buffer.write('💊 ${alarm.medication}\n');
    }

    buffer.write(
        '\n⚠️ Esta notificación se repetirá hasta que tomes tu medicación');

    return buffer.toString();
  }
}
