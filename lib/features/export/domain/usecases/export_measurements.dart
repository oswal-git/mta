import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:mta/core/error/failures.dart';
import 'package:mta/core/usecases/usecases.dart';
import 'package:mta/features/export/domain/entities/export_params_entity.dart';
import 'package:mta/features/export/domain/repositories/export_repository.dart';
import 'package:mta/features/measurements/domain/entities/measurement_entity.dart';

class ExportMeasurements implements UseCase<String, ExportMeasurementsParams> {
  final ExportRepository repository;

  ExportMeasurements(this.repository);

  @override
  Future<Either<Failure, String>> call(ExportMeasurementsParams params) async {
    return await repository.exportMeasurements(
      measurements: params.measurements,
      params: params.params,
    );
  }
}

class ExportMeasurementsParams extends Equatable {
  final List<MeasurementEntity> measurements;
  final ExportParamsEntity params;

  const ExportMeasurementsParams({
    required this.measurements,
    required this.params,
  });

  @override
  List<Object> get props => [measurements, params];
}
