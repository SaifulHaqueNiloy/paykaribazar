import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final connectivityProvider = StreamProvider<List<ConnectivityResult>>((ref) {
  return Connectivity().onConnectivityChanged;
});

final isOnlineProvider = Provider<bool>((ref) {
  final connectivity = ref.watch(connectivityProvider);
  return connectivity.when(
    data: (results) => results.isNotEmpty && results.first != ConnectivityResult.none,
    loading: () => true, // Assume online until proven otherwise
    error: (_, __) => false,
  );
});

class ConnectionAwareExecutor {
  static Future<T?> executeIfConnected<T>(
    Future<T> Function() task, {
    Duration timeout = const Duration(seconds: 30),
  }) async {
    final connectivity = await Connectivity().checkConnectivity();
    if (connectivity.contains(ConnectivityResult.none)) {
      return null;
    }
    
    return task().timeout(timeout);
  }
}

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();

  Stream<List<ConnectivityResult>> get onConnectivityChanged => _connectivity.onConnectivityChanged;

  Future<bool> get isConnected async {
    final result = await _connectivity.checkConnectivity();
    return !result.contains(ConnectivityResult.none);
  }

  Future<List<ConnectivityResult>> checkConnectivity() => _connectivity.checkConnectivity();
}
