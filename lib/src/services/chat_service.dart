import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../di/service_locator.dart';
import '../features/ai/services/ai_service.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<Map<String, dynamic>>> getMessages(String chatRoomId) {
    return _firestore
        .collection('private_chats')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((doc) {
              final data = doc.data();
              data['id'] = doc.id;
              return data;
            }).toList());
  }

  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String text,
    required String receiverName,
    required bool isStaffChat,
    String? receiverId,
    String? imageUrl,
  }) async {
    final chatRef = _firestore.collection('private_chats').doc(chatId);
    
    // Add message to sub-collection
    await chatRef.collection('messages').add({
      'text': text,
      'imageUrl': imageUrl,
      'senderId': senderId,
      'timestamp': FieldValue.serverTimestamp(),
      'status': 'sent',
    });

    // Update chat room metadata
    final Map<String, dynamic> data = {
      'chatId': chatId,
      'lastMessage': imageUrl != null ? '📷 Image' : text,
      'lastUpdate': FieldValue.serverTimestamp(),
      'type': isStaffChat ? 'staff_customer' : 'customer_customer',
      'lastSenderId': senderId,
    };

    if (receiverId != null) {
      data['participantIds'] = FieldValue.arrayUnion([senderId, receiverId]);
      // Increment unread count for the receiver
      data['unreadCount_$receiverId'] = FieldValue.increment(1);
    }

    if (isStaffChat) {
      data['customerName'] = receiverName;
      data['staffId'] = isStaffChat ? receiverId : senderId; 
      data['customerId'] = isStaffChat ? senderId : receiverId;
    } else {
      data['receiverName'] = receiverName;
      data['customerId'] = senderId; 
    }

    await chatRef.set(data, SetOptions(merge: true));
  }

  Future<void> markAsRead(String chatId, String userId) async {
    await _firestore.collection('private_chats').doc(chatId).update({
      'unreadCount_$userId': 0,
    });
  }

  Future<String> getOrCreateChatId(String uid1, String uid2) async {
    final List<String> ids = [uid1, uid2];
    ids.sort();
    return ids.join('_');
  }

  Future<void> initiateChat({
    required String senderId,
    required String receiverId,
    required String receiverName,
    required String senderName,
    bool isStaffChat = false,
  }) async {
    final chatId = await getOrCreateChatId(senderId, receiverId);
    final chatRef = _firestore.collection('private_chats').doc(chatId);
    
    await chatRef.set({
      'chatId': chatId,
      'participantIds': [senderId, receiverId],
      'type': isStaffChat ? 'staff_customer' : 'customer_customer',
      'receiverName': receiverName,
      'senderName': senderName,
      'lastUpdate': FieldValue.serverTimestamp(),
      'customerId': senderId,
      'staffId': isStaffChat ? receiverId : null,
      'customerName': isStaffChat ? senderName : null,
    }, SetOptions(merge: true));
  }

  Future<List<String>> getSmartReplies(String lastMessage, bool isStaff) async {
    try {
      final ai = getIt<AIService>();
      final prompt = isStaff 
          ? "You are a support staff at Paykari Bazar. The customer said: '$lastMessage'. Suggest 3 short, professional quick replies in Bengali. Return only a JSON array of strings."
          : "You are a customer at Paykari Bazar. The seller said: '$lastMessage'. Suggest 3 short, natural quick replies in Bengali. Return only a JSON array of strings.";
      
      final response = await ai.generateResponse(prompt);
      final clean = response.replaceAll('```json', '').replaceAll('```', '').trim();
      return List<String>.from(jsonDecode(clean));
    } catch (e) {
      return isStaff 
          ? ['আমি দেখছি', 'ধন্যবাদ', 'একটু অপেক্ষা করুন'] 
          : ['দাম কত?', 'স্টক আছে?', 'ধন্যবাদ'];
    }
  }
}
