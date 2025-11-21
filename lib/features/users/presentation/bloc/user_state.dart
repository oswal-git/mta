import 'package:equatable/equatable.dart';
import 'package:mta/features/users/domain/entities/user_entity.dart';

abstract class UserState extends Equatable {
  const UserState();

  @override
  List<Object?> get props => [];
}

class UserInitial extends UserState {}

class UserLoading extends UserState {}

class UsersLoaded extends UserState {
  final List<UserEntity> users;
  final UserEntity? activeUser;

  const UsersLoaded({required this.users, this.activeUser});

  @override
  List<Object?> get props => [users, activeUser];
}

class UserOperationSuccess extends UserState {
  final String message;

  const UserOperationSuccess(this.message);

  @override
  List<Object> get props => [message];
}

class UserError extends UserState {
  final String message;

  const UserError(this.message);

  @override
  List<Object> get props => [message];
}
