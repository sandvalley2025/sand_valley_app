import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  final StreamController<bool> _connectionStatusController = StreamController<bool>.broadcast();

  ConnectivityService() {
    _connectivity.onConnectivityChanged.listen(_updateStatus);
    _checkInitialConnection();
  }

  Stream<bool> get connectionStatusStream => _connectionStatusController.stream;

  Future<void> _checkInitialConnection() async {
    var result = await _connectivity.checkConnectivity();
    _updateStatus(result);
  }

  void _updateStatus(ConnectivityResult result) {
    bool isConnected = result != ConnectivityResult.none;
    _connectionStatusController.add(isConnected);
  }

  void dispose() {
    _connectionStatusController.close();
  }
}
