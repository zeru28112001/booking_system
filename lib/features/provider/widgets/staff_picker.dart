import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../domain/entities/staff.dart';
import 'gradient_avatar.dart';

/// Horizontal staff selection widget for shop-model providers.
/// Displays staff avatars, roles, ratings, and a prominent "Available Today" badge.
class StaffPicker extends StatelessWidget {
  const StaffPicker({
    super.key,
    required this.staffList,
    required this.selectedStaffId,
    required this.onStaffSelected,
  });

  final List<Staff> staffList;

  /// Null means "Any Available Staff".
  final String? selectedStaffId;
  final ValueChanged<Staff?> onStaffSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Select Staff / Pro', style: theme.textTheme.titleLarge),
            Text(
              '${staffList.where((s) => s.isAvailableToday).length} Available Today',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppTheme.secondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppConstants.spaceSm),
        SizedBox(
          height: 124,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: staffList.length + 1, // +1 for "Any Staff"
            separatorBuilder: (_, _) => const SizedBox(width: AppConstants.spaceSm),
            itemBuilder: (context, index) {
              if (index == 0) {
                final isSelected = selectedStaffId == null;
                return _AnyStaffCard(
                  isSelected: isSelected,
                  onTap: () => onStaffSelected(null),
                );
              }

              final staff = staffList[index - 1];
              final isSelected = selectedStaffId == staff.id;

              return _StaffCard(
                staff: staff,
                isSelected: isSelected,
                onTap: () => onStaffSelected(staff),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _AnyStaffCard extends StatelessWidget {
  const _AnyStaffCard({required this.isSelected, required this.onTap});

  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppConstants.radiusMd),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 100,
        padding: const EdgeInsets.all(AppConstants.spaceSm),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primary.withAlpha(20)
              : AppTheme.surface,
          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
          border: Border.all(
            color: isSelected ? AppTheme.primary : AppTheme.divider,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: isSelected
                  ? AppTheme.primary
                  : AppTheme.surfaceVariant,
              child: Icon(
                Icons.people_outline_rounded,
                color: isSelected ? AppTheme.onPrimary : AppTheme.onSurface,
                size: 24,
              ),
            ),
            const SizedBox(height: AppConstants.spaceXs),
            Text(
              'Any Staff',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? AppTheme.primary : AppTheme.onSurface,
                  ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              'Fastest slot',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: 10,
                    color: AppTheme.textSecondary,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StaffCard extends StatelessWidget {
  const _StaffCard({
    required this.staff,
    required this.isSelected,
    required this.onTap,
  });

  final Staff staff;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isAvailable = staff.isAvailableToday;

    return InkWell(
      onTap: isAvailable ? onTap : null,
      borderRadius: BorderRadius.circular(AppConstants.radiusMd),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: isAvailable ? 1.0 : 0.5,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 110,
          padding: const EdgeInsets.all(AppConstants.spaceSm),
          decoration: BoxDecoration(
            color: isSelected
                ? AppTheme.primary.withAlpha(20)
                : AppTheme.surface,
            borderRadius: BorderRadius.circular(AppConstants.radiusMd),
            border: Border.all(
              color: isSelected ? AppTheme.primary : AppTheme.divider,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                children: [
                  GradientAvatar(name: staff.name, size: 44, fontSize: 16),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: isAvailable
                            ? AppTheme.secondary
                            : AppTheme.textSecondary,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.spaceXs),
              Text(
                staff.name,
                style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w600,
                      color: isSelected ? AppTheme.primary : AppTheme.onSurface,
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                isAvailable ? staff.role : 'Off today',
                style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 10,
                      color: isAvailable
                          ? AppTheme.textSecondary
                          : AppTheme.error,
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
