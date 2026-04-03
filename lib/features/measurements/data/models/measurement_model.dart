import 'package:mta/core/database/database.dart';
import 'package:mta/features/measurements/domain/entities/measurement_entity.dart';

/// Model class for Measurement that extends the domain entity
class MeasurementModel extends MeasurementEntity {
  const MeasurementModel({
    required super.id,
    required super.userId,
    required super.measurementTime,
    required super.measurementNumber,
    required super.systolic,
    required super.diastolic,
    super.pulse,
    super.note,
    super.bpMonitorModel,
    super.measurementLocation,
    required super.createdAt,
    required super.updatedAt,
  });

  /// Creates a MeasurementModel from Drift
  factory MeasurementModel.fromDao(MeasurementsDaoData measurement) {
    return MeasurementModel(
      id: measurement.id,
      userId: measurement.userId,
      measurementTime: measurement.measurementTime,
      measurementNumber: measurement.measurementNumber,
      systolic: measurement.systolic,
      diastolic: measurement.diastolic,
      pulse: measurement.pulse,
      note: measurement.note,
      bpMonitorModel: measurement.bpMonitorModel,
      measurementLocation: measurement.measurementLocation,
      createdAt: measurement.createdAt,
      updatedAt: measurement.updatedAt,
    );
  }

  /// Converts this model to Drift
  MeasurementsDaoData toDao() {
    return MeasurementsDaoData(
      id: id,
      userId: userId,
      measurementTime: measurementTime,
      measurementNumber: measurementNumber,
      systolic: systolic,
      diastolic: diastolic,
      pulse: pulse,
      note: note,
      bpMonitorModel: bpMonitorModel,
      measurementLocation: measurementLocation,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Creates a MeasurementModel from a Measurement entity
  factory MeasurementModel.fromEntity(MeasurementEntity measurement) {
    return MeasurementModel(
      id: measurement.id,
      userId: measurement.userId,
      measurementTime: measurement.measurementTime,
      measurementNumber: measurement.measurementNumber,
      systolic: measurement.systolic,
      diastolic: measurement.diastolic,
      pulse: measurement.pulse,
      note: measurement.note,
      bpMonitorModel: measurement.bpMonitorModel,
      measurementLocation: measurement.measurementLocation,
      createdAt: measurement.createdAt,
      updatedAt: measurement.updatedAt,
    );
  }

  /// Converts this model to a CSV row
  List<dynamic> toCsvRow() {
    return [
      id,
      userId,
      measurementTime.toIso8601String(),
      measurementNumber,
      systolic,
      diastolic,
      pulse ?? '',
      note ?? '',
      bpMonitorModel ?? '',
      measurementLocation ?? '',
      createdAt.toIso8601String(),
      updatedAt.toIso8601String(),
    ];
  }

  /// Creates a MeasurementModel from a CSV row
  factory MeasurementModel.fromCsvRow(List<dynamic> row, String targetUserId) {
    return MeasurementModel(
      id: row[0].toString(),
      userId: targetUserId, // Use the provided userId to ensure it belongs to the active user
      measurementTime: DateTime.parse(row[2].toString()),
      measurementNumber: int.parse(row[3].toString()),
      systolic: int.parse(row[4].toString()),
      diastolic: int.parse(row[5].toString()),
      pulse: row[6].toString().isEmpty ? null : int.parse(row[6].toString()),
      note: row[7].toString().isEmpty ? null : row[7].toString(),
      bpMonitorModel: row[8].toString().isEmpty ? null : row[8].toString(),
      measurementLocation:
          row[9].toString().isEmpty ? null : row[9].toString(),
      createdAt: DateTime.parse(row[10].toString()),
      updatedAt: DateTime.parse(row[11].toString()),
    );
  }
}
