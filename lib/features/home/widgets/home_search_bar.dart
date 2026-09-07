import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';

/// Inert search field for the Home screen — search lands in a later phase,
/// so this renders the field styling without a text input.
class HomeSearchBar extends StatelessWidget {
  const HomeSearchBar({super.key, required this.hint});

  final String hint;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceMd),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusPill),
        border: Border.all(color: AppTheme.divider, width: 1.5),
      ),
      child: Row(
        children: [
          const Icon(Icons.search_rounded, size: 20, color: AppTheme.textHint),
          const SizedBox(width: AppConstants.spaceSm),
          Expanded(
            child: Text(
              hint,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textHint,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
