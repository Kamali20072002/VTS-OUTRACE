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
  final double? odometer;

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
    this.odometer,
  });

  factory ActiveVehicleModel.fromJson(Map<String, dynamic> json) {
    // Handle deviceId which can be a String or a Map
    final deviceData = json['deviceId'];
    Map<String, dynamic> deviceMap = {};
    String deviceIdStr = '';
    
    if (deviceData is Map<String, dynamic>) {
      deviceMap = deviceData;
      deviceIdStr = deviceMap['_id'] ?? deviceMap['id'] ?? '';
    } else if (deviceData is String) {
      deviceIdStr = deviceData;
    }

    // Extract status from root or device object
    String? rawStatus = json['status']?.toString().trim();
    if (rawStatus == null || rawStatus.isEmpty || rawStatus == 'null') {
      rawStatus = deviceMap['status']?.toString().trim();
    }

    return ActiveVehicleModel(
      id: json['_id'] ?? json['id'] ?? '',
      deviceId: deviceIdStr,
      trackerId: json['tracker_id'] ?? deviceMap['tracker_id'] ?? '',
      imei: json['imei'] ?? deviceMap['imei'] ?? '',
      vehicleId: json['vehicle_id'] ?? json['_id'] ?? json['id'] ?? '',
      model: json['model'] ?? '',
      type: json['type'] ?? '',
      registrationNumber: json['registrationNumber'] ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 
                (deviceMap['last_latitude'] as num?)?.toDouble() ?? 
                (deviceMap['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble() ?? 
                 (deviceMap['last_longitude'] as num?)?.toDouble() ?? 
                 (deviceMap['longitude'] as num?)?.toDouble(),
      speed: (json['speed'] as num?)?.toDouble() ?? 
             (json['speed_kmh'] as num?)?.toDouble() ??
             (deviceMap['last_speed'] as num?)?.toDouble() ??
             (deviceMap['speed'] as num?)?.toDouble(),
      course: (json['course'] as num?)?.toDouble() ?? 
              (deviceMap['last_course'] as num?)?.toDouble() ??
              (deviceMap['course'] as num?)?.toDouble(),
      engineStatus: json['engineStatus'] ?? deviceMap['engineStatus'],
      timestamp: json['timestamp'] ?? deviceMap['lastSeen'] ?? deviceMap['timestamp'],
      batteryLevel: (json['battery_level'] as num?)?.toDouble() ?? 
                    (deviceMap['battery_level'] as num?)?.toDouble(),
      signalStrength: json['signal_strength'] ?? deviceMap['signal_strength'],
      status: rawStatus?.toUpperCase(),
      odometer: (json['odometer'] as num?)?.toDouble() ?? 
                (deviceMap['odometer'] as num?)?.toDouble(),
    );
  }

  bool get isOnline {
    if (status == 'ONLINE') return true;
    if (status == 'OFFLINE') return false;

    // Fallback logic if explicit status is missing
    if (engineStatus?.toUpperCase() == 'ON' || engineStatus?.toUpperCase() == 'ACTIVE') {
      return true;
    }
    
    if (speed != null && speed! > 0) {
      return true;
    }

    if (timestamp != null) {
      try {
        final lastSeen = DateTime.parse(timestamp!).toLocal();
        final now = DateTime.now();
        // If the device has communicated within the last 15 minutes, it's considered online
        if (now.difference(lastSeen).inMinutes <= 15) {
          return true;
        }
      } catch (_) {}
    }

    return false;
  }

  ActiveVehicleModel copyWith({
    String? id,
    String? deviceId,
    String? trackerId,
    String? imei,
    String? vehicleId,
    String? model,
    String? type,
    String? registrationNumber,
    double? latitude,
    double? longitude,
    double? speed,
    double? course,
    String? engineStatus,
    String? timestamp,
    double? batteryLevel,
    int? signalStrength,
    String? status,
    double? odometer,
  }) {
    return ActiveVehicleModel(
      id: id ?? this.id,
      deviceId: deviceId ?? this.deviceId,
      trackerId: trackerId ?? this.trackerId,
      imei: imei ?? this.imei,
      vehicleId: vehicleId ?? this.vehicleId,
      model: model ?? this.model,
      type: type ?? this.type,
      registrationNumber: registrationNumber ?? this.registrationNumber,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      speed: speed ?? this.speed,
      course: course ?? this.course,
      engineStatus: engineStatus ?? this.engineStatus,
      timestamp: timestamp ?? this.timestamp,
      batteryLevel: batteryLevel ?? this.batteryLevel,
      signalStrength: signalStrength ?? this.signalStrength,
      status: status ?? this.status,
      odometer: odometer ?? this.odometer,
    );
  }
}
