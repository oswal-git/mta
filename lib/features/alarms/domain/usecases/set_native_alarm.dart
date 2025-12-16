import 'package:dartz/dartz.dart';
import 'package:mta/core/error/failures.dart';
import 'package:mta/core/usecases/usecases.dart';
import 'package:mta/features/alarms/domain/entities/alarm_entity.dart';
import 'package:mta/features/alarms/domain/repositories/alarm_repository.dart';

/// Caso de uso para programar una alarma nativa del sistema
class SetNativeAlarm implements UseCase<void, AlarmEntity> {
  final AlarmRepository repository;

  SetNativeAlarm(this.repository);

  @override
  Future<Either<Failure, void>> call(AlarmEntity params) async {
    // Validar que la alarma tenga un tiempo futuro
    if (params.alarmTime.isBefore(DateTime.now())) {
      return Left(ValidationFailure(
        'La hora de la alarma debe ser en el futuro',
      ));
    }

    // Validar datos requeridos
    if (params.userName.isEmpty) {
      return Left(ValidationFailure('El nombre de usuario es requerido'));
    }

    if (params.title.isEmpty) {
      return Left(ValidationFailure('El título de la alarma es requerido'));
    }

    return await repository.setNativeAlarm(params);
  }
}
