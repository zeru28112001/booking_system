import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../booking/domain/entities/booking.dart';
import '../providers/admin_portal_provider.dart';

class AdminBookingsScreen extends StatefulWidget {
  const AdminBookingsScreen({super.key});

  @override
  State<AdminBookingsScreen> createState() => _AdminBookingsScreenState();
}

class _AdminBookingsScreenState extends State<AdminBookingsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final _tabs = ['All', 'Pending', 'Accepted', 'In Progress', 'Completed', 'Cancelled'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<AdminPortalProvider>().fetchAllBookings();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showBookingDetailsModal(BuildContext context, Booking booking) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppConstants.radiusLg)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (_, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(AppConstants.spaceLg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: AppConstants.spaceSm),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Admin Booking Inspector', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: AppConstants.spaceSm),

              _buildRow(context, 'Booking ID', booking.id),
              _buildRow(context, 'Provider', booking.providerName),
              _buildRow(context, 'Service', booking.serviceName),
              if (booking.staffName != null && booking.staffName!.isNotEmpty)
                _buildRow(context, 'Assigned Staff', booking.staffName!),
              _buildRow(
                context,
                'Service Mode',
                booking.bookingType == 'home_service' ? 'Home Service (On-Site)' : 'At Salon / Shop',
              ),
              _buildRow(context, 'Status', booking.status.toUpperCase()),
              _buildRow(context, 'Date & Time', '${booking.date} at ${booking.timeSlot}'),
              _buildRow(context, 'Price', AppFormatters.currency(booking.price)),
              _buildRow(context, 'Customer Name', booking.customerName ?? 'Customer'),
              if (booking.customerPhone != null && booking.customerPhone!.isNotEmpty)
                _buildRow(context, 'Customer Phone', booking.customerPhone!),
              if (booking.bookingType == 'home_service' && booking.address.isNotEmpty)
                _buildRow(context, 'Customer Address', booking.address),
              _buildRow(context, 'Payment Method', booking.paymentMethod),

              if (booking.notes.trim().isNotEmpty) ...[
                const SizedBox(height: AppConstants.spaceSm),
                Text('Customer Notes:', style: theme.textTheme.bodySmall?.copyWith(color: AppTheme.textSecondary, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppConstants.spaceMd),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                  ),
                  child: Text(booking.notes, style: theme.textTheme.bodyMedium),
                ),
              ],
              const SizedBox(height: AppConstants.spaceLg),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRow(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.spaceMd),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(label, style: theme.textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary)),
          ),
          Expanded(
            child: Text(value, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminPortalProvider>();
    final allBookings = admin.allBookings;

    final pendingCount = allBookings.where((b) => b.status.toLowerCase() == 'pending').length;
    final acceptedCount = allBookings.where((b) => b.status.toLowerCase() == 'accepted').length;
    final inProgressCount = allBookings.where((b) => b.status.toLowerCase() == 'in_progress').length;
    final completedCount = allBookings.where((b) => b.status.toLowerCase() == 'completed').length;
    final cancelledCount = allBookings.where((b) => b.status.toLowerCase() == 'cancelled').length;

    final tabLabels = [
      'All (${allBookings.length})',
      'Pending ($pendingCount)',
      'Accepted ($acceptedCount)',
      'In Progress ($inProgressCount)',
      'Completed ($completedCount)',
      'Cancelled ($cancelledCount)',
    ];

    return DefaultTabController(
      length: _tabs.length,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: false,
          title: const Text('Global Booking Explorer'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              onPressed: () => admin.fetchAllBookings(),
              tooltip: 'Refresh Bookings',
            ),
          ],
          bottom: TabBar(
            isScrollable: true,
            tabs: tabLabels.map((t) => Tab(text: t)).toList(),
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppConstants.spaceMd),
              child: TextField(
                controller: _searchController,
                onChanged: (val) => setState(() => _searchQuery = val.trim()),
                decoration: InputDecoration(
                  hintText: 'Search booking ID, customer or provider...',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                ),
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildFilteredList(admin, allBookings, 'all'),
                  _buildFilteredList(admin, allBookings, 'pending'),
                  _buildFilteredList(admin, allBookings, 'accepted'),
                  _buildFilteredList(admin, allBookings, 'in_progress'),
                  _buildFilteredList(admin, allBookings, 'completed'),
                  _buildFilteredList(admin, allBookings, 'cancelled'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilteredList(AdminPortalProvider admin, List<Booking> list, String targetStatus) {
    var filtered = targetStatus == 'all'
        ? list
        : list.where((b) => b.status.toLowerCase() == targetStatus.toLowerCase()).toList();

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      filtered = filtered.where((b) {
        return b.id.toLowerCase().contains(q) ||
            b.providerName.toLowerCase().contains(q) ||
            (b.customerName?.toLowerCase().contains(q) ?? false) ||
            b.serviceName.toLowerCase().contains(q);
      }).toList();
    }

    if (filtered.isEmpty) {
      final statusLabel = targetStatus == 'all' ? 'System' : targetStatus.replaceAll('_', ' ').toUpperCase();
      return RefreshIndicator(
        onRefresh: () => admin.fetchAllBookings(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: 350,
            child: AppEmptyState(
              icon: Icons.calendar_today_outlined,
              title: 'No $statusLabel Bookings',
              subtitle: targetStatus == 'all'
                  ? 'No system appointments found.'
                  : 'There are currently 0 appointments with status "$targetStatus".',
            ),
          ),
        ),
      );
    }

    final theme = Theme.of(context);

    return RefreshIndicator(
      onRefresh: () => admin.fetchAllBookings(),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceMd),
        itemCount: filtered.length,
        separatorBuilder: (ctx, i) => const SizedBox(height: AppConstants.spaceSm),
        itemBuilder: (context, index) {
          final b = filtered[index];
          return Card(
            margin: EdgeInsets.zero,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusMd),
              side: const BorderSide(color: AppTheme.divider),
            ),
            color: AppTheme.surface,
            child: InkWell(
              onTap: () => _showBookingDetailsModal(context, b),
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.spaceMd),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            '${b.providerName} · ${b.serviceName}',
                            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        _buildStatusBadge(b.status),
                      ],
                    ),
                    const SizedBox(height: AppConstants.spaceSm),
                    Row(
                      children: [
                        const Icon(Icons.person_outline_rounded, size: 14, color: AppTheme.textSecondary),
                        const SizedBox(width: 4),
                        Text(b.customerName ?? 'Customer', style: theme.textTheme.bodySmall),
                        const SizedBox(width: 12),
                        const Icon(Icons.calendar_today_outlined, size: 14, color: AppTheme.textSecondary),
                        const SizedBox(width: 4),
                        Text('${b.date} at ${b.timeSlot}', style: theme.textTheme.bodySmall),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          AppFormatters.currency(b.price),
                          style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold, color: AppTheme.primary),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Mode: ${b.bookingType == "home_service" ? "Home Service" : "At Shop"}',
                          style: theme.textTheme.bodySmall?.copyWith(color: AppTheme.textSecondary),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bg;
    Color fg;
    String label = status.toUpperCase();

    switch (status) {
      case 'pending':
        bg = AppTheme.warning.withAlpha(30);
        fg = AppTheme.warning;
        label = 'Pending';
        break;
      case 'accepted':
        bg = AppTheme.info.withAlpha(30);
        fg = AppTheme.info;
        label = 'Accepted';
        break;
      case 'in_progress':
        bg = AppTheme.primary.withAlpha(30);
        fg = AppTheme.primary;
        label = 'In Progress';
        break;
      case 'completed':
        bg = AppTheme.success.withAlpha(30);
        fg = AppTheme.success;
        label = 'Completed';
        break;
      case 'cancelled':
        bg = AppTheme.error.withAlpha(30);
        fg = AppTheme.error;
        label = 'Cancelled';
        break;
      default:
        bg = Colors.grey.withAlpha(30);
        fg = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppConstants.radiusSm),
      ),
      child: Text(label, style: TextStyle(color: fg, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }
}
