import 'package:equatable/equatable.dart';

/// User entity representing a person who uses the application
class UserEntity extends Equatable {
  final String id;
  final String name;
  final int? age;
  final bool hasMedication;
  final String? medicationName;
  final bool enableNotifications;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserEntity({
    required this.id,
    required this.name,
    this.age,
    this.hasMedication = false,
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
    bool? hasMedication,
    String? medicationName,
    bool? enableNotifications,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      age: age ?? this.age,
      hasMedication: hasMedication ?? this.hasMedication,
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
        hasMedication,
        medicationName,
        enableNotifications,
        createdAt,
        updatedAt,
      ];
}
