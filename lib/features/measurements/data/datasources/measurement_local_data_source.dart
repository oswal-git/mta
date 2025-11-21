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
  Future<int> getNextMeasurementNumber(String userId, DateTime date);
}

class MeasurementLocalDataSourceImpl implements MeasurementLocalDataSource {
  final AppDatabase database;

  MeasurementLocalDataSourceImpl({required this.database});

  @override
  Future<List<MeasurementModel>> getMeasurements(String userId) async {
    try {
      final measurements = await (database.select(database.measurementsDao)
            ..where((tbl) => tbl.userId.equals(userId))
            ..orderBy([(tbl) => drift.OrderingTerm.desc(tbl.measurementTime)]))
          .get();

      return measurements.map((m) => MeasurementModel.fromDao(m)).toList();
    } catch (e) {
      throw CacheFailure('Failed to load measurements: ${e.toString()}');
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
      throw CacheFailure('Failed to load measurement: ${e.toString()}');
    }
  }

  @override
  Future<MeasurementModel> createMeasurement(
      MeasurementModel measurement) async {
    try {
      await database.into(database.measurementsDao).insert(
            MeasurementsDaoCompanion(
              id: drift.Value(measurement.id),
              userId: drift.Value(measurement.userId),
              measurementTime: drift.Value(measurement.measurementTime),
              measurementNumber: drift.Value(measurement.measurementNumber),
              systolic: drift.Value(measurement.systolic),
              diastolic: drift.Value(measurement.diastolic),
              pulse: drift.Value(measurement.pulse),
              note: drift.Value(measurement.note),
              createdAt: drift.Value(measurement.createdAt),
              updatedAt: drift.Value(measurement.updatedAt),
            ),
          );
      return measurement;
    } catch (e) {
      throw CacheFailure('Failed to create measurement: ${e.toString()}');
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
      throw CacheFailure('Failed to update measurement: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteMeasurement(String id) async {
    try {
      await (database.delete(database.measurementsDao)
            ..where((tbl) => tbl.id.equals(id)))
          .go();
    } catch (e) {
      throw CacheFailure('Failed to delete measurement: ${e.toString()}');
    }
  }

  @override
  Future<int> getNextMeasurementNumber(String userId, DateTime date) async {
    try {
      final measurements = await getMeasurements(userId);

      // Filter measurements from the same date
      final sameDateMeasurements = measurements.where((m) {
        final mDate = m.measurementTime;
        return mDate.year == date.year &&
            mDate.month == date.month &&
            mDate.day == date.day;
      }).toList();

      if (sameDateMeasurements.isEmpty) {
        return 1;
      }

      // Get the maximum measurement number for that date
      final maxNumber = sameDateMeasurements
          .map((m) => m.measurementNumber)
          .reduce((a, b) => a > b ? a : b);

      return maxNumber + 1;
    } catch (e) {
      throw CacheFailure(
          'Failed to get next measurement number: ${e.toString()}');
    }
  }
}
