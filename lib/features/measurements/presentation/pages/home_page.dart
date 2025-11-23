import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:mta/core/l10n/app_localizations.dart';
import 'package:mta/core/utils/constants.dart';
import 'package:mta/features/measurements/presentation/bloc/measurement_bloc.dart';
import 'package:mta/features/measurements/presentation/bloc/measurement_event.dart';
import 'package:mta/features/measurements/presentation/bloc/measurement_state.dart';
import 'package:mta/features/measurements/presentation/widgets/measurement_list_item.dart';
import 'package:mta/features/measurements/presentation/widgets/user_selector_widget.dart';
import 'package:mta/features/users/presentation/bloc/user_bloc.dart';
import 'package:mta/features/users/presentation/bloc/user_event.dart';
import 'package:mta/features/users/presentation/bloc/user_state.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    _loadMeasurements();
  }

  void _loadMeasurements() {
    final userState = context.read<UserBloc>().state;
    if (userState is UsersLoaded && userState.activeUser != null) {
      debugPrint(
          '${DateFormat('HH:mm:ss').format(DateTime.now())} -🔄 HomePage - Loading measurements for: ${userState.activeUser!.name}');
      context.read<MeasurementBloc>().add(
            LoadMeasurementsEvent(userState.activeUser!.id),
          );
    } else {
      debugPrint(
          '${DateFormat('HH:mm:ss').format(DateTime.now())} -⚠️ HomePage - No active user, cannot load measurements');
    }
  }

  void _onUserChanged() {
    debugPrint(
        '${DateFormat('HH:mm:ss').format(DateTime.now())} -🔄 HomePage - User changed, reloading measurements');
    _loadMeasurements();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: BlocBuilder<UserBloc, UserState>(
          builder: (context, state) {
            if (state is UsersLoaded && state.users.isNotEmpty) {
              return UserSelectorWidget(
                users: state.users,
                activeUser: state.activeUser,
                onUserChanged: _onUserChanged,
              );
            }
            return Text(l10n.appTitle);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: l10n.addMeasurement,
            onPressed: () {
              final userState = context.read<UserBloc>().state;
              if (userState is UsersLoaded && userState.activeUser != null) {
                context.push(Routes.measurementForm);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.errorNoUser)),
                );
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.file_download),
            tooltip: l10n.export,
            onPressed: () => context.push(Routes.export),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              switch (value) {
                case 'schedules':
                  context.push(Routes.scheduleSettings);
                  break;
                case 'new_user':
                  context.push(Routes.userForm);
                  break;
                case 'edit_user':
                  final userState = context.read<UserBloc>().state;
                  if (userState is UsersLoaded &&
                      userState.activeUser != null) {
                    context.push(
                      '${Routes.userForm}?userId=${userState.activeUser!.id}',
                    );
                  }
                  break;
                case 'delete_user':
                  _showDeleteUserDialog(context);
                  break;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'schedules',
                child: Row(
                  children: [
                    const Icon(Icons.schedule),
                    const SizedBox(width: 8),
                    Text(l10n.schedules),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'new_user',
                child: Row(
                  children: [
                    const Icon(Icons.person_add),
                    const SizedBox(width: 8),
                    Text(l10n.addUser),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'edit_user',
                child: Row(
                  children: [
                    const Icon(Icons.edit),
                    const SizedBox(width: 8),
                    Text(l10n.editUser),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete_user',
                child: Row(
                  children: [
                    const Icon(Icons.delete, color: Colors.red),
                    const SizedBox(width: 8),
                    Text(l10n.deleteUser,
                        style: const TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: BlocConsumer<MeasurementBloc, MeasurementState>(
        listener: (context, state) {
          if (state is MeasurementOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
            if (state.userId != null) {
              context.read<MeasurementBloc>().add(
                    LoadMeasurementsEvent(state.userId!),
                  );
            }
          } else if (state is MeasurementError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is MeasurementLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is MeasurementsLoaded) {
            if (state.measurements.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.favorite_border,
                      size: 100,
                      color: Colors.grey[300],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No measurements yet',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.grey,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap the + button to add your first measurement',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }

            return Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 5,
                        child: Text(
                          l10n.date,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Expanded(
                        flex: 4,
                        child: Text(
                          l10n.day,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                          l10n.measurementTime,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                          l10n.systolic,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                          l10n.diastolic,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                          l10n.pulse,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
                // List
                Expanded(
                  child: ListView.builder(
                    itemCount: state.measurements.length,
                    itemBuilder: (context, index) {
                      final measurement = state.measurements[index];
                      return MeasurementListItem(
                        measurement: measurement,
                        onTap: () {
                          context.push(
                            '${Routes.measurementDetail}?measurementId=${measurement.id}',
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          }

          // Initial state or error
          return Center(
            child: Text(
              'Select a user to view measurements',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          );
        },
      ),
    );
  }

  void _showDeleteUserDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final userState = context.read<UserBloc>().state;

    if (userState is! UsersLoaded || userState.activeUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.errorNoUser)),
      );
      return;
    }

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
              context.read<UserBloc>().add(
                    DeleteUserEvent(userState.activeUser!.id),
                  );
              Navigator.of(dialogContext).pop();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }
}
