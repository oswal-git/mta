// ===== lib/features/users/presentation/pages/splash_page.dart =====
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:mta/core/utils/constants.dart';
import 'package:mta/core/theme/theme.dart';
import 'package:mta/features/schedules/presentation/bloc/schedule_bloc.dart';
import 'package:mta/features/schedules/presentation/bloc/schedule_event.dart';
import 'package:mta/features/schedules/presentation/bloc/schedule_state.dart';
import 'package:mta/features/users/presentation/bloc/user_bloc.dart';
import 'package:mta/features/users/presentation/bloc/user_event.dart';
import 'package:mta/features/users/presentation/bloc/user_state.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  bool _hasNavigated = false;
  bool _minTimeElapsed = false;

  @override
  void initState() {
    super.initState();
    debugPrint(
        '${DateFormat('HH:mm:ss').format(DateTime.now())} -⏳ SplashPage - initState');

    // Cargar usuarios explícitamente
    context.read<UserBloc>().add(LoadUsersEvent());

    // Esperar tiempo mínimo de splash
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _minTimeElapsed = true;
        });
        _tryNavigate();
      }
    });
  }

  void _tryNavigate() {
    if (_hasNavigated || !_minTimeElapsed || !mounted) return;

    final userState = context.read<UserBloc>().state;
    debugPrint(
        '🔍 SplashPage - Trying to navigate, state: ${userState.runtimeType}');

    if (userState is UsersLoaded) {
      _navigateBasedOnUserState(userState);
    }
  }

  Future<void> _navigateBasedOnUserState(UsersLoaded userState) async {
    if (_hasNavigated || !mounted) return;

    setState(() {
      _hasNavigated = true;
    });

    debugPrint(
        '${DateFormat('HH:mm:ss').format(DateTime.now())} -👥 Users count: ${userState.users.length}');
    debugPrint(
        '${DateFormat('HH:mm:ss').format(DateTime.now())} -👤 Active user: ${userState.activeUser?.name ?? "none"}');

    if (userState.users.isEmpty) {
      debugPrint(
          '${DateFormat('HH:mm:ss').format(DateTime.now())} -➡️ Going to UserForm (no users)');
      context.go(Routes.userForm);
    } else if (userState.activeUser != null) {
      // Hay usuario activo, verificar horarios
      debugPrint(
          '${DateFormat('HH:mm:ss').format(DateTime.now())} -📋 Checking schedules for: ${userState.activeUser!.name}');
      final scheduleBloc = context.read<ScheduleBloc>();
      scheduleBloc.add(LoadSchedulesEvent(userState.activeUser!.id));

      await Future.delayed(const Duration(milliseconds: 500));

      if (!mounted) return;

      final scheduleState = scheduleBloc.state;
      debugPrint(
          '${DateFormat('HH:mm:ss').format(DateTime.now())} -📅 Schedule State: ${scheduleState.runtimeType}');

      if (scheduleState is SchedulesLoaded) {
        debugPrint(
            '${DateFormat('HH:mm:ss').format(DateTime.now())} -📅 Schedules count: ${scheduleState.schedules.length}');
        if (scheduleState.schedules.isEmpty) {
          debugPrint(
              '${DateFormat('HH:mm:ss').format(DateTime.now())} -➡️ Going to ScheduleSettings (no schedules)');
          context.go(Routes.scheduleSettings);
        } else {
          debugPrint(
              '${DateFormat('HH:mm:ss').format(DateTime.now())} -➡️ Going to Home');
          context.go(Routes.home);
        }
      } else {
        debugPrint(
            '${DateFormat('HH:mm:ss').format(DateTime.now())} -➡️ Going to Home (schedule load issue)');
        context.go(Routes.home);
      }
    } else {
      debugPrint(
          '${DateFormat('HH:mm:ss').format(DateTime.now())} -⚠️ Users exist but no active user - going to UserForm');
      context.go(Routes.userForm);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<UserBloc, UserState>(
      listener: (context, state) {
        if (state is UsersLoaded) {
          debugPrint(
              '🔄 SplashPage - UsersLoaded state received. Checking navigation.');
          // Intentamos navegar tan pronto como el estado sea UsersLoaded,
          // pero respetando el tiempo mínimo de splash.
          if (_minTimeElapsed) {
            _navigateBasedOnUserState(state);
          }
        }
      },
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.secondary,
              ],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.favorite,
                  size: AppIcons.xxl,
                  color: AppColors.white,
                ),
                const SizedBox(height: AppSpacing.gapLg),
                Text(
                  'MTA',
                  style: AppTypography.display.copyWith(
                    color: AppColors.white,
                  ),
                ),
                const SizedBox(height: AppSpacing.gapSm),
                Text(
                  'Blood Pressure Manager',
                  style: AppTypography.h3.copyWith(
                    color: AppColors.white.withValues(alpha: 0.9),
                  ),
                ),
                const SizedBox(height: AppSpacing.gapXl),
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
