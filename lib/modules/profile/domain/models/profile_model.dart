class ProfileModel {
  final String userId;
  final String name;
  final String email;
  final dynamic phoneNumber;
  final int roleId;
  final bool status;
  final bool isBlocked;
  final String createdAt;

  ProfileModel({
    required this.userId,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.roleId,
    required this.status,
    required this.isBlocked,
    required this.createdAt,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      userId: json['user_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phoneNumber: json['phone_number'],
      roleId: json['role_id'] as int? ?? 0,
      status: json['status'] as bool? ?? false,
      isBlocked: json['isBlocked'] as bool? ?? false,
      createdAt: json['createdAt'] as String? ?? '',
    );
  }
}

class ProfileStatsModel {
  final int totalVehicles;
  final int totalTrips;
  final String totalKm;
  final int notificationCount;

  ProfileStatsModel({
    required this.totalVehicles,
    required this.totalTrips,
    required this.totalKm,
    required this.notificationCount,
  });

  factory ProfileStatsModel.fromJson(Map<String, dynamic> json) {
    return ProfileStatsModel(
      totalVehicles: json['totalVehicles'] as int? ?? 0,
      totalTrips: json['totalTrips'] as int? ?? 0,
      totalKm: json['totalKm']?.toString() ?? '0.0',
      notificationCount: json['notificationCount'] as int? ?? 0,
    );
  }
}

class VehicleModel {
  final String id;
  final String registrationNumber;
  final String model;
  final String type;
  final String status;
  final int batteryLevel;
  final int fuelLevel;
  final String? lastSeen;
  final String? trackerId;
  final String? imei;
  final double? lastLatitude;
  final double? lastLongitude;
  final int? lastCourse;
  final List<RecentTrip>? recentTrips;

  VehicleModel({
    required this.id,
    required this.registrationNumber,
    required this.model,
    required this.type,
    required this.status,
    required this.batteryLevel,
    required this.fuelLevel,
    this.lastSeen,
    this.trackerId,
    this.imei,
    this.lastLatitude,
    this.lastLongitude,
    this.lastCourse,
    this.recentTrips,
  });

  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    final deviceData = json['deviceId'];
    final device = deviceData is Map<String, dynamic> ? deviceData : null;
    final trips = json['recentTrips'] as List<dynamic>?;

    // Standardized status parsing
    String? rawStatus = json['status']?.toString().trim();
    if (rawStatus == null || rawStatus.isEmpty || rawStatus == 'null') {
      rawStatus = device?['status']?.toString().trim();
    }

    return VehicleModel(
      id: json['_id'] as String? ?? '',
      registrationNumber: json['registrationNumber'] as String? ?? '',
      model: json['model'] as String? ?? '',
      type: json['type'] as String? ?? 'CAR',
      status: rawStatus?.toUpperCase() ?? 'OFFLINE',
      batteryLevel: (device?['battery_level'] as num?)?.toInt() ?? 0,
      fuelLevel: (device?['fuel_level'] as num?)?.toInt() ?? 0,
      lastSeen: device?['lastSeen'] as String?,
      trackerId: device?['tracker_id'] as String?,
      imei: device?['imei'] as String?,
      lastLatitude: (device?['last_latitude'] as num?)?.toDouble(),
      lastLongitude: (device?['last_longitude'] as num?)?.toDouble(),
      lastCourse: (device?['last_course'] as num?)?.toInt(),
      recentTrips: trips != null
          ? trips.map((t) => RecentTrip.fromJson(t as Map<String, dynamic>)).toList()
          : null,
    );
  }

  bool get isOnline {
    if (status == 'ONLINE') return true;
    
    if (lastSeen != null) {
      try {
        final last = DateTime.parse(lastSeen!).toLocal();
        if (DateTime.now().difference(last).inMinutes <= 15) {
          return true;
        }
      } catch (_) {}
    }
    
    return false;
  }

  String get vehicleImage {
    switch (type.toUpperCase()) {
      case 'TRUCK': return 'assets/images/truck_hero.jpg';
      case 'BIKE':  return 'assets/images/bike_hero.jpg';
      case 'BUS':   return 'assets/images/bus_hero.jpg';
      default:      return 'assets/images/bmw_x6.jpg';
    }
  }

  String get typeIcon {
    switch (type.toUpperCase()) {
      case 'TRUCK': return '🚛';
      case 'BIKE':  return '🏍️';
      case 'BUS':   return '🚌';
      default:      return '🚗';
    }
  }
}

