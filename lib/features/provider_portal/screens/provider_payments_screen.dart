import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../domain/entities/provider_payment.dart';
import '../providers/provider_portal_provider.dart';

class ProviderPaymentsScreen extends StatefulWidget {
  const ProviderPaymentsScreen({super.key});

  @override
  State<ProviderPaymentsScreen> createState() => _ProviderPaymentsScreenState();
}

class _ProviderPaymentsScreenState extends State<ProviderPaymentsScreen> {
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProviderPortalProvider>().fetchPayments();
    });
  }

  void _showRecordPaymentDialog(BuildContext context) {
    final amountController = TextEditingController();
    String selectedMethod = 'cash';
    String selectedStatus = 'completed';

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Record Cash Payment'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Amount (\$)',
                    prefixIcon: Icon(Icons.attach_money_rounded),
                  ),
                ),
                const SizedBox(height: AppConstants.spaceMd),
                DropdownButtonFormField<String>(
                  initialValue: selectedMethod,
                  decoration: const InputDecoration(labelText: 'Payment Method'),
                  items: const [
                    DropdownMenuItem(value: 'cash', child: Text('Cash')),
                    DropdownMenuItem(value: 'myanmyanpay', child: Text('MyanMyanPay')),
                    DropdownMenuItem(value: 'stripe', child: Text('Stripe')),
                  ],
                  onChanged: (val) {
                    if (val != null) setDialogState(() => selectedMethod = val);
                  },
                ),
                const SizedBox(height: AppConstants.spaceMd),
                DropdownButtonFormField<String>(
                  initialValue: selectedStatus,
                  decoration: const InputDecoration(labelText: 'Status'),
                  items: const [
                    DropdownMenuItem(value: 'completed', child: Text('Completed')),
                    DropdownMenuItem(value: 'pending', child: Text('Pending')),
                  ],
                  onChanged: (val) {
                    if (val != null) setDialogState(() => selectedStatus = val);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final amount = double.tryParse(amountController.text.trim());
                if (amount == null || amount <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter a valid payment amount.')),
                  );
                  return;
                }
                Navigator.pop(dialogCtx);
                final success = await context.read<ProviderPortalProvider>().createPayment(
                      amount: amount,
                      paymentMethod: selectedMethod,
                      status: selectedStatus,
                    );
                if (context.mounted && success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Payment recorded successfully!')),
                  );
                }
              },
              child: const Text('Record Payment'),
            ),
          ],
        ),
      ),
    );
  }

  void _showChangeStatusDialog(BuildContext context, ProviderPayment payment) {
    String newStatus = payment.status;

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Update Payment Status'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Customer: ${payment.customerName}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('Amount: ${AppFormatters.currency(payment.amount.toInt())}'),
              const SizedBox(height: AppConstants.spaceMd),
              DropdownButtonFormField<String>(
                initialValue: newStatus,
                decoration: const InputDecoration(labelText: 'Payment Status'),
                items: const [
                  DropdownMenuItem(value: 'completed', child: Text('Completed')),
                  DropdownMenuItem(value: 'pending', child: Text('Pending')),
                  DropdownMenuItem(value: 'refunded', child: Text('Refunded')),
                  DropdownMenuItem(value: 'failed', child: Text('Failed')),
                ],
                onChanged: (val) {
                  if (val != null) setDialogState(() => newStatus = val);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(dialogCtx);
                final success = await context.read<ProviderPortalProvider>().updatePaymentStatus(
                      payment.id,
                      newStatus,
                    );
                if (context.mounted && success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Payment status updated successfully!')),
                  );
                }
              },
              child: const Text('Update Status'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<ProviderPortalProvider>();
    final summary = provider.paymentSummary;
    final allPayments = provider.payments;

    final filteredPayments = _selectedFilter == 'all'
        ? allPayments
        : allPayments.where((p) => p.status == _selectedFilter).toList();

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: const Text('Payments & Earnings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded),
            tooltip: 'Record Cash Payment',
            onPressed: () => _showRecordPaymentDialog(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.spaceMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Revenue statistics overview
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppConstants.spaceLg),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primary, Color(0xFF4338CA)],
                ),
                borderRadius: BorderRadius.circular(AppConstants.radiusLg),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Total Earnings',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppFormatters.currency((summary?.totalEarnings ?? provider.totalRevenue.toDouble()).toInt()),
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppConstants.spaceMd),
                  Row(
                    children: [
                      Expanded(child: _buildHeaderStat('Pending', AppFormatters.currency((summary?.pendingEarnings ?? 0).toInt()))),
                      Expanded(child: _buildHeaderStat('Refunded', AppFormatters.currency((summary?.refundedAmount ?? 0).toInt()))),
                      Expanded(child: _buildHeaderStat('Transactions', '${summary?.totalTransactions ?? allPayments.length}')),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppConstants.spaceLg),

            // Action row & filter tabs
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Payment Transactions',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _showRecordPaymentDialog(context),
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('Record Cash'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spaceSm),

            // Filter chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('all', 'All (${allPayments.length})'),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    'completed',
                    'Completed (${summary?.completedCount ?? allPayments.where((p) => p.status == 'completed').length})',
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    'pending',
                    'Pending (${summary?.pendingCount ?? allPayments.where((p) => p.status == 'pending').length})',
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    'refunded',
                    'Refunded (${summary?.refundedCount ?? allPayments.where((p) => p.status == 'refunded').length})',
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppConstants.spaceMd),

            if (filteredPayments.isEmpty)
              AppEmptyState(
                icon: Icons.receipt_long_outlined,
                title: 'No payment transactions found',
                subtitle: _selectedFilter == 'all'
                    ? 'Payment history and offline cash logs will appear here.'
                    : 'No payments with status "$_selectedFilter".',
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filteredPayments.length,
                separatorBuilder: (ctx, i) => const SizedBox(height: AppConstants.spaceSm),
                itemBuilder: (context, index) {
                  final p = filteredPayments[index];
                  return Container(
                    padding: const EdgeInsets.all(AppConstants.spaceMd),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                      border: Border.all(color: AppTheme.divider),
                    ),
                    child: Row(
                      children: [
                        _buildMethodIcon(p.paymentMethod),
                        const SizedBox(width: AppConstants.spaceMd),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      p.customerName.isNotEmpty ? p.customerName : 'Customer',
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  _buildStatusBadge(p.status),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${p.paymentMethod.toUpperCase()} · ${AppFormatters.dateLabel(AppFormatters.isoDay(p.createdAt))}',
                                style: theme.textTheme.bodySmall?.copyWith(color: AppTheme.textSecondary),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '+${AppFormatters.currency(p.amount.toInt())}',
                              style: theme.textTheme.titleSmall?.copyWith(
                                color: p.status == 'completed' ? AppTheme.success : AppTheme.onSurface,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            InkWell(
                              onTap: () => _showChangeStatusDialog(context, p),
                              borderRadius: BorderRadius.circular(4),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: const [
                                    Text(
                                      'Update',
                                      style: TextStyle(
                                        color: AppTheme.primary,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Icon(Icons.arrow_drop_down_rounded, size: 16, color: AppTheme.primary),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String value, String label) {
    final isSelected = _selectedFilter == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) setState(() => _selectedFilter = value);
      },
      selectedColor: AppTheme.primary,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppTheme.onSurface,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildHeaderStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildMethodIcon(String method) {
    IconData icon;
    Color color;
    switch (method.toLowerCase()) {
      case 'cash':
        icon = Icons.payments_outlined;
        color = AppTheme.success;
        break;
      case 'myanmyanpay':
        icon = Icons.account_balance_wallet_outlined;
        color = AppTheme.secondary;
        break;
      case 'stripe':
        icon = Icons.credit_card_rounded;
        color = AppTheme.primary;
        break;
      default:
        icon = Icons.payment_rounded;
        color = AppTheme.textSecondary;
    }

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bg;
    Color fg;
    switch (status.toLowerCase()) {
      case 'completed':
        bg = AppTheme.success.withAlpha(20);
        fg = AppTheme.success;
        break;
      case 'pending':
        bg = AppTheme.warning.withAlpha(20);
        fg = AppTheme.warning;
        break;
      case 'refunded':
        bg = AppTheme.error.withAlpha(20);
        fg = AppTheme.error;
        break;
      default:
        bg = Colors.grey.withAlpha(30);
        fg = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppConstants.radiusSm),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(color: fg, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}
