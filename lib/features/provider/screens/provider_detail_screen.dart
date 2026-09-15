import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/app_error_state.dart';
import '../../../core/widgets/app_loading_indicator.dart';
import '../domain/entities/service.dart';
import '../domain/entities/service_provider.dart';
import '../domain/entities/staff.dart';
import '../providers/provider_detail_provider.dart';
import '../widgets/gradient_avatar.dart';
import '../widgets/review_card.dart';
import '../widgets/service_tile.dart';
import '../widgets/staff_picker.dart';

/// Phase 3 — provider profile: header, contact info, staff selection (if shop),
/// service groups, reviews and a sticky Book Now bar.
///
/// [onBook] hands the provider + chosen service (+ staff) back to the composition root
/// (main.dart) so this feature never imports features/booking.
class ProviderDetailScreen extends StatefulWidget {
  const ProviderDetailScreen({
    super.key,
    required this.providerId,
    required this.providerName,
    this.onBook,
  });

  final String providerId;
  final String providerName;
  final void Function(
    BuildContext context,
    ServiceProvider provider,
    List<Service> services,
    Staff? staff,
  )? onBook;

  @override
  State<ProviderDetailScreen> createState() => _ProviderDetailScreenState();
}

class _ProviderDetailScreenState extends State<ProviderDetailScreen> {
  int _groupIndex = 0;
  Staff? _selectedStaff;
  final Map<String, Service> _selectedServicesMap = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context
          .read<ProviderDetailProvider>()
          .fetchProviderDetail(widget.providerId);
    });
  }

  List<String> _groupsOf(ServiceProvider provider) =>
      provider.services.map((s) => s.group).toSet().toList();

  List<Service> _visibleServices(ServiceProvider provider) {
    final groups = _groupsOf(provider);
    if (groups.isEmpty) return const [];
    // Clamped, never reassigned here — build must stay side-effect free.
    final index = _groupIndex.clamp(0, groups.length - 1);
    return provider.services.where((s) => s.group == groups[index]).toList();
  }

  void _toggleService(Service service) {
    setState(() {
      if (_selectedServicesMap.containsKey(service.id)) {
        _selectedServicesMap.remove(service.id);
      } else {
        _selectedServicesMap[service.id] = service;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text(
          widget.providerName.isNotEmpty ? widget.providerName : 'Provider',
        ),
      ),
      body: Consumer<ProviderDetailProvider>(
        builder: (context, detail, _) {
          if (detail.isLoading) return const AppLoadingIndicator();

          if (detail.error != null) {
            return AppErrorState(
              message: detail.error!,
              onRetry: () => context
                  .read<ProviderDetailProvider>()
                  .fetchProviderDetail(widget.providerId),
            );
          }

          final provider = detail.provider;
          if (provider == null) {
            return AppEmptyState(
              icon: Icons.storefront_outlined,
              title: 'Provider not found',
              subtitle: 'This provider may have been removed.',
              actionLabel: 'Go back',
              onAction: () => context.pop(),
            );
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Header(provider: provider),
                if (!provider.isAvailable || !provider.isOpen)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(
                      left: AppConstants.spaceMd,
                      right: AppConstants.spaceMd,
                      top: AppConstants.spaceMd,
                    ),
                    padding: const EdgeInsets.all(AppConstants.spaceMd),
                    decoration: BoxDecoration(
                      color: AppTheme.warning.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                      border: Border.all(color: AppTheme.warning.withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline_rounded, color: AppTheme.warning, size: 24),
                        const SizedBox(width: AppConstants.spaceSm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Shop is Currently Busy / Closed Today',
                                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.warning,
                                    ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Not taking same-day bookings today. You can still schedule an appointment for upcoming days below.',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppTheme.onSurface,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.all(AppConstants.spaceMd),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        provider.name,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: AppConstants.spaceXs),
                      Text(
                        provider.tagline,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                      ),
                      const SizedBox(height: AppConstants.spaceSm),
                      _MetaRow(provider: provider),
                      const SizedBox(height: AppConstants.spaceMd),
                      _InfoRow(
                        icon: Icons.location_on_outlined,
                        text: provider.address,
                      ),
                      const SizedBox(height: AppConstants.spaceSm),
                      _InfoRow(icon: Icons.phone_outlined, text: provider.phone),
                      if (provider.isShop && provider.staffList.isNotEmpty) ...[
                        const SizedBox(height: AppConstants.spaceLg),
                        StaffPicker(
                          staffList: provider.staffList,
                          selectedStaffId: _selectedStaff?.id,
                          onStaffSelected: (staff) =>
                              setState(() => _selectedStaff = staff),
                        ),
                      ],
                      const SizedBox(height: AppConstants.spaceLg),
                      ..._buildServices(provider),
                      if (provider.reviews.isNotEmpty) ...[
                        const Divider(height: AppConstants.spaceXl),
                        const SizedBox(height: AppConstants.spaceLg),
                        Text(
                          'Reviews (${provider.reviewCount})',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: AppConstants.spaceMd),
                        for (final review in provider.reviews) ...[
                          ReviewCard(review: review),
                          const SizedBox(height: AppConstants.spaceSm),
                        ],
                      ],
                      const SizedBox(height: AppConstants.spaceMd),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: Consumer<ProviderDetailProvider>(
        builder: (context, detail, _) {
          final provider = detail.provider;
          if (detail.isLoading || detail.error != null || provider == null) {
            return const SizedBox.shrink();
          }
          final services = _visibleServices(provider);
          if (services.isEmpty) return const SizedBox.shrink();

          final selectedList = _selectedServicesMap.values.toList();
          final effectiveList = selectedList.isNotEmpty
              ? selectedList
              : [services.first];

          final totalPrice =
              effectiveList.fold(0, (sum, s) => sum + s.price);
          final totalDuration =
              effectiveList.fold(0, (sum, s) => sum + s.durationMinutes);

          return SafeArea(
            child: Container(
              color: AppTheme.surface,
              padding: const EdgeInsets.all(AppConstants.spaceMd),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (selectedList.length > 1) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${selectedList.length} Services Selected',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppTheme.primary,
                              ),
                        ),
                        Text(
                          '${AppFormatters.durationLabel(totalDuration)} · ${AppFormatters.currency(totalPrice)}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppTheme.onSurface,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppConstants.spaceSm),
                  ],
                  AppButton(
                    label: (!provider.isAvailable || !provider.isOpen)
                        ? (selectedList.length > 1
                            ? 'Schedule ${selectedList.length} Services for Future Date'
                            : 'Schedule for Future Date')
                        : selectedList.length > 1
                            ? 'Book ${selectedList.length} Services (${AppFormatters.currency(totalPrice)})'
                            : 'Book Now',
                    icon: Icons.calendar_month_rounded,
                    onPressed: widget.onBook == null
                        ? null
                        : () => widget.onBook!(
                              context,
                              provider,
                              effectiveList,
                              _selectedStaff,
                            ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  List<Widget> _buildServices(ServiceProvider provider) {
    final theme = Theme.of(context);
    final groups = _groupsOf(provider);
    if (groups.isEmpty) {
      return [
        Text(
          'No services listed yet.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppTheme.textSecondary,
          ),
        ),
      ];
    }

    final services = _visibleServices(provider);
    return [
      Text('Services', style: theme.textTheme.titleLarge),
      const SizedBox(height: AppConstants.spaceMd),
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (var i = 0; i < groups.length; i++) ...[
              ChoiceChip(
                label: Text(groups[i]),
                selected: i == _groupIndex.clamp(0, groups.length - 1),
                onSelected: (_) => setState(() => _groupIndex = i),
                selectedColor: AppTheme.primary,
                labelStyle: theme.textTheme.bodySmall?.copyWith(
                  color: i == _groupIndex.clamp(0, groups.length - 1)
                      ? AppTheme.onPrimary
                      : AppTheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: AppConstants.spaceSm),
            ],
          ],
        ),
      ),
      const SizedBox(height: AppConstants.spaceMd),
      for (final service in services) ...[
        ServiceTile(
          service: service,
          isSelected: _selectedServicesMap.containsKey(service.id),
          onTap: () => _toggleService(service),
        ),
        const SizedBox(height: AppConstants.spaceSm),
      ],
      const SizedBox(height: AppConstants.spaceSm),
    ];
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.provider});

  final ServiceProvider provider;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primary, AppTheme.accent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Hero(
            tag: 'provider-avatar-${provider.id}',
            child: GradientAvatar(name: provider.name, size: 72, fontSize: 28),
          ),
          const SizedBox(height: AppConstants.spaceSm),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.spaceSm,
              vertical: AppConstants.spaceXs,
            ),
            decoration: BoxDecoration(
              color: AppTheme.surface.withAlpha(230),
              borderRadius: BorderRadius.circular(AppConstants.radiusPill),
            ),
            child: Text(
              provider.isOpen ? 'Open now' : 'Closed',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: provider.isOpen
                        ? AppTheme.secondary
                        : AppTheme.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.provider});

  final ServiceProvider provider;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        const Icon(Icons.star_rounded, size: 18, color: AppTheme.warning),
        const SizedBox(width: AppConstants.spaceXs),
        Text(
          provider.rating.toStringAsFixed(1),
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: AppConstants.spaceXs),
        Text('(${provider.reviewCount} reviews)', style: theme.textTheme.bodySmall),
        const SizedBox(width: AppConstants.spaceSm),
        Text(
          '${provider.distanceKm.toStringAsFixed(1)} km away',
          style: theme.textTheme.bodySmall,
        ),
        const SizedBox(width: AppConstants.spaceSm),
        Text(
          AppFormatters.priceRange(provider.priceMin, provider.priceMax),
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppTheme.textSecondary),
        const SizedBox(width: AppConstants.spaceSm),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
          ),
        ),
      ],
    );
  }
}
