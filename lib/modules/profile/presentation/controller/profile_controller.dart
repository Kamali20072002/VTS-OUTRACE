import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notix_pro/notix_pro.dart';
import '../../../../core/utils/token_storage.dart';
import '../../../login/presentation/pages/login_screen.dart';

class ProfileController extends GetxController {
  final RxString name  = 'User'.obs;
  final RxString phone = ''.obs;
  final RxString email = ''.obs;
  final RxInt vehicleCount = 3.obs;

  @override
  void onInit() {
    super.onInit();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final savedName  = await TokenStorage.getUserName();
    final savedEmail = await TokenStorage.getUserEmail();
    if (savedName  != null) name.value  = savedName;
    if (savedEmail != null) email.value = savedEmail;
  }

  Future<void> logout(BuildContext context) async {
    NotixDialog.show(
      context,
      type: NotixType.warning,
      title: 'Logout',
      message: 'Are you sure you want to logout?',
      confirmText: 'Logout',
      cancelText: 'Cancel',
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
}