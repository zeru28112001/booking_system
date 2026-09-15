import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../data/models/provider_profile_request_model.dart';
import '../providers/admin_portal_provider.dart';

class AdminProvidersScreen extends StatefulWidget {
  const AdminProvidersScreen({super.key});

  @override
  State<AdminProvidersScreen> createState() => _AdminProvidersScreenState();
}

class _AdminProvidersScreenState extends State<AdminProvidersScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showRejectDialog(BuildContext context, String providerId, String shopName) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Reject $shopName?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Please state the reason for verification rejection:'),
            const SizedBox(height: AppConstants.spaceSm),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                hintText: 'e.g. Invalid business license or address',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
            onPressed: () {
              context.read<AdminPortalProvider>().rejectProvider(
                    providerId,
                    reasonController.text.trim(),
                  );
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Verification rejected for $shopName')),
              );
            },
            child: const Text('Reject Verification'),
          ),
        ],
      ),
    );
  }

  void _showProfileRequestRejectDialog(BuildContext context, String requestId, String shopName) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Reject Profile Request for $shopName?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Please state the reason for rejecting this change request:'),
            const SizedBox(height: AppConstants.spaceSm),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                hintText: 'e.g. Unverified address update',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
            onPressed: () {
              context.read<AdminPortalProvider>().rejectProfileRequest(
                    requestId,
                    reasonController.text.trim(),
                  );
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Profile request rejected for $shopName')),
              );
            },
            child: const Text('Reject Request'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminPortalProvider>(
      builder: (context, admin, _) {
        final pendingVerifications = admin.pendingVerifications;
        final pendingRequests = admin.pendingProfileRequests;
        final allProviders = admin.providers;

        return DefaultTabController(
          length: 3,
          child: Scaffold(
            appBar: AppBar(
              centerTitle: false,
              title: const Text('Provider & Request Queue'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh_rounded),
                  onPressed: () => admin.fetchAdminDashboardData(),
                  tooltip: 'Refresh Providers',
                ),
              ],
              bottom: TabBar(
                isScrollable: true,
                tabs: [
                  Tab(
                    child: Row(
                      children: [
                        const Text('Verifications'),
                        if (pendingVerifications.isNotEmpty) ...[
                          const SizedBox(width: 6),
                          _buildBadge(pendingVerifications.length, AppTheme.warning),
                        ],
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      children: [
                        const Text('Profile Requests'),
                        if (pendingRequests.isNotEmpty) ...[
                          const SizedBox(width: 6),
                          _buildBadge(pendingRequests.length, AppTheme.info),
                        ],
                      ],
                    ),
                  ),
                  Tab(text: 'Directory (${allProviders.length})'),
                ],
              ),
            ),
            body: TabBarView(
              children: [
                // Tab 1: Account Verifications
                _buildVerificationsQueue(context, admin, pendingVerifications),

                // Tab 2: Profile Edit Requests
                _buildProfileRequestsQueue(context, admin, pendingRequests),

                // Tab 3: Directory
                _buildProviderDirectory(context, admin, allProviders),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBadge(int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        '$count',
        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildVerificationsQueue(BuildContext context, AdminPortalProvider admin, List pending) {
    if (pending.isEmpty) {
      return RefreshIndicator(
        onRefresh: () => admin.fetchAdminDashboardData(),
        child: const SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: 400,
            child: AppEmptyState(
              icon: Icons.verified_user_outlined,
              title: 'Verification Queue Clear',
              subtitle: 'All provider verification applications have been reviewed.',
            ),
          ),
        ),
      );
    }

    final theme = Theme.of(context);

    return RefreshIndicator(
      onRefresh: () => admin.fetchAdminDashboardData(),
      child: ListView.separated(
        padding: const EdgeInsets.all(AppConstants.spaceMd),
        itemCount: pending.length,
        separatorBuilder: (ctx, i) => const SizedBox(height: AppConstants.spaceSm),
        itemBuilder: (context, index) {
          final p = pending[index];
          return Container(
            padding: const EdgeInsets.all(AppConstants.spaceMd),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(AppConstants.radiusMd),
              border: Border.all(color: AppTheme.warning.withAlpha(120)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.warning.withAlpha(20),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.store_rounded, color: AppTheme.warning),
                    ),
                    const SizedBox(width: AppConstants.spaceMd),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(p.shopName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          Text('${p.categoryName} · ${p.phone}', style: theme.textTheme.bodySmall),
                          Text(p.address, style: theme.textTheme.bodySmall?.copyWith(color: AppTheme.textSecondary)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.spaceMd),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(foregroundColor: AppTheme.error),
                        onPressed: () => _showRejectDialog(context, p.id, p.shopName),
                        child: const Text('Reject'),
                      ),
                    ),
                    const SizedBox(width: AppConstants.spaceMd),
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
                        label: const Text('Approve Provider'),
                        style: ElevatedButton.styleFrom(backgroundColor: AppTheme.success),
                        onPressed: () {
                          admin.approveProvider(p.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('${p.shopName} verified successfully!')),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileRequestsQueue(
      BuildContext context, AdminPortalProvider admin, List<ProviderProfileRequestModel> requests) {
    if (requests.isEmpty) {
      return RefreshIndicator(
        onRefresh: () => admin.fetchPendingProfileRequests(),
        child: const SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: 400,
            child: AppEmptyState(
              icon: Icons.published_with_changes_rounded,
              title: 'No Pending Profile Requests',
              subtitle: 'No provider profile edit requests awaiting admin approval.',
            ),
          ),
        ),
      );
    }

    final theme = Theme.of(context);

    return RefreshIndicator(
      onRefresh: () => admin.fetchPendingProfileRequests(),
      child: ListView.separated(
        padding: const EdgeInsets.all(AppConstants.spaceMd),
        itemCount: requests.length,
        separatorBuilder: (ctx, i) => const SizedBox(height: AppConstants.spaceSm),
        itemBuilder: (context, index) {
          final req = requests[index];
          final changes = req.requestedChanges;

          return Container(
            padding: const EdgeInsets.all(AppConstants.spaceMd),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(AppConstants.radiusMd),
              border: Border.all(color: AppTheme.info.withAlpha(120)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.info.withAlpha(20),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.edit_note_rounded, color: AppTheme.info),
                    ),
                    const SizedBox(width: AppConstants.spaceMd),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(req.providerName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          Text('Requested profile update', style: theme.textTheme.bodySmall?.copyWith(color: AppTheme.info)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.spaceMd),
                Container(
                  padding: const EdgeInsets.all(AppConstants.spaceSm),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceVariant.withAlpha(120),
                    borderRadius: BorderRadius.circular(AppConstants.radiusSm),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Requested Changes:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      const SizedBox(height: 4),
                      for (final entry in changes.entries)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 2),
                          child: Row(
                            children: [
                              Text('${entry.key}: ', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                              Expanded(
                                child: Text('${entry.value}', style: const TextStyle(fontSize: 13, color: AppTheme.primary)),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: AppConstants.spaceMd),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(foregroundColor: AppTheme.error),
                        onPressed: () => _showProfileRequestRejectDialog(context, req.id, req.providerName),
                        child: const Text('Reject Request'),
                      ),
                    ),
                    const SizedBox(width: AppConstants.spaceMd),
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
                        label: const Text('Approve Changes'),
                        style: ElevatedButton.styleFrom(backgroundColor: AppTheme.success),
                        onPressed: () async {
                          final ok = await admin.approveProfileRequest(req.id);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(ok ? 'Profile changes approved for ${req.providerName}' : 'Failed to approve request'),
                                backgroundColor: ok ? AppTheme.success : AppTheme.error,
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProviderDirectory(BuildContext context, AdminPortalProvider admin, List list) {
    final filtered = list.where((p) {
      if (_searchQuery.isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      return p.shopName.toLowerCase().contains(q) ||
          p.categoryName.toLowerCase().contains(q) ||
          p.phone.contains(q);
    }).toList();

    final theme = Theme.of(context);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(AppConstants.spaceMd),
          child: TextField(
            controller: _searchController,
            onChanged: (val) => setState(() => _searchQuery = val.trim()),
            decoration: InputDecoration(
              hintText: 'Search provider name, category or phone...',
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
          child: RefreshIndicator(
            onRefresh: () => admin.fetchAdminDashboardData(),
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceMd),
              itemCount: filtered.length,
              separatorBuilder: (ctx, i) => const SizedBox(height: AppConstants.spaceSm),
              itemBuilder: (context, index) {
                final p = filtered[index];
                return Container(
                  padding: const EdgeInsets.all(AppConstants.spaceMd),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                    border: Border.all(color: AppTheme.divider),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.storefront_rounded, color: AppTheme.primary, size: 28),
                      const SizedBox(width: AppConstants.spaceMd),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(p.shopName, style: const TextStyle(fontWeight: FontWeight.bold)),
                            Text('${p.categoryName} · ${p.phone}', style: theme.textTheme.bodySmall),
                            Text(
                              'Modes: ${p.isShop ? "Shop" : ""}${p.isShop && p.isHomeService ? " & " : ""}${p.isHomeService ? "Home" : ""}',
                              style: theme.textTheme.bodySmall?.copyWith(color: AppTheme.primary, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                      _buildStatusBadge(p.verificationStatus),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bg;
    Color fg;
    String label = status.toUpperCase();

    if (status == 'verified') {
      bg = AppTheme.success.withAlpha(30);
      fg = AppTheme.success;
      label = 'Verified';
    } else if (status == 'pending') {
      bg = AppTheme.warning.withAlpha(30);
      fg = AppTheme.warning;
      label = 'Pending';
    } else {
      bg = AppTheme.error.withAlpha(30);
      fg = AppTheme.error;
      label = 'Rejected';
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
