import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mta/features/notifications/presentation/bloc/notification_bloc.dart';
import 'package:mta/features/notifications/presentation/bloc/notification_event.dart';
import 'package:mta/features/notifications/presentation/bloc/notification_state.dart';
import 'package:mta/core/theme/theme.dart';

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
              backgroundColor: AppColors.success,
            ),
          );
        } else if (state is NotificationError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      child: BlocBuilder<NotificationBloc, NotificationState>(
        builder: (context, state) {
          return Card(
            margin: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            elevation: 2,
            child: Padding(
              padding: AppSpacing.pAllMd,
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
                          const SizedBox(width: AppSpacing.gapSm),
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
                        icon: const Icon(Icons.refresh,
                            size: AppIcons.smallMedium),
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
                      const SizedBox(width: AppSpacing.gapSm),
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
                          icon: const Icon(Icons.settings, size: AppIcons.sm),
                          label: const Text('CORREGIR PERMISOS',
                              style: AppTypography.small),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.orange,
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
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.xs,
        horizontal: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
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
              color: granted ? AppColors.success : AppColors.error,
              size: 12,
            ),
          const SizedBox(width: AppSpacing.gapXs),
          Text(
            label,
            style: AppTypography.small.copyWith(
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
