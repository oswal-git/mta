import 'package:equatable/equatable.dart';

/// Estados del BLoC de alarmas
sealed class AlarmState extends Equatable {
  const AlarmState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial
class AlarmInitial extends AlarmState {
  const AlarmInitial();
}

/// Estado de carga
class AlarmLoading extends AlarmState {
  const AlarmLoading();
}

/// Estado cuando una alarma se programó exitosamente
class AlarmSet extends AlarmState {
  final String message;

  const AlarmSet({
    this.message = 'Alarma programada correctamente',
  });

  @override
  List<Object?> get props => [message];
}

/// Estado cuando una alarma se detuvo exitosamente
class AlarmStopped extends AlarmState {
  final String message;

  const AlarmStopped({
    this.message = 'Alarma cancelada',
  });

  @override
  List<Object?> get props => [message];
}

/// Estado cuando una alarma se pospuso exitosamente
class AlarmSnoozed extends AlarmState {
  final int minutes;

  const AlarmSnoozed(this.minutes);

  @override
  List<Object?> get props => [minutes];
}

/// Estado cuando todas las alarmas se cancelaron
class AllAlarmsCancelled extends AlarmState {
  final String message;

  const AllAlarmsCancelled({
    this.message = 'Todas las alarmas han sido canceladas',
  });

  @override
  List<Object?> get props => [message];
}

/// Estado con el resultado de verificación de alarma
class AlarmStatusChecked extends AlarmState {
  final String alarmId;
  final bool isActive;

  const AlarmStatusChecked({
    required this.alarmId,
    required this.isActive,
  });

  @override
  List<Object?> get props => [alarmId, isActive];
}

/// Estado cuando se programaron múltiples alarmas para un usuario
class UserAlarmsSet extends AlarmState {
  final int count;
  final String message;

  const UserAlarmsSet({
    required this.count,
    String? message,
  }) : message = message ?? 'Se programaron $count alarmas';

  @override
  List<Object?> get props => [count, message];
}

/// Estado cuando todas las alarmas se reprogramaron
class AlarmsRescheduled extends AlarmState {
  final int count;

  const AlarmsRescheduled(this.count);

  @override
  List<Object?> get props => [count];
}

/// Estado de error
class AlarmError extends AlarmState {
  final String message;

  const AlarmError(this.message);

  @override
  List<Object?> get props => [message];
}
