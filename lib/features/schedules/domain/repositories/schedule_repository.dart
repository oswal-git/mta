import 'package:dartz/dartz.dart';
import 'package:mta/core/error/failures.dart';
import 'package:mta/features/schedules/domain/entities/schedule_entity.dart';

abstract class ScheduleRepository {
  Future<Either<Failure, List<ScheduleEntity>>> getSchedules(String userId);
  Future<Either<Failure, ScheduleEntity>> createSchedule(
      ScheduleEntity schedule);
  Future<Either<Failure, ScheduleEntity>> updateSchedule(
      ScheduleEntity schedule);
  Future<Either<Failure, void>> deleteSchedule(String id);
}
