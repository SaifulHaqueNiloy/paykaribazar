import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/services/notification_service.dart';
import '../../../di/service_locator.dart';

class CustomNotificationSheet extends ConsumerStatefulWidget {
  const CustomNotificationSheet({super.key});
  @override
  ConsumerState<CustomNotificationSheet> createState() =>
      _CustomNotificationSheetState();
}

class _CustomNotificationSheetState
    extends ConsumerState<CustomNotificationSheet> {
  final _titleCtrl = TextEditingController();
  final _bodyCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // ref.watch(locationsProvider) retrieved for potential use

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Text('Send Custom Notification',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        const SizedBox(height: 20),
        TextField(
            controller: _titleCtrl,
            decoration: const InputDecoration(labelText: 'Title')),
        TextField(
            controller: _bodyCtrl,
            decoration: const InputDecoration(labelText: 'Body')),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () async {
            await getIt<NotificationService>().showNotification(
              title: _titleCtrl.text,
              body: _bodyCtrl.text,
            );
            Navigator.pop(context);
          },
          child: const Text('SEND NOW'),
        ),
      ]),
    );
  }
}
