import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mta/features/notifications/presentation/bloc/notification_bloc.dart';
import 'package:mta/features/notifications/presentation/bloc/notification_event.dart';
import 'package:mta/features/measurements/presentation/bloc/measurement_bloc.dart';
import 'package:mta/core/routes/app_router.dart';
import 'package:mta/core/utils/constants.dart';

/// Manejador de acciones de notificaciones
class NotificationActionHandler {
  final NotificationBloc notificationBloc;
  final MeasurementBloc measurementBloc;

  NotificationActionHandler({
    required this.notificationBloc,
    required this.measurementBloc,
  });

  /// Maneja las acciones de las notificaciones
  void handleNotificationAction(NotificationResponse response) {
    final actionId = response.actionId;
    final payload = response.payload;

    debugPrint('');
    debugPrint('🎯 PROCESANDO ACCIÓN DE NOTIFICACIÓN');
    debugPrint('   Action: $actionId');
    debugPrint('   Payload: $payload');

    if (payload == null || payload.isEmpty) {
      debugPrint('   ⚠️ Payload vacío, ignorando');
      return;
    }

    // Parsear el payload: "scheduleId|repetitionNumber|userId"
    final parts = payload.split('|');
    if (parts.isEmpty) {
      debugPrint('   ⚠️ Formato de payload inválido');
      return;
    }

    final scheduleId = parts[0];
    final repetitionNumber = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
    final userId = parts.length > 2 ? parts[2] : null;

    debugPrint('   Schedule ID: $scheduleId');
    debugPrint('   Repetición: $repetitionNumber');
    debugPrint('   User ID: $userId');

    // Procesar la acción
    switch (actionId) {
      case 'taken':
        if (userId != null) {
          _handleMeasuringTaken(scheduleId, userId);
        } else {
          debugPrint(
              '   ⚠️ No se puede marcar como tomada: falta userId en payload (Versión antigua de notificación)');
        }
        break;

      case 'snooze':
        _handleSnooze(scheduleId);
        break;

      case null:
      case '':
        // Usuario tocó la notificación (sin acción específica)
        _handleNotificationTap(scheduleId, userId);
        break;

      default:
        debugPrint('   ⚠️ Acción desconocida: $actionId');
    }

    debugPrint('');
  }

  /// Maneja cuando el usuario marca como "tomada"
  void _handleMeasuringTaken(String scheduleId, String userId) {
    debugPrint('💊 Usuario marcó medicación como tomada');

    // Detener las notificaciones del schedule para HOY y programar para MAÑANA
    notificationBloc.add(MarkAsTaken(
      scheduleId: scheduleId,
      timestamp: DateTime.now(),
      userId: userId,
    ));

    debugPrint('   ✅ Notificaciones reprogramadas para mañana');
    debugPrint('   ℹ️  TODO: Implementar creación automática de medición');
  }

  /// Maneja cuando el usuario pospone (snooze)
  void _handleSnooze(String scheduleId) {
    debugPrint('⏰ Usuario pospuso la notificación');

    // Posponer por 5 minutos
    const snoozeDuration = Duration(minutes: 5);

    notificationBloc.add(SnoozeNotification(
      notificationId: 'schedule_$scheduleId',
      snoozeDuration: snoozeDuration,
    ));

    debugPrint(
        '   ✅ Notificación pospuesta por ${snoozeDuration.inMinutes} minutos');
  }

  /// Maneja cuando el usuario simplemente toca la notificación
  void _handleNotificationTap(String scheduleId, String? userId) {
    debugPrint('👆 Usuario tocó la notificación (Schedule: $scheduleId)');
    debugPrint('   → Abriendo pantalla de nueva toma');

    if (userId != null) {
      debugPrint('   → Navegando con userId: $userId');
      // Navegar a la pantalla de nueva toma con el userId
      appRouter.push('${Routes.measurementForm}?userId=$userId');
    } else {
      debugPrint(
          '   ⚠️ No se pudo extraer userId del payload, navegando sin contexto');
      // Navegar directamente a la pantalla de nueva toma
      appRouter.push(Routes.measurementForm);
    }
  }
}
