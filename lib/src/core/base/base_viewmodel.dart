import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract class BaseViewModel extends StateNotifier<bool> {
  BaseViewModel() : super(false);

  bool get isLoading => state;

  void setLoading(bool value) {
    state = value;
  }

  // Common logic for handling errors or state transitions
  void handleError(dynamic error, StackTrace stackTrace) {
    setLoading(false);
    debugPrint('Error: $error');
    debugPrint('Stack: $stackTrace');
  }
}
