import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  static final ConnectivityService _singleton = ConnectivityService._internal();

  factory ConnectivityService() {
    return _singleton;
  }

  ConnectivityService._internal();

  final Connectivity _connectivity = Connectivity();

  Stream<ConnectivityResult> get connectivityStream => _connectivity.onConnectivityChanged;

    Future<bool> isConnected() async {
    var connectivityResult = await _connectivity.checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }
}
