import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// Interactive star rating selector with smooth pop animations.
class InteractiveStarRating extends StatefulWidget {
  const InteractiveStarRating({
    super.key,
    this.initialRating = 5,
    this.maxRating = 5,
    this.starSize = 36.0,
    required this.onRatingChanged,
  });

  final int initialRating;
  final int maxRating;
  final double starSize;
  final ValueChanged<int> onRatingChanged;

  @override
  State<InteractiveStarRating> createState() => _InteractiveStarRatingState();
}

class _InteractiveStarRatingState extends State<InteractiveStarRating> {
  late int _currentRating;
  int? _tappedIndex;

  @override
  void initState() {
    super.initState();
    _currentRating = widget.initialRating;
  }

  void _onStarTapped(int index) {
    setState(() {
      _currentRating = index + 1;
      _tappedIndex = index;
    });
    widget.onRatingChanged(_currentRating);
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        setState(() {
          _tappedIndex = null;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(widget.maxRating, (index) {
        final isFilled = index < _currentRating;
        final isTapped = _tappedIndex == index;

        return GestureDetector(
          onTap: () => _onStarTapped(index),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: AnimatedScale(
              scale: isTapped ? 1.35 : 1.0,
              duration: const Duration(milliseconds: 150),
              curve: Curves.easeOutBack,
              child: Icon(
                isFilled ? Icons.star_rounded : Icons.star_outline_rounded,
                size: widget.starSize,
                color: isFilled ? AppTheme.warning : AppTheme.divider,
              ),
            ),
          ),
        );
      }),
    );
  }
}
