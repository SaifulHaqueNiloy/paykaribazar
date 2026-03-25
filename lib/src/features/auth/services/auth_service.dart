import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../core/firebase/firestore_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/services/security_initializer.dart';
import '../../../di/service_locator.dart';

final authServiceProvider = Provider((ref) => getIt<AuthService>());

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final StorageService _storage;
  final FirestoreService _firestore;

  AuthService({
    required StorageService storage,
    required FirestoreService firestore,
  })  : _storage = storage,
        _firestore = firestore;

  Future<User?> login(String emailOrPhone, String password) async {
    try {
      String email = emailOrPhone.trim();
      // If the input doesn't look like an email, assume it's a phone number and use the internal format
      if (!email.contains('@')) {
        email = '$email@paykaribazar.com';
      }

      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (credential.user != null) {
        await _storage.setString('user_id', credential.user!.uid);

        // ⭐ SECURITY: Also store token securely
        try {
          final secureAuth = SecurityInitializer.secureAuth;
          await secureAuth.storeSecureToken(
            'firebase_access_token',
            credential.user!.uid,
          );
          debugPrint('✅ Token stored securely via SecureAuthService');
        } catch (e) {
          debugPrint('⚠️ Failed to store token securely: $e');
          // Not critical, fallback to normal storage
        }
      }
      return credential.user;
    } catch (e) {
      rethrow;
    }
  }

  Future<User?> signIn(String email, String password) async {
    return await login(email, password);
  }

  Future<UserCredential?> signUp({
    required String name,
    String? email,
    String? phone,
    required String password,
    String? referralCode,
  }) async {
    try {
      final authEmail =
          email ?? (phone != null ? '$phone@paykaribazar.com' : null);
      if (authEmail == null) throw Exception('Email or Phone is required');

      final res = await _auth.createUserWithEmailAndPassword(
        email: authEmail,
        password: password,
      );

      if (res.user != null) {
        await _firestore.updateProfile(res.user!.uid, {
          'name': name,
          'email': email,
          'phone': phone,
          'referralCode': referralCode,
          'role': 'customer',
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      return res;
    } catch (e) {
      rethrow;
    }
  }

  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return null;
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final res = await _auth.signInWithCredential(credential);
      if (res.user != null) {
        await _firestore.updateProfile(res.user!.uid, {
          'name': res.user!.displayName,
          'email': res.user!.email,
          'profilePic': res.user!.photoURL,
          'lastLogin': FieldValue.serverTimestamp(),
        });
      }
      return res.user;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> registerStaff(
      {required String name,
      required String phone,
      required String staffId,
      required String password,
      required String role,
      bool allowMultipleDevices = false}) async {
    final email = '$staffId@paykaribazar.com';
    final res = await _auth.createUserWithEmailAndPassword(
        email: email, password: password);
    if (res.user != null) {
      await _firestore.updateProfile(res.user!.uid, {
        'name': name,
        'phone': phone,
        'staffId': staffId,
        'role': role,
        'allowMultipleDevices': allowMultipleDevices,
        'createdAt': DateTime.now(),
      });
    }
  }

  Future<void> updateStaffCredentials(String uid, {String? phone}) async {
    if (phone != null) {
      await _firestore.updateProfile(uid, {'phone': phone});
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    await _storage.remove('user_id');
  }

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();
}
