import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:mta/core/error/failures.dart';
import 'package:mta/core/usecases/usecases.dart';
import 'package:mta/features/measurements/domain/repositories/measurement_repository.dart';

class DeleteMeasurement implements UseCase<void, DeleteMeasurementParams> {
  final MeasurementRepository repository;

  DeleteMeasurement(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteMeasurementParams params) async {
    return await repository.deleteMeasurement(params.id);
  }
}

class DeleteMeasurementParams extends Equatable {
  final String id;

  const DeleteMeasurementParams({required this.id});

  @override
  List<Object> get props => [id];
}
