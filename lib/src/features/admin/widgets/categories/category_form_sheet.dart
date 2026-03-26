import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../di/providers.dart';
import '../../../../utils/styles.dart';

class CategoryFormSheet extends ConsumerStatefulWidget {
  final Map<String, dynamic>? category;
  final Map<String, dynamic>? parentCategory;
  final String? initialParentId;

  const CategoryFormSheet({
    super.key,
    this.category,
    this.parentCategory,
    this.initialParentId,
  });

  @override
  ConsumerState<CategoryFormSheet> createState() => _CategoryFormSheetState();
}

class _CategoryFormSheetState extends ConsumerState<CategoryFormSheet> {
  final _nameController = TextEditingController();
  final _nameBnController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _orderController = TextEditingController(text: '0');

  File? _imageFile;
  final bool _isProcessing = false;
  Map<String, dynamic>? selectedShop;

  @override
  void initState() {
    super.initState();
    if (widget.category != null) {
      _nameController.text = widget.category!['name'] ?? '';
      _nameBnController.text = widget.category!['nameBn'] ?? '';
      _imageUrlController.text = widget.category!['imageUrl'] ?? '';
      _orderController.text = (widget.category!['order'] ?? 0).toString();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nameBnController.dispose();
    _imageUrlController.dispose();
    _orderController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _imageFile = File(picked.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    final shops = ref.watch(storesProvider).value ?? [];
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 20,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Category Details',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _nameController,
              decoration: AppStyles.inputDecoration('Category Name (EN)', isDark, hint: 'e.g. Electronics'),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _nameBnController,
                    decoration: AppStyles.inputDecoration('Category Name (BN)', isDark, hint: 'উদা: ইলেকট্রনিক্স'),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.translate, color: Colors.teal),
                  onPressed: _autoTranslate,
                ),
              ],
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _orderController,
              keyboardType: TextInputType.number,
              decoration: AppStyles.inputDecoration('Display Order', isDark, hint: '0'),
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              initialValue: selectedShop?['id'],
              hint: const Text('Select Shop/Store'),
              items: shops.map((s) {
                return DropdownMenuItem<String>(
                  value: s['id'],
                  child: Text(s['name'] ?? 'Unknown'),
                );
              }).toList(),
              decoration: AppStyles.inputDecoration('Select Shop', isDark),
              onChanged: (val) {
                setState(() {
                  selectedShop = shops.firstWhere((s) => s['id'] == val);
                });
              },
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: _imageFile != null
                    ? Image.file(_imageFile!, fit: BoxFit.cover)
                    : widget.category?['imageUrl'] != null
                        ? CachedNetworkImage(
                            imageUrl: widget.category!['imageUrl'],
                            fit: BoxFit.cover,
                            placeholder: (context, url) => const Center(
                                child: CircularProgressIndicator()),
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.broken_image),
                          )
                        : const Icon(Icons.add_a_photo,
                            size: 40, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _isProcessing ? null : _saveCategory,
              child: _isProcessing
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : Text(
                      widget.category == null ? 'CREATE CATEGORY' : 'UPDATE'),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Future<void> _autoTranslate() async {
    // Logic for auto translate
  }

  Future<void> _saveCategory() async {
    // Logic for saving category
  }
}
