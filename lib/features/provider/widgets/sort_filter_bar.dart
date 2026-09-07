import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../domain/entities/provider_sort.dart';

/// Horizontal sort chips for the provider list.
class SortFilterBar extends StatelessWidget {
  const SortFilterBar({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final ProviderSort selected;
  final ValueChanged<ProviderSort> onSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spaceMd,
        vertical: AppConstants.spaceSm,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (final sort in ProviderSort.values) ...[
              ChoiceChip(
                label: Text(sort.label),
                selected: sort == selected,
                onSelected: (_) => onSelected(sort),
                selectedColor: AppTheme.primary,
                labelStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: sort == selected
                          ? AppTheme.onPrimary
                          : AppTheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(width: AppConstants.spaceSm),
            ],
          ],
        ),
      ),
    );
  }
}
