import 'package:flutter/material.dart';
import 'package:mta/core/l10n/app_localizations.dart';
import 'package:mta/features/schedules/domain/entities/schedule_entity.dart';
import 'package:mta/core/theme/theme.dart';

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
        padding: const EdgeInsets.only(right: AppSpacing.lg),
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.delete, color: AppColors.white, size: AppIcons.lg),
            const SizedBox(height: 4),
            Text(
              'Delete',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.white,
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
                style: TextButton.styleFrom(foregroundColor: AppColors.error),
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
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        child: InkWell(
          onTap: onEdit,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          child: Padding(
            padding: AppSpacing.pAllMd,
            child: Row(
              children: [
                // Icono de notificacion
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: schedule.isEnabled
                        ? Theme.of(context).colorScheme.primaryContainer
                        : AppColors.border,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  ),
                  child: Icon(
                    Icons.notifications_active,
                    size: AppIcons.lg,
                    color: schedule.isEnabled
                        ? Theme.of(context).colorScheme.primary
                        : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: AppSpacing.gapMd),

                // Información del horario
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Hora
                      Text(
                        schedule.formattedTime,
                        style: AppTypography.h1.copyWith(
                          color: schedule.isEnabled
                              ? null
                              : AppColors.textDisabled,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.gapXs),

                      // Notificación
                      Text(
                        schedule.isEnabled
                            ? 'Notification 5 min before (${_getNotificationTime(schedule)})'
                            : 'Disabled',
                        style: AppTypography.caption.copyWith(
                          color: schedule.isEnabled
                              ? AppColors.success
                              : AppColors.textDisabled,
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
                            size: AppIcons.tiny,
                            color:
                                schedule.isEnabled ? Colors.green : Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              schedule.isEnabled
                                  ? 'Notification enabled'
                                  : 'Notification disabled',
                              style: AppTypography.small.copyWith(
                                color: schedule.isEnabled
                                    ? AppColors.success
                                    : AppColors.textDisabled,
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

  String _getNotificationTime(ScheduleEntity schedule) {
    final notificationTime = schedule.notificationDateTime;
    final hour = notificationTime.hour.toString().padLeft(2, '0');
    final minute = notificationTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
