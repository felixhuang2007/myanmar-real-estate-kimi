/**
 * B端 - 经纪人登录页 (手机号+验证码)
 */
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pinput/pinput.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/app_utils.dart';
import '../../../buyer/providers/auth_provider.dart';
import '../../../l10n/gen/app_localizations.dart';

class AgentLoginPage extends ConsumerStatefulWidget {
  const AgentLoginPage({super.key});

  @override
  ConsumerState<AgentLoginPage> createState() => _AgentLoginPageState();
}

class _AgentLoginPageState extends ConsumerState<AgentLoginPage> {
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();
  bool _isCodeSent = false;
  int _countdown = 0;

  @override
  void dispose() {
    _phoneController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  void _sendCode() async {
    final phone = _phoneController.text.trim();
    if (!ValidatorUtil.isValidPhone(phone)) {
      ToastUtil.showError(AppLocalizations.of(context).invalidPhone);
      return;
    }

    try {
      await ref.read(authProvider.notifier).sendVerificationCode(phone);
      setState(() {
        _isCodeSent = true;
        _countdown = 60;
      });
      _startCountdown();
      ToastUtil.showSuccess(AppLocalizations.of(context).sendCode);
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
      ToastUtil.showError(l.pleaseEnterPhone);
      return;
    }
    if (code.length != 6) {
      ToastUtil.showError(l.invalidCode);
      return;
    }

    try {
      await ref.read(authProvider.notifier).login(phone, code);
      if (mounted) {
        ToastUtil.showSuccess(AppLocalizations.of(context).loginSuccess);
        context.go(RouteNames.agentHome);
      }
    } catch (e) {
      ToastUtil.showError(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final l = AppLocalizations.of(context);

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
                  Icons.business_center_rounded,
                  size: 32,
                  color: AppColors.white,
                ),
              ),
              const SizedBox(height: 32),
              // 标题
              Text(
                '经纪人登录',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                '请使用经纪人账号登录',
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
                  labelText: l.phoneNumber,
                  hintText: l.pleaseEnterPhone,
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
                      _countdown > 0 ? '${l.resendCode} ($_countdown s)' : l.resendCode,
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
                      : Text(_isCodeSent ? l.login : l.getVerificationCode),
                ),
              ),

              const SizedBox(height: 24),

              // 服务条款
              Center(
                child: Text.rich(
                  TextSpan(
                    text: '登录即表示您同意',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.gray600,
                        ),
                    children: [
                      TextSpan(
                        text: '《经纪人服务协议》',
                        style: const TextStyle(
                          color: AppColors.primary700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const TextSpan(text: '和'),
                      TextSpan(
                        text: '《隐私政策》',
                        style: const TextStyle(
                          color: AppColors.primary700,
                          fontWeight: FontWeight.w500,
                        ),
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
