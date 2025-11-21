import 'package:equatable/equatable.dart';
import 'package:mta/features/schedules/domain/entities/schedule_entity.dart';

abstract class ScheduleEvent extends Equatable {
  const ScheduleEvent();

  @override
  List<Object?> get props => [];
}

class LoadSchedulesEvent extends ScheduleEvent {
  final String userId;

  const LoadSchedulesEvent(this.userId);

  @override
  List<Object> get props => [userId];
}

class CreateScheduleEvent extends ScheduleEvent {
  final ScheduleEntity schedule;

  const CreateScheduleEvent(this.schedule);

  @override
  List<Object> get props => [schedule];
}

class UpdateScheduleEvent extends ScheduleEvent {
  final ScheduleEntity schedule;

  const UpdateScheduleEvent(this.schedule);

  @override
  List<Object> get props => [schedule];
}

class DeleteScheduleEvent extends ScheduleEvent {
  final String id;
  final String userId;

  const DeleteScheduleEvent(this.id, this.userId);

  @override
  List<Object> get props => [id, userId];
}

class ToggleScheduleEvent extends ScheduleEvent {
  final ScheduleEntity schedule;

  const ToggleScheduleEvent(this.schedule);

  @override
  List<Object> get props => [schedule];
}
