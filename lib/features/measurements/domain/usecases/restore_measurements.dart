import 'dart:io';
import 'package:flutter/foundation.dart';

import 'package:csv/csv.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:mta/core/error/failures.dart';
import 'package:mta/core/usecases/usecases.dart';
import 'package:mta/features/measurements/domain/entities/measurement_entity.dart';
import 'package:mta/features/measurements/data/models/measurement_model.dart';
import 'package:mta/features/measurements/domain/repositories/measurement_repository.dart';

class RestoreMeasurements implements UseCase<int, RestoreParams> {
  final MeasurementRepository repository;

  RestoreMeasurements(this.repository);

  @override
  Future<Either<Failure, int>> call(RestoreParams params) async {
    try {
      final file = File(params.filePath);
      if (!await file.exists()) {
        return const Left(NotFoundFailure('Archivo de respaldo no encontrado'));
      }

      final csvString = await file.readAsString();
      const converter = CsvToListConverter();
      final rows = converter.convert(csvString);

      if (rows.isEmpty) {
        return const Left(CacheFailure('Archivo CSV vacío'));
      }

      // Eliminar cabecera
      final header = rows.removeAt(0);
      final idIndex = header.indexOf('id');
      final userIdIndex = header.indexOf('userId');
      final timeIndex = header.indexOf('measurementTime');
      final numIndex = header.indexOf('measurementNumber');
      final systIndex = header.indexOf('systolic');
      final diastIndex = header.indexOf('diastolic');
      final pulseIndex = header.indexOf('pulse');
      final noteIndex = header.indexOf('note');
      final modelIndex = header.indexOf('bpMonitorModel');
      final locIndex = header.indexOf('measurementLocation');
      final createdIndex = header.indexOf('createdAt');
      final updatedIndex = header.indexOf('updatedAt');

      final List<MeasurementEntity> measurements = [];

      for (final row in rows) {
        if (row.length < header.length) continue;

        // Build a standard row list based on discovered indices
        final standardRow = [
          idIndex >= 0 ? row[idIndex] : '', // id
          userIdIndex >= 0 ? row[userIdIndex] : '', // userId (will be ignored by factory)
          timeIndex >= 0 ? row[timeIndex] : '', // measurementTime
          numIndex >= 0 ? row[numIndex] : 0, // measurementNumber
          systIndex >= 0 ? row[systIndex] : 0, // systolic
          diastIndex >= 0 ? row[diastIndex] : 0, // diastolic
          pulseIndex >= 0 ? row[pulseIndex] : '', // pulse
          noteIndex >= 0 ? row[noteIndex] : '', // note
          modelIndex >= 0 ? row[modelIndex] : '', // bpMonitorModel
          locIndex >= 0 ? row[locIndex] : '', // measurementLocation
          createdIndex >= 0 ? row[createdIndex] : '', // createdAt
          updatedIndex >= 0 ? row[updatedIndex] : '', // updatedAt
        ];

        try {
          measurements.add(MeasurementModel.fromCsvRow(standardRow, params.userId));
        } catch (e) {
          debugPrint('Error parsing row: $e');
        }
      }

      if (measurements.isEmpty) {
        return const Right(0);
      }

      final result = await repository.restoreMeasurements(measurements);

      return result.fold(
        (failure) => Left(failure),
        (_) => Right(measurements.length),
      );
    } catch (e) {
      return Left(CacheFailure('Parse error: $e'));
    }
  }
}

class RestoreParams extends Equatable {
  final String filePath;
  final String userId;

  const RestoreParams({required this.filePath, required this.userId});

  @override
  List<Object?> get props => [filePath, userId];
}
