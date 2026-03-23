import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notix_pro/notix_pro.dart';
import 'package:outrace/widgets/loading_screen.dart';

class OtpController extends GetxController {
  final List<TextEditingController> ctrls =
      List.generate(4, (_) => TextEditingController());
  final List<FocusNode> nodes = List.generate(4, (_) => FocusNode());

  final RxInt seconds = 60.obs;
  final RxBool canResend = false.obs;
  final RxString otp = ''.obs;

  Timer? _timer;

  @override
  void onInit() {
    super.onInit();
    startTimer();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => nodes[0].requestFocus(),
    );
    for (int i = 0; i < 4; i++) {
      nodes[i].addListener(() => update());
    }
  }

  @override
  void onClose() {
    for (final c in ctrls) {
      c.dispose();
    }
    for (final n in nodes) {
      n.dispose();
    }
    _timer?.cancel();
    super.onClose();
  }

  void startTimer() {
    seconds.value = 60;
    canResend.value = false;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (seconds.value == 0) {
        t.cancel();
        canResend.value = true;
      } else {
        seconds.value--;
      }
    });
  }

  String get timerText {
    final m = (seconds.value ~/ 60).toString().padLeft(2, '0');
    final s = (seconds.value % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  void onDigitChanged(int index, String value) {
    otp.value = ctrls.map((c) => c.text).join();
    if (value.isNotEmpty && index < 3) {
      nodes[index + 1].requestFocus();
    }
    if (value.isEmpty && index > 0) {
      nodes[index - 1].requestFocus();
    }
  }

  void verify(BuildContext context) {
    if (otp.value.length < 4) {
      NotixToast.show(
        context,
        type: NotixType.error,
        title: 'Incomplete OTP',
        message: 'Please enter the complete 4-digit OTP',
        position: NotixToastPosition.top,
      );
      return;
    }

    // Show success toast first
    NotixToast.show(
      context,
      type: NotixType.success,
      title: 'Verified!',
      message: 'Welcome to Outrace',
      position: NotixToastPosition.top,
    );

    // After toast shows, go to loading screen
    Future.delayed(const Duration(milliseconds: 1200), () {
      Get.off(
        () => const LoadingScreen(),
        transition: Transition.fadeIn,
        duration: const Duration(milliseconds: 500),
      );
    });
  }}