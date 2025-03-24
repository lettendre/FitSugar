import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

class ConnectivityService with ChangeNotifier {
  final Connectivity _connectivity = Connectivity();
  bool _isConnected = true;
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  bool get isConnected => _isConnected;

  ConnectivityService() {
    _initializeService();
  }

  void _initializeService() {
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
    _initConnectivity();
  }

  //initialise connectivity and check initial state
  Future<void> _initConnectivity() async {
    try {
      List<ConnectivityResult> resultList = await _connectivity.checkConnectivity();
      _updateConnectionStatus(resultList);
    } catch (e) {
      if (kDebugMode) {
        print("Connectivity initialization error: $e");
      }
      _isConnected = false;
      notifyListeners();
    }
  }

  //update connection status based on connectivity result
  void _updateConnectionStatus(List<ConnectivityResult> resultList) {
    _isConnected = resultList.isNotEmpty &&
        !resultList.contains(ConnectivityResult.none) &&
        !(resultList.length == 1 && resultList.first == ConnectivityResult.none);
    notifyListeners();
  }

  //check connectivity on demand
  Future<bool> checkConnectivity() async {
    List<ConnectivityResult> resultList = await _connectivity.checkConnectivity();
    _updateConnectionStatus(resultList);
    return _isConnected;
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }
}