class RegisterResponse {
  final bool error;
  final String message;
  final String? accessToken;
  final String? refreshToken;
  final UserModel? user;

  RegisterResponse({
    required this.error,
    required this.message,
    this.accessToken,
    this.refreshToken,
    this.user,
  });

  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>?;
    return RegisterResponse(
      error: json['error'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      accessToken: data?['accessToken'] as String?,
      refreshToken: data?['refreshToken'] as String?,
      user: data?['user'] != null
          ? UserModel.fromJson(data!['user'] as Map<String, dynamic>)
          : null,
    );
  }
}

class SendOtpResponse {
  final bool error;
  final String message;

  SendOtpResponse({required this.error, required this.message});

  factory SendOtpResponse.fromJson(Map<String, dynamic> json) {
    return SendOtpResponse(
      error: json['error'] as bool? ?? false,
      message: json['message'] as String? ?? '',
    );
  }
}

class LoginOtpResponse {
  final bool error;
  final String message;
  final String? accessToken;
  final String? refreshToken;
  final UserModel? user;

  LoginOtpResponse({
    required this.error,
    required this.message,
    this.accessToken,
    this.refreshToken,
    this.user,
  });

  factory LoginOtpResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>?;
    return LoginOtpResponse(
      error: json['error'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      accessToken: data?['accessToken'] as String?,
      refreshToken: data?['refreshToken'] as String?,
      user: data?['user'] != null
          ? UserModel.fromJson(data!['user'] as Map<String, dynamic>)
          : null,
    );
  }
}

class LoginPasswordResponse {
  final bool error;
  final String message;
  final String? accessToken;
  final String? refreshToken;
  final UserModel? user;

  LoginPasswordResponse({
    required this.error,
    required this.message,
    this.accessToken,
    this.refreshToken,
    this.user,
  });

  factory LoginPasswordResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>?;
    return LoginPasswordResponse(
      error: json['error'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      accessToken: data?['accessToken'] as String?,
      refreshToken: data?['refreshToken'] as String?,
      user: data?['user'] != null
          ? UserModel.fromJson(data!['user'] as Map<String, dynamic>)
          : null,
    );
  }
}

class UserModel {
  final String userId;
  final String name;
  final String email;
  final dynamic phoneNumber;
  final int roleId;
  final String roleName;

  UserModel({
    required this.userId,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.roleId,
    required this.roleName,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['user_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phoneNumber: json['phone_number'],
      roleId: json['role_id'] as int? ?? 0,
      roleName: json['role_name'] as String? ?? '',
    );
  }
}