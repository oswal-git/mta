import 'dart:io';

import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mta/core/error/failures.dart';
import 'package:mta/features/measurements/domain/entities/measurement_entity.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

abstract class ExportDataSource {
  Future<String> exportToExcel({
    required List<MeasurementEntity> measurements,
    required String fileName,
    required String username,
  });

  Future<String> exportToCSV({
    required List<MeasurementEntity> measurements,
    required String fileName,
    required String username,
  });

  Future<String> exportToPDF({
    required List<MeasurementEntity> measurements,
    required String fileName,
    required String username,
    required DateTime startDate,
    required DateTime endDate,
    int? userAge,
    String? medication,
  });
}

class ExportDataSourceImpl implements ExportDataSource {
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');
  final DateFormat _timeFormat = DateFormat('HH:mm');
  final DateFormat _dayFormat = DateFormat('EEEE', 'es');

  /// Obtiene el directorio público de Descargas
  Future<Directory> _getPublicDirectory(String username) async {
    if (Platform.isAndroid) {
      // Intentar usar la carpeta Downloads primero (más visible)
      final documentsDir =
          Directory('/storage/emulated/0/Documents/MTA/$username');

      try {
        if (!await documentsDir.exists()) {
          await documentsDir.create(recursive: true);
        }
        debugPrint('📂 Export directory (Downloads): ${documentsDir.path}');
        return documentsDir;
      } catch (e) {
        debugPrint(
            '⚠️ No se pudo crear en Downloads, intentando Documents: $e');

        // Fallback a Documents si Downloads falla
        final downloadsDir =
            Directory('/storage/emulated/0/Downloads/MTA/$username');
        if (!await downloadsDir.exists()) {
          await downloadsDir.create(recursive: true);
        }
        debugPrint('📂 Export directory (Downloads): ${downloadsDir.path}');
        return downloadsDir;
      }
    } else {
      // En otros sistemas, usar documents
      final appDir = await getApplicationDocumentsDirectory();
      final userDirectory = Directory('${appDir.path}/exports/$username');

      if (!await userDirectory.exists()) {
        await userDirectory.create(recursive: true);
      }

      return userDirectory;
    }
  }

  /// Notifica al MediaStore de Android que hay un nuevo archivo
  Future<void> _scanFile(String filePath) async {
    if (Platform.isAndroid) {
      try {
        // Método 1: Usar el comando am broadcast
        await Process.run('am', [
          'broadcast',
          '-a',
          'android.intent.action.MEDIA_SCANNER_SCAN_FILE',
          '-d',
          'file://$filePath'
        ]);

        // Método 2: Usar el comando media scan directamente
        await Process.run('am', [
          'broadcast',
          '-a',
          'android.intent.action.MEDIA_MOUNTED',
          '-d',
          'file:///storage/emulated/0'
        ]);

        debugPrint(
            '${DateFormat('HH:mm:ss').format(DateTime.now())} -📄 MediaStore notificado: $filePath');
      } catch (e) {
        debugPrint(
            '${DateFormat('HH:mm:ss').format(DateTime.now())} -⚠️ Error notificando MediaStore: $e');
      }

      // Esperar un momento para que el sistema procese
      await Future.delayed(const Duration(milliseconds: 500));
    }
  }

