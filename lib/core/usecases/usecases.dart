import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:mta/core/error/failures.dart';

/// Base class for all use cases in the application
///
/// [T] is the return type
/// [Params] is the parameter type
abstract class UseCase<T, Params> {
  Future<Either<Failure, T>> call(Params params);
}

/// Used when a use case doesn't need any parameters
class NoParams extends Equatable {
  @override
  List<Object> get props => [];
}
