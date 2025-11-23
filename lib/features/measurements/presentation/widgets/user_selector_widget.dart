// ===== lib/features/measurements/presentation/widgets/user_selector_widget.dart =====
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:mta/core/utils/constants.dart';
import 'package:mta/features/schedules/presentation/bloc/schedule_bloc.dart';
import 'package:mta/features/schedules/presentation/bloc/schedule_event.dart';
import 'package:mta/features/schedules/presentation/bloc/schedule_state.dart';
import 'package:mta/features/users/domain/entities/user_entity.dart';
import 'package:mta/features/users/presentation/bloc/user_bloc.dart';
import 'package:mta/features/users/presentation/bloc/user_event.dart';
import 'package:mta/features/users/presentation/bloc/user_state.dart';

class UserSelectorWidget extends StatelessWidget {
  final List<UserEntity> users;
  final UserEntity? activeUser;
  final VoidCallback onUserChanged;

  const UserSelectorWidget({
    super.key,
    required this.users,
    required this.activeUser,
    required this.onUserChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (users.isEmpty) {
      return const Text('No users');
    }

    if (users.length == 1) {
      return Text(
        activeUser?.name ?? users.first.name,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      );
    }

    return DropdownButton<String>(
      value: activeUser?.id ?? users.first.id,
      underline: Container(),
      dropdownColor: Theme.of(context).colorScheme.surface,
      icon: const Icon(Icons.arrow_drop_down),
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
      items: users.map((user) {
        return DropdownMenuItem<String>(
          value: user.id,
          child: Row(
            children: [
              Icon(
                Icons.person,
                size: 20,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                user.name,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
        );
      }).toList(),
      onChanged: (String? newUserId) async {
        if (newUserId != null && newUserId != activeUser?.id) {
          debugPrint(
              '${DateFormat('HH:mm:ss').format(DateTime.now())} -🔄 UserSelector - Changing user to: $newUserId');

          // Cambiar usuario activo
          context.read<UserBloc>().add(SetActiveUserEvent(newUserId));

          // Esperar un momento a que se actualice
          await Future.delayed(const Duration(milliseconds: 300));

          if (!context.mounted) return;

          // Obtener el nuevo usuario
          final userState = context.read<UserBloc>().state;
          if (userState is UsersLoaded && userState.activeUser != null) {
            debugPrint(
                '${DateFormat('HH:mm:ss').format(DateTime.now())} -✅ User changed to: ${userState.activeUser!.name}');

            // Cargar schedules del nuevo usuario
            final scheduleBloc = context.read<ScheduleBloc>();
            scheduleBloc.add(LoadSchedulesEvent(userState.activeUser!.id));

            // Esperar a que se carguen los schedules
            await Future.delayed(const Duration(milliseconds: 300));

            if (!context.mounted) return;

            final scheduleState = scheduleBloc.state;
            debugPrint(
                '${DateFormat('HH:mm:ss').format(DateTime.now())} -📅 Schedule state: ${scheduleState.runtimeType}');

            if (scheduleState is SchedulesLoaded) {
              debugPrint(
                  '${DateFormat('HH:mm:ss').format(DateTime.now())} -📅 Schedules count: ${scheduleState.schedules.length}');
              if (scheduleState.schedules.isEmpty) {
                // No tiene horarios, ir a configuración
                debugPrint(
                    '${DateFormat('HH:mm:ss').format(DateTime.now())} -➡️ Navigating to ScheduleSettings (no schedules)');
                context.go(Routes.scheduleSettings);
              } else {
                // Tiene horarios, recargar mediciones
                debugPrint(
                    '${DateFormat('HH:mm:ss').format(DateTime.now())} -🔄 User has schedules, reloading measurements');
                onUserChanged();
              }
            } else {
              // Si no se pudieron cargar schedules, recargar mediciones
              debugPrint(
                  '${DateFormat('HH:mm:ss').format(DateTime.now())} -⚠️ Could not load schedules, reloading measurements');
              onUserChanged();
            }
          }
        }
      },
    );
  }
}
