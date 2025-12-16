import 'package:dartz/dartz.dart';
import 'package:mta/core/error/failures.dart';
import 'package:mta/core/usecases/usecases.dart';
import 'package:mta/features/alarms/domain/repositories/alarm_repository.dart';

/// Caso de uso para detener una alarma nativa del sistema
class StopNativeAlarm implements UseCase<void, String> {
  final AlarmRepository repository;

  StopNativeAlarm(this.repository);

  @override
  Future<Either<Failure, void>> call(String alarmId) async {
    // Validar ID
    if (alarmId.isEmpty) {
      return Left(ValidationFailure('ID de alarma inválido'));
    }

    return await repository.stopNativeAlarm(alarmId);
  }
}
