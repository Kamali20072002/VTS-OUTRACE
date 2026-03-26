import '../models/profile_model.dart';
import '../../data/api/profile_api.dart';

class ProfileRepository {
  final ProfileApiCalls _api = ProfileApiCalls();

  Future<Map<String, dynamic>> getProfile() async {
    return await _api.getProfile();
  }

  Future<List<DeviceModel>> getMyDevices() async {
    final json = await _api.getMyDevices();
    final data = json['data'] as List<dynamic>? ?? [];
    return data
        .map((d) => DeviceModel.fromJson(d as Map<String, dynamic>))
        .toList();
  }

  Future<List<VehicleModel>> getMyVehicles() async {
    final json = await _api.getMyVehicles();
    final data = json['data'] as List<dynamic>? ?? [];
    return data
        .map((d) => VehicleModel.fromJson(d as Map<String, dynamic>))
        .toList();
  }

  Future<Map<String, String>> getVehicleTypes() async {
    final json = await _api.getVehicleTypes();
    final data = json['data'] as Map<String, dynamic>? ?? {};
    return data.map((key, value) => MapEntry(key, value.toString()));
  }

  Future<List<DeviceModel>> getUnassignedDevices() async {
    final json = await _api.getUnassignedDevices();
    final data = json['data'] as List<dynamic>? ?? [];
    return data
        .map((d) => DeviceModel.fromJson(d as Map<String, dynamic>))
        .toList();
  }

  Future<Map<String, dynamic>> getVehicleDetails(String id) async {
    return await _api.getVehicleDetails(id);
  }

  Future<DeviceModel> activateDevice(String imei) async {
    final json = await _api.activateDevice(imei);
    final data = json['data'] as Map<String, dynamic>? ?? {};
    return DeviceModel.fromJson(data);
  }

  Future<Map<String, dynamic>> addVehicle({
    required String registrationNumber,
    required String model,
    required String vehicleType,
    required String deviceId,
  }) async {
    return await _api.addVehicle(
      registrationNumber: registrationNumber,
      model: model,
      vehicleType: vehicleType,
      deviceId: deviceId,
    );
  }

  Future<Map<String, dynamic>> updateProfile({
    required String name,
    required String phoneNumber,
  }) async {
    return await _api.updateProfile(name: name, phoneNumber: phoneNumber);
  }

  Future<Map<String, dynamic>> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    return await _api.changePassword(
      oldPassword: oldPassword,
      newPassword: newPassword,
    );
  }
}