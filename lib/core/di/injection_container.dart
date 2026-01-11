import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Core
import 'package:mta/core/database/database.dart';
import 'package:mta/core/database/database_helper.dart';

// Features - Export
import 'package:mta/features/export/data/datasources/export_data_source.dart';
import 'package:mta/features/export/data/repositories/export_repository_impl.dart';
import 'package:mta/features/export/domain/repositories/export_repository.dart';
import 'package:mta/features/export/domain/usecases/export_measurements.dart';

// Features - Mesurements
import 'package:mta/features/measurements/data/datasources/measurement_local_data_source.dart';
import 'package:mta/features/measurements/data/repostoris/measurement_repository_impl.dart';
import 'package:mta/features/measurements/domain/repositories/measurement_repository.dart';
import 'package:mta/features/measurements/domain/usecases/create_measurement.dart';
import 'package:mta/features/measurements/domain/usecases/delete_measurement.dart';
import 'package:mta/features/measurements/domain/usecases/get_measurement_by_id.dart';
import 'package:mta/features/measurements/domain/usecases/get_measurements.dart';
import 'package:mta/features/measurements/domain/usecases/get_next_measurement_number.dart';
import 'package:mta/features/measurements/domain/usecases/update_measurement.dart';
import 'package:mta/features/measurements/presentation/bloc/measurement_bloc.dart';

// Features - Notifications
import 'package:mta/features/notifications/data/datasources/notification_native_data_source.dart';
import 'package:mta/features/notifications/data/repositories/notification_repository_impl.dart';
import 'package:mta/features/notifications/domain/repositories/notification_repository.dart';
import 'package:mta/features/notifications/domain/usecases/cancel_notification.dart';
import 'package:mta/features/notifications/domain/usecases/schedule_notification.dart';
import 'package:mta/features/notifications/domain/usecases/snooze_notification.dart';
import 'package:mta/features/notifications/presentation/bloc/notification_bloc.dart';
import 'package:mta/features/notifications/utils/notification_action_handler.dart';

// Features - Schedules
import 'package:mta/features/schedules/data/datasources/schedule_local_data_source.dart';
import 'package:mta/features/schedules/data/repositories/schedule_repository_impl.dart';
import 'package:mta/features/schedules/domain/repositories/schedule_repository.dart';
import 'package:mta/features/schedules/domain/usecases/create_schedule.dart';
import 'package:mta/features/schedules/domain/usecases/delete_schedule.dart';
import 'package:mta/features/schedules/domain/usecases/get_schedules.dart';
import 'package:mta/features/schedules/domain/usecases/update_schedule.dart';
import 'package:mta/features/schedules/presentation/bloc/schedule_bloc.dart';

// Features - Users
import 'package:mta/features/users/data/datasources/user_local_data_source.dart';
import 'package:mta/features/users/data/repositories/user_repository_impl.dart';
import 'package:mta/features/users/domain/repositories/user_repository.dart';
import 'package:mta/features/users/domain/usecases/get_users.dart';
import 'package:mta/features/users/domain/usecases/get_active_user.dart';
import 'package:mta/features/users/domain/usecases/create_user.dart';
import 'package:mta/features/users/domain/usecases/update_user.dart';
import 'package:mta/features/users/domain/usecases/delete_user.dart';
import 'package:mta/features/users/domain/usecases/set_active_user.dart';
import 'package:mta/features/users/presentation/bloc/user_bloc.dart';

// ✅ IMPORTAR LA INSTANCIA GLOBAL desde main.dart
import 'package:mta/main.dart' show flutterLocalNotificationsPlugin;

final sl = GetIt.instance;

