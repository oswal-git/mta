import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:mta/core/error/failures.dart';
import 'package:mta/core/usecases/usecases.dart';
import 'package:mta/features/notifications/domain/repositories/notification_repository.dart';

/// Parámetros para posponer una notificacion
class SnoozeNotificationParams extends Equatable {
  final String notificationId;
  final Duration snoozeDuration;

  const SnoozeNotificationParams({
    required this.notificationId,
    this.snoozeDuration = const Duration(minutes: 5),
  });

  @override
  List<Object?> get props => [notificationId, snoozeDuration];
}

/// Caso de uso para posponer una notificacion nativa del sistema
class SnoozeNotificationUseCase
    implements UseCase<void, SnoozeNotificationParams> {
  final NotificationRepository repository;

  SnoozeNotificationUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(SnoozeNotificationParams params) async {
    // Validar ID
    if (params.notificationId.isEmpty) {
      return Left(ValidationFailure('ID de notificacion inválido'));
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

    return await repository.snoozeNotification(
      params.notificationId,
      params.snoozeDuration,
    );
  }
}
