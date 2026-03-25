import 'package:package_info_plus/package_info_plus.dart';

class VersionUtils {
  /// DNA ENFORCED: Automatically derives app-specific versioning logic.
  /// If pubspec is 1.0.0+1:
  /// - Customer: 1.0.0+1
  /// - Admin: 2.0.0+1
  static Future<String> getDisplayVersion() async {
    final info = await PackageInfo.fromPlatform();
    final bool isAdmin = info.packageName.contains('admin') || 
                         info.appName.toLowerCase().contains('admin');
    
    if (isAdmin) {
      final parts = info.version.split('.');
      if (parts.isNotEmpty) {
        // Increment major version by 1 for Admin (e.g., 1.x.x -> 2.x.x)
        final major = int.tryParse(parts[0]) ?? 1;
        final adminVersion = '${major + 1}.${parts.skip(1).join('.')}';
        return '$adminVersion+${info.buildNumber}';
      }
    }
    
    return '${info.version}+${info.buildNumber}';
  }

  static Future<bool> isAdminApp() async {
    final info = await PackageInfo.fromPlatform();
    return info.packageName.contains('admin') || 
           info.appName.toLowerCase().contains('admin');
  }
}
