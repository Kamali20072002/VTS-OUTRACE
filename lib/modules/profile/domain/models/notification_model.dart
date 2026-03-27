class NotificationModel {
  final String id;
  final String type;
  final String message;
  final DateTime timestamp;
  final bool isAcknowledged;
  final NotificationLocation location;
  final String deviceId;
  final String vehicleId;
  final String userId;

  NotificationModel({
    required this.id,
    required this.type,
    required this.message,
    required this.timestamp,
    required this.isAcknowledged,
    required this.location,
    required this.deviceId,
    required this.vehicleId,
    required this.userId,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['_id'] ?? '',
      type: json['type'] ?? '',
      message: json['message'] ?? '',
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
      isAcknowledged: json['isAcknowledged'] ?? false,
      location: NotificationLocation.fromJson(json['location'] ?? {}),
      deviceId: json['deviceId'] ?? '',
      vehicleId: json['vehicleId'] ?? '',
      userId: json['userId'] ?? '',
    );
  }
}

class NotificationLocation {
  final double lat;
  final double lon;

  NotificationLocation({required this.lat, required this.lon});

  factory NotificationLocation.fromJson(Map<String, dynamic> json) {
    return NotificationLocation(
      lat: (json['lat'] as num?)?.toDouble() ?? 0.0,
      lon: (json['lon'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
