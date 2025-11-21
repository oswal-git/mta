import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mta/core/error/failures.dart';
import 'package:mta/features/users/data/datasources/user_local_data_source.dart';
import 'package:mta/features/users/data/models/user_model.dart';
import 'package:mta/features/users/domain/entities/user_entity.dart';
import 'package:mta/features/users/domain/repositories/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  final UserLocalDataSource localDataSource;

  UserRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, List<UserEntity>>> getUsers() async {
    try {
      debugPrint(
          '${DateFormat('HH:mm:ss').format(DateTime.now())} -🔍 UserRepository - Getting users...');
      final users = await localDataSource.getUsers();
      debugPrint(
          '${DateFormat('HH:mm:ss').format(DateTime.now())} -✅ UserRepository - Got ${users.length} users');
      return Right(users);
    } on CacheFailure catch (e) {
      debugPrint(
          '${DateFormat('HH:mm:ss').format(DateTime.now())} -❌ UserRepository - getUsers error: ${e.message}');
      return Left(CacheFailure(e.message));
    } catch (e) {
      debugPrint(
          '${DateFormat('HH:mm:ss').format(DateTime.now())} -💥 UserRepository - getUsers exception: $e');
      return Left(CacheFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, UserEntity?>> getActiveUser() async {
    try {
      debugPrint(
          '${DateFormat('HH:mm:ss').format(DateTime.now())} -🔍 UserRepository - Getting active user...');
      final activeUserId = await localDataSource.getActiveUserId();
      debugPrint(
          '${DateFormat('HH:mm:ss').format(DateTime.now())} -🔍 Repository - Active user ID: $activeUserId');

      if (activeUserId == null) {
        debugPrint(
            '${DateFormat('HH:mm:ss').format(DateTime.now())} -⚠️ Repository - No active user ID found');
        // Si no hay usuario activo pero hay usuarios, establecer el primero como activo
        final users = await localDataSource.getUsers();
        if (users.isNotEmpty) {
          debugPrint(
              '📌 Repository - Setting first user as active: ${users.first.id}');
          await localDataSource.setActiveUserId(users.first.id);
          return Right(users.first);
        }
        debugPrint(
            '${DateFormat('HH:mm:ss').format(DateTime.now())} -⚠️ Repository - No users found');
        return const Right(null);
      }

      final users = await localDataSource.getUsers();
      try {
        final activeUser = users.firstWhere((user) => user.id == activeUserId);
        debugPrint(
            '${DateFormat('HH:mm:ss').format(DateTime.now())} -✅ Repository - Found active user: ${activeUser.name}');
        return Right(activeUser);
      } catch (e) {
        debugPrint(
            '${DateFormat('HH:mm:ss').format(DateTime.now())} -⚠️ Repository - Active user not found in list, resetting');
        // Si el usuario activo no existe, establecer el primero como activo
        if (users.isNotEmpty) {
          await localDataSource.setActiveUserId(users.first.id);
          return Right(users.first);
        }
        return const Right(null);
      }
    } on CacheFailure catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> createUser(UserEntity user) async {
    try {
      debugPrint(
          '${DateFormat('HH:mm:ss').format(DateTime.now())} -📝 Repository - Creating user: ${user.name}');
      final userModel = UserModel.fromEntity(user);

      final createdUser = await localDataSource.createUser(userModel);
      debugPrint(
          '${DateFormat('HH:mm:ss').format(DateTime.now())} -✅ Repository - User created: ${createdUser.id}');

      // Primero verificar cuántos usuarios hay ANTES de crear
      final existingUsers = await localDataSource.getUsers();
      final isFirstUser = existingUsers.length == 1;
      debugPrint(
          '${DateFormat('HH:mm:ss').format(DateTime.now())} -📊 Repository - Existing users: ${existingUsers.length}');
      debugPrint(
          '${DateFormat('HH:mm:ss').format(DateTime.now())} -📊 Repository - Is FirstUser: ${isFirstUser ? 'yes' : 'no'}');

      // Si es el primer usuario, SIEMPRE establecerlo como activo
      if (isFirstUser) {
        debugPrint(
            '${DateFormat('HH:mm:ss').format(DateTime.now())} -🎯 Repository - First user, setting as active');
        await localDataSource.setActiveUserId(createdUser.id);
        debugPrint(
            '${DateFormat('HH:mm:ss').format(DateTime.now())} -✅ Repository - User set as active');
      } else {
        // Si no es el primero, verificar si hay usuario activo
        final activeUserId = await localDataSource.getActiveUserId();
        if (activeUserId == null) {
          debugPrint(
              '🎯 Repository - No active user, setting new user as active');
          await localDataSource.setActiveUserId(createdUser.id);
          debugPrint(
              '${DateFormat('HH:mm:ss').format(DateTime.now())} -✅ Repository - User set as active');
        } else {
          debugPrint(
              'ℹ️ Repository - Active user already exists: $activeUserId');
        }
      } // Si es el primer usuario, SIEMPRE establecerlo como activo

      return Right(createdUser);
    } on CacheFailure catch (e) {
      debugPrint(
          '${DateFormat('HH:mm:ss').format(DateTime.now())} -❌ Repository - Create user failed: ${e.message}');
      return Left(CacheFailure(e.message));
    } catch (e) {
      debugPrint(
          '${DateFormat('HH:mm:ss').format(DateTime.now())} -❌ Repository - Unexpected error: $e');
      return Left(CacheFailure('Failed to create user: $e'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> updateUser(UserEntity user) async {
    try {
      final userModel = UserModel.fromEntity(user);
      final updatedUser = await localDataSource.updateUser(userModel);
      return Right(updatedUser);
    } on CacheFailure catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> deleteUser(String userId) async {
    try {
      await localDataSource.deleteUser(userId);
      return const Right(null);
    } on CacheFailure catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> setActiveUser(String userId) async {
    try {
      await localDataSource.setActiveUserId(userId);
      return const Right(null);
    } on CacheFailure catch (e) {
      return Left(CacheFailure(e.message));
    }
  }
}
