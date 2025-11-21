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
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        // Aquí irían las migraciones futuras
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
