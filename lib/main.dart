import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:intl/intl.dart';
import 'package:mta/features/alarms/utils/alarm_permission_handler.dart';

import 'core/di/injection_container.dart' as di;
import 'core/routes/app_router.dart';
import 'core/database/database_helper.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/l10n/app_localizations.dart';
import 'package:timezone/data/latest.dart' as tz;

// Importar BLoCs
import 'features/users/presentation/bloc/user_bloc.dart';
import 'features/users/presentation/bloc/user_event.dart';
import 'features/measurements/presentation/bloc/measurement_bloc.dart';
import 'features/schedules/presentation/bloc/schedule_bloc.dart';
import 'features/alarms/presentation/bloc/alarm_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Capturar errores de Flutter
  FlutterError.onError = (FlutterErrorDetails details) {
    debugPrint(
        '${DateFormat('HH:mm:ss').format(DateTime.now())} -🔴 FLUTTER ERROR: ${details.exception}');
    debugPrint(
        '${DateFormat('HH:mm:ss').format(DateTime.now())} -Stack: ${details.stack}');
  };

  // Forzar que el debugger se mantenga vivo
  WidgetsBinding.instance.addPostFrameCallback((_) {
    debugPrint('🔧 App ready for debugging');
  });

  try {
    // Initialize timezone data for notifications
    tz.initializeTimeZones();
    debugPrint(
        '${DateFormat('HH:mm:ss').format(DateTime.now())} -✅ Timezone initialized');
  } catch (e) {
    debugPrint(
        '${DateFormat('HH:mm:ss').format(DateTime.now())} -Timezone initialization warning: $e');
    // Continue even if timezone fails (some platforms may not support it fully)
  }

  // ✅ Solicitar permisos de notificaciones y alarmas
  try {
    debugPrint(
        '${DateFormat('HH:mm:ss').format(DateTime.now())} -🔐 Solicitando permisos...');
    final permissionsGranted =
        await AlarmPermissionHandler.requestAllPermissions();
    if (permissionsGranted) {
      debugPrint(
          '${DateFormat('HH:mm:ss').format(DateTime.now())} -✅ Permisos concedidos');
    } else {
      debugPrint(
          '${DateFormat('HH:mm:ss').format(DateTime.now())} -⚠️ Algunos permisos no fueron concedidos');
    }
  } catch (e) {
    debugPrint(
        '${DateFormat('HH:mm:ss').format(DateTime.now())} -⚠️ Error al solicitar permisos: $e');
  }

  // Inicializar AndroidAlarmManager (solo para Android)
  try {
    await AndroidAlarmManager.initialize();
    debugPrint(
        '${DateFormat('HH:mm:ss').format(DateTime.now())} -✅ AndroidAlarmManager initialized');
  } catch (e) {
    debugPrint(
        '${DateFormat('HH:mm:ss').format(DateTime.now())} -⚠️ AndroidAlarmManager not available: $e');
    // No es crítico, continuar sin AndroidAlarmManager
  }

  try {
    // Inicializar base de datos con timeout
    await DatabaseHelper.init();
    debugPrint(
        '${DateFormat('HH:mm:ss').format(DateTime.now())} -✅ Database successfully');
  } catch (e, stackTrace) {
    debugPrint(
        '${DateFormat('HH:mm:ss').format(DateTime.now())} -❌ Database initialization failed: $e');
    debugPrint(
        '${DateFormat('HH:mm:ss').format(DateTime.now())} -Stack trace: $stackTrace');
    // Puedes mostrar un error al usuario o fallar gracefuly
  }

  // Initialize dependency injection
  debugPrint(
      '${DateFormat('HH:mm:ss').format(DateTime.now())} -🔧 Initializing DI...');
  await di.init();
  debugPrint(
      '${DateFormat('HH:mm:ss').format(DateTime.now())} -✅ DI initialized');

  runApp(const MTAApp());
}

class MTAApp extends StatelessWidget {
  const MTAApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) {
            debugPrint(
                '${DateFormat('HH:mm:ss').format(DateTime.now())} -🔧 Creating UserBloc...');
            final bloc = di.sl<UserBloc>();
            // Cargar usuarios inmediatamente
            bloc.add(LoadUsersEvent());
            debugPrint(
                '${DateFormat('HH:mm:ss').format(DateTime.now())} -✅ UserBloc created and loading users');
            return bloc;
          },
        ),
        BlocProvider(create: (_) => di.sl<MeasurementBloc>()),
        BlocProvider(create: (_) => di.sl<ScheduleBloc>()),
        // Agregar el AlarmBloc
        BlocProvider(
          create: (_) {
            debugPrint(
                '${DateFormat('HH:mm:ss').format(DateTime.now())} -🔧 Creating AlarmBloc...');
            final bloc = di.sl<AlarmBloc>();
            debugPrint(
                '${DateFormat('HH:mm:ss').format(DateTime.now())} -✅ AlarmBloc created');
            return bloc;
          },
        ),
      ],
      child: MaterialApp.router(
        title: 'MTA',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            centerTitle: true,
            elevation: 2,
          ),
          cardTheme: CardThemeData(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            filled: true,
            fillColor: Colors.grey[50],
          ),
        ),
        routerConfig: appRouter,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en'),
          Locale('es'),
          Locale('ca'),
        ],
        locale: const Locale('es'), // Default language
      ),
    );
  }
}
