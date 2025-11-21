import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:mta/core/error/failures.dart';
import 'package:mta/core/usecases/usecases.dart';
import 'package:mta/features/schedules/domain/entities/schedule_entity.dart';
import 'package:mta/features/schedules/domain/repositories/schedule_repository.dart';

class UpdateSchedule implements UseCase<ScheduleEntity, UpdateScheduleParams> {
  final ScheduleRepository repository;

  UpdateSchedule(this.repository);

  @override
  Future<Either<Failure, ScheduleEntity>> call(
      UpdateScheduleParams params) async {
    return await repository.updateSchedule(params.schedule);
  }
}

class UpdateScheduleParams extends Equatable {
  final ScheduleEntity schedule;

  const UpdateScheduleParams({required this.schedule});

  @override
  List<Object> get props => [schedule];
}
