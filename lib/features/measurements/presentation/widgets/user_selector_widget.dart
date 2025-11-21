// ===== lib/features/measurements/presentation/widgets/user_selector_widget.dart =====
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mta/features/users/domain/entities/user_entity.dart';
import 'package:mta/features/users/presentation/bloc/user_bloc.dart';
import 'package:mta/features/users/presentation/bloc/user_event.dart';

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
      onChanged: (String? newUserId) {
        if (newUserId != null && newUserId != activeUser?.id) {
          context.read<UserBloc>().add(SetActiveUserEvent(newUserId));
          onUserChanged();
        }
      },
    );
  }
}
