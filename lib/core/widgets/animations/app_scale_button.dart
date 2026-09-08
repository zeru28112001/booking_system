import 'package:flutter/material.dart';

/// Interactive wrapper providing a subtle scale down (0.96) micro-interaction feedback on tap.
class AppScaleButton extends StatefulWidget {
  const AppScaleButton({
    super.key,
    required this.child,
    this.onTap,
    this.scaleDown = 0.96,
    this.duration = const Duration(milliseconds: 120),
    this.curve = Curves.easeInOutCubic,
  });

  final Widget child;
  final VoidCallback? onTap;
  final double scaleDown;
  final Duration duration;
  final Curve curve;

  @override
  State<AppScaleButton> createState() => _AppScaleButtonState();
}

class _AppScaleButtonState extends State<AppScaleButton> {
  bool _isPressed = false;

  void _onTapDown(TapDownDetails details) {
    if (widget.onTap == null) return;
    setState(() {
      _isPressed = true;
    });
  }

  void _onTapUp(TapUpDetails details) {
    if (_isPressed) {
      setState(() {
        _isPressed = false;
      });
    }
  }

  void _onTapCancel() {
    if (_isPressed) {
      setState(() {
        _isPressed = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: _isPressed ? widget.scaleDown : 1.0,
        duration: widget.duration,
        curve: widget.curve,
        child: widget.child,
      ),
    );
  }
}
