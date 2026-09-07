import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../domain/entities/provider_profile.dart';
import '../providers/provider_portal_provider.dart';

class ProviderOnboardingScreen extends StatefulWidget {
  const ProviderOnboardingScreen({super.key});

  @override
  State<ProviderOnboardingScreen> createState() => _ProviderOnboardingScreenState();
}

class _ProviderOnboardingScreenState extends State<ProviderOnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _shopNameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  String _selectedCategory = 'Beauty & Salon';

  final _categories = [
    'Beauty & Salon',
    'Spa & Wellness',
    'House Cleaning',
    'Electrician',
    'Plumbing',
  ];

  @override
  void dispose() {
    _shopNameCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final provider = context.read<ProviderPortalProvider>();

    final newProfile = ProviderProfile(
      id: 'prov_${DateTime.now().millisecondsSinceEpoch}',
      shopName: _shopNameCtrl.text.trim(),
      categoryName: _selectedCategory,
      description: _descCtrl.text.trim(),
      address: _addressCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      isAvailable: true,
      verificationStatus: 'pending',
      rating: 5.0,
      reviewCount: 0,
      imageUrl: '',
    );

    final success = await provider.updateProfile(newProfile);
    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Provider onboarding complete! Account pending verification.')),
      );
      context.go('/provider-dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Provider Setup'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.spaceLg),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Register Your Business',
                style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                'Set up your shop details to list your services and accept customer bookings.',
                style: theme.textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary),
              ),
              const SizedBox(height: AppConstants.spaceLg),

              AppTextField(
                controller: _shopNameCtrl,
                label: 'Shop / Business Name',
                prefixIcon: Icons.storefront_rounded,
                validator: (v) => v == null || v.trim().isEmpty ? 'Shop name required' : null,
              ),
              const SizedBox(height: AppConstants.spaceMd),

              Text('Business Category', style: theme.textTheme.titleSmall),
              const SizedBox(height: AppConstants.spaceSm),
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                items: _categories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedCategory = val);
                },
              ),
              const SizedBox(height: AppConstants.spaceMd),

              AppTextField(
                controller: _phoneCtrl,
                label: 'Business Phone Number',
                prefixIcon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                validator: (v) => v == null || v.trim().isEmpty ? 'Phone number required' : null,
              ),
              const SizedBox(height: AppConstants.spaceMd),

              AppTextField(
                controller: _addressCtrl,
                label: 'Business / Service Address',
                prefixIcon: Icons.location_on_outlined,
                maxLines: 2,
                validator: (v) => v == null || v.trim().isEmpty ? 'Address required' : null,
              ),
              const SizedBox(height: AppConstants.spaceMd),

              AppTextField(
                controller: _descCtrl,
                label: 'Business Description',
                prefixIcon: Icons.description_outlined,
                maxLines: 3,
              ),
              const SizedBox(height: AppConstants.spaceXl),

              Consumer<ProviderPortalProvider>(
                builder: (context, provider, _) => AppButton(
                  label: 'Complete Setup',
                  icon: Icons.check_circle_outline_rounded,
                  isLoading: provider.isSaving,
                  onPressed: provider.isSaving ? null : _submit,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
