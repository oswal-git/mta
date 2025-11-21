import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:mta/core/error/failures.dart';
import 'package:mta/core/usecases/usecases.dart';
import 'package:mta/features/measurements/domain/repositories/measurement_repository.dart';

class GetNextMeasurementNumber
    implements UseCase<int, GetNextMeasurementNumberParams> {
  final MeasurementRepository repository;

  GetNextMeasurementNumber(this.repository);

  @override
  Future<Either<Failure, int>> call(
      GetNextMeasurementNumberParams params) async {
    return await repository.getNextMeasurementNumber(
        params.userId, params.date);
  }
}

class GetNextMeasurementNumberParams extends Equatable {
  final String userId;
  final DateTime date;

  const GetNextMeasurementNumberParams({
    required this.userId,
    required this.date,
  });

  @override
  List<Object> get props => [userId, date];
}
