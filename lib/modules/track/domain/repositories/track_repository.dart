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
}
