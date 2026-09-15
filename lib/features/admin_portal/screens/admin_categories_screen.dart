import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../home/data/models/category_model.dart';
import '../providers/admin_portal_provider.dart';

class AdminCategoriesScreen extends StatefulWidget {
  const AdminCategoriesScreen({super.key});

  @override
  State<AdminCategoriesScreen> createState() => _AdminCategoriesScreenState();
}

class _AdminCategoriesScreenState extends State<AdminCategoriesScreen> {
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
      case 'brush':
        return Icons.brush_rounded;
      case 'medical_services':
        return Icons.medical_services_rounded;
      case 'home_repair_service':
        return Icons.home_repair_service_rounded;
      default:
        return Icons.category_rounded;
    }
  }

  // All available icon presets for category selection
  static const List<Map<String, dynamic>> _iconPresets = [
    {'key': 'content_cut', 'label': 'Hair / Beauty'},
    {'key': 'spa', 'label': 'Spa'},
    {'key': 'cleaning', 'label': 'Cleaning'},
    {'key': 'plumbing', 'label': 'Plumbing'},
    {'key': 'electrical', 'label': 'Electrical'},
    {'key': 'tutoring', 'label': 'Tutoring'},
    {'key': 'car', 'label': 'Automotive'},
    {'key': 'fitness', 'label': 'Fitness'},
    {'key': 'pest', 'label': 'Pest Control'},
    {'key': 'brush', 'label': 'Art / Design'},
    {'key': 'medical_services', 'label': 'Medical'},
    {'key': 'home_repair_service', 'label': 'Home Repair'},
  ];

  void _showCategoryDialog(BuildContext context, [CategoryModel? existing]) {
    final nameController = TextEditingController(text: existing?.name ?? '');
    String selectedIcon = existing?.iconName ?? 'content_cut';
    // Normalize existing icon to a valid preset key
    final validKeys = _iconPresets.map((e) => e['key'] as String).toSet();
    if (!validKeys.contains(selectedIcon)) selectedIcon = 'content_cut';
    String? nameError;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusLg),
            ),
            title: Row(
              children: [
                Icon(
                  existing == null
                      ? Icons.add_circle_rounded
                      : Icons.edit_rounded,
                  color: AppTheme.primary,
                ),
                const SizedBox(width: 8),
                Text(existing == null
                    ? 'Add Service Category'
                    : 'Edit Category'),
              ],
            ),
            content: SizedBox(
              width: 400,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Category Name *',
                      hintText: 'e.g. Hair & Beauty',
                      prefixIcon: const Icon(Icons.label_rounded),
                      errorText: nameError,
                    ),
                    onChanged: (val) {
                      if (nameError != null && val.trim().isNotEmpty) {
                        setDialogState(() => nameError = null);
                      }
                    },
                  ),
                  const SizedBox(height: AppConstants.spaceMd),
                  Text(
                    'Choose Icon',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: AppConstants.spaceSm),
                  GridView.count(
                    crossAxisCount: 4,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    children: _iconPresets.map((preset) {
                      final key = preset['key'] as String;
                      final label = preset['label'] as String;
                      final isSelected = selectedIcon == key;
                      return GestureDetector(
                        onTap: () => setDialogState(() => selectedIcon = key),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          curve: Curves.easeInOut,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppTheme.primary
                                : AppTheme.primary.withAlpha(12),
                            borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                            border: Border.all(
                              color: isSelected
                                  ? AppTheme.primary
                                  : AppTheme.divider,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _getCategoryIcon(key),
                                size: 26,
                                color: isSelected
                                    ? Colors.white
                                    : AppTheme.primary,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                label,
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: isSelected
                                      ? Colors.white
                                      : AppTheme.textSecondary,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final name = nameController.text.trim();
                  if (name.isEmpty) {
                    setDialogState(
                        () => nameError = 'Category name is required');
                    return;
                  }

                  final admin = context.read<AdminPortalProvider>();
                  bool ok;
                  if (existing == null) {
                    ok = await admin.createCategory(
                        name: name, iconName: selectedIcon);
                  } else {
                    ok = await admin.updateCategory(existing.id,
                        name: name, iconName: selectedIcon);
                  }

                  if (ctx.mounted) {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(ok
                            ? 'Category saved successfully'
                            : 'Failed to save category'),
                        backgroundColor:
                            ok ? AppTheme.success : AppTheme.error,
                      ),
                    );
                  }
                },
                child: Text(
                    existing == null ? 'Create Category' : 'Save Changes'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _confirmDeleteCategory(
      BuildContext context, CategoryModel category) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete ${category.name}?'),
        content: const Text(
            'Are you sure you want to remove this service category?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Keep it'),
          ),
          ElevatedButton(
            style:
                ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
            onPressed: () async {
              final admin = context.read<AdminPortalProvider>();
              final ok = await admin.deleteCategory(category.id);
              if (ctx.mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(ok
                        ? 'Category deleted'
                        : 'Could not delete category'),
                    backgroundColor:
                        ok ? AppTheme.error : null,
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Service Categories'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh',
            onPressed: () =>
                context.read<AdminPortalProvider>().fetchCategories(),
          ),
        ],
      ),
      body: Consumer<AdminPortalProvider>(
        builder: (context, admin, _) {
          final categories = admin.categories;

          if (admin.isLoading && categories.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              // Header Summary
              Container(
                width: double.infinity,
                margin: const EdgeInsets.all(AppConstants.spaceMd),
                padding: const EdgeInsets.all(AppConstants.spaceMd),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.primary, AppTheme.accent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius:
                      BorderRadius.circular(AppConstants.radiusLg),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(40),
                        borderRadius:
                            BorderRadius.circular(AppConstants.radiusMd),
                      ),
                      child: const Icon(Icons.category_rounded,
                          size: 28, color: Colors.white),
                    ),
                    const SizedBox(width: AppConstants.spaceMd),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Service Categories',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${categories.length} Total Categories',
                            style: TextStyle(
                                color: Colors.white.withAlpha(220),
                                fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _showCategoryDialog(context),
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

              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.spaceMd),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'All Categories (${categories.length})',
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppConstants.spaceSm),

              Expanded(
                child: categories.isEmpty
                    ? const SingleChildScrollView(
                        physics: AlwaysScrollableScrollPhysics(),
                        child: SizedBox(
                          height: 350,
                          child: AppEmptyState(
                            icon: Icons.category_outlined,
                            title: 'No Categories Found',
                            subtitle:
                                'Add categories for providers to list their services.',
                          ),
                        ),
                      )
                    : ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppConstants.spaceMd),
                        itemCount: categories.length,
                        separatorBuilder: (ctx, i) =>
                            const SizedBox(height: AppConstants.spaceSm),
                        itemBuilder: (context, index) {
                          final c = categories[index];
                          return Container(
                            padding:
                                const EdgeInsets.all(AppConstants.spaceMd),
                            decoration: BoxDecoration(
                              color: AppTheme.surface,
                              borderRadius: BorderRadius.circular(
                                  AppConstants.radiusMd),
                              border: Border.all(color: AppTheme.divider),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withAlpha(6),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color:
                                        AppTheme.primary.withAlpha(20),
                                    borderRadius: BorderRadius.circular(
                                        AppConstants.radiusSm),
                                  ),
                                  child: Icon(
                                      _getCategoryIcon(c.iconName),
                                      color: AppTheme.primary),
                                ),
                                const SizedBox(
                                    width: AppConstants.spaceMd),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(c.name,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16)),
                                      Text(
                                          'Icon: ${c.iconName}',
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                                  color: AppTheme
                                                      .textSecondary)),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.edit_rounded,
                                      color: AppTheme.primary, size: 20),
                                  tooltip: 'Edit Category',
                                  onPressed: () =>
                                      _showCategoryDialog(context, c),
                                ),
                                IconButton(
                                  icon: const Icon(
                                      Icons.delete_outline_rounded,
                                      color: AppTheme.error,
                                      size: 20),
                                  tooltip: 'Delete Category',
                                  onPressed: () =>
                                      _confirmDeleteCategory(context, c),
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
      ),
    );
  }
}
