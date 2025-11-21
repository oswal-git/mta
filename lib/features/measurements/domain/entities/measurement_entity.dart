import 'package:equatable/equatable.dart';

/// Measurement entity representing a blood pressure measurement
class MeasurementEntity extends Equatable {
  final String id;
  final String userId;
  final DateTime measurementTime;
  final int measurementNumber;
  final int systolic;
  final int diastolic;
  final int? pulse;
  final String? note;
  final DateTime createdAt;
  final DateTime updatedAt;

  const MeasurementEntity({
    required this.id,
    required this.userId,
    required this.measurementTime,
    required this.measurementNumber,
    required this.systolic,
    required this.diastolic,
    this.pulse,
    this.note,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Creates a copy of this measurement with the given fields replaced
  MeasurementEntity copyWith({
    String? id,
    String? userId,
    DateTime? measurementTime,
    int? measurementNumber,
    int? systolic,
    int? diastolic,
    int? pulse,
    String? note,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MeasurementEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      measurementTime: measurementTime ?? this.measurementTime,
      measurementNumber: measurementNumber ?? this.measurementNumber,
      systolic: systolic ?? this.systolic,
      diastolic: diastolic ?? this.diastolic,
      pulse: pulse ?? this.pulse,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        measurementTime,
        measurementNumber,
        systolic,
        diastolic,
        pulse,
        note,
        createdAt,
        updatedAt,
      ];
}
