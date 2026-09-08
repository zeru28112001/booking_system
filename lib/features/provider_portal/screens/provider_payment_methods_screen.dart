import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_loading_indicator.dart';
import '../domain/entities/payment_method_config.dart';
import '../providers/provider_portal_provider.dart';

class ProviderPaymentMethodsScreen extends StatefulWidget {
  const ProviderPaymentMethodsScreen({super.key});

  @override
  State<ProviderPaymentMethodsScreen> createState() => _ProviderPaymentMethodsScreenState();
}

class _ProviderPaymentMethodsScreenState extends State<ProviderPaymentMethodsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProviderPortalProvider>().fetchPaymentMethods();
    });
  }

  void _openFormSheet(BuildContext context, [PaymentMethodConfig? method]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _PaymentMethodFormSheet(method: method),
    );
  }

  IconData _getPaymentIcon(String code, String customIcon) {
    if (customIcon.isNotEmpty && customIcon != 'payments') {
      switch (customIcon) {
        case 'account_balance':
          return Icons.account_balance_outlined;
        case 'qr_code':
          return Icons.qr_code_2_outlined;
        case 'credit_card':
          return Icons.credit_card_outlined;
        case 'payments':
          return Icons.payments_outlined;
        case 'account_balance_wallet':
          return Icons.account_balance_wallet_outlined;
      }
    }
    switch (code.toLowerCase()) {
      case 'cash':
        return Icons.payments_outlined;
      case 'myanmyanpay':
        return Icons.account_balance_wallet_outlined;
      case 'kbzpay':
      case 'wavepay':
        return Icons.qr_code_2_outlined;
      case 'bank_transfer':
        return Icons.account_balance_outlined;
      case 'stripe':
        return Icons.credit_card_outlined;
      default:
        return Icons.payment_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: const Text('Payment Methods'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add Payment Method',
            onPressed: () => _openFormSheet(context),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: null,
        onPressed: () => _openFormSheet(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Payment Method'),
      ),
      body: Consumer<ProviderPortalProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.paymentMethods.isEmpty) {
            return const AppLoadingIndicator();
          }

          final methods = provider.paymentMethods;

          if (methods.isEmpty) {
            return AppEmptyState(
              icon: Icons.account_balance_wallet_outlined,
              title: 'No Payment Methods Configured',
              subtitle: 'Add payment options (Cash, Mobile Wallet, QR, Bank Transfer) for your customers.',
              actionLabel: 'Add Payment Method',
              onAction: () => _openFormSheet(context),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(AppConstants.spaceMd),
            itemCount: methods.length,
            separatorBuilder: (ctx, i) => const SizedBox(height: AppConstants.spaceSm),
            itemBuilder: (context, index) {
              final method = methods[index];
              final icon = _getPaymentIcon(method.code, method.iconName);

              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.spaceSm,
                  vertical: AppConstants.spaceMd,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                  border: Border.all(color: AppTheme.divider),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withAlpha(20),
                        borderRadius: BorderRadius.circular(AppConstants.radiusSm),
                      ),
                      child: Icon(icon, color: AppTheme.primary, size: 24),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  method.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                decoration: BoxDecoration(
                                  color: method.isActive
                                      ? AppTheme.success.withAlpha(30)
                                      : AppTheme.error.withAlpha(30),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  method.isActive ? 'Active' : 'Disabled',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: method.isActive ? AppTheme.success : AppTheme.error,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (method.accountName.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              'Account: ${method.accountName} (${method.accountNumber})',
                              style: theme.textTheme.bodySmall?.copyWith(color: AppTheme.textSecondary),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                          if (method.instructions.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              method.instructions,
                              style: theme.textTheme.bodySmall?.copyWith(color: AppTheme.textSecondary, fontSize: 11),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Transform.scale(
                          scale: 0.8,
                          child: Switch.adaptive(
                            value: method.isActive,
                            onChanged: (val) {
                              final updated = method.copyWith(isActive: val);
                              provider.savePaymentMethod(updated);
                            },
                          ),
                        ),
                        IconButton(
                          constraints: const BoxConstraints(),
                          padding: const EdgeInsets.all(4),
                          icon: const Icon(Icons.edit_outlined, size: 18),
                          onPressed: () => _openFormSheet(context, method),
                        ),
                        const SizedBox(width: 2),
                        IconButton(
                          constraints: const BoxConstraints(),
                          padding: const EdgeInsets.all(4),
                          icon: const Icon(Icons.delete_outline, color: AppTheme.error, size: 18),
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Delete Payment Method?'),
                                content: Text('Are you sure you want to remove "${method.name}"?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx, false),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx, true),
                                    style: TextButton.styleFrom(foregroundColor: AppTheme.error),
                                    child: const Text('Delete'),
                                  ),
                                ],
                              ),
                            );

                            if (confirm == true && context.mounted) {
                              await provider.deletePaymentMethod(method.id);
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _PaymentMethodFormSheet extends StatefulWidget {
  const _PaymentMethodFormSheet({this.method});

  final PaymentMethodConfig? method;

  @override
  State<_PaymentMethodFormSheet> createState() => _PaymentMethodFormSheetState();
}

class _PaymentMethodFormSheetState extends State<_PaymentMethodFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _codeController;
  late TextEditingController _accountNameController;
  late TextEditingController _accountNumberController;
  late TextEditingController _qrCodeUrlController;
  late TextEditingController _instructionsController;
  late bool _isActive;
  late String _selectedPreset;

  final Map<String, String> _presets = {
    'cash': 'Cash Payment',
    'myanmyanpay': 'MyanMyanPay',
    'kbzpay': 'KBZPay QR / Phone',
    'wavepay': 'WavePay QR / Phone',
    'bank_transfer': 'Bank Transfer (CB / KBZ / AYA)',
    'stripe': 'Credit Card / Stripe',
    'custom': 'Custom Payment Method',
  };

  @override
  void initState() {
    super.initState();
    final m = widget.method;
    _nameController = TextEditingController(text: m?.name ?? '');
    _codeController = TextEditingController(text: m?.code ?? 'cash');
    _accountNameController = TextEditingController(text: m?.accountName ?? '');
    _accountNumberController = TextEditingController(text: m?.accountNumber ?? '');
    _qrCodeUrlController = TextEditingController(text: m?.qrCodeUrl ?? '');
    _instructionsController = TextEditingController(text: m?.instructions ?? '');
    _isActive = m?.isActive ?? true;
    _selectedPreset = _presets.containsKey(m?.code) ? (m?.code ?? 'cash') : 'custom';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _accountNameController.dispose();
    _accountNumberController.dispose();
    _qrCodeUrlController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  void _onPresetChanged(String? val) {
    if (val == null) return;
    setState(() {
      _selectedPreset = val;
      if (val != 'custom') {
        _codeController.text = val;
        if (_nameController.text.isEmpty) {
          _nameController.text = _presets[val] ?? '';
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.method != null;
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppConstants.radiusLg)),
      ),
      padding: EdgeInsets.fromLTRB(
        AppConstants.spaceMd,
        AppConstants.spaceMd,
        AppConstants.spaceMd,
        AppConstants.spaceMd + bottomPadding,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isEditing ? 'Edit Payment Method' : 'Add Payment Method',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.spaceMd),
              DropdownButtonFormField<String>(
                initialValue: _selectedPreset,
                decoration: const InputDecoration(
                  labelText: 'Payment Preset',
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                items: _presets.entries
                    .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
                    .toList(),
                onChanged: _onPresetChanged,
              ),
              const SizedBox(height: AppConstants.spaceMd),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Display Name *',
                  hintText: 'e.g. KBZPay Quick Pay',
                  prefixIcon: Icon(Icons.label_outlined),
                ),
                validator: (val) => val == null || val.trim().isEmpty ? 'Name is required' : null,
              ),
              const SizedBox(height: AppConstants.spaceMd),
              TextFormField(
                controller: _accountNameController,
                decoration: const InputDecoration(
                  labelText: 'Account / Payee Name (Optional)',
                  hintText: 'e.g. Daw Su Su',
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: AppConstants.spaceMd),
              TextFormField(
                controller: _accountNumberController,
                decoration: const InputDecoration(
                  labelText: 'Account / Phone Number (Optional)',
                  hintText: 'e.g. 09 1234 5678 or 123-456-789',
                  prefixIcon: Icon(Icons.numbers_outlined),
                ),
              ),
              const SizedBox(height: AppConstants.spaceMd),
              TextFormField(
                controller: _qrCodeUrlController,
                decoration: const InputDecoration(
                  labelText: 'QR Code Image URL (Optional)',
                  hintText: 'https://example.com/qr.png',
                  prefixIcon: Icon(Icons.qr_code_outlined),
                ),
              ),
              const SizedBox(height: AppConstants.spaceMd),
              TextFormField(
                controller: _instructionsController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Instructions for Customer (Optional)',
                  hintText: 'e.g. Send transfer screenshot via chat after payment',
                  prefixIcon: Icon(Icons.note_outlined),
                ),
              ),
              const SizedBox(height: AppConstants.spaceMd),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Active Payment Method'),
                subtitle: const Text('Show this payment option to customers'),
                value: _isActive,
                onChanged: (val) => setState(() => _isActive = val),
              ),
              const SizedBox(height: AppConstants.spaceLg),
              ElevatedButton(
                onPressed: () async {
                  if (!_formKey.currentState!.validate()) return;
                  final provider = context.read<ProviderPortalProvider>();

                  final method = PaymentMethodConfig(
                    id: widget.method?.id ?? '',
                    name: _nameController.text.trim(),
                    code: _codeController.text.trim().isEmpty ? 'custom' : _codeController.text.trim(),
                    accountName: _accountNameController.text.trim(),
                    accountNumber: _accountNumberController.text.trim(),
                    qrCodeUrl: _qrCodeUrlController.text.trim(),
                    instructions: _instructionsController.text.trim(),
                    isActive: _isActive,
                  );

                  final success = await provider.savePaymentMethod(method);
                  if (success && context.mounted) {
                    Navigator.pop(context);
                  }
                },
                child: providerConsumerIsSaving(context)
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(isEditing ? 'Update Payment Method' : 'Save Payment Method'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool providerConsumerIsSaving(BuildContext context) {
    return context.select<ProviderPortalProvider, bool>((p) => p.isSaving);
  }
}
