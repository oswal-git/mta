import 'package:get_it/get_it.dart';
import 'package:mta/core/database/database.dart';
import 'package:mta/core/database/database_helper.dart';
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
import 'package:shared_preferences/shared_preferences.dart';

// Features - Measurements

// Features - Schedules

// Features - Export

final sl = GetIt.instance;

Future<void> init() async {
  // ===== Core - Database =====
  final database = DatabaseHelper.database;
  sl.registerLazySingleton<AppDatabase>(() => database);

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
        // notificationPlugin: sl(),
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

  // // Use cases
  // sl.registerLazySingleton(() => ExportMeasurements(sl()));

  // // Repository
  // sl.registerLazySingleton<ExportRepository>(
  //   () => ExportRepositoryImpl(dataSource: sl()),
  // );

  // // Data sources
  // sl.registerLazySingleton<ExportDataSource>(
  //   () => ExportDataSourceImpl(),
  // );

  // ===== External =====

  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);

  // // Initialize notifications
  // final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  // const initializationSettingsAndroid =
  //     AndroidInitializationSettings('@mipmap/ic_launcher');
  // const initializationSettingsIOS = DarwinInitializationSettings();
  // const initializationSettings = InitializationSettings(
  //   android: initializationSettingsAndroid,
  //   iOS: initializationSettingsIOS,
  // );
  // await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  // sl.registerLazySingleton(() => flutterLocalNotificationsPlugin);
}
