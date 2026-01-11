import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mta/core/l10n/app_localizations.dart';
import 'package:mta/core/utils/constants.dart';
import 'package:mta/features/notifications/presentation/bloc/notification_bloc.dart';
import 'package:mta/features/notifications/presentation/bloc/notification_event.dart';
import 'package:mta/features/notifications/presentation/widgets/notification_status_widget.dart';
import 'package:mta/features/schedules/domain/entities/schedule_entity.dart';
import 'package:mta/features/schedules/presentation/bloc/schedule_bloc.dart';
import 'package:mta/features/schedules/presentation/bloc/schedule_event.dart';
import 'package:mta/features/schedules/presentation/bloc/schedule_state.dart';
import 'package:mta/features/schedules/presentation/widgets/schedule_item_widget.dart';
import 'package:mta/features/users/presentation/bloc/user_bloc.dart';
import 'package:mta/features/users/presentation/bloc/user_state.dart';

class ScheduleSettingsPage extends StatefulWidget {
  const ScheduleSettingsPage({super.key});

  @override
  State<ScheduleSettingsPage> createState() => _ScheduleSettingsPageState();
}

class _ScheduleSettingsPageState extends State<ScheduleSettingsPage> {
  String? _userId;

  @override
  void initState() {
    super.initState();
    _loadSchedules();
  }

  void _loadSchedules() {
    final userState = context.read<UserBloc>().state;
    if (userState is UsersLoaded && userState.activeUser != null) {
      _userId = userState.activeUser!.id;
      context.read<ScheduleBloc>().add(LoadSchedulesEvent(_userId!));
    }
  }

  // ✅ Método para reprogramar notificaciones automáticamente
  void _reprogramNotificationsAutomatically() {
    if (_userId != null) {
      context
          .read<NotificationBloc>()
          .add(ScheduleNotificationsForUser(_userId!));
    }
  }

  Future<void> _showAddScheduleDialog() async {
    final l10n = AppLocalizations.of(context);

    TimeOfDay? selectedTime = TimeOfDay.now();

    final result = await showDialog<TimeOfDay>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.addSchedule),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.access_time),
              title: Text(l10n.scheduleTime),
              subtitle: Text(selectedTime.format(dialogContext)),
              onTap: () async {
                final time = await showTimePicker(
                  context: dialogContext,
                  initialTime: selectedTime,
                  builder: (context, child) {
                    return MediaQuery(
                      data: MediaQuery.of(context).copyWith(
                        alwaysUse24HourFormat: true,
                      ),
                      child: child!,
                    );
                  },
                );
                if (time != null) {
                  if (mounted && dialogContext.mounted) {
                    Navigator.of(dialogContext).pop(time);
                  }
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop(selectedTime);
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    );

    if (result != null && _userId != null) {
      final now = DateTime.now();
      final schedule = ScheduleEntity(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: _userId!,
        hour: result.hour,
        minute: result.minute,
        isEnabled: true,
        createdAt: now,
        updatedAt: now,
      );

      if (mounted) {
        context.read<ScheduleBloc>().add(CreateScheduleEvent(schedule));
        // ✅ Reprogramar notificaciones automáticamente después de crear
        _reprogramNotificationsAutomatically();
      }
    }
  }

  Future<void> _showEditScheduleDialog(ScheduleEntity schedule) async {
    final l10n = AppLocalizations.of(context);

    TimeOfDay selectedTime =
        TimeOfDay(hour: schedule.hour, minute: schedule.minute);

    final result = await showDialog<TimeOfDay>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.editSchedule),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.access_time),
              title: Text(l10n.scheduleTime),
              subtitle: Text(selectedTime.format(dialogContext)),
              onTap: () async {
                final time = await showTimePicker(
                  context: dialogContext,
                  initialTime: selectedTime,
                  builder: (context, child) {
                    return MediaQuery(
                      data: MediaQuery.of(context).copyWith(
                        alwaysUse24HourFormat: true,
                      ),
                      child: child!,
                    );
                  },
                );
                if (time != null) {
                  if (mounted && dialogContext.mounted) {
                    Navigator.of(dialogContext).pop(time);
                  }
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop(selectedTime);
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    );

    if (result != null && _userId != null) {
      final updatedSchedule = schedule.copyWith(
        hour: result.hour,
        minute: result.minute,
        updatedAt: DateTime.now(),
      );

      if (mounted) {
        context.read<ScheduleBloc>().add(UpdateScheduleEvent(updatedSchedule));
        // ✅ Reprogramar notificaciones automáticamente después de editar
        _reprogramNotificationsAutomatically();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocConsumer<ScheduleBloc, ScheduleState>(
      listener: (context, state) {
        if (state is ScheduleOperationSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
          if (state.userId != null) {
            context.read<ScheduleBloc>().add(
                  LoadSchedulesEvent(state.userId!),
                );
          }
        } else if (state is ScheduleError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.schedules),
            actions: [
              IconButton(
                icon: const Icon(Icons.check),
                tooltip: 'Done',
                onPressed: () => context.go(Routes.home),
              ),
            ],
          ),
          body: Builder(
            builder: (context) {
              if (state is ScheduleLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is SchedulesLoaded) {
                return Column(
                  children: [
                    // ✅ WIDGET DE NOTIFICATIONES AQUÍ (arriba de todo)
                    if (_userId != null)
                      NotificationStatusWidget(userId: _userId!),

                    // Banner de límite máximo
                    if (state.schedules.length >= AppConstants.maxSchedules)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        color: Colors.orange[100],
                        child: Row(
                          children: [
                            Icon(Icons.info, color: Colors.orange[900]),
                            const SizedBox(width: 12),
                            Flexible(
                              child: Text(
                                l10n.maxSchedulesReached,
                                style: TextStyle(
                                  color: Colors.orange[900],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    Expanded(
                      child: state.schedules.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.schedule,
                                    size: 100,
                                    color: Colors.grey[300],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No schedules yet',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(
                                          color: Colors.grey,
                                        ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Tap the + button to add your first schedule',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: Colors.grey,
                                        ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 24),
                                  Text(
                                    'Maximum ${AppConstants.maxSchedules} schedules allowed',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          color: Colors.grey[600],
                                        ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: state.schedules.length,
                              itemBuilder: (context, index) {
                                final schedule = state.schedules[index];
                                return ScheduleItemWidget(
                                  schedule: schedule,
                                  onToggle: () {
                                    context.read<ScheduleBloc>().add(
                                          ToggleScheduleEvent(schedule),
                                        );
                                    // ✅ Reprogramar notificaciones al activar/desactivar
                                    _reprogramNotificationsAutomatically();
                                  },
                                  onEdit: () =>
                                      _showEditScheduleDialog(schedule),
                                  onDelete: () {
                                    context.read<ScheduleBloc>().add(
                                          DeleteScheduleEvent(
                                              schedule.id, schedule.userId),
                                        );
                                    // ✅ Reprogramar notificaciones al eliminar
                                    _reprogramNotificationsAutomatically();
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
                  'No user selected',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              );
            },
          ),
          floatingActionButton: BlocBuilder<ScheduleBloc, ScheduleState>(
            builder: (context, state) {
              final canAdd = state is SchedulesLoaded &&
                  state.schedules.length < AppConstants.maxSchedules;

              return FloatingActionButton.extended(
                onPressed: canAdd ? _showAddScheduleDialog : null,
                backgroundColor: canAdd ? null : Colors.grey,
                icon: const Icon(Icons.add),
                label: Text(l10n.addSchedule),
              );
            },
          ),
        );
      },
    );
  }
}
