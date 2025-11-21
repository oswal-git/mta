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

class MeasurementFormPage extends StatefulWidget {
  final String? measurementId;

  const MeasurementFormPage({super.key, this.measurementId});

  @override
  State<MeasurementFormPage> createState() => _MeasurementFormPageState();
}

class _MeasurementFormPageState extends State<MeasurementFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _systolicController = TextEditingController();
  final _diastolicController = TextEditingController();
  final _pulseController = TextEditingController();
  final _noteController = TextEditingController();

  DateTime _selectedDateTime = DateTime.now();
  int _currentMeasurementNumber = 1;
  String? _userId;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    final userState = context.read<UserBloc>().state;
    if (userState is UsersLoaded && userState.activeUser != null) {
      _userId = userState.activeUser!.id;

      // Get next measurement number
      context.read<MeasurementBloc>().add(
            GetNextMeasurementNumberEvent(_userId!, _selectedDateTime),
          );
    }
  }

  @override
  void dispose() {
    _systolicController.dispose();
    _diastolicController.dispose();
    _pulseController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _clearFields() {
    _systolicController.clear();
    _diastolicController.clear();
    _pulseController.clear();
    _noteController.clear();

    // Get next measurement number
    if (_userId != null) {
      context.read<MeasurementBloc>().add(
            GetNextMeasurementNumberEvent(_userId!, _selectedDateTime),
          );
    }
  }

  void _saveMeasurement({bool andContinue = true}) {
    if (_formKey.currentState!.validate() && _userId != null) {
      final now = DateTime.now();
      final measurement = MeasurementEntity(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: _userId!,
        measurementTime: _selectedDateTime,
        measurementNumber: _currentMeasurementNumber,
        systolic: int.parse(_systolicController.text),
        diastolic: int.parse(_diastolicController.text),
        pulse: _pulseController.text.isEmpty
            ? null
            : int.parse(_pulseController.text),
        note: _noteController.text.isEmpty ? null : _noteController.text,
        createdAt: now,
        updatedAt: now,
      );

      context.read<MeasurementBloc>().add(CreateMeasurementEvent(measurement));

      if (andContinue) {
        _clearFields();
        _formKey.currentState!.reset();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).successSaved),
            duration: const Duration(seconds: 1),
          ),
        );
      } else {
        context.go(Routes.home);
      }
    }
  }

  Future<void> _selectDateTime() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null && mounted) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
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

        // Get next measurement number for the new date
        if (_userId != null) {
          context.read<MeasurementBloc>().add(
                GetNextMeasurementNumberEvent(_userId!, _selectedDateTime),
              );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return BlocListener<MeasurementBloc, MeasurementState>(
      listener: (context, state) {
        if (state is MeasurementNumberLoaded) {
          setState(() {
            _currentMeasurementNumber = state.nextNumber;
            _isInitialized = true;
          });
        } else if (state is MeasurementError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.addMeasurement),
        ),
        body: _isInitialized
            ? SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Date and Time Selection
                      Card(
                        child: ListTile(
                          leading: const Icon(Icons.calendar_today),
                          title: Text(l10n.measurementTime),
                          subtitle: Text(dateFormat.format(_selectedDateTime)),
                          trailing: const Icon(Icons.edit),
                          onTap: _selectDateTime,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Measurement Number
                      Card(
                        child: ListTile(
                          leading: const Icon(Icons.numbers),
                          title: Text(l10n.measurementNumber),
                          trailing: Text(
                            _currentMeasurementNumber.toString(),
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Systolic
                      TextFormField(
                        controller: _systolicController,
                        decoration: InputDecoration(
                          labelText: '${l10n.systolic} *',
                          prefixIcon: const Icon(Icons.arrow_upward),
                          suffixText: 'mmHg',
                        ),
                        keyboardType: TextInputType.number,
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
                          helperText: 'Optional',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) => Validators.pulse(value),
                      ),
                      const SizedBox(height: 16),

                      // Note
                      TextFormField(
                        controller: _noteController,
                        decoration: InputDecoration(
                          labelText: l10n.note,
                          prefixIcon: const Icon(Icons.note),
                          helperText: 'Optional',
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 32),

                      // Buttons
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () =>
                                  _saveMeasurement(andContinue: true),
                              icon: const Icon(Icons.save),
                              label: Text(l10n.save),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.all(16),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () =>
                                  _saveMeasurement(andContinue: false),
                              icon: const Icon(Icons.check),
                              label: Text(l10n.finish),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.all(16),
                                backgroundColor:
                                    Theme.of(context).colorScheme.secondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Cancel button
                      OutlinedButton.icon(
                        onPressed: () => context.go(Routes.home),
                        icon: const Icon(Icons.cancel),
                        label: Text(l10n.cancel),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.all(16),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Color Legend
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Blood Pressure Reference',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 12),
                              _buildColorLegend(
                                context,
                                AppConstants.colorNormal,
                                'Normal',
                                'Systolic < 130, Diastolic < 85',
                              ),
                              const SizedBox(height: 8),
                              _buildColorLegend(
                                context,
                                AppConstants.colorElevated,
                                'Elevated',
                                'Systolic 130-139, Diastolic 85-89',
                              ),
                              const SizedBox(height: 8),
                              _buildColorLegend(
                                context,
                                AppConstants.colorHigh,
                                'High',
                                'Systolic ≥ 140, Diastolic ≥ 90',
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Widget _buildColorLegend(
    BuildContext context,
    Color color,
    String title,
    String description,
  ) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: color,
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                description,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
