import 'package:connectivity_plus/connectivity_plus.dart';

/// Checks device network connectivity.
class ConnectivityService {
  const ConnectivityService();

  /// Returns `true` when at least one non-none connectivity type is active.
  Future<bool> isOnline() async {
    final results = await Connectivity().checkConnectivity();
    return results.isNotEmpty &&
        results.any((r) => r != ConnectivityResult.none);
  }
}
