import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  Future<void> requestAllPermissions() async {
    await [
      Permission.location,
      Permission.notification,
      Permission.camera,
      Permission.storage,
    ].request();
  }

  static Future<bool> isLocationGranted() async => await Permission.location.isGranted;
}
