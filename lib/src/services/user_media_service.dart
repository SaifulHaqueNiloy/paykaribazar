import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../shared/services/media_service.dart';

class UserMediaService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final MediaService _mediaService;

  UserMediaService(this._mediaService);

  /// Get storage quota in bytes based on points and role
  int getQuotaLimit(int points, String role) {
    if (role == 'admin') return 5 * 1024 * 1024 * 1024; // 5 GB
    if (points >= 5000) return 500 * 1024 * 1024; // 500 MB (Platinum)
    if (points >= 2500) return 250 * 1024 * 1024; // 250 MB (Gold)
    if (points >= 1000) return 100 * 1024 * 1024; // 100 MB (Silver)
    return 50 * 1024 * 1024; // 50 MB (Bronze)
  }

  /// Get user's currently used storage from Firestore
  Future<int> getUsedStorage(String userId) async {
    final doc = await _db.collection('users').doc(userId).get();
    if (!doc.exists) return 0;
    return (doc.data()?['usedStorage'] ?? 0).toInt();
  }

  /// Upload file to Cloudinary with quota check
  Future<String?> uploadUserMedia(String userId, File file, String fileName, int points, String role) async {
    try {
      final int fileSize = await file.length();
      final int used = await getUsedStorage(userId);
      final int limit = getQuotaLimit(points, role);

      if (used + fileSize > limit) {
        throw Exception('Storage quota exceeded! Please free up space.');
      }

      // Upload to Cloudinary under user_backups folder
      final url = await _mediaService.uploadToCloudinary(file, folder: 'user_backups/$userId');
      if (url == null) throw Exception('Upload to Cloudinary failed.');

      // Save media metadata to Firestore
      final mediaId = _db.collection('user_media').doc().id;
      await _db.collection('user_media').doc(mediaId).set({
        'id': mediaId,
        'userId': userId,
        'fileName': fileName,
        'fileUrl': url,
        'fileSize': fileSize,
        'mimeType': fileName.toLowerCase().endsWith('.mp4') ? 'video/mp4' : 'image/jpeg',
        'uploadedAt': FieldValue.serverTimestamp(),
      });

      // Update used storage in users document
      await _db.collection('users').doc(userId).update({
        'usedStorage': FieldValue.increment(fileSize),
      });

      return url;
    } catch (e) {
      if (kDebugMode) debugPrint('Error in uploadUserMedia: $e');
      rethrow;
    }
  }

  /// Delete file from Firestore and decrement usedStorage
  Future<void> deleteUserMedia(String userId, String mediaId, int fileSize) async {
    try {
      // 1. Delete from user_media collection
      await _db.collection('user_media').doc(mediaId).delete();

      // 2. Decrement usedStorage in users collection
      await _db.collection('users').doc(userId).update({
        'usedStorage': FieldValue.increment(-fileSize),
      });
    } catch (e) {
      if (kDebugMode) debugPrint('Error in deleteUserMedia: $e');
      rethrow;
    }
  }

  /// Get stream of all uploaded media documents for a user
  Stream<List<Map<String, dynamic>>> getUserMediaStream(String userId) {
    return _db.collection('user_media')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snap) {
          final list = snap.docs.map((doc) => doc.data()).toList();
          // Sort locally by uploadedAt descending (safeguards against missing composite index)
          list.sort((a, b) {
            final aTime = a['uploadedAt'] as Timestamp?;
            final bTime = b['uploadedAt'] as Timestamp?;
            if (aTime == null || bTime == null) return 0;
            return bTime.compareTo(aTime);
          });
          return list;
        });
  }

  /// Simulate background media sync task
  Future<void> runAutomaticBackup(String userId, int points, String role) async {
    try {
      // For simulation: Pick a small dummy file or dummy bytes, save it temporarily and upload
      final dir = await Directory.systemTemp.createTemp('pb_autobackup');
      final tempFile = File('${dir.path}/simulated_photo_${DateTime.now().millisecondsSinceEpoch}.jpg');
      await tempFile.writeAsBytes(List.generate(1024 * 100, (index) => 0)); // 100 KB dummy file

      await uploadUserMedia(userId, tempFile, tempFile.path.split('/').last, points, role);
    } catch (e) {
      if (kDebugMode) debugPrint('Automatic Backup Error: $e');
    }
  }
}
