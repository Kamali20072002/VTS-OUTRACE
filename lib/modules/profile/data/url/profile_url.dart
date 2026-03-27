import '../../../../core/core.dart';

class ProfileUrl {
  static final String profile        = '${AppConfig.baseUrl}/auth/profile';
  static final String myVehicles     = '${AppConfig.baseUrl}/vehicles/my';
  static final String changePassword = '${AppConfig.baseUrl}/auth/change-password';
  static final String myDevices      = '${AppConfig.baseUrl}/devices/my';
  static final String activateDevice = '${AppConfig.baseUrl}/devices/activate';
  static final String addVehicle        = '${AppConfig.baseUrl}/vehicles/register';
  static final String vehicleTypes      = '${AppConfig.baseUrl}/vehicles/types';
  static final String unassignedDevices = '${AppConfig.baseUrl}/devices/unassigned/active';
  static final String myAlerts         = '${AppConfig.baseUrl}/alerts/my';
  static String vehicleDetails(String id) => '${AppConfig.baseUrl}/vehicles/$id';
}