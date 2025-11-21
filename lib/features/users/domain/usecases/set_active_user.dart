import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:mta/core/error/failures.dart';
import 'package:mta/core/usecases/usecases.dart';
import 'package:mta/features/users/domain/repositories/user_repository.dart';

class SetActiveUser implements UseCase<void, SetActiveUserParams> {
  final UserRepository repository;

  SetActiveUser(this.repository);

  @override
  Future<Either<Failure, void>> call(SetActiveUserParams params) async {
    return await repository.setActiveUser(params.userId);
  }
}

class SetActiveUserParams extends Equatable {
  final String userId;

  const SetActiveUserParams({required this.userId});

  @override
  List<Object> get props => [userId];
}
