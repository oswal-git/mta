import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:mta/core/l10n/app_localizations.dart';
import 'package:mta/core/theme/theme.dart';
import 'package:mta/features/notifications/domain/entities/notification_entity.dart';
import 'package:mta/features/notifications/presentation/bloc/notification_bloc.dart';
import 'package:mta/features/notifications/presentation/bloc/notification_event.dart';

/// Pantalla que se muestra cuando suena una notificacion
class NotificationRingPage extends StatefulWidget {
  final NotificationEntity notification;

  const NotificationRingPage({
    super.key,
    required this.notification,
  });

  @override
  State<NotificationRingPage> createState() => _NotificationRingPageState();
}

class _NotificationRingPageState extends State<NotificationRingPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Configurar animaciones
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(
      begin: 0.9,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.7,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _dismissNotification() {
    context
        .read<NotificationBloc>()
        .add(StopNotification(widget.notification.id));
    Navigator.of(context).pop();
  }

  void _markAsTaken() {
    context.read<NotificationBloc>().add(MarkAsTaken(
          scheduleId: widget.notification.scheduleId,
          timestamp: DateTime.now(),
          userId: widget.notification.userId,
        ));
    Navigator.of(context).pop();
  }

  void _snoozeNotification(Duration duration) {
    final l10n = AppLocalizations.of(context);
    context.read<NotificationBloc>().add(
          SnoozeNotification(
            notificationId: widget.notification.id,
            snoozeDuration: duration,
          ),
        );
    Navigator.of(context).pop();

    // Mostrar mensaje de confirmación
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          l10n.notificationSnoozedMessage(duration.inMinutes),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final timeFormat = DateFormat.Hm();
    final scheduledTime =
        timeFormat.format(widget.notification.notificationTime);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.errorContainer,
      body: SafeArea(
        child: Padding(
          padding: AppSpacing.pAllXl,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Icono animado
              AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Opacity(
                      opacity: _fadeAnimation.value,
                      child: Icon(
                        Icons.notifications_active,
                        size: AppIcons.jumbo,
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: AppSpacing.gapXl),

              // Nombre del usuario destacado
              Container(
                padding: AppSpacing.pAllMd,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(10),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      widget.notification.userName.toUpperCase(),
                      style:
                          Theme.of(context).textTheme.headlineLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.timeOfMeasurement,
                      style: Theme.of(context).textTheme.titleLarge,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.gapLg),

              // Información de la medición
              Card(
                elevation: 2,
                child: Padding(
                  padding: AppSpacing.pAllMd,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoRow(
                        context,
                        Icons.schedule,
                        l10n.scheduledTimeLabel,
                        scheduledTime,
                      ),
                      if (widget.notification.label != null &&
                          widget.notification.label!.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.gapMd),
                        _buildInfoRow(
                          context,
                          Icons.label,
                          l10n.reminderLabel,
                          widget.notification.label!,
                        ),
                      ],
                      if (widget.notification.medication != null &&
                          widget.notification.medication!.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.gapMd),
                        _buildInfoRow(
                          context,
                          Icons.heat_pump_rounded,
                          l10n.measurementLabel,
                          widget.notification.medication!,
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.gapXl),

              // Botón principal: Marcar como tomada
              ElevatedButton.icon(
                onPressed: () {
                  _markAsTaken();
                },
                icon: const Icon(Icons.check_circle, size: AppIcons.actionIcon),
                label: Text(
                  l10n.markAsTaken,
                  style: AppTypography.h3,
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.gapMd),

              // Opciones de snooze
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () =>
                          _snoozeNotification(const Duration(minutes: 5)),
                      icon: const Icon(Icons.snooze),
                      label: Text('5 ${l10n.minutesShort}'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppSpacing.radiusMd),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.gapMd),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () =>
                          _snoozeNotification(const Duration(minutes: 10)),
                      icon: const Icon(Icons.snooze),
                      label: Text('10 ${l10n.minutesShort}'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppSpacing.radiusMd),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.gapMd),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () =>
                          _snoozeNotification(const Duration(minutes: 15)),
                      icon: const Icon(Icons.snooze),
                      label: Text('15 ${l10n.minutesShort}'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppSpacing.radiusMd),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.gapMd),

              // Botón de cancelar
              TextButton.icon(
                onPressed: _dismissNotification,
                icon: const Icon(Icons.close),
                label: Text(l10n.cancelNotification),
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.error,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          size: AppIcons.navIcon,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(width: AppSpacing.gapMd),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
