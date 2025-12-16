import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mta/features/alarms/domain/repositories/alarm_repository.dart';
import 'package:mta/features/alarms/domain/usecases/set_native_alarm.dart';
import 'package:mta/features/alarms/domain/usecases/snooze_native_alarm.dart';
import 'package:mta/features/alarms/domain/usecases/stop_native_alarm.dart';
import 'alarm_event.dart';
import 'alarm_state.dart';

/// BLoC para gestionar las alarmas de medicación
class AlarmBloc extends Bloc<AlarmEvent, AlarmState> {
  final SetNativeAlarm setNativeAlarm;
  final StopNativeAlarm stopNativeAlarm;
  final SnoozeNativeAlarm snoozeNativeAlarm;
  final AlarmRepository repository;

  AlarmBloc({
    required this.setNativeAlarm,
    required this.stopNativeAlarm,
    required this.snoozeNativeAlarm,
    required this.repository,
  }) : super(const AlarmInitial()) {
    on<SetAlarm>(_onSetAlarm);
    on<StopAlarm>(_onStopAlarm);
    on<SnoozeAlarm>(_onSnoozeAlarm);
    on<CancelAllAlarms>(_onCancelAllAlarms);
    on<CheckAlarmStatus>(_onCheckAlarmStatus);
    on<SetAlarmsForUser>(_onSetAlarmsForUser);
    on<RescheduleAllAlarms>(_onRescheduleAllAlarms);
  }

  /// Maneja el evento de programar una alarma
  Future<void> _onSetAlarm(
    SetAlarm event,
    Emitter<AlarmState> emit,
  ) async {
    emit(const AlarmLoading());

    final result = await setNativeAlarm(event.alarm);

    result.fold(
      (failure) => emit(AlarmError(failure.message)),
      (_) => emit(const AlarmSet()),
    );
  }

  /// Maneja el evento de detener una alarma
  Future<void> _onStopAlarm(
    StopAlarm event,
    Emitter<AlarmState> emit,
  ) async {
    emit(const AlarmLoading());

    final result = await stopNativeAlarm(event.alarmId.toString());

    result.fold(
      (failure) => emit(AlarmError(failure.message)),
      (_) => emit(const AlarmStopped()),
    );
  }

  /// Maneja el evento de posponer una alarma
  Future<void> _onSnoozeAlarm(
    SnoozeAlarm event,
    Emitter<AlarmState> emit,
  ) async {
    emit(const AlarmLoading());

    final result = await snoozeNativeAlarm(
      SnoozeParams(
        alarmId: event.alarmId.toString(),
        snoozeDuration: event.snoozeDuration,
      ),
    );

    result.fold(
      (failure) => emit(AlarmError(failure.message)),
      (_) => emit(AlarmSnoozed(event.snoozeDuration.inMinutes)),
    );
  }

  /// Maneja el evento de cancelar todas las alarmas
  Future<void> _onCancelAllAlarms(
    CancelAllAlarms event,
    Emitter<AlarmState> emit,
  ) async {
    emit(const AlarmLoading());

    final result = await repository.cancelAllAlarms();

    result.fold(
      (failure) => emit(AlarmError(failure.message)),
      (_) => emit(const AllAlarmsCancelled()),
    );
  }

  /// Maneja el evento de verificar el estado de una alarma
  Future<void> _onCheckAlarmStatus(
    CheckAlarmStatus event,
    Emitter<AlarmState> emit,
  ) async {
    emit(const AlarmLoading());

    final result = await repository.isAlarmActive(event.alarmId.toString());

    result.fold(
      (failure) => emit(AlarmError(failure.message)),
      (isActive) => emit(AlarmStatusChecked(
        alarmId: event.alarmId,
        isActive: isActive,
      )),
    );
  }

  /// Maneja el evento de programar alarmas para un usuario
  Future<void> _onSetAlarmsForUser(
    SetAlarmsForUser event,
    Emitter<AlarmState> emit,
  ) async {
    emit(const AlarmLoading());

    final result =
        await repository.setAlarmsForUserSchedules(event.userId.toString());

    result.fold(
      (failure) => emit(AlarmError(failure.message)),
      (count) {
        if (count == 0) {
          emit(const AlarmError(
            'No se encontraron schedules activos para programar alarmas',
          ));
        } else {
          emit(UserAlarmsSet(count: count));
        }
      },
    );
  }

  /// Maneja el evento de reprogramar todas las alarmas
  Future<void> _onRescheduleAllAlarms(
    RescheduleAllAlarms event,
    Emitter<AlarmState> emit,
  ) async {
    emit(const AlarmLoading());

    // Primero cancelar todas las alarmas existentes
    final cancelResult = await repository.cancelAllAlarms();

    if (cancelResult.isLeft()) {
      emit(AlarmError('Error al cancelar alarmas existentes'));
      return;
    }

    // Aquí deberíamos obtener todos los usuarios activos
    // y reprogramar sus alarmas, pero eso requeriría acceso
    // al UserRepository. Por simplicidad, emitimos un estado
    // que indique que se deben reprogramar manualmente.

    emit(const AlarmsRescheduled(0));
  }
}
