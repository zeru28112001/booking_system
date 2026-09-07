import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_loading_indicator.dart';
import '../../../core/widgets/app_text_field.dart';
import '../domain/entities/payment_method.dart';
import '../providers/booking_provider.dart';
import 'date_strip.dart';
import 'payment_method_picker.dart';
import 'time_slot_grid.dart';

/// Two-step booking form shown with showModalBottomSheet:
/// step 0 collects date, slot, address and notes; step 1 collects payment.
///
/// Pops with the new booking id so the caller (main.dart) can route to the
/// confirmation screen. The constructor takes primitives only — features/booking
/// never imports features/provider.
class BookingFormSheet extends StatefulWidget {
  const BookingFormSheet({
    super.key,
    required this.providerId,
    required this.providerName,
    required this.serviceId,
    required this.serviceName,
    required this.price,
    required this.durationMinutes,
    this.staffId,
    this.staffName,
    this.isHomeService = true,
    this.providerAddress = '',
    this.itemizedServices,
  });

  final String providerId;
  final String providerName;
  final String serviceId;
  final String serviceName;
  final int price;
  final int durationMinutes;
  final String? staffId;
  final String? staffName;
  final bool isHomeService;
  final String providerAddress;
  final List<String>? itemizedServices;

  @override
  State<BookingFormSheet> createState() => _BookingFormSheetState();
}

