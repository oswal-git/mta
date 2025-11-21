// ===== lib/features/users/domain/repositories/user_repository.dart =====
import 'package:dartz/dartz.dart';
import 'package:mta/core/error/failures.dart';
import 'package:mta/features/users/domain/entities/user_entity.dart';

abstract class UserRepository {
  Future<Either<Failure, List<UserEntity>>> getUsers();
  Future<Either<Failure, UserEntity?>> getActiveUser();
  Future<Either<Failure, UserEntity>> createUser(UserEntity user);
  Future<Either<Failure, UserEntity>> updateUser(UserEntity user);
  Future<Either<Failure, void>> deleteUser(String userId);
  Future<Either<Failure, void>> setActiveUser(String userId);
}
