import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../di/service_locator.dart';

final secretsServiceProvider = Provider((ref) => getIt<SecretsService>());

class SecretsService {
  final Map<String, dynamic> _dbSecrets;
  SecretsService(this._dbSecrets);

  String getSecret(String key, {String fallback = ''}) {
    if (_dbSecrets.containsKey(key) && _dbSecrets[key].toString().isNotEmpty) {
      return _dbSecrets[key].toString().trim();
    }
    try {
      return dotenv.get(key, fallback: fallback).trim();
    } catch (_) {
      return fallback;
    }
  }

  List<String> getKeysByPrefix(String prefix) {
    final Set<String> allKeys = {};
    _dbSecrets.forEach((k, v) {
      if (k.startsWith(prefix) && v.toString().isNotEmpty) {
        allKeys.add(v.toString().trim());
      }
    });
    return allKeys.toList();
  }

  List<String> get deepSeekKeys => getKeysByPrefix('DEEPSEEK_API_KEY');
  List<String> get genericKeys => getKeysByPrefix('GEMINI_API_KEY');

  String get cloudinaryCloudName => getSecret('CLOUDINARY_CLOUD_NAME');
  String get cloudinaryApiKey => getSecret('CLOUDINARY_API_KEY');
}
