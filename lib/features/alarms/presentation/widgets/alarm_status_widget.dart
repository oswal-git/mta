import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mta/features/alarms/domain/entities/alarm_entity.dart';
import 'package:mta/features/alarms/presentation/bloc/alarm_bloc.dart';
import 'package:mta/features/alarms/presentation/bloc/alarm_event.dart';
import 'package:mta/features/alarms/presentation/bloc/alarm_state.dart';

/// Widget que muestra el estado de las alarmas y permite reprogramarlas
class AlarmStatusWidget extends StatelessWidget {
  final String userId; // Cambiado a String

  const AlarmStatusWidget({
    super.key,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AlarmBloc, AlarmState>(
      listener: (context, state) {
        if (state is UserAlarmsSet) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
            ),
          );
        } else if (state is AlarmError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        return Card(
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.alarm,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Alarmas de Medicación',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                Text(
                  'Las alarmas sonarán 5 minutos antes de cada toma programada.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),

                const SizedBox(height: 16),

                if (state is AlarmLoading)
                  const Center(child: CircularProgressIndicator())
                else
                  ElevatedButton.icon(
                    onPressed: () {
                      context.read<AlarmBloc>().add(SetAlarmsForUser(userId));
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reprogramar Alarmas'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                    ),
                  ),

                const SizedBox(height: 8),

                // 🧪 BOTÓN DE PRUEBA TEMPORAL
                OutlinedButton.icon(
                  onPressed: () {
                    // Crear una notificación de prueba que aparezca en 10 segundos
                    // y se regenere automáticamente cada 30 segundos
                    final testAlarm = AlarmEntity(
                      id: 'test_${DateTime.now().millisecondsSinceEpoch}',
                      scheduleId: 'test',
                      userId: userId,
                      userName: 'PRUEBA',
                      alarmTime: DateTime.now()
                          .add(const Duration(minutes: 5, seconds: 15)),
                      title: '🧪 NOTIFICACIÓN DE PRUEBA',
                      body: 'Esta notificación se repetirá cada 30 segundos',
                      label: 'Prueba',
                      medication: 'Test',
                      isActive: true,
                    );

                    context.read<AlarmBloc>().add(SetAlarm(testAlarm));

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('🔔 Notificación de prueba programada\n'
                            'Aparecerá en 10 segundos y se repetirá cada 30 segundos\n'
                            'hasta que la canceles o pase 1 hora'),
                        backgroundColor: Colors.blue,
                        duration: Duration(seconds: 5),
                      ),
                    );
                  },
                  icon: const Icon(Icons.science),
                  label: const Text('Probar Notificación Persistente'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.blue,
                    minimumSize: const Size(double.infinity, 48),
                  ),
                ),

                const SizedBox(height: 8),

                TextButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (dialogContext) => AlertDialog(
                        title: const Text('Cancelar todas las alarmas'),
                        content: const Text(
                          '¿Estás seguro de que quieres cancelar todas las alarmas programadas?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(dialogContext).pop(),
                            child: const Text('Cancelar'),
                          ),
                          TextButton(
                            onPressed: () {
                              context
                                  .read<AlarmBloc>()
                                  .add(const CancelAllAlarms());
                              Navigator.of(dialogContext).pop();
                            },
                            child: const Text(
                              'Confirmar',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  icon: const Icon(Icons.cancel),
                  label: const Text('Cancelar Todas las Alarmas'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                    minimumSize: const Size(double.infinity, 48),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
