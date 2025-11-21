import 'package:drift/drift.dart' as drift;
import 'package:mta/core/database/database.dart';
import 'package:mta/core/error/failures.dart';
import 'package:mta/features/schedules/data/models/schedule_model.dart';

abstract class ScheduleLocalDataSource {
  Future<List<ScheduleModel>> getSchedules(String userId);
  Future<ScheduleModel> createSchedule(ScheduleModel schedule);
  Future<ScheduleModel> updateSchedule(ScheduleModel schedule);
  Future<void> deleteSchedule(String id);
}

class ScheduleLocalDataSourceImpl implements ScheduleLocalDataSource {
  final AppDatabase database;

  ScheduleLocalDataSourceImpl({required this.database});

  @override
  Future<List<ScheduleModel>> getSchedules(String userId) async {
    try {
      final schedules = await (database.select(database.schedulesDao)
            ..where((tbl) => tbl.userId.equals(userId))
            ..orderBy([
              (tbl) => drift.OrderingTerm.asc(tbl.hour),
              (tbl) => drift.OrderingTerm.asc(tbl.minute),
            ]))
          .get();

      return schedules.map((s) => ScheduleModel.fromDao(s)).toList();
    } catch (e) {
      throw CacheFailure('Failed to load schedules: ${e.toString()}');
    }
  }

  @override
  Future<ScheduleModel> createSchedule(ScheduleModel schedule) async {
    try {
      await database.into(database.schedulesDao).insert(
            SchedulesDaoCompanion(
              id: drift.Value(schedule.id),
              userId: drift.Value(schedule.userId),
              hour: drift.Value(schedule.hour),
              minute: drift.Value(schedule.minute),
              isEnabled: drift.Value(schedule.isEnabled),
              createdAt: drift.Value(schedule.createdAt),
              updatedAt: drift.Value(schedule.updatedAt),
            ),
          );
      return schedule;
    } catch (e) {
      throw CacheFailure('Failed to create schedule: ${e.toString()}');
    }
  }

  @override
  Future<ScheduleModel> updateSchedule(ScheduleModel schedule) async {
    try {
      await database.update(database.schedulesDao).replace(
            schedule.toDao(),
          );
      return schedule;
    } catch (e) {
      throw CacheFailure('Failed to update schedule: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteSchedule(String id) async {
    try {
      await (database.delete(database.schedulesDao)
            ..where((tbl) => tbl.id.equals(id)))
          .go();
    } catch (e) {
      throw CacheFailure('Failed to delete schedule: ${e.toString()}');
    }
  }
}
