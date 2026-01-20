import 'package:drift/drift.dart';

class UsersDao extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  IntColumn get age => integer().nullable()();
  BoolColumn get takeMedication =>
      boolean().withDefault(const Constant(false))();
  TextColumn get medicationName => text().nullable()();
  BoolColumn get enableNotifications =>
      boolean().withDefault(const Constant(true))();
  BoolColumn get notificationSoundEnabled =>
      boolean().withDefault(const Constant(true))();
  TextColumn get notificationSoundUri => text().nullable()();
  TextColumn get languageCode => text().withDefault(const Constant('es'))();
  TextColumn get bpMonitorModel => text().nullable()();
  TextColumn get measurementLocation => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  String get tableName => 'users';

  @override
  Set<Column> get primaryKey => {id};
}
