import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:mta/core/l10n/app_localizations.dart';
import 'package:mta/core/theme/theme.dart';
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
  final ScrollController _scrollController = ScrollController();
  static const double _itemHeight = 56.0; // Estimated height of MeasurementListItem

  @override
  void initState() {
    super.initState();
    _loadMeasurements();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _loadMeasurements() {
    final userState = context.read<UserBloc>().state;
    if (userState is UsersLoaded && userState.activeUser != null) {
      debugPrint(
          '${DateFormat('HH:mm:ss').format(DateTime.now())} -🔄 HomePage - Loading measurements for: ${userState.activeUser!.name}');
      context.read<MeasurementBloc>().add(
            LoadMeasurementsEvent(userState.activeUser!.id),
          );
    }
  }

  void _onUserChanged() {
    _loadMeasurements();
  }

  Future<void> _scrollToItem(String measurementId, List measurements) async {
    final index = measurements.indexWhere((m) => m.id == measurementId);
    if (index != -1) {
      // Pequeno delay para asegurar que la lista se ha renderizado si volvió de una operación
      await Future.delayed(const Duration(milliseconds: 300));
      if (_scrollController.hasClients) {
        final targetOffset = index * _itemHeight;
        _scrollController.animateTo(
          targetOffset,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOutCubic,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocListener<UserBloc, UserState>(
      listener: (context, state) {
        if (state is UsersLoaded && state.activeUser != null) {
          context.read<MeasurementBloc>().add(
                LoadMeasurementsEvent(state.activeUser!.id),
              );
        }
      },
      child: Scaffold(
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
                  case 'clear_measurements':
                    context.push(Routes.clearMeasurements);
                    break;
                  case 'restore_measurements':
                    context.push(Routes.restoreMeasurements);
                    break;
                  case 'schedules':
                    context.push(Routes.scheduleSettings);
                    break;
                  case 'help':
                    context.push(Routes.help);
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
                  value: 'clear_measurements',
                  child: Row(
                    children: [
                      const Icon(Icons.delete_sweep),
                      const SizedBox(width: AppSpacing.gapSm),
                      Text(l10n.clearMeasurementsTitle),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'restore_measurements',
                  child: Row(
                    children: [
                      const Icon(Icons.settings_backup_restore),
                      const SizedBox(width: AppSpacing.gapSm),
                      Text(l10n.restoreMeasurements),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'schedules',
                  child: Row(
                    children: [
                      const Icon(Icons.schedule),
                      const SizedBox(width: AppSpacing.gapSm),
                      Text(l10n.schedules),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'new_user',
                  child: Row(
                    children: [
                      const Icon(Icons.person_add),
                      const SizedBox(width: AppSpacing.gapSm),
                      Text(l10n.addUser),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'edit_user',
                  child: Row(
                    children: [
                      const Icon(Icons.edit),
                      const SizedBox(width: AppSpacing.gapSm),
                      Text(l10n.editUser),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'help',
                  child: Row(
                    children: [
                      const Icon(Icons.help_outline),
                      const SizedBox(width: AppSpacing.gapSm),
                      Text(l10n.help),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'delete_user',
                  child: Row(
                    children: [
                      const Icon(Icons.delete, color: AppColors.error),
                      const SizedBox(width: AppSpacing.gapSm),
                      Text(l10n.deleteUser,
                          style: const TextStyle(color: AppColors.error)),
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
                  backgroundColor: AppColors.error,
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
                        size: AppIcons.xxl,
                        color: AppColors.textDisabled,
                      ),
                      const SizedBox(height: AppSpacing.gapMd),
                      Text(
                        'No measurements yet',
                        style: AppTypography.h3.copyWith(
                          color: AppColors.textDisabled,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.gapSm),
                      Text(
                        'Tap the + button to add your first measurement',
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textDisabled,
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
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
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
                            style: AppTypography.bodySmall
                                .copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Expanded(
                          flex: 4,
                          child: Text(
                            l10n.day,
                            style: AppTypography.bodySmall
                                .copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Text(
                            l10n.measurementTime,
                            style: AppTypography.bodySmall
                                .copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Text(
                            l10n.systolic,
                            style: AppTypography.bodySmall
                                .copyWith(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Text(
                            l10n.diastolic,
                            style: AppTypography.bodySmall
                                .copyWith(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Text(
                            l10n.pulse,
                            style: AppTypography.bodySmall
                                .copyWith(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // List
                  Expanded(
                    child: ListView.builder(
                      controller: _scrollController,
                      itemCount: state.measurements.length,
                      itemBuilder: (context, index) {
                        final measurement = state.measurements[index];
                        return MeasurementListItem(
                          measurement: measurement,
                          onTap: () async {
                            final resultId = await context.push(
                              '${Routes.measurementDetail}?measurementId=${measurement.id}',
                            );
                            
                            if (resultId != null && resultId is String) {
                              _scrollToItem(resultId, state.measurements);
                            }
                          },
                        );
                      },
                    ),
                  ),
                ],
              );
            }

            return Center(
              child: Text(
                'Select a user to view measurements',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            );
          },
        ),
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
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }
}
