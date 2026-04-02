import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../../../core/exceptions/app_exception.dart';
import '../../../../core/utils/network_utils.dart';
import '../url/login_url.dart';

class LoginApiCalls {

  // ── Register ───────────────────────────────
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String phoneNumber,
    required String password,
    String? fcmToken,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse(LoginUrl.register),
            headers: NetworkUtils.jsonHeaders,
            body: jsonEncode({
              'name': name,
              'email': email,
              'phone_number': int.tryParse(phoneNumber) ?? phoneNumber,
              'password': password,
              'role_id': 2,
              'fcmToken': fcmToken,
            }),
          )
          .timeout(
            const Duration(seconds: 60),
            onTimeout: () => throw TimeoutException(
              408,
              'Request timed out. Please try again.',
            ),
          );
      debugPrint('Register Status: ${response.statusCode}');
      debugPrint('Register Body: ${response.body}');
      return NetworkUtils.handleResponse(response);
    } on TimeoutException {
      throw HttpException(408, 'Request timed out. Please try again.');
    } on http.ClientException {
      throw HttpException(503,
          'Unable to reach the server.\nPlease check your connection.');
    } on HttpException {
      rethrow;
    } catch (e) {
      debugPrint('Register Error: $e');
      throw HttpException(500, 'An unexpected error occurred.');
    }
  }

  // ── Send OTP ───────────────────────────────
  Future<Map<String, dynamic>> sendOtp(String email) async {
    try {
      final response = await http
          .post(
            Uri.parse(LoginUrl.sendOtp),
            headers: NetworkUtils.jsonHeaders,
            body: jsonEncode({'email': email}),
          )
          .timeout(
            const Duration(seconds: 60),
            onTimeout: () => throw TimeoutException(
              408,
              'Request timed out. Please try again.',
            ),
          );
      debugPrint('SendOtp Status: ${response.statusCode}');
      debugPrint('SendOtp Body: ${response.body}');
      return NetworkUtils.handleResponse(response);
    } on TimeoutException {
      throw HttpException(408, 'Request timed out. Please try again.');
    } on http.ClientException {
      throw HttpException(503,
          'Unable to reach the server.\nPlease check your connection.');
    } on HttpException {
      rethrow;
    } catch (e) {
      debugPrint('SendOtp Error: $e');
      throw HttpException(500, 'An unexpected error occurred.');
    }
  }

  // ── Login with OTP ─────────────────────────
  Future<Map<String, dynamic>> loginOtp({
    required String email,
    required String otpCode,
    String? fcmToken,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse(LoginUrl.loginOtp),
            headers: NetworkUtils.jsonHeaders,
            body: jsonEncode({
              'email': email,
              'otpCode': otpCode,
              'fcmToken': fcmToken,
            }),
          )
          .timeout(
            const Duration(seconds: 60),
            onTimeout: () => throw TimeoutException(
              408,
              'Request timed out. Please try again.',
            ),
          );
      debugPrint('LoginOtp Status: ${response.statusCode}');
      debugPrint('LoginOtp Body: ${response.body}');
      return NetworkUtils.handleResponse(response);
    } on TimeoutException {
      throw HttpException(408, 'Request timed out. Please try again.');
    } on http.ClientException {
      throw HttpException(503,
          'Unable to reach the server.\nPlease check your connection.');
    } on HttpException {
      rethrow;
    } catch (e) {
      debugPrint('LoginOtp Error: $e');
      throw HttpException(500, 'An unexpected error occurred.');
    }
  }

// ── Login with password ────────────────────
Future<Map<String, dynamic>> loginWithPassword({
  required String email,
  required String password,
}) async {
  try {
    final response = await http
        .post(
          Uri.parse(LoginUrl.loginPass),
          headers: NetworkUtils.jsonHeaders,
          body: jsonEncode({
            'email': email,
            'password': password,
          }),
        )
        .timeout(
          const Duration(seconds: 60),
          onTimeout: () => throw TimeoutException(
            408,
            'Request timed out. Please try again.',
          ),
        );
    debugPrint('LoginPass Status: ${response.statusCode}');
    debugPrint('LoginPass Body: ${response.body}');
    return NetworkUtils.handleResponse(response);
  } on TimeoutException {
    throw HttpException(408, 'Request timed out. Please try again.');
  } on http.ClientException {
    throw HttpException(
        503, 'Unable to reach the server.\nPlease check your connection.');
  } on HttpException {
    rethrow;
  } catch (e) {
    debugPrint('LoginPass Error: $e');
    throw HttpException(500, 'An unexpected error occurred.');
  }
}

}