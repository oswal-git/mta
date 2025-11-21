import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mta/core/utils/constants.dart';
import 'package:mta/features/measurements/domain/entities/measurement_entity.dart';

class MeasurementListItem extends StatelessWidget {
  final MeasurementEntity measurement;
  final VoidCallback onTap;

  const MeasurementListItem({
    super.key,
    required this.measurement,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final timeFormat = DateFormat('HH:mm');

    // Get localized day name
    String getDayName(DateTime date) {
      final locale = Localizations.localeOf(context).languageCode;
      final dayFormat = DateFormat('EEEE', locale);
      return dayFormat.format(date);
    }

    final backgroundColor = getBloodPressureColor(
      measurement.systolic,
      measurement.diastolic,
    );

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border(
            bottom: BorderSide(
              color: Colors.grey[300]!,
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            // Date
            Expanded(
              flex: 2,
              child: Text(
                dateFormat.format(measurement.measurementTime),
                style: const TextStyle(fontSize: 13),
              ),
            ),
            // Day
            Expanded(
              flex: 2,
              child: Text(
                getDayName(measurement.measurementTime),
                style: const TextStyle(fontSize: 13),
              ),
            ),
            // Time
            Expanded(
              flex: 1,
              child: Text(
                timeFormat.format(measurement.measurementTime),
                style:
                    const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
              ),
            ),
            // Systolic
            Expanded(
              flex: 1,
              child: Text(
                measurement.systolic.toString(),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            // Diastolic
            Expanded(
              flex: 1,
              child: Text(
                measurement.diastolic.toString(),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            // Pulse
            Expanded(
              flex: 1,
              child: Text(
                measurement.pulse?.toString() ?? '-',
                style: const TextStyle(fontSize: 13),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
