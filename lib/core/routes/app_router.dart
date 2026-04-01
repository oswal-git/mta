import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mta/features/export/presentation/pages/export_page.dart';
import 'package:mta/features/schedules/presentation/pages/schedule_settings_page.dart';
import 'package:mta/core/utils/constants.dart';
import 'package:mta/features/users/presentation/pages/splash_page.dart';
import 'package:mta/features/users/presentation/pages/user_form_page.dart';
import 'package:mta/features/measurements/presentation/pages/home_page.dart';
import 'package:mta/features/measurements/presentation/pages/measurement_form_page.dart';
import 'package:mta/features/measurements/presentation/pages/measurement_detail_page.dart';

import 'package:mta/features/notifications/presentation/pages/notification_ring_page.dart';
import 'package:mta/features/notifications/domain/entities/notification_entity.dart';

/// Clase para manejar rutas pendientes desde notificaciones
class PendingRoute {
  static String? _route;
  static String? get route => _route;
  static set route(String? value) {
    debugPrint('📍 PendingRoute set to: $value');
    _route = value;
  }

  static String? consume() {
    final r = _route;
    if (r != null) debugPrint('📍 PendingRoute consumed: $r');
    _route = null;
    return r;
  }
}

final appRouter = GoRouter(
  initialLocation: Routes.splash,
  routes: [
    GoRoute(
      path: Routes.splash,
      builder: (context, state) => const SplashPage(),
    ),
    GoRoute(
      path: Routes.home,
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: Routes.userForm,
      builder: (context, state) {
        final userId = state.uri.queryParameters['userId'];
        return UserFormPage(userId: userId);
      },
    ),
    GoRoute(
      path: Routes.measurementForm,
      builder: (context, state) {
        final measurementId = state.uri.queryParameters['measurementId'];
        final userId = state.uri.queryParameters['userId'];
        return MeasurementFormPage(
            measurementId: measurementId, userId: userId);
      },
    ),
    GoRoute(
      path: Routes.measurementDetail,
      builder: (context, state) {
        final measurementId = state.uri.queryParameters['measurementId']!;
        return MeasurementDetailPage(measurementId: measurementId);
      },
    ),
    GoRoute(
      path: Routes.scheduleSettings,
      builder: (context, state) => const ScheduleSettingsPage(),
    ),
    GoRoute(
      path: Routes.export,
      builder: (context, state) => const ExportPage(),
    ),
    GoRoute(
      path: Routes.notificationRing,
      builder: (context, state) {
        final notification = state.extra as NotificationEntity;
        return NotificationRingPage(notification: notification);
      },
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Text('Error: ${state.error}'),
    ),
  ),
);
