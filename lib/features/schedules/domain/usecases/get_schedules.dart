import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:mta/core/error/failures.dart';
import 'package:mta/core/usecases/usecases.dart';
import 'package:mta/features/schedules/domain/entities/schedule_entity.dart';
import 'package:mta/features/schedules/domain/repositories/schedule_repository.dart';

class GetSchedules
    implements UseCase<List<ScheduleEntity>, GetSchedulesParams> {
  final ScheduleRepository repository;

  GetSchedules(this.repository);

  @override
  Future<Either<Failure, List<ScheduleEntity>>> call(
      GetSchedulesParams params) async {
    return await repository.getSchedules(params.userId);
  }
}

class GetSchedulesParams extends Equatable {
  final String userId;

  const GetSchedulesParams({required this.userId});

  @override
  List<Object> get props => [userId];
}
