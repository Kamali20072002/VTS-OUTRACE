import 'dart:async';
import 'package:http/http.dart' as http;
import '../../../../core/exceptions/app_exception.dart';
import '../../../../core/utils/network_utils.dart';
import '../url/track_url.dart';

class TrackApiCalls {
  Future<Map<String, dynamic>> getActiveVehicles() async {
    try {
      final headers = await NetworkUtils.authHeaders();
      final response = await http
          .get(Uri.parse(TrackUrl.activeVehicles), headers: headers)
          .timeout(const Duration(seconds: 30),
              onTimeout: () =>
                  throw TimeoutException(408, 'Request timed out.'));
      return NetworkUtils.handleResponse(response);
    } on TimeoutException {
      throw HttpException(408, 'Request timed out. Please try again.');
    } on http.ClientException {
      throw HttpException(503, 'Error:connect ECONNREFUSED');
    } on HttpException {
      rethrow;
    } catch (e) {
      throw HttpException(500, 'An unexpected error occurred.');
    }
  }
}
