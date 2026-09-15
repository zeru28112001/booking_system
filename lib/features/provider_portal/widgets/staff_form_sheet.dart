import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../domain/entities/provider_staff.dart';
import '../providers/provider_portal_provider.dart';

class StaffFormSheet extends StatefulWidget {
  const StaffFormSheet({super.key, this.staff});

  final ProviderStaff? staff;

  @override
  State<StaffFormSheet> createState() => _StaffFormSheetState();
}

class _StaffFormSheetState extends State<StaffFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late Set<String> _selectedSpecialties;
  late bool _isActive;
  late Set<String> _offDays;
  TimeOfDay? _shiftStartTime;
  TimeOfDay? _shiftEndTime;
  late bool _useShopHours;

  TimeOfDay? _parseTime(String? timeStr) {
    if (timeStr == null || timeStr.isEmpty) return null;
    final parts = timeStr.split(':');
    if (parts.length != 2) return null;
    return TimeOfDay(hour: int.tryParse(parts[0]) ?? 0, minute: int.tryParse(parts[1]) ?? 0);
  }

  String? _formatTime(TimeOfDay? time) {
    if (time == null) return null;
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  @override
  void initState() {
    super.initState();
    final stf = widget.staff;
    _nameController = TextEditingController(text: stf?.name ?? '');
    _phoneController = TextEditingController(text: stf?.phone ?? '');
    _selectedSpecialties = stf?.specialties.toSet() ?? {};
    _isActive = stf?.isActive ?? true;
    _offDays = stf?.offDays.toSet() ?? {};
    _shiftStartTime = _parseTime(stf?.shiftStartTime);
    _shiftEndTime = _parseTime(stf?.shiftEndTime);
    _useShopHours = _shiftStartTime == null && _shiftEndTime == null;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final provider = context.read<ProviderPortalProvider>();
    final isNew = widget.staff == null;

    final staffMember = ProviderStaff(
      id: widget.staff?.id ?? '',
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      specialties: _selectedSpecialties.toList(),
      isActive: _isActive,
      avatarUrl: widget.staff?.avatarUrl ?? '',
      offDays: _offDays.toList(),
      shiftStartTime: _useShopHours ? null : _formatTime(_shiftStartTime),
      shiftEndTime: _useShopHours ? null : _formatTime(_shiftEndTime),
    );

    final success = await provider.saveStaff(staffMember);
    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isNew ? 'Staff member added successfully' : 'Staff member updated successfully'),
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEditing = widget.staff != null;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.spaceLg),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isEditing ? 'Edit Staff Member' : 'Add Staff Member',
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.spaceMd),
              AppTextField(
                controller: _nameController,
                label: 'Full Name',
                prefixIcon: Icons.person_outline_rounded,
                validator: (val) => val == null || val.trim().isEmpty ? 'Name required' : null,
              ),
              const SizedBox(height: AppConstants.spaceMd),
              AppTextField(
                controller: _phoneController,
                label: 'Phone Number',
                prefixIcon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                validator: (val) => val == null || val.trim().isEmpty ? 'Phone required' : null,
              ),
              const SizedBox(height: AppConstants.spaceLg),

              Text(
                'Assign Services & Specialties',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                'Select the services this staff member is qualified to perform:',
                style: theme.textTheme.bodySmall?.copyWith(color: AppTheme.textSecondary),
              ),
              const SizedBox(height: AppConstants.spaceSm),

              Consumer<ProviderPortalProvider>(
                builder: (context, provider, _) {
                  final services = provider.services;
                  if (services.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.all(AppConstants.spaceMd),
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                        border: Border.all(color: AppTheme.divider),
                      ),
                      child: const Text('No services added yet. You can add custom specialties below.'),
                    );
                  }

                  return Column(
                    children: services.map((s) {
                      final isChecked = _selectedSpecialties.contains(s.name);
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                          border: Border.all(
                            color: isChecked ? AppTheme.primary : AppTheme.divider,
                            width: isChecked ? 1.5 : 1.0,
                          ),
                        ),
                        child: Material(
                          color: isChecked ? AppTheme.primary.withAlpha(15) : AppTheme.surface,
                          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                          clipBehavior: Clip.antiAlias,
                          child: CheckboxListTile(
                            dense: true,
                            value: isChecked,
                            tileColor: Colors.transparent,
                            activeColor: AppTheme.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                            ),
                            title: Text(
                              s.name,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: isChecked ? FontWeight.bold : FontWeight.w500,
                              ),
                            ),
                            subtitle: Text(
                              '${s.group} · ${s.durationMinutes} mins',
                              style: theme.textTheme.bodySmall?.copyWith(color: AppTheme.textSecondary),
                            ),
                            onChanged: (val) {
                              setState(() {
                                if (val == true) {
                                  _selectedSpecialties.add(s.name);
                                } else {
                                  _selectedSpecialties.remove(s.name);
                                }
                              });
                            },
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),

              if (_selectedSpecialties.isNotEmpty) ...[
                const SizedBox(height: AppConstants.spaceSm),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: _selectedSpecialties.map((specialty) {
                    return Chip(
                      avatar: const Icon(Icons.check_circle, size: 16, color: AppTheme.primary),
                      label: Text(specialty, style: const TextStyle(fontSize: 12)),
                      deleteIcon: const Icon(Icons.close, size: 14),
                      onDeleted: () {
                        setState(() {
                          _selectedSpecialties.remove(specialty);
                        });
                      },
                    );
                  }).toList(),
                ),
              ],

              const SizedBox(height: AppConstants.spaceLg),
              Text(
                'Weekly Off Days',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                'Select days this staff member does not work:',
                style: theme.textTheme.bodySmall?.copyWith(color: AppTheme.textSecondary),
              ),
              const SizedBox(height: AppConstants.spaceSm),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'].map((day) {
                  final isOff = _offDays.contains(day);
                  return FilterChip(
                    label: Text(day, style: const TextStyle(fontSize: 12)),
                    selected: isOff,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _offDays.add(day);
                        } else {
                          _offDays.remove(day);
                        }
                      });
                    },
                    selectedColor: AppTheme.error.withAlpha(30),
                    checkmarkColor: AppTheme.error,
                  );
                }).toList(),
              ),

              const SizedBox(height: AppConstants.spaceLg),
              Text(
                'Daily Working Hours (Shift)',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                'Set specific working hours for this staff member.',
                style: theme.textTheme.bodySmall?.copyWith(color: AppTheme.textSecondary),
              ),
              const SizedBox(height: AppConstants.spaceSm),
              Material(
                color: AppTheme.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                  side: const BorderSide(color: AppTheme.divider),
                ),
                clipBehavior: Clip.antiAlias,
                child: Padding(
                padding: const EdgeInsets.all(AppConstants.spaceMd),
                child: Column(
                  children: [
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Inherit Shop Hours', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                      subtitle: const Text('Staff works exactly when the shop is open', style: TextStyle(fontSize: 12)),
                      value: _useShopHours,
                      activeColor: AppTheme.primary,
                      onChanged: (val) {
                        setState(() {
                          _useShopHours = val ?? true;
                          if (_useShopHours) {
                            _shiftStartTime = null;
                            _shiftEndTime = null;
                          } else {
                            _shiftStartTime = const TimeOfDay(hour: 9, minute: 0);
                            _shiftEndTime = const TimeOfDay(hour: 17, minute: 0);
                          }
                        });
                      },
                    ),
                    if (!_useShopHours) ...[
                      const Divider(),
                      const SizedBox(height: AppConstants.spaceSm),
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () async {
                                final time = await showTimePicker(
                                  context: context,
                                  initialTime: _shiftStartTime ?? const TimeOfDay(hour: 9, minute: 0),
                                );
                                if (time != null) setState(() => _shiftStartTime = time);
                              },
                              child: InputDecorator(
                                decoration: const InputDecoration(
                                  labelText: 'Start Time',
                                  prefixIcon: Icon(Icons.access_time),
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                ),
                                child: Text(_shiftStartTime?.format(context) ?? '--:--'),
                              ),
                            ),
                          ),
                          const SizedBox(width: AppConstants.spaceMd),
                          Expanded(
                            child: InkWell(
                              onTap: () async {
                                final time = await showTimePicker(
                                  context: context,
                                  initialTime: _shiftEndTime ?? const TimeOfDay(hour: 17, minute: 0),
                                );
                                if (time != null) setState(() => _shiftEndTime = time);
                              },
                              child: InputDecorator(
                                decoration: const InputDecoration(
                                  labelText: 'End Time',
                                  prefixIcon: Icon(Icons.access_time),
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                ),
                                child: Text(_shiftEndTime?.format(context) ?? '--:--'),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),

              const SizedBox(height: AppConstants.spaceLg),
              Container(
                padding: const EdgeInsets.all(AppConstants.spaceMd),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                  border: Border.all(color: AppTheme.divider),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                _isActive ? 'Active Status' : 'Day Off Status',
                                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: _isActive ? AppTheme.success.withAlpha(30) : Colors.orange.withAlpha(30),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  _isActive ? 'Active' : 'Day Off or Break',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: _isActive ? AppTheme.success : Colors.orange.shade800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _isActive ? 'Staff is available for appointments' : 'Staff is taking a day off (မအားပါ/ခွင့်ရက်)',
                            style: theme.textTheme.bodySmall?.copyWith(color: AppTheme.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: _isActive,
                      activeThumbColor: AppTheme.primary,
                      onChanged: (val) => setState(() => _isActive = val),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppConstants.spaceLg),
              Consumer<ProviderPortalProvider>(
                builder: (context, provider, _) {
                  return AppButton(
                    label: isEditing ? 'Save Staff' : 'Add Staff',
                    icon: Icons.check_rounded,
                    isLoading: provider.isSaving,
                    onPressed: provider.isSaving ? null : _submit,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
