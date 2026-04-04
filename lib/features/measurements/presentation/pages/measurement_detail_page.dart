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
import 'package:mta/features/measurements/presentation/widgets/compact_increment_field_widget.dart';

class MeasurementDetailPage extends StatefulWidget {
  final String measurementId;

  const MeasurementDetailPage({super.key, required this.measurementId});

  @override
  State<MeasurementDetailPage> createState() => _MeasurementDetailPageState();
}

class _MeasurementDetailPageState extends State<MeasurementDetailPage> {
  PageController? _pageController;
  int _currentIndex = 0;
  List<MeasurementEntity> _measurements = [];
  bool _isInitialized = false;
  bool _isCurrentPageDirty = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _pageController?.dispose();
    super.dispose();
  }

  void _initializePageView(List<MeasurementEntity> measurements) {
    if (_isInitialized) return;

    final index = measurements.indexWhere((m) => m.id == widget.measurementId);
    if (index != -1) {
      _measurements = measurements;
      _currentIndex = index;
      _pageController = PageController(initialPage: index);
      _isInitialized = true;
    }
  }

  Future<bool> _showDiscardDialog() async {
    final l10n = AppLocalizations.of(context);
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.discardChangesTitle),
        content: Text(l10n.discardChangesMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.continueEditing),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: Text(l10n.discard),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  void _handleBack() async {
    if (_isCurrentPageDirty) {
      final discard = await _showDiscardDialog();
      if (!discard) return;
    }
    if (mounted) {
      context.pop(_measurements[_currentIndex].id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocBuilder<MeasurementBloc, MeasurementState>(
      builder: (context, state) {
        if (state is MeasurementsLoaded) {
          _initializePageView(state.measurements);

          if (!_isInitialized) {
            return Scaffold(
              appBar: AppBar(title: Text(l10n.measurementDetails)),
              body: const Center(child: CircularProgressIndicator()),
            );
          }

          return PopScope(
            canPop: false,
            onPopInvokedWithResult: (didPop, result) async {
              if (didPop) return;
              _handleBack();
            },
            child: Scaffold(
              appBar: AppBar(
                title: Text(
                    '${l10n.measurementDetails} (${_currentIndex + 1}/${_measurements.length})'),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: _handleBack,
                ),
              ),
              body: GestureDetector(
                onHorizontalDragStart: (_) {
                  // Captura el inicio del swipe si está el modo "Dirty" bloqueado
                },
                child: PageView.builder(
                  controller: _pageController,
                  physics: _isCurrentPageDirty
                      ? const NeverScrollableScrollPhysics()
                      : const BouncingScrollPhysics(),
                  itemCount: _measurements.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentIndex = index;
                      _isCurrentPageDirty = false;
                    });
                  },
                  itemBuilder: (context, index) {
                    return Stack(
                      children: [
                        _MeasurementDetailView(
                          measurement: _measurements[index],
                          onDeleted: () => context.go(Routes.home),
                          onDirtyChanged: (isDirty) {
                            if (_isCurrentPageDirty != isDirty) {
                              setState(() {
                                _isCurrentPageDirty = isDirty;
                              });
                            }
                          },
                        ),
                        // Overlay para detectar swipes cuando está bloqueado
                        if (_isCurrentPageDirty)
                          Positioned.fill(
                            child: Row(
                              children: [
                                // Lado izquierdo (detectar swipe hacia la derecha -> página anterior)
                                Expanded(
                                  child: GestureDetector(
                                    behavior: HitTestBehavior.translucent,
                                    onHorizontalDragUpdate: (details) async {
                                      if (details.primaryDelta! > 10) {
                                        final discard =
                                            await _showDiscardDialog();
                                        if (discard && mounted) {
                                          setState(() =>
                                              _isCurrentPageDirty = false);
                                          _pageController?.previousPage(
                                            duration: const Duration(
                                                milliseconds: 300),
                                            curve: Curves.easeInOut,
                                          );
                                        }
                                      } else if (details.primaryDelta! < -10) {
                                        final discard =
                                            await _showDiscardDialog();
                                        if (discard && mounted) {
                                          setState(() =>
                                              _isCurrentPageDirty = false);
                                          _pageController?.nextPage(
                                            duration: const Duration(
                                                milliseconds: 300),
                                            curve: Curves.easeInOut,
                                          );
                                        }
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(title: Text(l10n.measurementDetails)),
          body: const Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}

class _MeasurementDetailView extends StatefulWidget {
  final MeasurementEntity measurement;
  final VoidCallback onDeleted;
  final Function(bool isDirty) onDirtyChanged;

  const _MeasurementDetailView({
    required this.measurement,
    required this.onDeleted,
    required this.onDirtyChanged,
  });

  @override
  State<_MeasurementDetailView> createState() => _MeasurementDetailViewState();
}

class _MeasurementDetailViewState extends State<_MeasurementDetailView> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _systolicController;
  late TextEditingController _diastolicController;
  late TextEditingController _pulseController;
  late TextEditingController _noteController;
  late TextEditingController _bpMonitorModelController;

  DateTime? _selectedDateTime;
  String? _measurementLocation;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _initControllers();
  }

  @override
  void didUpdateWidget(covariant _MeasurementDetailView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.measurement.id != widget.measurement.id) {
      _initControllers();
      _isEditing = false;
    }
  }

  void _initControllers() {
    _selectedDateTime = widget.measurement.measurementTime;
    _systolicController =
        TextEditingController(text: widget.measurement.systolic.toString());
    _diastolicController =
        TextEditingController(text: widget.measurement.diastolic.toString());
    _pulseController =
        TextEditingController(text: widget.measurement.pulse?.toString() ?? '');
    _noteController =
        TextEditingController(text: widget.measurement.note ?? '');
    _bpMonitorModelController =
        TextEditingController(text: widget.measurement.bpMonitorModel ?? '');
    _measurementLocation = widget.measurement.measurementLocation;

    _systolicController.addListener(_checkDirty);
    _diastolicController.addListener(_checkDirty);
    _pulseController.addListener(_checkDirty);
    _noteController.addListener(_checkDirty);
    _bpMonitorModelController.addListener(_checkDirty);
  }

  void _checkDirty() {
    final isDirty = _isCurrentlyDirty();
    widget.onDirtyChanged(isDirty);
    setState(() {}); // Actualizar estado de iconos
  }

  bool _isCurrentlyDirty() {
    if (!_isEditing) return false;

    final currentPulse = _pulseController.text.isEmpty
        ? null
        : int.tryParse(_pulseController.text);
    final currentNote =
        _noteController.text.isEmpty ? null : _noteController.text;
    final currentModel = _bpMonitorModelController.text.trim().isEmpty
        ? null
        : _bpMonitorModelController.text.trim();

    bool dirty = false;
    dirty |= _systolicController.text != widget.measurement.systolic.toString();
    dirty |=
        _diastolicController.text != widget.measurement.diastolic.toString();
    dirty |= currentPulse != widget.measurement.pulse;
    dirty |= currentNote != widget.measurement.note;
    dirty |= currentModel != widget.measurement.bpMonitorModel;
    dirty |= _measurementLocation != widget.measurement.measurementLocation;
    dirty |= _selectedDateTime != widget.measurement.measurementTime;

    return dirty;
  }

  Future<bool> _showDiscardDialog() async {
    final l10n = AppLocalizations.of(context);
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.discardChangesTitle),
        content: Text(l10n.discardChangesMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.continueEditing),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: Text(l10n.discard),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  void _exitEditMode() async {
    if (_isCurrentlyDirty()) {
      final discard = await _showDiscardDialog();
      if (!discard) return;
    }

    setState(() {
      _isEditing = false;
      _initControllers();
    });
    widget.onDirtyChanged(false);
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

  void _updateMeasurement() {
    if (_formKey.currentState!.validate()) {
      final updatedMeasurement = widget.measurement.copyWith(
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

      context
          .read<MeasurementBloc>()
          .add(UpdateMeasurementEvent(updatedMeasurement, userName));

      setState(() {
        _isEditing = false;
      });
      widget.onDirtyChanged(false);
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
              child: Text(l10n.cancel)),
          TextButton(
            onPressed: () {
              final userState = context.read<UserBloc>().state;
              String userName = '';
              if (userState is UsersLoaded && userState.activeUser != null) {
                userName = userState.activeUser!.name;
              }
              context.read<MeasurementBloc>().add(DeleteMeasurementEvent(
                  widget.measurement.id, widget.measurement.userId, userName));
              Navigator.of(dialogContext).pop();
              widget.onDeleted();
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final backgroundColor = getBloodPressureColor(
        widget.measurement.systolic, widget.measurement.diastolic);

    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: AppSpacing.pAllMd,
            decoration: BoxDecoration(color: backgroundColor, boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4))
            ]),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(widget.measurement.systolic.toString(),
                        style: AppTypography.displaySmall),
                    const Text(' / ', style: TextStyle(fontSize: AppIcons.lg)),
                    Text(widget.measurement.diastolic.toString(),
                        style: AppTypography.displaySmall),
                  ],
                ),
                const Text('mmHg', style: TextStyle(fontSize: 16)),
                if (widget.measurement.pulse != null) ...[
                  const SizedBox(height: AppSpacing.gapMd),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    const Icon(Icons.favorite, size: AppIcons.navIcon),
                    const SizedBox(width: AppSpacing.gapSm),
                    Text('${widget.measurement.pulse} bpm',
                        style: AppTypography.h2
                            .copyWith(fontWeight: FontWeight.w500)),
                  ]),
                ],
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (!_isEditing)
                  IconButton(
                    icon: const Icon(Icons.edit),
                    tooltip: l10n.edit,
                    onPressed: () => setState(() => _isEditing = true),
                  )
                else ...[
                  IconButton(
                    onPressed: _exitEditMode,
                    icon: const Icon(Icons.edit_off_outlined),
                    tooltip: l10n.cancel,
                  ),
                  IconButton(
                    onPressed: _isCurrentlyDirty() ? _updateMeasurement : null,
                    icon: const Icon(Icons.save),
                    tooltip: l10n.save,
                  ),
                ],
                IconButton(
                    icon: const Icon(Icons.delete, color: AppColors.error),
                    tooltip: l10n.delete,
                    onPressed: _deleteMeasurement),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                          l10n.measurementTitle(
                              widget.measurement.measurementNumber.toString()),
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today),
                          const SizedBox(width: AppSpacing.gapSm),
                          Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(l10n.measurementTime),
                                Text(_selectedDateTime != null
                                    ? dateFormat.format(_selectedDateTime!)
                                    : ''),
                              ]),
                          const SizedBox(width: AppSpacing.gapMd),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.gapLg),
                  // LÍNEA 2: Sístole y Pulso
                  Row(
                    children: [
                      Expanded(
                        child: CompactIncrementFieldWidget(
                          label: l10n.systole,
                          controller: _systolicController,
                          unit: 'mmHg',
                          icon: Icons.arrow_upward,
                          min: 50,
                          max: 250,
                          enabled: _isEditing,
                          onChanged: _checkDirty,
                          validator: (value) => Validators.systolic(value),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: CompactIncrementFieldWidget(
                          label: l10n.pulse,
                          controller: _pulseController,
                          unit: 'bpm',
                          icon: Icons.favorite,
                          min: 30,
                          max: 200,
                          enabled: _isEditing,
                          onChanged: _checkDirty,
                          validator: (value) => Validators.pulse(value),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // LÍNEA 3: Diástole y espacio vacío
                  Row(
                    children: [
                      Expanded(
                        child: CompactIncrementFieldWidget(
                          label: l10n.diastole,
                          controller: _diastolicController,
                          unit: 'mmHg',
                          icon: Icons.arrow_downward,
                          min: 30,
                          max: 150,
                          enabled: _isEditing,
                          onChanged: _checkDirty,
                          validator: (value) => Validators.diastolic(value),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Expanded(child: SizedBox()),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // LÍNEA 4: Nota
                  Card(
                    margin: EdgeInsets.zero,
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.note, size: 16),
                              const SizedBox(width: 6),
                              Text(
                                _isEditing ? l10n.addNoteHint : l10n.note,
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
                            decoration: InputDecoration(
                              hintText:
                                  _isEditing ? l10n.addNoteHint : l10n.note,
                              border: const OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 8,
                              ),
                              isDense: true,
                            ),
                            maxLines: 3,
                            enabled: _isEditing,
                            maxLength: 200,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.gapMd),
                  // LÍNEA 5: Tensiómetro y Ubicación
                  Card(
                    margin: EdgeInsets.zero,
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextFormField(
                            controller: _bpMonitorModelController,
                            decoration: InputDecoration(
                              labelText:
                                  '${l10n.bloodPressureMonitorModel} (opcional)',
                              prefixIcon: const Icon(Icons.monitor_heart),
                              isDense: true,
                              enabled: _isEditing,
                            ),
                            style: const TextStyle(fontSize: 14),
                          ),
                          if (_isEditing)
                            Padding(
                              padding: const EdgeInsets.only(top: 16.0),
                              child: DropdownButtonFormField<String?>(
                                initialValue: _measurementLocation,
                                isExpanded: true,
                                decoration: InputDecoration(
                                  labelText:
                                      '${l10n.measurementLocation} (opcional)',
                                  prefixIcon:
                                      const Icon(Icons.accessibility_new),
                                  isDense: true,
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
                                style: const TextStyle(
                                    fontSize: 14, color: Colors.black),
                              ),
                            )
                          else
                            Padding(
                              padding: const EdgeInsets.only(top: 12.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: AppColors.textDisabled,
                                  ),
                                  borderRadius: BorderRadius.circular(
                                      AppSpacing.radiusSm),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12.0, vertical: 6.0),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.accessibility_new),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              l10n.measurementLocation,
                                              style: const TextStyle(
                                                color: AppColors.textDisabled,
                                                fontSize: 16,
                                              ),
                                            ),
                                            const SizedBox(
                                                height: AppSpacing.gapXs),
                                            Text(
                                              _measurementLocation == null
                                                  ? l10n.locationNotIndicated
                                                  : (_measurementLocation ==
                                                          'left_arm'
                                                      ? l10n.locationLeftArm
                                                      : (_measurementLocation ==
                                                              'left_wrist'
                                                          ? l10n
                                                              .locationLeftWrist
                                                          : (_measurementLocation ==
                                                                  'right_arm'
                                                              ? l10n
                                                                  .locationRightArm
                                                              : l10n
                                                                  .locationRightWrist))),
                                              style: const TextStyle(
                                                color: AppColors.textDisabled,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            )
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
