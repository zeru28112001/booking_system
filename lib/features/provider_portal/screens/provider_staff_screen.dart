import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_loading_indicator.dart';
import '../providers/provider_portal_provider.dart';
import '../widgets/staff_form_sheet.dart';
import '../../provider/widgets/gradient_avatar.dart';

class ProviderStaffScreen extends StatelessWidget {
  const ProviderStaffScreen({super.key});

  void _openSheet(BuildContext context, [dynamic staff]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => StaffFormSheet(staff: staff),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: const Text('Manage Staff'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_alt_outlined),
            tooltip: 'Add Staff',
            onPressed: () => _openSheet(context),
          ),
        ],
      ),
      body: Consumer<ProviderPortalProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.staff.isEmpty) {
            return const AppLoadingIndicator();
          }

          final staff = provider.staff;

          if (staff.isEmpty) {
            return AppEmptyState(
              icon: Icons.people_outline_rounded,
              title: 'No staff members added',
              subtitle: 'Add staff members to allow customers to choose specific specialists.',
              actionLabel: 'Add Staff Member',
              onAction: () => _openSheet(context),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(AppConstants.spaceMd),
            itemCount: staff.length,
            separatorBuilder: (ctx, i) => const SizedBox(height: AppConstants.spaceSm),
            itemBuilder: (context, index) {
              final member = staff[index];
              return Container(
                padding: const EdgeInsets.all(AppConstants.spaceMd),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                  border: Border.all(color: AppTheme.divider),
                ),
                child: Row(
                  children: [
                    GradientAvatar(name: member.name, size: 48, fontSize: 18),
                    const SizedBox(width: AppConstants.spaceMd),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                member.name,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: member.isActive ? AppTheme.success.withAlpha(30) : AppTheme.error.withAlpha(30),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  member.isActive ? 'Active' : 'Inactive',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: member.isActive ? AppTheme.success : AppTheme.error,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            member.phone,
                            style: theme.textTheme.bodySmall?.copyWith(color: AppTheme.textSecondary),
                          ),
                          if (member.specialties.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 4,
                              children: member.specialties
                                  .map(
                                    (tag) => Chip(
                                      label: Text(tag, style: const TextStyle(fontSize: 10)),
                                      padding: EdgeInsets.zero,
                                      visualDensity: VisualDensity.compact,
                                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    ),
                                  )
                                  .toList(),
                            ),
                          ],
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, color: AppTheme.primary),
                      onPressed: () => _openSheet(context, member),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, color: AppTheme.error),
                      onPressed: () {
                        provider.deleteStaff(member.id);
                      },
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
        onPressed: () => _openSheet(context),
        icon: const Icon(Icons.person_add_rounded),
        label: const Text('Add Staff'),
      ),
    );
  }
}
