import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_header.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();

  final _nameFocus = FocusNode();
  final _phoneFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmFocus = FocusNode();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    _nameFocus.dispose();
    _phoneFocus.dispose();
    _passwordFocus.dispose();
    _confirmFocus.dispose();
    super.dispose();
  }

  String _selectedRole = 'customer';

  Future<void> _onRegister() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    await auth.register(
      name: _nameCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      password: _passwordCtrl.text,
      role: _selectedRole,
    );
    if (!mounted) return;
    if (auth.isAuthenticated) {
      if (_selectedRole == 'provider') {
        context.go('/provider-onboarding');
      } else {
        context.go('/home');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spaceLg,
            vertical: AppConstants.spaceSm,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header (no logo on sub-screens)
                const AuthHeader(
                  title: 'Create account',
                  subtitle: 'Join BookLocal and find services near you',
                  showLogo: false,
                ),
                const SizedBox(height: AppConstants.spaceXl),

                // Error banner
                Consumer<AuthProvider>(
                  builder: (context, auth, w) {
                    if (auth.error == null) return const SizedBox.shrink();
                    return Container(
                      margin: const EdgeInsets.only(bottom: AppConstants.spaceMd),
                      padding: const EdgeInsets.all(AppConstants.spaceMd),
                      decoration: BoxDecoration(
                        color: AppTheme.error.withAlpha(20),
                        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                        border: Border.all(color: AppTheme.error.withAlpha(80)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: AppTheme.error, size: 18),
                          const SizedBox(width: AppConstants.spaceSm),
                          Expanded(
                            child: Text(
                              auth.error!,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppTheme.error,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),

                // Full name
                AppTextField(
                  controller: _nameCtrl,
                  focusNode: _nameFocus,
                  label: 'Full Name',
                  hint: 'Your full name',
                  prefixIcon: Icons.person_outline_rounded,
                  keyboardType: TextInputType.name,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.name],
                  onFieldSubmitted: (_) =>
                      FocusScope.of(context).requestFocus(_phoneFocus),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Full name is required';
                    if (v.trim().length < 2) return 'Name must be at least 2 characters';
                    return null;
                  },
                ),
                const SizedBox(height: AppConstants.spaceMd),

                // Phone
                AppTextField(
                  controller: _phoneCtrl,
                  focusNode: _phoneFocus,
                  label: 'Phone Number',
                  hint: 'e.g. 09123456789',
                  prefixIcon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.telephoneNumber],
                  onFieldSubmitted: (_) =>
                      FocusScope.of(context).requestFocus(_passwordFocus),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Phone number is required';
                    if (v.trim().length < 9) return 'Enter a valid phone number';
                    return null;
                  },
                ),
                const SizedBox(height: AppConstants.spaceMd),

                // Password
                AppTextField(
                  controller: _passwordCtrl,
                  focusNode: _passwordFocus,
                  label: 'Password',
                  hint: 'At least 6 characters',
                  prefixIcon: Icons.lock_outline_rounded,
                  obscureText: true,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.newPassword],
                  onFieldSubmitted: (_) =>
                      FocusScope.of(context).requestFocus(_confirmFocus),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Password is required';
                    if (v.length < 6) return 'Password must be at least 6 characters';
                    return null;
                  },
                ),
                const SizedBox(height: AppConstants.spaceMd),

                // Confirm password
                AppTextField(
                  controller: _confirmPasswordCtrl,
                  focusNode: _confirmFocus,
                  label: 'Confirm Password',
                  hint: 'Re-enter your password',
                  prefixIcon: Icons.lock_outline_rounded,
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _onRegister(),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Please confirm your password';
                    if (v != _passwordCtrl.text) return 'Passwords do not match';
                    return null;
                  },
                ),
                const SizedBox(height: AppConstants.spaceSm),
                Text(
                  'Account Type',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: AppConstants.spaceSm),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(
                      value: 'customer',
                      label: Text('Customer'),
                      icon: Icon(Icons.person_outline),
                    ),
                    ButtonSegment(
                      value: 'provider',
                      label: Text('Service Provider'),
                      icon: Icon(Icons.storefront_outlined),
                    ),
                  ],
                  selected: {_selectedRole},
                  onSelectionChanged: (val) {
                    setState(() => _selectedRole = val.first);
                  },
                ),
                const SizedBox(height: AppConstants.spaceXl),

                // Register button
                Consumer<AuthProvider>(
                  builder: (context, auth, _) => AppButton(
                    label: 'Create Account',
                    isLoading: auth.isLoading,
                    onPressed: auth.isLoading ? null : _onRegister,
                  ),
                ),
                const SizedBox(height: AppConstants.spaceLg),

                // Login link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account? ',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    GestureDetector(
                      onTap: () {
                        context.read<AuthProvider>().clearError();
                        context.pop();
                      },
                      child: Text(
                        'Login',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
