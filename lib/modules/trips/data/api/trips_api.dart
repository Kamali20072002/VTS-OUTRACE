import 'dart:async';
import 'package:http/http.dart' as http;
import '../../../../core/exceptions/app_exception.dart';
import '../../../../core/utils/network_utils.dart';
import '../url/trips_url.dart';

class TripsApi {
  Future<Map<String, dynamic>> fetchMyTrips() async {
    try {
      final response = await http
          .get(
            Uri.parse(TripsUrl.myTrips),
            headers: await NetworkUtils.authHeaders(),
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () => throw TimeoutException(
              408,
              'Request timed out. Please try again.',
            ),
          );
      return NetworkUtils.handleResponse(response);
    } on TimeoutException {
      throw HttpException(408, 'Request timed out. Please try again.');
    } on http.ClientException {
      throw HttpException(503, 'Unable to reach the server. Please check your connection.');
    } on HttpException {
      rethrow;
    } catch (e) {
      throw HttpException(500, 'An unexpected error occurred.');
    }
  }
}
