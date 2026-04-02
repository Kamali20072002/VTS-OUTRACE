import '../models/login_model.dart';
import '../../data/api/login_api.dart';

class LoginRepository {
  final LoginApiCalls _api = LoginApiCalls();

  Future<RegisterResponse> register({
    required String name,
    required String email,
    required String phoneNumber,
    required String password,
    String? fcmToken,
  }) async {
    final json = await _api.register(
      name: name,
      email: email,
      phoneNumber: phoneNumber,
      password: password,
      fcmToken: fcmToken,
    );
    return RegisterResponse.fromJson(json);
  }

  Future<SendOtpResponse> sendOtp(String email) async {
    final json = await _api.sendOtp(email);
    return SendOtpResponse.fromJson(json);
  }

  Future<LoginOtpResponse> loginOtp({
    required String email,
    required String otpCode,
    String? fcmToken,
  }) async {
    final json = await _api.loginOtp(
      email: email,
      otpCode: otpCode,
      fcmToken: fcmToken,
    );
    return LoginOtpResponse.fromJson(json);
  }

  Future<LoginPasswordResponse> loginWithPassword({
  required String email,
  required String password,
}) async {
  final json = await _api.loginWithPassword(
    email: email,
    password: password,
  );
  return LoginPasswordResponse.fromJson(json);
}
}