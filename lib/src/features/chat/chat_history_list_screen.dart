import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../di/providers.dart';
import '../../utils/styles.dart';

class ChatHistoryListScreen extends ConsumerStatefulWidget {
  const ChatHistoryListScreen({super.key});

  @override
  ConsumerState<ChatHistoryListScreen> createState() => _ChatHistoryListScreenState();
}

class _ChatHistoryListScreenState extends ConsumerState<ChatHistoryListScreen> {
  String _searchQuery = '';
  final _searchCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final u = FirebaseAuth.instance.currentUser;
    final isD = Theme.of(context).brightness == Brightness.dark;

    if (u == null) return const Scaffold(body: Center(child: Text('Please login')));

    return Scaffold(
      backgroundColor: isD ? AppStyles.darkBackgroundColor : const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('মেসেজ হিস্ট্রি', style: TextStyle(fontWeight: FontWeight.bold)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) => setState(() => _searchQuery = v.trim().toLowerCase()),
              decoration: InputDecoration(
                hintText: 'চ্যাট বা ব্যবহারকারী খুঁজুন...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: isD ? AppStyles.darkSurfaceColor : Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(),
              ),
            ),
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('private_chats')
            .where('participantIds', arrayContains: u.uid)
            .orderBy('lastUpdate', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          
          final docs = snapshot.data?.docs ?? [];
          final filtered = docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final name = (data['receiverName'] ?? '').toString().toLowerCase();
            final lastMsg = (data['lastMessage'] ?? '').toString().toLowerCase();
            return name.contains(_searchQuery) || lastMsg.contains(_searchQuery);
          }).toList();

          if (filtered.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat_bubble_outline_rounded, size: 64, color: Colors.grey.withOpacity(0.3)),
                  const SizedBox(height: 16),
                  const Text('কোনো চ্যাট পাওয়া যায়নি', style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              final data = filtered[index].data() as Map<String, dynamic>;
              final otherUserId = (data['participantIds'] as List).firstWhere((id) => id != u.uid);
              final name = data['receiverName'] ?? 'User';
              final lastMsg = data['lastMessage'] ?? '';
              final time = data['lastUpdate'] != null 
                  ? DateFormat('hh:mm a').format((data['lastUpdate'] as Timestamp).toDate()) 
                  : '';
              final unreadCount = data['unreadCount_${u.uid}'] ?? 0;

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppStyles.primaryColor.withOpacity(0.1),
                  child: Text(name[0].toUpperCase(), style: const TextStyle(color: AppStyles.primaryColor, fontWeight: FontWeight.bold)),
                ),
                title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(lastMsg, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: unreadCount > 0 ? (isD ? Colors.white : Colors.black) : Colors.grey)),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(time, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                    if (unreadCount > 0)
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                        child: Text('$unreadCount', style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
                      ),
                  ],
                ),
                onTap: () => context.push('/private-chat?chatId=${data['chatId']}&name=$name&receiverId=$otherUserId&isStaff=${data['type'] == 'staff_customer'}'),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showUserSearch(context),
        backgroundColor: AppStyles.primaryColor,
        child: const Icon(Icons.person_add_alt_1_rounded, color: Colors.white),
      ),
    );
  }

  void _showUserSearch(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const UserSearchSheet(),
    );
  }
}

class UserSearchSheet extends ConsumerStatefulWidget {
  const UserSearchSheet({super.key});
  @override
  ConsumerState<UserSearchSheet> createState() => _UserSearchSheetState();
}

class _UserSearchSheetState extends ConsumerState<UserSearchSheet> {
  String _query = '';
  @override
  Widget build(BuildContext context) {
    final isD = Theme.of(context).brightness == Brightness.dark;
    final currentU = FirebaseAuth.instance.currentUser;

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: isD ? AppStyles.darkBackgroundColor : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Text('ব্যবহারকারী খুঁজুন', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          TextField(
            onChanged: (v) => setState(() => _query = v.trim().toLowerCase()),
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'নাম বা ফোন নম্বর দিয়ে খুঁজুন...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: isD ? AppStyles.darkSurfaceColor : Colors.grey[100],
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('users').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                
                final users = snapshot.data!.docs.where((doc) {
                  final d = doc.data() as Map<String, dynamic>;
                  final name = (d['name'] ?? '').toString().toLowerCase();
                  final phone = (d['phone'] ?? '').toString();
                  final uid = doc.id;
                  return uid != currentU?.uid && (name.contains(_query) || phone.contains(_query));
                }).toList();

                return ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, i) {
                    final d = users[i].data() as Map<String, dynamic>;
                    return ListTile(
                      leading: CircleAvatar(backgroundImage: d['profilePic'] != null ? NetworkImage(d['profilePic']) : null),
                      title: Text(d['name'] ?? 'User'),
                      subtitle: Text(d['phone'] ?? ''),
                      onTap: () async {
                        final otherId = users[i].id;
                        final chatId = await ref.read(chatServiceProvider).getOrCreateChatId(currentU!.uid, otherId);
                        
                        await ref.read(chatServiceProvider).initiateChat(
                          senderId: currentU.uid,
                          receiverId: otherId,
                          receiverName: d['name'] ?? 'User',
                          senderName: currentU.displayName ?? 'Customer',
                        );

                        if (context.mounted) {
                          Navigator.pop(context);
                          context.push('/private-chat?chatId=$chatId&name=${d['name']}&receiverId=$otherId&isStaff=false');
                        }
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
