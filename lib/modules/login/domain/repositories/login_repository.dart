import '../models/login_model.dart';
import '../../data/api/login_api.dart';

class LoginRepository {
  final LoginApiCalls _api = LoginApiCalls();

  Future<RegisterResponse> register({
    required String name,
    required String email,
    required String phoneNumber,
    required String password,
  }) async {
    final json = await _api.register(
      name: name,
      email: email,
      phoneNumber: phoneNumber,
      password: password,
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
  }) async {
    final json = await _api.loginOtp(email: email, otpCode: otpCode);
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