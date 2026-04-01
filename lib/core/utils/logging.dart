import 'package:intl/intl.dart';

/// Función global para estandarizar los logs del sistema con marcas de tiempo e iconos.
///
/// [symbol] define el icono a mostrar
///
String fechaD([String symbol = ' ']) {
  final now = DateTime.now();
  final timeStr = DateFormat('HH:mm:ss').format(now);

  final icon = symbol.substring(0, 1).toLowerCase();

  return '$timeStr -$icon ';
}
