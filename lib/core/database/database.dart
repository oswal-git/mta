import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'package:mta/core/database/daos/measurement_dao.dart';
import 'package:mta/core/database/daos/schedule_dao.dart';
import 'package:mta/core/database/daos/user_dao.dart';

part 'database.g.dart';

/// Main database class
@DriftDatabase(tables: [UsersDao, MeasurementsDao, SchedulesDao])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 6;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 2 && to >= 2) {
          // Añadir columnas para configuración de sonido de notificaciones
          try {
            await customStatement(
              'ALTER TABLE users ADD COLUMN notification_sound_enabled INTEGER NOT NULL DEFAULT 1',
            );
            await customStatement(
              'ALTER TABLE users ADD COLUMN notification_sound_uri TEXT',
            );
          } catch (_) {}
        }
        if (from < 3 && to >= 3) {
          // V2 -> V3: Añadir language_code
          try {
            await customStatement(
              "ALTER TABLE users ADD COLUMN language_code TEXT NOT NULL DEFAULT 'es'",
            );
          } catch (_) {}
        }
        if (from < 4 && to >= 4) {
          // V3 -> V4: Rename columns has_measuring -> take_medication and measuring_name -> medication_name
          // Check if table users_new exists or if we should skip
          try {
            // Recrear tabla si es necesario
            await customStatement('''
              CREATE TABLE users_new (
                id TEXT NOT NULL,
                name TEXT NOT NULL,
                age INTEGER,
                take_medication INTEGER NOT NULL DEFAULT 0,
                medication_name TEXT,
                enable_notifications INTEGER NOT NULL DEFAULT 1,
                notification_sound_enabled INTEGER NOT NULL DEFAULT 1,
                notification_sound_uri TEXT,
                language_code TEXT NOT NULL DEFAULT 'es',
                created_at INTEGER NOT NULL,
                updated_at INTEGER NOT NULL,
                PRIMARY KEY (id)
              )
            ''');

            await customStatement('''
              INSERT INTO users_new (
                id, name, age, take_medication, medication_name,
                enable_notifications, notification_sound_enabled, notification_sound_uri,
                language_code, created_at, updated_at
              )
              SELECT
                id, name, age, has_measuring, measuring_name,
                enable_notifications, notification_sound_enabled, notification_sound_uri,
                language_code, created_at, updated_at
              FROM users
            ''');

            await customStatement('DROP TABLE users');
            await customStatement('ALTER TABLE users_new RENAME TO users');
          } catch (_) {}
        }
        if (from < 5 && to >= 5) {
          // V4 -> V5: Add bp_monitor_model and measurement_location to users
          try {
            await customStatement(
              'ALTER TABLE users ADD COLUMN bp_monitor_model TEXT',
            );
            await customStatement(
              'ALTER TABLE users ADD COLUMN measurement_location TEXT',
            );
          } catch (_) {}
        }
        if (from < 6 && to >= 6) {
          // V5 -> V6: Add bp_monitor_model and measurement_location to measurements
          try {
            await customStatement(
              'ALTER TABLE measurements ADD COLUMN bp_monitor_model TEXT',
            );
            await customStatement(
              'ALTER TABLE measurements ADD COLUMN measurement_location TEXT',
            );
          } catch (_) {}
        }
      },
      beforeOpen: (details) async {
        // ✅ También las claves foráneas aquí
        await customStatement('PRAGMA foreign_keys = ON');

        if (details.wasCreated) {
          // Create indexes for better performance
          await customStatement(
            'CREATE INDEX IF NOT EXISTS idx_measurements_userId ON measurements(user_id)',
          );
          await customStatement(
            'CREATE INDEX IF NOT EXISTS idx_measurements_time ON measurements(measurement_time)',
          );
          await customStatement(
            'CREATE INDEX IF NOT EXISTS idx_schedules_userId ON schedules(user_id)',
          );
        }
      },
    );
  }
}

// Connection setup for web and mobile
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    // Mobile: usa SQLite nativo
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'mta.db'));
    return NativeDatabase(file);
  });
}
