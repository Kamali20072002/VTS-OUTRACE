class ActiveVehicleModel {
  final String id;
  final String deviceId;
  final String trackerId;
  final String imei;
  final String vehicleId;
  final String model;
  final String type;
  final String registrationNumber;
  final double? latitude;
  final double? longitude;
  final double? speed;
  final double? course;
  final String? engineStatus;
  final String? timestamp;
  final double? batteryLevel;
  final int? signalStrength;
  final String? status;

  ActiveVehicleModel({
    required this.id,
    required this.deviceId,
    required this.trackerId,
    required this.imei,
    required this.vehicleId,
    required this.model,
    required this.type,
    required this.registrationNumber,
    this.latitude,
    this.longitude,
    this.speed,
    this.course,
    this.engineStatus,
    this.timestamp,
    this.batteryLevel,
    this.signalStrength,
    this.status,
  });

  factory ActiveVehicleModel.fromJson(Map<String, dynamic> json) {
    return ActiveVehicleModel(
      id: json['id'] ?? '',
      deviceId: json['deviceId'] ?? '',
      trackerId: json['tracker_id'] ?? '',
      imei: json['imei'] ?? '',
      vehicleId: json['vehicle_id'] ?? '',
      model: json['model'] ?? '',
      type: json['type'] ?? '',
      registrationNumber: json['registrationNumber'] ?? '',
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      speed: (json['speed'] as num?)?.toDouble(),
      course: (json['course'] as num?)?.toDouble(),
      engineStatus: json['engineStatus'],
      timestamp: json['timestamp'],
      batteryLevel: (json['battery_level'] as num?)?.toDouble(),
      signalStrength: json['signal_strength'],
      status: json['status'],
    );
  }

  bool get isOnline => status == 'ONLINE';
}
