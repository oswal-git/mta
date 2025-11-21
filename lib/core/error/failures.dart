import 'package:equatable/equatable.dart';

/// Base class for all failures in the application
abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

/// Failure when there's an error with the cache/local storage
class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Cache Failure']);
}

/// Failure when there's an error with server communication
class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Server Failure']);
}

/// Failure when there's a validation error
class ValidationFailure extends Failure {
  const ValidationFailure([super.message = 'Validation Failure']);
}

/// Failure when the user is not authenticated
class AuthenticationFailure extends Failure {
  const AuthenticationFailure([super.message = 'Authentication Failure']);
}

/// Failure when the user doesn't have permission
class PermissionFailure extends Failure {
  const PermissionFailure([super.message = 'Permission Failure']);
}

/// Failure when a resource is not found
class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'Resource Not Found']);
}
