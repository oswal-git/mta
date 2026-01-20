import 'package:equatable/equatable.dart';

/// User entity representing a person who uses the application
class UserEntity extends Equatable {
  final String id;
  final String name;
  final int? age;
  final bool takeMedication;
  final String? medicationName;
  final bool enableNotifications;
  final bool notificationSoundEnabled;
  final String? notificationSoundUri;
  final String languageCode;
  final String? bpMonitorModel;
  final String? measurementLocation;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserEntity({
    required this.id,
    required this.name,
    this.age,
    this.takeMedication = false,
    this.medicationName,
    this.enableNotifications = true,
    this.notificationSoundEnabled = true,
    this.notificationSoundUri,
    this.languageCode = 'es',
    this.bpMonitorModel,
    this.measurementLocation,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Creates a copy of this user with the given fields replaced
  UserEntity copyWith({
    String? id,
    String? name,
    int? age,
    bool? takeMedication,
    String? medicationName,
    bool? enableNotifications,
    bool? notificationSoundEnabled,
    String? notificationSoundUri,
    String? languageCode,
    String? bpMonitorModel,
    String? measurementLocation,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      age: age ?? this.age,
      takeMedication: takeMedication ?? this.takeMedication,
      medicationName: medicationName ?? this.medicationName,
      enableNotifications: enableNotifications ?? this.enableNotifications,
      notificationSoundEnabled:
          notificationSoundEnabled ?? this.notificationSoundEnabled,
      notificationSoundUri: notificationSoundUri ?? this.notificationSoundUri,
      languageCode: languageCode ?? this.languageCode,
      bpMonitorModel: bpMonitorModel ?? this.bpMonitorModel,
      measurementLocation: measurementLocation ?? this.measurementLocation,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        age,
        takeMedication,
        medicationName,
        enableNotifications,
        notificationSoundEnabled,
        notificationSoundUri,
        languageCode,
        bpMonitorModel,
        measurementLocation,
        createdAt,
        updatedAt,
      ];
}
