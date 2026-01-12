import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:intl/intl.dart';
import 'package:mta/features/notifications/utils/notification_action_handler.dart';
import 'package:mta/features/notifications/utils/notification_permission_handler.dart';

import 'core/di/injection_container.dart' as di;
import 'core/routes/app_router.dart';
import 'core/database/database_helper.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/l10n/app_localizations.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

// Importar BLoCs
import 'features/users/presentation/bloc/user_bloc.dart';
import 'features/users/presentation/bloc/user_event.dart';
import 'features/measurements/presentation/bloc/measurement_bloc.dart';
import 'features/schedules/presentation/bloc/schedule_bloc.dart';
import 'features/notifications/presentation/bloc/notification_bloc.dart';

// ✅ INSTANCIA GLOBAL del plugin de notificaciones
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

// ✅ INSTANCIA GLOBAL del manejador de acciones
late NotificationActionHandler notificationActionHandler;

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
  // WidgetsBinding.instance.addPostFrameCallback((_) {
  //   debugPrint('🔧 App ready for debugging');
  // });

  // ✅ INICIALIZACIÓN PARALELA
  debugPrint(
      '${DateFormat('HH:mm:ss').format(DateTime.now())} -🚀 Iniciando inicialización paralela...');

  await Future.wait([
    // PASO 1 & 2: Timezone
    (() async {
      try {
        tz.initializeTimeZones();
        final timeZoneInfo = await FlutterTimezone.getLocalTimezone();
        tz.setLocalLocation(tz.getLocation(timeZoneInfo.identifier));
        debugPrint(
            '${DateFormat('HH:mm:ss').format(DateTime.now())} -✅ Timezone initialized: ${timeZoneInfo.identifier}');
      } catch (e) {
        debugPrint(
            '${DateFormat('HH:mm:ss').format(DateTime.now())} -⚠️ Timezone warning: $e');
        try {
          tz.setLocalLocation(tz.getLocation('Europe/Madrid'));
        } catch (_) {}
      }
    })(),

    // PASO 3 & 4: Notificaciones
    (() async {
      try {
        const initializationSettings = InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
          iOS: DarwinInitializationSettings(
              requestAlertPermission: true,
              requestBadgePermission: true,
              requestSoundPermission: true),
        );
        await flutterLocalNotificationsPlugin.initialize(
          initializationSettings,
          onDidReceiveNotificationResponse: _onNotificationResponse,
          onDidReceiveBackgroundNotificationResponse:
              _onBackgroundNotificationResponse,
        );
        await _createNotificationChannels();
        debugPrint(
            '${DateFormat('HH:mm:ss').format(DateTime.now())} -✅ Notificaciones inicializadas');
      } catch (e) {
        debugPrint(
            '${DateFormat('HH:mm:ss').format(DateTime.now())} -❌ Error notificaciones: $e');
      }
    })(),

    // PASO 5: Database
    (() async {
      try {
        await DatabaseHelper.init();
        debugPrint(
            '${DateFormat('HH:mm:ss').format(DateTime.now())} -✅ Database ready');
      } catch (e) {
        debugPrint(
            '${DateFormat('HH:mm:ss').format(DateTime.now())} -❌ Error DB: $e');
      }
    })(),
  ]);

  // Solicitar permisos puede ser asíncrono pero no queremos bloquear el arranque si no es crítico,
  // aunque es mejor tenerlos antes de programar nada.
  NotificationPermissionHandler.requestAllPermissions().then((granted) {
    debugPrint(
        '${DateFormat('HH:mm:ss').format(DateTime.now())} -🔐 Permisos: ${granted ? '✅' : '⚠️'}');
  });

  // DI depende de que la DB y SharedPreferences estén listas (o al menos que sus helpers lo estén)
  // SharedPreferences se inicializa DENTRO de di.init() en muchos casos, pero aquí lo vemos en injection_container.dart
  // Vamos a ejecutar di.init() al final de las paralelas.
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
        // Agregar el NotificationBloc
        BlocProvider(
          create: (_) {
            debugPrint(
                '${DateFormat('HH:mm:ss').format(DateTime.now())} -🔧 Creating NotificationBloc...');
            final bloc = di.sl<NotificationBloc>();
            debugPrint(
                '${DateFormat('HH:mm:ss').format(DateTime.now())} -✅ NotificationBloc created');
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

/// Callback cuando el usuario toca la notificación o sus acciones
void _onNotificationResponse(NotificationResponse response) {
  debugPrint('');
  debugPrint('👆 NOTIFICACIÓN INTERACTUADA');
  debugPrint('   Action ID: ${response.actionId}');
  debugPrint('   Payload: ${response.payload}');
  debugPrint('');

  // Inicializar el handler si no existe
  notificationActionHandler = NotificationActionHandler(
    notificationBloc: di.sl(),
    measurementBloc: di.sl(),
  );

  notificationActionHandler.handleNotificationAction(response);
}

/// Callback para notificaciones en background
@pragma('vm:entry-point')
void _onBackgroundNotificationResponse(NotificationResponse response) {
  debugPrint('🔔 Notificación en background: ${response.actionId}');
  // Las acciones en background son limitadas
  // Normalmente solo se registra el evento
}

/// Crear los canales de notificaciones necesarios
Future<void> _createNotificationChannels() async {
  final androidPlugin =
      flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

  if (androidPlugin == null) return;

  // Canal principal de notificaciones
  const mainChannel = AndroidNotificationChannel(
    'measuring_notifications',
    'Notificaciones de Medición',
    description: 'Recordatorios para tomar medición',
    importance: Importance.max,
    playSound: true,
    sound: RawResourceAndroidNotificationSound('notification'),
    enableVibration: true,
    enableLights: true,
  );

  debugPrint(
      '${DateFormat('HH:mm:ss').format(DateTime.now())} -✅ Canal principal de notificaciones creado: ${mainChannel.id}');

  // Canal para repeticiones
  const repeatChannel = AndroidNotificationChannel(
    'measuring_notifications_repeat',
    'Recordatorios Repetidos',
    description: 'Notificaciones repetidas para medición no tomada',
    importance: Importance.max,
    playSound: true,
    sound: RawResourceAndroidNotificationSound('notification'),
    enableVibration: true,
    enableLights: true,
  );

  debugPrint(
      '${DateFormat('HH:mm:ss').format(DateTime.now())} -✅ Canal de repeticiones de notificaciones creado: ${repeatChannel.id}');

  await androidPlugin.createNotificationChannel(mainChannel);
  await androidPlugin.createNotificationChannel(repeatChannel);

  debugPrint('✅ Canales de notificaciones creados');
}
