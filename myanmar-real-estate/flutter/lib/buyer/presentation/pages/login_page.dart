/**
 * C端 - 登录页 (手机号+验证码)
 */
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pinput/pinput.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/app_utils.dart';
import '../../providers/auth_provider.dart';
import '../../../l10n/gen/app_localizations.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();
  final _codeFocusNode = FocusNode();
  bool _isCodeSent = false;
  int _countdown = 0;

  late final TapGestureRecognizer _termsRecognizer;
  late final TapGestureRecognizer _privacyRecognizer;

  @override
  void initState() {
    super.initState();
    _termsRecognizer = TapGestureRecognizer()
      ..onTap = () => context.push('/buyer/terms');
    _privacyRecognizer = TapGestureRecognizer()
      ..onTap = () => context.push('/buyer/privacy');
  }

  @override
  void dispose() {
    _termsRecognizer.dispose();
    _privacyRecognizer.dispose();
    _phoneController.dispose();
    _codeController.dispose();
    _codeFocusNode.dispose();
    super.dispose();
  }

  void _sendCode() async {
    final phone = _phoneController.text.trim();
    final l = AppLocalizations.of(context);
    if (!ValidatorUtil.isValidPhone(phone)) {
      ToastUtil.showError(l?.invalidPhone ?? 'Invalid phone number');
      return;
    }

    try {
      await ref.read(authProvider.notifier).sendVerificationCode(phone);
      setState(() {
        _isCodeSent = true;
        _countdown = 60;
      });
      _startCountdown();
      ToastUtil.showSuccess(l?.sendCode ?? 'Code sent');
      // 焦点移到验证码输入框
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _codeFocusNode.requestFocus();
      });
    } catch (e) {
      ToastUtil.showError(e.toString());
    }
  }

  void _startCountdown() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        setState(() {
          _countdown--;
        });
      }
      return _countdown > 0;
    });
  }

  void _login() async {
    final phone = _phoneController.text.trim();
    final code = _codeController.text.trim();
    final l = AppLocalizations.of(context);

    if (phone.isEmpty) {
      ToastUtil.showError(l?.pleaseEnterPhone ?? 'Please enter phone number');
      return;
    }
    if (code.length != 6) {
      ToastUtil.showError(l?.invalidCode ?? 'Invalid code');
      return;
    }

    try {
      await ref.read(authProvider.notifier).login(phone, code);
      if (mounted) {
        ToastUtil.showSuccess(l?.loginSuccess ?? 'Login successful');
        context.go(RouteNames.buyerHome);
      }
    } catch (e) {
      ToastUtil.showError(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              // Logo
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.primary700,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.home_rounded,
                  size: 32,
                  color: AppColors.white,
                ),
              ),
              const SizedBox(height: 32),
              // 标题
              Text(
                l?.welcome ?? 'Welcome',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                l?.loginSubtitle ?? 'Login with your phone number',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.gray600,
                    ),
              ),
              const SizedBox(height: 48),

              // 手机号输入
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: l?.phoneNumber ?? '手机号',
                  hintText: l?.pleaseEnterPhone ?? '请输入手机号',
                  prefixIcon: const Icon(Icons.phone_outlined),
                  prefixText: '+95 ',
                  filled: true,
                  fillColor: AppColors.gray50,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(11),
                ],
              ),
              const SizedBox(height: 24),

              // 验证码输入
              if (_isCodeSent) ...[
                Pinput(
                  controller: _codeController,
                  focusNode: _codeFocusNode,
                  length: 6,
                  defaultPinTheme: PinTheme(
                    width: 48,
                    height: 56,
                    textStyle: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.gray400),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  focusedPinTheme: PinTheme(
                    width: 48,
                    height: 56,
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.primary700, width: 2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onCompleted: (_) => _login(),
                ),
                const SizedBox(height: 16),
                // 重新发送
                Center(
                  child: TextButton(
                    onPressed: _countdown > 0 ? null : _sendCode,
                    child: Text(
                      _countdown > 0 ? '${l?.resendCode ?? 'Resend'} ($_countdown s)' : (l?.resendCode ?? 'Resend'),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 32),

              // 登录按钮
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: authState.isLoading ? null : (_isCodeSent ? _login : _sendCode),
                  child: authState.isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.white,
                          ),
                        )
                      : Text(_isCodeSent ? (l?.login ?? '登录') : (l?.getVerificationCode ?? '获取验证码')),
                ),
              ),

              const SizedBox(height: 24),

              // 服务条款
              Center(
                child: Text.rich(
                  TextSpan(
                    text: l?.agreeToTerms ?? 'By logging in, you agree to',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.gray600,
                        ),
                    children: [
                      TextSpan(
                        text: ' ${l?.termsOfService ?? 'Terms of Service'} ',
                        style: const TextStyle(
                          color: AppColors.primary700,
                          fontWeight: FontWeight.w500,
                        ),
                        recognizer: _termsRecognizer,
                      ),
                      TextSpan(text: l?.andConnector ?? 'and'),
                      TextSpan(
                        text: ' ${l?.privacyPolicy ?? 'Privacy Policy'} ',
                        style: const TextStyle(
                          color: AppColors.primary700,
                          fontWeight: FontWeight.w500,
                        ),
                        recognizer: _privacyRecognizer,
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
