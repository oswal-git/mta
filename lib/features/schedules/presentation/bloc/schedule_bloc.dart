import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mta/features/schedules/domain/usecases/create_schedule.dart';
import 'package:mta/features/schedules/domain/usecases/delete_schedule.dart';
import 'package:mta/features/schedules/domain/usecases/get_schedules.dart';
import 'package:mta/features/schedules/domain/usecases/update_schedule.dart';
import 'package:mta/features/schedules/presentation/bloc/schedule_event.dart';
import 'package:mta/features/schedules/presentation/bloc/schedule_state.dart';

class ScheduleBloc extends Bloc<ScheduleEvent, ScheduleState> {
  final GetSchedules getSchedules;
  final CreateSchedule createSchedule;
  final UpdateSchedule updateSchedule;
  final DeleteSchedule deleteSchedule;
  // final FlutterLocalNotificationsPlugin notificationPlugin;

  ScheduleBloc({
    required this.getSchedules,
    required this.createSchedule,
    required this.updateSchedule,
    required this.deleteSchedule,
    // required this.notificationPlugin,
  }) : super(ScheduleInitial()) {
    on<LoadSchedulesEvent>(_onLoadSchedules);
    on<CreateScheduleEvent>(_onCreateSchedule);
    on<UpdateScheduleEvent>(_onUpdateSchedule);
    on<DeleteScheduleEvent>(_onDeleteSchedule);
    on<ToggleScheduleEvent>(_onToggleSchedule);
  }

  Future<void> _onLoadSchedules(
    LoadSchedulesEvent event,
    Emitter<ScheduleState> emit,
  ) async {
    emit(ScheduleLoading());

    final result = await getSchedules(
      GetSchedulesParams(userId: event.userId),
    );

    result.fold(
      (failure) => emit(ScheduleError(failure.message)),
      (schedules) => emit(SchedulesLoaded(
        schedules: schedules,
        userId: event.userId,
      )),
    );
  }

  Future<void> _onCreateSchedule(
    CreateScheduleEvent event,
    Emitter<ScheduleState> emit,
  ) async {
    emit(ScheduleLoading());

    final result = await createSchedule(
      CreateScheduleParams(schedule: event.schedule),
    );

    await result.fold(
      (failure) async => emit(ScheduleError(failure.message)),
      (schedule) async {
        // Schedule notification
        if (schedule.isEnabled) {
          // await _scheduleNotification(schedule);
        }

        emit(ScheduleOperationSuccess(
          'Schedule created successfully',
          userId: schedule.userId,
        ));
      },
    );
  }

  Future<void> _onUpdateSchedule(
    UpdateScheduleEvent event,
    Emitter<ScheduleState> emit,
  ) async {
    emit(ScheduleLoading());

    final result = await updateSchedule(
      UpdateScheduleParams(schedule: event.schedule),
    );

    await result.fold(
      (failure) async => emit(ScheduleError(failure.message)),
      (schedule) async {
        // Cancel old notification
        // await _cancelNotification(schedule.id.hashCode);

        // Schedule new notification if enabled
        if (schedule.isEnabled) {
          // await _scheduleNotification(schedule);
        }

        emit(ScheduleOperationSuccess(
          'Schedule updated successfully',
          userId: schedule.userId,
        ));
      },
    );
  }

  Future<void> _onDeleteSchedule(
    DeleteScheduleEvent event,
    Emitter<ScheduleState> emit,
  ) async {
    emit(ScheduleLoading());

    final result = await deleteSchedule(
      DeleteScheduleParams(id: event.id),
    );

    await result.fold(
      (failure) async => emit(ScheduleError(failure.message)),
      (_) async {
        // Cancel notification
        // await _cancelNotification(event.id.hashCode);

        emit(ScheduleOperationSuccess(
          'Schedule deleted successfully',
          userId: event.userId,
        ));
      },
    );
  }

  Future<void> _onToggleSchedule(
    ToggleScheduleEvent event,
    Emitter<ScheduleState> emit,
  ) async {
    final toggledSchedule = event.schedule.copyWith(
      isEnabled: !event.schedule.isEnabled,
      updatedAt: DateTime.now(),
    );

    add(UpdateScheduleEvent(toggledSchedule));
  }

  // Future<void> _scheduleNotification(Schedule schedule) async {
  //   try {
  //     final now = DateTime.now();
  //     final scheduledTime = DateTime(
  //       now.year,
  //       now.month,
  //       now.day,
  //       schedule.hour,
  //       schedule.minute,
  //     );

  //     // Schedule 5 minutes before
  //     var notificationTime = scheduledTime.subtract(const Duration(minutes: 5));

  //     // If the time has passed today, schedule for tomorrow
  //     if (notificationTime.isBefore(now)) {
  //       notificationTime = notificationTime.add(const Duration(days: 1));
  //     }

  //     const androidDetails = AndroidNotificationDetails(
  //       'blood_pressure_channel',
  //       'Blood Pressure Measurements',
  //       channelDescription: 'Reminders for blood pressure measurements',
  //       importance: Importance.high,
  //       priority: Priority.high,
  //       actions: <AndroidNotificationAction>[
  //         AndroidNotificationAction(
  //           'postpone',
  //           'Postpone 10 min',
  //         ),
  //         AndroidNotificationAction(
  //           'take_measurement',
  //           'Take Measurement',
  //         ),
  //         AndroidNotificationAction(
  //           'cancel',
  //           'Cancel',
  //         ),
  //       ],
  //     );

  //     const iosDetails = DarwinNotificationDetails();

  //     const notificationDetails = NotificationDetails(
  //       android: androidDetails,
  //       iOS: iosDetails,
  //     );

  //     await notificationPlugin.zonedSchedule(
  //       schedule.id.hashCode,
  //       'Blood Pressure Measurement',
  //       'Time to take your blood pressure (${schedule.formattedTime})',
  //       tz.TZDateTime.from(notificationTime, tz.local),
  //       notificationDetails,
  //       androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
  //       uiLocalNotificationDateInterpretation:
  //           UILocalNotificationDateInterpretation.absoluteTime,
  //       matchDateTimeComponents: DateTimeComponents.time, // Repeat daily
  //     );
  //   } catch (e) {
  //     print('Error scheduling notification: $e');
  //   }
  // }

  // Future<void> _cancelNotification(int id) async {
  //   try {
  //     await notificationPlugin.cancel(id);
  //   } catch (e) {
  //     print('Error canceling notification: $e');
  //   }
  // }
}
