import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../../../core/exceptions/app_exception.dart';
import '../../../../core/utils/network_utils.dart';
import '../../../../core/utils/token_storage.dart';
import '../url/profile_url.dart';

class ProfileApiCalls {

  Future<Map<String, dynamic>> getProfile() async {
    try {
      final headers = await NetworkUtils.authHeaders();
      final response = await http
          .get(Uri.parse(ProfileUrl.profile), headers: headers)
          .timeout(const Duration(seconds: 60),
              onTimeout: () =>
                  throw TimeoutException(408, 'Request timed out.'));
      debugPrint('Profile Status: ${response.statusCode}');
      debugPrint('Profile Body: ${response.body}');
      return NetworkUtils.handleResponse(response);
    } on TimeoutException {
      throw HttpException(408, 'Request timed out. Please try again.');
    } on http.ClientException {
      throw HttpException(503, 'Error:connect ECONNREFUSED 172.235.29.67:4000');
    } on HttpException {
      rethrow;
    } catch (e) {
      debugPrint('GetProfile Error: $e');
      throw HttpException(500, 'An unexpected error occurred.');
    }
  }

  Future<Map<String, dynamic>> getMyDevices() async {
    try {
      final headers = await NetworkUtils.authHeaders();
      final response = await http
          .get(Uri.parse(ProfileUrl.myDevices), headers: headers)
          .timeout(const Duration(seconds: 60),
              onTimeout: () =>
                  throw TimeoutException(408, 'Request timed out.'));
      return NetworkUtils.handleResponse(response);
    } on TimeoutException {
      throw HttpException(408, 'Request timed out.');
    } on http.ClientException {
      throw HttpException(503, 'Error:connect ECONNREFUSED 172.235.29.67:4000');
    } on HttpException {
      rethrow;
    } catch (e) {
      throw HttpException(500, 'An unexpected error occurred.');
    }
  }

  Future<Map<String, dynamic>> activateDevice(String imei) async {
    try {
      final headers = await NetworkUtils.authHeaders();
      final response = await http
          .post(
            Uri.parse(ProfileUrl.activateDevice),
            headers: headers,
            body: jsonEncode({'imei': imei}),
          )
          .timeout(const Duration(seconds: 60),
              onTimeout: () =>
                  throw TimeoutException(408, 'Request timed out.'));
      return NetworkUtils.handleResponse(response);
    } on TimeoutException {
      throw HttpException(408, 'Request timed out.');
    } on http.ClientException {
      throw HttpException(503, 'Error:connect ECONNREFUSED 172.235.29.67:4000');
    } on HttpException {
      rethrow;
    } catch (e) {
      throw HttpException(500, 'An unexpected error occurred.');
    }
  }

  Future<Map<String, dynamic>> addVehicle({
    required String registrationNumber,
    required String model,
    required String vehicleType,
    required String deviceId,
  }) async {
    try {
      final headers = await NetworkUtils.authHeaders();
      final response = await http
          .post(
            Uri.parse(ProfileUrl.addVehicle),
            headers: headers,
            body: jsonEncode({
              'registrationNumber': registrationNumber,
              'model': model,
              'vehicleType': vehicleType,
              'deviceId': deviceId,
            }),
          )
          .timeout(const Duration(seconds: 60),
              onTimeout: () =>
                  throw TimeoutException(408, 'Request timed out.'));
      return NetworkUtils.handleResponse(response);
    } on TimeoutException {
      throw HttpException(408, 'Request timed out.');
    } on http.ClientException {
      throw HttpException(503, 'Error:connect ECONNREFUSED 172.235.29.67:4000');
    } on HttpException {
      rethrow;
    } catch (e) {
      throw HttpException(500, 'An unexpected error occurred.');
    }
  }
  
  Future<Map<String, dynamic>> updateProfile({
    required String name,
    required String phoneNumber,
  }) async {
    try {
      final headers = await NetworkUtils.authHeaders();
      final response = await http
          .patch(
            Uri.parse(ProfileUrl.profile),
            headers: headers,
            body: jsonEncode({
              'name': name,
              'phone_number': int.tryParse(phoneNumber) ?? phoneNumber,
            }),
          )
          .timeout(const Duration(seconds: 60),
              onTimeout: () =>
                  throw TimeoutException(408, 'Request timed out.'));
      debugPrint('UpdateProfile Status: ${response.statusCode}');
      debugPrint('UpdateProfile Body: ${response.body}');
      return NetworkUtils.handleResponse(response);
    } on TimeoutException {
      throw HttpException(408, 'Request timed out. Please try again.');
    } on http.ClientException {
      throw HttpException(503, 'Error:connect ECONNREFUSED 172.235.29.67:4000');
    } on HttpException {
      rethrow;
    } catch (e) {
      debugPrint('UpdateProfile Error: $e');
      throw HttpException(500, 'An unexpected error occurred.');
    }
  }

