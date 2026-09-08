import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../domain/entities/service_provider.dart';
import 'gradient_avatar.dart';

/// One row of the provider list: avatar, name, rating meta, price range,
/// open/closed pill.
class ProviderCard extends StatelessWidget {
  const ProviderCard({
    super.key,
    required this.provider,
    required this.onTap,
  });

  final ServiceProvider provider;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.surface,
      borderRadius: BorderRadius.circular(AppConstants.radiusLg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.spaceMd),
          child: Row(
            children: [
              Hero(
                tag: 'provider-avatar-${provider.id}',
                child: GradientAvatar(name: provider.name),
              ),
              const SizedBox(width: AppConstants.spaceMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      provider.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: AppConstants.spaceXs),
                    Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          size: 16,
                          color: AppTheme.warning,
                        ),
                        const SizedBox(width: AppConstants.spaceXs),
                        Text(
                          provider.rating.toStringAsFixed(1),
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppTheme.onSurface,
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                        const SizedBox(width: AppConstants.spaceXs),
                        Text(
                          '(${provider.reviewCount})',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(width: AppConstants.spaceSm),
                        Text(
                          '${provider.distanceKm.toStringAsFixed(1)} km',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppConstants.spaceXs),
                    Text(
                      AppFormatters.priceRange(provider.priceMin, provider.priceMax),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppConstants.spaceSm),
              _OpenPill(
                isOpen: provider.isOpen,
                isAvailable: provider.isAvailable,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OpenPill extends StatelessWidget {
  const _OpenPill({
    required this.isOpen,
    this.isAvailable = true,
  });

  final bool isOpen;
  final bool isAvailable;

  @override
  Widget build(BuildContext context) {
    final bool active = isOpen && isAvailable;
    final color = active
        ? AppTheme.secondary
        : (!isAvailable ? AppTheme.warning : AppTheme.textHint);
    final label = active ? 'Open' : (!isAvailable ? 'Busy' : 'Closed');

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spaceSm,
        vertical: AppConstants.spaceXs,
      ),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(AppConstants.radiusPill),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
