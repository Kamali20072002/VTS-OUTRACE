import '../../../../core/core.dart';

class LoginUrl {
  static final String register = '${AppConfig.baseUrl}/auth/register';
  static final String sendOtp  = '${AppConfig.baseUrl}/auth/send-otp';
  static final String loginOtp = '${AppConfig.baseUrl}/auth/login-otp';
  static final String loginPass  = '${AppConfig.baseUrl}/auth/login';

}