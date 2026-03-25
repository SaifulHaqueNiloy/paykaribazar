import 'package:flutter/material.dart';
import '../utils/styles.dart';

class UpdateDialog extends StatelessWidget {
  final String message;
  final bool isForceUpdate;
  final VoidCallback onUpdate;

  const UpdateDialog({
    super.key,
    required this.message,
    required this.isForceUpdate,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PopScope(
      canPop: !isForceUpdate,
      child: AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            const Icon(Icons.system_update_rounded, color: AppStyles.primaryColor),
            const SizedBox(width: 12),
            Text(
              isForceUpdate ? 'Force Update' : 'Update Available', 
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message, style: const TextStyle(fontSize: 14, height: 1.5)),
            if (isForceUpdate)
              const Padding(
                padding: EdgeInsets.only(top: 12),
                child: Text(
                  'This update is required to continue using the app.',
                  style: TextStyle(color: Colors.redAccent, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
        actions: [
          if (!isForceUpdate)
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('LATER', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
            ),
          ElevatedButton(
            onPressed: onUpdate,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppStyles.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('UPDATE NOW', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
