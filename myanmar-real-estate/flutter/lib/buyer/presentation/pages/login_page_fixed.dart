/**
 * C端 - 登录页 (修复版本)
 * 修复内容:
 * 1. 修复内存泄漏问题 (使用Timer替代Future.doWhile)
 * 2. 优化错误处理
 */
import 'dart:async';
import 'package:flutter/material.dart';
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

class _LoginPageState extends ConsumerState<LoginPage> with WidgetsBindingObserver {
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();
  bool _isCodeSent = false;
  int _countdown = 0;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _countdownTimer?.cancel();
    _phoneController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _countdownTimer?.cancel();
    }
  }

  void _sendCode() async {
    final phone = _phoneController.text.trim();

    if (!ValidatorUtil.isValidPhone(phone)) {
      ToastUtil.showError('请输入有效的手机号');
      return;
    }

    try {
      await ref.read(authProvider.notifier).sendVerificationCode(phone);
      setState(() {
        _isCodeSent = true;
        _countdown = 60;
      });
      _startCountdown();
      ToastUtil.showSuccess('验证码已发送');
    } catch (e) {
      ToastUtil.showError(e.toString());
    }
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _countdown--;
      });
      if (_countdown <= 0) {
        timer.cancel();
      }
    });
  }

  void _login() async {
    final phone = _phoneController.text.trim();
    final code = _codeController.text.trim();

    if (!ValidatorUtil.isValidPhone(phone)) {
      ToastUtil.showError('请输入有效的手机号');
      return;
    }

    if (code.length != 6) {
      ToastUtil.showError('请输入6位验证码');
      return;
    }

    try {
      await ref.read(authProvider.notifier).login(phone, code);
      if (mounted) {
        ToastUtil.showSuccess('登录成功');
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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              Text(
                '欢迎登录',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.gray900,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                '请输入手机号获取验证码',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.gray600,
                    ),
              ),
              const SizedBox(height: 48),
              // 手机号输入
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                maxLength: 11,
                decoration: InputDecoration(
                  hintText: l.pleaseEnterPhone,
                  prefixIcon: const Icon(Icons.phone_outlined),
                  prefixText: '+95 ',
                  counterText: '',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // 验证码输入
              if (_isCodeSent)
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
                      border: Border.all(color: AppColors.gray300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  focusedPinTheme: PinTheme(
                    width: 48,
                    height: 56,
                    textStyle: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.primary700),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              const SizedBox(height: 32),
              // 登录按钮
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: authState.isLoading
                      ? null
                      : (_isCodeSent ? _login : _sendCode),
                  child: authState.isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.white,
                          ),
                        )
                      : Text(_isCodeSent ? l.login : l.getVerificationCode),
                ),
              ),
              const SizedBox(height: 16),
              // 重新发送
              if (_isCodeSent)
                Center(
                  child: TextButton(
                    onPressed: _countdown > 0 ? null : _sendCode,
                    child: Text(
                      _countdown > 0 ? '$_countdown秒后重新获取' : l.resendCode,
                      style: TextStyle(
                        color: _countdown > 0 ? AppColors.gray400 : AppColors.primary700,
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 24),
              // 协议
              Center(
                child: Text.rich(
                  TextSpan(
                    text: '登录即表示同意',
                    style: TextStyle(fontSize: 12, color: AppColors.gray500),
                    children: [
                      TextSpan(
                        text: '《${l.termsOfService}》',
                        style: TextStyle(color: AppColors.primary700),
                      ),
                      TextSpan(text: '和'),
                      TextSpan(
                        text: '《${l.privacyPolicy}》',
                        style: TextStyle(color: AppColors.primary700),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
