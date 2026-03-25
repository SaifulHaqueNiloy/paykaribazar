import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../di/providers.dart';
import '../../../services/notice_service.dart';

class NoticeManagementTab extends ConsumerStatefulWidget {
  const NoticeManagementTab({super.key});

  @override
  ConsumerState<NoticeManagementTab> createState() => _NoticeManagementTabState();
}

class _NoticeManagementTabState extends ConsumerState<NoticeManagementTab> {
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();
  final _imageController = TextEditingController();

  void _submit() {
    if (_titleController.text.isEmpty || _messageController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Title and Message are required')));
      return;
    }
    ref.read(noticeServiceProvider).addNotice(
      _titleController.text,
      _messageController.text,
      _imageController.text.isEmpty ? null : _imageController.text,
    );
    _titleController.clear();
    _messageController.clear();
    _imageController.clear();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Notice added successfully')));
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Add New Notice', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          TextField(controller: _titleController, decoration: const InputDecoration(labelText: 'Title', border: OutlineInputBorder())),
          const SizedBox(height: 10),
          TextField(controller: _messageController, decoration: const InputDecoration(labelText: 'Message', border: OutlineInputBorder()), maxLines: 3),
          const SizedBox(height: 10),
          TextField(controller: _imageController, decoration: const InputDecoration(labelText: 'Image URL (Optional)', border: OutlineInputBorder())),
          const SizedBox(height: 15),
          SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _submit, child: const Text('Add Notice'))),
          const Divider(height: 40),
          const Text('Existing Notices', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          StreamBuilder<List<NoticeModel>>(
            stream: ref.watch(noticeServiceProvider).getNotices(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const CircularProgressIndicator();
              final notices = snapshot.data!;
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: notices.length,
                itemBuilder: (context, index) {
                  final notice = notices[index];
                  return Card(
                    child: ListTile(
                      leading: notice.imageUrl != null 
                        ? Image.network(notice.imageUrl!, width: 50, height: 50, fit: BoxFit.cover)
                        : const Icon(Icons.campaign),
                      title: Text(notice.title),
                      subtitle: Text(notice.message, maxLines: 1, overflow: TextOverflow.ellipsis),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => ref.read(noticeServiceProvider).deleteNotice(notice.id),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
