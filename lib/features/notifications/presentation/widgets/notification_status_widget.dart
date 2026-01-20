import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mta/features/notifications/presentation/bloc/notification_bloc.dart';
import 'package:mta/features/notifications/presentation/bloc/notification_event.dart';
import 'package:mta/features/notifications/presentation/bloc/notification_state.dart';

/// Widget que muestra el estado de las notificaciones y permite reprogramarlas
class NotificationStatusWidget extends StatefulWidget {
  final String userId;

  const NotificationStatusWidget({
    super.key,
    required this.userId,
  });

  @override
  State<NotificationStatusWidget> createState() =>
      _NotificationStatusWidgetState();
}

class _NotificationStatusWidgetState extends State<NotificationStatusWidget> {
  bool? _hasNotif;
  bool? _hasExact;

  @override
  void initState() {
    super.initState();
    // Iniciar verificación de permisos al cargar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationBloc>().add(const CheckPermissionsEvent());
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<NotificationBloc, NotificationState>(
      listener: (context, state) {
        if (state is PermissionStatusChecked) {
          setState(() {
            _hasNotif = state.hasNotificationPermission;
            _hasExact = state.hasExactAlarmPermission;
          });
        }
        if (state is UserNotificationsSet) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
            ),
          );
        } else if (state is NotificationError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: BlocBuilder<NotificationBloc, NotificationState>(
        builder: (context, state) {
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.notifications_active,
                            color: Theme.of(context).colorScheme.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Gestión de Alertas',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh, size: 18),
                        onPressed: () => context
                            .read<NotificationBloc>()
                            .add(const CheckPermissionsEvent()),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),

                  const Divider(height: 16),

                  // 🛡️ INDICADORES DE PERMISOS (Compactos)
                  Row(
                    children: [
                      Expanded(
                        child: _CompactPermissionBadge(
                          label: 'Notificaciones',
                          isGranted: _hasNotif,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _CompactPermissionBadge(
                          label: 'Alarmas Exactas',
                          isGranted: _hasExact,
                        ),
                      ),
                    ],
                  ),

                  if (_hasNotif == false || _hasExact == false)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: SizedBox(
                        width: double.infinity,
                        height: 34,
                        child: ElevatedButton.icon(
                          onPressed: () => context
                              .read<NotificationBloc>()
                              .add(const RequestPermissionsEvent()),
                          icon: const Icon(Icons.settings, size: 16),
                          label: const Text('CORREGIR PERMISOS',
                              style: TextStyle(
                                  fontSize: 11, fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange[800],
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                    ),

                  const SizedBox(height: 4),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CompactPermissionBadge extends StatelessWidget {
  final String label;
  final bool? isGranted;

  const _CompactPermissionBadge({required this.label, required this.isGranted});

  @override
  Widget build(BuildContext context) {
    final bool granted = isGranted ?? false;
    final bool loading = isGranted == null;

    final Color bgColor = loading
        ? Colors.grey[100]!
        : granted
            ? Colors.green[50]!
            : Colors.red[50]!;
    final Color borderColor = loading
        ? Colors.grey[300]!
        : granted
            ? Colors.green[200]!
            : Colors.red[200]!;
    final Color textColor = loading
        ? Colors.grey[600]!
        : granted
            ? Colors.green[800]!
            : Colors.red[800]!;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (loading)
            const SizedBox(
              width: 12,
              height: 12,
              child:
                  CircularProgressIndicator(strokeWidth: 2, color: Colors.grey),
            )
          else
            Icon(
              granted ? Icons.check_circle : Icons.cancel,
              color: granted ? Colors.green : Colors.red,
              size: 12,
            ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
