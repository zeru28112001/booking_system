import 'package:flutter/material.dart';
import '../../constants/app_constants.dart';
import '../../theme/app_theme.dart';
import 'skeleton_container.dart';

/// Skeleton item matching BookingCard layout.
class BookingCardSkeleton extends StatelessWidget {
  const BookingCardSkeleton({super.key});

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
          // Icon skeleton
          SkeletonContainer(
            width: 44,
            height: 44,
            borderRadius: AppConstants.radiusMd,
          ),
          SizedBox(width: AppConstants.spaceMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Provider name line
                SkeletonContainer(
                  width: 130,
                  height: 16,
                  borderRadius: AppConstants.radiusSm,
                ),
                SizedBox(height: AppConstants.spaceXs),
                // Service name line
                SkeletonContainer(
                  width: 100,
                  height: 12,
                  borderRadius: AppConstants.radiusSm,
                ),
                SizedBox(height: AppConstants.spaceXs),
                // Date & time line
                SkeletonContainer(
                  width: 140,
                  height: 12,
                  borderRadius: AppConstants.radiusSm,
                ),
              ],
            ),
          ),
          SizedBox(width: AppConstants.spaceSm),
          // Status badge skeleton
          SkeletonContainer(
            width: 65,
            height: 24,
            borderRadius: AppConstants.radiusPill,
          ),
        ],
      ),
    );
  }
}

/// List wrapper of booking card skeletons.
class BookingListSkeleton extends StatelessWidget {
  const BookingListSkeleton({
    super.key,
    this.itemCount = 5,
  });

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: itemCount,
      separatorBuilder: (context, index) => const SizedBox(height: AppConstants.spaceMd),
      itemBuilder: (context, index) => const BookingCardSkeleton(),
    );
  }
}
