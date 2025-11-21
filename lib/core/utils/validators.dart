/// Validation utilities for the application
class Validators {
  /// Validates that a string is not empty
  static String? required(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  /// Validates that a string represents a valid integer
  static String? integer(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return null; // Allow empty for optional fields
    }

    if (int.tryParse(value) == null) {
      return '$fieldName must be a valid number';
    }
    return null;
  }

  /// Validates that a string represents a valid positive integer
  static String? positiveInteger(String? value, String fieldName) {
    final intError = integer(value, fieldName);
    if (intError != null) return intError;

    if (value != null && value.isNotEmpty) {
      final intValue = int.parse(value);
      if (intValue <= 0) {
        return '$fieldName must be greater than 0';
      }
    }
    return null;
  }

  /// Validates blood pressure systolic value
  static String? systolic(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Systolic is required';
    }

    final intValue = int.tryParse(value);
    if (intValue == null) {
      return 'Systolic must be a valid number';
    }

    if (intValue < 50 || intValue > 300) {
      return 'Systolic must be between 50 and 300';
    }

    return null;
  }

  /// Validates blood pressure diastolic value
  static String? diastolic(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Diastolic is required';
    }

    final intValue = int.tryParse(value);
    if (intValue == null) {
      return 'Diastolic must be a valid number';
    }

    if (intValue < 30 || intValue > 200) {
      return 'Diastolic must be between 30 and 200';
    }

    return null;
  }

  /// Validates pulse value
  static String? pulse(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Pulse is optional
    }

    final intValue = int.tryParse(value);
    if (intValue == null) {
      return 'Pulse must be a valid number';
    }

    if (intValue < 30 || intValue > 250) {
      return 'Pulse must be between 30 and 250';
    }

    return null;
  }

  /// Validates age
  static String? age(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Age is optional
    }

    final intValue = int.tryParse(value);
    if (intValue == null) {
      return 'Age must be a valid number';
    }

    if (intValue < 1 || intValue > 150) {
      return 'Age must be between 1 and 150';
    }

    return null;
  }

  /// Validates that start date/time is before end date/time
  static String? dateTimeRange(DateTime start, DateTime end) {
    if (start.isAfter(end) || start.isAtSameMomentAs(end)) {
      return 'Start must be before end';
    }

    if (end.isAfter(DateTime.now())) {
      return 'End cannot be in the future';
    }

    return null;
  }
}
