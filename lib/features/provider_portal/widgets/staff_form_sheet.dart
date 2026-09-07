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
  late TextEditingController _specialtiesController;
  late bool _isActive;

  @override
  void initState() {
    super.initState();
    final stf = widget.staff;
    _nameController = TextEditingController(text: stf?.name ?? '');
    _phoneController = TextEditingController(text: stf?.phone ?? '');
    _specialtiesController = TextEditingController(
      text: stf != null ? stf.specialties.join(', ') : '',
    );
    _isActive = stf?.isActive ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _specialtiesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final provider = context.read<ProviderPortalProvider>();
    final isNew = widget.staff == null;

    final specialties = _specialtiesController.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    final staffMember = ProviderStaff(
      id: widget.staff?.id ?? '',
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      specialties: specialties,
      isActive: _isActive,
      avatarUrl: widget.staff?.avatarUrl ?? '',
    );

    final success = await provider.saveStaff(staffMember);
    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isNew ? 'Staff member added' : 'Staff member updated'),
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
              const SizedBox(height: AppConstants.spaceMd),
              AppTextField(
                controller: _specialtiesController,
                label: 'Specialties (comma separated, e.g. Haircut, Color)',
                prefixIcon: Icons.workspace_premium_outlined,
              ),
              const SizedBox(height: AppConstants.spaceMd),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Active Status', style: TextStyle(fontWeight: FontWeight.w600)),
                  Switch(
                    value: _isActive,
                    activeThumbColor: AppTheme.primary,
                    onChanged: (val) => setState(() => _isActive = val),
                  ),
                ],
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
