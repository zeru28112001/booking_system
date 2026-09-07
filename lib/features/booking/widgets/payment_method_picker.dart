import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../domain/entities/payment_method.dart';

/// Radio rows for the three supported payment methods.
class PaymentMethodPicker extends StatelessWidget {
  const PaymentMethodPicker({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final PaymentMethod selected;
  final ValueChanged<PaymentMethod> onSelected;

  IconData _iconFor(PaymentMethod method) => switch (method) {
        PaymentMethod.cash => Icons.payments_outlined,
        PaymentMethod.myanmyanpay => Icons.account_balance_wallet_outlined,
        PaymentMethod.stripe => Icons.credit_card_rounded,
      };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        for (final method in PaymentMethod.values)
          Padding(
            padding: const EdgeInsets.only(bottom: AppConstants.spaceSm),
            child: Material(
              color: method == selected
                  ? AppTheme.primary.withAlpha(15)
                  : AppTheme.surface,
              borderRadius: BorderRadius.circular(AppConstants.radiusMd),
              child: InkWell(
                onTap: () => onSelected(method),
                borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.spaceMd,
                    vertical: AppConstants.spaceSm,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                    border: Border.all(
                      color: method == selected
                          ? AppTheme.primary
                          : AppTheme.divider,
                      width: method == selected ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _iconFor(method),
                        size: 20,
                        color: method == selected
                            ? AppTheme.primary
                            : AppTheme.textSecondary,
                      ),
                      const SizedBox(width: AppConstants.spaceMd),
                      Expanded(
                        child: Text(
                          method.label,
                          style: theme.textTheme.bodyLarge?.copyWith(
                                fontWeight: method == selected
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                              ),
                        ),
                      ),
                      Icon(
                        method == selected
                            ? Icons.radio_button_checked_rounded
                            : Icons.radio_button_unchecked_rounded,
                        size: 20,
                        color: method == selected
                            ? AppTheme.primary
                            : AppTheme.textHint,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
