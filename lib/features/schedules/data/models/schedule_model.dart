import 'package:mta/core/database/database.dart';
import 'package:mta/features/schedules/domain/entities/schedule_entity.dart';

class ScheduleModel extends ScheduleEntity {
  const ScheduleModel({
    required super.id,
    required super.userId,
    required super.hour,
    required super.minute,
    super.isEnabled,
    required super.createdAt,
    required super.updatedAt,
  });

  factory ScheduleModel.fromDao(SchedulesDaoData schedule) {
    return ScheduleModel(
      id: schedule.id,
      userId: schedule.userId,
      hour: schedule.hour,
      minute: schedule.minute,
      isEnabled: schedule.isEnabled,
      createdAt: schedule.createdAt,
      updatedAt: schedule.updatedAt,
    );
  }

  SchedulesDaoData toDao() {
    return SchedulesDaoData(
      id: id,
      userId: userId,
      hour: hour,
      minute: minute,
      isEnabled: isEnabled,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  factory ScheduleModel.fromEntity(ScheduleEntity schedule) {
    return ScheduleModel(
      id: schedule.id,
      userId: schedule.userId,
      hour: schedule.hour,
      minute: schedule.minute,
      isEnabled: schedule.isEnabled,
      createdAt: schedule.createdAt,
      updatedAt: schedule.updatedAt,
    );
  }
}
