/// Bundle de strings localizados para notificaciones (sin dependencia de Context)
class NotificationStrings {
  final String channelAlertTitle;
  final String channelRepeatTitle;
  final String actionCancelled;
  final String actionSnooze5;
  final String actionSnooze10;
  final String groupSummaryBody;
  final String testPrefix;
  final String testNotificationBody;
  final String nextMeasurementTime; // Template: {time}
  final String measurementTimeTitle; // Template: {time}
  final String reminderMeasurementTitle; // Template: {repetition}, {time}
  final String preAvisoBody;
  final String scheduledTimeBody;
  final String repeatBody; // Template: {minutes}

  NotificationStrings({
    required this.channelAlertTitle,
    required this.channelRepeatTitle,
    required this.actionCancelled,
    required this.actionSnooze5,
    required this.actionSnooze10,
    required this.groupSummaryBody,
    required this.testPrefix,
    required this.testNotificationBody,
    required this.nextMeasurementTime,
    required this.measurementTimeTitle,
    required this.reminderMeasurementTitle,
    required this.preAvisoBody,
    required this.scheduledTimeBody,
    required this.repeatBody,
  });
}
