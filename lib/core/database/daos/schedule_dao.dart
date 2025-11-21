import 'package:drift/drift.dart';
import 'package:mta/core/database/daos/user_dao.dart';

class SchedulesDao extends Table {
  TextColumn get id => text()();
  TextColumn get userId =>
      text().references(UsersDao, #id, onDelete: KeyAction.cascade)();
  IntColumn get hour => integer()();
  IntColumn get minute => integer()();
  BoolColumn get isEnabled => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  String get tableName => 'schedules';

  @override
  Set<Column> get primaryKey => {id};
}
