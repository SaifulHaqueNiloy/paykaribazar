import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:path/path.dart' as p;

class ImageUtils {
  /// Optimized image processing using native compression.
  /// Balanced quality vs size for general usage (Profile, Products, etc.)
  static Future<File?> compressImage(File file, {int quality = 70, int minWidth = 1000, int minHeight = 1000}) async {
    try {
      final dir = await path_provider.getTemporaryDirectory();
      final targetPath = p.join(dir.path, 'compressed_${DateTime.now().millisecondsSinceEpoch}.jpg');

      final XFile? compressedFile = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        quality: quality,
        minWidth: minWidth,
        minHeight: minHeight,
      );

      if (compressedFile != null) {
        // final originalSize = await file.length();
        // final compressedSize = await File(compressedFile.path).length();
        // Image compression size difference logged internally
        return File(compressedFile.path);
      }
    } catch (e) {
      // Compression error handled silently
    }
    return null;
  }
}

/// Helper to ensure we always have a gallery list, even if only one image exists.
/// In the future, this can be expanded with AI to fetch related images.
List<String> getSmartGalleryUrls(String? mainUrl, String name, {List<String>? existing}) {
  final List<String> gallery = [];
  if (mainUrl != null && mainUrl.isNotEmpty) gallery.add(mainUrl);
  if (existing != null) {
    for (var url in existing) {
      if (url.isNotEmpty && url != mainUrl) gallery.add(url);
    }
  }
  
  // If still empty, we could add a placeholder or return an empty list
  return gallery.isEmpty ? [] : gallery;
}
