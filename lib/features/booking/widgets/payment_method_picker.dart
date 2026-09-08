import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../provider_portal/domain/entities/payment_method_config.dart';
import '../domain/entities/payment_method.dart';

/// Radio rows for payment methods — supports dynamic PaymentMethodConfig lists per provider.
class PaymentMethodPicker extends StatelessWidget {
  const PaymentMethodPicker({
    super.key,
    required this.selected,
    required this.onSelected,
    this.methods,
    this.selectedConfig,
    this.onConfigSelected,
  });

  final PaymentMethod selected;
  final ValueChanged<PaymentMethod> onSelected;
  final List<PaymentMethodConfig>? methods;
  final PaymentMethodConfig? selectedConfig;
  final ValueChanged<PaymentMethodConfig>? onConfigSelected;

  IconData _iconFor(PaymentMethod method) => switch (method) {
        PaymentMethod.cash => Icons.payments_outlined,
        PaymentMethod.myanmyanpay => Icons.account_balance_wallet_outlined,
        PaymentMethod.stripe => Icons.credit_card_rounded,
      };

  IconData _iconForConfig(PaymentMethodConfig config) {
    switch (config.iconName) {
      case 'payments':
      case 'cash':
        return Icons.payments_outlined;
      case 'account_balance_wallet':
      case 'wallet':
        return Icons.account_balance_wallet_outlined;
      case 'credit_card':
      case 'card':
        return Icons.credit_card_rounded;
      case 'qr_code':
        return Icons.qr_code_rounded;
      default:
        switch (config.code.toLowerCase()) {
          case 'cash':
            return Icons.payments_outlined;
          case 'myanmyanpay':
            return Icons.account_balance_wallet_outlined;
          case 'stripe':
            return Icons.credit_card_rounded;
          default:
            return Icons.payment_rounded;
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (methods != null && methods!.isNotEmpty) {
      return Column(
        children: methods!.map((config) {
          final isSelected = selectedConfig?.id == config.id ||
              (selectedConfig == null &&
                  config.code.toLowerCase() == selected.value.toLowerCase());
          return Padding(
            padding: const EdgeInsets.only(bottom: AppConstants.spaceSm),
            child: Material(
              color: isSelected
                  ? AppTheme.primary.withAlpha(15)
                  : AppTheme.surface,
              borderRadius: BorderRadius.circular(AppConstants.radiusMd),
              child: InkWell(
                onTap: () {
                  onSelected(PaymentMethod.fromValue(config.code));
                  if (onConfigSelected != null) {
                    onConfigSelected!(config);
                  }
                },
                borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.spaceMd,
                    vertical: AppConstants.spaceSm,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                    border: Border.all(
                      color: isSelected ? AppTheme.primary : AppTheme.divider,
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _iconForConfig(config),
                        size: 22,
                        color: isSelected
                            ? AppTheme.primary
                            : AppTheme.textSecondary,
                      ),
                      const SizedBox(width: AppConstants.spaceMd),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              config.name,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                              ),
                            ),
                            if (config.instructions.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                config.instructions,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: AppTheme.textSecondary,
                                  fontSize: 11,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                      ),
                      Icon(
                        isSelected
                            ? Icons.radio_button_checked_rounded
                            : Icons.radio_button_unchecked_rounded,
                        size: 20,
                        color:
                            isSelected ? AppTheme.primary : AppTheme.textHint,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      );
    }

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
