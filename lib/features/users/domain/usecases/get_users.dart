import 'package:dartz/dartz.dart';
import 'package:mta/core/error/failures.dart';
import 'package:mta/core/usecases/usecases.dart';
import 'package:mta/features/users/domain/entities/user_entity.dart';
import 'package:mta/features/users/domain/repositories/user_repository.dart';

class GetUsers implements UseCase<List<UserEntity>, NoParams> {
  final UserRepository repository;

  GetUsers(this.repository);

  @override
  Future<Either<Failure, List<UserEntity>>> call(NoParams params) async {
    return await repository.getUsers();
  }
}
