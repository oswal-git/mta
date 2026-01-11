import 'package:equatable/equatable.dart';

/// Entidad que representa una notificacion programada para una toma de medición
class NotificationEntity extends Equatable {
  /// ID único de la notificacion (coincide con el ID del schedule)
  final String id;

  /// ID del schedule asociado
  final String scheduleId;

  /// ID del usuario destinatario
  final String userId;

  /// Nombre del usuario destinatario
  final String userName;

  /// Fecha y hora exacta en que saltará la notification
  final DateTime notificationTime;

  /// Título de la notificacion
  final String title;

  /// Mensaje descriptivo de la notification
  final String body;

  /// Etiqueta personalizada del recordatorio (si existe)
  final String? label;

  /// Medicación del usuario (si existe)
  final String? medication;

  /// Indica si la notificacion está activa
  final bool isActive;

  const NotificationEntity({
    required this.id,
    required this.scheduleId,
    required this.userId,
    required this.userName,
    required this.notificationTime,
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
        notificationTime,
        title,
        body,
        label,
        medication,
        isActive,
      ];

  /// Crea una copia con los campos modificados
  NotificationEntity copyWith({
    String? id,
    String? scheduleId,
    String? userId,
    String? userName,
    DateTime? notificationTime,
    String? title,
    String? body,
    String? label,
    String? medication,
    bool? isActive,
  }) {
    return NotificationEntity(
      id: id ?? this.id,
      scheduleId: scheduleId ?? this.scheduleId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      notificationTime: notificationTime ?? this.notificationTime,
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
