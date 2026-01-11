import 'package:equatable/equatable.dart';
import 'package:mta/features/measurements/domain/entities/measurement_entity.dart';

abstract class MeasurementState extends Equatable {
  const MeasurementState();

  @override
  List<Object?> get props => [];
}

class MeasurementInitial extends MeasurementState {}

class MeasurementLoading extends MeasurementState {}

class MeasurementsLoaded extends MeasurementState {
  final List<MeasurementEntity> measurements;
  final String userId;

  const MeasurementsLoaded({
    required this.measurements,
    required this.userId,
  });

  @override
  List<Object> get props => [measurements, userId];
}

class MeasurementDetailLoaded extends MeasurementState {
  final MeasurementEntity measurement;

  const MeasurementDetailLoaded(this.measurement);

  @override
  List<Object> get props => [measurement];
}

class MeasurementNumberLoaded extends MeasurementState {
  final int nextNumber;

  const MeasurementNumberLoaded(this.nextNumber);

  @override
  List<Object> get props => [nextNumber];
}

class NextMeasurementNumberLoaded extends MeasurementState {
  final int number;

  const NextMeasurementNumberLoaded({required this.number});

  @override
  List<Object> get props => [number];
}

class MeasurementOperationSuccess extends MeasurementState {
  final String message;
  final String? userId;

  const MeasurementOperationSuccess(this.message, {this.userId});

  @override
  List<Object?> get props => [message, userId];
}

class MeasurementError extends MeasurementState {
  final String message;

  const MeasurementError(this.message);

  @override
  List<Object> get props => [message];
}
