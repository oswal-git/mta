import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:mta/features/notifications/utils/notification_action_handler.dart';
import 'package:mta/features/notifications/utils/notification_permission_handler.dart';
import 'package:mta/features/users/presentation/bloc/user_state.dart';

import 'core/di/injection_container.dart' as di;
import 'core/routes/app_router.dart';
import 'core/database/database_helper.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/l10n/app_localizations.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'core/theme/app_theme.dart';
import 'core/utils/utils_barrel.dart'; // Importar barrel para FechaD

// Importar BLoCs
import 'features/users/presentation/bloc/user_bloc.dart';
import 'features/users/presentation/bloc/user_event.dart';
import 'features/measurements/presentation/bloc/measurement_bloc.dart';
import 'features/schedules/presentation/bloc/schedule_bloc.dart';
import 'features/notifications/presentation/bloc/notification_bloc.dart';
import 'package:mta/features/notifications/presentation/bloc/notification_event.dart';

// ✅ INSTANCIA GLOBAL del plugin de notificaciones
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

// ✅ INSTANCIA GLOBAL del manejador de acciones
late NotificationActionHandler notificationActionHandler;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Capturar errores de Flutter
  FlutterError.onError = (FlutterErrorDetails details) {
    debugPrint('${fechaD('🔴')} FLUTTER ERROR: ${details.exception}');
    debugPrint('${fechaD('🔴')} Stack: ${details.stack}');
  };

  // Forzar que el debugger se mantenga vivo
  // WidgetsBinding.instance.addPostFrameCallback((_) {
  //   debugPrint('🔧 App ready for debugging');
  // });

  // ✅ INICIALIZACIÓN PARALELA
  debugPrint('${fechaD('🚀')} Iniciando inicialización paralela...');

  await Future.wait([
    // PASO 1 & 2: Timezone
    (() async {
      try {
        tz.initializeTimeZones();
        final timeZoneInfo = await FlutterTimezone.getLocalTimezone();
        tz.setLocalLocation(tz.getLocation(timeZoneInfo.identifier));
        tz.setLocalLocation(tz.getLocation(timeZoneInfo.identifier));
        debugPrint(
            '${fechaD()} Timezone initialized: ${timeZoneInfo.identifier}');
      } catch (e) {
        debugPrint('${fechaD('⚠️')} Timezone warning: $e');
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
        await _createNotificationChannels();
        debugPrint('${fechaD()} Notificaciones inicializadas');
      } catch (e) {
        debugPrint('${fechaD('❌')} Error notificaciones: $e');
      }
    })(),

    // PASO 5: Database
    (() async {
      try {
        await DatabaseHelper.init();
        await DatabaseHelper.init();
        debugPrint('${fechaD()} Database ready');
      } catch (e) {
        debugPrint('${fechaD('❌')} Error DB: $e');
      }
    })(),
  ]);

  // Solicitar permisos puede ser asíncrono pero no queremos bloquear el arranque si no es crítico,
  // aunque es mejor tenerlos antes de programar nada.
  // aunque es mejor tenerlos antes de programar nada.
  NotificationPermissionHandler.requestAllPermissions().then((granted) {
    debugPrint('${fechaD('🔐')} Permisos: ${granted ? '✅' : '⚠️'}');
  });

  // DI depende de que la DB y SharedPreferences estén listas (o al menos que sus helpers lo estén)
  // SharedPreferences se inicializa DENTRO de di.init() en muchos casos, pero aquí lo vemos en injection_container.dart
  // Vamos a ejecutar di.init() al final de las paralelas.
  debugPrint('${fechaD('🔧')} Initializing DI...');
  await di.init();
  debugPrint('${fechaD('💉')} DI initialized');

  // ✅ Sincronizar notificaciones de todos los usuarios al arrancar
  // (Asegura que las notificaciones del OS estén al día tras una actualización)
  di.sl<NotificationBloc>().add(const RescheduleAllNotifications());
  debugPrint('${fechaD('🔄')} Notification sync triggered');

  // ✅ CHECK FOR NOTIFICATION LAUNCH (Cold Start)
  try {
    final NotificationAppLaunchDetails? notificationAppLaunchDetails =
        await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();

    if (notificationAppLaunchDetails?.didNotificationLaunchApp ?? false) {
      final payload =
          notificationAppLaunchDetails!.notificationResponse?.payload;
      debugPrint('${fechaD('🚀')} App launched via notification!');
      debugPrint('   Payload: $payload');

      if (payload != null && payload.isNotEmpty) {
        final parts = payload.split('|');
        if (parts.isNotEmpty) {
          final userId = parts.length > 2 ? parts[2] : null;
          final targetRoute = userId != null
              ? '${Routes.measurementForm}?userId=$userId'
              : Routes.measurementForm;

          PendingRoute.route = targetRoute;
          debugPrint('${fechaD('📍')} PendingRoute set to: $targetRoute');
        }
      }
    }
  } catch (e) {
    debugPrint('${fechaD('❌')} Error checking notification launch details: $e');
  }

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
            debugPrint('${fechaD('🔧')} Creating UserBloc...');
            final bloc = di.sl<UserBloc>();
            // Cargar usuarios inmediatamente
            bloc.add(LoadUsersEvent());
            debugPrint('${fechaD()} UserBloc created and loading users');
            return bloc;
          },
        ),
        BlocProvider(create: (_) => di.sl<MeasurementBloc>()),
        BlocProvider(create: (_) => di.sl<ScheduleBloc>()),
        // Agregar el NotificationBloc
        BlocProvider(
          create: (_) {
            debugPrint('${fechaD('🔧')} Creating NotificationBloc...');
            final bloc = di.sl<NotificationBloc>();
            debugPrint('${fechaD()} NotificationBloc created');
            return bloc;
          },
        ),
      ],
      child: BlocBuilder<UserBloc, UserState>(
        builder: (context, state) {
          Locale appLocale = const Locale('es');
          if (state is UsersLoaded && state.activeUser != null) {
            appLocale = Locale(state.activeUser!.languageCode);
          }
          return MaterialApp.router(
            title: 'MTA',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
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
            locale: appLocale,
          );
        },
      ),
    );
  }
}

/// Callback cuando el usuario toca la notificación o sus acciones
void _onNotificationResponse(NotificationResponse response) {
  debugPrint('');
  debugPrint('${fechaD('👆')} NOTIFICACIÓN INTERACTUADA');
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
  debugPrint(
      '${fechaD('🔔')} Notificación en background: ${response.actionId}');
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
  final mainChannel = AndroidNotificationChannel(
    'mta_notifications_v5',
    'MTA Alerta V5',
    description: 'Canal para alertas principales',
    importance: Importance.max,
    playSound: true,
    enableVibration: true,
    enableLights: true,
  );

  debugPrint(
      '${fechaD()} Canal principal de notificaciones creado: ${mainChannel.id}');

  // Canal para repeticiones
  final repeatChannel = AndroidNotificationChannel(
    'mta_notifications_repeat_v5',
    'MTA Recordatorio V5',
    description: 'Canal para recordatorios constantes',
    importance: Importance.max,
    playSound: true,
    enableVibration: true,
    enableLights: true,
  );

  debugPrint(
      '${fechaD()} Canal de repeticiones de notificaciones creado: ${repeatChannel.id}');

  await androidPlugin.createNotificationChannel(mainChannel);
  await androidPlugin.createNotificationChannel(repeatChannel);

  debugPrint('${fechaD()} Canales de notificaciones creados');
}
