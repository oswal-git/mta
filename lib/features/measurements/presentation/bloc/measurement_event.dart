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
  final String userName;

  const UpdateMeasurementEvent(this.measurement, this.userName);

  @override
  List<Object> get props => [measurement, userName];
}

class DeleteMeasurementEvent extends MeasurementEvent {
  final String id;
  final String userId;
  final String userName;

  const DeleteMeasurementEvent(this.id, this.userId, this.userName);

  @override
  List<Object> get props => [id, userId, userName];
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

class ClearMeasurementsByDateRangeEvent extends MeasurementEvent {
  final String userId;
  final String userName;
  final DateTime? startDate;
  final DateTime? endDate;

  const ClearMeasurementsByDateRangeEvent({
    required this.userId,
    required this.userName,
    this.startDate,
    this.endDate,
  });

  @override
  List<Object?> get props => [userId, userName, startDate, endDate];
}

class AutoBackupEvent extends MeasurementEvent {
  final String userId;
  final String userName;

  const AutoBackupEvent({required this.userId, required this.userName});

  @override
  List<Object> get props => [userId, userName];
}

class RestoreMeasurementsEvent extends MeasurementEvent {
  final String userId;
  final String filePath;

  const RestoreMeasurementsEvent(
      {required this.userId, required this.filePath});

  @override
  List<Object> get props => [userId, filePath];
}
