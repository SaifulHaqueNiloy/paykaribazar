import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:path/path.dart' as p;

/// Optimized image processing using native compression.
/// This is significantly faster and more memory-efficient than pure Dart libraries.
Future<File?> processImage(String path, String type) async {
  final dir = await path_provider.getTemporaryDirectory();
  final targetPath = p.join(dir.path, 'compressed_${type}_${DateTime.now().millisecondsSinceEpoch}.jpg');

  final XFile? compressedFile = await FlutterImageCompress.compressAndGetFile(
    path,
    targetPath,
    quality: 70, // Balanced quality vs size
    minWidth: 800,
    minHeight: 800,
  );

  return compressedFile != null ? File(compressedFile.path) : null;
}

String toTitleCase(String text) {
  if (text.isEmpty) return text;
  return text.split(' ').map((word) {
    if (word.isEmpty) return word;
    return word[0].toUpperCase() + word.substring(1).toLowerCase();
  }).join(' ');
}
