import 'package:drift/drift.dart' as drift;
import 'package:mta/core/database/database.dart';
import 'package:mta/core/error/failures.dart';
import 'package:mta/features/measurements/data/models/measurement_model.dart';

abstract class MeasurementLocalDataSource {
  Future<List<MeasurementModel>> getMeasurements(String userId);
  Future<MeasurementModel?> getMeasurementById(String id);
  Future<MeasurementModel> createMeasurement(MeasurementModel measurement);
  Future<MeasurementModel> updateMeasurement(MeasurementModel measurement);
  Future<void> deleteMeasurement(String id);
  Future<void> deleteMeasurementsByDateRange(
      String userId, DateTime? startDate, DateTime? endDate);
  Future<int> getNextMeasurementNumber(String userId, DateTime date);
  Future<void> restoreMeasurements(List<MeasurementModel> measurements);
}

class MeasurementLocalDataSourceImpl implements MeasurementLocalDataSource {
  final AppDatabase database;

  MeasurementLocalDataSourceImpl({required this.database});

  @override
  Future<List<MeasurementModel>> getMeasurements(String userId) async {
    try {
      final measurements = await (database.select(database.measurementsDao)
            ..where((tbl) => tbl.userId.equals(userId))
            ..orderBy([
              (tbl) => drift.OrderingTerm.desc(tbl.measurementTime),
              (tbl) => drift.OrderingTerm.desc(tbl.measurementNumber),
            ]))
          .get();

      return measurements.map((m) => MeasurementModel.fromDao(m)).toList();
    } catch (e) {
      throw CacheFailure(
          'Database failure: Failed to load measurements for user $userId. ${e.toString()}');
    }
  }

  @override
  Future<MeasurementModel?> getMeasurementById(String id) async {
    try {
      final MeasurementsDaoData? measurement =
          await (database.select(database.measurementsDao)
                ..where((tbl) => tbl.id.equals(id)))
              .getSingleOrNull();

      return measurement != null ? MeasurementModel.fromDao(measurement) : null;
    } catch (e) {
      throw CacheFailure(
          'Database failure: Failed to load measurement $id. ${e.toString()}');
    }
  }

  @override
  Future<MeasurementModel> createMeasurement(
      MeasurementModel measurement) async {
    try {
      await database.into(database.measurementsDao).insert(measurement.toDao());
      return measurement;
    } catch (e) {
      throw CacheFailure(
          'Database failure: Failed to create measurement. ${e.toString()}');
    }
  }

  @override
  Future<MeasurementModel> updateMeasurement(
      MeasurementModel measurement) async {
    try {
      await database.update(database.measurementsDao).replace(
            measurement.toDao(),
          );
      return measurement;
    } catch (e) {
      throw CacheFailure(
          'Database failure: Failed to update measurement ${measurement.id}. ${e.toString()}');
    }
  }

  @override
  Future<void> deleteMeasurement(String id) async {
    try {
      await (database.delete(database.measurementsDao)
            ..where((tbl) => tbl.id.equals(id)))
          .go();
    } catch (e) {
      throw CacheFailure(
          'Database failure: Failed to delete measurement $id. ${e.toString()}');
    }
  }

  @override
  Future<void> deleteMeasurementsByDateRange(
      String userId, DateTime? startDate, DateTime? endDate) async {
    try {
      await (database.delete(database.measurementsDao)
            ..where((tbl) {
              var condition = tbl.userId.equals(userId);
              if (startDate != null) {
                condition = condition &
                    tbl.measurementTime.isBiggerOrEqualValue(startDate);
              }
              if (endDate != null) {
                condition = condition &
                    tbl.measurementTime.isSmallerOrEqualValue(endDate);
              }
              return condition;
            }))
          .go();
    } catch (e) {
      throw CacheFailure(
          'Database failure: Failed to delete measurements in range for user $userId. ${e.toString()}');
    }
  }

  @override
  Future<int> getNextMeasurementNumber(String userId, DateTime date) async {
    try {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final query = database.selectOnly(database.measurementsDao)
        ..addColumns([database.measurementsDao.measurementNumber.max()])
        ..where(database.measurementsDao.userId.equals(userId) &
            database.measurementsDao.measurementTime
                .isBiggerOrEqualValue(startOfDay) &
            database.measurementsDao.measurementTime
                .isSmallerThanValue(endOfDay));

      final result = await query.getSingle();
      final maxNumber =
          result.read(database.measurementsDao.measurementNumber.max());

      return (maxNumber ?? 0) + 1;
    } catch (e) {
      throw CacheFailure(
          'Database failure: Failed to calculate next measurement number. ${e.toString()}');
    }
  }

  @override
  Future<void> restoreMeasurements(List<MeasurementModel> measurements) async {
    try {
      await database.batch((batch) {
        batch.insertAll(
          database.measurementsDao,
          measurements.map((m) => m.toDao()).toList(),
          mode: drift.InsertMode.insertOrReplace,
        );
      });
    } catch (e) {
      throw CacheFailure(
          'Database failure: Failed to restore batch measurements. ${e.toString()}');
    }
  }
}
