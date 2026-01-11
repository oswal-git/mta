import 'package:mta/core/database/database.dart';
import 'package:mta/features/users/domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.name,
    super.age,
    super.hasMeasuring,
    super.medicationName,
    super.enableNotifications,
    required super.createdAt,
    required super.updatedAt,
  });

  factory UserModel.fromDao(UsersDaoData user) {
    return UserModel(
      id: user.id,
      name: user.name,
      age: user.age,
      hasMeasuring: user.hasMeasuring,
      medicationName: user.measuringName,
      enableNotifications: user.enableNotifications,
      createdAt: user.createdAt,
      updatedAt: user.updatedAt,
    );
  }

  UsersDaoData toDao() {
    return UsersDaoData(
      id: id,
      name: name,
      age: age,
      hasMeasuring: hasMeasuring,
      measuringName: medicationName,
      enableNotifications: enableNotifications,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  factory UserModel.fromEntity(UserEntity user) {
    return UserModel(
      id: user.id,
      name: user.name,
      age: user.age,
      hasMeasuring: user.hasMeasuring,
      medicationName: user.medicationName,
      enableNotifications: user.enableNotifications,
      createdAt: user.createdAt,
      updatedAt: user.updatedAt,
    );
  }
}
