import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/providers/locale_provider.dart';
import '../../core/storage/local_storage.dart';
import '../../l10n/gen/app_localizations.dart';

class LanguageSelectionPage extends ConsumerStatefulWidget {
  final String nextRoute;

  const LanguageSelectionPage({super.key, required this.nextRoute});

  @override
  ConsumerState<LanguageSelectionPage> createState() =>
      _LanguageSelectionPageState();
}

class _LanguageSelectionPageState
    extends ConsumerState<LanguageSelectionPage> {
  String _selectedCode = 'my';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'ဘာသာစကားရွေးချယ်ပါ\nSelect Language\n选择语言',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 48),
              _LanguageTile(
                code: 'my',
                label: 'Myanmar (မြန်မာ)',
                selected: _selectedCode == 'my',
                onTap: () => setState(() => _selectedCode = 'my'),
              ),
              const SizedBox(height: 12),
              _LanguageTile(
                code: 'en',
                label: 'English',
                selected: _selectedCode == 'en',
                onTap: () => setState(() => _selectedCode = 'en'),
              ),
              const SizedBox(height: 12),
              _LanguageTile(
                code: 'zh',
                label: '中文',
                selected: _selectedCode == 'zh',
                onTap: () => setState(() => _selectedCode = 'zh'),
              ),
              const SizedBox(height: 48),
              FilledButton(
                onPressed: _onContinue,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Text(
                    AppLocalizations.of(context).continueBtn,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onContinue() async {
    await ref
        .read(localeProvider.notifier)
        .setLocale(Locale(_selectedCode));
    await LocalStorage.setFirstLaunch(false);
    if (mounted) {
      context.go(widget.nextRoute);
    }
  }
}

class _LanguageTile extends StatelessWidget {
  final String code;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _LanguageTile({
    required this.code,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFF1976D2).withOpacity(0.08)
              : Colors.white,
          border: Border.all(
            color: selected ? const Color(0xFF1976D2) : Colors.grey.shade300,
            width: selected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight:
                      selected ? FontWeight.w600 : FontWeight.normal,
                  color:
                      selected ? const Color(0xFF1976D2) : Colors.black87,
                ),
              ),
            ),
            if (selected)
              const Icon(Icons.check_circle, color: Color(0xFF1976D2)),
          ],
        ),
      ),
    );
  }
}
