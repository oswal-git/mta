import 'package:equatable/equatable.dart';

/// User entity representing a person who uses the application
class UserEntity extends Equatable {
  final String id;
  final String name;
  final int? age;
  final bool hasMeasuring;
  final String? medicationName;
  final bool enableNotifications;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserEntity({
    required this.id,
    required this.name,
    this.age,
    this.hasMeasuring = false,
    this.medicationName,
    this.enableNotifications = true,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Creates a copy of this user with the given fields replaced
  UserEntity copyWith({
    String? id,
    String? name,
    int? age,
    bool? hasMeasuring,
    String? medicationName,
    bool? enableNotifications,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      age: age ?? this.age,
      hasMeasuring: hasMeasuring ?? this.hasMeasuring,
      medicationName: medicationName ?? this.medicationName,
      enableNotifications: enableNotifications ?? this.enableNotifications,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        age,
        hasMeasuring,
        medicationName,
        enableNotifications,
        createdAt,
        updatedAt,
      ];
}
