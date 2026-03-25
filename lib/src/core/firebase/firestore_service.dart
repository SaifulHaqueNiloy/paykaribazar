import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/services/media_service.dart';
import '../../di/service_locator.dart';
import '../constants/paths.dart';
import '../exceptions/app_exceptions.dart';

final _db = FirebaseFirestore.instance;
final _storage = FirebaseStorage.instance;

// --- GLOBAL PROVIDERS FOR UI COMPATIBILITY ---
final allUsersProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  return _db.collection(HubPaths.users).snapshots().map((snap) =>
      snap.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList());
});

final storesProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  return _db.collection(HubPaths.stores).orderBy('order').snapshots().map(
      (snap) => snap.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList());
});

final locationsProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  return _db.collection(HubPaths.locations).snapshots().map((snap) =>
      snap.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList());
});

final firestoreServiceProvider = Provider((ref) => getIt<FirestoreService>());

class FirestoreService {
  // --- CORE DATABASE METHODS ---

  Future<String> addDocument(String collection, Map<String, dynamic> data) async {
    try {
      final doc = await _db.collection(collection).add({
        ...data,
        'createdAt': FieldValue.serverTimestamp(),
      });
      await doc.update({'id': doc.id});
      return doc.id;
    } catch (e) {
      throw FirestoreException('Failed to add document to $collection: $e', details: e);
    }
  }

