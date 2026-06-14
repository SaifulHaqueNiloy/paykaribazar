import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:photo_manager/photo_manager.dart';
import '../shared/services/media_service.dart';

class UserMediaService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final MediaService _mediaService;

  UserMediaService(this._mediaService);

  /// Get storage quota in bytes from user data
  int getQuotaLimit(Map<String, dynamic>? userData) {
    if (userData != null && userData['storageLimit'] != null) {
      return (userData['storageLimit'] as num).toInt();
    }
    return 50 * 1024 * 1024; // Default fallback 50 MB
  }

  /// Get user's currently used storage from Firestore
  Future<int> getUsedStorage(String userId) async {
    final doc = await _db.collection('users').doc(userId).get();
    if (!doc.exists) return 0;
    return (doc.data()?['usedStorage'] ?? 0).toInt();
  }

  /// Upload file to Cloudinary with quota check
  Future<String?> uploadUserMedia(String userId, File file, String fileName, {String? localId}) async {
    final int fileSize = await file.length();
    bool spaceReserved = false;

    try {
      // 1. Reserve space in users collection using Transaction to prevent race conditions
      await _db.runTransaction((transaction) async {
        final userRef = _db.collection('users').doc(userId);
        final userSnap = await transaction.get(userRef);
        if (!userSnap.exists) throw Exception('User not found');

        final userData = userSnap.data() ?? {};
        final int used = (userData['usedStorage'] ?? 0).toInt();
        final int limit = getQuotaLimit(userData);

        if (used + fileSize > limit) {
          throw Exception('Storage quota exceeded! Please free up space.');
        }

        transaction.update(userRef, {
          'usedStorage': FieldValue.increment(fileSize),
        });
      });
      spaceReserved = true;

      // 2. Upload to Cloudinary under user_backups folder
      final url = await _mediaService.uploadToCloudinary(file, folder: 'user_backups/$userId');
      if (url == null) throw Exception('Upload to Cloudinary failed.');

      // 3. Save media metadata to Firestore
      final mediaId = _db.collection('user_media').doc().id;
      await _db.collection('user_media').doc(mediaId).set({
        'id': mediaId,
        'userId': userId,
        'fileName': fileName,
        'fileUrl': url,
        'fileSize': fileSize,
        'mimeType': fileName.toLowerCase().endsWith('.mp4') ? 'video/mp4' : 'image/jpeg',
        'uploadedAt': FieldValue.serverTimestamp(),
        if (localId != null) 'localId': localId,
      });

      return url;
    } catch (e) {
      if (spaceReserved) {
        // Rollback reserved space if upload failed
        try {
          await _db.collection('users').doc(userId).update({
            'usedStorage': FieldValue.increment(-fileSize),
          });
        } catch (rollbackError) {
          if (kDebugMode) debugPrint('Rollback failed: $rollbackError');
        }
      }
      if (kDebugMode) debugPrint('Error in uploadUserMedia: $e');
      rethrow;
    }
  }

  /// Delete file from Firestore and decrement usedStorage
  Future<void> deleteUserMedia(String userId, String mediaId, int fileSize, String fileUrl) async {
    try {
      // 1. Delete from Cloudinary first
      await _mediaService.deleteFromCloudinary(fileUrl);

      // 2. Delete from user_media collection
      await _db.collection('user_media').doc(mediaId).delete();

      // 3. Decrement usedStorage in users collection
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

  /// Scans local gallery files from newest to oldest and uploads them until user quota is exceeded.
  Future<void> runAutomaticBackup(String userId) async {
    try {
      // 1. Request/verify permissions
      final PermissionState ps = await PhotoManager.requestPermissionExtend();
      if (!ps.isAuth) {
        if (kDebugMode) debugPrint('PhotoManager permission not granted.');
        return;
      }

      // 2. Fetch the root/all media album
      final List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
        type: RequestType.common,
      );
      if (albums.isEmpty) return;

      // 3. Fetch the latest 50 media assets
      final List<AssetEntity> assets = await albums.first.getAssetListRange(start: 0, end: 50);

      // 4. Iterate assets, check if already backed up, and upload
      for (final asset in assets) {
        final localId = asset.id;

        final existing = await _db.collection('user_media')
            .where('userId', isEqualTo: userId)
            .where('localId', isEqualTo: localId)
            .limit(1)
            .get();

        if (existing.docs.isNotEmpty) {
          // Already backed up, skip this asset
          continue;
        }

        final file = await asset.file;
        if (file == null) continue;

        try {
          await uploadUserMedia(
            userId,
            file,
            (asset.title != null && asset.title!.isNotEmpty) ? asset.title! : 'media_$localId',
            localId: localId,
          );
          if (kDebugMode) debugPrint('Auto backed up asset: $localId');
        } catch (e) {
          if (e.toString().contains('Storage quota exceeded')) {
            if (kDebugMode) debugPrint('Auto backup stopped: storage quota reached.');
            break; // Stop loop when limit is reached
          }
          if (kDebugMode) debugPrint('Failed auto backup for asset $localId: $e');
        }
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Automatic Backup Error: $e');
    }
  }

  /// Recalculates total used storage from user_media and updates user document to ensure consistency
  Future<int> recalculateAndSyncUsedStorage(String userId) async {
    try {
      final snap = await _db.collection('user_media')
          .where('userId', isEqualTo: userId)
          .get();
      
      int totalSize = 0;
      for (var doc in snap.docs) {
        totalSize += ((doc.data()['fileSize'] ?? 0) as num).toInt();
      }

      await _db.collection('users').doc(userId).update({
        'usedStorage': totalSize,
      });

      return totalSize;
    } catch (e) {
      if (kDebugMode) debugPrint('Sync Storage Error: $e');
      rethrow;
    }
  }
}
