import 'package:flutter/material.dart';

class RiderApplicationScreen extends StatelessWidget {
  const RiderApplicationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rider Application')),
      body: const Center(child: Text('Rider Application Screen')),
    );
  }
}
