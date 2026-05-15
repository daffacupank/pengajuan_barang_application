import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  static Future<bool> hasConnection() async {
    final results = await Connectivity().checkConnectivity();
    return !results.contains(ConnectivityResult.none);
  }
}
