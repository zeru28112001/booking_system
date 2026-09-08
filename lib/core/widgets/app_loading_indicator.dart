import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Custom branded loading animation (pulsing logo badge + smooth spin).
class AppLoadingIndicator extends StatefulWidget {
  const AppLoadingIndicator({
    super.key,
    this.size = 48.0,
  });

  final double size;

  @override
  State<AppLoadingIndicator> createState() => _AppLoadingIndicatorState();
}

class _AppLoadingIndicatorState extends State<AppLoadingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: RotationTransition(
        turns: _controller,
        child: Container(
          width: widget.size,
          height: widget.size,
          padding: const EdgeInsets.all(3),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: SweepGradient(
              colors: [
                AppTheme.primary,
                AppTheme.accent,
                AppTheme.primaryLight,
                AppTheme.primary,
              ],
            ),
          ),
          child: Container(
            decoration: const BoxDecoration(
              color: AppTheme.surface,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(
                Icons.auto_awesome_rounded,
                size: 20,
                color: AppTheme.primary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
