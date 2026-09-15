import '../../provider_portal/domain/entities/payment_method_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_loading_indicator.dart';
import '../../../core/widgets/app_text_field.dart';
import '../domain/entities/payment_method.dart';
import '../providers/booking_provider.dart';
import '../../profile/providers/profile_provider.dart';
import '../../profile/domain/entities/user_profile.dart';
import '../../home/screens/map_location_picker_screen.dart';
import '../../../core/providers/location_provider.dart';
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
    this.isShop = true,
    this.isHomeService = true,
    this.providerAddress = '',
    this.itemizedServices,
    this.isClosedToday = false,
  });

  final String providerId;
  final String providerName;
  final String serviceId;
  final String serviceName;
  final int price;
  final int durationMinutes;
  final String? staffId;
  final String? staffName;
  final bool isShop;
  final bool isHomeService;
  final String providerAddress;
  final List<String>? itemizedServices;
  final bool isClosedToday;

  @override
  State<BookingFormSheet> createState() => _BookingFormSheetState();
}

class _BookingFormSheetState extends State<BookingFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _notesController = TextEditingController();

  int _step = 0;
  late String _selectedDate;
  String? _selectedTime;
  String? _selectedLocationId;
  late String _selectedServiceLocationType; // 'in_shop' | 'home_service'
  PaymentMethod _paymentMethod = PaymentMethod.cash;
  PaymentMethodConfig? _selectedPaymentConfig;

  @override
  void initState() {
    super.initState();
    final initialDateObj = widget.isClosedToday
        ? DateTime.now().add(const Duration(days: 1))
        : DateTime.now();
    _selectedDate = AppFormatters.isoDay(initialDateObj);

    if (widget.isShop && widget.isHomeService) {
      _selectedServiceLocationType = 'in_shop';
    } else if (widget.isShop) {
      _selectedServiceLocationType = 'in_shop';
    } else {
      _selectedServiceLocationType = 'home_service';
    }

    // Deferring keeps notifyListeners out of the build phase.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _fetchSlots(_selectedDate);
      context
          .read<BookingProvider>()
          .fetchProviderPaymentMethods(widget.providerId);
          
      final profileProvider = context.read<ProfileProvider>();
      if (profileProvider.profile == null) {
        profileProvider.fetchProfile().then((_) {
          if (mounted && profileProvider.profile != null) {
            if (_phoneController.text.isEmpty && profileProvider.profile!.phone.isNotEmpty) {
              _phoneController.text = profileProvider.profile!.phone;
            }
            final locs = profileProvider.profile?.savedLocations ?? [];
            if (locs.isNotEmpty && _selectedLocationId == null) {
              setState(() {
                _selectedLocationId = locs.first.id;
                _addressController.text = locs.first.address;
              });
            }
          }
        });
      } else {
        if (_phoneController.text.isEmpty && profileProvider.profile!.phone.isNotEmpty) {
          _phoneController.text = profileProvider.profile!.phone;
        }
        final locs = profileProvider.profile?.savedLocations ?? [];
        if (locs.isNotEmpty && _selectedLocationId == null) {
          setState(() {
            _selectedLocationId = locs.first.id;
            _addressController.text = locs.first.address;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _addressController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _fetchSlots(String date) {
    context.read<BookingProvider>().fetchTimeSlots(
          providerId: widget.providerId,
          date: date,
          staffId: widget.staffId,
          durationMinutes: widget.durationMinutes,
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
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _step = 1);
  }

  Future<void> _confirm() async {
    final bookingProvider = context.read<BookingProvider>();
    bookingProvider.clearError();

    final isHome = _selectedServiceLocationType == 'home_service';

    final addressToSave = isHome
        ? _addressController.text.trim()
        : 'At Salon (${widget.providerAddress.isNotEmpty ? widget.providerAddress : widget.providerName})';

    final activeConfig = _selectedPaymentConfig ??
        (bookingProvider.providerPaymentMethods.isNotEmpty
            ? bookingProvider.providerPaymentMethods.firstWhere(
                (m) =>
                    m.code.toLowerCase() ==
                    _paymentMethod.value.toLowerCase(),
                orElse: () => bookingProvider.providerPaymentMethods.first,
              )
            : null);

    final paymentMethodParam = activeConfig?.id.isNotEmpty == true
        ? activeConfig!.id
        : _paymentMethod.value;

    double? lat;
    double? lng;
    if (isHome) {
      final profileLocations = context.read<ProfileProvider>().profile?.savedLocations ?? [];
      final selectedLoc = profileLocations.where((l) => l.id == _selectedLocationId).firstOrNull;
      if (selectedLoc != null) {
        lat = selectedLoc.latitude;
        lng = selectedLoc.longitude;
      } else {
        final locProv = context.read<LocationProvider>();
        lat = locProv.activeLat;
        lng = locProv.activeLng;
      }
    }

    final booking = await bookingProvider.createBooking(
      providerId: widget.providerId,
      providerName: widget.providerName,
      serviceId: widget.serviceId,
      serviceName: widget.serviceName,
      date: _selectedDate,
      timeSlot: _selectedTime ?? '',
      bookingType: _selectedServiceLocationType,
      address: addressToSave,
      latitude: lat,
      longitude: lng,
      notes: _notesController.text.trim(),
      paymentMethod: paymentMethodParam,
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
        DateStrip(
          selectedDate: _selectedDate,
          onSelected: _onDateSelected,
          isTodayDisabled: widget.isClosedToday,
        ),
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
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.isShop && widget.isHomeService) ...[
                Text('Service Location Mode', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: AppConstants.spaceSm),
                Row(
                  children: [
                    Expanded(
                      child: ChoiceChip(
                        showCheckmark: false,
                        avatar: Icon(
                          Icons.storefront_rounded,
                          size: 18,
                          color: _selectedServiceLocationType == 'in_shop' ? Colors.white : AppTheme.textSecondary,
                        ),
                        label: Center(
                          child: Text(
                            'At Shop',
                            style: TextStyle(
                              color: _selectedServiceLocationType == 'in_shop' ? Colors.white : AppTheme.onSurface,
                              fontWeight: _selectedServiceLocationType == 'in_shop' ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                        selected: _selectedServiceLocationType == 'in_shop',
                        selectedColor: AppTheme.primary,
                        backgroundColor: AppTheme.surfaceVariant,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() => _selectedServiceLocationType = 'in_shop');
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: AppConstants.spaceSm),
                    Expanded(
                      child: ChoiceChip(
                        showCheckmark: false,
                        avatar: Icon(
                          Icons.home_outlined,
                          size: 18,
                          color: _selectedServiceLocationType == 'home_service' ? Colors.white : AppTheme.textSecondary,
                        ),
                        label: Center(
                          child: Text(
                            'Home Service',
                            style: TextStyle(
                              color: _selectedServiceLocationType == 'home_service' ? Colors.white : AppTheme.onSurface,
                              fontWeight: _selectedServiceLocationType == 'home_service' ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                        selected: _selectedServiceLocationType == 'home_service',
                        selectedColor: AppTheme.primary,
                        backgroundColor: AppTheme.surfaceVariant,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() => _selectedServiceLocationType = 'home_service');
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.spaceMd),
              ],
              if (_selectedServiceLocationType == 'home_service') ...[
                Builder(
                  builder: (context) {
                    final savedLocations = context.watch<ProfileProvider>().profile?.savedLocations ?? [];
                    
                    // Safely validate _selectedLocationId against actual available item values
                    String? activeLocationValue;
                    if (savedLocations.any((l) => l.id == _selectedLocationId)) {
                      activeLocationValue = _selectedLocationId;
                    } else if (savedLocations.isNotEmpty) {
                      activeLocationValue = savedLocations.last.id;
                    }

                    return DropdownButtonFormField<String>(
                      key: Key('addr_dropdown_${activeLocationValue}_${savedLocations.length}'),
                      value: activeLocationValue,
                      decoration: InputDecoration(
                        labelText: 'Service address',
                        prefixIcon: const Icon(Icons.location_on_outlined, color: AppTheme.textSecondary),
                        filled: true,
                        fillColor: AppTheme.surfaceVariant,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                          borderSide: const BorderSide(color: AppTheme.primary, width: 2),
                        ),
                      ),
                      isExpanded: true,
                      items: [
                        ...savedLocations.map((loc) => DropdownMenuItem(
                          value: loc.id,
                          child: Text('${loc.label} - ${loc.address}', maxLines: 1, overflow: TextOverflow.ellipsis),
                        )),
                        const DropdownMenuItem(
                          value: 'ADD_NEW',
                          child: Text('+ Add New Location...', style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold)),
                        ),
                      ],
                      onChanged: (value) async {
                        if (value == 'ADD_NEW') {
                          final newLoc = await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const MapLocationPickerScreen()),
                          );
                          if (newLoc != null && newLoc is SavedLocation) {
                            if (!context.mounted) return;
                            final updatedLocs = context.read<ProfileProvider>().profile?.savedLocations ?? [];
                            final match = updatedLocs.firstWhere(
                              (l) => l.id == newLoc.id || (l.label == newLoc.label && l.address == newLoc.address),
                              orElse: () => updatedLocs.isNotEmpty ? updatedLocs.last : newLoc,
                            );
                            setState(() {
                              _selectedLocationId = match.id;
                              _addressController.text = match.address;
                            });
                          }
                        } else if (value != null) {
                          final profile = context.read<ProfileProvider>().profile;
                          final loc = profile?.savedLocations.where((l) => l.id == value).firstOrNull;
                          if (loc != null) {
                            setState(() {
                              _selectedLocationId = value;
                              _addressController.text = loc.address;
                            });
                          }
                        }
                      },
                      validator: (value) =>
                          (value == null || value == 'ADD_NEW')
                              ? 'Please select your address'
                              : null,
                    );
                  },
                ),
                const SizedBox(height: AppConstants.spaceMd),
              ] else ...[
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
                      const Icon(Icons.storefront_rounded, color: AppTheme.primary, size: 20),
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
              ],
              AppTextField(
                controller: _phoneController,
                label: 'Contact Phone Number',
                hint: 'e.g. 09123456789',
                prefixIcon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Please enter your contact phone number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppConstants.spaceMd),
              AppTextField(
                controller: _notesController,
                label: 'Notes (optional)',
                hint: 'Anything the provider should know?',
                prefixIcon: Icons.notes_rounded,
                maxLines: 2,
                textInputAction: TextInputAction.done,
                maxLength: 200,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppConstants.spaceSm),
      ],
    );
  }

  Widget _buildPaymentStep(ThemeData theme, BookingProvider booking) {
    final activeConfig = _selectedPaymentConfig ??
        (booking.providerPaymentMethods.isNotEmpty
            ? booking.providerPaymentMethods.firstWhere(
                (m) =>
                    m.code.toLowerCase() ==
                    _paymentMethod.value.toLowerCase(),
                orElse: () => booking.providerPaymentMethods.first,
              )
            : null);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Payment method', style: theme.textTheme.titleMedium),
        const SizedBox(height: AppConstants.spaceSm),
        PaymentMethodPicker(
          selected: _paymentMethod,
          methods: booking.providerPaymentMethods,
          selectedConfig: activeConfig,
          onSelected: (method) => setState(() => _paymentMethod = method),
          onConfigSelected: (cfg) =>
              setState(() => _selectedPaymentConfig = cfg),
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
              _SummaryRow(
                label: 'Payment',
                value: activeConfig?.name ?? _paymentMethod.label,
              ),
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
              if (activeConfig != null &&
                  (activeConfig.accountName.isNotEmpty ||
                      activeConfig.accountNumber.isNotEmpty ||
                      activeConfig.instructions.isNotEmpty ||
                      activeConfig.qrCodeUrl.isNotEmpty)) ...[
                const SizedBox(height: AppConstants.spaceMd),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppConstants.spaceMd),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withAlpha(12),
                    borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                    border: Border.all(color: AppTheme.primary.withAlpha(40)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.info_outline_rounded,
                              size: 18, color: AppTheme.primary),
                          const SizedBox(width: AppConstants.spaceXs),
                          Text(
                            'Payment Info',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppTheme.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppConstants.spaceSm),
                      if (activeConfig.accountName.isNotEmpty) ...[
                        Text(
                          'Account Name: ${activeConfig.accountName}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                      ],
                      if (activeConfig.accountNumber.isNotEmpty) ...[
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Account / Phone: ${activeConfig.accountNumber}',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.primary,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.copy_rounded, size: 16),
                              tooltip: 'Copy account number',
                              visualDensity: VisualDensity.compact,
                              onPressed: () {
                                Clipboard.setData(
                                  ClipboardData(
                                      text: activeConfig.accountNumber),
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        'Account number copied to clipboard'),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                      ],
                      if (activeConfig.instructions.isNotEmpty) ...[
                        Text(
                          'Instructions: ${activeConfig.instructions}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                      ],
                      if (activeConfig.qrCodeUrl.isNotEmpty) ...[
                        const SizedBox(height: AppConstants.spaceSm),
                        Center(
                          child: ClipRRect(
                            borderRadius:
                                BorderRadius.circular(AppConstants.radiusSm),
                            child: Image.network(
                              activeConfig.qrCodeUrl,
                              width: 150,
                              height: 150,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const SizedBox.shrink(),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
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
