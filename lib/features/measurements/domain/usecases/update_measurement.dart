import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:mta/core/error/failures.dart';
import 'package:mta/core/usecases/usecases.dart';
import 'package:mta/features/measurements/domain/entities/measurement_entity.dart';
import 'package:mta/features/measurements/domain/repositories/measurement_repository.dart';

class UpdateMeasurement
    implements UseCase<MeasurementEntity, UpdateMeasurementParams> {
  final MeasurementRepository repository;

  UpdateMeasurement(this.repository);

  @override
  Future<Either<Failure, MeasurementEntity>> call(
      UpdateMeasurementParams params) async {
    return await repository.updateMeasurement(params.measurement);
  }
}

class UpdateMeasurementParams extends Equatable {
  final MeasurementEntity measurement;

  const UpdateMeasurementParams({required this.measurement});

  @override
  List<Object> get props => [measurement];
}
