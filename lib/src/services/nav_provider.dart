import 'package:flutter_riverpod/flutter_riverpod.dart';

class NavNotifier extends StateNotifier<int> {
  NavNotifier() : super(0);

  void setIndex(int index) {
    state = index;
  }
}

final navProvider = StateNotifierProvider<NavNotifier, int>((ref) {
  return NavNotifier();
});
