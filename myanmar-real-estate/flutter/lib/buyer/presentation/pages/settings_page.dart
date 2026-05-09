/**
 * C端 - 设置页面
 */
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/storage/local_storage.dart';
import '../../../core/providers/locale_provider.dart';
import '../../../l10n/gen/app_localizations.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  String _currentLocale = 'en';

  @override
  void initState() {
    super.initState();
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    final locale = LocalStorage.getLocale() ?? 'en';
    setState(() {
      _currentLocale = locale;
    });
  }

  Future<void> _changeLanguage(String languageCode) async {
    await ref.read(localeProvider.notifier).setLocale(Locale(languageCode));
    setState(() {
      _currentLocale = languageCode;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l.settings),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.gray900,
        elevation: 0.5,
      ),
      body: ListView(
        children: [
          // 语言设置
          _buildSectionHeader(context, 'Language'),
          _buildLanguageTile(context, 'English', 'en', Icons.language),
          _buildLanguageTile(context, 'Myanmar (မြန်မာ)', 'my', Icons.language),
          _buildLanguageTile(context, '中文', 'zh', Icons.language),

          const SizedBox(height: 16),

          // 关于
          _buildSectionHeader(context, 'About'),
          _buildMenuTile(
            context,
            icon: Icons.description,
            title: l.userAgreement,
            onTap: () => context.push('/buyer/terms'),
          ),
          _buildMenuTile(
            context,
            icon: Icons.privacy_tip,
            title: l.privacyPolicy,
            onTap: () => context.push('/buyer/privacy'),
          ),

          const SizedBox(height: 32),

          // 版本号
          Center(
            child: Text(
              'Myanmar Home v1.0.0',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.gray500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.gray500,
        ),
      ),
    );
  }

  Widget _buildLanguageTile(BuildContext context, String label, String code, IconData icon) {
    final isSelected = _currentLocale == code;
    return Container(
      color: AppColors.white,
      child: ListTile(
        leading: Icon(icon, color: AppColors.gray700),
        title: Text(label),
        trailing: isSelected
            ? Icon(Icons.check_circle, color: AppColors.primary700)
            : const SizedBox.shrink(),
        onTap: () => _changeLanguage(code),
      ),
    );
  }

  Widget _buildMenuTile(BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      color: AppColors.white,
      child: ListTile(
        leading: Icon(icon, color: AppColors.gray700),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right, color: AppColors.gray400),
        onTap: onTap,
      ),
    );
  }
}
