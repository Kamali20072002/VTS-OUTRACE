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
      ttlMinutes: 30, // Vehicle list can be cached for 30 mins
    );
  }
}
