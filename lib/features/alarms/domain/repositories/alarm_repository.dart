import 'package:dartz/dartz.dart';
import 'package:mta/core/error/failures.dart';
import 'package:mta/features/alarms/domain/entities/alarm_entity.dart';

/// Contrato del repositorio de alarmas nativas
abstract class AlarmRepository {
  /// Programa una alarma nativa del sistema
  ///
  /// [alarm] - Entidad con todos los datos de la alarma
  ///
  /// Retorna [Right(void)] si se programó correctamente
  /// Retorna [Left(Failure)] si hubo algún error
  Future<Either<Failure, void>> setNativeAlarm(AlarmEntity alarm);

  /// Detiene una alarma nativa específica
  ///
  /// [alarmId] - ID de la alarma a detener
  ///
  /// Retorna [Right(void)] si se detuvo correctamente
  /// Retorna [Left(Failure)] si hubo algún error
  Future<Either<Failure, void>> stopNativeAlarm(String alarmId);

  /// Pospone una alarma por una duración específica
  ///
  /// [alarmId] - ID de la alarma a posponer
  /// [snoozeDuration] - Duración del snooze (por defecto 5 minutos)
  ///
  /// Retorna [Right(void)] si se pospuso correctamente
  /// Retorna [Left(Failure)] si hubo algún error
  Future<Either<Failure, void>> snoozeNativeAlarm(
    String alarmId,
    Duration snoozeDuration,
  );

  /// Cancela todas las alarmas programadas
  ///
  /// Retorna [Right(void)] si se cancelaron correctamente
  /// Retorna [Left(Failure)] si hubo algún error
  Future<Either<Failure, void>> cancelAllAlarms();

  /// Verifica si una alarma específica está activa
  ///
  /// [alarmId] - ID de la alarma a verificar
  ///
  /// Retorna [Right(bool)] con el estado de la alarma
  /// Retorna [Left(Failure)] si hubo algún error
  Future<Either<Failure, bool>> isAlarmActive(String alarmId);

  /// Programa alarmas para todos los schedules activos de un usuario
  ///
  /// [userId] - ID del usuario
  ///
  /// Retorna [Right(int)] con el número de alarmas programadas
  /// Retorna [Left(Failure)] si hubo algún error
  Future<Either<Failure, int>> setAlarmsForUserSchedules(String userId);
}
