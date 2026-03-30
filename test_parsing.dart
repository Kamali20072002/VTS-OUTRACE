void main() {
  final Map<String, dynamic> json = {
    "odometer": 0,
    "_id": "69c4e225eaa7fa9a13101c30",
    "registrationNumber": "TN-01-AB-5678",
    "model": "Toyota Camry",
    "type": "CAR",
    "deviceId": {
        "status": "ONLINE",
    }
  };

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
  String? rawStatus = json['status']?.toString();
  if (rawStatus == null || rawStatus.trim().isEmpty) {
    rawStatus = deviceMap['status']?.toString();
  }
  
  print("Parsed status: \${rawStatus?.toUpperCase()}");
}
