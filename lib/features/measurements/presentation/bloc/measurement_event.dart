import 'package:equatable/equatable.dart';
import 'package:mta/features/measurements/domain/entities/measurement_entity.dart';

abstract class MeasurementEvent extends Equatable {
  const MeasurementEvent();

  @override
  List<Object?> get props => [];
}

class LoadMeasurementsEvent extends MeasurementEvent {
  final String userId;

  const LoadMeasurementsEvent(this.userId);

  @override
  List<Object> get props => [userId];
}

class LoadMeasurementByIdEvent extends MeasurementEvent {
  final String id;

  const LoadMeasurementByIdEvent(this.id);

  @override
  List<Object> get props => [id];
}

class CreateMeasurementEvent extends MeasurementEvent {
  final MeasurementEntity measurement;

  const CreateMeasurementEvent(this.measurement);

  @override
  List<Object> get props => [measurement];
}

class UpdateMeasurementEvent extends MeasurementEvent {
  final MeasurementEntity measurement;

  const UpdateMeasurementEvent(this.measurement);

  @override
  List<Object> get props => [measurement];
}

class DeleteMeasurementEvent extends MeasurementEvent {
  final String id;
  final String userId;

  const DeleteMeasurementEvent(this.id, this.userId);

  @override
  List<Object> get props => [id, userId];
}

class GetNextMeasurementNumberEvent extends MeasurementEvent {
  final String userId;
  final DateTime date;

  const GetNextMeasurementNumberEvent(this.userId, this.date);

  @override
  List<Object> get props => [userId, date];
}

class ResetMeasurementStateEvent extends MeasurementEvent {
  const ResetMeasurementStateEvent();
}
