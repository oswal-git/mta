// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get accept => 'Accept';

  @override
  String get activeUser => 'Active User';

  @override
  String get addMeasurement => 'Add Measurement';

  @override
  String get addNoteHint => 'Add a note...';

  @override
  String get addSchedule => 'Add Schedule';

  @override
  String get addUser => 'Add User';

  @override
  String get alertManagement => 'Alert Management';

  @override
  String get appTitle => 'MTA - Blood Pressure Manager';

  @override
  String get backToHome => 'Back to Home';

  @override
  String get bloodPressureMonitorModel => 'Blood pressure monitor brand/model';

  @override
  String get bloodPressureReference => 'Blood Pressure Reference';

  @override
  String get cancel => 'Cancel';

  @override
  String get cancelNotification => 'Cancel notification';

  @override
  String get close => 'Close';

  @override
  String get confirm => 'Confirm';

  @override
  String get customSound => 'Custom sound';

  @override
  String get date => 'Date';

  @override
  String get day => 'Day';

  @override
  String get defaultOption => 'Default';

  @override
  String get defaultSound => 'Default sound';

  @override
  String get defaultUsername => 'user';

  @override
  String get delete => 'Delete';

  @override
  String get deleteConfirmMessage =>
      'Are you sure you want to delete this item?';

  @override
  String get deleteConfirmTitle => 'Confirm Deletion';

  @override
  String get deleteMeasurement => 'Delete Measurement';

  @override
  String get deleteSchedule => 'Delete Schedule';

  @override
  String get deleteUser => 'Delete User';

  @override
  String get diastole => 'Diastole';

  @override
  String get diastoleValidation => 'Diastole must be between 30 and 150';

  @override
  String get diastolic => 'Diastol.';

  @override
  String get discardChanges => 'Discard changes?';

  @override
  String get edit => 'Edit';

  @override
  String get editMeasurement => 'Edit Measurement';

  @override
  String get editSchedule => 'Edit Schedule';

  @override
  String get editUser => 'Edit User';

  @override
  String get elevated => 'Elevated';

  @override
  String get enableNotifications => 'Enable Notifications?';

  @override
  String get endDate => 'End Date';

  @override
  String get endTime => 'End Time';

  @override
  String get english => 'English';

  @override
  String get errorGeneric => 'An error occurred';

  @override
  String get errorLoadFailed => 'Failed to load data';

  @override
  String get errorNoUser => 'No user selected';

  @override
  String get errorSaveFailed => 'Failed to save';

  @override
  String get exactAlarmsPermission => 'Exact Alarms';

  @override
  String get exit => 'Exit';

  @override
  String get export => 'Export';

  @override
  String get exportButton => 'Export';

  @override
  String get exportData => 'Export Data';

  @override
  String get exportError => 'Export error';

  @override
  String get exportFormat => 'Export Format';

  @override
  String get exporting => 'Exporting...';

  @override
  String get exportSuccess => 'File exported successfully';

  @override
  String get fileLocation => 'File location';

  @override
  String get fileName => 'File Name';

  @override
  String get finish => 'Finish';

  @override
  String get fixPermissions => 'FIX PERMISSIONS';

  @override
  String get formatCsv => 'CSV';

  @override
  String get formatExcel => 'Excel (XLSX)';

  @override
  String get formatPdf => 'PDF';

  @override
  String get friday => 'Friday';

  @override
  String get hasMeasuring => 'Taking Measuring?';

  @override
  String get high => 'High';

  @override
  String get language => 'Language';

  @override
  String get languageSelection => 'Language Selection';

  @override
  String get markAsTaken => 'Mark as taken';

  @override
  String maxSchedulesAllowed(Object count) {
    return 'Maximum $count schedules allowed';
  }

  @override
  String get maxSchedulesReached => 'Maximum 10 schedules allowed';

  @override
  String get measurementDetails => 'Measurement Details';

  @override
  String get measurementLabel => 'Measurement';

  @override
  String get measurementLocation => 'Measurement location';

  @override
  String get locationNotIndicated => 'Not indicated';

  @override
  String get locationLeftArm => 'Left arm';

  @override
  String get locationLeftWrist => 'Left wrist';

  @override
  String get locationRightArm => 'Right arm';

  @override
  String get locationRightWrist => 'Right wrist';

  @override
  String get measurementNumber => 'Measurement #';

  @override
  String get measurements => 'Measurements';

  @override
  String get measurementTime => 'Time';

  @override
  String measurementTitle(Object number) {
    return 'Measurement $number';
  }

  @override
  String get medicationName => 'Medication Name';

  @override
  String get minutesShort => 'min';

  @override
  String get monday => 'Monday';

  @override
  String get newUser => 'New User';

  @override
  String get next => 'Next';

  @override
  String get noMeasurementsAvailable => 'No measurements available';

  @override
  String get noMeasurementsInRange => 'No measurements in selected range';

  @override
  String get normal => 'Normal';

  @override
  String get noSchedulesYet => 'No schedules yet';

  @override
  String get noSoundsFound => 'No sounds found';

  @override
  String get note => 'Note';

  @override
  String get noteOptional => 'Note (optional)';

  @override
  String get notificationBody => 'Time to take your blood pressure measurement';

  @override
  String notificationSnoozedMessage(Object minutes) {
    return 'Notification snoozed for $minutes minutes';
  }

  @override
  String get notificationSounds => 'Notification sounds';

  @override
  String get notificationSoundsSubtitle => 'Play sound when receiving alerts';

  @override
  String get notificationsPermission => 'Notifications';

  @override
  String get notificationTitle => 'Blood Pressure Measurement';

  @override
  String get noUsers => 'No users';

  @override
  String get noUserSelected => 'No user selected';

  @override
  String get ok => 'OK';

  @override
  String get postpone => 'Postpone 10 min';

  @override
  String get pulse => 'Pulse';

  @override
  String get pulseValidation => 'Pulse must be between 30 and 200';

  @override
  String get reminderLabel => 'Reminder';

  @override
  String get saturday => 'Saturday';

  @override
  String get save => 'Save';

  @override
  String get scheduledTimeLabel => 'Scheduled time';

  @override
  String get schedules => 'Schedules';

  @override
  String get scheduleTime => 'Schedule Time';

  @override
  String get selectDateRange => 'Select Date Range';

  @override
  String get selectDirectory => 'Select Directory';

  @override
  String get selectSound => 'Select sound';

  @override
  String get selectSoundTitle => 'Select Sound';

  @override
  String get settings => 'Settings';

  @override
  String get spanish => 'Spanish';

  @override
  String get startDate => 'Start Date';

  @override
  String get startTime => 'Start Time';

  @override
  String get stay => 'Stay';

  @override
  String get success => 'Success';

  @override
  String get successDeleted => 'Deleted successfully';

  @override
  String get successExported => 'Exported successfully';

  @override
  String get successSaved => 'Saved successfully';

  @override
  String get sunday => 'Sunday';

  @override
  String get syncAlertsToolip => 'Sync Alerts (Emergency)';

  @override
  String get systole => 'Systole';

  @override
  String get systoleDiastoleElevated => 'Systole 130-139\nDiastole 85-89';

  @override
  String get systoleDiastoleHigh => 'Systole ≥ 140\nDiastole ≥ 90';

  @override
  String get systoleDiastoleNormal => 'Systole < 130\nDiastole < 85';

  @override
  String get systoleValidation => 'Systole must be between 50 and 250';

  @override
  String get systolic => 'Systol.';

  @override
  String get takeMeasurement => 'Take Measurement';

  @override
  String get tapPlusToAdd => 'Tap the + button to add your first schedule';

  @override
  String get thursday => 'Thursday';

  @override
  String get timeOfMeasurement => 'Time of measurement';

  @override
  String get tuesday => 'Tuesday';

  @override
  String get unknownOption => 'Unknown';

  @override
  String get unsavedChangesMessage =>
      'You have unsaved changes. Do you want to exit without saving?';

  @override
  String get userAge => 'Age';

  @override
  String get userName => 'Name';

  @override
  String get users => 'Users';

  @override
  String get valencian => 'Valencian';

  @override
  String get validationEndNotFuture => 'End cannot be in the future';

  @override
  String get validationInvalidNumber => 'Invalid number';

  @override
  String get validationRequired => 'This field is required';

  @override
  String get validationStartBeforeEnd => 'Start must be before end';

  @override
  String get wednesday => 'Wednesday';
}
