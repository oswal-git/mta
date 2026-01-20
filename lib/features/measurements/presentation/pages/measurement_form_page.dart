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
import 'package:mta/features/users/presentation/bloc/user_event.dart';
import 'package:mta/features/users/presentation/bloc/user_state.dart';

class MeasurementFormPage extends StatefulWidget {
  final String? measurementId;
  final String? userId;

  const MeasurementFormPage({super.key, this.measurementId, this.userId});

  @override
  State<MeasurementFormPage> createState() => _MeasurementFormPageState();
}

class _MeasurementFormPageState extends State<MeasurementFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _noteController = TextEditingController();
  final _noteFocusNode = FocusNode();
  final _systolicController = TextEditingController();
  final _diastolicController = TextEditingController();
  final _pulseController = TextEditingController();
  final _bpMonitorModelController = TextEditingController();

  DateTime _selectedDateTime = DateTime.now();
  int _currentMeasurementNumber = 1;
  String? _userId;
  String? _measurementLocation;
  bool _isInitialized = false;
  bool _isDateTimeManuallyChanged = false;

  int _systolic = 120;
  int _diastolic = 80;
  int? _pulse = 70;

  @override
  void initState() {
    super.initState();
    _systolicController.text = _systolic.toString();
    _diastolicController.text = _diastolic.toString();
    _pulseController.text = _pulse.toString();
    _initializeForm();
  }

  void _initializeForm() {
    final userState = context.read<UserBloc>().state;

    // If a userId was passed in the route, set it as active user
    if (widget.userId != null) {
      debugPrint(
          '📋 MeasurementForm - Setting active user from route: ${widget.userId}');
      context.read<UserBloc>().add(SetActiveUserEvent(widget.userId!));
      _userId = widget.userId;
    } else if (userState is UsersLoaded && userState.activeUser != null) {
      _userId = userState.activeUser!.id;
      // Heredar valores del usuario por defecto
      _bpMonitorModelController.text =
          userState.activeUser!.bpMonitorModel ?? '';
      _measurementLocation = userState.activeUser!.measurementLocation;
    } else {
      debugPrint(
          '⚠️ MeasurementForm - No active user found, attempting to load users');
      // Intentar cargar usuarios si no están cargados aún
      context.read<UserBloc>().add(LoadUsersEvent());
      return;
    }

    setState(() {
      _currentMeasurementNumber = 1; // <-- reiniciar al abrir
      _selectedDateTime = DateTime.now(); // <-- opcional, iniciar fecha actual
      _isDateTimeManuallyChanged = false; // resetear la bandera
    });

    context.read<MeasurementBloc>().add(
          GetNextMeasurementNumberEvent(_userId!, _selectedDateTime),
        );
  }

  @override
  void dispose() {
    _noteController.dispose();
    _noteFocusNode.dispose();
    _systolicController.dispose();
    _diastolicController.dispose();
    _pulseController.dispose();
    _bpMonitorModelController.dispose();
    super.dispose();
  }

  void _clearFields() {
    setState(() {
      _systolic = 120;
      _diastolic = 80;
      _pulse = 70;
      _systolicController.text = _systolic.toString();
      _diastolicController.text = _diastolic.toString();
      _pulseController.text = _pulse.toString();
      _noteController.clear();
      // Volver a heredar del usuario al limpiar
      final userState = context.read<UserBloc>().state;
      if (userState is UsersLoaded && userState.activeUser != null) {
        _bpMonitorModelController.text =
            userState.activeUser!.bpMonitorModel ?? '';
        _measurementLocation = userState.activeUser!.measurementLocation;
      } else {
        _bpMonitorModelController.clear();
        _measurementLocation = null;
      }
    });

    if (_userId != null) {
      context.read<MeasurementBloc>().add(
            GetNextMeasurementNumberEvent(_userId!, _selectedDateTime),
          );
    }
  }

  void _saveMeasurement({bool andContinue = true}) {
    // Obtener valores de los controladores
    final systolicValue = int.tryParse(_systolicController.text);
    final diastolicValue = int.tryParse(_diastolicController.text);
    final pulseValue = _pulseController.text.isEmpty
        ? null
        : int.tryParse(_pulseController.text);

    if (systolicValue == null || systolicValue < 50 || systolicValue > 250) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).systoleValidation),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (diastolicValue == null || diastolicValue < 30 || diastolicValue > 150) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).diastoleValidation),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (pulseValue != null && (pulseValue < 30 || pulseValue > 200)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).pulseValidation),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_userId == null) return;

    final now = DateTime.now();
    if (!_isDateTimeManuallyChanged) {
      _selectedDateTime = DateTime.now();
    }

    final measurement = MeasurementEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: _userId!,
      measurementTime: _selectedDateTime,
      measurementNumber: _currentMeasurementNumber,
      systolic: systolicValue,
      diastolic: diastolicValue,
      pulse: pulseValue,
      note: _noteController.text.isEmpty ? null : _noteController.text,
      bpMonitorModel: _bpMonitorModelController.text.trim().isEmpty
          ? null
          : _bpMonitorModelController.text.trim(),
      measurementLocation: _measurementLocation,
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
      // Al terminar, simplemente volvemos. La HomePage se actualizará
      // al recibir el estado de MeasurementOperationSuccess.
      if (context.canPop()) {
        context.pop();
      } else {
        context.go(Routes.home); // Fallback por si no se puede hacer pop
      }
    }
  }

  Future<void> _selectDateTime() async {
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
          _isDateTimeManuallyChanged = true;
        });

        if (_userId != null) {
          context.read<MeasurementBloc>().add(
                GetNextMeasurementNumberEvent(_userId!, _selectedDateTime),
              );
        }
      }
    }
  }

  Color _getBackgroundColor() {
    final systolicValue = int.tryParse(_systolicController.text) ?? 120;
    final diastolicValue = int.tryParse(_diastolicController.text) ?? 80;
    return getBloodPressureColor(systolicValue, diastolicValue);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final dateTimeFormat = DateFormat('dd/MM/yyyy HH:mm');

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop && _userId != null) {
          debugPrint(
              '🔙 MeasurementForm - User pressed back, reloading measurements');
          // Recargar las mediciones del usuario activo
          context.read<MeasurementBloc>().add(LoadMeasurementsEvent(_userId!));
        }
      },
      child: MultiBlocListener(
        listeners: [
          BlocListener<MeasurementBloc, MeasurementState>(
            listener: (context, state) {
              if (state is NextMeasurementNumberLoaded) {
                setState(() {
                  _currentMeasurementNumber = state.number;
                  _isInitialized = true;
                });
              } else if (state is MeasurementNumberLoaded) {
                // Fallback por si acaso se usa el otro estado en alguna parte
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
          ),
          BlocListener<UserBloc, UserState>(
            listener: (context, state) {
              // Cuando se cargan los usuarios, intentar inicializar de nuevo
              if (state is UsersLoaded &&
                  state.activeUser != null &&
                  !_isInitialized) {
                debugPrint(
                    '✅ MeasurementForm - Users loaded, initializing form');
                _initializeForm();
              }
            },
          ),
        ],
        child: Scaffold(
          appBar: AppBar(
            title: Text(l10n.addMeasurement),
            actions: [
              IconButton(
                icon: const Icon(Icons.info_outline),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text(l10n.bloodPressureReference),
                      content: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildColorLegendDialog(
                              context,
                              AppConstants.colorNormal,
                              l10n.normal,
                              l10n.systoleDiastoleNormal,
                            ),
                            const SizedBox(height: 12),
                            _buildColorLegendDialog(
                              context,
                              AppConstants.colorElevated,
                              l10n.elevated,
                              l10n.systoleDiastoleElevated,
                            ),
                            const SizedBox(height: 12),
                            _buildColorLegendDialog(
                              context,
                              AppConstants.colorHigh,
                              l10n.high,
                              l10n.systoleDiastoleHigh,
                            ),
                          ],
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(l10n.close),
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
                        padding: const EdgeInsets.all(12),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // LÍNEA 1: Medición # y Fecha/Hora
                              Row(
                                children: [
                                  // Número de medición (sin card)
                                  Text(
                                    l10n.measurementTitle(
                                        _currentMeasurementNumber),
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const Spacer(),
                                  // Fecha y Hora (ajustado al contenido)
                                  InkWell(
                                    onTap: _selectDateTime,
                                    borderRadius: BorderRadius.circular(8),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                            color: Colors.grey[300]!),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.calendar_today,
                                              size: 16),
                                          const SizedBox(width: 6),
                                          Text(
                                            dateTimeFormat
                                                .format(_selectedDateTime),
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),

                              // LÍNEA 2: Sístole y Pulso (horizontales)
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildCompactIncrementField(
                                      label: l10n.systole,
                                      controller: _systolicController,
                                      unit: 'mmHg',
                                      icon: Icons.arrow_upward,
                                      min: 50,
                                      max: 250,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: _buildCompactIncrementField(
                                      label: l10n.pulse,
                                      controller: _pulseController,
                                      unit: 'bpm',
                                      icon: Icons.favorite,
                                      min: 30,
                                      max: 200,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),

                              // LÍNEA 3: Diástole y espacio vacío
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildCompactIncrementField(
                                      label: l10n.diastole,
                                      controller: _diastolicController,
                                      unit: 'mmHg',
                                      icon: Icons.arrow_downward,
                                      min: 30,
                                      max: 150,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Expanded(child: SizedBox()),
                                ],
                              ),
                              const SizedBox(height: 12),

                              // LÍNEA 4: Nota
                              Card(
                                margin: EdgeInsets.zero,
                                child: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(Icons.note, size: 16),
                                          const SizedBox(width: 6),
                                          Text(
                                            l10n.noteOptional,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      TextFormField(
                                        controller: _noteController,
                                        focusNode: _noteFocusNode,
                                        decoration: InputDecoration(
                                          hintText: l10n.addNoteHint,
                                          border: const OutlineInputBorder(),
                                          contentPadding: EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 8,
                                          ),
                                          isDense: true,
                                        ),
                                        maxLines: 3,
                                        maxLength: 200,
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              // LÍNEA 5: Tensiómetro y Ubicación
                              Card(
                                margin: EdgeInsets.zero,
                                child: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      TextFormField(
                                        controller: _bpMonitorModelController,
                                        decoration: InputDecoration(
                                          labelText:
                                              '${l10n.bloodPressureMonitorModel} (opcional)',
                                          prefixIcon:
                                              const Icon(Icons.monitor_heart),
                                          isDense: true,
                                        ),
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                      const SizedBox(height: 12),
                                      DropdownButtonFormField<String?>(
                                        initialValue: _measurementLocation,
                                        isExpanded: true,
                                        decoration: InputDecoration(
                                          labelText:
                                              '${l10n.measurementLocation} (opcional)',
                                          prefixIcon: const Icon(
                                              Icons.accessibility_new),
                                          isDense: true,
                                        ),
                                        items: [
                                          DropdownMenuItem(
                                            value: null,
                                            child:
                                                Text(l10n.locationNotIndicated),
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
                                            child:
                                                Text(l10n.locationRightWrist),
                                          ),
                                        ],
                                        onChanged: (value) {
                                          setState(() {
                                            _measurementLocation = value;
                                          });
                                        },
                                        style: const TextStyle(
                                            fontSize: 14, color: Colors.black),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Botones
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: () =>
                                          _saveMeasurement(andContinue: true),
                                      icon: const Icon(Icons.arrow_forward,
                                          size: 20),
                                      label: Text(l10n.next),
                                      style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 14),
                                        backgroundColor: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        foregroundColor: Colors.white,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: () =>
                                          _saveMeasurement(andContinue: false),
                                      icon: const Icon(Icons.check, size: 20),
                                      label: Text(l10n.finish),
                                      style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 14),
                                        backgroundColor: Colors.green[700],
                                        foregroundColor: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 40),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              : const Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }

  Widget _buildCompactIncrementField({
    required String label,
    required TextEditingController controller,
    required String unit,
    required IconData icon,
    required int min,
    required int max,
  }) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 12),
                const SizedBox(width: 3),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    final currentValue = int.tryParse(controller.text) ?? min;
                    if (currentValue > min) {
                      setState(() {
                        controller.text = (currentValue - 1).toString();
                      });
                    }
                  },
                  icon: const Icon(Icons.remove_circle_outline),
                  iconSize: 20,
                  padding: EdgeInsets.zero,
                  constraints:
                      const BoxConstraints(minWidth: 28, minHeight: 28),
                  color: Theme.of(context).colorScheme.primary,
                ),
                Expanded(
                  child: IntrinsicHeight(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          constraints: const BoxConstraints(minHeight: 32),
                          child: TextFormField(
                            controller: controller,
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              height: 1.0,
                            ),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(vertical: 4),
                              isDense: true,
                            ),
                            onChanged: (value) {
                              setState(() {}); // Actualizar el color de fondo
                            },
                            onTap: () {
                              // Seleccionar todo el texto al tocar
                              controller.selection = TextSelection(
                                baseOffset: 0,
                                extentOffset: controller.text.length,
                              );
                            },
                          ),
                        ),
                        Text(
                          unit,
                          style: TextStyle(
                            fontSize: 9,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    final currentValue = int.tryParse(controller.text) ?? min;
                    if (currentValue < max) {
                      setState(() {
                        controller.text = (currentValue + 1).toString();
                      });
                    }
                  },
                  icon: const Icon(Icons.add_circle_outline),
                  iconSize: 20,
                  padding: EdgeInsets.zero,
                  constraints:
                      const BoxConstraints(minWidth: 28, minHeight: 28),
                  color: Theme.of(context).colorScheme.primary,
                ),
              ],
            ),
          ],
        ),
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
