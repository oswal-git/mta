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
    final l10n = AppLocalizations.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
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
        title: Text(
          schedule.formattedTime,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: schedule.isEnabled ? null : Colors.grey,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              schedule.isEnabled
                  ? 'Alarm 5 min before (${_getAlarmTime(schedule)})'
                  : 'Disabled',
              style: TextStyle(
                fontSize: 12,
                color: schedule.isEnabled ? Colors.green[700] : Colors.grey,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  schedule.isEnabled
                      ? Icons.notifications_active
                      : Icons.notifications_off,
                  size: 14,
                  color: schedule.isEnabled ? Colors.green : Colors.grey,
                ),
                const SizedBox(width: 4),
                Text(
                  schedule.isEnabled
                      ? 'Notification enabled'
                      : 'Notification disabled',
                  style: TextStyle(
                    fontSize: 11,
                    color: schedule.isEnabled ? Colors.green[700] : Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Switch(
              value: schedule.isEnabled,
              onChanged: (_) => onToggle(),
              activeThumbColor: Theme.of(context).colorScheme.primary,
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) {
                switch (value) {
                  case 'edit':
                    onEdit();
                    break;
                  case 'delete':
                    onDelete();
                    break;
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      const Icon(Icons.edit),
                      const SizedBox(width: 8),
                      Text(l10n.edit),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      const Icon(Icons.delete, color: Colors.red),
                      const SizedBox(width: 8),
                      Text(
                        l10n.delete,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
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
