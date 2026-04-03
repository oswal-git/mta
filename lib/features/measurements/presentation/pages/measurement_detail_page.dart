import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:mta/core/l10n/app_localizations.dart';
import 'package:mta/core/utils/constants.dart';
import 'package:mta/core/utils/validators.dart';
import 'package:mta/features/measurements/domain/entities/measurement_entity.dart';
import 'package:mta/features/measurements/presentation/bloc/measurement_bloc.dart';
import 'package:mta/features/measurements/presentation/bloc/measurement_event.dart';
import 'package:mta/features/measurements/presentation/bloc/measurement_state.dart';
import 'package:mta/features/users/presentation/bloc/user_bloc.dart';
import 'package:mta/features/users/presentation/bloc/user_state.dart';
import 'package:mta/core/theme/theme.dart';

class MeasurementDetailPage extends StatefulWidget {
  final String measurementId;

  const MeasurementDetailPage({super.key, required this.measurementId});

  @override
  State<MeasurementDetailPage> createState() => _MeasurementDetailPageState();
}

class _MeasurementDetailPageState extends State<MeasurementDetailPage> {
  final _formKey = GlobalKey<FormState>();
  final _systolicController = TextEditingController();
  final _diastolicController = TextEditingController();
  final _pulseController = TextEditingController();
  final _noteController = TextEditingController();
  final _bpMonitorModelController = TextEditingController();

  DateTime? _selectedDateTime;
  String? _measurementLocation;
  MeasurementEntity? _measurement;
  bool _isEditing = false;
  bool _hasLoadedInitialData = false;

  @override
  void initState() {
    super.initState();
    _loadMeasurement();
  }

  void _loadMeasurement() {
    debugPrint('🔍 Loading measurement: ${widget.measurementId}');
    context.read<MeasurementBloc>().add(
          LoadMeasurementByIdEvent(widget.measurementId),
        );
  }

  @override
  void dispose() {
    _systolicController.dispose();
    _diastolicController.dispose();
    _pulseController.dispose();
    _noteController.dispose();
    _bpMonitorModelController.dispose();
    super.dispose();
  }

  void _loadMeasurementData(MeasurementEntity measurement) {
    setState(() {
      _measurement = measurement;
      _selectedDateTime = measurement.measurementTime;
      _systolicController.text = measurement.systolic.toString();
      _diastolicController.text = measurement.diastolic.toString();
      _pulseController.text = measurement.pulse?.toString() ?? '';
      _noteController.text = measurement.note ?? '';
      _bpMonitorModelController.text = measurement.bpMonitorModel ?? '';
      _measurementLocation = measurement.measurementLocation;
      _hasLoadedInitialData = true;
    });
    debugPrint('✅ Measurement data loaded: ${measurement.id}');
  }

  void _updateMeasurement() {
    if (_formKey.currentState!.validate() && _measurement != null) {
      final updatedMeasurement = _measurement!.copyWith(
        measurementTime: _selectedDateTime!,
        systolic: int.parse(_systolicController.text),
        diastolic: int.parse(_diastolicController.text),
        pulse: _pulseController.text.isEmpty
            ? null
            : int.parse(_pulseController.text),
        note: _noteController.text.isEmpty ? null : _noteController.text,
        bpMonitorModel: _bpMonitorModelController.text.trim().isEmpty
            ? null
            : _bpMonitorModelController.text.trim(),
        measurementLocation: _measurementLocation,
        updatedAt: DateTime.now(),
      );

      final userState = context.read<UserBloc>().state;
      String userName = '';
      if (userState is UsersLoaded && userState.activeUser != null) {
        userName = userState.activeUser!.name;
      }

      context.read<MeasurementBloc>().add(
            UpdateMeasurementEvent(updatedMeasurement, userName),
          );
    }
  }

