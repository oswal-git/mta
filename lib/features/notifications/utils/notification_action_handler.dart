import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mta/features/notifications/presentation/bloc/notification_bloc.dart';
import 'package:mta/features/notifications/presentation/bloc/notification_event.dart';
import 'package:mta/features/measurements/presentation/bloc/measurement_bloc.dart';
import 'package:mta/core/routes/app_router.dart';
import 'package:mta/core/utils/utils_barrel.dart';

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
    debugPrint('${fechaD('👆')} PROCESANDO ACCIÓN DE NOTIFICACIÓN');
    debugPrint('${fechaD()}    Action: $actionId');
    debugPrint('${fechaD()}    Payload: $payload');

    if (payload == null || payload.isEmpty) {
      debugPrint('${fechaD('⚠️')}    ⚠️ Payload vacío, ignorando');
      return;
    }

    // Parsear el payload: "scheduleId|repetitionNumber|userId"
    final parts = payload.split('|');
    if (parts.isEmpty) {
      debugPrint('${fechaD('⚠️')}    ⚠️ Formato de payload inválido');
      return;
    }

    final scheduleId = parts[0];
    final repetitionNumber = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
    final userId = parts.length > 2 ? parts[2] : null;

    debugPrint('${fechaD()}    Schedule ID: $scheduleId');
    debugPrint('${fechaD()}    Repetición: $repetitionNumber');
    debugPrint('${fechaD()}    User ID: $userId');

    // Procesar la acción
    switch (actionId) {
      case 'taken':
        if (userId != null) {
          _handleMeasuringTaken(scheduleId, userId);
        } else {
          debugPrint(
              '${fechaD('⚠️')}    ⚠️ No se puede marcar como tomada: falta userId en payload (Versión antigua de notificación)');
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
        debugPrint('${fechaD('⚠️')}    ⚠️ Acción desconocida: $actionId');
    }

    debugPrint('');
  }

  /// Maneja cuando el usuario marca como "tomada"
  void _handleMeasuringTaken(String scheduleId, String userId) {
    debugPrint('${fechaD('💉')} Usuario marcó medicación como tomada');

    // Detener las notificaciones del schedule para HOY y programar para MAÑANA
    notificationBloc.add(MarkAsTaken(
      scheduleId: scheduleId,
      timestamp: DateTime.now(),
      userId: userId,
    ));

    debugPrint('${fechaD('🔄')}    ✅ Notificaciones reprogramadas para mañana');
    debugPrint(
        '${fechaD('🔧')}    ℹ️  TODO: Implementar creación automática de medición');
  }

  /// Maneja cuando el usuario pospone (snooze)
  void _handleSnooze(String scheduleId) {
    debugPrint('${fechaD('🔔')} Usuario pospuso la notificación');

    // Posponer por 5 minutos
    const snoozeDuration = Duration(minutes: 5);

    notificationBloc.add(SnoozeNotification(
      notificationId: 'schedule_$scheduleId',
      snoozeDuration: snoozeDuration,
    ));

    debugPrint(
        '${fechaD('🔄')}    ✅ Notificación pospuesta por ${snoozeDuration.inMinutes} minutos');
  }

  /// Maneja cuando el usuario simplemente toca la notificación
  void _handleNotificationTap(String scheduleId, String? userId) {
    debugPrint(
        '${fechaD('👆')} Usuario tocó la notificación (Schedule: $scheduleId)');
    debugPrint('${fechaD()}    → Preparando navegación...');

    final targetRoute = userId != null
        ? '${Routes.measurementForm}?userId=$userId'
        : Routes.measurementForm;

    // Guardamos como ruta pendiente por si el router no está listo o la app se está abriendo
    PendingRoute.route = targetRoute;

    // Intentamos navegar inmediatamente con un pequeño delay para asegurar que el frame actual terminó
    Future.delayed(const Duration(milliseconds: 300), () {
      if (PendingRoute.route == targetRoute) {
        debugPrint('${fechaD()}    → Ejecutando push demorado a: $targetRoute');
        appRouter.push(targetRoute);
        PendingRoute.consume(); // Limpiamos si tuvo éxito
      }
    });
  }
}
