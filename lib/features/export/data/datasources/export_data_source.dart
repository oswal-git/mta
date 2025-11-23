import 'dart:io';

import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mta/core/error/failures.dart';
import 'package:mta/features/measurements/domain/entities/measurement_entity.dart';
import 'package:path_provider/path_provider.dart';

abstract class ExportDataSource {
  Future<String> exportToExcel({
    required List<MeasurementEntity> measurements,
    required String fileName,
  });

  Future<String> exportToCSV({
    required List<MeasurementEntity> measurements,
    required String fileName,
  });
}

class ExportDataSourceImpl implements ExportDataSource {
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');
  final DateFormat _timeFormat = DateFormat('HH:mm');
  final DateFormat _dayFormat = DateFormat('EEEE', 'es');

  /// Obtiene el directorio público de Descargas
  Future<Directory> _getPublicDirectory() async {
    if (Platform.isAndroid) {
      // Usar Downloads en Android (accesible desde el explorador)
      final directory = Directory('/storage/emulated/0/Documents/MTA');
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }
      return directory;
    } else {
      // En otros sistemas, usar documents
      return await getApplicationDocumentsDirectory();
    }
  }

  @override
  Future<String> exportToExcel({
    required List<MeasurementEntity> measurements,
    required String fileName,
  }) async {
    try {
      debugPrint(
          '${DateFormat('HH:mm:ss').format(DateTime.now())} -📊 ExportDataSource - Creating Excel file: $fileName');

      // Crear Excel
      final excel = Excel.createExcel();
      final sheet = excel['Measurements'];

      // Headers
      sheet.appendRow([
        TextCellValue('Fecha'),
        TextCellValue('Día'),
        TextCellValue('Hora'),
        TextCellValue('Nº Medición'),
        TextCellValue('Sistólica (mmHg)'),
        TextCellValue('Diastólica (mmHg)'),
        TextCellValue('Pulsaciones (bpm)'),
        TextCellValue('Nota'),
      ]);

      // Estilo para encabezados
      for (int col = 0; col < 8; col++) {
        final cell = sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: 0));
        cell.cellStyle = CellStyle(
          bold: true,
          backgroundColorHex: ExcelColor.blue,
          fontColorHex: ExcelColor.white,
        );
      }

      // Data rows
      for (final measurement in measurements) {
        sheet.appendRow([
          TextCellValue(_dateFormat.format(measurement.measurementTime)),
          TextCellValue(_dayFormat.format(measurement.measurementTime)),
          TextCellValue(_timeFormat.format(measurement.measurementTime)),
          IntCellValue(measurement.measurementNumber),
          IntCellValue(measurement.systolic),
          IntCellValue(measurement.diastolic),
          measurement.pulse != null
              ? IntCellValue(measurement.pulse!)
              : TextCellValue('-'),
          TextCellValue(measurement.note ?? ''),
        ]);
      }

      // Auto-ajustar columnas
      for (int col = 0; col < 8; col++) {
        sheet.setColumnWidth(col, 15);
      }

      // Guardar archivo
      final directory = await _getPublicDirectory();
      final filePath = '${directory.path}/$fileName.xlsx';

      final fileBytes = excel.encode();
      if (fileBytes == null) {
        throw CacheFailure('Failed to encode Excel file');
      }

      final file = File(filePath);
      await file.writeAsBytes(fileBytes);

      debugPrint(
          '${DateFormat('HH:mm:ss').format(DateTime.now())} -✅ ExportDataSource - Excel file created: $filePath');
      debugPrint(
          '${DateFormat('HH:mm:ss').format(DateTime.now())} -📂 Accessible from: Download/MTA/$fileName.xlsx');
      return filePath;
    } catch (e) {
      debugPrint(
          '${DateFormat('HH:mm:ss').format(DateTime.now())} -❌ ExportDataSource - Error creating Excel: $e');
      throw CacheFailure('Failed to export to Excel: ${e.toString()}');
    }
  }

  @override
  Future<String> exportToCSV({
    required List<MeasurementEntity> measurements,
    required String fileName,
  }) async {
    try {
      debugPrint(
          '${DateFormat('HH:mm:ss').format(DateTime.now())} -📊 ExportDataSource - Creating CSV file: $fileName');

      final buffer = StringBuffer();

      // Headers
      buffer.writeln(
          'Fecha,Día,Hora,Nº Medición,Sistólica (mmHg),Diastólica (mmHg),Pulsaciones (bpm),Nota');

      // Data rows
      for (final measurement in measurements) {
        final date = _dateFormat.format(measurement.measurementTime);
        final day = _dayFormat.format(measurement.measurementTime);
        final time = _timeFormat.format(measurement.measurementTime);
        final number = measurement.measurementNumber;
        final systolic = measurement.systolic;
        final diastolic = measurement.diastolic;
        final pulse = measurement.pulse?.toString() ?? '-';
        final note = measurement.note ?? '';

        buffer.writeln(
            '$date,$day,$time,$number,$systolic,$diastolic,$pulse,"$note"');
      }

      // Guardar archivo
      final directory = await _getPublicDirectory();
      final filePath = '${directory.path}/$fileName.csv';

      final file = File(filePath);
      await file.writeAsString(buffer.toString());

      debugPrint(
          '${DateFormat('HH:mm:ss').format(DateTime.now())} -✅ ExportDataSource - CSV file created: $filePath');
      debugPrint(
          '${DateFormat('HH:mm:ss').format(DateTime.now())} -📂 Accessible from: Download/MTA/$fileName.csv');
      return filePath;
    } catch (e) {
      debugPrint(
          '${DateFormat('HH:mm:ss').format(DateTime.now())} -❌ ExportDataSource - Error creating CSV: $e');
      throw CacheFailure('Failed to export to CSV: ${e.toString()}');
    }
  }
}
