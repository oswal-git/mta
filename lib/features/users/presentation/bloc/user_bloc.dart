import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:mta/core/usecases/usecases.dart';
import 'package:mta/features/users/domain/usecases/create_user.dart';
import 'package:mta/features/users/domain/usecases/delete_user.dart';
import 'package:mta/features/users/domain/usecases/get_active_user.dart';
import 'package:mta/features/users/domain/usecases/get_users.dart';
import 'package:mta/features/users/domain/usecases/set_active_user.dart';
import 'package:mta/features/users/domain/usecases/update_user.dart';
import 'package:mta/features/users/presentation/bloc/user_event.dart';
import 'package:mta/features/users/presentation/bloc/user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final GetUsers getUsers;
  final GetActiveUser getActiveUser;
  final CreateUser createUser;
  final UpdateUser updateUser;
  final DeleteUser deleteUser;
  final SetActiveUser setActiveUser;

  UserBloc({
    required this.getUsers,
    required this.getActiveUser,
    required this.createUser,
    required this.updateUser,
    required this.deleteUser,
    required this.setActiveUser,
  }) : super(UserInitial()) {
    on<LoadUsersEvent>(_onLoadUsers);
    on<LoadActiveUserEvent>(_onLoadActiveUser);
    on<CreateUserEvent>(_onCreateUser);
    on<UpdateUserEvent>(_onUpdateUser);
    on<DeleteUserEvent>(_onDeleteUser);
    on<SetActiveUserEvent>(_onSetActiveUser);
  }

  Future<void> _onLoadUsers(
    LoadUsersEvent event,
    Emitter<UserState> emit,
  ) async {
    debugPrint(
        '${DateFormat('HH:mm:ss').format(DateTime.now())} -🔄 UserBloc - Loading users...');
    emit(UserLoading());

    try {
      final usersResult = await getUsers(NoParams());
      debugPrint(
          '${DateFormat('HH:mm:ss').format(DateTime.now())} -📦 UserBloc - Got users result');

      await usersResult.fold(
        (failure) async {
          debugPrint(
              '${DateFormat('HH:mm:ss').format(DateTime.now())} -❌ UserBloc - Failed to load users: ${failure.message}');
          emit(UserError(failure.message));
        },
        (users) async {
          debugPrint(
              '${DateFormat('HH:mm:ss').format(DateTime.now())} -✅ UserBloc - Loaded ${users.length} users');

          final activeUserResult = await getActiveUser(NoParams());
          debugPrint(
              '${DateFormat('HH:mm:ss').format(DateTime.now())} -📦 UserBloc - Got active user result');

          activeUserResult.fold(
            (failure) {
              debugPrint(
                  '${DateFormat('HH:mm:ss').format(DateTime.now())} -⚠️ UserBloc - No active user found');
              emit(UsersLoaded(users: users));
            },
            (activeUser) {
              if (activeUser == null) {
                debugPrint(
                    '${DateFormat('HH:mm:ss').format(DateTime.now())} -⚠️ UserBloc - Active user is null');
                emit(UsersLoaded(users: users));
              } else {
                debugPrint(
                    '✅ UserBloc - Active user: ${activeUser.name} (${activeUser.id})');
                emit(UsersLoaded(users: users, activeUser: activeUser));
              }
            },
          );
        },
      );
    } catch (e) {
      debugPrint(
          '${DateFormat('HH:mm:ss').format(DateTime.now())} -💥 UserBloc - Exception: $e');
      emit(UserError('Failed to load users: $e'));
    }
  }

  Future<void> _onLoadActiveUser(
    LoadActiveUserEvent event,
    Emitter<UserState> emit,
  ) async {
    final result = await getActiveUser(NoParams());

    result.fold(
      (failure) => emit(UserError(failure.message)),
      (activeUser) {
        // Also load all users
        add(LoadUsersEvent());
      },
    );
  }

  Future<void> _onCreateUser(
    CreateUserEvent event,
    Emitter<UserState> emit,
  ) async {
    emit(UserLoading());

    final result = await createUser(CreateUserParams(user: event.user));

    result.fold(
      (failure) => emit(UserError(failure.message)),
      (user) {
        debugPrint(
            '${DateFormat('HH:mm:ss').format(DateTime.now())} -✅ User created: ${user.name} (${user.id})');

        // El repository ya establece el usuario como activo
        emit(const UserOperationSuccess('User created successfully'));
        add(LoadUsersEvent());
      },
    );
  }

  Future<void> _onUpdateUser(
    UpdateUserEvent event,
    Emitter<UserState> emit,
  ) async {
    emit(UserLoading());

    final result = await updateUser(UpdateUserParams(user: event.user));

    result.fold(
      (failure) => emit(UserError(failure.message)),
      (_) {
        emit(const UserOperationSuccess('User updated successfully'));
        add(LoadUsersEvent());
      },
    );
  }

  Future<void> _onDeleteUser(
    DeleteUserEvent event,
    Emitter<UserState> emit,
  ) async {
    emit(UserLoading());

    final result = await deleteUser(DeleteUserParams(userId: event.userId));

    result.fold(
      (failure) => emit(UserError(failure.message)),
      (_) {
        emit(const UserOperationSuccess('User deleted successfully'));
        add(LoadUsersEvent());
      },
    );
  }

  Future<void> _onSetActiveUser(
    SetActiveUserEvent event,
    Emitter<UserState> emit,
  ) async {
    final result =
        await setActiveUser(SetActiveUserParams(userId: event.userId));

    result.fold(
      (failure) => emit(UserError(failure.message)),
      (_) {
        add(LoadUsersEvent());
      },
    );
  }
}
