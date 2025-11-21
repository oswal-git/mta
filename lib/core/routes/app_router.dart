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
        return MeasurementFormPage(measurementId: measurementId);
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
  ],
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Text('Error: ${state.error}'),
    ),
  ),
);
