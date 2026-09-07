import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../domain/entities/service.dart';

/// One bookable service row: name, duration and price, plus selection state.
class ServiceTile extends StatelessWidget {
  const ServiceTile({
    super.key,
    required this.service,
    required this.onTap,
    this.isSelected = false,
  });

  final Service service;
  final VoidCallback onTap;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: isSelected ? AppTheme.primary.withAlpha(12) : AppTheme.surface,
      borderRadius: BorderRadius.circular(AppConstants.radiusMd),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(AppConstants.spaceMd),
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected ? AppTheme.primary : AppTheme.divider,
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(AppConstants.radiusMd),
          ),
          child: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? AppTheme.primary : Colors.transparent,
                  border: Border.all(
                    color: isSelected ? AppTheme.primary : AppTheme.textHint,
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? const Icon(
                        Icons.check_rounded,
                        size: 16,
                        color: AppTheme.onPrimary,
                      )
                    : null,
              ),
              const SizedBox(width: AppConstants.spaceSm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      service.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight:
                                isSelected ? FontWeight.w700 : FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: AppConstants.spaceXs),
                    Text(
                      '${AppFormatters.durationLabel(service.durationMinutes)} · '
                      '${AppFormatters.currency(service.price)}',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppConstants.spaceSm),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.spaceSm,
                  vertical: AppConstants.spaceXs,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.primary
                      : AppTheme.primary.withAlpha(15),
                  borderRadius: BorderRadius.circular(AppConstants.radiusPill),
                ),
                child: Text(
                  isSelected ? 'Added' : 'Add',
                  style: theme.textTheme.bodySmall?.copyWith(
                        color: isSelected
                            ? AppTheme.onPrimary
                            : AppTheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
