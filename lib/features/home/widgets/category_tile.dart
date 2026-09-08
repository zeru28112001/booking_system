import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../domain/entities/category.dart';

/// One tile of the Home category grid: gradient icon badge + label.
class CategoryTile extends StatelessWidget {
  const CategoryTile({
    super.key,
    required this.category,
    required this.onTap,
  });

  final Category category;
  final VoidCallback onTap;

  /// Resolves the backend-safe [Category.iconName] key to an icon.
  static const Map<String, IconData> _icons = {
    'spa': Icons.spa_outlined,
    'cleaning': Icons.cleaning_services_outlined,
    'plumbing': Icons.plumbing_outlined,
    'electrical': Icons.electrical_services_outlined,
    'tutoring': Icons.school_outlined,
  };

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.surface,
      borderRadius: BorderRadius.circular(AppConstants.radiusLg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spaceXs,
            vertical: AppConstants.spaceSm,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.primary, AppTheme.accent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                ),
                child: Icon(
                  _icons[category.iconName] ?? Icons.home_repair_service_rounded,
                  size: 24,
                  color: AppTheme.onPrimary,
                ),
              ),
              const SizedBox(height: AppConstants.spaceSm),
              Text(
                category.name,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
