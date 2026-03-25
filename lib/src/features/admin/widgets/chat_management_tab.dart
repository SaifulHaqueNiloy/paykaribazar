import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../di/providers.dart';
import '../../../utils/styles.dart';

class ChatManagementTab extends ConsumerStatefulWidget {
  const ChatManagementTab({super.key});
  @override
  ConsumerState<ChatManagementTab> createState() => _ChatManagementTabState();
}

class _ChatManagementTabState extends ConsumerState<ChatManagementTab> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection(HubPaths.privateChats)
            .orderBy('lastUpdate', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final chats = snapshot.data!.docs;
          if (chats.isEmpty) return const Center(child: Text('No active chats.'));

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: chats.length,
            separatorBuilder: (c, i) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final chat = chats[index].data() as Map<String, dynamic>;
              final isStaffChat = chat['type'] == 'staff_customer';
              
              return Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isStaffChat ? Colors.teal : Colors.orange,
                    child: Icon(isStaffChat ? Icons.support_agent : Icons.person, color: Colors.white),
                  ),
                  title: Text(chat['receiverName'] ?? chat['customerName'] ?? 'User', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(chat['lastMessage'] ?? '...', maxLines: 1, overflow: TextOverflow.ellipsis),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showChatDetail(chats[index].id, chat),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showChatDetail(String chatId, Map<String, dynamic> chat) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AdminChatDetailSheet(chatId: chatId, chatData: chat),
    );
  }
}

class _AdminChatDetailSheet extends ConsumerStatefulWidget {
  final String chatId;
  final Map<String, dynamic> chatData;
  const _AdminChatDetailSheet({required this.chatId, required this.chatData});

  @override
  ConsumerState<_AdminChatDetailSheet> createState() => _AdminChatDetailSheetState();
}

class _AdminChatDetailSheetState extends ConsumerState<_AdminChatDetailSheet> {
  final _msgCtrl = TextEditingController();
  bool _isAiBusy = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: isDark ? AppStyles.darkBackgroundColor : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(children: [
        Row(
          children: [
            IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
            const SizedBox(width: 10),
            Text("Chat with ${widget.chatData['receiverName'] ?? 'User'}",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
        const Divider(),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection(HubPaths.privateChats)
                .doc(widget.chatId)
                .collection('messages')
                .orderBy('timestamp', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              final msgs = snapshot.data!.docs;
              return ListView.builder(
                reverse: true,
                itemCount: msgs.length,
                itemBuilder: (context, i) {
                  final m = msgs[i].data() as Map<String, dynamic>;
                  final isMe = m['senderId'] == 'admin'; // Admin ID check
                  return _buildBubble(m['text'] ?? '', isMe);
                },
              );
            }
          ),
        ),
        if (_isAiBusy) const LinearProgressIndicator(minHeight: 2),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(
            child: TextField(
              controller: _msgCtrl,
              decoration: AppStyles.inputDecoration('Admin Response...', isDark),
            )
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.auto_awesome, color: Colors.teal),
            tooltip: 'Get AI Suggestion',
            onPressed: _isAiBusy ? null : _getAiSuggestion,
          ),
          IconButton(
            icon: const Icon(Icons.send, color: AppStyles.primaryColor),
            onPressed: _sendMessage,
          ),
        ]),
      ]),
    );
  }

  Widget _buildBubble(String text, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isMe ? AppStyles.primaryColor : Colors.grey[200],
          borderRadius: BorderRadius.circular(15),
        ),
        child: Text(text, style: TextStyle(color: isMe ? Colors.white : Colors.black87, fontSize: 13)),
      ),
    );
  }

  void _getAiSuggestion() async {
    final lastMsg = widget.chatData['lastMessage'] ?? '';
    if (lastMsg.isEmpty) return;

    setState(() => _isAiBusy = true);
    final prompt = "You are customer support for Paykari Bazar. Provide a professional Bengali reply to this message: '$lastMsg'";
    try {
      final reply = await ref.read(aiServiceProvider).generateResponse(prompt);
      setState(() => _msgCtrl.text = reply);
    } finally {
      setState(() => _isAiBusy = false);
    }
  }

  void _sendMessage() async {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty) return;

    await FirebaseFirestore.instance
        .collection(HubPaths.privateChats)
        .doc(widget.chatId)
        .collection('messages')
        .add({
      'text': text,
      'senderId': 'admin',
      'timestamp': FieldValue.serverTimestamp(),
    });

    await FirebaseFirestore.instance
        .collection(HubPaths.privateChats)
        .doc(widget.chatId)
        .update({
      'lastMessage': text,
      'lastUpdate': FieldValue.serverTimestamp(),
    });

    _msgCtrl.clear();
  }
}
