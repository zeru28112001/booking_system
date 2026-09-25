import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/localization/app_language_provider.dart';
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
    final langProvider = context.watch<AppLanguageProvider>();

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text(langProvider.translate('provider_staff_title')),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_alt_outlined),
            tooltip: langProvider.translate('add_staff'),
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
              actionLabel: langProvider.translate('add_staff'),
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
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: member.isActive ? AppTheme.success.withAlpha(30) : Colors.orange.withAlpha(30),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: member.isActive ? AppTheme.success.withAlpha(80) : Colors.orange.withAlpha(80),
                                    width: 0.8,
                                  ),
                                ),
                                child: Text(
                                  member.isActive
                                      ? langProvider.translate('active_status')
                                      : langProvider.translate('day_off_break'),
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: member.isActive ? AppTheme.success : Colors.orange.shade800,
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
        label: Text(langProvider.translate('add_staff')),
      ),
    );
  }
}
