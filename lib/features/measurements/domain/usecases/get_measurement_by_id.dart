import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:mta/core/error/failures.dart';
import 'package:mta/core/usecases/usecases.dart';
import 'package:mta/features/measurements/domain/entities/measurement_entity.dart';
import 'package:mta/features/measurements/domain/repositories/measurement_repository.dart';

class GetMeasurementById
    implements UseCase<MeasurementEntity, GetMeasurementByIdParams> {
  final MeasurementRepository repository;

  GetMeasurementById(this.repository);

  @override
  Future<Either<Failure, MeasurementEntity>> call(
      GetMeasurementByIdParams params) async {
    return await repository.getMeasurementById(params.id);
  }
}

class GetMeasurementByIdParams extends Equatable {
  final String id;

  const GetMeasurementByIdParams({required this.id});

  @override
  List<Object> get props => [id];
}
