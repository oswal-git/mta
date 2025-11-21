import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:mta/core/error/failures.dart';
import 'package:mta/core/usecases/usecases.dart';
import 'package:mta/features/measurements/domain/entities/measurement_entity.dart';
import 'package:mta/features/measurements/domain/repositories/measurement_repository.dart';

class GetMeasurements
    implements UseCase<List<MeasurementEntity>, GetMeasurementsParams> {
  final MeasurementRepository repository;

  GetMeasurements(this.repository);

  @override
  Future<Either<Failure, List<MeasurementEntity>>> call(
      GetMeasurementsParams params) async {
    return await repository.getMeasurements(params.userId);
  }
}

class GetMeasurementsParams extends Equatable {
  final String userId;

  const GetMeasurementsParams({required this.userId});

  @override
  List<Object> get props => [userId];
}
