import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_loading_indicator.dart';
import 'package:booking_system/features/auth/providers/auth_provider.dart';
import '../../home/screens/map_location_picker_screen.dart';
import '../domain/entities/provider_profile.dart';
import '../providers/provider_portal_provider.dart';

class ProviderProfileScreen extends StatefulWidget {
  const ProviderProfileScreen({super.key});

  @override
  State<ProviderProfileScreen> createState() => _ProviderProfileScreenState();
}

class _ProviderProfileScreenState extends State<ProviderProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<ProviderPortalProvider>();
      if (provider.profile == null) {
        provider.fetchAllData();
      }
    });
  }

  void _showEditProfileDialog(BuildContext context, ProviderProfile profile) {
    final nameController = TextEditingController(text: profile.shopName);
    final categoryController = TextEditingController(text: profile.categoryName);
    final phoneController = TextEditingController(text: profile.phone);
    final addressController = TextEditingController(text: profile.address);
    final descController = TextEditingController(text: profile.description);
    final latController = TextEditingController(text: profile.latitude?.toString() ?? '');
    final lngController = TextEditingController(text: profile.longitude?.toString() ?? '');
    bool isShop = profile.isShop;
    bool isHomeService = profile.isHomeService;

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Edit Shop Profile'),
            content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Shop / Business Name'),
              ),
              const SizedBox(height: AppConstants.spaceSm),
              TextField(
                controller: categoryController,
                decoration: const InputDecoration(labelText: 'Category'),
              ),
              const SizedBox(height: AppConstants.spaceSm),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: 'Business Phone'),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: AppConstants.spaceSm),
              TextField(
                controller: addressController,
                decoration: const InputDecoration(labelText: 'Shop Address'),
              ),
              const SizedBox(height: AppConstants.spaceSm),
              TextField(
                controller: descController,
                decoration: const InputDecoration(labelText: 'Business Description'),
                maxLines: 3,
              ),
              // const SizedBox(height: AppConstants.spaceSm),
              // SwitchListTile(
              //   contentPadding: EdgeInsets.zero,
              //   title: const Text('Storefront / Multi-Staff Shop', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              //   subtitle: const Text('Customers visit your shop or select staff', style: TextStyle(fontSize: 12)),
              //   value: isShop,
              //   onChanged: (val) => setState(() => isShop = val),
              // ),
              // SwitchListTile(
              //   contentPadding: EdgeInsets.zero,
              //   title: const Text('Home / On-Site Service', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              //   subtitle: const Text('You travel to customer\'s location/home', style: TextStyle(fontSize: 12)),
              //   value: isHomeService,
              //   onChanged: (val) => setState(() => isHomeService = val),
              // ),
              const SizedBox(height: AppConstants.spaceSm),
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (ctx) => MapLocationPickerScreen(
                        onLocationPicked: (lat, lng, address) async {
                          setState(() {
                            latController.text = lat.toString();
                            lngController.text = lng.toString();
                            if (addressController.text.isEmpty || addressController.text == 'Selected Location') {
                              addressController.text = address;
                            }
                          });
                          return true; // Auto-close map
                        },
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.map_outlined),
                label: const Text('Pick Location on Map'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
              ),
              if (latController.text.isNotEmpty && lngController.text.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    'Location selected: ${latController.text}, ${lngController.text}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
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
              final updated = ProviderProfile(
                id: profile.id,
                shopName: nameController.text.trim(),
                categoryName: categoryController.text.trim(),
                description: descController.text.trim(),
                address: addressController.text.trim(),
                phone: phoneController.text.trim(),
                isAvailable: profile.isAvailable,
                isShop: isShop,
                isHomeService: isHomeService,
                verificationStatus: profile.verificationStatus,
                rating: profile.rating,
                reviewCount: profile.reviewCount,
                imageUrl: profile.imageUrl,
                latitude: double.tryParse(latController.text.trim()),
                longitude: double.tryParse(lngController.text.trim()),
              );
              Navigator.pop(dialogCtx);
              _confirmAndRequestProfileChange(context, updated, 'Profile details');
            },
            child: const Text('Submit to Admin'),
          ),
        ],
      );
    }));
  }

  Future<void> _confirmAndRequestProfileChange(
    BuildContext context,
    ProviderProfile updated,
    String changeDescription,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Submit for Admin Approval?'),
        content: Text(
          'Changing your business profile settings ($changeDescription) requires Admin approval before taking effect.\n\n'
          'Would you like to submit this change request to the Administrator now?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogCtx, true),
            child: const Text('Submit Request'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final success = await context.read<ProviderPortalProvider>().requestProfileUpdate(updated);
      if (context.mounted && success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Change request submitted to Admin for approval!'),
            backgroundColor: AppTheme.primary,
          ),
        );
      }
    }
  }

  Future<void> _showAvailabilityConfirmationDialog(
    BuildContext context,
    ProviderPortalProvider provider,
    bool newStatus,
  ) async {
    final statusText = newStatus ? 'Available' : 'Busy / Closed';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Confirm Status Change'),
        content: Text(
          'Are you sure you want to change your shop status to "$statusText"?\n\n'
          '${newStatus ? "Customers will now be able to book services with your shop." : "When set to Busy / Closed, customers will not be able to make new bookings."}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: newStatus ? AppTheme.success : AppTheme.warning,
            ),
            onPressed: () => Navigator.pop(dialogCtx, true),
            child: Text('Confirm ($statusText)'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await provider.toggleAvailability(newStatus);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Provider Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit Profile',
            onPressed: () {
              final p = context.read<ProviderPortalProvider>().profile;
              if (p != null) _showEditProfileDialog(context, p);
            },
          ),
        ],
      ),
      body: Consumer<ProviderPortalProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.profile == null) {
            return const AppLoadingIndicator();
          }

          final p = provider.profile;
          if (p == null) {
            return const Center(child: Text('Failed to load profile.'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.spaceMd),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (p.hasPendingApproval) ...[
                  Container(
                    margin: const EdgeInsets.only(bottom: AppConstants.spaceMd),
                    padding: const EdgeInsets.all(AppConstants.spaceMd),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                      border: Border.all(color: Colors.amber.shade400),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.hourglass_top_rounded, color: Colors.amber.shade900),
                        const SizedBox(width: AppConstants.spaceSm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Change Request Pending Admin Approval',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.amber.shade900,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Your requested service mode / profile updates are currently under review by an Administrator.',
                                style: theme.textTheme.bodySmall?.copyWith(color: Colors.amber.shade900),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Profile Header Card
                Container(
                  padding: const EdgeInsets.all(AppConstants.spaceMd),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(AppConstants.radiusLg),
                    border: Border.all(color: AppTheme.divider),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 36,
                            backgroundColor: AppTheme.primaryLight,
                            backgroundImage: p.imageUrl.isNotEmpty ? NetworkImage(p.imageUrl) : null,
                            child: p.imageUrl.isEmpty
                                ? Text(
                                    p.shopName.isNotEmpty ? p.shopName[0].toUpperCase() : 'P',
                                    style: theme.textTheme.headlineMedium?.copyWith(color: AppTheme.primary),
                                  )
                                : null,
                          ),
                          const SizedBox(width: AppConstants.spaceMd),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  p.shopName,
                                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  p.categoryName,
                                  style: theme.textTheme.bodySmall?.copyWith(color: AppTheme.primary),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.star_rounded, size: 16, color: Colors.amber),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${p.rating} (${p.reviewCount} reviews)',
                                      style: theme.textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          _buildVerificationBadge(p.verificationStatus),
                        ],
                      ),
                      const Divider(height: 24),
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined, size: 18, color: AppTheme.textSecondary),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              p.address,
                              style: theme.textTheme.bodySmall?.copyWith(color: AppTheme.textSecondary),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.phone_outlined, size: 18, color: AppTheme.textSecondary),
                          const SizedBox(width: 8),
                          Text(
                            p.phone,
                            style: theme.textTheme.bodySmall?.copyWith(color: AppTheme.textSecondary),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppConstants.spaceLg),

                // Business Real-time Availability
                Material(
                  color: AppTheme.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                    side: const BorderSide(color: AppTheme.divider),
                  ),
                  child: SwitchListTile(
                    title: const Text('Store Status', style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(
                      provider.isAvailable
                          ? 'Available for new customer bookings'
                          : 'Currently set to Busy / Offline',
                      style: theme.textTheme.bodySmall,
                    ),
                    secondary: Icon(
                      provider.isAvailable ? Icons.storefront_rounded : Icons.storefront_outlined,
                      color: provider.isAvailable ? AppTheme.success : AppTheme.error,
                    ),
                    activeThumbColor: AppTheme.success,
                    value: provider.isAvailable,
                    onChanged: (val) {
                      _showAvailabilityConfirmationDialog(context, provider, val);
                    },
                  ),
                ),
                const SizedBox(height: AppConstants.spaceMd),

                // Service Modes (isShop & isHomeService)
                Material(
                  color: AppTheme.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                    side: const BorderSide(color: AppTheme.divider),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Padding(
                    padding: const EdgeInsets.all(AppConstants.spaceSm),
                    child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        child: Text(
                          'Service Mode Options (Requires Admin Review)',
                          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      SwitchListTile(
                        dense: true,
                        title: const Text('Storefront / Salon Shop (isShop)', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                        subtitle: const Text('In-shop bookings with staff options', style: TextStyle(fontSize: 11)),
                        secondary: const Icon(Icons.store_rounded, color: AppTheme.primary, size: 22),
                        value: p.isShop,
                        onChanged: (val) {
                          if (!val && !p.isHomeService) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('At least one service mode (Storefront Shop or Home Service) must remain active!'),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }
                          final updated = ProviderProfile(
                            id: p.id,
                            shopName: p.shopName,
                            categoryName: p.categoryName,
                            description: p.description,
                            address: p.address,
                            phone: p.phone,
                            isAvailable: p.isAvailable,
                            isShop: val,
                            isHomeService: p.isHomeService,
                            verificationStatus: p.verificationStatus,
                            rating: p.rating,
                            reviewCount: p.reviewCount,
                            imageUrl: p.imageUrl,
                            latitude: p.latitude,
                            longitude: p.longitude,
                          );
                          _confirmAndRequestProfileChange(context, updated, 'Storefront Shop mode');
                        },
                      ),
                      const Divider(height: 1),
                      SwitchListTile(
                        dense: true,
                        title: const Text('Home / On-Site Service (isHomeService)', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                        subtitle: const Text('Travel to customer location/home', style: TextStyle(fontSize: 11)),
                        secondary: const Icon(Icons.home_repair_service_rounded, color: AppTheme.primary, size: 22),
                        value: p.isHomeService,
                        onChanged: (val) {
                          if (!val && !p.isShop) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('At least one service mode (Storefront Shop or Home Service) must remain active!'),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }
                          final updated = ProviderProfile(
                            id: p.id,
                            shopName: p.shopName,
                            categoryName: p.categoryName,
                            description: p.description,
                            address: p.address,
                            phone: p.phone,
                            isAvailable: p.isAvailable,
                            isShop: p.isShop,
                            isHomeService: val,
                            verificationStatus: p.verificationStatus,
                            rating: p.rating,
                            reviewCount: p.reviewCount,
                            imageUrl: p.imageUrl,
                            latitude: p.latitude,
                            longitude: p.longitude,
                          );
                          _confirmAndRequestProfileChange(context, updated, 'Home Service mode');
                        },
                      ),
                    ],
                    ),
                  ),
                ),
                const SizedBox(height: AppConstants.spaceLg),

                // Business Management Links
                Text('Business Setup', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: AppConstants.spaceSm),
                _buildActionTile(
                  context,
                  icon: Icons.access_time_filled_rounded,
                  title: 'Weekly Working Hours',
                  subtitle: 'Set open days, start & end times',
                  onTap: () => context.push('/provider-schedule'),
                ),
                _buildActionTile(
                  context,
                  icon: Icons.account_balance_wallet_outlined,
                  title: 'Manage Payment Methods',
                  subtitle: 'Configure accepted payment options (Cash, Mobile Wallet, Bank QR)',
                  onTap: () => context.push('/provider-payment-methods'),
                ),
                _buildActionTile(
                  context,
                  icon: Icons.monetization_on_rounded,
                  title: 'Earnings & Booking Insights',
                  subtitle: 'View payout history and daily revenue',
                  onTap: () => context.push('/provider-earnings'),
                ),
                _buildActionTile(
                  context,
                  icon: Icons.edit_note_rounded,
                  title: 'Edit Business Description',
                  subtitle: p.description,
                  onTap: () => _showEditProfileDialog(context, p),
                ),
                const SizedBox(height: AppConstants.spaceLg),

                // Account & Session
                Text('Account', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: AppConstants.spaceSm),
                Material(
                  color: AppTheme.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                    side: const BorderSide(color: AppTheme.divider),
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.logout_rounded, color: AppTheme.error),
                    title: const Text('Logout Provider Account', style: TextStyle(color: AppTheme.error, fontWeight: FontWeight.bold)),
                    onTap: () async {
                      final auth = context.read<AuthProvider>();
                      final router = GoRouter.of(context);
                      await auth.logout();
                      router.go('/login');
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildActionTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.spaceSm),
      child: Material(
        color: AppTheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
          side: const BorderSide(color: AppTheme.divider),
        ),
        child: ListTile(
          leading: Icon(icon, color: AppTheme.primary),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(subtitle, style: theme.textTheme.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
          trailing: const Icon(Icons.chevron_right_rounded),
          onTap: onTap,
        ),
      ),
    );
  }

  Widget _buildVerificationBadge(String status) {
    final isVerified = status == 'verified';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isVerified ? AppTheme.success.withAlpha(20) : AppTheme.warning.withAlpha(20),
        borderRadius: BorderRadius.circular(AppConstants.radiusSm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isVerified ? Icons.check_circle_rounded : Icons.hourglass_top_rounded,
            size: 14,
            color: isVerified ? AppTheme.success : AppTheme.warning,
          ),
          const SizedBox(width: 4),
          Text(
            isVerified ? 'Verified' : 'Pending',
            style: TextStyle(
              color: isVerified ? AppTheme.success : AppTheme.warning,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
