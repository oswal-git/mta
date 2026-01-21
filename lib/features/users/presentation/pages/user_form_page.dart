import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mta/core/l10n/app_localizations.dart';
import 'package:mta/core/utils/constants.dart';
import 'package:mta/core/utils/validators.dart';
import 'package:mta/features/users/domain/entities/user_entity.dart';
import 'package:mta/features/users/presentation/bloc/user_bloc.dart';
import 'package:mta/features/users/presentation/bloc/user_event.dart';
import 'package:mta/features/users/presentation/bloc/user_state.dart';
import 'package:mta/features/notifications/presentation/bloc/notification_bloc.dart';
import 'package:mta/features/notifications/presentation/bloc/notification_event.dart';
import 'package:mta/core/services/sound_service.dart';
import 'package:mta/core/theme/theme.dart';

class UserFormPage extends StatefulWidget {
  final String? userId;

  const UserFormPage({super.key, this.userId});

  @override
  State<UserFormPage> createState() => _UserFormPageState();
}

class _UserFormPageState extends State<UserFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _medicationNameController = TextEditingController();
  final _bpMonitorModelController = TextEditingController();

  bool _takeMedication = false;
  bool _enableNotifications = true;
  bool _notificationSoundEnabled = true;
  String? _notificationSoundUri;
  String? _notificationSoundName;
  UserEntity? _existingUser;
  bool _isFirstUser = false;
  String _languageCode = 'es';
  String? _measurementLocation;
  bool _isDirty = false;

  @override
  void initState() {
    super.initState();
    _checkIfFirstUser();
    _loadExistingUser();

    // Listeners required for dirty checking
    _nameController.addListener(_markDirty);
    _ageController.addListener(_markDirty);
    _medicationNameController.addListener(_markDirty);
    _bpMonitorModelController.addListener(_markDirty);
  }

  void _markDirty() {
    if (!_isDirty) setState(() => _isDirty = true);
  }

  void _checkIfFirstUser() {
    final userState = context.read<UserBloc>().state;
    if (userState is UsersLoaded) {
      _isFirstUser = userState.users.isEmpty;
    }
  }

  void _loadExistingUser() {
    if (widget.userId != null) {
      final userState = context.read<UserBloc>().state;
      if (userState is UsersLoaded) {
        try {
          _existingUser = userState.users.firstWhere(
            (u) => u.id == widget.userId,
          );

          _nameController.text = _existingUser!.name;
          _ageController.text = _existingUser!.age?.toString() ?? '';
          _takeMedication = _existingUser!.takeMedication;
          _medicationNameController.text = _existingUser!.medicationName ?? '';
          _notificationSoundEnabled = _existingUser!.notificationSoundEnabled;
          _notificationSoundUri = _existingUser!.notificationSoundUri;
          _languageCode = _existingUser!.languageCode;
          _bpMonitorModelController.text = _existingUser!.bpMonitorModel ?? '';
          _measurementLocation = _existingUser!.measurementLocation;
          if (_notificationSoundUri != null) {
            _loadSoundName(_notificationSoundUri!);
          }
          setState(() {});
        } catch (e) {
          // User not found
        }
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _medicationNameController.dispose();
    _bpMonitorModelController.dispose();
    _nameController.removeListener(_markDirty);
    _ageController.removeListener(_markDirty);
    _medicationNameController.removeListener(_markDirty);
    _bpMonitorModelController.removeListener(_markDirty);
    super.dispose();
  }

  Future<void> _loadSoundName(String uri) async {
    final sounds = await SoundService().getSystemRingtones();
    try {
      final sound = sounds.firstWhere((s) => s['uri'] == uri);
      if (mounted) {
        setState(() {
          _notificationSoundName = sound['title'];
        });
      }
    } catch (_) {
      // Si no se encuentra, dejar como null
    }
  }

  void _saveUser() {
    if (_formKey.currentState!.validate()) {
      final now = DateTime.now();
      final user = UserEntity(
        id: _existingUser?.id ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        age:
            _ageController.text.isEmpty ? null : int.parse(_ageController.text),
        takeMedication: _takeMedication,
        medicationName:
            _takeMedication ? _medicationNameController.text.trim() : null,
        enableNotifications: _enableNotifications,
        notificationSoundEnabled: _notificationSoundEnabled,
        notificationSoundUri: _notificationSoundUri,
        languageCode: _languageCode,
        bpMonitorModel: _bpMonitorModelController.text.trim().isEmpty
            ? null
            : _bpMonitorModelController.text.trim(),
        measurementLocation: _measurementLocation,
        createdAt: _existingUser?.createdAt ?? now,
        updatedAt: now,
      );

      if (_existingUser == null) {
        context.read<UserBloc>().add(CreateUserEvent(user));
      } else {
        context.read<UserBloc>().add(UpdateUserEvent(user));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isEditing = _existingUser != null;

    return BlocListener<UserBloc, UserState>(
        listener: (context, state) {
          if (state is UserOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );

            // Reprogramar notificaciones para aplicar cambios (sonido, etc)
            context
                .read<NotificationBloc>()
                .add(const RescheduleAllNotifications());

            // If it's the first user, go to schedule settings
            if (_isFirstUser) {
              context.go(Routes.scheduleSettings);
            } else {
              context.go(Routes.home);
            }
          } else if (state is UserError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(isEditing ? l10n.editUser : l10n.newUser),
            actions: [
              IconButton(
                icon: const Icon(Icons.save),
                onPressed: _saveUser,
              ),
            ],
          ),
          body: PopScope(
            canPop: !_isDirty,
            onPopInvokedWithResult: (didPop, result) async {
              if (didPop) return;

              final shouldPop = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(l10n.discardChanges),
                  content: Text(l10n.unsavedChangesMessage),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false), // Stay
                      child: Text(l10n.stay),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true), // Exit
                      child: Text(l10n.exit),
                    ),
                  ],
                ),
              );

              if (shouldPop == true && context.mounted) {
                Navigator.of(context).pop();
              }
            },
            child: BlocBuilder<UserBloc, UserState>(
              builder: (context, state) {
                if (state is UserLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                return SingleChildScrollView(
                  padding: AppSpacing.pAllMd,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            labelText: l10n.userName,
                            prefixIcon: const Icon(Icons.person),
                          ),
                          validator: (value) =>
                              Validators.required(value, l10n.userName),
                        ),
                        const SizedBox(height: AppSpacing.gapMd),
                        TextFormField(
                          controller: _ageController,
                          decoration: InputDecoration(
                            labelText: '${l10n.userAge} (opcional)',
                            prefixIcon: const Icon(Icons.cake),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) => Validators.age(value),
                        ),
                        const SizedBox(height: AppSpacing.gapMd),
                        DropdownButtonFormField<String>(
                          initialValue: _languageCode,
                          decoration: InputDecoration(
                            labelText: l10n.language,
                            prefixIcon: const Icon(Icons.language),
                          ),
                          items: [
                            DropdownMenuItem(
                              value: 'en',
                              child: Text(l10n.english),
                            ),
                            DropdownMenuItem(
                              value: 'es',
                              child: Text(l10n.spanish),
                            ),
                            DropdownMenuItem(
                              value: 'ca',
                              child: Text(l10n.valencian),
                            ),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _languageCode = value;
                                _markDirty();
                              });
                            }
                          },
                        ),
                        const SizedBox(height: AppSpacing.gapMd),
                        TextFormField(
                          controller: _bpMonitorModelController,
                          decoration: InputDecoration(
                            labelText:
                                '${l10n.bloodPressureMonitorModel} (opcional)',
                            prefixIcon: const Icon(Icons.monitor_heart),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.gapMd),
                        DropdownButtonFormField<String?>(
                          initialValue: _measurementLocation,
                          decoration: InputDecoration(
                            labelText: '${l10n.measurementLocation} (opcional)',
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
                              _markDirty();
                            });
                          },
                        ),
                        const SizedBox(height: AppSpacing.gapLg),
                        SwitchListTile(
                          title: Text(l10n.hasMeasuring),
                          value: _takeMedication,
                          onChanged: (value) {
                            _markDirty();
                            setState(() {
                              _takeMedication = value;
                              if (!value) {
                                _medicationNameController.clear();
                              }
                            });
                          },
                        ),
                        if (_takeMedication) ...[
                          const SizedBox(height: AppSpacing.gapMd),
                          TextFormField(
                            controller: _medicationNameController,
                            decoration: InputDecoration(
                              labelText: l10n.medicationName,
                              prefixIcon: const Icon(Icons.medication),
                            ),
                          ),
                        ],
                        const SizedBox(height: AppSpacing.gapLg),
                        SwitchListTile(
                          title: Text(l10n.enableNotifications),
                          value: _enableNotifications,
                          onChanged: (value) {
                            _markDirty();
                            setState(() {
                              _enableNotifications = value;
                            });
                          },
                        ),
                        const SizedBox(height: AppSpacing.gapMd),
                        Card(
                          child: Column(
                            children: [
                              SwitchListTile(
                                title: Text(l10n.notificationSounds),
                                subtitle: Text(l10n.notificationSoundsSubtitle),
                                value: _notificationSoundEnabled,
                                onChanged: (value) {
                                  _markDirty();
                                  setState(() {
                                    _notificationSoundEnabled = value;
                                    if (!value) {
                                      _notificationSoundUri = null;
                                    }
                                  });
                                },
                              ),
                              if (_notificationSoundEnabled) ...[
                                const Divider(height: 1),
                                ListTile(
                                  leading: const Icon(Icons.music_note),
                                  title: Text(l10n.selectSound),
                                  subtitle: Text(
                                    _notificationSoundUri == null
                                        ? l10n.defaultSound
                                        : (_notificationSoundName ??
                                            l10n.customSound),
                                  ),
                                  trailing: const Icon(Icons.arrow_forward_ios,
                                      size: AppIcons.sm),
                                  onTap: _showSoundPicker,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ));
  }

  Future<void> _showSoundPicker() async {
    final soundService = SoundService();
    // ignore: use_build_context_synchronously
    if (!mounted) return;
    final l10n = AppLocalizations.of(context);
    // Mostrar loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (c) => const Center(child: CircularProgressIndicator()),
    );

    final sounds = await soundService.getSystemRingtones();

    // Cerrar loading
    if (mounted) Navigator.pop(context);

    if (sounds.isEmpty && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.noSoundsFound)),
      );
      return;
    }

    if (!mounted) return;

    // Estado local para el diálogo
    String? tempSelectedUri = _notificationSoundUri;
    String? tempSelectedName = _notificationSoundName;

    await showDialog(
      context: context,
      barrierDismissible: false, // Obligar a usar botones
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text(l10n.selectSoundTitle),
              content: SizedBox(
                width: double.maxFinite,
                height: 300,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: sounds.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      final isSelected = tempSelectedUri == null;
                      return ListTile(
                        leading: const Icon(Icons.music_note_outlined),
                        title: Text(l10n.defaultOption),
                        trailing: isSelected
                            ? const Icon(Icons.check, color: AppColors.primary)
                            : null,
                        selected: isSelected,
                        onTap: () {
                          // Parar cualquier sonido previo
                          soundService.stopRingtone();
                          setStateDialog(() {
                            tempSelectedUri = null;
                            tempSelectedName = null;
                          });
                        },
                      );
                    }

                    final sound = sounds[index - 1];
                    final isSelected = tempSelectedUri == sound['uri'];

                    return ListTile(
                      leading: const Icon(Icons.music_note),
                      title: Text(sound['title'] ?? l10n.unknownOption),
                      trailing: isSelected
                          ? const Icon(Icons.check, color: AppColors.primary)
                          : null,
                      selected: isSelected,
                      onTap: () {
                        setStateDialog(() {
                          tempSelectedUri = sound['uri'];
                          tempSelectedName = sound['title'];
                        });
                        // Reproducir preview
                        if (sound['uri'] != null) {
                          soundService.playRingtone(sound['uri']!);
                        }
                      },
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    soundService.stopRingtone();
                    Navigator.pop(context); // Cancelar
                  },
                  child: Text(l10n.cancel),
                ),
                TextButton(
                  onPressed: () {
                    soundService.stopRingtone();
                    // Guardar selección
                    setState(() {
                      _notificationSoundUri = tempSelectedUri;
                      _notificationSoundName = tempSelectedName;
                      _markDirty();
                    });
                    Navigator.pop(context);
                  },
                  child: Text(l10n.accept),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