Future<void> init() async {
  // ===== Core - Database =====
  final database = DatabaseHelper.database;
  sl.registerLazySingleton<AppDatabase>(() => database);

  // ===== External =====
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);

  // ===== External - Flutter Local Notifications =====
  // ✅ USAR LA INSTANCIA GLOBAL YA INICIALIZADA desde main.dart
  // NO crear una nueva instancia, usar la que ya fue inicializada
  sl.registerLazySingleton(() => flutterLocalNotificationsPlugin);

  // ===== Features - Users =====

  // Bloc
  sl.registerFactory(() => UserBloc(
        getUsers: sl(),
        getActiveUser: sl(),
        createUser: sl(),
        updateUser: sl(),
        deleteUser: sl(),
        setActiveUser: sl(),
      ));

  // Use cases
  sl.registerLazySingleton(() => GetUsers(sl()));
  sl.registerLazySingleton(() => GetActiveUser(sl()));
  sl.registerLazySingleton(() => CreateUser(sl()));
  sl.registerLazySingleton(() => UpdateUser(sl()));
  sl.registerLazySingleton(() => DeleteUser(sl()));
  sl.registerLazySingleton(() => SetActiveUser(sl()));

  // Repository
  sl.registerLazySingleton<UserRepository>(
    () => UserRepositoryImpl(localDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<UserLocalDataSource>(
    () => UserLocalDataSourceImpl(
      sharedPreferences: sl(),
      database: sl(),
    ),
  );

  // ===== Features - Measurements =====

  // Bloc
  sl.registerFactory(() => MeasurementBloc(
        getMeasurements: sl(),
        getMeasurementById: sl(),
        createMeasurement: sl(),
        updateMeasurement: sl(),
        deleteMeasurement: sl(),
        getNextMeasurementNumber: sl(),
        notificationRepository: sl(),
        scheduleRepository: sl(),
      ));

  // Use cases
  sl.registerLazySingleton(() => GetMeasurements(sl()));
  sl.registerLazySingleton(() => GetMeasurementById(sl()));
  sl.registerLazySingleton(() => CreateMeasurement(sl()));
  sl.registerLazySingleton(() => UpdateMeasurement(sl()));
  sl.registerLazySingleton(() => DeleteMeasurement(sl()));
  sl.registerLazySingleton(() => GetNextMeasurementNumber(sl()));

  // Repository
  sl.registerLazySingleton<MeasurementRepository>(
    () => MeasurementRepositoryImpl(localDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<MeasurementLocalDataSource>(
    () => MeasurementLocalDataSourceImpl(database: sl()),
  );

  // ===== Features - Schedules =====

  // Bloc
  sl.registerFactory(() => ScheduleBloc(
        getSchedules: sl(),
        createSchedule: sl(),
        updateSchedule: sl(),
        deleteSchedule: sl(),
        notificationRepository: sl(),
      ));

  // Use cases
  sl.registerLazySingleton(() => GetSchedules(sl()));
  sl.registerLazySingleton(() => CreateSchedule(sl()));
  sl.registerLazySingleton(() => UpdateSchedule(sl()));
  sl.registerLazySingleton(() => DeleteSchedule(sl()));

  // Repository
  sl.registerLazySingleton<ScheduleRepository>(
    () => ScheduleRepositoryImpl(localDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<ScheduleLocalDataSource>(
    () => ScheduleLocalDataSourceImpl(database: sl()),
  );

  // ===== Features - Export =====

  // Use cases
  sl.registerLazySingleton(() => ExportMeasurements(sl()));

  // Repository
  sl.registerLazySingleton<ExportRepository>(
    () => ExportRepositoryImpl(dataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<ExportDataSource>(
    () => ExportDataSourceImpl(),
  );

  // ===== External =====

  // ===== Features - Notifications =====

  // BLoC
  sl.registerFactory(
    () => NotificationBloc(
      scheduleNotification: sl(),
      cancelNotification: sl(),
      snoozeNotification: sl(),
      repository: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => ScheduleNotificationUseCase(sl()));
  sl.registerLazySingleton(() => CancelNotificationUseCase(sl()));
  sl.registerLazySingleton(() => SnoozeNotificationUseCase(sl()));

  // Repository
  sl.registerLazySingleton<NotificationRepository>(
    () => NotificationRepositoryImpl(
      dataSource: sl(),
      userRepository: sl(),
      scheduleRepository: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<NotificationNativeDataSource>(
    () => NotificationNativeDataSourceImpl(
      notificationsPlugin: sl(),
    ),
  );

  // Utils
  sl.registerLazySingleton<NotificationActionHandler>(
    () => NotificationActionHandler(
      notificationBloc: sl(),
      measurementBloc: sl(),
    ),
  );
}