  @override
  Future<String> exportToExcel({
    required List<MeasurementEntity> measurements,
    required String fileName,
    required String username,
  }) async {
    try {
      debugPrint(
          '${DateFormat('HH:mm:ss').format(DateTime.now())} -📊 ExportDataSource - Creating Excel file: $fileName for user: $username');

      // Crear Excel
      final excel = Excel.createExcel();

      // Eliminar la hoja por defecto 'Sheet1'
      excel.delete('Sheet1');
      final sheet = excel['Measurements'];

      // Headers
      sheet.appendRow([
        TextCellValue('Fecha'),
        TextCellValue('Día'),
        TextCellValue('Hora'),
        // TextCellValue('Nº Medición'),
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
          // IntCellValue(measurement.measurementNumber),
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
      final directory = await _getPublicDirectory(username);
      final filePath = '${directory.path}/$fileName.xlsx';

      final fileBytes = excel.encode();
      if (fileBytes == null) {
        throw CacheFailure('Failed to encode Excel file');
      }

      final file = File(filePath);
      await file.writeAsBytes(fileBytes);

      // Notificar al MediaStore
      await _scanFile(filePath);

      debugPrint(
          '${DateFormat('HH:mm:ss').format(DateTime.now())} -✅ ExportDataSource - Excel file created: $filePath');
      debugPrint(
          '${DateFormat('HH:mm:ss').format(DateTime.now())} -📂 Accessible from: Download/MTA/$username/$fileName.xlsx');
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
    required String username,
  }) async {
    try {
      debugPrint(
          '${DateFormat('HH:mm:ss').format(DateTime.now())} -📊 ExportDataSource - Creating CSV file: $fileName for user: $username');

      final buffer = StringBuffer();

      // Headers
      buffer.writeln(
          'Fecha,Día,Hora,Nº Medición,Sistólica (mmHg),Diastólica (mmHg),Pulsaciones (bpm),Nota');

      // Data rows
      for (final measurement in measurements) {
        final date = _dateFormat.format(measurement.measurementTime);
        final day = _dayFormat.format(measurement.measurementTime);
        final time = _timeFormat.format(measurement.measurementTime);
        // final number = measurement.measurementNumber;
        final systolic = measurement.systolic;
        final diastolic = measurement.diastolic;
        final pulse = measurement.pulse?.toString() ?? '-';
        final note = measurement.note ?? '';

        buffer.writeln('$date,$day,$time,$systolic,$diastolic,$pulse,"$note"');
      }

      // Guardar archivo
      final directory = await _getPublicDirectory(username);
      final filePath = '${directory.path}/$fileName.csv';

      final file = File(filePath);
      await file.writeAsString(buffer.toString());

      // Notificar al MediaStore
      await _scanFile(filePath);

      debugPrint(
          '${DateFormat('HH:mm:ss').format(DateTime.now())} -✅ ExportDataSource - CSV file created: $filePath');
      debugPrint(
          '${DateFormat('HH:mm:ss').format(DateTime.now())} -📂 Accessible from: Download/MTA/$username/$fileName.csv');
      return filePath;
    } catch (e) {
      debugPrint(
          '${DateFormat('HH:mm:ss').format(DateTime.now())} -❌ ExportDataSource - Error creating CSV: $e');
      throw CacheFailure('Failed to export to CSV: ${e.toString()}');
    }
  }

  @override
  Future<String> exportToPDF({
    required List<MeasurementEntity> measurements,
    required String fileName,
    required String username,
    required DateTime startDate,
    required DateTime endDate,
    int? userAge,
    String? medication,
  }) async {
    try {
      debugPrint(
          '${DateFormat('HH:mm:ss').format(DateTime.now())} -📊 ExportDataSource - Creating PDF file: $fileName for user: $username');

      final pdf = pw.Document();

      // Datos del encabezado
      final startDateStr = _dateFormat.format(startDate);
      final endDateStr = _dateFormat.format(endDate);

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (pw.Context context) {
            return [
              // Encabezado
              pw.Container(
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey400),
                  borderRadius:
                      const pw.BorderRadius.all(pw.Radius.circular(8)),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Listado de Mediciones de Tensión Arterial',
                      style: pw.TextStyle(
                        fontSize: 18,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 16),
                    pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        // Columna izquierda
                        pw.Expanded(
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              _buildHeaderRow('Nombre:', username),
                              pw.SizedBox(height: 8),
                              _buildHeaderRow(
                                  'Edad:', userAge?.toString() ?? 'N/A'),
                              pw.SizedBox(height: 8),
                              _buildHeaderRow(
                                  'Medicación:', medication ?? 'N/A'),
                              pw.SizedBox(height: 8),
                              _buildHeaderRow(
                                  'Período:', '$startDateStr - $endDateStr'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 24),

              // Tabla de mediciones
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey400),
                columnWidths: {
                  0: const pw.FixedColumnWidth(60),
                  1: const pw.FixedColumnWidth(50),
                  2: const pw.FixedColumnWidth(40),
                  // 3: const pw.FixedColumnWidth(30),
                  3: const pw.FixedColumnWidth(50),
                  4: const pw.FixedColumnWidth(50),
                  5: const pw.FixedColumnWidth(50),
                  6: const pw.FlexColumnWidth(),
                },
                children: [
                  // Encabezado de tabla
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(
                      color: PdfColors.blue100,
                    ),
                    children: [
                      _buildTableHeader('Fecha'),
                      _buildTableHeader('Día'),
                      _buildTableHeader('Hora'),
                      // _buildTableHeader('Nº'),
                      _buildTableHeader('Sist.\n(mmHg)'),
                      _buildTableHeader('Diast.\n(mmHg)'),
                      _buildTableHeader('Puls.\n(bpm)'),
                      _buildTableHeader('Nota'),
                    ],
                  ),
                  // Filas de datos
                  ...measurements.map((measurement) {
                    return pw.TableRow(
                      children: [
                        _buildTableCell(
                            _dateFormat.format(measurement.measurementTime)),
                        _buildTableCell(
                            _dayFormat.format(measurement.measurementTime)),
                        _buildTableCell(
                            _timeFormat.format(measurement.measurementTime)),
                        // _buildTableCell(
                        //     measurement.measurementNumber.toString()),
                        _buildTableCell(measurement.systolic.toString()),
                        _buildTableCell(measurement.diastolic.toString()),
                        _buildTableCell(measurement.pulse?.toString() ?? '-'),
                        _buildTableCell(measurement.note ?? ''),
                      ],
                    );
                  }),
                ],
              ),
            ];
          },
        ),
      );

      // Guardar archivo
      final directory = await _getPublicDirectory(username);
      final filePath = '${directory.path}/$fileName.pdf';
      debugPrint(
          '${DateFormat('HH:mm:ss').format(DateTime.now())} -✅ ExportDataSource - directory.path: ${directory.path}');

      final file = File(filePath);
      await file.writeAsBytes(await pdf.save());

      // Notificar al MediaStore
      await _scanFile(filePath);

      debugPrint(
          '${DateFormat('HH:mm:ss').format(DateTime.now())} -✅ ExportDataSource - PDF file created: $filePath');
      debugPrint(
          '${DateFormat('HH:mm:ss').format(DateTime.now())} -📂 Accessible from: Download/MTA/$username/$fileName.pdf or Documents/MTA/$username/$fileName.pdf');
      return filePath;
    } catch (e) {
      debugPrint(
          '${DateFormat('HH:mm:ss').format(DateTime.now())} -❌ ExportDataSource - Error creating PDF: $e');
      throw CacheFailure('Failed to export to PDF: ${e.toString()}');
    }
  }

  pw.Widget _buildHeaderRow(String label, String value) {
    return pw.Row(
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(
            fontWeight: pw.FontWeight.bold,
            fontSize: 12,
          ),
        ),
        pw.SizedBox(width: 8),
        pw.Text(
          value,
          style: const pw.TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  pw.Widget _buildTableHeader(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(4),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontWeight: pw.FontWeight.bold,
          fontSize: 9,
        ),
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  pw.Widget _buildTableCell(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(4),
      child: pw.Text(
        text,
        style: const pw.TextStyle(fontSize: 8),
        textAlign: pw.TextAlign.center,
      ),
    );
  }
}
