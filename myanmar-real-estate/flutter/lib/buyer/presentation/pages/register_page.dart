/**
 * C端 - 注册页
 */
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

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isCodeSent = false;
  int _countdown = 0;
  bool _agreedToTerms = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _phoneController.dispose();
    _codeController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _sendCode() async {
    final phone = _phoneController.text.trim();
    if (!ValidatorUtil.isValidPhone(phone)) {
      ToastUtil.showError('请输入有效的手机号');
      return;
    }

    setState(() {
      _isCodeSent = true;
      _countdown = 60;
    });
    _startCountdown();
    ToastUtil.showSuccess('验证码已发送');
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

  void _register() async {
    if (!_agreedToTerms) {
      ToastUtil.showError('请同意用户协议');
      return;
    }

    final phone = _phoneController.text.trim();
    final code = _codeController.text.trim();
    final password = _passwordController.text.trim();
    final name = _nameController.text.trim();

    if (phone.isEmpty) {
      ToastUtil.showError('请输入手机号');
      return;
    }
    if (code.length != 6) {
      ToastUtil.showError('请输入6位验证码');
      return;
    }
    if (password.length < 6) {
      ToastUtil.showError('密码至少6位');
      return;
    }
    if (name.isEmpty) {
      ToastUtil.showError('请输入姓名');
      return;
    }

    try {
      await ref.read(authProvider.notifier).register(
        phone: phone,
        code: code,
        password: password,
        name: name,
      );
      if (mounted) {
        ToastUtil.showSuccess('注册成功');
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
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back, color: AppColors.gray700),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 标题
              Text(
                '创建新账号',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                '填写以下信息完成注册',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.gray600,
                    ),
              ),
              const SizedBox(height: 32),

              // 姓名输入
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: '真实姓名',
                  hintText: '请输入您的真实姓名',
                  prefixIcon: const Icon(Icons.person_outline),
                  filled: true,
                  fillColor: AppColors.gray50,
                ),
              ),
              const SizedBox(height: 16),

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
              const SizedBox(height: 16),

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
                ),
                const SizedBox(height: 8),
                // 重新发送
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _countdown > 0 ? null : _sendCode,
                    child: Text(
                      _countdown > 0 ? '重新发送 ($_countdown s)' : l.resendCode,
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 8),

              // 密码输入
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: '设置密码',
                  hintText: '6-20位密码',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    ),
                  ),
                  filled: true,
                  fillColor: AppColors.gray50,
                ),
              ),

              const SizedBox(height: 16),

              // 用户协议
              Row(
                children: [
                  Checkbox(
                    value: _agreedToTerms,
                    onChanged: (value) {
                      setState(() {
                        _agreedToTerms = value ?? false;
                      });
                    },
                  ),
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        text: '我已阅读并同意',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.gray600,
                            ),
                        children: [
                          TextSpan(
                            text: '《${l.termsOfService}》',
                            style: const TextStyle(
                              color: AppColors.primary700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const TextSpan(text: '和'),
                          TextSpan(
                            text: '《${l.privacyPolicy}》',
                            style: const TextStyle(
                              color: AppColors.primary700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // 注册按钮
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: authState.isLoading
                      ? null
                      : (_isCodeSent ? _register : _sendCode),
                  child: authState.isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.white,
                          ),
                        )
                      : Text(_isCodeSent ? l.register : l.getVerificationCode),
                ),
              ),

              const SizedBox(height: 24),

              // 登录入口
              Center(
                child: TextButton(
                  onPressed: () {
                    context.pop();
                  },
                  child: const Text('已有账号？立即登录'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
