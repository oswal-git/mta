import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:mta/core/l10n/app_localizations.dart';
import 'package:mta/core/theme/theme.dart';
import 'package:mta/features/measurements/presentation/bloc/measurement_bloc.dart';
import 'package:mta/features/measurements/presentation/bloc/measurement_event.dart';
import 'package:mta/features/measurements/presentation/bloc/measurement_state.dart';
import 'package:mta/features/users/presentation/bloc/user_bloc.dart';
import 'package:mta/features/users/presentation/bloc/user_state.dart';

class ClearMeasurementsPage extends StatefulWidget {
  const ClearMeasurementsPage({super.key});

  @override
  State<ClearMeasurementsPage> createState() => _ClearMeasurementsPageState();
}

class _ClearMeasurementsPageState extends State<ClearMeasurementsPage> {
  DateTime? _startDate;
  DateTime? _endDate;
  bool _noLimitFrom = true;
  bool _noLimitTo = true;

  @override
  void initState() {
    super.initState();
    _startDate = DateTime.now().subtract(const Duration(days: 30));
    _endDate = DateTime.now();
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final initialDate =
        isStart ? (_startDate ?? DateTime.now()) : (_endDate ?? DateTime.now());

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null && mounted) {
      setState(() {
        if (isStart) {
          _startDate = pickedDate;
          if (_endDate != null && _startDate!.isAfter(_endDate!)) {
            _endDate = _startDate;
          }
        } else {
          _endDate = pickedDate;
          if (_startDate != null && _endDate!.isBefore(_startDate!)) {
            _startDate = _endDate;
          }
        }
      });
    }
  }

  void _confirmAndClear(BuildContext context, String userId, String userName) {
    final l10n = AppLocalizations.of(context);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.clearMeasurementsTitle),
        content: Text(l10n.confirmDeleteMeasurements),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<MeasurementBloc>().add(
                    ClearMeasurementsByDateRangeEvent(
                      userId: userId,
                      startDate: _noLimitFrom ? null : _startDate,
                      endDate: _noLimitTo ? null : _endDate,
                      userName: userName,
                    ),
                  );
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }

  void _showSummaryDialog(
      BuildContext context, ClearMeasurementsSuccess state) {
    final l10n = AppLocalizations.of(context);

    if (state.count == 0) {
      showDialog(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(l10n.clearMeasurementsTitle),
          content: Text(l10n.noMeasurementsToDelete),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(l10n.accept),
            ),
          ],
        ),
      );
      return;
    }

    final formatShortName = DateFormat('MM/dd/yyyy');

    final hasStart = !_noLimitFrom && _startDate != null;
    final hasEnd = !_noLimitTo && _endDate != null;

    String summaryText = '';
    if (hasStart && hasEnd) {
      summaryText = l10n.deleteMeasurementsSummaryBoth(
          formatShortName.format(_startDate!),
          formatShortName.format(_endDate!));
    } else if (hasStart && !hasEnd) {
      summaryText = l10n
          .deleteMeasurementsSummaryFrom(formatShortName.format(_startDate!));
    } else if (!hasStart && hasEnd) {
      summaryText = l10n
          .deleteMeasurementsSummaryUntil(formatShortName.format(_endDate!));
    } else {
      summaryText = l10n.deleteMeasurementsSummaryAll;
    }

    String cleanPath = state.backupPath ?? '';
    if (cleanPath.startsWith('/storage/emulated/0/')) {
      cleanPath = cleanPath.replaceFirst('/storage/emulated/0/', '');
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.success),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(summaryText),
            const SizedBox(height: AppSpacing.gapSm),
            if (state.backupPath != null) Text(l10n.backupSavedIn(cleanPath)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.pop(); // Return to HomePage
            },
            child: Text(l10n.accept),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    // We need the active user ID to clear their measurements
    final userState = context.read<UserBloc>().state;
    final String? userId =
        userState is UsersLoaded ? userState.activeUser?.id : null;
    final String? userName =
        userState is UsersLoaded ? userState.activeUser?.name : null;

    return BlocListener<MeasurementBloc, MeasurementState>(
      listener: (context, state) {
        if (state is ClearMeasurementsSuccess) {
          // Re-load the measurements in the background
          context
              .read<MeasurementBloc>()
              .add(LoadMeasurementsEvent(state.userId));
          _showSummaryDialog(context, state);
        } else if (state is MeasurementError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.clearMeasurementsTitle),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
          actions: [
            if (userId != null)
              IconButton(
                icon: const Icon(Icons.delete_sweep),
                tooltip: l10n.clearMeasurements,
                onPressed: () =>
                    _confirmAndClear(context, userId, userName ?? 'usuario'),
              ),
          ],
        ),
        body: userId == null
            ? Center(child: Text(l10n.errorNoUser))
            : BlocBuilder<MeasurementBloc, MeasurementState>(
                builder: (context, state) {
                  if (state is MeasurementLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Start Date Section
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(AppSpacing.md),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      l10n.startDate,
                                      style: theme.textTheme.titleMedium,
                                    ),
                                    Row(
                                      children: [
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(right: 8.0),
                                          child: Text(l10n.noLimitFrom),
                                        ),
                                        Switch(
                                          value: _noLimitFrom,
                                          onChanged: (value) {
                                            setState(() {
                                              _noLimitFrom = value;
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                if (!_noLimitFrom) ...[
                                  const SizedBox(height: AppSpacing.gapSm),
                                  ListTile(
                                    title: Text(
                                      _startDate != null
                                          ? DateFormat.yMMMd()
                                              .format(_startDate!)
                                          : l10n.startDate,
                                    ),
                                    trailing: const Icon(Icons.calendar_today),
                                    shape: RoundedRectangleBorder(
                                      side:
                                          BorderSide(color: theme.dividerColor),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    onTap: () => _selectDate(context, true),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: AppSpacing.gapMd),

                        // End Date Section
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(AppSpacing.md),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      l10n.endDate,
                                      style: theme.textTheme.titleMedium,
                                    ),
                                    Row(
                                      children: [
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(right: 8.0),
                                          child: Text(l10n.noLimitTo),
                                        ),
                                        Switch(
                                          value: _noLimitTo,
                                          onChanged: (value) {
                                            setState(() {
                                              _noLimitTo = value;
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                if (!_noLimitTo) ...[
                                  const SizedBox(height: AppSpacing.gapSm),
                                  ListTile(
                                    title: Text(
                                      _endDate != null
                                          ? DateFormat.yMMMd().format(_endDate!)
                                          : l10n.endDate,
                                    ),
                                    trailing: const Icon(Icons.calendar_today),
                                    shape: RoundedRectangleBorder(
                                      side:
                                          BorderSide(color: theme.dividerColor),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    onTap: () => _selectDate(context, false),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}
