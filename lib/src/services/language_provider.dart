import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LanguageNotifier extends StateNotifier<Locale> {
  LanguageNotifier() : super(const Locale('bn', ''));

  void setLanguage(String code) {
    state = Locale(code, '');
  }

  void toggleLanguage() {
    if (state.languageCode == 'bn') {
      state = const Locale('en', '');
    } else {
      state = const Locale('bn', '');
    }
  }

  String get languageCode => state.languageCode;
}

final languageProvider = StateNotifierProvider<LanguageNotifier, Locale>((ref) {
  return LanguageNotifier();
});

final translatorProvider = Provider((ref) => TranslatorService());

class TranslatorService {
  String translate(String key, String lang) {
    return key;
  }

  String call(String key) => key; // Support for translatorProvider(key)
}
