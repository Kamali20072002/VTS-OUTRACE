import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/utils/network_utils.dart';
import '../url/profile_url.dart';

class ProfileApiCalls {

  Future<Map<String, dynamic>> getProfile({bool forceRefresh = false}) async {
    return NetworkUtils.getWithCache(
      ProfileUrl.profile,
      forceRefresh: forceRefresh,
      ttlMinutes: 60,
    );
  }

  Future<Map<String, dynamic>> getMyDevices({bool forceRefresh = false}) async {
    return NetworkUtils.getWithCache(
      ProfileUrl.myDevices,
      forceRefresh: forceRefresh,
      ttlMinutes: 30,
    );
  }

  Future<Map<String, dynamic>> getMyVehicles({bool forceRefresh = false}) async {
    return NetworkUtils.getWithCache(
      ProfileUrl.myVehicles,
      forceRefresh: forceRefresh,
      ttlMinutes: 30,
    );
  }

  Future<Map<String, dynamic>> getVehicleTypes({bool forceRefresh = false}) async {
    return NetworkUtils.getWithCache(
      ProfileUrl.vehicleTypes,
      forceRefresh: forceRefresh,
      ttlMinutes: 1440, // Types don't change often, cache for 1 day
    );
  }

  Future<Map<String, dynamic>> getUnassignedDevices({bool forceRefresh = false}) async {
    return NetworkUtils.getWithCache(
      ProfileUrl.unassignedDevices,
      forceRefresh: forceRefresh,
      ttlMinutes: 10,
    );
  }

  Future<Map<String, dynamic>> getVehicleDetails(String id, {bool forceRefresh = false}) async {
    return NetworkUtils.getWithCache(
      ProfileUrl.vehicleDetails(id),
      forceRefresh: forceRefresh,
      ttlMinutes: 30,
    );
  }

  Future<Map<String, dynamic>> getMyAlerts({bool forceRefresh = false}) async {
    return NetworkUtils.getWithCache(
      ProfileUrl.myAlerts,
      forceRefresh: forceRefresh,
      ttlMinutes: 5,
    );
  }

  // POST/PATCH methods remain without automatic caching as they are state-changing
  Future<Map<String, dynamic>> activateDevice(String imei) async {
    final headers = await NetworkUtils.authHeaders();
    final response = await http.post(
      Uri.parse(ProfileUrl.activateDevice),
      headers: headers,
      body: jsonEncode({'imei': imei}),
    ).timeout(const Duration(seconds: 30));
    return NetworkUtils.handleResponse(response);
  }

  Future<Map<String, dynamic>> addVehicle({
    required String registrationNumber,
    required String model,
    required String vehicleType,
    required String deviceId,
  }) async {
    final headers = await NetworkUtils.authHeaders();
    final response = await http.post(
      Uri.parse(ProfileUrl.addVehicle),
      headers: headers,
      body: jsonEncode({
        'registrationNumber': registrationNumber,
        'model': model,
        'vehicleType': vehicleType,
        'deviceId': deviceId,
      }),
    ).timeout(const Duration(seconds: 30));
    return NetworkUtils.handleResponse(response);
  }
  
  Future<Map<String, dynamic>> updateProfile({
    required String name,
    required String phoneNumber,
  }) async {
    final headers = await NetworkUtils.authHeaders();
    final response = await http.patch(
      Uri.parse(ProfileUrl.profile),
      headers: headers,
      body: jsonEncode({
        'name': name,
        'phone_number': int.tryParse(phoneNumber) ?? phoneNumber,
      }),
    ).timeout(const Duration(seconds: 30));
    return NetworkUtils.handleResponse(response);
  }

  Future<Map<String, dynamic>> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    final headers = await NetworkUtils.authHeaders();
    final response = await http.post(
      Uri.parse(ProfileUrl.changePassword),
      headers: headers,
      body: jsonEncode({
        'oldPassword': oldPassword,
        'newPassword': newPassword,
      }),
    ).timeout(const Duration(seconds: 30));
    return NetworkUtils.handleResponse(response);
  }
}
