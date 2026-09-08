import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_header.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _phoneFocus = FocusNode();
  final _passwordFocus = FocusNode();

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    _phoneFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  Future<void> _onLogin() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    await auth.login(
      phone: _phoneCtrl.text.trim(),
      password: _passwordCtrl.text,
    );
    if (!mounted) return;
    if (auth.isAuthenticated) {
      final role = auth.currentUser?.role ?? 'customer';
      if (role == 'admin') {
        context.go('/admin-dashboard');
      } else if (role == 'provider') {
        context.go('/provider-dashboard');
      } else {
        context.go('/home');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.spaceLg,
                vertical: AppConstants.spaceMd,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - (AppConstants.spaceMd * 2),
                ),
                child: IntrinsicHeight(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Header
                        const AuthHeader(
                          title: 'Welcome back!',
                          subtitle: 'Sign in to book local services',
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

                        // Phone field
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

                        // Password field
                        AppTextField(
                          controller: _passwordCtrl,
                          focusNode: _passwordFocus,
                          label: 'Password',
                          hint: 'Enter your password',
                          prefixIcon: Icons.lock_outline_rounded,
                          obscureText: true,
                          textInputAction: TextInputAction.done,
                          autofillHints: const [AutofillHints.password],
                          onFieldSubmitted: (_) => _onLogin(),
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Password is required';
                            if (v.length < 6) return 'Password must be at least 6 characters';
                            return null;
                          },
                        ),
                        const SizedBox(height: AppConstants.spaceXl),

                        // Login button
                        Consumer<AuthProvider>(
                          builder: (context, auth, _) => AppButton(
                            label: 'Login',
                            isLoading: auth.isLoading,
                            onPressed: auth.isLoading ? null : _onLogin,
                          ),
                        ),
                        const SizedBox(height: AppConstants.spaceLg),

                        // Register link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Don't have an account? ",
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            GestureDetector(
                              onTap: () {
                                context.read<AuthProvider>().clearError();
                                context.push('/register');
                              },
                              child: Text(
                                'Register',
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
          },
        ),
      ),
    );
  }
}
