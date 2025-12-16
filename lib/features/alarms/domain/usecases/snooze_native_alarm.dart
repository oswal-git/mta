import 'package:dartz/dartz.dart';
import 'package:mta/core/error/failures.dart';
import 'package:mta/core/usecases/usecases.dart';
import 'package:mta/features/alarms/domain/repositories/alarm_repository.dart';

/// Parámetros para posponer una alarma
class SnoozeParams {
  final String alarmId;
  final Duration snoozeDuration;

  const SnoozeParams({
    required this.alarmId,
    this.snoozeDuration = const Duration(minutes: 5),
  });
}

/// Caso de uso para posponer una alarma nativa del sistema
class SnoozeNativeAlarm implements UseCase<void, SnoozeParams> {
  final AlarmRepository repository;

  SnoozeNativeAlarm(this.repository);

  @override
  Future<Either<Failure, void>> call(SnoozeParams params) async {
    // Validar ID
    if (params.alarmId.isEmpty) {
      return Left(ValidationFailure('ID de alarma inválido'));
    }

    // Validar duración del snooze
    if (params.snoozeDuration.inSeconds <= 0) {
      return Left(ValidationFailure('Duración de snooze inválida'));
    }

    // Limitar duración máxima a 1 hora
    if (params.snoozeDuration.inHours > 1) {
      return Left(ValidationFailure(
        'La duración máxima de snooze es 1 hora',
      ));
    }

    return await repository.snoozeNativeAlarm(
      params.alarmId,
      params.snoozeDuration,
    );
  }
}
