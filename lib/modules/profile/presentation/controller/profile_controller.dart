// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notix_pro/notix_pro.dart';
import '../../../../core/exceptions/app_exception.dart';
import '../../../../core/utils/token_storage.dart';
import '../../domain/models/profile_model.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../../login/presentation/pages/login_screen.dart';

class ProfileController extends GetxController {
  final ProfileRepository _repo = ProfileRepository();

  // ── Profile data ───────────────────────────
  final RxString name   = 'User'.obs;
  final RxString email  = ''.obs;
  final RxString phone  = ''.obs;
  final RxString userId = ''.obs;

  // ── Stats ──────────────────────────────────
  final RxInt    vehicleCount       = 0.obs;
  final RxInt    totalTrips         = 0.obs;
  final RxString totalKm            = '0.0'.obs;
  final RxInt    notificationCount  = 0.obs;

  // ── Vehicles ───────────────────────────────
  final RxList<VehicleModel> vehicles = <VehicleModel>[].obs;

  // ── Devices ────────────────────────────────
  final RxList<DeviceModel> myDevices = <DeviceModel>[].obs;

  // ── Loading states ─────────────────────────
  final RxBool isLoading          = false.obs;
  final RxBool isUpdating         = false.obs;
  final RxBool isChangingPass     = false.obs;
  final RxBool isLoadingDevices   = false.obs;
  final RxBool isActivatingDevice = false.obs;
  final RxBool isAddingVehicle    = false.obs;

  // ── Edit profile controllers ───────────────
  final TextEditingController nameEditCtrl  = TextEditingController();
  final TextEditingController phoneEditCtrl = TextEditingController();

  // ── Password controllers ───────────────────
  final TextEditingController oldPassCtrl  = TextEditingController();
  final TextEditingController newPassCtrl  = TextEditingController();
  final TextEditingController confPassCtrl = TextEditingController();
  final RxBool showOldPass  = false.obs;
  final RxBool showNewPass  = false.obs;
  final RxBool showConfPass = false.obs;

  // ── Add vehicle form ───────────────────────
  final TextEditingController regNoCtrl  = TextEditingController();
  final TextEditingController vModelCtrl = TextEditingController();
  final TextEditingController imeiCtrl   = TextEditingController();
  final RxString selectedType     = 'CAR'.obs;
  final RxString selectedDeviceId = ''.obs;

  @override
  void onInit() {
    super.onInit();
    refreshProfile();
    loadMyDevices();
  }

