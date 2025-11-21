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

  bool _hasMedication = false;
  bool _enableNotifications = true;
  UserEntity? _existingUser;
  bool _isFirstUser = false;

  @override
  void initState() {
    super.initState();
    _checkIfFirstUser();
    _loadExistingUser();
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
          _hasMedication = _existingUser!.hasMedication;
          _medicationNameController.text = _existingUser!.medicationName ?? '';
          _enableNotifications = _existingUser!.enableNotifications;
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
    super.dispose();
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
        hasMedication: _hasMedication,
        medicationName:
            _hasMedication ? _medicationNameController.text.trim() : null,
        enableNotifications: _enableNotifications,
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
        ),
        body: BlocBuilder<UserBloc, UserState>(
          builder: (context, state) {
            if (state is UserLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
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
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _ageController,
                      decoration: InputDecoration(
                        labelText: '${l10n.userAge} (opcional)',
                        prefixIcon: const Icon(Icons.cake),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) => Validators.age(value),
                    ),
                    const SizedBox(height: 24),
                    SwitchListTile(
                      title: Text(l10n.hasMedication),
                      value: _hasMedication,
                      onChanged: (value) {
                        setState(() {
                          _hasMedication = value;
                          if (!value) {
                            _medicationNameController.clear();
                          }
                        });
                      },
                    ),
                    if (_hasMedication) ...[
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _medicationNameController,
                        decoration: InputDecoration(
                          labelText: l10n.medicationName,
                          prefixIcon: const Icon(Icons.medication),
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    SwitchListTile(
                      title: Text(l10n.enableNotifications),
                      value: _enableNotifications,
                      onChanged: (value) {
                        setState(() {
                          _enableNotifications = value;
                        });
                      },
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton.icon(
                      onPressed: _saveUser,
                      icon: const Icon(Icons.save),
                      label: Text(l10n.save),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                      ),
                    ),
                    if (isEditing) ...[
                      const SizedBox(height: 16),
                      OutlinedButton.icon(
                        onPressed: () => context.go(Routes.home),
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
            );
          },
        ),
      ),
    );
  }
}