  Future<Map<String, dynamic>> getMyVehicles() async {
    try {
      final headers = await NetworkUtils.authHeaders();
      final response = await http
          .get(Uri.parse(ProfileUrl.myVehicles), headers: headers)
          .timeout(const Duration(seconds: 60),
              onTimeout: () =>
                  throw TimeoutException(408, 'Request timed out.'));
      return NetworkUtils.handleResponse(response);
    } on TimeoutException {
      throw HttpException(408, 'Request timed out.');
    } on http.ClientException {
      throw HttpException(503, 'Error:connect ECONNREFUSED 172.235.29.67:4000');
    } on HttpException {
      rethrow;
    } catch (e) {
      throw HttpException(500, 'An unexpected error occurred.');
    }
  }

  Future<Map<String, dynamic>> getVehicleTypes() async {
    try {
      final headers = await NetworkUtils.authHeaders();
      final response = await http
          .get(Uri.parse(ProfileUrl.vehicleTypes), headers: headers)
          .timeout(const Duration(seconds: 60),
              onTimeout: () =>
                  throw TimeoutException(408, 'Request timed out.'));
      return NetworkUtils.handleResponse(response);
    } on TimeoutException {
      throw HttpException(408, 'Request timed out.');
    } on http.ClientException {
      throw HttpException(503, 'Error:connect ECONNREFUSED 172.235.29.67:4000');
    } on HttpException {
      rethrow;
    } catch (e) {
      throw HttpException(500, 'An unexpected error occurred.');
    }
  }

  Future<Map<String, dynamic>> getUnassignedDevices() async {
    try {
      final headers = await NetworkUtils.authHeaders();
      final response = await http
          .get(Uri.parse(ProfileUrl.unassignedDevices), headers: headers)
          .timeout(const Duration(seconds: 60),
              onTimeout: () =>
                  throw TimeoutException(408, 'Request timed out.'));
      return NetworkUtils.handleResponse(response);
    } on TimeoutException {
      throw HttpException(408, 'Request timed out.');
    } on http.ClientException {
      throw HttpException(503, 'Error:connect ECONNREFUSED 172.235.29.67:4000');
    } on HttpException {
      rethrow;
    } catch (e) {
      throw HttpException(500, 'An unexpected error occurred.');
    }
  }

  Future<Map<String, dynamic>> getVehicleDetails(String id) async {
    try {
      final headers = await NetworkUtils.authHeaders();
      final response = await http
          .get(Uri.parse(ProfileUrl.vehicleDetails(id)), headers: headers)
          .timeout(const Duration(seconds: 60),
              onTimeout: () =>
                  throw TimeoutException(408, 'Request timed out.'));
      return NetworkUtils.handleResponse(response);
    } on TimeoutException {
      throw HttpException(408, 'Request timed out.');
    } on http.ClientException {
      throw HttpException(503, 'Error:connect ECONNREFUSED 172.235.29.67:4000');
    } on HttpException {
      rethrow;
    } catch (e) {
      throw HttpException(500, 'An unexpected error occurred.');
    }
  }

  Future<Map<String, dynamic>> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      final headers = await NetworkUtils.authHeaders();
      final response = await http
          .post(
            Uri.parse(ProfileUrl.changePassword),
            headers: headers,
            body: jsonEncode({
              'oldPassword': oldPassword,
              'newPassword': newPassword,
            }),
          )
          .timeout(const Duration(seconds: 60),
              onTimeout: () =>
                  throw TimeoutException(408, 'Request timed out.'));
      debugPrint('ChangePassword Status: ${response.statusCode}');
      debugPrint('ChangePassword Body: ${response.body}');
      return NetworkUtils.handleResponse(response);
    } on TimeoutException {
      throw HttpException(408, 'Request timed out. Please try again.');
    } on http.ClientException {
      throw HttpException(503, 'Error:connect ECONNREFUSED 172.235.29.67:4000');
    } on HttpException {
      rethrow;
    } catch (e) {
      debugPrint('ChangePassword Error: $e');
      throw HttpException(500, 'An unexpected error occurred.');
    }
  }

  Future<Map<String, dynamic>> getMyAlerts() async {
    try {
      final headers = await NetworkUtils.authHeaders();
      final response = await http
          .get(Uri.parse(ProfileUrl.myAlerts), headers: headers)
          .timeout(const Duration(seconds: 60),
              onTimeout: () =>
                  throw TimeoutException(408, 'Request timed out.'));
      return NetworkUtils.handleResponse(response);
    } on TimeoutException {
      throw HttpException(408, 'Request timed out.');
    } on http.ClientException {
      throw HttpException(503, 'Error:connect ECONNREFUSED 172.235.29.67:4000');
    } on HttpException {
      rethrow;
    } catch (e) {
      throw HttpException(500, 'An unexpected error occurred.');
    }
  }
}