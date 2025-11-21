import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:mta/core/error/failures.dart';
import 'package:mta/core/usecases/usecases.dart';
import 'package:mta/features/users/domain/entities/user_entity.dart';
import 'package:mta/features/users/domain/repositories/user_repository.dart';

class UpdateUser implements UseCase<UserEntity, UpdateUserParams> {
  final UserRepository repository;

  UpdateUser(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(UpdateUserParams params) async {
    return await repository.updateUser(params.user);
  }
}

class UpdateUserParams extends Equatable {
  final UserEntity user;

  const UpdateUserParams({required this.user});

  @override
  List<Object> get props => [user];
}
