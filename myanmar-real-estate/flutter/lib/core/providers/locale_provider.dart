import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../storage/local_storage.dart';

class LocaleNotifier extends Notifier<Locale> {
  @override
  Locale build() {
    final saved = LocalStorage.getLocale();
    return Locale(saved ?? 'my');
  }

  Future<void> setLocale(Locale locale) async {
    await LocalStorage.saveLocale(locale.languageCode);
    state = locale;
  }
}

final localeProvider = NotifierProvider<LocaleNotifier, Locale>(
  LocaleNotifier.new,
);
