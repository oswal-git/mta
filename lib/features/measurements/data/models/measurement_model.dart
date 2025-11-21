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
      createdAt: measurement.createdAt,
      updatedAt: measurement.updatedAt,
    );
  }
}