class DeviceModel {
  final String id;
  final String imei;
  final String trackerId;
  final String status;
  final bool isActivated;
  final int batteryLevel;
  final int fuelLevel;
  final String moduleModel;
  final String? lastSeen;

  DeviceModel({
    required this.id,
    required this.imei,
    required this.trackerId,
    required this.status,
    required this.isActivated,
    required this.batteryLevel,
    required this.fuelLevel,
    required this.moduleModel,
    this.lastSeen,
  });

  factory DeviceModel.fromJson(Map<String, dynamic> json) {
    return DeviceModel(
      id: json['_id'] as String? ?? '',
      imei: json['imei'] as String? ?? '',
      trackerId: json['tracker_id'] as String? ?? '',
      status: json['status'] as String? ?? 'OFFLINE',
      isActivated: json['isActivated'] as bool? ?? false,
      batteryLevel: (json['battery_level'] as num?)?.toInt() ?? 0,
      fuelLevel: (json['fuel_level'] as num?)?.toInt() ?? 0,
      moduleModel: json['module_model'] as String? ?? '',
      lastSeen: json['lastSeen'] as String?,
    );
  }
}

class RecentTrip {
  final String id;
  final String startTime;
  final double distance;
  final double duration;
  final String status;
  final TripPathPoint startLocation;
  final TripPathPoint endLocation;
  final List<TripPathPoint> path;

  RecentTrip({
    required this.id,
    required this.startTime,
    required this.distance,
    required this.duration,
    required this.status,
    required this.startLocation,
    required this.endLocation,
    required this.path,
  });

  factory RecentTrip.fromJson(Map<String, dynamic> json) {
    final pathData = json['path'] as List<dynamic>? ?? [];
    return RecentTrip(
      id: json['_id'] as String? ?? '',
      startTime: json['startTime'] as String? ?? '',
      distance: (json['distance'] as num?)?.toDouble() ?? 0.0,
      duration: (json['duration'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] as String? ?? 'COMPLETED',
      startLocation: TripPathPoint.fromJson(json['startLocation'] is Map ? json['startLocation'] as Map<String, dynamic> : {}),
      endLocation: TripPathPoint.fromJson(json['endLocation'] is Map ? json['endLocation'] as Map<String, dynamic> : {}),
      path: pathData.map((p) => TripPathPoint.fromJson(p is Map ? p as Map<String, dynamic> : {})).toList(),
    );
  }
}

class TripPathPoint {
  final double lat;
  final double lon;
  final String? address;
  final String? area;
  final String? landmark;
  final String? city;
  final String? state;
  final String? country;
  final String? pincode;
  final String timestamp;
  final double speed;

  TripPathPoint({
    required this.lat,
    required this.lon,
    this.address,
    this.area,
    this.landmark,
    this.city,
    this.state,
    this.country,
    this.pincode,
    required this.timestamp,
    required this.speed,
  });

  factory TripPathPoint.fromJson(Map<String, dynamic> json) {
    return TripPathPoint(
      lat: (json['lat'] as num?)?.toDouble() ?? 0.0,
      lon: (json['lon'] as num?)?.toDouble() ?? 0.0,
      address: json['address'] as String?,
      area: json['area'] as String?,
      landmark: json['landmark'] as String?,
      city: json['city'] as String?,
      state: json['state'] as String?,
      country: json['country'] as String?,
      pincode: json['pincode'] as String?,
      timestamp: json['timestamp'] as String? ?? '',
      speed: (json['speed'] as num?)?.toDouble() ?? 0.0,
    );
  }

  String get displayName {
    if (area != null && area!.isNotEmpty) return area!;
    if (address != null && address!.isNotEmpty) return address!;
    return '${lat.toStringAsFixed(4)}, ${lon.toStringAsFixed(4)}';
  }
}