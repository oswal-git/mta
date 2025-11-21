import 'package:flutter/material.dart';

/// Application-wide constants
class AppConstants {
  // Storage keys
  static const String keyActiveUserId = 'active_user_id';
  static const String keyLanguage = 'language';

  // Limits
  static const int maxSchedules = 10;
  static const int alarmAdvanceMinutes = 5;
  static const int postponeMinutes = 10;

  // Blood pressure thresholds
  static const int systolicNormalMax = 129;
  static const int systolicElevatedMax = 139;
  static const int diastolicNormalMax = 84;
  static const int diastolicElevatedMax = 89;

  // Colors for blood pressure levels
  static const Color colorNormal = Color(0xFFC8E6C9); // Light green
  static const Color colorElevated = Color(0xFFFFE0B2); // Light orange
  static const Color colorHigh = Color(0xFFFFCDD2); // Light red

  // Export
  static const String defaultExportFileName = 'listado_toma_tension';

  // Firestore collections
  static const String collectionUsers = 'users';
  static const String collectionMeasurements = 'measurements';
  static const String collectionSchedules = 'schedules';
}

/// Route names for navigation
class Routes {
  static const String splash = '/';
  static const String home = '/home';
  static const String userForm = '/user-form';
  static const String measurementForm = '/measurement-form';
  static const String measurementDetail = '/measurement-detail';
  static const String scheduleSettings = '/schedule-settings';
  static const String export = '/export';
}

/// Helper to get color based on blood pressure values
Color getBloodPressureColor(int systolic, int diastolic) {
  if (systolic >= 140 || diastolic >= 90) {
    return AppConstants.colorHigh;
  } else if (systolic >= 130 || diastolic >= 85) {
    return AppConstants.colorElevated;
  } else {
    return AppConstants.colorNormal;
  }
}
