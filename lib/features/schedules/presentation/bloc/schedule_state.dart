import 'package:equatable/equatable.dart';
import 'package:mta/features/schedules/domain/entities/schedule_entity.dart';

abstract class ScheduleState extends Equatable {
  const ScheduleState();

  @override
  List<Object?> get props => [];
}

class ScheduleInitial extends ScheduleState {}

class ScheduleLoading extends ScheduleState {}

class SchedulesLoaded extends ScheduleState {
  final List<ScheduleEntity> schedules;
  final String userId;

  const SchedulesLoaded({
    required this.schedules,
    required this.userId,
  });

  @override
  List<Object> get props => [schedules, userId];
}

class ScheduleOperationSuccess extends ScheduleState {
  final String message;
  final String? userId;

  const ScheduleOperationSuccess(this.message, {this.userId});

  @override
  List<Object?> get props => [message, userId];
}

class ScheduleError extends ScheduleState {
  final String message;

  const ScheduleError(this.message);

  @override
  List<Object> get props => [message];
}
