import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mta/core/error/failures.dart';
import 'package:mta/features/export/data/datasources/export_data_source.dart';
import 'package:mta/features/export/domain/entities/export_params_entity.dart';
import 'package:mta/features/export/domain/repositories/export_repository.dart';
import 'package:mta/features/measurements/domain/entities/measurement_entity.dart';

class ExportRepositoryImpl implements ExportRepository {
  final ExportDataSource dataSource;

  ExportRepositoryImpl({required this.dataSource});

  @override
  Future<Either<Failure, String>> exportMeasurements({
    required List<MeasurementEntity> measurements,
    required ExportParamsEntity params,
  }) async {
    try {
      debugPrint(
          '${DateFormat('HH:mm:ss').format(DateTime.now())} -📦 ExportRepository - Exporting ${measurements.length} measurements');

      // Filtrar mediciones por rango de fechas
      final filteredMeasurements = measurements.where((m) {
        return m.measurementTime.isAfter(
                params.startDate.subtract(const Duration(seconds: 1))) &&
            m.measurementTime
                .isBefore(params.endDate.add(const Duration(days: 1)));
      }).toList();

      debugPrint(
          '${DateFormat('HH:mm:ss').format(DateTime.now())} -📦 ExportRepository - Filtered to ${filteredMeasurements.length} measurements');

      if (filteredMeasurements.isEmpty) {
        return const Left(ValidationFailure(
            'No measurements found in the selected date range'));
      }

// 🎯 NUEVO: Ordenar por fecha/hora y luego por número de medición (Ascendente)
      filteredMeasurements.sort((a, b) {
        // 1. Comparar por measurementTime (fecha y hora)
        final timeComparison = a.measurementTime.compareTo(b.measurementTime);

        if (timeComparison != 0) {
          // Si las horas son diferentes, devuelve la comparación de tiempo
          return timeComparison;
        }

        // 2. Si las horas son iguales, compara por measurementNumber (Ascendente)
        return a.measurementNumber.compareTo(b.measurementNumber);
      });

      // Exportar según formato
      final String filePath;
      switch (params.format) {
        case ExportFormat.excel:
          filePath = await dataSource.exportToExcel(
            measurements: filteredMeasurements,
            fileName: params.fileName,
            username: params.username,
            translations: params.translations,
          );
          break;
        case ExportFormat.csv:
          filePath = await dataSource.exportToCSV(
            measurements: filteredMeasurements,
            fileName: params.fileName,
            username: params.username,
            translations: params.translations,
          );
          break;
        case ExportFormat.pdf:
          filePath = await dataSource.exportToPDF(
            measurements: filteredMeasurements,
            fileName: params.fileName,
            username: params.username,
            startDate: params.startDate,
            endDate: params.endDate,
            translations: params.translations,
            userAge: params.userAge,
            medicacion: params.medication,
            userBpMonitorModel: params.userBpMonitorModel,
            userMeasurementLocation: params.userMeasurementLocation,
          );
          break;
      }

      debugPrint(
          '${DateFormat('HH:mm:ss').format(DateTime.now())} -✅ ExportRepository - Export completed: $filePath');
      return Right(filePath);
    } on CacheFailure catch (e) {
      debugPrint(
          '${DateFormat('HH:mm:ss').format(DateTime.now())} -❌ ExportRepository - Error: ${e.message}');
      return Left(CacheFailure(e.message));
    } catch (e) {
      debugPrint(
          '${DateFormat('HH:mm:ss').format(DateTime.now())} -💥 ExportRepository - Unexpected error: $e');
      return Left(CacheFailure('Unexpected error: $e'));
    }
  }
}
