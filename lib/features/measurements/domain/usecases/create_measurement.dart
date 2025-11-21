import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:mta/core/error/failures.dart';
import 'package:mta/core/usecases/usecases.dart';
import 'package:mta/features/measurements/domain/entities/measurement_entity.dart';
import 'package:mta/features/measurements/domain/repositories/measurement_repository.dart';

class CreateMeasurement
    implements UseCase<MeasurementEntity, CreateMeasurementParams> {
  final MeasurementRepository repository;

  CreateMeasurement(this.repository);

  @override
  Future<Either<Failure, MeasurementEntity>> call(
      CreateMeasurementParams params) async {
    return await repository.createMeasurement(params.measurement);
  }
}

class CreateMeasurementParams extends Equatable {
  final MeasurementEntity measurement;

  const CreateMeasurementParams({required this.measurement});

  @override
  List<Object> get props => [measurement];
}
