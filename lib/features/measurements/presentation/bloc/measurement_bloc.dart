import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mta/features/measurements/domain/entities/measurement_entity.dart';
import 'package:mta/features/measurements/domain/usecases/create_measurement.dart';
import 'package:mta/features/measurements/domain/usecases/delete_measurement.dart';
import 'package:mta/features/measurements/domain/usecases/get_measurement_by_id.dart';
import 'package:mta/features/measurements/domain/usecases/get_measurements.dart';
import 'package:mta/features/measurements/domain/usecases/get_next_measurement_number.dart';
import 'package:mta/features/measurements/domain/usecases/update_measurement.dart';
import 'package:mta/features/measurements/presentation/bloc/measurement_event.dart';
import 'package:mta/features/measurements/presentation/bloc/measurement_state.dart';

class MeasurementBloc extends Bloc<MeasurementEvent, MeasurementState> {
  final GetMeasurements getMeasurements;
  final GetMeasurementById getMeasurementById;
  final CreateMeasurement createMeasurement;
  final UpdateMeasurement updateMeasurement;
  final DeleteMeasurement deleteMeasurement;
  final GetNextMeasurementNumber getNextMeasurementNumber;

  MeasurementBloc({
    required this.getMeasurements,
    required this.getMeasurementById,
    required this.createMeasurement,
    required this.updateMeasurement,
    required this.deleteMeasurement,
    required this.getNextMeasurementNumber,
  }) : super(MeasurementInitial()) {
    on<LoadMeasurementsEvent>(_onLoadMeasurements);
    on<LoadMeasurementByIdEvent>(_onLoadMeasurementById);
    on<CreateMeasurementEvent>(_onCreateMeasurement);
    on<UpdateMeasurementEvent>(_onUpdateMeasurement);
    on<DeleteMeasurementEvent>(_onDeleteMeasurement);
    on<GetNextMeasurementNumberEvent>(_onGetNextMeasurementNumber);
    on<ResetMeasurementStateEvent>(_onResetState);
  }

  Future<void> _onLoadMeasurements(
    LoadMeasurementsEvent event,
    Emitter<MeasurementState> emit,
  ) async {
    emit(MeasurementLoading());

    final result = await getMeasurements(
      GetMeasurementsParams(userId: event.userId),
    );

    result.fold(
      (failure) => emit(MeasurementError(failure.message)),
      (measurements) => emit(MeasurementsLoaded(
        measurements: measurements,
        userId: event.userId,
      )),
    );
  }

  Future<void> _onLoadMeasurementById(
    LoadMeasurementByIdEvent event,
    Emitter<MeasurementState> emit,
  ) async {
    emit(MeasurementLoading());

    final result = await getMeasurementById(
      GetMeasurementByIdParams(id: event.id),
    );

    result.fold(
      (failure) => emit(MeasurementError(failure.message)),
      (measurement) => emit(MeasurementDetailLoaded(measurement)),
    );
  }

  Future<void> _onCreateMeasurement(
    CreateMeasurementEvent event,
    Emitter<MeasurementState> emit,
  ) async {
    emit(MeasurementLoading());

    final result = await createMeasurement(
      CreateMeasurementParams(measurement: event.measurement),
    );

    result.fold(
      (failure) => emit(MeasurementError(failure.message)),
      (measurement) {
        emit(MeasurementOperationSuccess(
          'Measurement saved successfully',
          userId: measurement.userId,
        ));
        // ✅ NUEVO: Cancelar notificaciones del horario de esta medición
        _cancelNotificationsForMeasurementTime(measurement);
      },
    );
  }

  Future<void> _onUpdateMeasurement(
    UpdateMeasurementEvent event,
    Emitter<MeasurementState> emit,
  ) async {
    emit(MeasurementLoading());

    final result = await updateMeasurement(
      UpdateMeasurementParams(measurement: event.measurement),
    );

    result.fold(
      (failure) => emit(MeasurementError(failure.message)),
      (measurement) {
        emit(MeasurementOperationSuccess(
          'Measurement updated successfully',
          userId: measurement.userId,
        ));
      },
    );
  }

  Future<void> _onDeleteMeasurement(
    DeleteMeasurementEvent event,
    Emitter<MeasurementState> emit,
  ) async {
    emit(MeasurementLoading());

    final result = await deleteMeasurement(
      DeleteMeasurementParams(id: event.id),
    );

    result.fold(
      (failure) => emit(MeasurementError(failure.message)),
      (_) => emit(MeasurementOperationSuccess(
        'Measurement deleted successfully',
        userId: event.userId,
      )),
    );
  }

  Future<void> _onGetNextMeasurementNumber(
    GetNextMeasurementNumberEvent event,
    Emitter<MeasurementState> emit,
  ) async {
    final result = await getNextMeasurementNumber(
      GetNextMeasurementNumberParams(
        userId: event.userId,
        date: event.date,
      ),
    );

    result.fold(
      (failure) => emit(MeasurementError(failure.message)),
      (number) => emit(MeasurementNumberLoaded(number)),
    );
  }

  /// Resetea el estado del BLoC a inicial
  void _onResetState(
    ResetMeasurementStateEvent event,
    Emitter<MeasurementState> emit,
  ) {
    debugPrint('🔄 Resetting MeasurementBloc state');
    emit(MeasurementInitial());
  }

  /// Cancela notificaciones activas que correspondan al horario de esta medición
  Future<void> _cancelNotificationsForMeasurementTime(
    MeasurementEntity measurement,
  ) async {
    try {
      // final alarmBloc = sl<AlarmBloc>(); // Obtener desde DI

      // Obtener la hora de la medición (redondear a la hora más cercana)
      final measurementTime = measurement.measurementTime;
      final roundedHour = measurementTime.hour;
      final roundedMinute = (measurementTime.minute / 15).round() * 15;

      debugPrint('🔍 Buscando notificaciones para cancelar...');
      debugPrint('   Medición registrada a las: $roundedHour:$roundedMinute');

      // Aquí deberías tener acceso a las alarmas activas
      // y cancelar la que corresponda a este horario

      // Por ahora, esta lógica se puede implementar en el AlarmRepository
      // alarmBloc.add(CancelAlarmForTime(roundedHour, roundedMinute));
    } catch (e) {
      debugPrint('⚠️ Error al cancelar notificaciones: $e');
      // No lanzar error, solo registrar
    }
  }
}
