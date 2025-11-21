import 'package:dartz/dartz.dart';
import 'package:mta/core/error/failures.dart';
import 'package:mta/features/measurements/data/datasources/measurement_local_data_source.dart';
import 'package:mta/features/measurements/data/models/measurement_model.dart';
import 'package:mta/features/measurements/domain/entities/measurement_entity.dart';
import 'package:mta/features/measurements/domain/repositories/measurement_repository.dart';

class MeasurementRepositoryImpl implements MeasurementRepository {
  final MeasurementLocalDataSource localDataSource;

  MeasurementRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, List<MeasurementEntity>>> getMeasurements(
      String userId) async {
    try {
      final measurements = await localDataSource.getMeasurements(userId);
      return Right(measurements);
    } on CacheFailure catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, MeasurementEntity>> getMeasurementById(
      String id) async {
    try {
      final measurement = await localDataSource.getMeasurementById(id);
      if (measurement == null) {
        return const Left(NotFoundFailure('Measurement not found'));
      }
      return Right(measurement);
    } on CacheFailure catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, MeasurementEntity>> createMeasurement(
    MeasurementEntity measurement,
  ) async {
    try {
      final measurementModel = MeasurementModel.fromEntity(measurement);
      final createdMeasurement =
          await localDataSource.createMeasurement(measurementModel);
      return Right(createdMeasurement);
    } on CacheFailure catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, MeasurementEntity>> updateMeasurement(
    MeasurementEntity measurement,
  ) async {
    try {
      final measurementModel = MeasurementModel.fromEntity(measurement);
      final updatedMeasurement =
          await localDataSource.updateMeasurement(measurementModel);
      return Right(updatedMeasurement);
    } on CacheFailure catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> deleteMeasurement(String id) async {
    try {
      await localDataSource.deleteMeasurement(id);
      return const Right(null);
    } on CacheFailure catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, int>> getNextMeasurementNumber(
    String userId,
    DateTime date,
  ) async {
    try {
      final number =
          await localDataSource.getNextMeasurementNumber(userId, date);
      return Right(number);
    } on CacheFailure catch (e) {
      return Left(CacheFailure(e.message));
    }
  }
}
