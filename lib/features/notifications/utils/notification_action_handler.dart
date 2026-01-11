import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mta/features/notifications/presentation/bloc/notification_bloc.dart';
import 'package:mta/features/notifications/presentation/bloc/notification_event.dart';
import 'package:mta/features/measurements/presentation/bloc/measurement_bloc.dart';

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

    // Parsear el payload: "scheduleId|repetitionNumber"
    final parts = payload.split('|');
    if (parts.isEmpty) {
      debugPrint('   ⚠️ Formato de payload inválido');
      return;
    }

    final scheduleId = parts[0];
    final repetitionNumber = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;

    debugPrint('   Schedule ID: $scheduleId');
    debugPrint('   Repetición: $repetitionNumber');

    // Procesar la acción
    switch (actionId) {
      case 'taken':
        _handleMeasuringTaken(scheduleId);
        break;

      case 'snooze':
        _handleSnooze(scheduleId);
        break;

      case null:
      case '':
        // Usuario tocó la notificación (sin acción específica)
        _handleNotificationTap(scheduleId);
        break;

      default:
        debugPrint('   ⚠️ Acción desconocida: $actionId');
    }

    debugPrint('');
  }

  /// Maneja cuando el usuario marca como "tomada"
  void _handleMeasuringTaken(String scheduleId) {
    debugPrint('💊 Usuario marcó medicación como tomada');

    // Detener las notificaciones del schedule
    notificationBloc.add(CancelNotification(scheduleId));

    debugPrint('   ✅ Notificaciones detenidas');
    debugPrint('   ℹ️  TODO: Implementar creación automática de medición');
  }

  /// Maneja cuando el usuario pospone (snooze)
  void _handleSnooze(String scheduleId) {
    debugPrint('⏰ Usuario pospuso la notificación');

    // Posponer por 5 minutos
    const snoozeDuration = Duration(minutes: 5);

    notificationBloc.add(SnoozeNotification(
      notificationId: scheduleId,
      snoozeDuration: snoozeDuration,
    ));

    debugPrint(
        '   ✅ Notificación pospuesta por ${snoozeDuration.inMinutes} minutos');
  }

  /// Maneja cuando el usuario simplemente toca la notificación
  void _handleNotificationTap(String scheduleId) {
    debugPrint('👆 Usuario tocó la notificación');
    debugPrint('   ℹ️ Puedes navegar a una pantalla específica aquí');

    // TODO: Navegar a la pantalla de registro de medición
    // navigatorKey.currentState?.pushNamed('/measurement/create', arguments: scheduleId);
  }
}