  // ── Load profile ───────────────────────────
  Future<void> refreshProfile() async {
    isLoading.value = true;
    try {
      final json = await _repo.getProfile();
      final data = json['data'] as Map<String, dynamic>?;
      if (data != null) {
        final user  = ProfileModel.fromJson(
            data['user'] as Map<String, dynamic>? ?? {});
        final stats = ProfileStatsModel.fromJson(
            data['stats'] as Map<String, dynamic>? ?? {});

        name.value             = user.name;
        email.value            = user.email;
        phone.value            = user.phoneNumber?.toString() ?? '';
        userId.value           = user.userId;
        vehicleCount.value     = stats.totalVehicles;
        totalTrips.value       = stats.totalTrips;
        totalKm.value          = stats.totalKm;
        notificationCount.value = stats.notificationCount;

        await TokenStorage.saveUser(
          userId: user.userId,
          name: user.name,
          email: user.email,
        );

        nameEditCtrl.text  = user.name;
        phoneEditCtrl.text = user.phoneNumber?.toString() ?? '';
      }
    } on HttpException catch (e) {
      debugPrint('Profile Error: ${e.message}');
      if (Get.context != null) {
        _showError(Get.context!, e.message);
      }
      await _loadFromLocal();
    } catch (e) {
      debugPrint('Profile Error: $e');
      if (Get.context != null) {
        _showError(Get.context!, 'Failed to load profile');
      }
      await _loadFromLocal();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadFromLocal() async {
    final savedName  = await TokenStorage.getUserName();
    final savedEmail = await TokenStorage.getUserEmail();
    if (savedName  != null) name.value  = savedName;
    if (savedEmail != null) email.value = savedEmail;
  }

  // ── Load my devices ────────────────────────
  Future<void> loadMyDevices() async {
    isLoadingDevices.value = true;
    try {
      final list = await _repo.getMyDevices();
      myDevices.value = list;
    } catch (e) {
      debugPrint('Devices Error: $e');
      if (Get.context != null) {
        _showError(Get.context!, 'Failed to load devices');
      }
    } finally {
      isLoadingDevices.value = false;
    }
  }


 // ── Activate device ────────────────────────
  Future<void> activateDevice(BuildContext context) async {
    final imei = imeiCtrl.text.trim();
    if (imei.isEmpty) {
      _showError(context, 'Please enter IMEI number');
      return;
    }
    isActivatingDevice.value = true;
    try {
      final device = await _repo.activateDevice(imei);
      await loadMyDevices();
      imeiCtrl.clear();
      _showSuccess(context, 'Activated!', 'Device activated successfully');
    } on HttpException catch (e) {
      _showError(context, e.message);
    } catch (e) {
      _showError(context, 'Something went wrong. Please try again.');
    } finally {
      isActivatingDevice.value = false;
    }
  }

  // ── Add vehicle ────────────────────────────
  Future<void> addVehicle(BuildContext context) async {
    final regNo  = regNoCtrl.text.trim();
    final model  = vModelCtrl.text.trim();
    final type   = selectedType.value;
    final devId  = selectedDeviceId.value;

    if (regNo.isEmpty) {
      _showError(context, 'Please enter registration number');
      return;
    }
    if (model.isEmpty) {
      _showError(context, 'Please enter vehicle model');
      return;
    }
    if (devId.isEmpty) {
      _showError(context, 'Please select a device');
      return;
    }

    isAddingVehicle.value = true;
    try {
      final json = await _repo.addVehicle(
        registrationNumber: regNo,
        model: model,
        vehicleType: type,
        deviceId: devId,
      );

      if (json['error'] == true) {
        _showError(context, json['message'] as String? ?? 'Failed to add vehicle');
        return;
      }

      // Refresh vehicles
      await loadMyDevices();

      regNoCtrl.clear();
      vModelCtrl.clear();
      selectedDeviceId.value = '';
      selectedType.value = 'CAR';

      _showSuccess(context, 'Vehicle Added!', 'Your vehicle has been added successfully');
      Get.back();
      Get.back();
    } on HttpException catch (e) {
      _showError(context, e.message);
    } catch (e) {
      _showError(context, 'Something went wrong. Please try again.');
    } finally {
      isAddingVehicle.value = false;
    }
  }
  // ── Update profile ─────────────────────────
  Future<void> updateProfile(BuildContext context) async {
    final newName  = nameEditCtrl.text.trim();
    final newPhone = phoneEditCtrl.text.trim();

    if (newName.isEmpty) {
      _showError(context, 'Name cannot be empty');
      return;
    }

    isUpdating.value = true;
    try {
      final json = await _repo.updateProfile(
        name: newName,
        phoneNumber: newPhone,
      );

      if (json['error'] == true) {
        _showError(context,
            json['message'] as String? ?? 'Update failed');
        return;
      }

      name.value  = newName;
      phone.value = newPhone;

      await TokenStorage.saveUser(
        userId: userId.value,
        name: newName,
        email: email.value,
      );

      _showSuccess(context, 'Updated!', 'Profile updated successfully');
      Get.back();
    } on HttpException catch (e) {
      _showError(context, e.message);
    } catch (e) {
      _showError(context, 'Something went wrong. Please try again.');
    } finally {
      isUpdating.value = false;
    }
  }

  // ── Change password ────────────────────────
  Future<void> changePassword(BuildContext context) async {
    final oldPass  = oldPassCtrl.text.trim();
    final newPass  = newPassCtrl.text.trim();
    final confPass = confPassCtrl.text.trim();

    if (oldPass.isEmpty) {
      _showError(context, 'Please enter your current password');
      return;
    }
    if (newPass.length < 6) {
      _showError(context, 'New password must be at least 6 characters');
      return;
    }
    if (newPass != confPass) {
      _showError(context, 'Passwords do not match');
      return;
    }

    isChangingPass.value = true;
    try {
      final json = await _repo.changePassword(
        oldPassword: oldPass,
        newPassword: newPass,
      );

      if (json['error'] == true) {
        _showError(context,
            json['message'] as String? ?? 'Password change failed');
        return;
      }

      oldPassCtrl.clear();
      newPassCtrl.clear();
      confPassCtrl.clear();

      _showSuccess(context, 'Success!', 'Password changed successfully');
      Get.back();
    } on HttpException catch (e) {
      _showError(context, e.message);
    } catch (e) {
      _showError(context, 'Something went wrong. Please try again.');
    } finally {
      isChangingPass.value = false;
    }
  }

  // ── Logout ─────────────────────────────────
  Future<void> logout(BuildContext context) async {
    NotixDialog.show(
      context,
      type: NotixType.warning,
      theme: NotixTheme(
        animationStyle: NotixAnimationStyle.flip,
      ),
      title: 'Logout',
      message: 'Are you sure you want to logout?',
      confirmText: 'Logout',
      cancelText: 'Cancel',
      onCancel: () {},
      onConfirm: () async {
        await TokenStorage.clearAll();
        Get.offAll(
          () => const LoginScreen(),
          transition: Transition.fadeIn,
          duration: const Duration(milliseconds: 500),
        );
      },
    );
  }

  // ── Helpers ────────────────────────────────
  void _showError(BuildContext context, String message) {
    NotixToast.show(context,
        type: NotixType.error,
        title: 'Error',
        message: message,
        position: NotixToastPosition.top);
  }

  void _showSuccess(BuildContext context, String title, String message) {
    NotixToast.show(context,
        type: NotixType.success,
        title: title,
        message: message,
        position: NotixToastPosition.top);
  }
}