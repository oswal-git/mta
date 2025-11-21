import 'dart:async';

import 'package:intl/intl.dart';
import 'package:mta/core/database/database_helper.dart';

import 'core/di/injection_container.dart' as di;
import 'core/routes/app_router.dart';
import 'features/measurements/presentation/bloc/measurement_bloc.dart';
import 'features/users/presentation/bloc/user_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/material.dart';

import 'package:mta/core/l10n/app_localizations.dart';
import 'package:mta/features/schedules/presentation/bloc/schedule_bloc.dart';
import 'package:mta/features/users/presentation/bloc/user_event.dart';
import 'package:timezone/data/latest.dart' as tz;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Capturar errores de Flutter
  FlutterError.onError = (FlutterErrorDetails details) {
    debugPrint(
        '${DateFormat('HH:mm:ss').format(DateTime.now())} -🔴 FLUTTER ERROR: ${details.exception}');
    debugPrint(
        '${DateFormat('HH:mm:ss').format(DateTime.now())} -Stack: ${details.stack}');
  };
  runZonedGuarded(() async {
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
  }, (error, stack) {
    debugPrint(
        '${DateFormat('HH:mm:ss').format(DateTime.now())} -🔴 UNCAUGHT ERROR: $error');
    debugPrint(
        '${DateFormat('HH:mm:ss').format(DateTime.now())} -Stack: $stack');
  });
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
