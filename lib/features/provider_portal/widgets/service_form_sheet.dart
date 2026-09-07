import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:booking_system/features/provider/domain/entities/service.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../providers/provider_portal_provider.dart';

class ServiceFormSheet extends StatefulWidget {
  const ServiceFormSheet({super.key, this.service});

  final Service? service;

  @override
  State<ServiceFormSheet> createState() => _ServiceFormSheetState();
}

class _ServiceFormSheetState extends State<ServiceFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _durationController;
  late TextEditingController _groupController;

  @override
  void initState() {
    super.initState();
    final s = widget.service;
    _nameController = TextEditingController(text: s?.name ?? '');
    _priceController = TextEditingController(text: s != null ? s.price.toString() : '');
    _durationController = TextEditingController(text: s != null ? s.durationMinutes.toString() : '45');
    _groupController = TextEditingController(text: s?.group ?? 'General');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _durationController.dispose();
    _groupController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final provider = context.read<ProviderPortalProvider>();
    final isNew = widget.service == null;

    final service = Service(
      id: widget.service?.id ?? '',
      name: _nameController.text.trim(),
      group: _groupController.text.trim(),
      price: int.parse(_priceController.text.trim()),
      durationMinutes: int.parse(_durationController.text.trim()),
    );

    final success = await provider.saveService(service);
    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isNew ? 'Service added successfully' : 'Service updated successfully'),
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEditing = widget.service != null;

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
                    isEditing ? 'Edit Service' : 'Add New Service',
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
                label: 'Service Title (e.g. Haircut & Styling)',
                prefixIcon: Icons.content_cut_rounded,
                validator: (val) => val == null || val.trim().isEmpty ? 'Service title is required' : null,
              ),
              const SizedBox(height: AppConstants.spaceMd),
              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      controller: _priceController,
                      label: 'Price (MMK)',
                      prefixIcon: Icons.payments_outlined,
                      keyboardType: TextInputType.number,
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) return 'Required';
                        if (int.tryParse(val.trim()) == null) return 'Invalid price';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: AppConstants.spaceMd),
                  Expanded(
                    child: AppTextField(
                      controller: _durationController,
                      label: 'Duration (Mins)',
                      prefixIcon: Icons.timer_outlined,
                      keyboardType: TextInputType.number,
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) return 'Required';
                        if (int.tryParse(val.trim()) == null) return 'Invalid min';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.spaceMd),
              AppTextField(
                controller: _groupController,
                label: 'Service Group (e.g. Hair, Nails, Spa)',
                prefixIcon: Icons.category_outlined,
                validator: (val) => val == null || val.trim().isEmpty ? 'Group required' : null,
              ),
              const SizedBox(height: AppConstants.spaceLg),
              Consumer<ProviderPortalProvider>(
                builder: (context, provider, _) {
                  return AppButton(
                    label: isEditing ? 'Save Changes' : 'Add Service',
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
