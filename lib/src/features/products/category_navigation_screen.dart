import 'package:flutter/material.dart';

class CategoryNavigationScreen extends StatelessWidget {
  final String categoryId;
  final String categoryName;
  const CategoryNavigationScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(categoryName)),
      body: Center(child: Text('Navigation for $categoryName ($categoryId)')),
    );
  }
}
