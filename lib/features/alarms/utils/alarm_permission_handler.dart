import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';

/// Helper para gestionar permisos de alarmas y notificaciones
class AlarmPermissionHandler {
  static const platform = MethodChannel('com.example.mta/alarms');

  /// Verifica y solicita todos los permisos necesarios
  static Future<bool> requestAllPermissions() async {
    try {
      debugPrint('📋 Verificando permisos de notificaciones y alarmas...');

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

      // 2. Permiso de alarmas exactas (Android 12+)
      final canScheduleExactAlarms = await checkExactAlarmPermission();
      if (!canScheduleExactAlarms) {
        debugPrint('⚠️ Permiso de alarmas exactas no disponible');
        await openExactAlarmSettings();
        return false;
      }

      debugPrint('✅ Todos los permisos concedidos');
      return true;
    } catch (e) {
      debugPrint('❌ Error al verificar permisos: $e');
      return false;
    }
  }

  /// Verifica si se puede programar alarmas exactas
  static Future<bool> checkExactAlarmPermission() async {
    try {
      if (defaultTargetPlatform == TargetPlatform.android) {
        final bool canSchedule =
            await platform.invokeMethod('canScheduleExactAlarms');
        return canSchedule;
      }
      return true; // iOS no requiere este permiso
    } catch (e) {
      debugPrint('Error al verificar permiso de alarmas exactas: $e');
      return false;
    }
  }

  /// Abre la configuración para permitir alarmas exactas
  static Future<void> openExactAlarmSettings() async {
    try {
      if (defaultTargetPlatform == TargetPlatform.android) {
        await platform.invokeMethod('openExactAlarmSettings');
        debugPrint('🔧 Abriendo configuración de alarmas exactas...');
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
