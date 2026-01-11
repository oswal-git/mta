import 'package:equatable/equatable.dart';

/// Schedule entity representing a scheduled time for taking measurements
class ScheduleEntity extends Equatable {
  final String id;
  final String userId;
  final int hour; // 0-23
  final int minute; // 0-59
  final bool isEnabled;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ScheduleEntity({
    required this.id,
    required this.userId,
    required this.hour,
    required this.minute,
    this.isEnabled = true,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Creates a copy of this schedule with the given fields replaced
  ScheduleEntity copyWith({
    String? id,
    String? userId,
    int? hour,
    int? minute,
    bool? isEnabled,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ScheduleEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      isEnabled: isEnabled ?? this.isEnabled,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Returns a formatted time string (HH:mm)
  String get formattedTime {
    final h = hour.toString().padLeft(2, '0');
    final m = minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  /// Returns the DateTime for today at this schedule's time
  DateTime get todayDateTime {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, hour, minute);
  }

  /// Returns the DateTime for the notification (5 minutes before)
  DateTime get notificationDateTime {
    return todayDateTime.subtract(const Duration(minutes: 5));
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        hour,
        minute,
        isEnabled,
        createdAt,
        updatedAt,
      ];
}
