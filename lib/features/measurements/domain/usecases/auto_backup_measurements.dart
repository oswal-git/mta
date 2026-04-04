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

class AutoBackupMeasurements implements UseCase<String, AutoBackupParams> {
  final MeasurementRepository repository;

  AutoBackupMeasurements(this.repository);

  @override
  Future<Either<Failure, String>> call(AutoBackupParams params) async {
    try {
      // 1. Obtener todas las mediciones del usuario
      final result = await repository.getMeasurements(params.userId);

      return result.fold(
        (failure) => Left(failure),
        (measurements) async {
          if (measurements.isEmpty) {
            return const Right('');
          }

          // 2. Determinar directorio de backup (Normalizar a minúsculas)
          final normalizedUserName = params.userName.toLowerCase();
          Directory backupDir;
          if (Platform.isAndroid) {
            backupDir = Directory(
                '/storage/emulated/0/Documents/MTA/$normalizedUserName/backup');
          } else {
            final docsDir = await getApplicationDocumentsDirectory();
            backupDir =
                Directory('${docsDir.path}/mta/$normalizedUserName/backup');
          }

          if (!await backupDir.exists()) {
            await backupDir.create(recursive: true);
          }

          // 3. Generar nombre de archivo con TS
          final ts = DateFormat('yyyy-MM-dd_HHmmss').format(DateTime.now());
          final filename = 'backup-$ts.csv';
          final file = File('${backupDir.path}/$filename');

          // 4. Preparar datos CSV
          final rows = <List<dynamic>>[];
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

          for (final m in measurements) {
            rows.add(MeasurementModel.fromEntity(m).toCsvRow());
          }

          final csvData = const ListToCsvConverter().convert(rows);
          await file.writeAsString(csvData);

          // Notificar al MediaStore en Android
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

          // 5. Rotación de archivos (Mantener solo los 10 más recientes)
          final files = backupDir
              .listSync()
              .whereType<File>()
              .where((f) => f.path.endsWith('.csv') && f.path.contains('backup-'))
              .toList();

          // Ordenar por nombre (el TS asegura el orden cronológico)
          files.sort((a, b) => a.path.compareTo(b.path));

          if (files.length > 10) {
            final toDeleteCount = files.length - 10;
            for (int i = 0; i < toDeleteCount; i++) {
              await files[i].delete();
            }
          }

          return Right(file.path);
        },
      );
    } catch (e) {
      return Left(CacheFailure('Auto-backup error: $e'));
    }
  }
}

class AutoBackupParams extends Equatable {
  final String userId;
  final String userName;

  const AutoBackupParams({required this.userId, required this.userName});

  @override
  List<Object?> get props => [userId, userName];
}
