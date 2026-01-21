import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:mta/core/di/injection_container.dart' as di;
import 'package:mta/core/l10n/app_localizations.dart';
import 'package:mta/core/theme/theme.dart';
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

  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    // Valores por defecto: último mes
    _endDate = DateTime.now();
    _startDate = DateTime(_endDate!.year, _endDate!.month - 1, _endDate!.day);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _updateFileName();
      _initialized = true;
    }
  }

  @override
  void dispose() {
    _fileNameController.dispose();
    super.dispose();
  }

  void _updateFileName() {
    final userState = context.read<UserBloc>().state;
    String username = AppLocalizations.of(context).defaultUsername;

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
        throw Exception(l10n.noMeasurementsAvailable);
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
        userBpMonitorModel: userState.activeUser!.bpMonitorModel,
        userMeasurementLocation: userState.activeUser!.measurementLocation,
        translations: {
          'header_date': l10n.exportHeaderDate,
          'header_day': l10n.exportHeaderDay,
          'header_time': l10n.exportHeaderTime,
          'header_systolic': l10n.exportHeaderSystolic,
          'header_diastolic': l10n.exportHeaderDiastolic,
          'header_pulse': l10n.exportHeaderPulse,
          'header_model': l10n.exportHeaderModel,
          'header_zone': l10n.exportHeaderZone,
          'header_note': l10n.exportHeaderNote,
          'pdf_title': l10n.exportPdfTitle,
          'header_systolic_short': l10n.exportHeaderSystolicShort,
          'header_diastolic_short': l10n.exportHeaderDiastolicShort,
          'header_pulse_short': l10n.exportHeaderPulseShort,
          'header_user_name': l10n.userName,
          'header_user_age': l10n.userAge,
          'header_medication': l10n.medicationName,
          'header_period': l10n.exportHeaderPeriod,
          'location_left_arm': l10n.locationLeftArm,
          'location_left_wrist': l10n.locationLeftWrist,
          'location_right_arm': l10n.locationRightArm,
          'location_right_wrist': l10n.locationRightWrist,
          'location_null': '',
          'location_not_indicated': '',
        },
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
              backgroundColor: AppColors.error,
            ),
          );
        },
        (filePath) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Row(
                children: [
                  Icon(Icons.check_circle,
                      color: AppColors.success, size: AppIcons.md),
                  const SizedBox(width: AppSpacing.gapSm),
                  Expanded(child: Text(l10n.exportSuccess)),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${l10n.fileLocation}:'),
                  const SizedBox(height: AppSpacing.gapSm),
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    ),
                    child: SelectableText(
                      filePath,
                      style: AppTypography.caption,
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
                  child: Text(l10n.ok),
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
          backgroundColor: AppColors.error,
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
        actions: [
          _isExporting
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: SizedBox(
                      width: AppIcons.navIcon,
                      height: AppIcons.navIcon,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: AppColors.white),
                    ),
                  ),
                )
              : IconButton(
                  icon: const Icon(Icons.file_download),
                  tooltip: l10n.exportButton,
                  onPressed: _exportData,
                ),
        ],
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.pAllMd,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Información
              Card(
                color: AppColors.surfaceVariant,
                child: Padding(
                  padding: AppSpacing.pAllMd,
                  child: Row(
                    children: [
                      Icon(Icons.info_outline,
                          color: AppColors.info, size: AppIcons.md),
                      const SizedBox(width: AppSpacing.gapMd),
                      Expanded(
                        child: Text(
                          l10n.selectDateRange,
                          style: AppTypography.bodyMedium
                              .copyWith(color: AppColors.info),
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
                    title: Text(_getFormatDisplayName(format, l10n)),
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
            ],
          ),
        ),
      ),
    );
  }

  String _getFormatDisplayName(ExportFormat format, AppLocalizations l10n) {
    switch (format) {
      case ExportFormat.excel:
        return l10n.formatExcel;
      case ExportFormat.csv:
        return l10n.formatCsv;
      case ExportFormat.pdf:
        return l10n.formatPdf;
    }
  }
}
