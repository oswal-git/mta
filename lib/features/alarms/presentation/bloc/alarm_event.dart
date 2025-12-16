import 'package:equatable/equatable.dart';
import 'package:mta/features/alarms/domain/entities/alarm_entity.dart';

/// Eventos del BLoC de alarmas
sealed class AlarmEvent extends Equatable {
  const AlarmEvent();

  @override
  List<Object?> get props => [];
}

/// Evento para programar una nueva alarma
class SetAlarm extends AlarmEvent {
  final AlarmEntity alarm;

  const SetAlarm(this.alarm);

  @override
  List<Object?> get props => [alarm];
}

/// Evento para detener/cancelar una alarma
class StopAlarm extends AlarmEvent {
  final String alarmId;

  const StopAlarm(this.alarmId);

  @override
  List<Object?> get props => [alarmId];
}

/// Evento para posponer una alarma
class SnoozeAlarm extends AlarmEvent {
  final String alarmId;
  final Duration snoozeDuration;

  const SnoozeAlarm({
    required this.alarmId,
    required this.snoozeDuration,
  });

  @override
  List<Object?> get props => [alarmId, snoozeDuration];
}

/// Evento para cancelar todas las alarmas
class CancelAllAlarms extends AlarmEvent {
  const CancelAllAlarms();
}

/// Evento para verificar si una alarma está activa
class CheckAlarmStatus extends AlarmEvent {
  final String alarmId;

  const CheckAlarmStatus(this.alarmId);

  @override
  List<Object?> get props => [alarmId];
}

/// Evento para programar alarmas para todos los schedules de un usuario
class SetAlarmsForUser extends AlarmEvent {
  final String userId;

  const SetAlarmsForUser(this.userId);

  @override
  List<Object?> get props => [userId];
}

/// Evento para reprogramar todas las alarmas
/// (útil después de cambios en schedules)
class RescheduleAllAlarms extends AlarmEvent {
  const RescheduleAllAlarms();
}
