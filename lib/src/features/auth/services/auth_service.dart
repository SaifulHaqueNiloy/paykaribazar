import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../core/firebase/firestore_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/services/security_initializer.dart';
import '../../../di/service_locator.dart';
import '../../../core/constants/paths.dart';

final authServiceProvider = Provider((ref) => getIt<AuthService>());

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final StorageService _storage;
  final FirestoreService _firestore;

  AuthService({
    required StorageService storage,
    required FirestoreService firestore,
  })  : _storage = storage,
        _firestore = firestore;

  String _normalizePhone(String phone) {
    String cleaned = phone.replaceAll(RegExp(r'[\s\-()]+'), '');
    if (cleaned.startsWith('+880')) {
      cleaned = cleaned.substring(3);
    } else if (cleaned.startsWith('880')) {
      cleaned = cleaned.substring(2);
    } else if (cleaned.startsWith('+88')) {
      cleaned = cleaned.substring(3);
    } else if (cleaned.startsWith('88')) {
      cleaned = cleaned.substring(2);
    }
    if (cleaned.length == 10 && RegExp(r'^[1-9]\d{9}$').hasMatch(cleaned)) {
      cleaned = '0$cleaned';
    }
    return cleaned;
  }

  Future<String> _generateReferralCode(String name, String? phone) async {
    final cleanName = name.replaceAll(RegExp(r'[^a-zA-Z]'), '').toUpperCase();
    final prefix = cleanName.length >= 3 ? cleanName.substring(0, 3) : 'PB';
    final random = '$prefix${DateTime.now().microsecondsSinceEpoch % 9000 + 1000}';

    final existing = await _db
        .collection(HubPaths.users)
        .where('myReferralCode', isEqualTo: random)
        .limit(1)
        .get();

    if (existing.docs.isEmpty) {
      return random;
    }

    for (var i = 0; i < 10; i++) {
      final candidate = '$prefix${DateTime.now().microsecondsSinceEpoch % 9000 + 1000 + i}';
      final dup = await _db
          .collection(HubPaths.users)
          .where('myReferralCode', isEqualTo: candidate)
          .limit(1)
          .get();

      if (dup.docs.isEmpty) return candidate;
    }

    final fallback = '${prefix}_${DateTime.now().millisecondsSinceEpoch}';
    return fallback;
  }

  Future<User?> login(String emailOrPhone, String password) async {
    try {
      String email = emailOrPhone.trim();
      // If the input doesn't look like an email, assume it's a phone number and use the internal format
      if (!email.contains('@')) {
        final normalized = _normalizePhone(email);
        email = '$normalized@paykaribazar.com';
      }

      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (credential.user != null) {
        await _storage.setString('user_id', credential.user!.uid);

        // Auto-create user document in Firestore if missing or incomplete
        try {
          final userDoc = await _db.collection(HubPaths.users).doc(credential.user!.uid).get();
          final userData = userDoc.data();
          if (!userDoc.exists || userData?['myReferralCode'] == null) {
            String role = userData?['role'] ?? 'customer';
            String name = userData?['name'] ?? 'User';
            if (!userDoc.exists) {
              if (email.startsWith('admin')) {
                role = 'admin';
                name = 'Admin';
              } else if (email.contains('staff')) {
                role = 'staff';
                name = 'Staff';
              } else if (email.contains('rider') || email.contains('logistic')) {
                role = 'logistic';
                name = 'Rider';
              }
            }
            
            final myCode = await _generateReferralCode(name, null);
            await _firestore.updateProfile(credential.user!.uid, {
              if (!userDoc.exists) 'name': name,
              if (!userDoc.exists) 'email': email.contains('paykaribazar.com') && !emailOrPhone.contains('@') ? null : email,
              if (!userDoc.exists) 'phone': !emailOrPhone.contains('@') ? _normalizePhone(emailOrPhone) : null,
              if (!userDoc.exists) 'role': role,
              'myReferralCode': myCode,
              if (!userDoc.exists) 'createdAt': FieldValue.serverTimestamp(),
            });
          }
        } catch (e) {
          debugPrint('⚠️ Failed to auto-create/update user document: $e');
        }

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
    String? districtId,
    String? upazilaId,
    String? bloodGroup,
    bool isBloodDonor = false,
    String? bloodContactNumber,
  }) async {
    try {
      final normalizedPhone = phone != null ? _normalizePhone(phone) : null;
      final authEmail =
          email ?? (normalizedPhone != null ? '$normalizedPhone@paykaribazar.com' : null);
      if (authEmail == null) throw Exception('Email or Phone is required');

      // ১. প্রথমে ইউজার তৈরি করা (অবশ্যই আগে করতে হবে সিকিউরিটির জন্য)
      final res = await _auth.createUserWithEmailAndPassword(
        email: authEmail,
        password: password,
      );

      if (res.user != null) {
        // ২. ইউজার এখন লগইন অবস্থায় আছে, এখন প্যারালাল কাজ শুরু করা নিরাপদ
        final settingsFuture = _db.doc(HubPaths.loyaltyDoc).get();
        final myCodeFuture = _generateReferralCode(name, normalizedPhone);
        
        String? referrerUid;
        if (referralCode != null && referralCode.isNotEmpty) {
          final refDoc = await _db
              .collection(HubPaths.users)
              .where('myReferralCode', isEqualTo: referralCode)
              .limit(1)
              .get();

          if (refDoc.docs.isNotEmpty) {
            referrerUid = refDoc.docs.first.id;
          } else {
             throw Exception('Invalid referral code');
          }
        }

        // ৩. প্যারালাল টাস্কগুলোর জন্য অপেক্ষা করা
        final results = await Future.wait([myCodeFuture, settingsFuture]);
        final myCode = results[0] as String;
        final settingsSnap = results[1] as DocumentSnapshot<Map<String, dynamic>>;
        
        final signupBonus = (settingsSnap.data()?['signupPoints'] ?? 
                             settingsSnap.data()?['signup_bonus'] ?? 100).toInt();

        // ৪. ব্যাচ অপারেশন দিয়ে একবারে সব ডাটা সেভ করা (Super Fast)
        final batch = _db.batch();
        final userRef = _db.collection(HubPaths.users).doc(res.user!.uid);
        
        batch.set(userRef, {
          'name': name,
          'email': email,
          'phone': normalizedPhone,
          'referredBy': referralCode,
          'referredByUid': referrerUid,
          'myReferralCode': myCode,
          'points': signupBonus, 
          'role': 'customer',
          'districtId': districtId,
          'upazilaId': upazilaId,
          'bloodGroup': bloodGroup,
          'isBloodDonor': isBloodDonor,
          'bloodContactNumber': bloodContactNumber,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        final txRef = userRef.collection('transactions').doc();
        batch.set(txRef, {
          'title': 'স্বাগতম বোনাস (Welcome Bonus)',
          'points': signupBonus,
          'type': 'credit',
          'createdAt': FieldValue.serverTimestamp(),
        });

        if (referrerUid != null) {
          final referrerRef = _db.collection(HubPaths.users).doc(referrerUid);
          batch.update(referrerRef, {
            'referredCount': FieldValue.increment(1),
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }

        if (isBloodDonor && bloodGroup != null) {
          final donorRef = _db.collection(HubPaths.donors).doc();
          batch.set(donorRef, {
            'uid': res.user!.uid,
            'name': name,
            'group': bloodGroup,
            'phone': bloodContactNumber ?? normalizedPhone,
            'districtId': districtId,
            'upazilaId': upazilaId,
            'isVisible': true,
            'lastDonated': null,
            'type': 'donor',
            'createdAt': FieldValue.serverTimestamp(),
          });
        }

        await batch.commit();
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
        final doc = await FirebaseFirestore.instance.collection(HubPaths.users).doc(res.user!.uid).get();
        final existingReferral = doc.data()?['myReferralCode'];

        await _firestore.updateProfile(res.user!.uid, {
          'name': res.user!.displayName,
          'email': res.user!.email,
          'profilePic': res.user!.photoURL,
          'myReferralCode': existingReferral ?? await _generateReferralCode(res.user!.displayName ?? 'User', null),
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
      final normalizedPhone = _normalizePhone(phone);
      final myCode = await _generateReferralCode(name, normalizedPhone);
      await _firestore.updateProfile(res.user!.uid, {
        'name': name,
        'phone': normalizedPhone,
        'staffId': staffId,
        'role': role,
        'myReferralCode': myCode,
        'allowMultipleDevices': allowMultipleDevices,
        'createdAt': FieldValue.serverTimestamp(),
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
