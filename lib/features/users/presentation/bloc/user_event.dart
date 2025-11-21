import 'package:equatable/equatable.dart';
import 'package:mta/features/users/domain/entities/user_entity.dart';

abstract class UserEvent extends Equatable {
  const UserEvent();

  @override
  List<Object?> get props => [];
}

class LoadUsersEvent extends UserEvent {}

class LoadActiveUserEvent extends UserEvent {}

class CreateUserEvent extends UserEvent {
  final UserEntity user;

  const CreateUserEvent(this.user);

  @override
  List<Object> get props => [user];
}

class UpdateUserEvent extends UserEvent {
  final UserEntity user;

  const UpdateUserEvent(this.user);

  @override
  List<Object> get props => [user];
}

class DeleteUserEvent extends UserEvent {
  final String userId;

  const DeleteUserEvent(this.userId);

  @override
  List<Object> get props => [userId];
}

class SetActiveUserEvent extends UserEvent {
  final String userId;

  const SetActiveUserEvent(this.userId);

  @override
  List<Object> get props => [userId];
}
