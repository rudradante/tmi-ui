import 'dart:async';
import 'package:flutter/material.dart';
import 'package:tmiui/custom_widgets/text_field.dart';
import 'package:tmiui/helpers/file_system.dart';
import 'package:tmiui/models.dart/login_user.dart';
import 'package:tmiui/screens/my_account.dart';
import 'package:tmiui/screens/plan_dashboard.dart';

import '../config/config_provider.dart';
import '../custom_widgets/custom_flat_button.dart';
import '../custom_widgets/custom_scaffold.dart';
import '../custom_widgets/message_dialog.dart';
import '../extensions/color.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;

  // ----------------- Forgot Password Sheet State -----------------
  final _fpFormKey = GlobalKey<FormState>();
  final TextEditingController _fpEmail = TextEditingController();
  final TextEditingController _fpOtp = TextEditingController();
  final TextEditingController _fpNewPass = TextEditingController();
  final TextEditingController _fpConfirmPass = TextEditingController();

  bool _fpOtpPhase = false; // after OTP sent, show OTP + new pass inputs
  bool _fpSendingOtp = false;
  bool _fpResetting = false;

  bool _fpCanResend = true;
  int _fpResendSeconds = 45;
  Timer? _fpTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => checkLoggedIn());
  }

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();

    _fpEmail.dispose();
    _fpOtp.dispose();
    _fpNewPass.dispose();
    _fpConfirmPass.dispose();

    _fpTimer?.cancel();
    super.dispose();
  }

  // ----------------- Login -----------------
  void login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    final loginUser = await LoginUser.login(
      usernameController.text.trim(),
      passwordController.text.trim(),
      context,
    );

    setState(() => isLoading = false);

    if (loginUser == null) return;
    await PlanDashboardRoute.push(context);
  }

  // ----------------- Auto-login -----------------
  void checkLoggedIn() async {
    final refreshToken = AppFile.readAsString("refresh_token");
    if (refreshToken != null && refreshToken.isNotEmpty) {
      final lu = await LoginUser.refresh(refreshToken, context);
      if (lu != null) {
        await PlanDashboardRoute.push(context);
      } else {
        AppFile.delete("refresh_token");
      }
    }
  }

  // ----------------- Sign up -----------------
  void goToSignup() {
    MyAccountRoute.push(context, true);
  }

  // ----------------- Forgot Password (Bottom Sheet) -----------------
  void _openForgotPasswordSheet() {
    _resetForgotSheetState();
    _fpEmail.text = usernameController.text.trim(); // prefill if available

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final theme = ConfigProvider.getThemeConfig();
        final primary = HexColor.fromHex(theme.primaryButtonColor);

        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
          ),
          child: Form(
            key: _fpFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 6),
                Container(
                  width: 50,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Reset Password',
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),

                // Email (always shown)
                CustomTextField(
                    controller: _fpEmail, label: 'Registered email'),
                const SizedBox(height: 10),

                // Phase 1: Send OTP
                if (!_fpOtpPhase) ...[
                  Row(
                    children: [
                      Expanded(
                        child: CustomFlatButton(
                          isOutlined: false,
                          text: _fpSendingOtp
                              ? 'Sending...'
                              : (_fpCanResend
                                  ? 'Send OTP'
                                  : 'Resend in ${_fpResendSeconds}s'),
                          color: primary,
                          onTap: (!_fpCanResend || _fpSendingOtp)
                              ? null
                              : _sendOtp,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'We will email a One-Time Password to this address.',
                    style: TextStyle(fontSize: 12, color: Colors.black87),
                  ),
                ],

                // Phase 2: Enter OTP + New Password (same request on submit)
                if (_fpOtpPhase) ...[
                  CustomTextField(
                      controller: _fpOtp, label: '6-digit OTP', maxLength: 6),
                  const SizedBox(height: 10),
                  CustomTextField(
                    controller: _fpNewPass,
                    label: 'New Password',
                    hiddenText: true,
                  ),
                  const SizedBox(height: 10),
                  CustomTextField(
                    controller: _fpConfirmPass,
                    label: 'Confirm New Password',
                    hiddenText: true,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: CustomFlatButton(
                          isOutlined: false,
                          text:
                              _fpResetting ? 'Resetting...' : 'Reset Password',
                          color: primary,
                          onTap: _fpResetting ? null : _resetPasswordWithOtp,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _fpCanResend ? _resendOtp : null,
                      child: Text(_fpCanResend
                          ? 'Resend OTP'
                          : 'Resend in ${_fpResendSeconds}s'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    ).whenComplete(() => _resetForgotSheetState(keepEmail: true));
  }

  void _resetForgotSheetState({bool keepEmail = false}) {
    if (!keepEmail) _fpEmail.clear();
    _fpOtp.clear();
    _fpNewPass.clear();
    _fpConfirmPass.clear();

    _fpOtpPhase = false;
    _fpSendingOtp = false;
    _fpResetting = false;

    _fpCanResend = true;
    _fpResendSeconds = 45;
    _fpTimer?.cancel();

    setState(() {});
  }

  Future<void> _sendOtp() async {
    setState(() => _fpSendingOtp = true);

    // BACKEND: send OTP to email (no password in this email)
    final ok = await LoginUser.forgotPassword(_fpEmail.text.trim(), context);

    setState(() => _fpSendingOtp = false);
    if (!ok) return;

    // Switch to OTP + New Password phase
    setState(() {
      _fpOtpPhase = true;
      _fpCanResend = false;
      _fpResendSeconds = 45;
    });

    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('OTP sent to ${_fpEmail.text.trim()}')));

    _startResendCountdown();
  }

  void _startResendCountdown() {
    _fpTimer?.cancel();
    _fpTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_fpResendSeconds <= 1) {
        t.cancel();
        if (mounted) {
          setState(() {
            _fpCanResend = true;
            _fpResendSeconds = 45;
          });
        }
      } else {
        if (mounted) {
          setState(() => _fpResendSeconds--);
        }
      }
    });
  }

  Future<void> _resendOtp() async {
    if (_fpSendingOtp) return;
    setState(() => _fpSendingOtp = true);

    final ok = await LoginUser.forgotPassword(_fpEmail.text.trim(), context);

    setState(() => _fpSendingOtp = false);

    if (!ok) return;

    setState(() {
      _fpCanResend = false;
      _fpResendSeconds = 45;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('OTP re-sent to ${_fpEmail.text.trim()}')),
    );

    _startResendCountdown();
  }

  Future<void> _resetPasswordWithOtp() async {
    if (_fpConfirmPass.text.trim() != _fpNewPass.text.trim()) {
      showMessageDialog("Invalid password", 'Passwords do not match', context);
      return;
    }
    setState(() => _fpResetting = true);

    // BACKEND: single request with email + otp + newPassword
    final ok = await LoginUser.resetPassword(
      _fpEmail.text.trim(),
      _fpOtp.text.trim(),
      _fpNewPass.text.trim(),
      context,
    );

    setState(() => _fpResetting = false);

    if (!ok) return;

    if (mounted) Navigator.of(context).pop(); // close sheet

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text(
          'Password reset successful. Please log in with your new password.'),
    ));

    // Prefill username; keep password field empty
    setState(() => usernameController.text = _fpEmail.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final theme = ConfigProvider.getThemeConfig();
    final primary = HexColor.fromHex(theme.primaryButtonColor);

    return CustomScaffold(
      title: "Login",
      leadingAppbarWidget: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Image.asset("assets/icons/empty.png", width: 16, height: 16),
      ),
      showBackButton: false,
      appBarTitleSize: 32,
      appBarBackgroundColor: HexColor.fromHex(theme.scaffoldBackgroundColor),
      scaffoldBackgroundColor: Colors.white,
      centerWidget: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset("assets/icons/empty.png", width: 128, height: 128),
              const SizedBox(height: 20),
              CustomTextField(controller: usernameController, label: "Email"),
              const SizedBox(height: 8),
              CustomTextField(
                  hiddenText: true,
                  controller: passwordController,
                  label: "Password"),
              const SizedBox(height: 6),
              const SizedBox(height: 8),
              CustomFlatButton(
                isOutlined: false,
                text: isLoading ? 'Logging in...' : 'Login',
                color: primary,
                onTap: isLoading ? null : login,
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: goToSignup,
                child: const Text("Don't have an account? Sign Up"),
              ),
              SizedBox(height: 6),
              CustomFlatButton(
                  text: 'Forgot Password?',
                  color: primary,
                  isOutlined: true,
                  onTap: _openForgotPasswordSheet)
            ],
          ),
        ),
      ),
    );
  }
}
