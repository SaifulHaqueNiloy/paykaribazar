import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:http/http.dart' as http;
import '../core/constants/paths.dart';
import 'package:flutter/foundation.dart';

class BackupService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  late final encrypt.Encrypter _encrypter;

  /// Initializes BackupService with a 32-byte encryption key.
  /// Key should be provided from a secure source (e.g. Remote Config).
  BackupService(String masterKey) {
    // DNA ENFORCED: Key must be 32 chars for AES-256
    final key = encrypt.Key.fromUtf8(masterKey);
    _encrypter = encrypt.Encrypter(encrypt.AES(key));
  }

  /// Performs a full cloud backup with encryption
  Future<String> performFullBackup(String adminId) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final backupData = <String, dynamic>{
        'timestamp': timestamp,
        'adminId': adminId,
        'collections': {},
      };

      // Define target collections for backup
      final collections = [
        HubPaths.users,
        HubPaths.orders,
        HubPaths.products,
        HubPaths.categories,
        'settings',
      ];

      for (var collection in collections) {
        final snap = await _db.collection(collection).get();
        backupData['collections'][collection] = snap.docs.map((doc) => {
          'id': doc.id,
          ...doc.data(),
        }).toList();
      }

      final jsonStr = jsonEncode(backupData);
      final iv = encrypt.IV.fromSecureRandom(16);
      final encrypted = _encrypter.encrypt(jsonStr, iv: iv);

      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/backup_$timestamp.enc');
      await file.writeAsBytes(Uint8List.fromList(iv.bytes + encrypted.bytes));

      final ref = _storage.ref().child('backups/backup_$timestamp.enc');
      await ref.putFile(file);
      final downloadUrl = await ref.getDownloadURL();

      await _db.collection('backups').add({
        'timestamp': FieldValue.serverTimestamp(),
        'fileUrl': downloadUrl,
        'fileName': 'backup_$timestamp.enc',
        'adminId': adminId,
        'status': 'success',
        'isEncrypted': true,
      });

      return 'Backup successful and encrypted: backup_$timestamp.enc';
    } catch (e) {
      if (kDebugMode) debugPrint('Backup Error: $e');
      return 'Backup failed: $e';
    }
  }

  /// Restores data from an encrypted backup file using Batch Writes
  /// WARNING: This overwrites existing data in the target collections.
  Future<void> restoreFromBackup(String fileUrl) async {
    try {
      // 1. Download the encrypted file
      final response = await http.get(Uri.parse(fileUrl));
      if (response.statusCode != 200) throw Exception('Download failed');

      // 2. Decrypt data
      final bytes = response.bodyBytes;
      final iv = encrypt.IV(bytes.sublist(0, 16));
      final encrypted = encrypt.Encrypted(bytes.sublist(16));
      final decryptedStr = _encrypter.decrypt(encrypted, iv: iv);
      final Map<String, dynamic> backupData = jsonDecode(decryptedStr);
      final collectionsData = backupData['collections'] as Map<String, dynamic>;

      // 3. Restore each collection using Batch Writes
      for (var entry in collectionsData.entries) {
        final collectionName = entry.key;
        final List<dynamic> documents = entry.value;

        await _restoreCollectionInBatches(collectionName, documents);
      }
      
      if (kDebugMode) debugPrint('✅ System Restoration Complete');
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Restore failed: $e');
      rethrow;
    }
  }

  /// Helper to write documents in batches of 100 (Safe limit)
  Future<void> _restoreCollectionInBatches(String collectionName, List<dynamic> docs) async {
    const int batchSize = 100;
    
    for (var i = 0; i < docs.length; i += batchSize) {
      final batch = _db.batch();
      final chunk = docs.skip(i).take(batchSize);

      for (var docData in chunk) {
        final Map<String, dynamic> data = Map<String, dynamic>.from(docData);
        final id = data.remove('id');
        final docRef = _db.collection(collectionName).doc(id);
        batch.set(docRef, data, SetOptions(merge: false)); // Overwrite with backup
      }

      await batch.commit();
      if (kDebugMode) debugPrint('Restored $batchSize docs to $collectionName');
    }
  }

  static Future<void> performBackgroundBackup(String uid) async {
    // For background tasks, ensure the master key is retrieved securely
    // e.g., from flutter_secure_storage or a safe environment variable.
    const masterKey = 'REPLACE_WITH_SECURELY_LOADED_KEY_32CHARS';
    final service = BackupService(masterKey);
    await service.performFullBackup(uid);
  }

  Stream<List<Map<String, dynamic>>> getBackupHistory() {
    return _db.collection('backups')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList());
  }
}
