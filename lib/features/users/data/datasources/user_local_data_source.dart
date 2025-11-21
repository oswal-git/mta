import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mta/core/database/database.dart';
import 'package:mta/core/error/failures.dart';
import 'package:mta/core/utils/constants.dart';
import 'package:mta/features/users/data/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class UserLocalDataSource {
  Future<List<UserModel>> getUsers();
  Future<String?> getActiveUserId();
  Future<UserModel> createUser(UserModel user);
  Future<UserModel> updateUser(UserModel user);
  Future<void> deleteUser(String userId);
  Future<void> setActiveUserId(String userId);
}

class UserLocalDataSourceImpl implements UserLocalDataSource {
  final SharedPreferences sharedPreferences;
  final AppDatabase database;

  UserLocalDataSourceImpl({
    required this.sharedPreferences,
    required this.database,
  });

  @override
  Future<List<UserModel>> getUsers() async {
    try {
      final users = await database.select(database.usersDao).get();
      debugPrint(
          '📖 UserLocalDataSource - getUsers: ${users.length} users found');
      return users.map((user) => UserModel.fromDao(user)).toList();
    } catch (e) {
      debugPrint(
          '${DateFormat('HH:mm:ss').format(DateTime.now())} -❌ UserLocalDataSource - getUsers error: $e');
      throw CacheFailure('Failed to load users: ${e.toString()}');
    }
  }

  @override
  Future<String?> getActiveUserId() async {
    final id = sharedPreferences.getString(AppConstants.keyActiveUserId);
    debugPrint(
        '${DateFormat('HH:mm:ss').format(DateTime.now())} -📖 UserLocalDataSource - getActiveUserId: $id');
    return id;
  }

  @override
  Future<UserModel> createUser(UserModel user) async {
    try {
      debugPrint(
          '💾 UserLocalDataSource - createUser: ${user.name} (${user.id})');
      await database.into(database.usersDao).insert(
            UsersDaoCompanion(
              id: drift.Value(user.id),
              name: drift.Value(user.name),
              age: drift.Value(user.age),
              hasMedication: drift.Value(user.hasMedication),
              medicationName: drift.Value(user.medicationName),
              enableNotifications: drift.Value(user.enableNotifications),
              createdAt: drift.Value(user.createdAt),
              updatedAt: drift.Value(user.updatedAt),
            ),
          );
      debugPrint(
          '${DateFormat('HH:mm:ss').format(DateTime.now())} -✅ UserLocalDataSource - User created successfully');
      return user;
    } catch (e) {
      debugPrint(
          '${DateFormat('HH:mm:ss').format(DateTime.now())} -❌ UserLocalDataSource - createUser error: $e');
      throw CacheFailure('Failed to create user: ${e.toString()}');
    }
  }

  @override
  Future<UserModel> updateUser(UserModel user) async {
    try {
      debugPrint(
          '${DateFormat('HH:mm:ss').format(DateTime.now())} -💾 UserLocalDataSource - updateUser: ${user.name}');
      await database.update(database.usersDao).replace(user.toDao());
      debugPrint(
          '${DateFormat('HH:mm:ss').format(DateTime.now())} -✅ UserLocalDataSource - User updated successfully');
      return user;
    } catch (e) {
      debugPrint(
          '${DateFormat('HH:mm:ss').format(DateTime.now())} -❌ UserLocalDataSource - updateUser error: $e');
      throw CacheFailure('Failed to update user: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteUser(String userId) async {
    try {
      debugPrint(
          '${DateFormat('HH:mm:ss').format(DateTime.now())} -🗑️ UserLocalDataSource - deleteUser: $userId');
      await (database.delete(database.usersDao)
            ..where((tbl) => tbl.id.equals(userId)))
          .go();

      // If this was the active user, clear or set new active user
      final activeUserId = await getActiveUserId();
      if (activeUserId == userId) {
        final remainingUsers = await getUsers();
        if (remainingUsers.isNotEmpty) {
          await setActiveUserId(remainingUsers.first.id);
        } else {
          await sharedPreferences.remove(AppConstants.keyActiveUserId);
        }
      }
      debugPrint(
          '${DateFormat('HH:mm:ss').format(DateTime.now())} -✅ UserLocalDataSource - User deleted successfully');
    } catch (e) {
      debugPrint(
          '${DateFormat('HH:mm:ss').format(DateTime.now())} -❌ UserLocalDataSource - deleteUser error: $e');
      throw CacheFailure('Failed to delete user: ${e.toString()}');
    }
  }

  @override
  Future<void> setActiveUserId(String userId) async {
    debugPrint(
        '${DateFormat('HH:mm:ss').format(DateTime.now())} -💾 UserLocalDataSource - setActiveUserId: $userId');
    await sharedPreferences.setString(AppConstants.keyActiveUserId, userId);
    final saved = sharedPreferences.getString(AppConstants.keyActiveUserId);
    debugPrint(
        '${DateFormat('HH:mm:ss').format(DateTime.now())} -✅ UserLocalDataSource - Active user saved: $saved');
  }
}
