import 'package:dartz/dartz.dart';
import 'package:mta/core/error/failures.dart';
import 'package:mta/core/usecases/usecases.dart';
import 'package:mta/features/notifications/domain/entities/notification_entity.dart';
import 'package:mta/features/notifications/domain/repositories/notification_repository.dart';

class ScheduleNotificationUseCase implements UseCase<void, NotificationEntity> {
  final NotificationRepository repository;

  ScheduleNotificationUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(NotificationEntity params) async {
    // Validaciones
    if (params.userName.isEmpty) {
      return Left(ValidationFailure('El nombre de usuario es requerido'));
    }

    if (params.title.isEmpty) {
      return Left(
          ValidationFailure('El título de la notificación es requerido'));
    }

    return await repository.scheduleNotification(params);
  }
}
