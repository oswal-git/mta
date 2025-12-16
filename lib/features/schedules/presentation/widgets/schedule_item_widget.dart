import 'package:flutter/material.dart';
import 'package:mta/core/l10n/app_localizations.dart';
import 'package:mta/features/schedules/domain/entities/schedule_entity.dart';

class ScheduleItemWidget extends StatelessWidget {
  final ScheduleEntity schedule;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ScheduleItemWidget({
    super.key,
    required this.schedule,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(schedule.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.delete, color: Colors.white, size: 32),
            SizedBox(height: 4),
            Text(
              'Delete',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      confirmDismiss: (direction) async {
        final l10n = AppLocalizations.of(context);

        return await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: Text(l10n.deleteConfirmTitle),
            content: Text(l10n.deleteConfirmMessage),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: Text(l10n.cancel),
              ),
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: Text(l10n.delete),
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) {
        onDelete();
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: InkWell(
          onTap: onEdit,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Icono de alarma
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: schedule.isEnabled
                        ? Theme.of(context).colorScheme.primaryContainer
                        : Colors.grey[300],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.alarm,
                    color: schedule.isEnabled
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey[600],
                  ),
                ),
                const SizedBox(width: 16),

                // Información del horario
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Hora
                      Text(
                        schedule.formattedTime,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: schedule.isEnabled ? null : Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),

                      // Alarma
                      Text(
                        schedule.isEnabled
                            ? 'Alarm 5 min before (${_getAlarmTime(schedule)})'
                            : 'Disabled',
                        style: TextStyle(
                          fontSize: 12,
                          color: schedule.isEnabled
                              ? Colors.green[700]
                              : Colors.grey,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      const SizedBox(height: 2),

                      // Notificación
                      Row(
                        children: [
                          Icon(
                            schedule.isEnabled
                                ? Icons.notifications_active
                                : Icons.notifications_off,
                            size: 14,
                            color:
                                schedule.isEnabled ? Colors.green : Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              schedule.isEnabled
                                  ? 'Notification enabled'
                                  : 'Notification disabled',
                              style: TextStyle(
                                fontSize: 11,
                                color: schedule.isEnabled
                                    ? Colors.green[700]
                                    : Colors.grey,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Switch compacto a la derecha
                Transform.scale(
                  scale: 0.85,
                  child: Switch(
                    value: schedule.isEnabled,
                    onChanged: (_) => onToggle(),
                    activeThumbColor: Theme.of(context).colorScheme.primary,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getAlarmTime(ScheduleEntity schedule) {
    final alarmTime = schedule.alarmDateTime;
    final hour = alarmTime.hour.toString().padLeft(2, '0');
    final minute = alarmTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
