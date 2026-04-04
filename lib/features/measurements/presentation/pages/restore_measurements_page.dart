import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mta/core/l10n/app_localizations.dart';
import 'package:mta/core/theme/theme.dart';
import 'package:mta/features/measurements/presentation/bloc/measurement_bloc.dart';
import 'package:mta/features/measurements/presentation/bloc/measurement_event.dart';
import 'package:mta/features/measurements/presentation/bloc/measurement_state.dart';
import 'package:mta/features/users/presentation/bloc/user_bloc.dart';
import 'package:mta/features/users/presentation/bloc/user_state.dart';
import 'package:path_provider/path_provider.dart';

class RestoreMeasurementsPage extends StatefulWidget {
  const RestoreMeasurementsPage({super.key});

  @override
  State<RestoreMeasurementsPage> createState() =>
      _RestoreMeasurementsPageState();
}

class _RestoreMeasurementsPageState extends State<RestoreMeasurementsPage> {
  List<File> _backupFiles = [];
  bool _isLoadingFiles = true;
  String? _userId;
  String? _userName;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    final userState = context.read<UserBloc>().state;
    if (userState is UsersLoaded && userState.activeUser != null) {
      _userId = userState.activeUser!.id;
      _userName = userState.activeUser!.name;
      await _loadBackupFiles();
    } else {
      setState(() {
        _isLoadingFiles = false;
      });
    }
  }

  Future<void> _loadBackupFiles() async {
    setState(() {
      _isLoadingFiles = true;
    });

    try {
      Directory backupDir;
      final normalizedUserName = _userName?.toLowerCase() ?? '';
      if (Platform.isAndroid) {
        backupDir = Directory('/storage/emulated/0/Documents/MTA/$normalizedUserName/backup');
      } else {
        final docsDir = await getApplicationDocumentsDirectory();
        backupDir = Directory('${docsDir.path}/mta/$normalizedUserName/backup');
      }

      if (await backupDir.exists()) {
        final files = backupDir
            .listSync()
            .whereType<File>()
            .where((f) => f.path.endsWith('.csv'))
            .toList();

        // Sort by name descending (most recent first based on TS in name)
        files.sort((a, b) => b.path.compareTo(a.path));

        setState(() {
          _backupFiles = files;
          _isLoadingFiles = false;
        });
      } else {
        setState(() {
          _backupFiles = [];
          _isLoadingFiles = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading backup files: $e');
      setState(() {
        _isLoadingFiles = false;
      });
    }
  }

  void _confirmAndRestore(File file) {
    final l10n = AppLocalizations.of(context);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.restoreMeasurementsTitle),
        content: Text(l10n.confirmRestore),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<MeasurementBloc>().add(
                    RestoreMeasurementsEvent(
                      userId: _userId!,
                      filePath: file.path,
                    ),
                  );
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.primary),
            child: Text(l10n.accept),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocListener<MeasurementBloc, MeasurementState>(
      listener: (context, state) {
        if (state is RestoreMeasurementsSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.restoreSuccess(state.count)),
              backgroundColor: AppColors.success,
            ),
          );
          // Reload measurements for the home page
          context.read<MeasurementBloc>().add(LoadMeasurementsEvent(state.userId));
          context.pop();
        } else if (state is MeasurementError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.restoreMeasurementsTitle),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadBackupFiles,
            ),
          ],
        ),
        body: _userId == null
            ? Center(child: Text(l10n.errorNoUser))
            : _isLoadingFiles
                ? const Center(child: CircularProgressIndicator())
                : _backupFiles.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.backup_outlined,
                                size: 64, color: Colors.grey),
                            const SizedBox(height: 16),
                            Text(l10n.noBackupsFound),
                          ],
                        ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              l10n.selectBackupFile,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                          Expanded(
                            child: ListView.builder(
                              itemCount: _backupFiles.length,
                              itemBuilder: (context, index) {
                                final file = _backupFiles[index];
                                final fileName = file.path.split(Platform.pathSeparator).last;
                                
                                // Extract date from backup-yyyy-MM-dd_HHmmss.csv
                                String displayDate = fileName;
                                try {
                                   if (fileName.startsWith('backup-')) {
                                     final dateStr = fileName.substring(7, 17); // yyyy-MM-dd
                                     final timeStr = fileName.substring(18, 24); // HHmmss
                                     displayDate = '${dateStr.split('-').reversed.join('/')} ${timeStr.substring(0,2)}:${timeStr.substring(2,4)}:${timeStr.substring(4,6)}';
                                   }
                                } catch (_) {}

                                return Card(
                                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  child: ListTile(
                                    leading: const Icon(Icons.insert_drive_file, color: AppColors.primary),
                                    title: Text(displayDate),
                                    subtitle: Text(fileName, style: const TextStyle(fontSize: 12)),
                                    trailing: const Icon(Icons.restore),
                                    onTap: () => _confirmAndRestore(file),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
      ),
    );
  }
}
