import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:mta/core/error/failures.dart';
import 'package:mta/core/usecases/usecases.dart';
import 'package:mta/features/schedules/domain/entities/schedule_entity.dart';
import 'package:mta/features/schedules/domain/repositories/schedule_repository.dart';

class CreateSchedule implements UseCase<ScheduleEntity, CreateScheduleParams> {
  final ScheduleRepository repository;

  CreateSchedule(this.repository);

  @override
  Future<Either<Failure, ScheduleEntity>> call(
      CreateScheduleParams params) async {
    return await repository.createSchedule(params.schedule);
  }
}

class CreateScheduleParams extends Equatable {
  final ScheduleEntity schedule;

  const CreateScheduleParams({required this.schedule});

  @override
  List<Object> get props => [schedule];
}
