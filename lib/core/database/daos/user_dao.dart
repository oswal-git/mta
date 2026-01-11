import 'package:drift/drift.dart';

class UsersDao extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  IntColumn get age => integer().nullable()();
  BoolColumn get hasMeasuring =>
      boolean().withDefault(const Constant(false))();
  TextColumn get measuringName => text().nullable()();
  BoolColumn get enableNotifications =>
      boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  String get tableName => 'users';

  @override
  Set<Column> get primaryKey => {id};
}
