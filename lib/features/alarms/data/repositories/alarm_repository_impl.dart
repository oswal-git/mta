import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:mta/core/error/failures.dart';
import 'package:mta/features/alarms/data/datasources/alarm_native_data_source.dart';
import 'package:mta/features/alarms/domain/entities/alarm_entity.dart';
import 'package:mta/features/alarms/domain/repositories/alarm_repository.dart';
import 'package:mta/features/schedules/domain/repositories/schedule_repository.dart';
import 'package:mta/features/users/domain/repositories/user_repository.dart';

/// Implementación del repositorio de alarmas
class AlarmRepositoryImpl implements AlarmRepository {
  final AlarmNativeDataSource dataSource;
  final UserRepository userRepository;
  final ScheduleRepository scheduleRepository;

  AlarmRepositoryImpl({
    required this.dataSource,
    required this.userRepository,
    required this.scheduleRepository,
  });

  @override
  Future<Either<Failure, void>> setNativeAlarm(AlarmEntity alarm) async {
    try {
      await dataSource.setAlarm(alarm);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Error al programar alarma: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> stopNativeAlarm(String alarmId) async {
    try {
      await dataSource.cancelAlarm(alarmId);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Error al detener alarma: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> snoozeNativeAlarm(
    String alarmId,
    Duration snoozeDuration,
  ) async {
    try {
      await dataSource.snoozeAlarm(alarmId, snoozeDuration);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Error al posponer alarma: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> cancelAllAlarms() async {
    try {
      await dataSource.cancelAllAlarms();
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(
        'Error al cancelar todas las alarmas: ${e.toString()}',
      ));
    }
  }

  @override
  Future<Either<Failure, bool>> isAlarmActive(String alarmId) async {
    try {
      final isActive = await dataSource.isAlarmActive(alarmId);
      return Right(isActive);
    } catch (e) {
      return Left(CacheFailure(
        'Error al verificar alarma: ${e.toString()}',
      ));
    }
  }

  @override
  Future<Either<Failure, int>> setAlarmsForUserSchedules(String userId) async {
    try {
      // Obtener el usuario
      final userResult = await userRepository.getUsers();
      if (userResult.isLeft()) {
        return Left(CacheFailure('Error al obtener usuario'));
      }

      final users = userResult.getOrElse(() => []);
      final user = users.firstWhere(
        (u) => u.id == userId,
        orElse: () => throw Exception('Usuario no encontrado'),
      );

      // Obtener los schedules activos del usuario
      final schedulesResult = await scheduleRepository.getSchedules(userId);
      if (schedulesResult.isLeft()) {
        return Left(CacheFailure('Error al obtener schedules'));
      }

      final schedules = schedulesResult
          .getOrElse(() => [])
          .where((s) => s.isEnabled)
          .toList();

      int alarmsSet = 0;

      // Programar una alarma para cada schedule
      for (final schedule in schedules) {
        // Calcular las próximas ocurrencias del schedule
        final nextAlarms = _calculateNextAlarms(schedule);

        for (final alarmTime in nextAlarms) {
          // Create a unique ID string without parsing
          final uniqueAlarmId = '${schedule.id}_$alarmsSet';

          final alarm = AlarmEntity(
            id: uniqueAlarmId, // ID único combinando schedule y contador
            scheduleId: schedule.id,
            userId: user.id,
            userName: user.name,
            alarmTime: alarmTime,
            title: 'Recordatorio de medicación',
            body: 'Es hora de tomar tu medicación',
            label: schedule.formattedTime,
            medication: user.medicationName,
            isActive: true,
          );

          final result = await setNativeAlarm(alarm);
          if (result.isRight()) {
            alarmsSet++;
          }
        }
      }

      return Right(alarmsSet);
    } catch (e) {
      return Left(CacheFailure(
        'Error al programar alarmas para usuario: ${e.toString()}',
      ));
    }
  }

  /// Calcula las próximas ocurrencias de un schedule
  /// Retorna hasta 7 alarmas (una por cada día de la semana siguiente)
  List<DateTime> _calculateNextAlarms(dynamic schedule) {
    final List<DateTime> alarms = [];
    final now = DateTime.now();

    // Usar hour y minute directamente del schedule
    final scheduleHour = schedule.hour as int;
    final scheduleMinute = schedule.minute as int;

    // Calcular las próximas 7 ocurrencias
    for (int i = 0; i < 7; i++) {
      final date = now.add(Duration(days: i));

      final alarmDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        scheduleHour,
        scheduleMinute,
      );

      // Solo agregar si es en el futuro
      if (alarmDateTime.isAfter(now)) {
        alarms.add(alarmDateTime);
      }
    }
    return alarms;
  }

  /// ✅ Cancela notificaciones que correspondan a un horario específico
  Future<Either<Failure, void>> cancelAlarmsForTime(
      int hour, int minute) async {
    try {
      // ✅ Obtener las alarmas activas a través del dataSource
      final activeAlarms = await dataSource.getActiveAlarms();

      // Filtrar alarmas que correspondan a este horario (±15 minutos)
      final alarmsToCancel = activeAlarms.where((alarm) {
        final alarmHour = alarm.alarmTime.hour;
        final alarmMinute = alarm.alarmTime.minute;

        // Calcular diferencia en minutos
        final targetMinutes = hour * 60 + minute;
        final alarmMinutes = alarmHour * 60 + alarmMinute;
        final difference = (targetMinutes - alarmMinutes).abs();

        // Cancelar si está dentro de 15 minutos
        return difference <= 15;
      }).toList();

      debugPrint(
          '🔍 Encontradas ${alarmsToCancel.length} notificaciones para cancelar');

      // Cancelar cada alarma
      for (final alarm in alarmsToCancel) {
        await dataSource.cancelAlarm(alarm.id);
        debugPrint('✓ Notificación cancelada: ${alarm.id}');
      }

      return const Right(null);
    } catch (e) {
      return Left(
          CacheFailure('Error al cancelar notificaciones: ${e.toString()}'));
    }
  }
}
