// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get accept => 'Aceptar';

  @override
  String get activeUser => 'Usuario Activo';

  @override
  String get addMeasurement => 'Agregar Medición';

  @override
  String get addNoteHint => 'Añade una nota...';

  @override
  String get addSchedule => 'Agregar Horario';

  @override
  String get addUser => 'Agregar Usuario';

  @override
  String get alertManagement => 'Gestión de Alertas';

  @override
  String get appTitle => 'MTA - Gestor de Presión Arterial';

  @override
  String get backToHome => 'Volver al inicio';

  @override
  String get bloodPressureMonitorModel => 'Marca y modelo del tensiómetro';

  @override
  String get bloodPressureReference => 'Referencia de Presión Arterial';

  @override
  String get cancel => 'Cancelar';

  @override
  String get cancelNotification => 'Cancelar notificación';

  @override
  String get close => 'Cerrar';

  @override
  String get confirm => 'Confirmar';

  @override
  String get customSound => 'Sonido personalizado';

  @override
  String get date => 'Fecha';

  @override
  String get day => 'Día';

  @override
  String get defaultOption => 'Predeterminado';

  @override
  String get defaultSound => 'Sonido predeterminado';

  @override
  String get defaultUsername => 'usuario';

  @override
  String get delete => 'Eliminar';

  @override
  String get deleteConfirmMessage =>
      '¿Estás seguro de que deseas eliminar este elemento?';

  @override
  String get deleteConfirmTitle => 'Confirmar Eliminación';

  @override
  String get deleteMeasurement => 'Eliminar Medición';

  @override
  String get deleteSchedule => 'Eliminar Horario';

  @override
  String get deleteUser => 'Eliminar Usuario';

  @override
  String get diastole => 'Diástole';

  @override
  String get diastoleValidation => 'Diástole debe estar entre 30 y 150';

  @override
  String get diastolic => 'Diastól.';

  @override
  String get discardChanges => '¿Descartar cambios?';

  @override
  String get edit => 'Editar';

  @override
  String get editMeasurement => 'Editar Medición';

  @override
  String get editSchedule => 'Editar Horario';

  @override
  String get editUser => 'Editar Usuario';

  @override
  String get elevated => 'Elevada';

  @override
  String get enableNotifications => '¿Activar notificaciones?';

  @override
  String get endDate => 'Fecha Fin';

  @override
  String get endTime => 'Hora de Fin';

  @override
  String get english => 'Inglés';

  @override
  String get errorGeneric => 'Se produjo un error';

  @override
  String get errorLoadFailed => 'Error al cargar los datos';

  @override
  String get errorNoUser => 'No se ha seleccionado un usuario';

  @override
  String get errorSaveFailed => 'Error al guardar';

  @override
  String get exactAlarmsPermission => 'Alarmas Exactas';

  @override
  String get exit => 'Salir';

  @override
  String get export => 'Exportar';

  @override
  String get exportButton => 'Exportar';

  @override
  String get exportData => 'Exportar Datos';

  @override
  String get exportError => 'Error al exportar';

  @override
  String get exportFormat => 'Formato de Exportación';

  @override
  String get exportHeaderDate => 'Fecha';

  @override
  String get exportHeaderDay => 'Día';

  @override
  String get exportHeaderTime => 'Hora';

  @override
  String get exportHeaderSystolic => 'Sistólica (mmHg)';

  @override
  String get exportHeaderDiastolic => 'Diastólica (mmHg)';

  @override
  String get exportHeaderPulse => 'Pulsaciones (bpm)';

  @override
  String get exportHeaderModel => 'Modelo';

  @override
  String get exportHeaderPeriod => 'Período';

  @override
  String get exportHeaderZone => 'Zona';

  @override
  String get exportHeaderNote => 'Nota';

  @override
  String get exportPdfTitle => 'Listado de Mediciones de Tensión Arterial';

  @override
  String get exportHeaderSystolicShort => 'Sist.\n(mmHg)';

  @override
  String get exportHeaderDiastolicShort => 'Diast.\n(mmHg)';

  @override
  String get exportHeaderPulseShort => 'Puls.\n(bpm)';

  @override
  String get exporting => 'Exportando...';

  @override
  String get exportSuccess => 'Archivo exportado exitosamente';

  @override
  String get fileLocation => 'Ubicación del archivo';

  @override
  String get fileName => 'Nombre de Archivo';

  @override
  String get finish => 'Finalizar';

  @override
  String get fixPermissions => 'CORREGIR PERMISOS';

  @override
  String get formatCsv => 'CSV';

  @override
  String get formatExcel => 'Excel (XLSX)';

  @override
  String get formatPdf => 'PDF';

  @override
  String get friday => 'Viernes';

  @override
  String get hasMeasuring => '¿Toma medición?';

  @override
  String get high => 'Alta';

  @override
  String get language => 'Idioma';

  @override
  String get languageSelection => 'Selección de Idioma';

  @override
  String get markAsTaken => 'Marcar como tomada';

  @override
  String maxSchedulesAllowed(Object count) {
    return 'Máximo $count horarios permitidos';
  }

  @override
  String get maxSchedulesReached => 'Se permiten un máximo de 10 horarios';

  @override
  String get measurementDetails => 'Detalles de la Medición';

  @override
  String get measurementLabel => 'Medición';

  @override
  String get measurementLocation => 'Zona de medición';

  @override
  String get locationNotIndicated => 'Sin indicar';

  @override
  String get locationLeftArm => 'Brazo izquierdo';

  @override
  String get locationLeftWrist => 'Muñeca izquierda';

  @override
  String get locationRightArm => 'Brazo derecho';

  @override
  String get locationRightWrist => 'Muñeca derecha';

  @override
  String get measurementNumber => 'Medición #';

  @override
  String get measurements => 'Mediciones';

  @override
  String get measurementTime => 'Hora';

  @override
  String measurementTitle(Object number) {
    return 'Medición $number';
  }

  @override
  String get medicationName => 'Nombre de la Medicación';

  @override
  String get minutesShort => 'min';

  @override
  String get monday => 'Lunes';

  @override
  String get newUser => 'Nuevo Usuario';

  @override
  String get next => 'Siguiente';

  @override
  String get noMeasurementsAvailable => 'No hay mediciones disponibles';

  @override
  String get noMeasurementsInRange =>
      'No hay mediciones en el rango seleccionado';

  @override
  String get normal => 'Normal';

  @override
  String get noSchedulesYet => 'Aún no hay horarios';

  @override
  String get noSoundsFound => 'No se encontraron sonidos';

  @override
  String get note => 'Nota';

  @override
  String get noteOptional => 'Nota (opcional)';

  @override
  String get notificationBody =>
      'Es hora de realizar tu medición de presión arterial';

  @override
  String notificationSnoozedMessage(Object minutes) {
    return 'Notificación pospuesta por $minutes minutos';
  }

  @override
  String get notificationSounds => 'Sonido en notificaciones';

  @override
  String get notificationSoundsSubtitle =>
      'Reproducir sonido al recibir alertas';

  @override
  String get notificationsPermission => 'Notificaciones';

  @override
  String get notificationTitle => 'Medición de Presión Arterial';

  @override
  String get noUsers => 'Sin usuarios';

  @override
  String get noUserSelected => 'Ningún usuario seleccionado';

  @override
  String get ok => 'OK';

  @override
  String get postpone => 'Posponer 10 min';

  @override
  String get pulse => 'Pulso';

  @override
  String get pulseValidation => 'Pulso debe estar entre 30 y 200';

  @override
  String get reminderLabel => 'Recordatorio';

  @override
  String get saturday => 'Sábado';

  @override
  String get save => 'Guardar';

  @override
  String get scheduledTimeLabel => 'Hora programada';

  @override
  String get schedules => 'Horarios';

  @override
  String get scheduleTime => 'Hora del Horario';

  @override
  String get selectDateRange => 'Seleccionar Rango de Fechas';

  @override
  String get selectDirectory => 'Seleccionar Directorio';

  @override
  String get selectSound => 'Seleccionar sonido';

  @override
  String get selectSoundTitle => 'Seleccionar Sonido';

  @override
  String get settings => 'Configuración';

  @override
  String get spanish => 'Español';

  @override
  String get startDate => 'Fecha Inicio';

  @override
  String get startTime => 'Hora de Inicio';

  @override
  String get stay => 'Quedarse';

  @override
  String get success => 'Éxito';

  @override
  String get successDeleted => 'Eliminado correctamente';

  @override
  String get successExported => 'Exportado correctamente';

  @override
  String get successSaved => 'Guardado correctamente';

  @override
  String get sunday => 'Domingo';

  @override
  String get syncAlertsToolip => 'Sincronizar Alertas (Emergencia)';

  @override
  String get systole => 'Sístole';

  @override
  String get systoleDiastoleElevated => 'Sístole 130-139\nDiástole 85-89';

  @override
  String get systoleDiastoleHigh => 'Sístole ≥ 140\nDiástole ≥ 90';

  @override
  String get systoleDiastoleNormal => 'Sístole < 130\nDiástole < 85';

  @override
  String get systoleValidation => 'Sístole debe estar entre 50 y 250';

  @override
  String get systolic => 'Sistól.';

  @override
  String get takeMeasurement => 'Realizar Medición';

  @override
  String get tapPlusToAdd => 'Toca el botón + para agregar tu primer horario';

  @override
  String get thursday => 'Jueves';

  @override
  String get timeOfMeasurement => 'Hora de la medición';

  @override
  String get tuesday => 'Martes';

  @override
  String get unknownOption => 'Desconocido';

  @override
  String get unsavedChangesMessage =>
      'Tienes cambios sin guardar. ¿Deseas salir sin guardar?';

  @override
  String get userAge => 'Edad';

  @override
  String get userName => 'Nombre';

  @override
  String get users => 'Usuarios';

  @override
  String get valencian => 'Valenciano';

  @override
  String get validationEndNotFuture =>
      'La fecha de fin no puede ser posterior a hoy';

  @override
  String get validationInvalidNumber => 'Número inválido';

  @override
  String get validationRequired => 'Este campo es obligatorio';

  @override
  String get validationStartBeforeEnd =>
      'La fecha de inicio debe ser anterior a la fecha de fin';

  @override
  String get wednesday => 'Miércoles';
}
