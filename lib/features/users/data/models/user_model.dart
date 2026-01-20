import 'package:mta/core/database/database.dart';
import 'package:mta/features/users/domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.name,
    super.age,
    super.takeMedication,
    super.medicationName,
    super.enableNotifications,
    super.notificationSoundEnabled,
    super.notificationSoundUri,
    super.languageCode,
    super.bpMonitorModel,
    super.measurementLocation,
    required super.createdAt,
    required super.updatedAt,
  });

  factory UserModel.fromDao(UsersDaoData user) {
    return UserModel(
      id: user.id,
      name: user.name,
      age: user.age,
      takeMedication: user.takeMedication,
      medicationName: user.medicationName,
      enableNotifications: user.enableNotifications,
      notificationSoundEnabled: user.notificationSoundEnabled,
      notificationSoundUri: user.notificationSoundUri,
      languageCode: user.languageCode,
      bpMonitorModel: user.bpMonitorModel,
      measurementLocation: user.measurementLocation,
      createdAt: user.createdAt,
      updatedAt: user.updatedAt,
    );
  }

  UsersDaoData toDao() {
    return UsersDaoData(
      id: id,
      name: name,
      age: age,
      takeMedication: takeMedication,
      medicationName: medicationName,
      enableNotifications: enableNotifications,
      notificationSoundEnabled: notificationSoundEnabled,
      notificationSoundUri: notificationSoundUri,
      languageCode: languageCode,
      bpMonitorModel: bpMonitorModel,
      measurementLocation: measurementLocation,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  factory UserModel.fromEntity(UserEntity user) {
    return UserModel(
      id: user.id,
      name: user.name,
      age: user.age,
      takeMedication: user.takeMedication,
      medicationName: user.medicationName,
      enableNotifications: user.enableNotifications,
      notificationSoundEnabled: user.notificationSoundEnabled,
      notificationSoundUri: user.notificationSoundUri,
      languageCode: user.languageCode,
      bpMonitorModel: user.bpMonitorModel,
      measurementLocation: user.measurementLocation,
      createdAt: user.createdAt,
      updatedAt: user.updatedAt,
    );
  }
}
