import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class PhoneAuthScreen extends StatefulWidget {
  const PhoneAuthScreen({super.key, this.role = 'customer'});

  final String role;

  @override
  State<PhoneAuthScreen> createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends State<PhoneAuthScreen> {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isOtpSent = false;
  bool _isLoading = false;
  String? _verificationId;
  int? _resendToken;
  int _timerSeconds = 60;
  Timer? _timer;

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timerSeconds = 60;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timerSeconds > 0) {
        setState(() {
          _timerSeconds--;
        });
      } else {
        _timer?.cancel();
      }
    });
  }

  String _formatPhoneNumber(String phone) {
    String trimmed = phone.trim().replaceAll(' ', '').replaceAll('-', '');
    if (trimmed.startsWith('09')) {
      return '+959${trimmed.substring(2)}';
    } else if (trimmed.startsWith('9') && trimmed.length >= 9) {
      return '+95$trimmed';
    } else if (!trimmed.startsWith('+')) {
      return '+95$trimmed';
    }
    return trimmed;
  }

  Future<void> _sendOtp() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final rawPhone = _phoneController.text.trim();
    final formattedPhone = _formatPhoneNumber(rawPhone);

    try {
      await fb_auth.FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: formattedPhone,
        timeout: const Duration(seconds: 60),
        forceResendingToken: _resendToken,
        verificationCompleted: (fb_auth.PhoneAuthCredential credential) async {
          // Automatic verification on some devices
          await _signInWithCredential(credential, formattedPhone);
        },
        verificationFailed: (fb_auth.FirebaseAuthException e) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Verification Failed: ${e.message}'),
              backgroundColor: Colors.red,
            ),
          );
        },
        codeSent: (String verificationId, int? resendToken) {
          setState(() {
            _isLoading = false;
            _isOtpSent = true;
            _verificationId = verificationId;
            _resendToken = resendToken;
          });
          _startTimer();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('OTP Code sent to $formattedPhone'),
              backgroundColor: const Color(0xFF10B981),
            ),
          );
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _verifyOtp() async {
    final otp = _otpController.text.trim();
    if (otp.length < 6 || _verificationId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid 6-digit OTP code')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final credential = fb_auth.PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: otp,
      );
      final rawPhone = _phoneController.text.trim();
      final formattedPhone = _formatPhoneNumber(rawPhone);
      await _signInWithCredential(credential, formattedPhone);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Invalid OTP Code. Please try again: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _signInWithCredential(
    fb_auth.PhoneAuthCredential credential,
    String phone,
  ) async {
    try {
      final userCredential =
          await fb_auth.FirebaseAuth.instance.signInWithCredential(credential);
      final idToken = await userCredential.user?.getIdToken();

      if (idToken == null) {
        throw Exception('Failed to obtain Firebase ID Token');
      }

      if (!mounted) return;
      final authProvider = context.read<AuthProvider>();
      await authProvider.verifyFirebasePhone(
        idToken: idToken,
        phone: phone,
        role: widget.role,
      );

      if (!mounted) return;
      if (authProvider.isAuthenticated) {
        final userRole = authProvider.currentUser?.role ?? 'customer';
        if (userRole == 'provider') {
          context.go('/provider-portal');
        } else if (userRole == 'admin') {
          context.go('/admin-portal');
        } else {
          context.go('/home');
        }
      } else if (authProvider.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.error!),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login error: ${e.toString()}'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF1E293B)),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _isOtpSent ? Icons.mark_email_read_outlined : Icons.phone_android_rounded,
                    size: 38,
                    color: primaryColor,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  _isOtpSent ? 'Verify OTP Code' : 'Phone Verification',
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _isOtpSent
                      ? 'Enter the 6-digit verification code sent to ${_phoneController.text}'
                      : 'We will send a 6-digit SMS OTP verification code to log in securely.',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF64748B),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 32),
                if (!_isOtpSent) ...[
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0F172A),
                    ),
                    decoration: InputDecoration(
                      labelText: 'Phone Number',
                      hintText: '09 123 456 789',
                      prefixIcon: const Icon(Icons.phone_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Please enter phone number';
                      }
                      if (val.trim().length < 8) {
                        return 'Enter a valid phone number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _sendOtp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Send Verification Code',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ] else ...[
                  TextFormField(
                    controller: _otpController,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 10,
                      color: Color(0xFF0F172A),
                    ),
                    decoration: InputDecoration(
                      hintText: '••••••',
                      counterText: '',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _isOtpSent = false;
                            _otpController.clear();
                          });
                        },
                        child: const Text('Change Number'),
                      ),
                      TextButton(
                        onPressed: _timerSeconds == 0 ? _sendOtp : null,
                        child: Text(
                          _timerSeconds > 0
                              ? 'Resend in ${_timerSeconds}s'
                              : 'Resend Code',
                          style: TextStyle(
                            color: _timerSeconds == 0
                                ? primaryColor
                                : const Color(0xFF94A3B8),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _verifyOtp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Verify & Continue',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
