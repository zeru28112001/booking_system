import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../data/models/promo_banner_model.dart';
import '../providers/admin_portal_provider.dart';

class AdminBannersScreen extends StatefulWidget {
  final bool isEmbedded;
  const AdminBannersScreen({super.key, this.isEmbedded = true});

  @override
  State<AdminBannersScreen> createState() => _AdminBannersScreenState();
}

class _AdminBannersScreenState extends State<AdminBannersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminPortalProvider>().fetchBanners();
    });
  }

  void _showBannerDialog({PromoBannerModel? existingBanner}) {
    final titleController = TextEditingController(text: existingBanner?.title ?? '');
    final subtitleController = TextEditingController(text: existingBanner?.subtitle ?? '');
    final imageUrlController = TextEditingController(text: existingBanner?.imageUrl ?? '');
    final sortOrderController = TextEditingController(text: (existingBanner?.sortOrder ?? 0).toString());
    
    String selectedIcon = existingBanner?.iconName ?? 'local_offer';
    bool isActive = existingBanner?.isActive ?? true;
    bool isSubmitting = false;

    final iconPresets = [
      {'name': 'local_offer', 'icon': Icons.local_offer},
      {'name': 'spa', 'icon': Icons.spa},
      {'name': 'cleaning', 'icon': Icons.cleaning_services},
      {'name': 'content_cut', 'icon': Icons.content_cut},
      {'name': 'brush', 'icon': Icons.brush},
      {'name': 'home_repair_service', 'icon': Icons.home_repair_service},
      {'name': 'medical_services', 'icon': Icons.medical_services},
      {'name': 'star', 'icon': Icons.star_rounded},
    ];

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.radiusLg)),
              title: Row(
                children: [
                  Icon(
                    existingBanner == null ? Icons.add_photo_alternate_rounded : Icons.edit_rounded,
                    color: AppTheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(existingBanner == null ? 'Add Promo Banner' : 'Edit Promo Banner'),
                ],
              ),
              content: SingleChildScrollView(
                child: SizedBox(
                  width: 440,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: titleController,
                        decoration: const InputDecoration(
                          labelText: 'Title *',
                          hintText: 'e.g. Glow Up Weekend',
                          prefixIcon: Icon(Icons.title_rounded),
                        ),
                      ),
                      const SizedBox(height: AppConstants.spaceSm),
                      TextField(
                        controller: subtitleController,
                        decoration: const InputDecoration(
                          labelText: 'Subtitle / Promotion Offer *',
                          hintText: 'e.g. Free Hair Spa with any Hair Color',
                          prefixIcon: Icon(Icons.subtitles_rounded),
                        ),
                      ),
                      const SizedBox(height: AppConstants.spaceSm),
                      Text('Icon Identifier', style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      DropdownButtonFormField<String>(
                        initialValue: iconPresets.any((element) => element['name'] == selectedIcon) ? selectedIcon : 'local_offer',
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.category_rounded),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        items: iconPresets.map((preset) {
                          return DropdownMenuItem<String>(
                            value: preset['name'] as String,
                            child: Row(
                              children: [
                                Icon(preset['icon'] as IconData, size: 20, color: AppTheme.primary),
                                const SizedBox(width: 8),
                                Text(preset['name'] as String),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setDialogState(() => selectedIcon = val);
                        },
                      ),
                      const SizedBox(height: AppConstants.spaceSm),
                      TextField(
                        controller: imageUrlController,
                        decoration: const InputDecoration(
                          labelText: 'Image URL (Optional)',
                          hintText: 'https://example.com/banner.jpg',
                          prefixIcon: Icon(Icons.image_rounded),
                        ),
                      ),
                      const SizedBox(height: AppConstants.spaceSm),
                      TextField(
                        controller: sortOrderController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Display Sort Order',
                          hintText: '0, 1, 2...',
                          prefixIcon: Icon(Icons.format_list_numbered_rounded),
                        ),
                      ),
                      const SizedBox(height: AppConstants.spaceSm),
                      SwitchListTile(
                        title: const Text('Active Banner'),
                        subtitle: const Text('Show on consumer home screen'),
                        value: isActive,
                        activeThumbColor: AppTheme.primary,
                        onChanged: (val) => setDialogState(() => isActive = val),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSubmitting ? null : () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          final title = titleController.text.trim();
                          final subtitle = subtitleController.text.trim();
                          if (title.isEmpty || subtitle.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Please provide both Title and Subtitle.')),
                            );
                            return;
                          }

                          final scaffoldMessenger = ScaffoldMessenger.of(context);
                          final navigator = Navigator.of(dialogContext);

                          setDialogState(() => isSubmitting = true);

                          final sortOrder = int.tryParse(sortOrderController.text.trim()) ?? 0;
                          final imageUrl = imageUrlController.text.trim().isEmpty ? null : imageUrlController.text.trim();

                          final banner = PromoBannerModel(
                            id: existingBanner?.id ?? '',
                            title: title,
                            subtitle: subtitle,
                            iconName: selectedIcon,
                            imageUrl: imageUrl,
                            targetCategoryId: existingBanner?.targetCategoryId,
                            isActive: isActive,
                            sortOrder: sortOrder,
                          );

                          final provider = context.read<AdminPortalProvider>();
                          final success = existingBanner == null
                              ? await provider.createBanner(banner)
                              : await provider.updateBanner(banner);

                          navigator.pop();
                          scaffoldMessenger.showSnackBar(
                            SnackBar(
                              content: Text(success
                                  ? (existingBanner == null ? 'Promo banner created successfully!' : 'Promo banner updated successfully!')
                                  : 'Failed to save promo banner.'),
                            ),
                          );
                        },
                  child: isSubmitting
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : Text(existingBanner == null ? 'Create Banner' : 'Save Changes'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showDeleteDialog(PromoBannerModel banner) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Promo Banner'),
        content: Text('Are you sure you want to delete "${banner.title}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
            onPressed: () async {
              Navigator.pop(ctx);
              final provider = context.read<AdminPortalProvider>();
              final success = await provider.deleteBanner(banner.id);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success ? 'Promo banner deleted.' : 'Failed to delete banner.'),
                  ),
                );
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName.toLowerCase()) {
      case 'spa':
        return Icons.spa;
      case 'cleaning':
        return Icons.cleaning_services;
      case 'content_cut':
        return Icons.content_cut;
      case 'brush':
        return Icons.brush;
      case 'home_repair_service':
        return Icons.home_repair_service;
      case 'medical_services':
        return Icons.medical_services;
      case 'star':
        return Icons.star_rounded;
      case 'local_offer':
      default:
        return Icons.local_offer_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final adminProvider = context.watch<AdminPortalProvider>();
    final banners = adminProvider.banners;

    final body = SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppConstants.spaceMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
            // Header Summary Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppConstants.spaceMd),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primary, AppTheme.accent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(AppConstants.radiusLg),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(40),
                      borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                    ),
                    child: const Icon(Icons.view_carousel_rounded, size: 28, color: Colors.white),
                  ),
                  const SizedBox(width: AppConstants.spaceMd),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Home Screen Promo Banners',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${banners.where((b) => b.isActive).length} Active · ${banners.length} Total Banners',
                          style: TextStyle(color: Colors.white.withAlpha(220), fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  // Add button — compact icon button, no text wrapping risk
                  GestureDetector(
                    onTap: () => _showBannerDialog(),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                      ),
                      child: const Icon(Icons.add_rounded, color: AppTheme.primary, size: 22),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppConstants.spaceLg),

              Text('All Banners (${banners.length})', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: AppConstants.spaceSm),

              if (adminProvider.isLoading && banners.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (banners.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppConstants.spaceXl),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(AppConstants.radiusLg),
                    border: Border.all(color: AppTheme.divider),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.view_carousel_outlined, size: 56, color: AppTheme.textSecondary.withAlpha(100)),
                      const SizedBox(height: AppConstants.spaceSm),
                      const Text(
                        'No promo banners available',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Click "+ Add Banner" to create a new banner offer.',
                        style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                      ),
                    ],
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: banners.length,
                  itemBuilder: (context, index) {
                    final banner = banners[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: AppConstants.spaceMd),
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
                        border: Border.all(color: AppTheme.divider),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(8),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Banner Gradient Visual Card Preview
                          Container(
                            padding: const EdgeInsets.all(AppConstants.spaceMd),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: banner.isActive
                                    ? [AppTheme.primary, AppTheme.accent]
                                    : [Colors.grey.shade600, Colors.grey.shade400],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(AppConstants.radiusLg),
                                topRight: Radius.circular(AppConstants.radiusLg),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withAlpha(40),
                                    borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                                  ),
                                  child: Icon(_getIconData(banner.iconName), size: 22, color: Colors.white),
                                ),
                                const SizedBox(width: AppConstants.spaceMd),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        banner.title,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        banner.subtitle,
                                        style: TextStyle(
                                          color: Colors.white.withAlpha(220),
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withAlpha(50),
                                    borderRadius: BorderRadius.circular(AppConstants.radiusSm),
                                  ),
                                  child: Text(
                                    'Order: ${banner.sortOrder}',
                                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Action Toolbar
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceMd, vertical: AppConstants.spaceSm),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: banner.isActive ? AppTheme.success.withAlpha(20) : Colors.grey.withAlpha(30),
                                    borderRadius: BorderRadius.circular(AppConstants.radiusSm),
                                  ),
                                  child: Text(
                                    banner.isActive ? 'ACTIVE' : 'INACTIVE',
                                    style: TextStyle(
                                      color: banner.isActive ? AppTheme.success : AppTheme.textSecondary,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                Switch(
                                  value: banner.isActive,
                                  activeThumbColor: AppTheme.primary,
                                  onChanged: (val) {
                                    final updated = banner.copyWith(isActive: val);
                                    adminProvider.updateBanner(updated);
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined, color: AppTheme.primary),
                                  onPressed: () => _showBannerDialog(existingBanner: banner),
                                  tooltip: 'Edit Banner',
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline_rounded, color: AppTheme.error),
                                  onPressed: () => _showDeleteDialog(banner),
                                  tooltip: 'Delete Banner',
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
            ],
          ),
        );

    if (widget.isEmbedded) {
      return body;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Promo Banners Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => adminProvider.fetchBanners(),
            tooltip: 'Refresh Banners',
          ),
        ],
      ),
      body: body,
    );
  }
}
