import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ca.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ca'),
    Locale('en'),
    Locale('es')
  ];

  /// No description provided for @appTitle.
  ///
  /// In es, this message translates to:
  /// **'MTA - Blood Pressure Manager'**
  String get appTitle;

  /// No description provided for @users.
  ///
  /// In es, this message translates to:
  /// **'Users'**
  String get users;

  /// No description provided for @measurements.
  ///
  /// In es, this message translates to:
  /// **'Measurements'**
  String get measurements;

  /// No description provided for @schedules.
  ///
  /// In es, this message translates to:
  /// **'Schedules'**
  String get schedules;

  /// No description provided for @export.
  ///
  /// In es, this message translates to:
  /// **'Export'**
  String get export;

  /// No description provided for @settings.
  ///
  /// In es, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @userName.
  ///
  /// In es, this message translates to:
  /// **'Name'**
  String get userName;

  /// No description provided for @userAge.
  ///
  /// In es, this message translates to:
  /// **'Age'**
  String get userAge;

  /// No description provided for @hasMedication.
  ///
  /// In es, this message translates to:
  /// **'Taking Medication?'**
  String get hasMedication;

  /// No description provided for @medicationName.
  ///
  /// In es, this message translates to:
  /// **'Medication Name'**
  String get medicationName;

  /// No description provided for @enableNotifications.
  ///
  /// In es, this message translates to:
  /// **'Enable Notifications?'**
  String get enableNotifications;

  /// No description provided for @addUser.
  ///
  /// In es, this message translates to:
  /// **'Add User'**
  String get addUser;

  /// No description provided for @editUser.
  ///
  /// In es, this message translates to:
  /// **'Edit User'**
  String get editUser;

  /// No description provided for @deleteUser.
  ///
  /// In es, this message translates to:
  /// **'Delete User'**
  String get deleteUser;

  /// No description provided for @newUser.
  ///
  /// In es, this message translates to:
  /// **'New User'**
  String get newUser;

  /// No description provided for @activeUser.
  ///
  /// In es, this message translates to:
  /// **'Active User'**
  String get activeUser;

  /// No description provided for @systolic.
  ///
  /// In es, this message translates to:
  /// **'Systolic'**
  String get systolic;

  /// No description provided for @diastolic.
  ///
  /// In es, this message translates to:
  /// **'Diastolic'**
  String get diastolic;

  /// No description provided for @pulse.
  ///
  /// In es, this message translates to:
  /// **'Pulse'**
  String get pulse;

  /// No description provided for @measurementNumber.
  ///
  /// In es, this message translates to:
  /// **'Measurement #'**
  String get measurementNumber;

  /// No description provided for @measurementTime.
  ///
  /// In es, this message translates to:
  /// **'Time'**
  String get measurementTime;

  /// No description provided for @note.
  ///
  /// In es, this message translates to:
  /// **'Note'**
  String get note;

  /// No description provided for @date.
  ///
  /// In es, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @day.
  ///
  /// In es, this message translates to:
  /// **'Day'**
  String get day;

  /// No description provided for @addMeasurement.
  ///
  /// In es, this message translates to:
  /// **'Add Measurement'**
  String get addMeasurement;

  /// No description provided for @editMeasurement.
  ///
  /// In es, this message translates to:
  /// **'Edit Measurement'**
  String get editMeasurement;

  /// No description provided for @deleteMeasurement.
  ///
  /// In es, this message translates to:
  /// **'Delete Measurement'**
  String get deleteMeasurement;

  /// No description provided for @measurementDetails.
  ///
  /// In es, this message translates to:
  /// **'Measurement Details'**
  String get measurementDetails;

  /// No description provided for @save.
  ///
  /// In es, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @finish.
  ///
  /// In es, this message translates to:
  /// **'Finish'**
  String get finish;

  /// No description provided for @cancel.
  ///
  /// In es, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In es, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In es, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @confirm.
  ///
  /// In es, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @scheduleTime.
  ///
  /// In es, this message translates to:
  /// **'Schedule Time'**
  String get scheduleTime;

  /// No description provided for @addSchedule.
  ///
  /// In es, this message translates to:
  /// **'Add Schedule'**
  String get addSchedule;

  /// No description provided for @editSchedule.
  ///
  /// In es, this message translates to:
  /// **'Edit Schedule'**
  String get editSchedule;

  /// No description provided for @deleteSchedule.
  ///
  /// In es, this message translates to:
  /// **'Delete Schedule'**
  String get deleteSchedule;

  /// No description provided for @maxSchedulesReached.
  ///
  /// In es, this message translates to:
  /// **'Maximum 10 schedules allowed'**
  String get maxSchedulesReached;

  /// No description provided for @monday.
  ///
  /// In es, this message translates to:
  /// **'Monday'**
  String get monday;

  /// No description provided for @tuesday.
  ///
  /// In es, this message translates to:
  /// **'Tuesday'**
  String get tuesday;

  /// No description provided for @wednesday.
  ///
  /// In es, this message translates to:
  /// **'Wednesday'**
  String get wednesday;

  /// No description provided for @thursday.
  ///
  /// In es, this message translates to:
  /// **'Thursday'**
  String get thursday;

  /// No description provided for @friday.
  ///
  /// In es, this message translates to:
  /// **'Friday'**
  String get friday;

  /// No description provided for @saturday.
  ///
  /// In es, this message translates to:
  /// **'Saturday'**
  String get saturday;

  /// No description provided for @sunday.
  ///
  /// In es, this message translates to:
  /// **'Sunday'**
  String get sunday;

  /// No description provided for @exportData.
  ///
  /// In es, this message translates to:
  /// **'Export Data'**
  String get exportData;

  /// No description provided for @startDate.
  ///
  /// In es, this message translates to:
  /// **'Start Date'**
  String get startDate;

  /// No description provided for @endDate.
  ///
  /// In es, this message translates to:
  /// **'End Date'**
  String get endDate;

  /// No description provided for @startTime.
  ///
  /// In es, this message translates to:
  /// **'Start Time'**
  String get startTime;

  /// No description provided for @endTime.
  ///
  /// In es, this message translates to:
  /// **'End Time'**
  String get endTime;

  /// No description provided for @fileName.
  ///
  /// In es, this message translates to:
  /// **'File Name'**
  String get fileName;

  /// No description provided for @selectDirectory.
  ///
  /// In es, this message translates to:
  /// **'Select Directory'**
  String get selectDirectory;

  /// No description provided for @exportFormat.
  ///
  /// In es, this message translates to:
  /// **'Export Format'**
  String get exportFormat;

  /// No description provided for @alarmTitle.
  ///
  /// In es, this message translates to:
  /// **'Blood Pressure Measurement'**
  String get alarmTitle;

  /// No description provided for @alarmBody.
  ///
  /// In es, this message translates to:
  /// **'Time to take your blood pressure measurement'**
  String get alarmBody;

  /// No description provided for @postpone.
  ///
  /// In es, this message translates to:
  /// **'Postpone 10 min'**
  String get postpone;

  /// No description provided for @takeMeasurement.
  ///
  /// In es, this message translates to:
  /// **'Take Measurement'**
  String get takeMeasurement;

  /// No description provided for @validationRequired.
  ///
  /// In es, this message translates to:
  /// **'This field is required'**
  String get validationRequired;

  /// No description provided for @validationInvalidNumber.
  ///
  /// In es, this message translates to:
  /// **'Invalid number'**
  String get validationInvalidNumber;

  /// No description provided for @validationStartBeforeEnd.
  ///
  /// In es, this message translates to:
  /// **'Start must be before end'**
  String get validationStartBeforeEnd;

  /// No description provided for @validationEndNotFuture.
  ///
  /// In es, this message translates to:
  /// **'End cannot be in the future'**
  String get validationEndNotFuture;

  /// No description provided for @deleteConfirmTitle.
  ///
  /// In es, this message translates to:
  /// **'Confirm Deletion'**
  String get deleteConfirmTitle;

  /// No description provided for @deleteConfirmMessage.
  ///
  /// In es, this message translates to:
  /// **'Are you sure you want to delete this item?'**
  String get deleteConfirmMessage;

  /// No description provided for @errorGeneric.
  ///
  /// In es, this message translates to:
  /// **'An error occurred'**
  String get errorGeneric;

  /// No description provided for @errorNoUser.
  ///
  /// In es, this message translates to:
  /// **'No user selected'**
  String get errorNoUser;

  /// No description provided for @errorSaveFailed.
  ///
  /// In es, this message translates to:
  /// **'Failed to save'**
  String get errorSaveFailed;

  /// No description provided for @errorLoadFailed.
  ///
  /// In es, this message translates to:
  /// **'Failed to load data'**
  String get errorLoadFailed;

  /// No description provided for @success.
  ///
  /// In es, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @successSaved.
  ///
  /// In es, this message translates to:
  /// **'Saved successfully'**
  String get successSaved;

  /// No description provided for @successDeleted.
  ///
  /// In es, this message translates to:
  /// **'Deleted successfully'**
  String get successDeleted;

  /// No description provided for @successExported.
  ///
  /// In es, this message translates to:
  /// **'Exported successfully'**
  String get successExported;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ca', 'en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ca':
      return AppLocalizationsCa();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
