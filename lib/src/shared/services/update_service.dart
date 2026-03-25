import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/paths.dart';
import '../../utils/version_utils.dart'; // DNA ENFORCED

enum UpdateStatus { upToDate, softUpdate, forceUpdate }

class UpdateService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<UpdateStatus> checkForAppUpdate() async {
    try {
      final snap = await _db.doc(HubPaths.configDoc).get();
      if (!snap.exists) return UpdateStatus.upToDate;

      final data = snap.data() as Map<String, dynamic>;

      // DNA ENFORCED: Automatically derives the virtual version for comparison
      final currentVersionRaw = await VersionUtils.getDisplayVersion();
      final currentVersion = currentVersionRaw.split('+')[0];

      // Logic: Admin apps use admin-specific version keys in config
      final bool isAdmin = await VersionUtils.isAdminApp();
      final String latestKey = isAdmin ? 'adminLatestVersion' : 'latestVersion';
      final String minKey = isAdmin ? 'adminMinVersion' : 'minVersion';

      final latestVersion = data[latestKey] ?? currentVersion;
      final minVersion = data[minKey] ?? currentVersion;

      if (_isLowerVersion(currentVersion, minVersion)) {
        return UpdateStatus.forceUpdate;
      }
      if (_isLowerVersion(currentVersion, latestVersion)) {
        return UpdateStatus.softUpdate;
      }

      return UpdateStatus.upToDate;
    } catch (_) {
      return UpdateStatus.upToDate;
    }
  }

  bool _isLowerVersion(String current, String target) {
    try {
      final c = current.split('.').map(int.parse).toList();
      final t = target.split('.').map(int.parse).toList();
      for (int i = 0; i < c.length; i++) {
        if (c[i] < t[i]) return true;
        if (c[i] > t[i]) return false;
      }
    } catch (_) {}
    return false;
  }

  Future<void> initialize() async {
    // Pre-check updates on startup
    await checkForAppUpdate();
  }

  String getUpdateMessage(String languageCode) {
    final isEnglish = languageCode == 'en';
    return isEnglish
        ? 'A new version of Paykari Bazar is available. Please update to continue.'
        : 'পাইকারী বাজারের নতুন সংস্করণ উপলব্ধ। অনুগ্রহ করে আপডেট করুন।';
  }

  Future<void> launchUpdateUrl() async {
    final snap = await _db.doc(HubPaths.configDoc).get();
    final bool isAdmin = await VersionUtils.isAdminApp();

    final url = snap.data()?[isAdmin ? 'adminUpdateUrl' : 'updateUrl'] ??
        'https://play.google.com/store/apps/details?id=com.paykaribazar.app';
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }
}
