import 'package:dartz/dartz.dart';
import 'package:mta/core/error/failures.dart';
import 'package:mta/features/schedules/data/datasources/schedule_local_data_source.dart';
import 'package:mta/features/schedules/data/models/schedule_model.dart';
import 'package:mta/features/schedules/domain/entities/schedule_entity.dart';
import 'package:mta/features/schedules/domain/repositories/schedule_repository.dart';

class ScheduleRepositoryImpl implements ScheduleRepository {
  final ScheduleLocalDataSource localDataSource;

  ScheduleRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, List<ScheduleEntity>>> getSchedules(
      String userId) async {
    try {
      final schedules = await localDataSource.getSchedules(userId);
      return Right(schedules);
    } on CacheFailure catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, ScheduleEntity>> createSchedule(
      ScheduleEntity schedule) async {
    try {
      final scheduleModel = ScheduleModel.fromEntity(schedule);
      final createdSchedule =
          await localDataSource.createSchedule(scheduleModel);
      return Right(createdSchedule);
    } on CacheFailure catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, ScheduleEntity>> updateSchedule(
      ScheduleEntity schedule) async {
    try {
      final scheduleModel = ScheduleModel.fromEntity(schedule);
      final updatedSchedule =
          await localDataSource.updateSchedule(scheduleModel);
      return Right(updatedSchedule);
    } on CacheFailure catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> deleteSchedule(String id) async {
    try {
      await localDataSource.deleteSchedule(id);
      return const Right(null);
    } on CacheFailure catch (e) {
      return Left(CacheFailure(e.message));
    }
  }
}
