import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:mta/core/error/failures.dart';
import 'package:mta/core/usecases/usecases.dart';
import 'package:mta/features/users/domain/repositories/user_repository.dart';

class DeleteUser implements UseCase<void, DeleteUserParams> {
  final UserRepository repository;

  DeleteUser(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteUserParams params) async {
    return await repository.deleteUser(params.userId);
  }
}

class DeleteUserParams extends Equatable {
  final String userId;

  const DeleteUserParams({required this.userId});

  @override
  List<Object> get props => [userId];
}
