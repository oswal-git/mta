import 'package:dartz/dartz.dart';
import 'package:mta/core/error/failures.dart';
import 'package:mta/features/measurements/domain/entities/measurement_entity.dart';

abstract class MeasurementRepository {
  Future<Either<Failure, List<MeasurementEntity>>> getMeasurements(
      String userId);
  Future<Either<Failure, MeasurementEntity>> getMeasurementById(String id);
  Future<Either<Failure, MeasurementEntity>> createMeasurement(
      MeasurementEntity measurement);
  Future<Either<Failure, MeasurementEntity>> updateMeasurement(
      MeasurementEntity measurement);
  Future<Either<Failure, void>> deleteMeasurement(String id);
  Future<Either<Failure, int>> getNextMeasurementNumber(
      String userId, DateTime date);
}
