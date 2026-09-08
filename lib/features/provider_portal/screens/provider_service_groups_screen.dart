import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_loading_indicator.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../domain/entities/service_group.dart';
import '../providers/provider_portal_provider.dart';

class ProviderServiceGroupsScreen extends StatefulWidget {
  const ProviderServiceGroupsScreen({super.key});

  @override
  State<ProviderServiceGroupsScreen> createState() => _ProviderServiceGroupsScreenState();
}

class _ProviderServiceGroupsScreenState extends State<ProviderServiceGroupsScreen> {
  final Map<String, IconData> _availableIcons = const {
    'spa': Icons.spa_rounded,
    'content_cut': Icons.content_cut_rounded,
    'brush': Icons.brush_rounded,
    'face': Icons.face_rounded,
    'cleaning_services': Icons.cleaning_services_rounded,
    'sanitizer': Icons.sanitizer_rounded,
    'eco': Icons.eco_rounded,
    'star': Icons.star_rounded,
    'category': Icons.category_rounded,
  };

  IconData _getIconData(String name) {
    return _availableIcons[name] ?? Icons.category_rounded;
  }

  void _openGroupDialog([ServiceGroup? group]) {
    final nameController = TextEditingController(text: group?.name ?? '');
    final descController = TextEditingController(text: group?.description ?? '');
    String selectedIcon = group?.iconName ?? 'spa';
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final isEditing = group != null;
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusLg),
              ),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withAlpha(20),
                      borderRadius: BorderRadius.circular(AppConstants.radiusSm),
                    ),
                    child: Icon(_getIconData(selectedIcon), color: AppTheme.primary),
                  ),
                  const SizedBox(width: AppConstants.spaceSm),
                  Text(isEditing ? 'Edit Service Group' : 'Add Service Group'),
                ],
              ),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppTextField(
                        controller: nameController,
                        label: 'Group Name (e.g. Spa, Hair, Nails)',
                        prefixIcon: Icons.label_outlined,
                        validator: (val) => val == null || val.trim().isEmpty ? 'Group name required' : null,
                      ),
                      const SizedBox(height: AppConstants.spaceMd),
                      AppTextField(
                        controller: descController,
                        label: 'Description (Optional)',
                        prefixIcon: Icons.description_outlined,
                      ),
                      const SizedBox(height: AppConstants.spaceMd),
                      Text(
                        'Select Category Icon',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _availableIcons.entries.map((entry) {
                          final isSelected = selectedIcon == entry.key;
                          return ChoiceChip(
                            avatar: Icon(
                              entry.value,
                              size: 18,
                              color: isSelected ? Colors.white : AppTheme.primary,
                            ),
                            label: Text(entry.key),
                            selected: isSelected,
                            selectedColor: AppTheme.primary,
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : AppTheme.onSurface,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                            onSelected: (val) {
                              if (val) {
                                setDialogState(() {
                                  selectedIcon = entry.key;
                                });
                              }
                            },
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogCtx),
                  child: const Text('Cancel'),
                ),
                Consumer<ProviderPortalProvider>(
                  builder: (context, provider, _) {
                    return AppButton(
                      label: isEditing ? 'Update' : 'Create',
                      isLoading: provider.isSaving,
                      onPressed: provider.isSaving
                          ? null
                          : () async {
                              if (!(formKey.currentState?.validate() ?? false)) return;
                              final newGroup = ServiceGroup(
                                id: group?.id ?? '',
                                providerId: group?.providerId ?? '',
                                name: nameController.text.trim(),
                                description: descController.text.trim(),
                                iconName: selectedIcon,
                              );
                              final messenger = ScaffoldMessenger.of(context);
                              final nav = Navigator.of(dialogCtx);
                              final success = await provider.saveServiceGroup(newGroup);
                              if (success) {
                                nav.pop();
                                messenger.showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      isEditing ? 'Group updated successfully' : 'Group created successfully',
                                    ),
                                  ),
                                );
                              }
                            },
                    );
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, ServiceGroup group) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Service Group?'),
        content: Text('Are you sure you want to delete "${group.name}"? Services assigned to this group will remain intact.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
            onPressed: () async {
              Navigator.pop(ctx);
              final provider = context.read<ProviderPortalProvider>();
              await provider.deleteServiceGroup(group.id);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
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
        title: const Text('Manage Service Groups'),
      ),
      body: Consumer<ProviderPortalProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.serviceGroups.isEmpty) {
            return const AppLoadingIndicator();
          }

          final groups = provider.serviceGroups;

          if (groups.isEmpty) {
            return AppEmptyState(
              icon: Icons.category_outlined,
              title: 'No Service Groups Yet',
              subtitle: 'Organize your shop services into categories like Spa, Hair, Nails, or Massages.',
              actionLabel: 'Add First Group',
              onAction: () => _openGroupDialog(),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(AppConstants.spaceMd),
            itemCount: groups.length,
            separatorBuilder: (ctx, i) => const SizedBox(height: AppConstants.spaceSm),
            itemBuilder: (context, index) {
              final g = groups[index];
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
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withAlpha(20),
                        borderRadius: BorderRadius.circular(AppConstants.radiusSm),
                      ),
                      child: Icon(_getIconData(g.iconName), color: AppTheme.primary, size: 24),
                    ),
                    const SizedBox(width: AppConstants.spaceMd),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            g.name,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (g.description.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              g.description,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, color: AppTheme.primary),
                      onPressed: () => _openGroupDialog(g),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, color: AppTheme.error),
                      onPressed: () => _confirmDelete(context, g),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: null,
        onPressed: () => _openGroupDialog(),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Service Group'),
      ),
    );
  }
}
