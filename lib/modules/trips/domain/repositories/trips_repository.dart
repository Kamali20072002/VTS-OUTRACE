import '../../data/api/trips_api.dart';

class TripsRepository {
  final TripsApi _api = TripsApi();

  Future<Map<String, dynamic>> getMyTrips({bool forceRefresh = false}) async {
    final response = await _api.fetchMyTrips(forceRefresh: forceRefresh);
    return response;
  }
}
