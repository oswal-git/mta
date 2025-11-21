import 'package:drift/drift.dart';
import 'package:mta/core/database/daos/user_dao.dart';

class MeasurementsDao extends Table {
  TextColumn get id => text()();
  TextColumn get userId =>
      text().references(UsersDao, #id, onDelete: KeyAction.cascade)();
  DateTimeColumn get measurementTime => dateTime()();
  IntColumn get measurementNumber => integer()();
  IntColumn get systolic => integer()();
  IntColumn get diastolic => integer()();
  IntColumn get pulse => integer().nullable()();
  TextColumn get note => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  String get tableName => 'measurements';

  @override
  Set<Column> get primaryKey => {id};
}
