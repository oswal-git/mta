import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mta/core/theme/theme.dart';

class CompactIncrementFieldWidget extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String unit;
  final IconData icon;
  final int min;
  final int max;
  final bool enabled;
  final VoidCallback? onChanged;
  final String? Function(String?)? validator;

  const CompactIncrementFieldWidget({
    super.key,
    required this.label,
    required this.controller,
    required this.unit,
    required this.icon,
    required this.min,
    required this.max,
    this.enabled = true,
    this.onChanged,
    this.validator,
  });

  void _updateValue(int delta) {
    if (!enabled) return;
    final int currentValue = int.tryParse(controller.text) ?? min;
    final int newValue = currentValue + delta;
    if (newValue >= min && newValue <= max) {
      controller.text = newValue.toString();
      onChanged?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: AppSpacing.pAllXs,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon,
                    size: AppIcons.xs,
                    color: enabled ? null : AppColors.textSecondary),
                const SizedBox(width: 3),
                Text(
                  label,
                  style: AppTypography.small.copyWith(
                    fontWeight: FontWeight.w500,
                    color: enabled ? null : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.gapXs),
            Row(
              children: [
                IconButton(
                  onPressed: enabled ? () => _updateValue(-1) : null,
                  icon: const Icon(Icons.remove_circle_outline),
                  iconSize: AppIcons.navIcon,
                  padding: EdgeInsets.zero,
                  constraints:
                      const BoxConstraints(minWidth: 28, minHeight: 28),
                  color: enabled
                      ? Theme.of(context).colorScheme.primary
                      : AppColors.textSecondary,
                ),
                Expanded(
                  child: IntrinsicHeight(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          constraints: const BoxConstraints(minHeight: 32),
                          child: TextFormField(
                            controller: controller,
                            enabled: enabled,
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            style: AppTypography.h2.copyWith(
                              height: 1.0,
                              color: enabled ? null : AppColors.textSecondary,
                            ),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(vertical: 4),
                              isDense: true,
                            ),
                            validator: validator,
                            onChanged: (_) => onChanged?.call(),
                            onTap: () {
                              if (enabled) {
                                controller.selection = TextSelection(
                                  baseOffset: 0,
                                  extentOffset: controller.text.length,
                                );
                              }
                            },
                          ),
                        ),
                        Text(
                          unit,
                          style: AppTypography.micro.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                IconButton(
                  onPressed: enabled ? () => _updateValue(1) : null,
                  icon: const Icon(Icons.add_circle_outline),
                  iconSize: AppIcons.navIcon,
                  padding: EdgeInsets.zero,
                  constraints:
                      const BoxConstraints(minWidth: 28, minHeight: 28),
                  color: enabled
                      ? Theme.of(context).colorScheme.primary
                      : AppColors.textSecondary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
