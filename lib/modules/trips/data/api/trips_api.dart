import 'dart:async';
import 'package:http/http.dart' as http;
import '../../../../core/exceptions/app_exception.dart';
import '../../../../core/utils/network_utils.dart';
import '../url/trips_url.dart';

class TripsApi {
  Future<Map<String, dynamic>> fetchMyTrips({bool forceRefresh = false}) async {
    return NetworkUtils.getWithCache(
      TripsUrl.myTrips,
      forceRefresh: forceRefresh,
      ttlMinutes: 60, // Trips can be cached for 1 hour
    );
  }
}
