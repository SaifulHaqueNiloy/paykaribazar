import 'dart:io';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/services/secrets_service.dart';

class MediaService {
  final SecretsService _secrets;
  final _picker = ImagePicker();

  MediaService(this._secrets);

  Future<File?> pickImage({ImageSource source = ImageSource.gallery}) async {
    final pickedFile =
        await _picker.pickImage(source: source, imageQuality: 70);
    return pickedFile != null ? File(pickedFile.path) : null;
  }

  Future<String?> uploadToCloudinary(File file,
      {required String folder, bool removeBg = false}) async {
    final cloudName = _secrets.getSecret('CLOUDINARY_CLOUD_NAME');
    final uploadPreset = _secrets.getSecret('CLOUDINARY_UPLOAD_PRESET',
        fallback: 'paykaribazar_preset');

    try {
      final dio = Dio();
      final Map<String, dynamic> params = {
        'file': await MultipartFile.fromFile(file.path),
        'upload_preset': uploadPreset,
        'folder': 'paykaribazar/$folder',
      };
      if (removeBg) params['background_removal'] = 'cloudinary_ai';

      final response = await dio.post(
        'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
        data: FormData.fromMap(params),
      );

      if (response.statusCode == 200) {
        return response.data['secure_url'];
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  String getAdaptiveUrl(String url, {int width = 500}) {
    if (!url.contains('cloudinary.com')) return url;
    return url.replaceAll(
        '/upload/', '/upload/f_auto,q_auto,w_$width,c_limit/');
  }

  String? _getPublicIdFromUrl(String url) {
    try {
      final uri = Uri.parse(url);
      final pathSegments = uri.pathSegments;
      final uploadIndex = pathSegments.indexOf('upload');
      if (uploadIndex == -1 || uploadIndex >= pathSegments.length - 1) return null;
      
      var segments = pathSegments.sublist(uploadIndex + 1);
      if (segments.isNotEmpty && RegExp(r'^v\d+$').hasMatch(segments.first)) {
        segments = segments.sublist(1);
      }
      
      final publicIdWithExt = segments.join('/');
      final dotIndex = publicIdWithExt.lastIndexOf('.');
      if (dotIndex != -1) {
        return publicIdWithExt.substring(0, dotIndex);
      }
      return publicIdWithExt;
    } catch (_) {
      return null;
    }
  }

  Future<bool> deleteFromCloudinary(String url) async {
    final cloudName = _secrets.getSecret('CLOUDINARY_CLOUD_NAME');
    final apiKey = _secrets.getSecret('CLOUDINARY_API_KEY');
    final apiSecret = _secrets.getSecret('CLOUDINARY_API_SECRET');

    if (cloudName.isEmpty || apiKey.isEmpty || apiSecret.isEmpty) {
      return false;
    }

    final publicId = _getPublicIdFromUrl(url);
    if (publicId == null) return false;

    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final signatureString = 'public_id=$publicId&timestamp=$timestamp$apiSecret';
      final signature = sha1.convert(utf8.encode(signatureString)).toString();

      final dio = Dio();
      final response = await dio.post(
        'https://api.cloudinary.com/v1_1/$cloudName/image/destroy',
        data: {
          'public_id': publicId,
          'api_key': apiKey,
          'timestamp': timestamp,
          'signature': signature,
        },
      );

      if (response.statusCode == 200) {
        final result = response.data['result'];
        return result == 'ok';
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Cloudinary Delete Error: $e');
    }
    return false;
  }
}
