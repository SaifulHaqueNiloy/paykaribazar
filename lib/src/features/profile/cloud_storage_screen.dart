import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../di/providers.dart';
import '../../utils/styles.dart';

// Riverpod StateProvider to persist Auto-Backup setting locally in memory (can link to SharedPreferences)
final autoBackupEnabledProvider = StateProvider<bool>((ref) => false);

class CloudStorageScreen extends ConsumerStatefulWidget {
  const CloudStorageScreen({super.key});

  @override
  ConsumerState<CloudStorageScreen> createState() => _CloudStorageScreenState();
}

class _CloudStorageScreenState extends ConsumerState<CloudStorageScreen> {
  bool _isUploading = false;

  String _formatSize(int bytes) {
    if (bytes <= 0) return '0 B';
    const suffixes = ['B', 'KB', 'MB', 'GB'];
    var i = 0;
    double size = bytes.toDouble();
    while (size >= 1024 && i < suffixes.length - 1) {
      size /= 1024;
      i++;
    }
    return '${size.toStringAsFixed(1)} ${suffixes[i]}';
  }

  Future<void> _handleUpload() async {
    final user = ref.read(currentUserDataProvider).value;
    final authUser = ref.read(authStateProvider).value;
    if (user == null || authUser == null) return;

    final mediaService = ref.read(mediaServiceProvider);
    final userMediaService = ref.read(userMediaServiceProvider);

    setState(() => _isUploading = true);
    try {
      final file = await mediaService.pickImage();
      if (file == null) {
        setState(() => _isUploading = false);
        return;
      }

      final fileName = file.path.split('/').last;
      final int points = (user['points'] ?? 0).toInt();
      final String role = user['role'] ?? 'customer';

      await userMediaService.uploadUserMedia(authUser.uid, file, fileName, points, role);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('মিডিয়া ফাইল সফলভাবে ক্লাউডে ব্যাকআপ করা হয়েছে।'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('আপলোড ব্যর্থ হয়েছে: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  Future<void> _handleDelete(String mediaId, int fileSize) async {
    final authUser = ref.read(authStateProvider).value;
    if (authUser == null) return;

    final userMediaService = ref.read(userMediaServiceProvider);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('মিডিয়া ডিলিট করুন'),
        content: const Text('আপনি কি নিশ্চিত যে ক্লাউড স্টোরেজ থেকে এই ফাইলটি ডিলিট করতে চান?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('না')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('ডিলিট করুন'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await userMediaService.deleteUserMedia(authUser.uid, mediaId, fileSize);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('মিডিয়া ফাইল সফলভাবে ডিলিট করা হয়েছে।'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ডিলিট করতে ব্যর্থ: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = ref.watch(currentUserDataProvider).value;
    final authUser = ref.watch(authStateProvider).value;

    if (user == null || authUser == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final String role = user['role'] ?? 'customer';
    final int points = (user['points'] ?? 0).toInt();
    
    final userMediaService = ref.watch(userMediaServiceProvider);
    final int limitBytes = userMediaService.getQuotaLimit(points, role);
    final double limitMB = limitBytes / (1024 * 1024);

    return Scaffold(
      backgroundColor: isDark ? AppStyles.darkBackgroundColor : AppStyles.backgroundColor,
      appBar: AppBar(
        title: const Text('ক্লাউড স্টোরেজ (Cloud Storage)', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: isDark ? AppStyles.darkSurfaceColor : AppStyles.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: userMediaService.getUserMediaStream(authUser.uid),
        builder: (context, snapshot) {
          final list = snapshot.data ?? [];
          final int usedBytes = list.fold<int>(0, (sum, item) => sum + (item['fileSize'] as int? ?? 0));
          final double usedMB = usedBytes / (1024 * 1024);
          final double usagePercent = (usedBytes / limitBytes).clamp(0.0, 1.0);

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // 1. Quota Progress Card
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isDark
                            ? [Colors.white.withOpacity(0.08), Colors.white.withOpacity(0.03)]
                            : [Colors.teal.withOpacity(0.05), Colors.teal.withOpacity(0.01)],
                      ),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: isDark ? Colors.white.withOpacity(0.08) : Colors.teal.withOpacity(0.1),
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('ব্যবহৃত স্টোরেজ Space', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
                                const SizedBox(height: 6),
                                Text(
                                  '${usedMB.toStringAsFixed(1)} MB / ${limitMB.toStringAsFixed(0)} MB',
                                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: AppStyles.primaryColor),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppStyles.primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                role == 'admin' ? 'ADMIN' : (points >= 5000 ? 'PLATINUM' : (points >= 2500 ? 'GOLD' : 'SILVER')),
                                style: const TextStyle(color: AppStyles.primaryColor, fontWeight: FontWeight.bold, fontSize: 10),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: usagePercent,
                            minHeight: 12,
                            backgroundColor: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[200],
                            valueColor: const AlwaysStoppedAnimation<Color>(AppStyles.primaryColor),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${(usagePercent * 100).toStringAsFixed(1)}% Storage Used',
                              style: const TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.w600),
                            ),
                            Text(
                              'অবশিষ্ট: ${_formatSize(limitBytes - usedBytes)}',
                              style: const TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // 2. Auto-Backup Toggle Card
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white.withOpacity(0.03) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: !isDark ? AppStyles.softShadow : null,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.backup_rounded, color: AppStyles.primaryColor, size: 20),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('অটো-ব্যাকআপ (Auto-Backup)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                Text('মিডিয়া ফাইল স্বয়ংক্রিয়ভাবে ক্লাউডে যাবে', style: TextStyle(color: Colors.grey, fontSize: 10)),
                              ],
                            ),
                          ],
                        ),
                        Switch(
                          value: ref.watch(autoBackupEnabledProvider),
                          onChanged: (val) {
                            ref.read(autoBackupEnabledProvider.notifier).state = val;
                          },
                          activeColor: AppStyles.primaryColor,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(18, 24, 18, 12),
                  child: Text(
                    'আমার ব্যাকআপ ফাইলসমূহ (MY BACKED UP FILES)',
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 0.5, color: Colors.grey),
                  ),
                ),
              ),

              // 3. Media List
              list.isEmpty
                  ? const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(40.0),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(Icons.cloud_off_rounded, size: 48, color: Colors.grey),
                              SizedBox(height: 12),
                              Text('কোনো ব্যাকআপ ফাইল পাওয়া যায়নি', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                    )
                  : SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final item = list[index];
                            final String fileName = item['fileName'] ?? 'Unnamed File';
                            final String fileUrl = item['fileUrl'] ?? '';
                            final int size = (item['fileSize'] ?? 0).toInt();
                            final Timestamp? timestamp = item['uploadedAt'] as Timestamp?;
                            final dateStr = timestamp != null
                                ? DateFormat('dd MMM yyyy, hh:mm a').format(timestamp.toDate())
                                : '';

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: !isDark ? AppStyles.softShadow : null,
                                  border: Border.all(color: Colors.white.withOpacity(0.03)),
                                ),
                                child: Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: CachedNetworkImage(
                                        imageUrl: fileUrl,
                                        width: 50,
                                        height: 50,
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) => Container(color: Colors.grey[300]),
                                        errorWidget: (context, url, err) => Container(
                                          color: Colors.grey[200],
                                          child: const Icon(Icons.insert_drive_file_rounded, color: Colors.grey),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            fileName,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '${_formatSize(size)} • $dateStr',
                                            style: const TextStyle(color: Colors.grey, fontSize: 11),
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
                                      onPressed: () => _handleDelete(item['id'], size),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                          childCount: list.length,
                        ),
                      ),
                    ),
              const SliverToBoxAdapter(child: SizedBox(height: 120)),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isUploading ? null : _handleUpload,
        backgroundColor: AppStyles.primaryColor,
        icon: _isUploading
            ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : const Icon(Icons.upload_file_rounded, color: Colors.white),
        label: Text(_isUploading ? 'Uploading...' : 'ফাইল আপলোড', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
      ),
    );
  }
}
