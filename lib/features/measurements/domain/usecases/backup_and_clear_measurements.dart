import 'dart:io';

import 'package:csv/csv.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';
import 'package:mta/core/error/failures.dart';
import 'package:mta/core/usecases/usecases.dart';
import 'package:mta/features/measurements/domain/repositories/measurement_repository.dart';
import 'package:mta/features/measurements/data/models/measurement_model.dart';
import 'package:path_provider/path_provider.dart';

class BackupAndClearMeasurements
    implements UseCase<BackupAndClearResult, BackupAndClearParams> {
  final MeasurementRepository repository;

  BackupAndClearMeasurements(this.repository);

  @override
  Future<Either<Failure, BackupAndClearResult>> call(
      BackupAndClearParams params) async {
    try {
      // 1. Obtener todas las mediciones del usuario
      final result = await repository.getMeasurements(params.userId);

      return result.fold(
        (failure) => Left(failure),
        (measurements) async {
          // 2. Filtrar por fechas
          final filteredMeasurements = measurements.where((m) {
            bool matches = true;
            if (params.startDate != null) {
              matches = matches &&
                  (m.measurementTime.isAfter(params.startDate!) ||
                      m.measurementTime.isAtSameMomentAs(params.startDate!));
            }
            if (params.endDate != null) {
              matches = matches &&
                  (m.measurementTime.isBefore(params.endDate!) ||
                      m.measurementTime.isAtSameMomentAs(params.endDate!));
            }
            return matches;
          }).toList();

          if (filteredMeasurements.isEmpty) {
            // No hay nada que borrar
            return const Right(BackupAndClearResult(
              count: 0,
              backupPath: null,
            ));
          }

          // 3. Generar archivo CSV en la carpeta pública
          Directory eliminadosDir;
          if (Platform.isAndroid) {
            eliminadosDir = Directory('/storage/emulated/0/Documents/MTA/${params.userName}/eliminados');
            try {
              if (!await eliminadosDir.exists()) {
                await eliminadosDir.create(recursive: true);
              }
            } catch (e) {
              eliminadosDir = Directory('/storage/emulated/0/Downloads/MTA/${params.userName}/eliminados');
              if (!await eliminadosDir.exists()) {
                await eliminadosDir.create(recursive: true);
              }
            }
          } else {
            final docsDir = await getApplicationDocumentsDirectory();
            eliminadosDir = Directory('${docsDir.path}/mta/${params.userName}/eliminados');
            if (!await eliminadosDir.exists()) {
              await eliminadosDir.create(recursive: true);
            }
          }

          final formatTS = DateFormat('yyyy-MM-dd_HHmmss');
          final formatShortName = DateFormat('yyyyMMdd');
          
          final ts = formatTS.format(DateTime.now());
          
          String filename;
          if (params.startDate != null && params.endDate != null) {
            final fdesde = formatShortName.format(params.startDate!);
            final fhasta = formatShortName.format(params.endDate!);
            filename = 'eliminados-$fdesde-$fhasta-$ts.csv';
          } else if (params.startDate == null && params.endDate != null) {
            final fhasta = formatShortName.format(params.endDate!);
            filename = 'eliminados-hasta-$fhasta-$ts.csv';
          } else if (params.startDate != null && params.endDate == null) {
            final fdesde = formatShortName.format(params.startDate!);
            filename = 'eliminados-desde-$fdesde-$ts.csv';
          } else {
            filename = 'eliminados-$ts.csv';
          }

          final file = File('${eliminadosDir.path}/$filename');

          // Crear filas CSV (formato base de datos para fácil re-importación)
          final rows = <List<dynamic>>[];
          // Cabecera exacta a variables
          rows.add([
            'id',
            'userId',
            'measurementTime',
            'measurementNumber',
            'systolic',
            'diastolic',
            'pulse',
            'note',
            'bpMonitorModel',
            'measurementLocation',
            'createdAt',
            'updatedAt'
          ]);

          for (final m in filteredMeasurements) {
            rows.add(MeasurementModel.fromEntity(m).toCsvRow());
          }

          final csvData = const ListToCsvConverter().convert(rows);
          await file.writeAsString(csvData);

          if (Platform.isAndroid) {
            try {
              await Process.run('am', [
                'broadcast',
                '-a',
                'android.intent.action.MEDIA_SCANNER_SCAN_FILE',
                '-d',
                'file://${file.path}'
              ]);
            } catch (_) {}
          }

          // 4. Borrar en la DB
          final deleteResult = await repository.deleteMeasurementsByDateRange(
            params.userId,
            params.startDate,
            params.endDate,
          );

          return deleteResult.fold(
            (failure) => Left(failure),
            (_) {
              return Right(BackupAndClearResult(
                count: filteredMeasurements.length,
                backupPath: file.path,
              ));
            },
          );
        },
      );
    } catch (e) {
      return Left(CacheFailure('Unexpected error: $e'));
    }
  }
}

class BackupAndClearParams extends Equatable {
  final String userId;
  final String userName;
  final DateTime? startDate;
  final DateTime? endDate;

  const BackupAndClearParams({
    required this.userId,
    required this.userName,
    this.startDate,
    this.endDate,
  });

  @override
  List<Object?> get props => [userId, startDate, endDate];
}

class BackupAndClearResult extends Equatable {
  final int count;
  final String? backupPath;

  const BackupAndClearResult({
    required this.count,
    this.backupPath,
  });

  @override
  List<Object?> get props => [count, backupPath];
}
