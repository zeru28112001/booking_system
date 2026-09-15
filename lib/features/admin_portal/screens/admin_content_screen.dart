import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../home/data/models/category_model.dart';
import '../providers/admin_portal_provider.dart';
import 'admin_banners_screen.dart';

class AdminContentScreen extends StatefulWidget {
  const AdminContentScreen({super.key});

  @override
  State<AdminContentScreen> createState() => _AdminContentScreenState();
}

class _AdminContentScreenState extends State<AdminContentScreen> {
  int _selectedSegment = 0; // 0: Categories, 1: Promo Banners

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Content & Marketing'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: SegmentedButton<int>(
              segments: const [
                ButtonSegment<int>(
                  value: 0,
                  label: Text('Categories'),
                  icon: Icon(Icons.category_rounded, size: 18),
                ),
                ButtonSegment<int>(
                  value: 1,
                  label: Text('Promo Banners'),
                  icon: Icon(Icons.view_carousel_rounded, size: 18),
                ),
              ],
              selected: {_selectedSegment},
              onSelectionChanged: (newSelection) {
                setState(() {
                  _selectedSegment = newSelection.first;
                });
              },
            ),
          ),
        ),
      ),
      body: _selectedSegment == 0
          ? const AdminCategoriesView()
          : const AdminBannersScreen(isEmbedded: true),
    );
  }
}

class AdminCategoriesView extends StatefulWidget {
  const AdminCategoriesView({super.key});

  @override
  State<AdminCategoriesView> createState() => _AdminCategoriesViewState();
}

class _AdminCategoriesViewState extends State<AdminCategoriesView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<AdminPortalProvider>().fetchCategories();
    });
  }

  IconData _getCategoryIcon(String iconName) {
    switch (iconName.toLowerCase()) {
      case 'content_cut':
      case 'cut':
      case 'hair':
      case 'barber':
      case 'beauty':
        return Icons.content_cut_rounded;
      case 'spa':
        return Icons.spa_rounded;
      case 'cleaning':
      case 'cleaning_services':
        return Icons.cleaning_services_rounded;
      case 'plumbing':
        return Icons.plumbing_rounded;
      case 'electrical':
      case 'electrical_services':
        return Icons.electrical_services_rounded;
      case 'tutoring':
      case 'school':
      case 'education':
        return Icons.school_rounded;
      case 'car':
      case 'automotive':
        return Icons.directions_car_rounded;
      case 'fitness':
      case 'gym':
        return Icons.fitness_center_rounded;
      case 'pest':
      case 'pest_control':
        return Icons.bug_report_rounded;
      default:
        return Icons.category_rounded;
    }
  }

  void _showCategoryDialog(BuildContext context, [CategoryModel? existing]) {
    final nameController = TextEditingController(text: existing?.name ?? '');
    final iconController = TextEditingController(text: existing?.iconName ?? 'content_cut');
    String? nameError;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Text(existing == null ? 'Add Service Category' : 'Edit Category'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Category Name',
                    hintText: 'e.g. Hair & Beauty',
                    errorText: nameError,
                  ),
                  onChanged: (val) {
                    if (nameError != null && val.trim().isNotEmpty) {
                      setDialogState(() => nameError = null);
                    }
                  },
                ),
                const SizedBox(height: AppConstants.spaceMd),
                TextField(
                  controller: iconController,
                  decoration: InputDecoration(
                    labelText: 'Icon Name / Key',
                    hintText: 'e.g. content_cut, spa, cleaning',
                    suffixIcon: Icon(_getCategoryIcon(iconController.text.trim())),
                  ),
                  onChanged: (_) => setDialogState(() {}),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final name = nameController.text.trim();
                  final icon = iconController.text.trim().isEmpty ? 'category' : iconController.text.trim();
                  if (name.isEmpty) {
                    setDialogState(() => nameError = 'Category name is required');
                    return;
                  }

                  final admin = context.read<AdminPortalProvider>();
                  bool ok;
                  if (existing == null) {
                    ok = await admin.createCategory(name: name, iconName: icon);
                  } else {
                    ok = await admin.updateCategory(existing.id, name: name, iconName: icon);
                  }

                  if (ctx.mounted) {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(ok ? 'Category saved successfully' : 'Failed to save category'),
                        backgroundColor: ok ? AppTheme.success : AppTheme.error,
                      ),
                    );
                  }
                },
                child: Text(existing == null ? 'Create Category' : 'Save Changes'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _confirmDeleteCategory(BuildContext context, CategoryModel category) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete ${category.name}?'),
        content: const Text('Are you sure you want to remove this service category?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Keep it'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
            onPressed: () async {
              final admin = context.read<AdminPortalProvider>();
              final ok = await admin.deleteCategory(category.id);
              if (ctx.mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(ok ? 'Category deleted' : 'Could not delete category'),
                    backgroundColor: ok ? AppTheme.error : null,
                  ),
                );
              }
            },
            child: const Text('Delete Category'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer<AdminPortalProvider>(
      builder: (context, admin, _) {
        final categories = admin.categories;

        if (admin.isLoading && categories.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppConstants.spaceMd),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Active Categories (${categories.length})',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: const Text('Add Category'),
                    onPressed: () => _showCategoryDialog(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: categories.isEmpty
                  ? const SingleChildScrollView(
                      physics: AlwaysScrollableScrollPhysics(),
                      child: SizedBox(
                        height: 350,
                        child: AppEmptyState(
                          icon: Icons.category_outlined,
                          title: 'No Categories Found',
                          subtitle: 'Add categories for providers to list their services.',
                        ),
                      ),
                    )
                  : ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceMd),
                      itemCount: categories.length,
                      separatorBuilder: (ctx, i) => const SizedBox(height: AppConstants.spaceSm),
                      itemBuilder: (context, index) {
                        final c = categories[index];
                        return Container(
                          padding: const EdgeInsets.all(AppConstants.spaceMd),
                          decoration: BoxDecoration(
                            color: AppTheme.surface,
                            borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                            border: Border.all(color: AppTheme.divider),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppTheme.primary.withAlpha(20),
                                  borderRadius: BorderRadius.circular(AppConstants.radiusSm),
                                ),
                                child: Icon(_getCategoryIcon(c.iconName), color: AppTheme.primary),
                              ),
                              const SizedBox(width: AppConstants.spaceMd),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(c.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                    Text('Key: ${c.iconName}', style: theme.textTheme.bodySmall?.copyWith(color: AppTheme.textSecondary)),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit_rounded, color: AppTheme.primary, size: 20),
                                tooltip: 'Edit Category',
                                onPressed: () => _showCategoryDialog(context, c),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline_rounded, color: AppTheme.error, size: 20),
                                tooltip: 'Delete Category',
                                onPressed: () => _confirmDeleteCategory(context, c),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}
