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

  try {
    // ✅ PASO 1: Initialize timezone data for notifications
    tz.initializeTimeZones();

    // ✅ PASO 2: PASO 2: Obtener la zona horaria del dispositivo
    final timeZoneInfo = await FlutterTimezone.getLocalTimezone();
    final String timeZoneName = timeZoneInfo.identifier;

    debugPrint(
        '${DateFormat('HH:mm:ss').format(DateTime.now())} -📍 timeZoneInfo.identifier: ${timeZoneInfo.identifier}');
    debugPrint(
        '${DateFormat('HH:mm:ss').format(DateTime.now())} -📍 Zona horaria del dispositivo: ${timeZoneInfo.localizedName?.name}');
    debugPrint(
        '${DateFormat('HH:mm:ss').format(DateTime.now())} -📍 Zona horaria del dispositivo - key: ${const ValueKey("timeZoneLabel")}');
    debugPrint(
        '${DateFormat('HH:mm:ss').format(DateTime.now())} -📍 Zona horaria del dispositivo: $timeZoneName');

    // ✅ PASO 3: Configurar la zona horaria local
    tz.setLocalLocation(tz.getLocation(timeZoneName));

    final now = DateTime.now();

    debugPrint(
        '${DateFormat('HH:mm:ss').format(DateTime.now())} -✅ Timezone initialized: $timeZoneName');
    debugPrint(
        '${DateFormat('HH:mm:ss').format(now)} - ⏰ Hora local actual: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(now)}');
  } catch (e) {
    debugPrint(
        '${DateFormat('HH:mm:ss').format(DateTime.now())} -Timezone initialization warning: $e');
    // Fallback a 'Europe/Madrid' si falla
    try {
      tz.setLocalLocation(tz.getLocation('Europe/Madrid'));
      debugPrint(
          '${DateFormat('HH:mm:ss').format(DateTime.now())} -✅ Fallback a Europe/Madrid');
    } catch (e2) {
      debugPrint(
          '${DateFormat('HH:mm:ss').format(DateTime.now())} -❌ No se pudo configurar timezone: $e2');
    }
  }

  // ✅ PASO 3: Inicializar el plugin de notificaciones locales
  try {
    debugPrint(
        '${DateFormat('HH:mm:ss').format(DateTime.now())} -🔔 Inicializando notificaciones...');

    // Configuración para Android
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // Configuración para iOS/macOS
    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    // Configuración combinada
    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
      macOS: initializationSettingsDarwin,
    );

    // Inicializar el plugin con callback para acciones
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
      onDidReceiveBackgroundNotificationResponse:
          _onBackgroundNotificationResponse,
    );

    // ✅ PASO 4: Crear el canal de notificaciones para Android
    await _createNotificationChannels();

    debugPrint(
        '${DateFormat('HH:mm:ss').format(DateTime.now())} -✅ Notificaciones inicializadas correctamente');
  } catch (e, stackTrace) {
    debugPrint(
        '${DateFormat('HH:mm:ss').format(DateTime.now())} -❌ Error al inicializar notificaciones: $e');
    debugPrint('Stack: $stackTrace');
  }

  // ✅ Solicitar permisos de notificaciones
  try {
    debugPrint(
        '${DateFormat('HH:mm:ss').format(DateTime.now())} -🔐 Solicitando permisos...');
    final permissionsGranted =
        await NotificationPermissionHandler.requestAllPermissions();
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
