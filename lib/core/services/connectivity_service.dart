import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';

class ConnectivityService extends GetxService {
  final Connectivity _connectivity = Connectivity();
  final _isConnected = true.obs;
  bool get isConnected => _isConnected.value;

  late StreamSubscription<List<ConnectivityResult>> _subscription;

  @override
  void onInit() {
    super.onInit();
    checkInitialConnectivity();
    _subscription = _connectivity.onConnectivityChanged.listen(_updateState);
  }

  Future<void> checkInitialConnectivity() async {
    final results = await _connectivity.checkConnectivity();
    _updateState(results);
  }

  void _updateState(List<ConnectivityResult> results) {
    if (results.isEmpty || results.contains(ConnectivityResult.none)) {
      _isConnected.value = false;
    } else {
      _isConnected.value = true;
    }
  }

  @override
  void onClose() {
    _subscription.cancel();
    super.onClose();
  }
}
