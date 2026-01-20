import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';

/// Helper para gestionar permisos de notificaciones
class NotificationPermissionHandler {
  static const platform = MethodChannel('es.eglos.mta/notifications');

  /// Verifica y solicita todos los permisos necesarios
  static Future<bool> requestAllPermissions() async {
    try {
      debugPrint('📋 Verificando permisos de notificaciones ...');

      // 1. Permiso de notificaciones (Android 13+)
      final notificationStatus = await Permission.notification.status;
      if (!notificationStatus.isGranted) {
        debugPrint('🔔 Solicitando permiso de notificaciones...');
        final result = await Permission.notification.request();
        if (!result.isGranted) {
          debugPrint('❌ Permiso de notificaciones denegado');
          return false;
        }
      }

      // 2. Permiso de alarmas exactas (Android 12+) - necesario para notificaciones exactas
      final canScheduleExactNotifications =
          await checkExactNotificationPermission();
      debugPrint(
          '⏰ Permiso de alarmas exactas: $canScheduleExactNotifications');

      if (!canScheduleExactNotifications) {
        debugPrint(
            '⚠️ Notificación: Requisito de ALARMA EXACTA no concedido. Abriendo ajustes...');
        await openExactNotificationSettings();
        return false;
      }

      debugPrint('✅ Todos los permisos concedidos');
      return true;
    } catch (e) {
      debugPrint('❌ Error al verificar permisos: $e');
      return false;
    }
  }

  /// Verifica si se puede programar notificaciones exactas
  static Future<bool> checkExactNotificationPermission() async {
    try {
      if (defaultTargetPlatform == TargetPlatform.android) {
        final bool canSchedule =
            await platform.invokeMethod('canScheduleExactAlarms');
        return canSchedule;
      }
      return true; // iOS no requiere este permiso
    } catch (e) {
      debugPrint('Error al verificar permiso de notificaciones exactas: $e');
      return false;
    }
  }

  /// Abre la configuración para permitir notificaciones exactas
  static Future<void> openExactNotificationSettings() async {
    try {
      if (defaultTargetPlatform == TargetPlatform.android) {
        await platform.invokeMethod('openExactAlarmSettings');
        debugPrint('🔧 Abriendo configuración de notificaciones exactas...');
      }
    } catch (e) {
      debugPrint('Error al abrir configuración: $e');
    }
  }

  /// Verifica si el permiso de notificaciones está concedido
  static Future<bool> hasNotificationPermission() async {
    final status = await Permission.notification.status;
    return status.isGranted;
  }
}
