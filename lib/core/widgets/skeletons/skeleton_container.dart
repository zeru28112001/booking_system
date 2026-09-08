import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../constants/app_constants.dart';
import '../../theme/app_theme.dart';

/// Reusable Shimmer container wrapper for skeleton loading states.
class SkeletonContainer extends StatelessWidget {
  const SkeletonContainer({
    super.key,
    this.width,
    this.height,
    this.borderRadius = AppConstants.radiusMd,
    this.margin,
    this.shape = BoxShape.rectangle,
  });

  final double? width;
  final double? height;
  final double borderRadius;
  final EdgeInsetsGeometry? margin;
  final BoxShape shape;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: Shimmer.fromColors(
        baseColor: AppTheme.divider.withAlpha(120),
        highlightColor: AppTheme.surface,
        period: const Duration(milliseconds: 1200),
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: AppTheme.surfaceVariant,
            shape: shape,
            borderRadius: shape == BoxShape.rectangle
                ? BorderRadius.circular(borderRadius)
                : null,
          ),
        ),
      ),
    );
  }
}