  Future<void> updateDocument(String collection, String id, Map<String, dynamic> data) async {
    try {
      await _db.collection(collection).doc(id).update({
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw FirestoreException('Failed to update document in $collection: $e', details: e);
    }
  }

  Future<void> updateProfile(String uid, Map<String, dynamic> data) async {
    try {
      await _db
          .collection(HubPaths.users)
          .doc(uid)
          .update({...data, 'updatedAt': FieldValue.serverTimestamp()});
    } catch (e) {
      throw FirestoreException('Failed to update profile: $e', details: e);
    }
  }

  Future<void> updateGeneric(
      String collection, String id, Map<String, dynamic> data) async {
    try {
      await _db
          .collection(collection)
          .doc(id)
          .set(data, SetOptions(merge: true));
    } catch (e) {
      throw FirestoreException('Failed to update $collection: $e', details: e);
    }
  }

  // --- ORDERS ---

  Future<String> placeOrder(Map<String, dynamic> data) async {
    try {
      final doc = await _db
          .collection(HubPaths.orders)
          .add({...data, 'createdAt': FieldValue.serverTimestamp()});
      await doc.update({'id': doc.id});
      return doc.id;
    } catch (e) {
      throw FirestoreException('Failed to place order: $e', details: e);
    }
  }

  Future<String> placeMedicineOrder(Map<String, dynamic> data) async {
    return await placeOrder(
        {...data, 'orderType': 'medicine', 'isEmergency': true});
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    try {
      await _db.collection(HubPaths.orders).doc(orderId).update(
          {'status': status, 'updatedAt': FieldValue.serverTimestamp()});
    } catch (e) {
      throw FirestoreException('Failed to update order status: $e', details: e);
    }
  }

  Future<void> assignOrder(
      String orderId, String riderUid, String riderName) async {
    try {
      await _db.collection(HubPaths.orders).doc(orderId).update({
        'riderUid': riderUid,
        'riderName': riderName,
        'status': 'Processing',
        'assignedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw FirestoreException('Failed to assign order: $e', details: e);
    }
  }

  // --- PRODUCTS ---

  Future<void> addProduct(Map<String, dynamic> data) async {
    try {
      final doc = await _db
          .collection(HubPaths.products)
          .add({...data, 'createdAt': FieldValue.serverTimestamp()});
      await doc.update({'id': doc.id});
    } catch (e) {
      throw FirestoreException('Failed to add product: $e', details: e);
    }
  }

  Future<void> updateProduct(String id, Map<String, dynamic> data) async {
    try {
      await _db
          .collection(HubPaths.products)
          .doc(id)
          .update({...data, 'updatedAt': FieldValue.serverTimestamp()});
    } catch (e) {
      throw FirestoreException('Failed to update product: $e', details: e);
    }
  }

  Future<void> deleteProduct(String id) async {
    try {
      await _db.collection(HubPaths.products).doc(id).delete();
    } catch (e) {
      throw FirestoreException('Failed to delete product: $e', details: e);
    }
  }

  Future<void> toggleWishlist(String uid, String productId) async {
    try {
      final doc = _db
          .collection(HubPaths.users)
          .doc(uid)
          .collection('wishlist')
          .doc(productId);
      final snap = await doc.get();
      if (snap.exists) {
        await doc.delete();
      } else {
        await doc.set(
            {'productId': productId, 'addedAt': FieldValue.serverTimestamp()});
      }
    } catch (e) {
      throw FirestoreException('Failed to toggle wishlist: $e', details: e);
    }
  }

  // --- CATEGORIES ---

  Future<void> addCategory(Map<String, dynamic> data) async {
    try {
      final doc = await _db
          .collection(HubPaths.categories)
          .add({...data, 'createdAt': FieldValue.serverTimestamp()});
      await doc.update({'id': doc.id});
    } catch (e) {
      throw FirestoreException('Failed to add category: $e', details: e);
    }
  }

  Future<void> updateCategory(String id, Map<String, dynamic> data) async {
    try {
      await _db.collection(HubPaths.categories).doc(id).update(data);
    } catch (e) {
      throw FirestoreException('Failed to update category: $e', details: e);
    }
  }

  Future<void> updateCategoryOrder(String id, int order) async {
    try {
      await _db
          .collection(HubPaths.categories)
          .doc(id)
          .update({'order': order});
    } catch (e) {
      throw FirestoreException('Failed to update category order: $e',
          details: e);
    }
  }

  Future<void> deleteCategory(String id) async {
    try {
      await _db.collection(HubPaths.categories).doc(id).delete();
    } catch (e) {
      throw FirestoreException('Failed to delete category: $e', details: e);
    }
  }

  // --- STORES & LOCATIONS ---

  Future<void> addStore(Map<String, dynamic> data) async {
    try {
      final doc = await _db.collection(HubPaths.stores).add(data);
      await doc.update({'id': doc.id});
    } catch (e) {
      throw FirestoreException('Failed to add store: $e', details: e);
    }
  }

  Future<void> updateStore(String id, Map<String, dynamic> data) async {
    try {
      await _db.collection(HubPaths.stores).doc(id).update(data);
    } catch (e) {
      throw FirestoreException('Failed to update store: $e', details: e);
    }
  }

  Future<void> updateStoreOrder(String id, int order) async {
    try {
      await _db.collection(HubPaths.stores).doc(id).update({'order': order});
    } catch (e) {
      throw FirestoreException('Failed to update store order: $e', details: e);
    }
  }

  Future<void> deleteStore(String id) async {
    try {
      await _db.collection(HubPaths.stores).doc(id).delete();
    } catch (e) {
      throw FirestoreException('Failed to delete store: $e', details: e);
    }
  }

  Future<void> addLocation(Map<String, dynamic> data) async {
    try {
      final doc = await _db.collection(HubPaths.locations).add(data);
      await doc.update({'id': doc.id});
    } catch (e) {
      throw FirestoreException('Failed to add location: $e', details: e);
    }
  }

  Future<void> updateLocation(String id, Map<String, dynamic> data) async {
    try {
      await _db.collection(HubPaths.locations).doc(id).update(data);
    } catch (e) {
      throw FirestoreException('Failed to update location: $e', details: e);
    }
  }

  Future<void> deleteLocation(String id) async {
    try {
      await _db.collection(HubPaths.locations).doc(id).delete();
    } catch (e) {
      throw FirestoreException('Failed to delete location: $e', details: e);
    }
  }

  // --- SPECIAL & BATCH OPERATIONS ---

  Future<void> performBatchUpdate(
      List<Map<String, dynamic>> updates, String collection) async {
    try {
      final batch = _db.batch();
      for (var update in updates) {
        final docRef = _db.collection(collection).doc(update['id']);
        batch.update(docRef, update['data']);
      }
      await batch.commit();
    } catch (e) {
      throw FirestoreException('Failed to perform batch update: $e',
          details: e);
    }
  }

  // --- SYSTEM SETTINGS ---

  Future<void> updateLoyaltySettings(Map<String, dynamic> data) async {
    try {
      await _db.doc(HubPaths.loyaltyDoc).set(data, SetOptions(merge: true));
    } catch (e) {
      throw FirestoreException('Failed to update loyalty settings: $e',
          details: e);
    }
  }

  Future<void> updateAppSettings(String doc, Map<String, dynamic> data) async {
    try {
      await _db
          .collection('settings')
          .doc(doc)
          .set(data, SetOptions(merge: true));
    } catch (e) {
      throw FirestoreException('Failed to update app settings: $e', details: e);
    }
  }

  Future<void> updateAppConfig(Map<String, dynamic> data) async {
    try {
      await _db.doc(HubPaths.configDoc).set(data, SetOptions(merge: true));
    } catch (e) {
      throw FirestoreException('Failed to update app config: $e', details: e);
    }
  }

  Future<void> updateSecrets(Map<String, dynamic> data) async {
    try {
      await _db.doc(HubPaths.secretsDoc).set(data, SetOptions(merge: true));
    } catch (e) {
      throw FirestoreException('Failed to update secrets: $e', details: e);
    }
  }

  Future<void> updateLocalization(Map<String, dynamic> data) async {
    try {
      await _db
          .doc(HubPaths.localizationDoc)
          .set(data, SetOptions(merge: true));
    } catch (e) {
      throw FirestoreException('Failed to update localization: $e', details: e);
    }
  }

  Stream<Map<String, dynamic>> watchLocalization() {
    return _db.doc(HubPaths.localizationDoc).snapshots().map((snap) {
      final data = snap.data();
      return data != null ? Map<String, dynamic>.from(data) : {};
    });
  }

  Future<void> updateResellerAppStatus(String id, String status,
      {String? uid, String? shopName}) async {
    try {
      await _db.collection('reseller_applications').doc(id).update({
        'status': status,
        'processedAt': FieldValue.serverTimestamp(),
      });
      if (status == 'Approved' && uid != null) {
        await updateProfile(uid, {'role': 'reseller', 'shopName': shopName});
      }
    } catch (e) {
      throw FirestoreException('Failed to update reseller app status: $e',
          details: e);
    }
  }

  Future<void> registerAsDonor(Map<String, dynamic> data) async {
    try {
      await _db.collection(HubPaths.donors).add(
          {...data, 'type': 'donor', 'createdAt': FieldValue.serverTimestamp()});
    } catch (e) {
      throw FirestoreException('Failed to register as donor: $e', details: e);
    }
  }

  Future<void> markCommissionPaid(String id) async {
    try {
      await _db
          .collection(HubPaths.staffCommissions)
          .doc(id)
          .update({'status': 'Paid', 'paidAt': FieldValue.serverTimestamp()});
    } catch (e) {
      throw FirestoreException('Failed to mark commission paid: $e',
          details: e);
    }
  }

  // --- ASYNC IMAGE UPLOAD ---

  Future<String?> uploadImage(File file, String folder) async {
    try {
      final media = getIt<MediaService>();
      return await media.uploadToCloudinary(file, folder: folder);
    } catch (e) {
      try {
        final ref = _storage
            .ref()
            .child('uploads/$folder/${DateTime.now().millisecondsSinceEpoch}');
        await ref.putFile(file);
        return await ref.getDownloadURL();
      } catch (e2) {
        throw AppException('Failed to upload image: $e2', details: e2);
      }
    }
  }
}
