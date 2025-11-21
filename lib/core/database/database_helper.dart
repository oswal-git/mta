import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mta/core/database/database.dart';

/// Singleton instance helper
class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._();
  DatabaseHelper._();

  static AppDatabase? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  static AppDatabase get database {
    if (_database == null) {
      throw Exception('Database not initialized. Call init() first.');
    }
    return _database!;
  }

  /// Initialize database
  static Future<void> init() async {
    if (_database != null) return;

    try {
      _database = AppDatabase();

      // Inicialización más simple - sin consulta forzada
      // Execute a simple query to force initialization
      // await _database?.customSelect('SELECT 1').get();
      // La base de datos se inicializa automáticamente al primer uso
      debugPrint(
          '${DateFormat('HH:mm:ss').format(DateTime.now())} -✅ Database initialized successfully');
    } catch (e) {
      debugPrint(
          '${DateFormat('HH:mm:ss').format(DateTime.now())} -❌ Database initialization failed: $e');
      rethrow;
    }
  }

  /// Close database
  static Future<void> close() async {
    await _database?.close();
    _database = null;
  }
}
