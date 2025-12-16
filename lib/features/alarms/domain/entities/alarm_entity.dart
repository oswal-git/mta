import 'package:equatable/equatable.dart';

/// Entidad que representa una alarma programada para una toma de medicación
class AlarmEntity extends Equatable {
  /// ID único de la alarma (coincide con el ID del schedule)
  final String id;

  /// ID del schedule asociado
  final String scheduleId;

  /// ID del usuario destinatario
  final String userId;

  /// Nombre del usuario destinatario
  final String userName;

  /// Fecha y hora exacta en que sonará la alarma
  final DateTime alarmTime;

  /// Título de la alarma
  final String title;

  /// Mensaje descriptivo de la alarma
  final String body;

  /// Etiqueta personalizada del recordatorio (si existe)
  final String? label;

  /// Medicación del usuario (si existe)
  final String? medication;

  /// Indica si la alarma está activa
  final bool isActive;

  const AlarmEntity({
    required this.id,
    required this.scheduleId,
    required this.userId,
    required this.userName,
    required this.alarmTime,
    required this.title,
    required this.body,
    this.label,
    this.medication,
    this.isActive = true,
  });

  @override
  List<Object?> get props => [
        id,
        scheduleId,
        userId,
        userName,
        alarmTime,
        title,
        body,
        label,
        medication,
        isActive,
      ];

  /// Crea una copia con los campos modificados
  AlarmEntity copyWith({
    String? id,
    String? scheduleId,
    String? userId,
    String? userName,
    DateTime? alarmTime,
    String? title,
    String? body,
    String? label,
    String? medication,
    bool? isActive,
  }) {
    return AlarmEntity(
      id: id ?? this.id,
      scheduleId: scheduleId ?? this.scheduleId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      alarmTime: alarmTime ?? this.alarmTime,
      title: title ?? this.title,
      body: body ?? this.body,
      label: label ?? this.label,
      medication: medication ?? this.medication,
      isActive: isActive ?? this.isActive,
    );
  }

  /// Convierte el String ID a int para las notificaciones locales
  /// Usa el hashCode del ID para generar un int único
  int get notificationId => id.hashCode.abs();
}