  void _deleteMeasurement() {
    final l10n = AppLocalizations.of(context);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.deleteConfirmTitle),
        content: Text(l10n.deleteConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              final userState = context.read<UserBloc>().state;
              String userName = '';
              if (userState is UsersLoaded && userState.activeUser != null) {
                userName = userState.activeUser!.name;
              }

              context.read<MeasurementBloc>().add(
                    DeleteMeasurementEvent(
                      widget.measurementId,
                      _measurement!.userId,
                      userName,
                    ),
                  );
              Navigator.of(dialogContext).pop();
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDateTime() async {
    if (_selectedDateTime == null) return;

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime!,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null && mounted) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDateTime!),
      );

      if (pickedTime != null && mounted) {
        setState(() {
          _selectedDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop && _measurement != null) {
          debugPrint(
              '🔙 MeasurementDetail - User pressed back, reloading measurements');
          // Recargar las mediciones del usuario antes de salir
          final userState = context.read<UserBloc>().state;
          if (userState is UsersLoaded && userState.activeUser != null) {
            context.read<MeasurementBloc>().add(
                  LoadMeasurementsEvent(userState.activeUser!.id),
                );
          }
        }
      },
      child: BlocConsumer<MeasurementBloc, MeasurementState>(
        listener: (context, state) {
          debugPrint('📊 MeasurementDetail State: ${state.runtimeType}');

          if (state is MeasurementDetailLoaded) {
            _loadMeasurementData(state.measurement);
          } else if (state is MeasurementOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
            context.go(Routes.home);
          } else if (state is MeasurementError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
            // Si hay error, volver atrás
            if (mounted) {
              context.go(Routes.home);
            }
          }
        },
        builder: (context, state) {
          if (state is MeasurementLoading && !_hasLoadedInitialData) {
            return Scaffold(
              appBar: AppBar(title: Text(l10n.measurementDetails)),
              body: const Center(child: CircularProgressIndicator()),
            );
          }

          // Si hay error y no tenemos datos, mostrar mensaje
          if (state is MeasurementError && _measurement == null) {
            return Scaffold(
              appBar: AppBar(title: Text(l10n.measurementDetails)),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: AppIcons.huge,
                      color: AppColors.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => context.go(Routes.home),
                      icon: const Icon(Icons.home),
                      label: Text(l10n.backToHome),
                    ),
                  ],
                ),
              ),
            );
          }

          // Si no tenemos medición todavía, mostrar loading
          if (_measurement == null) {
            return Scaffold(
              appBar: AppBar(title: Text(l10n.measurementDetails)),
              body: const Center(child: CircularProgressIndicator()),
            );
          }

          final backgroundColor = getBloodPressureColor(
            _measurement!.systolic,
            _measurement!.diastolic,
          );

          return Scaffold(
            appBar: AppBar(
              title: Text(l10n.measurementDetails),
              actions: [
                if (!_isEditing)
                  IconButton(
                    icon: const Icon(Icons.edit),
                    tooltip: l10n.edit,
                    onPressed: () {
                      setState(() {
                        _isEditing = true;
                      });
                    },
                  ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  tooltip: l10n.delete,
                  onPressed: _deleteMeasurement,
                ),
              ],
            ),
            body: SingleChildScrollView(
              child: Column(
                children: [
                  // Header with color
                  Container(
                    width: double.infinity,
                    padding: AppSpacing.pAllMd,
                    decoration: BoxDecoration(
                      color: backgroundColor,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _measurement!.systolic.toString(),
                              style: AppTypography.displaySmall,
                            ),
                            const Text(
                              ' / ',
                              style: TextStyle(fontSize: AppIcons.lg),
                            ),
                            Text(
                              _measurement!.diastolic.toString(),
                              style: AppTypography.displaySmall,
                            ),
                          ],
                        ),
                        const Text(
                          'mmHg',
                          style: TextStyle(fontSize: 16),
                        ),
                        if (_measurement!.pulse != null) ...[
                          const SizedBox(height: AppSpacing.gapMd),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.favorite,
                                  size: AppIcons.navIcon),
                              const SizedBox(width: AppSpacing.gapSm),
                              Text(
                                '${_measurement!.pulse} bpm',
                                style: AppTypography.h2.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Form
                  Padding(
                    padding: AppSpacing.pAllMd,
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Measurement Number (read-only)
                          Card(
                            child: ListTile(
                              leading: const Icon(Icons.numbers),
                              title: Text(l10n.measurementNumber),
                              trailing: Text(
                                _measurement!.measurementNumber.toString(),
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.gapMd),

                          // Date and Time
                          Card(
                            child: ListTile(
                              leading: const Icon(Icons.calendar_today),
                              title: Text(l10n.measurementTime),
                              subtitle: Text(
                                _selectedDateTime != null
                                    ? dateFormat.format(_selectedDateTime!)
                                    : '',
                              ),
                              trailing: _isEditing
                                  ? IconButton(
                                      icon: const Icon(Icons.edit),
                                      onPressed: _selectDateTime,
                                    )
                                  : null,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.gapLg),

                          // Systolic
                          TextFormField(
                            controller: _systolicController,
                            decoration: InputDecoration(
                              labelText: '${l10n.systolic} *',
                              prefixIcon: const Icon(Icons.arrow_upward),
                              suffixText: 'mmHg',
                            ),
                            keyboardType: TextInputType.number,
                            enabled: _isEditing,
                            validator: (value) => Validators.systolic(value),
                          ),
                          const SizedBox(height: 16),

                          // Diastolic
                          TextFormField(
                            controller: _diastolicController,
                            decoration: InputDecoration(
                              labelText: '${l10n.diastolic} *',
                              prefixIcon: const Icon(Icons.arrow_downward),
                              suffixText: 'mmHg',
                            ),
                            keyboardType: TextInputType.number,
                            enabled: _isEditing,
                            validator: (value) => Validators.diastolic(value),
                          ),
                          const SizedBox(height: 16),

                          // Pulse
                          TextFormField(
                            controller: _pulseController,
                            decoration: InputDecoration(
                              labelText: l10n.pulse,
                              prefixIcon: const Icon(Icons.favorite),
                              suffixText: 'bpm',
                            ),
                            keyboardType: TextInputType.number,
                            enabled: _isEditing,
                            validator: (value) => Validators.pulse(value),
                          ),
                          const SizedBox(height: 16),

                          // Note
                          TextFormField(
                            controller: _noteController,
                            decoration: InputDecoration(
                              labelText: l10n.note,
                              prefixIcon: const Icon(Icons.note),
                            ),
                            maxLines: 3,
                            enabled: _isEditing,
                          ),
                          const SizedBox(height: AppSpacing.gapMd),

                          // BP Monitor Model
                          TextFormField(
                            controller: _bpMonitorModelController,
                            decoration: InputDecoration(
                              labelText: l10n.bloodPressureMonitorModel,
                              prefixIcon: const Icon(Icons.monitor_heart),
                            ),
                            enabled: _isEditing,
                          ),
                          const SizedBox(height: AppSpacing.gapMd),

                          // Measurement Location
                          if (_isEditing)
                            DropdownButtonFormField<String?>(
                              initialValue: _measurementLocation,
                              decoration: InputDecoration(
                                labelText: l10n.measurementLocation,
                                prefixIcon: const Icon(Icons.accessibility_new),
                              ),
                              items: [
                                DropdownMenuItem(
                                  value: null,
                                  child: Text(l10n.locationNotIndicated),
                                ),
                                DropdownMenuItem(
                                  value: 'left_arm',
                                  child: Text(l10n.locationLeftArm),
                                ),
                                DropdownMenuItem(
                                  value: 'left_wrist',
                                  child: Text(l10n.locationLeftWrist),
                                ),
                                DropdownMenuItem(
                                  value: 'right_arm',
                                  child: Text(l10n.locationRightArm),
                                ),
                                DropdownMenuItem(
                                  value: 'right_wrist',
                                  child: Text(l10n.locationRightWrist),
                                ),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  _measurementLocation = value;
                                });
                              },
                            )
                          else
                            Card(
                              child: ListTile(
                                leading: const Icon(Icons.accessibility_new),
                                title: Text(l10n.measurementLocation),
                                subtitle: Text(_measurementLocation == null
                                    ? l10n.locationNotIndicated
                                    : (_measurementLocation == 'left_arm'
                                        ? l10n.locationLeftArm
                                        : (_measurementLocation == 'left_wrist'
                                            ? l10n.locationLeftWrist
                                            : (_measurementLocation ==
                                                    'right_arm'
                                                ? l10n.locationRightArm
                                                : l10n.locationRightWrist)))),
                              ),
                            ),
                          const SizedBox(height: 32),

                          // Buttons
                          if (_isEditing) ...[
                            ElevatedButton.icon(
                              onPressed: _updateMeasurement,
                              icon: const Icon(Icons.save),
                              label: Text(l10n.save),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.all(16),
                              ),
                            ),
                            const SizedBox(height: 16),
                            OutlinedButton.icon(
                              onPressed: () {
                                setState(() {
                                  _isEditing = false;
                                  _loadMeasurementData(_measurement!);
                                });
                              },
                              icon: const Icon(Icons.cancel),
                              label: Text(l10n.cancel),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.all(16),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
