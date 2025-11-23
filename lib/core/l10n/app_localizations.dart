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

  /// No description provided for @activeUser.
  ///
  /// In es, this message translates to:
  /// **'Usuario Activo'**
  String get activeUser;

  /// No description provided for @addMeasurement.
  ///
  /// In es, this message translates to:
  /// **'Agregar Medición'**
  String get addMeasurement;

  /// No description provided for @addSchedule.
  ///
  /// In es, this message translates to:
  /// **'Agregar Horario'**
  String get addSchedule;

  /// No description provided for @addUser.
  ///
  /// In es, this message translates to:
  /// **'Agregar Usuario'**
  String get addUser;

  /// No description provided for @alarmBody.
  ///
  /// In es, this message translates to:
  /// **'Es hora de realizar tu medición de presión arterial'**
  String get alarmBody;

  /// No description provided for @alarmTitle.
  ///
  /// In es, this message translates to:
  /// **'Medición de Presión Arterial'**
  String get alarmTitle;

  /// No description provided for @appTitle.
  ///
  /// In es, this message translates to:
  /// **'MTA - Gestor de Presión Arterial'**
  String get appTitle;

  /// No description provided for @cancel.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In es, this message translates to:
  /// **'Confirmar'**
  String get confirm;

  /// No description provided for @date.
  ///
  /// In es, this message translates to:
  /// **'Fecha'**
  String get date;

  /// No description provided for @day.
  ///
  /// In es, this message translates to:
  /// **'Día'**
  String get day;

  /// No description provided for @delete.
  ///
  /// In es, this message translates to:
  /// **'Eliminar'**
  String get delete;

  /// No description provided for @deleteConfirmMessage.
  ///
  /// In es, this message translates to:
  /// **'¿Estás seguro de que deseas eliminar este elemento?'**
  String get deleteConfirmMessage;

  /// No description provided for @deleteConfirmTitle.
  ///
  /// In es, this message translates to:
  /// **'Confirmar Eliminación'**
  String get deleteConfirmTitle;

  /// No description provided for @deleteMeasurement.
  ///
  /// In es, this message translates to:
  /// **'Eliminar Medición'**
  String get deleteMeasurement;

  /// No description provided for @deleteSchedule.
  ///
  /// In es, this message translates to:
  /// **'Eliminar Horario'**
  String get deleteSchedule;

  /// No description provided for @deleteUser.
  ///
  /// In es, this message translates to:
  /// **'Eliminar Usuario'**
  String get deleteUser;

  /// No description provided for @diastolic.
  ///
  /// In es, this message translates to:
  /// **'Diastól.'**
  String get diastolic;

  /// No description provided for @edit.
  ///
  /// In es, this message translates to:
  /// **'Editar'**
  String get edit;

  /// No description provided for @editMeasurement.
  ///
  /// In es, this message translates to:
  /// **'Editar Medición'**
  String get editMeasurement;

  /// No description provided for @editSchedule.
  ///
  /// In es, this message translates to:
  /// **'Editar Horario'**
  String get editSchedule;

  /// No description provided for @editUser.
  ///
  /// In es, this message translates to:
  /// **'Editar Usuario'**
  String get editUser;

  /// No description provided for @enableNotifications.
  ///
  /// In es, this message translates to:
  /// **'¿Activar notificaciones?'**
  String get enableNotifications;

  /// No description provided for @endDate.
  ///
  /// In es, this message translates to:
  /// **'Fecha Fin'**
  String get endDate;

  /// No description provided for @endTime.
  ///
  /// In es, this message translates to:
  /// **'Hora de Fin'**
  String get endTime;

  /// No description provided for @errorGeneric.
  ///
  /// In es, this message translates to:
  /// **'Se produjo un error'**
  String get errorGeneric;

  /// No description provided for @errorLoadFailed.
  ///
  /// In es, this message translates to:
  /// **'Error al cargar los datos'**
  String get errorLoadFailed;

  /// No description provided for @errorNoUser.
  ///
  /// In es, this message translates to:
  /// **'No se ha seleccionado un usuario'**
  String get errorNoUser;

  /// No description provided for @errorSaveFailed.
  ///
  /// In es, this message translates to:
  /// **'Error al guardar'**
  String get errorSaveFailed;

  /// No description provided for @export.
  ///
  /// In es, this message translates to:
  /// **'Exportar'**
  String get export;

  /// No description provided for @exportButton.
  ///
  /// In es, this message translates to:
  /// **'Exportar'**
  String get exportButton;

  /// No description provided for @exportData.
  ///
  /// In es, this message translates to:
  /// **'Exportar Datos'**
  String get exportData;

  /// No description provided for @exportError.
  ///
  /// In es, this message translates to:
  /// **'Error al exportar'**
  String get exportError;

  /// No description provided for @exportFormat.
  ///
  /// In es, this message translates to:
  /// **'Formato de Exportación'**
  String get exportFormat;

  /// No description provided for @exportSuccess.
  ///
  /// In es, this message translates to:
  /// **'Archivo exportado exitosamente'**
  String get exportSuccess;

  /// No description provided for @fileLocation.
  ///
  /// In es, this message translates to:
  /// **'Ubicación del archivo'**
  String get fileLocation;

  /// No description provided for @fileName.
  ///
  /// In es, this message translates to:
  /// **'Nombre de Archivo'**
  String get fileName;

  /// No description provided for @finish.
  ///
  /// In es, this message translates to:
  /// **'Finalizar'**
  String get finish;

  /// No description provided for @friday.
  ///
  /// In es, this message translates to:
  /// **'Viernes'**
  String get friday;

  /// No description provided for @hasMedication.
  ///
  /// In es, this message translates to:
  /// **'¿Toma medicación?'**
  String get hasMedication;

  /// No description provided for @maxSchedulesReached.
  ///
  /// In es, this message translates to:
  /// **'Se permiten un máximo de 10 horarios'**
  String get maxSchedulesReached;

  /// No description provided for @measurementDetails.
  ///
  /// In es, this message translates to:
  /// **'Detalles de la Medición'**
  String get measurementDetails;

  /// No description provided for @measurementNumber.
  ///
  /// In es, this message translates to:
  /// **'Medición #'**
  String get measurementNumber;

  /// No description provided for @measurements.
  ///
  /// In es, this message translates to:
  /// **'Mediciones'**
  String get measurements;

  /// No description provided for @measurementTime.
  ///
  /// In es, this message translates to:
  /// **'Hora'**
  String get measurementTime;

  /// No description provided for @medicationName.
  ///
  /// In es, this message translates to:
  /// **'Nombre de la Medicación'**
  String get medicationName;

  /// No description provided for @monday.
  ///
  /// In es, this message translates to:
  /// **'Lunes'**
  String get monday;

  /// No description provided for @newUser.
  ///
  /// In es, this message translates to:
  /// **'Nuevo Usuario'**
  String get newUser;

  /// No description provided for @noMeasurementsInRange.
  ///
  /// In es, this message translates to:
  /// **'No hay mediciones en el rango seleccionado'**
  String get noMeasurementsInRange;

  /// No description provided for @note.
  ///
  /// In es, this message translates to:
  /// **'Nota'**
  String get note;

  /// No description provided for @postpone.
  ///
  /// In es, this message translates to:
  /// **'Posponer 10 min'**
  String get postpone;

  /// No description provided for @pulse.
  ///
  /// In es, this message translates to:
  /// **'Pulso'**
  String get pulse;

  /// No description provided for @saturday.
  ///
  /// In es, this message translates to:
  /// **'Sábado'**
  String get saturday;

  /// No description provided for @save.
  ///
  /// In es, this message translates to:
  /// **'Guardar'**
  String get save;

  /// No description provided for @schedules.
  ///
  /// In es, this message translates to:
  /// **'Horarios'**
  String get schedules;

  /// No description provided for @scheduleTime.
  ///
  /// In es, this message translates to:
  /// **'Hora del Horario'**
  String get scheduleTime;

  /// No description provided for @selectDateRange.
  ///
  /// In es, this message translates to:
  /// **'Seleccionar Rango de Fechas'**
  String get selectDateRange;

  /// No description provided for @selectDirectory.
  ///
  /// In es, this message translates to:
  /// **'Seleccionar Directorio'**
  String get selectDirectory;

  /// No description provided for @settings.
  ///
  /// In es, this message translates to:
  /// **'Configuración'**
  String get settings;

  /// No description provided for @startDate.
  ///
  /// In es, this message translates to:
  /// **'Fecha Inicio'**
  String get startDate;

  /// No description provided for @startTime.
  ///
  /// In es, this message translates to:
  /// **'Hora de Inicio'**
  String get startTime;

  /// No description provided for @success.
  ///
  /// In es, this message translates to:
  /// **'Éxito'**
  String get success;

  /// No description provided for @successDeleted.
  ///
  /// In es, this message translates to:
  /// **'Eliminado correctamente'**
  String get successDeleted;

  /// No description provided for @successExported.
  ///
  /// In es, this message translates to:
  /// **'Exportado correctamente'**
  String get successExported;

  /// No description provided for @successSaved.
  ///
  /// In es, this message translates to:
  /// **'Guardado correctamente'**
  String get successSaved;

  /// No description provided for @sunday.
  ///
  /// In es, this message translates to:
  /// **'Domingo'**
  String get sunday;

  /// No description provided for @systolic.
  ///
  /// In es, this message translates to:
  /// **'Sistól.'**
  String get systolic;

  /// No description provided for @takeMeasurement.
  ///
  /// In es, this message translates to:
  /// **'Realizar Medición'**
  String get takeMeasurement;

  /// No description provided for @thursday.
  ///
  /// In es, this message translates to:
  /// **'Jueves'**
  String get thursday;

  /// No description provided for @tuesday.
  ///
  /// In es, this message translates to:
  /// **'Martes'**
  String get tuesday;

  /// No description provided for @userAge.
  ///
  /// In es, this message translates to:
  /// **'Edad'**
  String get userAge;

  /// No description provided for @userName.
  ///
  /// In es, this message translates to:
  /// **'Nombre'**
  String get userName;

  /// No description provided for @users.
  ///
  /// In es, this message translates to:
  /// **'Usuarios'**
  String get users;

  /// No description provided for @validationEndNotFuture.
  ///
  /// In es, this message translates to:
  /// **'La fecha de fin no puede ser posterior a hoy'**
  String get validationEndNotFuture;

  /// No description provided for @validationInvalidNumber.
  ///
  /// In es, this message translates to:
  /// **'Número inválido'**
  String get validationInvalidNumber;

  /// No description provided for @validationRequired.
  ///
  /// In es, this message translates to:
  /// **'Este campo es obligatorio'**
  String get validationRequired;

  /// No description provided for @validationStartBeforeEnd.
  ///
  /// In es, this message translates to:
  /// **'La fecha de inicio debe ser anterior a la fecha de fin'**
  String get validationStartBeforeEnd;

  /// No description provided for @wednesday.
  ///
  /// In es, this message translates to:
  /// **'Miércoles'**
  String get wednesday;
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
