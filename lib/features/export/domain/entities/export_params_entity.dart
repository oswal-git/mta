import 'package:equatable/equatable.dart';

/// Parámetros para exportar mediciones
class ExportParamsEntity extends Equatable {
  final DateTime startDate;
  final DateTime endDate;
  final String fileName;
  final ExportFormat format;
  final String userId;
  final String username;
   final int? userAge;
  final String? medication;

  const ExportParamsEntity({
    required this.startDate,
    required this.endDate,
    required this.fileName,
    required this.format,
    required this.userId,
    required this.username,
      this.userAge,
    this.medication,
  });

  @override
  List<Object?> get props => [
        startDate,
        endDate,
        fileName,
        format,
        userId,
        username,
          userAge,
        medication,
      ];
}

/// Formatos de exportación disponibles
enum ExportFormat {
  excel,
  csv,
  pdf,
}

extension ExportFormatExtension on ExportFormat {
  String get extension {
    switch (this) {
      case ExportFormat.excel:
        return 'xlsx';
      case ExportFormat.csv:
        return 'csv';
      case ExportFormat.pdf:
        return 'pdf';
    }
  }

  String get displayName {
    switch (this) {
      case ExportFormat.excel:
        return 'Excel (XLSX)';
      case ExportFormat.csv:
        return 'CSV';
      case ExportFormat.pdf:
        return 'PDF';
    }
  }
}
