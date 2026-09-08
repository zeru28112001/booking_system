import 'package:flutter/material.dart';
import '../../constants/app_constants.dart';
import '../../theme/app_theme.dart';
import 'skeleton_container.dart';

/// Skeleton placeholder matching ProviderCard layout.
class ProviderCardSkeleton extends StatelessWidget {
  const ProviderCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spaceMd),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
      ),
      child: const Row(
        children: [
          // Avatar skeleton
          SkeletonContainer(
            width: 56,
            height: 56,
            shape: BoxShape.circle,
          ),
          SizedBox(width: AppConstants.spaceMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title line
                SkeletonContainer(
                  width: 140,
                  height: 16,
                  borderRadius: AppConstants.radiusSm,
                ),
                SizedBox(height: AppConstants.spaceSm),
                // Rating / meta line
                SkeletonContainer(
                  width: 180,
                  height: 12,
                  borderRadius: AppConstants.radiusSm,
                ),
                SizedBox(height: AppConstants.spaceSm),
                // Price range line
                SkeletonContainer(
                  width: 90,
                  height: 12,
                  borderRadius: AppConstants.radiusSm,
                ),
              ],
            ),
          ),
          SizedBox(width: AppConstants.spaceSm),
          // Pill skeleton
          SkeletonContainer(
            width: 50,
            height: 24,
            borderRadius: AppConstants.radiusPill,
          ),
        ],
      ),
    );
  }
}
