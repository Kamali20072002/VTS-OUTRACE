import '../models/active_vehicle_model.dart';
import '../../data/api/track_api.dart';

class TrackRepository {
  final TrackApiCalls _api = TrackApiCalls();

  Future<List<ActiveVehicleModel>> getActiveVehicles({bool forceRefresh = false}) async {
    final json = await _api.getActiveVehicles(forceRefresh: forceRefresh);
    final data = json['data'] as List<dynamic>? ?? [];
    return data
        .map((v) => ActiveVehicleModel.fromJson(v as Map<String, dynamic>))
        .toList();
  }

  Future<ActiveVehicleModel?> getLatestGps(String deviceId) async {
    final json = await _api.getLatestGps(deviceId);
    if (json['data'] != null) {
      return ActiveVehicleModel.fromJson(json['data'] as Map<String, dynamic>);
    }
    return null;
  }
}
