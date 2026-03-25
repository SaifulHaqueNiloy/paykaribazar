import 'package:flutter_riverpod/flutter_riverpod.dart';

class ComparisonNotifier extends StateNotifier<List<String>> {
  ComparisonNotifier() : super([]);

  void addProduct(String productId) {
    if (state.length < 3 && !state.contains(productId)) {
      state = [...state, productId];
    }
  }

  void removeProduct(String productId) {
    state = state.where((id) => id != productId).toList();
  }

  void clear() => state = [];
}

final comparisonProvider = StateNotifierProvider<ComparisonNotifier, List<String>>((ref) {
  return ComparisonNotifier();
});
