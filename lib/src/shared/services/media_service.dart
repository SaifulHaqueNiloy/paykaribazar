import 'dart:io';
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
}
