import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:mta/core/error/failures.dart';
import 'package:mta/core/usecases/usecases.dart';
import 'package:mta/features/schedules/domain/repositories/schedule_repository.dart';

class DeleteSchedule implements UseCase<void, DeleteScheduleParams> {
  final ScheduleRepository repository;

  DeleteSchedule(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteScheduleParams params) async {
    return await repository.deleteSchedule(params.id);
  }
}

class DeleteScheduleParams extends Equatable {
  final String id;

  const DeleteScheduleParams({required this.id});

  @override
  List<Object> get props => [id];
}
