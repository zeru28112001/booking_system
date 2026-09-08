import 'package:flutter/material.dart';
import '../../constants/app_constants.dart';
import '../../theme/app_theme.dart';
import 'skeleton_container.dart';

/// Skeleton grid layout for category tiles loading state.
class CategoryGridSkeleton extends StatelessWidget {
  const CategoryGridSkeleton({
    super.key,
    this.itemCount = 8,
  });

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: itemCount,
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 130,
        mainAxisSpacing: AppConstants.spaceMd,
        crossAxisSpacing: AppConstants.spaceMd,
        childAspectRatio: 0.85,
      ),
      itemBuilder: (context, index) {
        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spaceXs,
            vertical: AppConstants.spaceSm,
          ),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(AppConstants.radiusLg),
          ),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SkeletonContainer(
                width: 48,
                height: 48,
                borderRadius: AppConstants.radiusMd,
              ),
              SizedBox(height: AppConstants.spaceSm),
              SkeletonContainer(
                width: 64,
                height: 12,
                borderRadius: AppConstants.radiusSm,
              ),
            ],
          ),
        );
      },
    );
  }
}
