import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:mta/core/di/injection_container.dart' as di;
import 'package:mta/core/l10n/app_localizations.dart';
import 'package:mta/core/utils/constants.dart';
import 'package:mta/features/export/domain/entities/export_params_entity.dart';
import 'package:mta/features/export/domain/usecases/export_measurements.dart';
import 'package:mta/features/measurements/presentation/bloc/measurement_bloc.dart';
import 'package:mta/features/measurements/presentation/bloc/measurement_state.dart';
import 'package:mta/features/users/presentation/bloc/user_bloc.dart';
import 'package:mta/features/users/presentation/bloc/user_state.dart';

class ExportPage extends StatefulWidget {
  const ExportPage({super.key});

  @override
  State<ExportPage> createState() => _ExportPageState();
}

class _ExportPageState extends State<ExportPage> {
  final _formKey = GlobalKey<FormState>();
  final _fileNameController = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;
  ExportFormat _selectedFormat = ExportFormat.excel;
  bool _isExporting = false;

  @override
  void initState() {
    super.initState();
    // Valores por defecto: último mes
    _endDate = DateTime.now();
    _startDate = DateTime(_endDate!.year, _endDate!.month - 1, _endDate!.day);
    _updateFileName();
  }

  @override
  void dispose() {
    _fileNameController.dispose();
    super.dispose();
  }

  void _updateFileName() {
    final userState = context.read<UserBloc>().state;
    String username = 'usuario';
    
    if (userState is UsersLoaded && userState.activeUser != null) {
      username = userState.activeUser!.name;
    }

    final dateFormat = DateFormat('yyyy-MM-dd');
    final start = dateFormat.format(_startDate!);
    final end = dateFormat.format(_endDate!);
    _fileNameController.text = 'listado_mta_${username}_${start}_$end';
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _startDate! : _endDate!,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      locale: Localizations.localeOf(context),
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
        _updateFileName();
      });
    }
  }

  String? _validateDates() {
    final l10n = AppLocalizations.of(context);

    if (_startDate == null || _endDate == null) {
      return l10n.validationRequired;
    }

    if (_startDate!.isAfter(_endDate!)) {
      return l10n.validationStartBeforeEnd;
    }

    if (_endDate!.isAfter(DateTime.now())) {
      return l10n.validationEndNotFuture;
    }

    return null;
  }

  Future<void> _exportData() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final dateError = _validateDates();
    if (dateError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(dateError), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() {
      _isExporting = true;
    });

    final l10n = AppLocalizations.of(context);

    try {
      // Obtener usuario activo
      final userState = context.read<UserBloc>().state;
      if (userState is! UsersLoaded || userState.activeUser == null) {
        throw Exception(l10n.errorNoUser);
      }

      // Obtener mediciones
      final measurementState = context.read<MeasurementBloc>().state;
      if (measurementState is! MeasurementsLoaded) {
        throw Exception(l10n.errorLoadFailed);
      }

      final measurements = measurementState.measurements;

      if (measurements.isEmpty) {
        throw Exception('No measurements available');
      }

      // Crear parámetros de exportación
      final params = ExportParamsEntity(
        startDate: _startDate!,
        endDate: _endDate!,
        fileName: _fileNameController.text,
        format: _selectedFormat,
        userId: userState.activeUser!.id,
        username: userState.activeUser!.name,
        userAge: userState.activeUser!.age,
        medication: userState.activeUser!.medicationName,
      );

      // Ejecutar exportación
      final exportUseCase = di.sl<ExportMeasurements>();
      final result = await exportUseCase(
        ExportMeasurementsParams(
          measurements: measurements,
          params: params,
        ),
      );

      if (!mounted) return;

      result.fold(
        (failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${l10n.exportError}: ${failure.message}'),
              backgroundColor: Colors.red,
            ),
          );
        },
        (filePath) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green),
                  const SizedBox(width: 8),
                  Expanded(child: Text(l10n.exportSuccess)),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${l10n.fileLocation}:'),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: SelectableText(
                      filePath,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    context.go(Routes.home);
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        },
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${l10n.exportError}: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isExporting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.exportData),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(Routes.home),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Información
              Card(
                color: Colors.blue[50],
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue[700]),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          l10n.selectDateRange,
                          style: TextStyle(color: Colors.blue[700]),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Fecha de inicio
              Card(
                child: ListTile(
                  leading: const Icon(Icons.calendar_today),
                  title: Text(l10n.startDate),
                  subtitle: Text(
                    _startDate != null ? dateFormat.format(_startDate!) : '-',
                  ),
                  trailing: const Icon(Icons.edit),
                  onTap: () => _selectDate(context, true),
                ),
              ),
              const SizedBox(height: 12),

              // Fecha de fin
              Card(
                child: ListTile(
                  leading: const Icon(Icons.calendar_today),
                  title: Text(l10n.endDate),
                  subtitle: Text(
                    _endDate != null ? dateFormat.format(_endDate!) : '-',
                  ),
                  trailing: const Icon(Icons.edit),
                  onTap: () => _selectDate(context, false),
                ),
              ),
              const SizedBox(height: 24),

              // Formato de exportación
              Text(
                l10n.exportFormat,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              RadioGroup<ExportFormat>(
                groupValue: _selectedFormat,
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedFormat = value;
                    });
                  }
                },
                child: Column(
                    children: ExportFormat.values.map((format) {
                  return RadioListTile<ExportFormat>(
                    title: Text(format.displayName),
                    subtitle: Text('.${format.extension}'),
                    value: format,
                  );
                }).toList()),
              ),
              const SizedBox(height: 24),

              // Nombre del archivo
              TextFormField(
                controller: _fileNameController,
                decoration: InputDecoration(
                  labelText: l10n.fileName,
                  prefixIcon: const Icon(Icons.insert_drive_file),
                  suffixText: '.${_selectedFormat.extension}',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return l10n.validationRequired;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // Botón de exportar
              ElevatedButton.icon(
                onPressed: _isExporting ? null : _exportData,
                icon: _isExporting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.file_download),
                label: Text(
                  _isExporting ? 'Exportando...' : l10n.exportButton,
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 16),

              // Botón cancelar
              OutlinedButton.icon(
                onPressed: _isExporting ? null : () => context.go(Routes.home),
                icon: const Icon(Icons.cancel),
                label: Text(l10n.cancel),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}