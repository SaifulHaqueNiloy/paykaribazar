import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/constants/paths.dart';

class LanguageNotifier extends StateNotifier<Locale> {
  LanguageNotifier() : super(const Locale('bn', '')) {
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString('language_code');
    if (code != null) {
      state = Locale(code, '');
    }
  }

  Future<void> setLanguage(String code) async {
    state = Locale(code, '');
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', code);
    _syncToDatabase(code);
  }

  Future<void> toggleLanguage() async {
    final newCode = state.languageCode == 'bn' ? 'en' : 'bn';
    await setLanguage(newCode);
  }

  void _syncToDatabase(String code) {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      FirebaseFirestore.instance
          .collection(HubPaths.users)
          .doc(user.uid)
          .update({'preferredLanguage': code}).catchError((_) {});
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

  String call(String key) => key;
}