class _BookingFormSheetState extends State<BookingFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();

  int _step = 0;
  String _selectedDate = AppFormatters.isoDay(DateTime.now());
  String? _selectedTime;
  PaymentMethod _paymentMethod = PaymentMethod.cash;

  @override
  void initState() {
    super.initState();
    // Deferring keeps notifyListeners out of the build phase.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _fetchSlots(_selectedDate);
    });
  }

  @override
  void dispose() {
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _fetchSlots(String date) {
    context.read<BookingProvider>().fetchTimeSlots(
          providerId: widget.providerId,
          date: date,
          staffId: widget.staffId,
        );
  }

  void _onDateSelected(String date) {
    setState(() {
      _selectedDate = date;
      _selectedTime = null;
    });
    _fetchSlots(date);
  }

  void _onTimeSelected(String time) {
    setState(() => _selectedTime = time);
  }

  void _continueToPayment() {
    if (_selectedTime == null) return;
    if (widget.isHomeService) {
      if (!(_formKey.currentState?.validate() ?? false)) return;
    }
    setState(() => _step = 1);
  }

  Future<void> _confirm() async {
    final bookingProvider = context.read<BookingProvider>();
    bookingProvider.clearError();

    final addressToSave = widget.isHomeService
        ? _addressController.text.trim()
        : 'At Salon (${widget.providerAddress.isNotEmpty ? widget.providerAddress : 'Shop Location'})';

    final booking = await bookingProvider.createBooking(
      providerId: widget.providerId,
      providerName: widget.providerName,
      serviceId: widget.serviceId,
      serviceName: widget.serviceName,
      date: _selectedDate,
      timeSlot: _selectedTime ?? '',
      address: addressToSave,
      notes: _notesController.text.trim(),
      paymentMethod: _paymentMethod.value,
      price: widget.price,
      durationMinutes: widget.durationMinutes,
      staffId: widget.staffId,
      staffName: widget.staffName,
    );
    if (!mounted || booking == null) return;
    Navigator.pop(context, booking.id);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final keyboardInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: keyboardInset),
      child: Consumer<BookingProvider>(
        builder: (context, booking, _) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: AppConstants.spaceSm),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.divider,
                  borderRadius: BorderRadius.circular(AppConstants.radiusPill),
                ),
              ),
              _buildHeader(theme),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.spaceMd,
                  ),
                  child: _step == 0
                      ? _buildDetailsStep(theme, booking)
                      : _buildPaymentStep(theme, booking),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppConstants.spaceMd),
                child: _step == 0
                    ? AppButton(
                        label: 'Continue',
                        icon: Icons.arrow_forward_rounded,
                        onPressed:
                            _selectedTime == null ? null : _continueToPayment,
                      )
                    : AppButton(
                        label: 'Confirm Booking',
                        icon: Icons.check_rounded,
                        isLoading: booking.isSubmitting,
                        onPressed: booking.isSubmitting ? null : _confirm,
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceSm),
      child: Row(
        children: [
          if (_step == 1)
            IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              tooltip: 'Back',
              onPressed: () => setState(() => _step = 0),
            ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: _step == 1 ? 0 : AppConstants.spaceMd),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _step == 0 ? 'Booking details' : 'Payment',
                    style: theme.textTheme.titleLarge,
                  ),
                  Text(
                    'Step ${_step + 1} of 2',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close_rounded),
            tooltip: 'Close',
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsStep(ThemeData theme, BookingProvider booking) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(AppConstants.spaceMd),
          decoration: BoxDecoration(
            color: AppTheme.surfaceVariant,
            borderRadius: BorderRadius.circular(AppConstants.radiusMd),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.providerName, style: theme.textTheme.bodySmall),
              const SizedBox(height: AppConstants.spaceXs),
              Text(
                widget.serviceName,
                style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              if (widget.staffName != null && widget.staffName!.isNotEmpty) ...[
                const SizedBox(height: AppConstants.spaceXs),
                Row(
                  children: [
                    const Icon(Icons.person_outline_rounded,
                        size: 14, color: AppTheme.primary),
                    const SizedBox(width: AppConstants.spaceXs),
                    Text(
                      'Staff: ${widget.staffName}',
                      style: theme.textTheme.bodySmall?.copyWith(
                            color: AppTheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: AppConstants.spaceXs),
              Text(
                '${AppFormatters.durationLabel(widget.durationMinutes)} · '
                '${AppFormatters.currency(widget.price)}',
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppConstants.spaceLg),
        Text('Select date', style: theme.textTheme.titleMedium),
        const SizedBox(height: AppConstants.spaceSm),
        DateStrip(selectedDate: _selectedDate, onSelected: _onDateSelected),
        const SizedBox(height: AppConstants.spaceMd),
        Text('Select time', style: theme.textTheme.titleMedium),
        const SizedBox(height: AppConstants.spaceSm),
        if (booking.isLoading)
          const SizedBox(
            height: 96,
            child: AppLoadingIndicator(size: 24),
          )
        else if (booking.timeSlots.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppConstants.spaceMd),
            child: Text(
              'No slots left on this date. Try another day.',
              style: theme.textTheme.bodySmall,
            ),
          )
        else
          TimeSlotGrid(
            slots: booking.timeSlots,
            selectedTime: _selectedTime,
            onSelected: _onTimeSelected,
          ),
        const SizedBox(height: AppConstants.spaceLg),
        if (widget.isHomeService)
          Form(
            key: _formKey,
            child: Column(
              children: [
                AppTextField(
                  controller: _addressController,
                  label: 'Service address',
                  hint: 'House no., street, township',
                  prefixIcon: Icons.location_on_outlined,
                  textInputAction: TextInputAction.next,
                  validator: (value) =>
                      (value == null || value.trim().isEmpty)
                          ? 'Please enter your address'
                          : null,
                ),
                const SizedBox(height: AppConstants.spaceMd),
                AppTextField(
                  controller: _notesController,
                  label: 'Notes (optional)',
                  hint: 'Anything the provider should know?',
                  prefixIcon: Icons.notes_rounded,
                  maxLines: 3,
                  textInputAction: TextInputAction.done,
                  maxLength: 200,
                ),
              ],
            ),
          )
        else
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(AppConstants.spaceMd),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceVariant.withAlpha(120),
                  borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                  border: Border.all(color: AppTheme.divider),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.storefront_rounded,
                        color: AppTheme.primary, size: 20),
                    const SizedBox(width: AppConstants.spaceSm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Service Location',
                            style: theme.textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.primary,
                                ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'At Salon — ${widget.providerAddress.isNotEmpty ? widget.providerAddress : widget.providerName}',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppConstants.spaceMd),
              AppTextField(
                controller: _notesController,
                label: 'Notes (optional)',
                hint: 'Anything the salon should know?',
                prefixIcon: Icons.notes_rounded,
                maxLines: 2,
                textInputAction: TextInputAction.done,
                maxLength: 200,
              ),
            ],
          ),
        const SizedBox(height: AppConstants.spaceSm),
      ],
    );
  }

  Widget _buildPaymentStep(ThemeData theme, BookingProvider booking) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Payment method', style: theme.textTheme.titleMedium),
        const SizedBox(height: AppConstants.spaceSm),
        PaymentMethodPicker(
          selected: _paymentMethod,
          onSelected: (method) => setState(() => _paymentMethod = method),
        ),
        const SizedBox(height: AppConstants.spaceMd),
        Container(
          padding: const EdgeInsets.all(AppConstants.spaceMd),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(AppConstants.radiusMd),
            border: Border.all(color: AppTheme.divider),
          ),
          child: Column(
            children: [
              _SummaryRow(label: 'Provider', value: widget.providerName),
              _SummaryRow(label: 'Service', value: widget.serviceName),
              if (widget.staffName != null && widget.staffName!.isNotEmpty)
                _SummaryRow(label: 'Staff', value: widget.staffName!),
              _SummaryRow(
                label: 'Date',
                value: AppFormatters.dateLabel(_selectedDate),
              ),
              _SummaryRow(
                label: 'Time',
                value: _selectedTime == null
                    ? '—'
                    : AppFormatters.timeLabel(_selectedTime!),
              ),
              _SummaryRow(label: 'Payment', value: _paymentMethod.label),
              const Divider(height: AppConstants.spaceLg),
              Row(
                children: [
                  Text('Total', style: theme.textTheme.titleMedium),
                  const Spacer(),
                  Text(
                    AppFormatters.currency(widget.price),
                    style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primary,
                        ),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (booking.error != null) ...[
          const SizedBox(height: AppConstants.spaceMd),
          Container(
            padding: const EdgeInsets.all(AppConstants.spaceMd),
            decoration: BoxDecoration(
              color: AppTheme.error.withAlpha(20),
              borderRadius: BorderRadius.circular(AppConstants.radiusMd),
            ),
            child: Row(
              children: [
                const Icon(Icons.error_outline_rounded,
                    size: 20, color: AppTheme.error),
                const SizedBox(width: AppConstants.spaceSm),
                Expanded(
                  child: Text(
                    booking.error!,
                    style: theme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.error,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: AppConstants.spaceSm),
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.spaceSm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 84, child: Text(label, style: theme.textTheme.bodySmall)),
          Expanded(child: Text(value, style: theme.textTheme.bodyMedium)),
        ],
      ),
    );
  }
}
