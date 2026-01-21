import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mta/core/utils/constants.dart';
import 'package:mta/features/measurements/domain/entities/measurement_entity.dart';
import 'package:mta/core/theme/theme.dart';

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
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border(
            bottom: BorderSide(
              color: AppColors.border,
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            // Date
            Expanded(
              flex: 5,
              child: Text(
                dateFormat.format(measurement.measurementTime),
                style: AppTypography.bodySmall,
              ),
            ),
            // Day
            Expanded(
              flex: 4,
              child: Text(
                getDayName(measurement.measurementTime),
                style: AppTypography.bodySmall,
              ),
            ),
            // Time
            Expanded(
              flex: 3,
              child: Text(
                timeFormat.format(measurement.measurementTime),
                style: AppTypography.bodySmall
                    .copyWith(fontWeight: FontWeight.w500),
              ),
            ),
            // Systolic
            Expanded(
              flex: 3,
              child: Text(
                measurement.systolic.toString(),
                style: AppTypography.bodyMedium
                    .copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            // Diastolic
            Expanded(
              flex: 3,
              child: Text(
                measurement.diastolic.toString(),
                style: AppTypography.bodyMedium
                    .copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            // Pulse
            Expanded(
              flex: 3,
              child: Text(
                measurement.pulse?.toString() ?? '-',
                style: AppTypography.bodySmall,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
