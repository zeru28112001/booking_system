import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../providers/review_provider.dart';

/// Modal bottom sheet for writing and submitting a provider review.
class ReviewFormSheet extends StatefulWidget {
  const ReviewFormSheet({
    super.key,
    required this.providerId,
    required this.providerName,
    this.bookingId,
  });

  final String providerId;
  final String providerName;
  final String? bookingId;

  @override
  State<ReviewFormSheet> createState() => _ReviewFormSheetState();
}

class _ReviewFormSheetState extends State<ReviewFormSheet> {
  final _commentController = TextEditingController();
  double _rating = 5.0;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final reviewProvider = context.read<ReviewProvider>();
    reviewProvider.clearError();
    final review = await reviewProvider.submitReview(
      providerId: widget.providerId,
      rating: _rating,
      comment: _commentController.text.trim(),
      bookingId: widget.bookingId,
    );

    if (!mounted || review == null) return;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final keyboardInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: keyboardInset),
      child: Consumer<ReviewProvider>(
        builder: (context, provider, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.spaceMd),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppTheme.divider,
                      borderRadius:
                          BorderRadius.circular(AppConstants.radiusPill),
                    ),
                  ),
                ),
                const SizedBox(height: AppConstants.spaceSm),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Write a Review', style: theme.textTheme.headlineSmall),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                Text(
                  'How was your experience with ${widget.providerName}?',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: AppConstants.spaceLg),
                Center(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          for (int i = 1; i <= 5; i++)
                            IconButton(
                              onPressed: () => setState(() => _rating = i.toDouble()),
                              icon: Icon(
                                i <= _rating
                                    ? Icons.star_rounded
                                    : Icons.star_outline_rounded,
                                size: 36,
                                color: AppTheme.warning,
                              ),
                            ),
                        ],
                      ),
                      Text(
                        _ratingLabel(_rating),
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: AppTheme.warning,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppConstants.spaceLg),
                AppTextField(
                  controller: _commentController,
                  label: 'Your Review',
                  hint: 'Tell others about your appointment...',
                  prefixIcon: Icons.rate_review_outlined,
                  maxLines: 4,
                  maxLength: 300,
                ),
                if (provider.error != null) ...[
                  const SizedBox(height: AppConstants.spaceSm),
                  Text(
                    provider.error!,
                    style: theme.textTheme.bodySmall?.copyWith(color: AppTheme.error),
                  ),
                ],
                const SizedBox(height: AppConstants.spaceLg),
                AppButton(
                  label: 'Submit Review',
                  icon: Icons.send_rounded,
                  isLoading: provider.isSubmitting,
                  onPressed: provider.isSubmitting ? null : _submit,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _ratingLabel(double rating) {
    switch (rating.toInt()) {
      case 1:
        return 'Poor';
      case 2:
        return 'Fair';
      case 3:
        return 'Good';
      case 4:
        return 'Very Good';
      case 5:
      default:
        return 'Excellent!';
    }
  }
}
