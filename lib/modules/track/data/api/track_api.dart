import 'dart:async';
import 'package:http/http.dart' as http;
import '../../../../core/exceptions/app_exception.dart';
import '../../../../core/utils/network_utils.dart';
import '../url/track_url.dart';

class TrackApiCalls {
  Future<Map<String, dynamic>> getActiveVehicles({bool forceRefresh = false}) async {
    return NetworkUtils.getWithCache(
      TrackUrl.activeVehicles,
      forceRefresh: forceRefresh,
      ttlMinutes: 1, // Reduced from 30 to 1 min to fix status discrepancy
    );
  }

  Future<Map<String, dynamic>> getLatestGps(String deviceId) async {
    return NetworkUtils.get(
      TrackUrl.latestGps(deviceId),
    );
  }
}
