import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
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

  void _snoozeNotification(Duration duration) {
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
          'Notificación pospuesta por ${duration.inMinutes} minutos',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat.Hm();
    final scheduledTime =
        timeFormat.format(widget.notification.notificationTime);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.errorContainer,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
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
                        size: 120,
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 32),

              // Nombre del usuario destacado
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
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
                      'Hora de tomar medición',
                      style: Theme.of(context).textTheme.titleLarge,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Información de la toma
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoRow(
                        context,
                        Icons.schedule,
                        'Hora programada',
                        scheduledTime,
                      ),
                      if (widget.notification.label != null &&
                          widget.notification.label!.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        _buildInfoRow(
                          context,
                          Icons.label,
                          'Recordatorio',
                          widget.notification.label!,
                        ),
                      ],
                      if (widget.notification.medication != null &&
                          widget.notification.medication!.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        _buildInfoRow(
                          context,
                          Icons.heat_pump_rounded,
                          'Medición',
                          widget.notification.medication!,
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Botón principal: Marcar como tomada
              ElevatedButton.icon(
                onPressed: () {
                  // Aquí se podría registrar automáticamente la medición
                  _dismissNotification();
                },
                icon: const Icon(Icons.check_circle, size: 28),
                label: const Text(
                  'Marcar como tomada',
                  style: TextStyle(fontSize: 18),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Opciones de snooze
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () =>
                          _snoozeNotification(const Duration(minutes: 5)),
                      icon: const Icon(Icons.snooze),
                      label: const Text('5 min'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () =>
                          _snoozeNotification(const Duration(minutes: 10)),
                      icon: const Icon(Icons.snooze),
                      label: const Text('10 min'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () =>
                          _snoozeNotification(const Duration(minutes: 15)),
                      icon: const Icon(Icons.snooze),
                      label: const Text('15 min'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Botón de cancelar
              TextButton.icon(
                onPressed: _dismissNotification,
                icon: const Icon(Icons.close),
                label: const Text('Cancelar notificación'),
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
          size: 20,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(width: 12),
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
