import 'package:dartz/dartz.dart';
import 'package:mta/core/error/failures.dart';
import 'package:mta/core/usecases/usecases.dart';
import 'package:mta/features/notifications/domain/repositories/notification_repository.dart';

class CancelNotificationUseCase implements UseCase<void, String> {
  final NotificationRepository repository;

  CancelNotificationUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(String notificationId) async {
    if (notificationId.isEmpty) {
      return Left(ValidationFailure('ID de notificación inválido'));
    }

    return await repository.cancelNotification(notificationId);
  }
}
