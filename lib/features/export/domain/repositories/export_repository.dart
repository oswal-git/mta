import 'package:dartz/dartz.dart';
import 'package:mta/core/error/failures.dart';
import 'package:mta/features/export/domain/entities/export_params_entity.dart';
import 'package:mta/features/measurements/domain/entities/measurement_entity.dart';

abstract class ExportRepository {
  Future<Either<Failure, String>> exportMeasurements({
    required List<MeasurementEntity> measurements,
    required ExportParamsEntity params,
  });
}
