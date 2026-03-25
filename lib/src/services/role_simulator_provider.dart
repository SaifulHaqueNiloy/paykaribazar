import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';

final isSimulatingProvider = StateProvider<bool>((ref) => false);
final simulatedUserUidProvider = StateProvider<String?>((ref) => null);
final simulatedRoleProvider = StateProvider<UserRole?>((ref) => null);
