import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../exceptions/app_exception.dart';
import 'token_storage.dart';
import '../../modules/login/presentation/pages/login_screen.dart';

class NetworkUtils {
  static Map<String, dynamic> handleResponse(
    http.Response response, {
    bool autoLogout = true,
  }) {
    debugPrint('Status: ${response.statusCode}');
    debugPrint('Body: ${response.body}');

    final body = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    }

    // Token expired or unauthorized
    if (response.statusCode == 401 && autoLogout) {
      _handleUnauthorized();
    }

    final message = body['message'] as String? ??
        _getDefaultErrorMessage(response.statusCode);

    throw HttpException(response.statusCode, message);
  }

  static void _handleUnauthorized() async {
    await TokenStorage.clearAll();
    Get.offAll(
      () => const LoginScreen(),
      transition: Transition.fadeIn,
      duration: const Duration(milliseconds: 500),
    );
  }

  static String _getDefaultErrorMessage(int statusCode) {
    switch (statusCode) {
      case 400: return 'Invalid request. Please check your input.';
      case 401: return 'Session expired. Please login again.';
      case 403: return 'You do not have permission to access this resource.';
      case 404: return 'The requested resource was not found.';
      case 500: return 'Server error. Please try again later.';
      case 503: return 'Service unavailable. Please try again later.';
      default:  return 'An unexpected error occurred. Please try again.';
    }
  }

  static Map<String, String> get jsonHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  static Future<Map<String, String>> authHeaders() async {
    final token = await TokenStorage.getAccessToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }
}
