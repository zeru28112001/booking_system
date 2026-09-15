import 'package:flutter/material.dart';

/// Staggered entrance animation widget — renders child directly.
/// The animation is intentionally removed to prevent layout-phase assertion
/// errors on Flutter Web (box.dart:2251 hasSize).
class StaggeredEntrance extends StatelessWidget {
  const StaggeredEntrance({
    super.key,
    required this.index,
    required this.child,
    this.duration = const Duration(milliseconds: 450),
    this.delayStep = const Duration(milliseconds: 60),
    this.slideOffset = 20.0,
  });

  final int index;
  final Widget child;
  final Duration duration;
  final Duration delayStep;
  final double slideOffset;

  @override
  Widget build(BuildContext context) {
    return child;
  }
}
