import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:mta/core/l10n/app_localizations.dart';
import 'package:mta/core/utils/constants.dart';
import 'package:mta/features/measurements/domain/entities/measurement_entity.dart';
import 'package:mta/features/measurements/presentation/bloc/measurement_bloc.dart';
import 'package:mta/features/measurements/presentation/bloc/measurement_event.dart';
import 'package:mta/features/measurements/presentation/bloc/measurement_state.dart';
import 'package:mta/features/users/presentation/bloc/user_bloc.dart';
import 'package:mta/features/users/presentation/bloc/user_state.dart';

class MeasurementFormPageCopy extends StatefulWidget {
  final String? measurementId;

  const MeasurementFormPageCopy({super.key, this.measurementId});

  @override
  State<MeasurementFormPageCopy> createState() =>
      _MeasurementFormPageCopyState();
}

class _MeasurementFormPageCopyState extends State<MeasurementFormPageCopy> {
  final _formKey = GlobalKey<FormState>();
  final _noteController = TextEditingController();
  final _noteFocusNode = FocusNode();

  DateTime _selectedDateTime = DateTime.now();
  int _currentMeasurementNumber = 1;
  String? _userId;
  bool _isInitialized = false;

  // Valores con incrementadores
  int _systolic = 120;
  int _diastolic = 80;
  int? _pulse = 70;

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
    _noteController.dispose();
    _noteFocusNode.dispose();
    super.dispose();
  }

  void _clearFields() {
    setState(() {
      _systolic = 120;
      _diastolic = 80;
      _pulse = 70;
      _noteController.clear();
    });

    // Get next measurement number
    if (_userId != null) {
      context.read<MeasurementBloc>().add(
            GetNextMeasurementNumberEvent(_userId!, _selectedDateTime),
          );
    }
  }

  void _saveMeasurement({bool andContinue = true}) {
    // Validación básica
    if (_systolic < 50 || _systolic > 250) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sístole debe estar entre 50 y 250'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_diastolic < 30 || _diastolic > 150) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Diástole debe estar entre 30 y 150'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_pulse != null && (_pulse! < 30 || _pulse! > 200)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pulso debe estar entre 30 y 200'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_userId == null) return;

    final now = DateTime.now();
    final measurement = MeasurementEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: _userId!,
      measurementTime: _selectedDateTime,
      measurementNumber: _currentMeasurementNumber,
      systolic: _systolic,
      diastolic: _diastolic,
      pulse: _pulse,
      note: _noteController.text.isEmpty ? null : _noteController.text,
      createdAt: now,
      updatedAt: now,
    );

    context.read<MeasurementBloc>().add(CreateMeasurementEvent(measurement));

    if (andContinue) {
      _clearFields();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).successSaved),
          duration: const Duration(seconds: 1),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      context.go(Routes.home);
    }
  }

  Future<void> _selectDateTime() async {
    // Cerrar teclado si está abierto
    FocusScope.of(context).unfocus();

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
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(
              alwaysUse24HourFormat: true,
            ),
            child: child!,
          );
        },
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

  Color _getBackgroundColor() {
    return getBloodPressureColor(_systolic, _diastolic);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    debugPrint(
        '${DateFormat('HH:mm:ss').format(DateTime.now())} -🌈 Primary: ${Theme.of(context).colorScheme.primary}');

    debugPrint(
        '${DateFormat('HH:mm:ss').format(DateTime.now())} -🌈 Primary: ${Theme.of(context).colorScheme.secondary}');

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
          actions: [
            // Botón de información
            IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Referencia de Presión Arterial'),
                    content: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildColorLegendDialog(
                            context,
                            AppConstants.colorNormal,
                            'Normal',
                            'Sístole < 130\nDiástole < 85',
                          ),
                          const SizedBox(height: 12),
                          _buildColorLegendDialog(
                            context,
                            AppConstants.colorElevated,
                            'Elevada',
                            'Sístole 130-139\nDiástole 85-89',
                          ),
                          const SizedBox(height: 12),
                          _buildColorLegendDialog(
                            context,
                            AppConstants.colorHigh,
                            'Alta',
                            'Sístole ≥ 140\nDiástole ≥ 90',
                          ),
                        ],
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cerrar'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
        body: _isInitialized
            ? GestureDetector(
                onTap: () => FocusScope.of(context).unfocus(),
                child: Container(
                  color: _getBackgroundColor(),
                  child: SafeArea(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // LÍNEA 1: Hora y Número de medición
                            Row(
                              children: [
                                // Hora
                                Expanded(
                                  child: Card(
                                    child: InkWell(
                                      onTap: _selectDateTime,
                                      child: Padding(
                                        padding: const EdgeInsets.all(16),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                const Icon(Icons.calendar_today,
                                                    size: 20),
                                                const SizedBox(width: 8),
                                                Text(
                                                  'Hora',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey[600],
                                                  ),
                                                ),
                                                const Spacer(),
                                                const Icon(Icons.edit,
                                                    size: 16),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              dateFormat
                                                  .format(_selectedDateTime),
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                // Número de medición
                                Card(
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      children: [
                                        const Icon(Icons.numbers, size: 20),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Medición #',
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          _currentMeasurementNumber.toString(),
                                          style: const TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // LÍNEA 2: Sístole y Pulso
                            Row(
                              children: [
                                // Sístole
                                Expanded(
                                  child: _buildIncrementField(
                                    label: 'Sístole',
                                    value: _systolic,
                                    unit: 'mmHg',
                                    icon: Icons.arrow_upward,
                                    onChanged: (newValue) {
                                      setState(() {
                                        _systolic = newValue;
                                      });
                                    },
                                    min: 50,
                                    max: 250,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                // Pulso
                                Expanded(
                                  child: _buildIncrementField(
                                    label: 'Pulso',
                                    value: _pulse ?? 70,
                                    unit: 'bpm',
                                    icon: Icons.favorite,
                                    onChanged: (newValue) {
                                      setState(() {
                                        _pulse = newValue;
                                      });
                                    },
                                    min: 30,
                                    max: 200,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // LÍNEA 3: Diástole
                            _buildIncrementField(
                              label: 'Diástole',
                              value: _diastolic,
                              unit: 'mmHg',
                              icon: Icons.arrow_downward,
                              onChanged: (newValue) {
                                setState(() {
                                  _diastolic = newValue;
                                });
                              },
                              min: 30,
                              max: 150,
                            ),
                            const SizedBox(height: 16),

                            // LÍNEA 4: Nota
                            Card(
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.note, size: 20),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Nota (opcional)',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    TextFormField(
                                      controller: _noteController,
                                      focusNode: _noteFocusNode,
                                      decoration: const InputDecoration(
                                        hintText: 'Añade una nota...',
                                        border: OutlineInputBorder(),
                                        contentPadding: EdgeInsets.all(12),
                                      ),
                                      maxLines: 2,
                                      maxLength: 200,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Botones
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () =>
                                        _saveMeasurement(andContinue: true),
                                    icon: const Icon(Icons.arrow_forward),
                                    label: const Text('Siguiente'),
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 16),
                                      backgroundColor:
                                          Theme.of(context).colorScheme.primary,
                                      foregroundColor: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () =>
                                        _saveMeasurement(andContinue: false),
                                    icon: const Icon(Icons.check),
                                    label: const Text('Terminar'),
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 16),
                                      backgroundColor: Colors.green[700],
                                      foregroundColor: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                                height: 60), // Espacio extra para el teclado
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              )
            : const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Widget _buildIncrementField({
    required String label,
    required int value,
    required String unit,
    required IconData icon,
    required Function(int) onChanged,
    required int min,
    required int max,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                // Botón decrementar
                IconButton(
                  onPressed: value > min ? () => onChanged(value - 1) : null,
                  icon: const Icon(Icons.remove_circle_outline),
                  iconSize: 32,
                  color: Theme.of(context).colorScheme.primary,
                ),
                // Valor
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      // Permitir edición manual
                      _showManualInput(
                        context: context,
                        label: label,
                        currentValue: value,
                        unit: unit,
                        min: min,
                        max: max,
                        onChanged: onChanged,
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Text(
                            value.toString(),
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            unit,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Botón incrementar
                IconButton(
                  onPressed: value < max ? () => onChanged(value + 1) : null,
                  icon: const Icon(Icons.add_circle_outline),
                  iconSize: 32,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showManualInput({
    required BuildContext context,
    required String label,
    required int currentValue,
    required String unit,
    required int min,
    required int max,
    required Function(int) onChanged,
  }) {
    final controller = TextEditingController(text: currentValue.toString());

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Editar $label'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: label,
            suffixText: unit,
            border: const OutlineInputBorder(),
          ),
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
          ],
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              final newValue = int.tryParse(controller.text);
              if (newValue != null && newValue >= min && newValue <= max) {
                onChanged(newValue);
                Navigator.pop(dialogContext);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('El valor debe estar entre $min y $max'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  Widget _buildColorLegendDialog(
    BuildContext context,
    Color color,
    String title,
    String description,
  ) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color,
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
