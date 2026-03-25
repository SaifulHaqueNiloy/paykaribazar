import 'package:firebase_core/firebase_core.dart';
import '../../../firebase_options.dart';

class FirebaseCoreService {
  bool _initialized = false;
  
  Future<void> initialize() async {
    if (_initialized) return;
    
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
    _initialized = true;
  }
  
  bool get isInitialized => _initialized;
}
