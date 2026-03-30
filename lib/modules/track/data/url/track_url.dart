import '../../../../core/core.dart';

class TrackUrl {
  static final String activeVehicles = '${AppConfig.baseUrl}/vehicles/my';
  static String latestGps(String deviceId) => '${AppConfig.baseUrl}/gps/latest/$deviceId';
}
