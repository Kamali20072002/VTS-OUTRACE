import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notix_pro/notix_pro.dart';
import '../../../otp/presentation/pages/otp_screen.dart';

class LoginController extends GetxController {
  final TextEditingController phoneCtrl = TextEditingController();
  final FocusNode focusNode = FocusNode();
  final RxBool isFocused = false.obs;

  @override
  void onInit() {
    super.onInit();
    focusNode.addListener(() {
      isFocused.value = focusNode.hasFocus;
    });
  }

  @override
  void onClose() {
    phoneCtrl.dispose();
    focusNode.dispose();
    super.onClose();
  }

  void sendOtp(BuildContext context) {
    if (phoneCtrl.text.length < 10) {
      NotixToast.show(
        context,
        type: NotixType.error,
        title: 'Invalid Number',
        message: 'Please enter a valid 10-digit mobile number',
        position: NotixToastPosition.top,
      );
      return;
    }
    Get.to(() => OtpScreen(phone: '+91 ${phoneCtrl.text}'));
  }
}