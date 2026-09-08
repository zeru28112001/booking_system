import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// Animated success checkmark badge with pop scale effect.
class AnimatedSuccessCheckmark extends StatefulWidget {
  const AnimatedSuccessCheckmark({
    super.key,
    this.size = 80,
    this.color = AppTheme.success,
  });

  final double size;
  final Color color;

  @override
  State<AnimatedSuccessCheckmark> createState() => _AnimatedSuccessCheckmarkState();
}

class _AnimatedSuccessCheckmarkState extends State<AnimatedSuccessCheckmark>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          color: widget.color.withAlpha(25),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: widget.color.withAlpha(50),
              blurRadius: 16,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Center(
          child: Icon(
            Icons.check_circle_rounded,
            size: widget.size * 0.75,
            color: widget.color,
          ),
        ),
      ),
    );
  }
}
