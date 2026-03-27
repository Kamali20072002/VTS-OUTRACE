import '../../data/api/trips_api.dart';

class TripsRepository {
  final TripsApi _api = TripsApi();

  Future<Map<String, dynamic>> getMyTrips() async {
    final response = await _api.fetchMyTrips();
    return response;
  }
}
