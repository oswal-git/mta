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

  /// Indica si el sonido está habilitado para esta notificación
  final bool soundEnabled;

  /// URI del sonido personalizado (si existe)
  final String? soundUri;

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
    this.soundEnabled = true,
    this.soundUri,
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
        soundEnabled,
        soundUri,
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
    bool? soundEnabled,
    String? soundUri,
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
      soundEnabled: soundEnabled ?? this.soundEnabled,
      soundUri: soundUri ?? this.soundUri,
      isActive: isActive ?? this.isActive,
    );
  }

  /// Convierte el String ID a int para las notificaciones locales de forma DETERMINISTA.
  /// No usa String.hashCode porque no es estable entre ejecuciones o reinicios.
  int get notificationId {
    // Si el ID contiene un número largo (como un timestamp), intentamos usarlo directamente
    final numericPart = id.replaceAll(RegExp(r'[^0-9]'), '');
    if (numericPart.length >= 9) {
      // Usamos los últimos 9 dígitos para asegurar que quepa en un int de 31 bits
      return int.parse(numericPart.substring(numericPart.length - 9));
    }

    // Fallback: Hash determinista simple (similar a Java String.hashCode)
    int hash = 0;
    for (int i = 0; i < id.length; i++) {
      hash = (31 * hash + id.codeUnitAt(i)) & 0x7FFFFFFF;
    }
    return hash;
  }
}
