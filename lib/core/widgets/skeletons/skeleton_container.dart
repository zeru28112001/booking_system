import 'package:flutter/material.dart';
import '../../constants/app_constants.dart';
import '../../theme/app_theme.dart';

/// Static skeleton loading placeholder — no animation to avoid layout issues.
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
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppTheme.divider.withAlpha(80),
        shape: shape,
        borderRadius: shape == BoxShape.rectangle
            ? BorderRadius.circular(borderRadius)
            : null,
      ),
    );
  }
}
