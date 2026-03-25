import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:paykari_bazar/src/di/providers.dart'; // MASTER HUB
import 'package:paykari_bazar/src/models/product_model.dart';
import 'package:paykari_bazar/src/utils/styles.dart';
import 'package:paykari_bazar/src/features/ai/services/multimodal_ai_service.dart';

class ProductFormSheet extends ConsumerStatefulWidget {
  final Product? product;
  const ProductFormSheet({super.key, this.product});
  @override
  ConsumerState<ProductFormSheet> createState() => _ProductFormSheetState();
}

class _ProductFormSheetState extends ConsumerState<ProductFormSheet> {
  final _nameEn = TextEditingController(), _nameBn = TextEditingController();
  final _descEn = TextEditingController(), _descBn = TextEditingController();
  final _price = TextEditingController();
  final _stock = TextEditingController();
  final _imageUrlCtrl = TextEditingController();

  File? _image;
  bool _isLoading = false;
  bool _isAiAnalyzing = false; // ⭐ NEW: Track AI analysis state
  String _catId = 'grocery', _catName = 'Grocery', _catNameBn = 'মুদি';

  bool _isFlashSale = false;
  bool _isNewArrival = true;
  bool _isFeatured = false;
  bool _isCombo = false;
  List<String> _selectedComboProductIds = [];

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      final p = widget.product!;
      _nameEn.text = p.name;
      _nameBn.text = p.nameBn;
      _descEn.text = p.description;
      _descBn.text = p.descriptionBn;
      _price.text = p.price.toString();
      _stock.text = p.stock.toString();
      _imageUrlCtrl.text = p.imageUrl;
      _isFlashSale = p.isFlashSale;
      _isNewArrival = p.isNewArrival;
      _isFeatured = p.isFeatured;
      _isCombo = p.isCombo;
      _selectedComboProductIds = List.from(p.comboProductIds);
    }
  }

  // ⭐ NEW: Handle AI Analysis from Image
  Future<void> _handleAiAnalysis() async {
    if (_image == null && _imageUrlCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload or provide an image URL first')),
      );
      return;
    }

    setState(() => _isAiAnalyzing = true);

    try {
      String url = _imageUrlCtrl.text.trim();
      
      // If a new local image is selected, upload it first to Cloudinary
      if (_image != null) {
        url = await ref
                .read(firestoreServiceProvider)
                .uploadImage(_image!, 'products') ?? '';
        _imageUrlCtrl.text = url;
      }

      if (url.isEmpty) throw Exception('Image URL is empty');

      // Initialize Multimodal AI Service
      final multimodalAi = MultimodalAIService(
        secrets: ref.read(secretsServiceProvider),
      );

      // Analyze image
      final details = await multimodalAi.generateProductDetailsFromImage(
        imageUrl: url,
        category: _catName,
      );

      if (mounted) {
        setState(() {
          _nameEn.text = details['title_en'] ?? _nameEn.text;
          _nameBn.text = details['title_bn'] ?? _nameBn.text;
          _descEn.text = details['description_en'] ?? _descEn.text;
          _descBn.text = details['description_bn'] ?? _descBn.text;
          
          // Suggest price if empty
          if (_price.text.isEmpty && details['suggested_price_range'] != null) {
            final priceMatch = RegExp(r'৳(\d+)').firstMatch(details['suggested_price_range']);
            if (priceMatch != null) {
              _price.text = priceMatch.group(1) ?? '';
            }
          }
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('AI Analysis Complete! ✨'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('AI Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isAiAnalyzing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30))),
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 20,
          right: 20,
          top: 16),
      child: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10))),
          const SizedBox(height: 20),
          _buildImagePicker(isDark),
          
          // ⭐ NEW: AI Generate Button
          const SizedBox(height: 10),
          _isAiAnalyzing 
            ? const LinearProgressIndicator(color: AppStyles.primaryColor)
            : TextButton.icon(
                onPressed: _handleAiAnalysis,
                icon: const Icon(Icons.auto_awesome, color: Colors.amber),
                label: const Text('GENERATE DETAILS WITH AI', 
                  style: TextStyle(fontWeight: FontWeight.bold, color: AppStyles.primaryColor)),
                style: TextButton.styleFrom(
                  backgroundColor: AppStyles.primaryColor.withValues(alpha: 0.1),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),

          const SizedBox(height: 20),
          _buildSectionTitle('CAMPAIGN TAGS'),
          Wrap(
            spacing: 10,
            children: [
              _buildTagChip('FLASH SALE', _isFlashSale, Colors.red,
                  (v) => setState(() => _isFlashSale = v)),
              _buildTagChip('NEW ARRIVAL', _isNewArrival, Colors.green,
                  (v) => setState(() => _isNewArrival = v)),
              _buildTagChip('FEATURED', _isFeatured, Colors.blue,
                  (v) => setState(() => _isFeatured = v)),
              _buildTagChip('COMBO PACK', _isCombo, Colors.orange,
                  (v) => setState(() => _isCombo = v)),
            ],
          ),
          _buildSectionTitle('BASIC INFORMATION'),
          _buildField(_nameEn, 'Product Name (EN)', isDark),
          _buildField(_nameBn, 'পন্যের নাম (BN)', isDark),
          _buildField(_descEn, 'Description (EN)', isDark, max: 3),
          _buildField(_descBn, 'বিবরণ (BN)', isDark, max: 3),
          _buildSectionTitle('PRICING & STOCK'),
          Row(children: [
            Expanded(
                child:
                    _buildField(_price, 'Retail Price', isDark, isNum: true)),
            const SizedBox(width: 10),
            Expanded(
                child:
                    _buildField(_stock, 'Current Stock', isDark, isNum: true)),
          ]),
          const SizedBox(height: 24),
          _isLoading
              ? const CircularProgressIndicator()
              : ElevatedButton(
                  onPressed: _handleSave,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppStyles.primaryColor,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 55),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16))),
                  child: Text('SAVE PRODUCT'.toUpperCase(),
                      style: const TextStyle(fontWeight: FontWeight.bold))),
          const SizedBox(height: 40),
        ]),
      ),
    );
  }

  Widget _buildSectionTitle(String title) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(children: [
        Text(title,
            style: const TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 10,
                color: Colors.blueGrey,
                letterSpacing: 1.2)),
        const Expanded(child: Divider(indent: 10))
      ]));

  Widget _buildTagChip(String l, bool s, Color c, Function(bool) o) =>
      FilterChip(
          label: Text(l,
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: s ? Colors.white : c)),
          selected: s,
          onSelected: o,
          selectedColor: c,
          backgroundColor: c.withValues(alpha: 0.1),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)));

  Widget _buildImagePicker(bool isDark) => GestureDetector(
      onTap: () async {
        final p = await ImagePicker().pickImage(source: ImageSource.gallery);
        if (p != null) {
          setState(() {
            _image = File(p.path);
            _imageUrlCtrl.clear();
          });
        }
      },
      child: Container(
          height: 150,
          width: double.infinity,
          decoration: BoxDecoration(
              color: isDark ? Colors.white10 : Colors.grey[100],
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.grey.withValues(alpha: 0.2))),
          child: _image != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.file(_image!, fit: BoxFit.cover))
              : _imageUrlCtrl.text.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.network(
                        _imageUrlCtrl.text,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Center(
                                child: Icon(Icons.broken_image_rounded,
                                    color: Colors.red)),
                      ))
                  : const Center(
                      child: Icon(Icons.add_a_photo, color: Colors.grey))));

  Widget _buildField(TextEditingController c, String l, bool d,
          {bool isNum = false, int max = 1}) =>
      Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: TextFormField(
              controller: c,
              maxLines: max,
              keyboardType: isNum ? TextInputType.number : TextInputType.text,
              decoration: AppStyles.inputDecoration(l, d)));

  Future<void> _handleSave() async {
    setState(() => _isLoading = true);
    try {
      String url = _imageUrlCtrl.text.trim();
      if (_image != null) {
        url = await ref
                .read(firestoreServiceProvider)
                .uploadImage(_image!, 'products') ??
            '';
      }
      final p = Product(
          id: widget.product?.id ?? const Uuid().v4(),
          sku:
              widget.product?.sku ?? 'SKU-${const Uuid().v4().substring(0, 8)}',
          name: _nameEn.text,
          nameBn: _nameBn.text,
          description: _descEn.text,
          descriptionBn: _descBn.text,
          price: double.tryParse(_price.text) ?? 0,
          oldPrice: double.tryParse(_price.text) ?? 0,
          stock: int.tryParse(_stock.text) ?? 0,
          unit: 'pcs',
          unitBn: 'পিস',
          imageUrl: url,
          categoryId: _catId,
          categoryName: _catName,
          categoryNameBn: _catNameBn,
          addedBy: ref.read(authStateProvider).value?.uid ?? '',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isFlashSale: _isFlashSale,
          isNewArrival: _isNewArrival,
          isFeatured: _isFeatured,
          isCombo: _isCombo,
          comboProductIds: _selectedComboProductIds);
      if (widget.product == null) {
        await ref.read(firestoreServiceProvider).addProduct(p.toMap());
      } else {
        await ref
            .read(firestoreServiceProvider)
            .updateProduct(widget.product!.id, p.toMap());
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}

