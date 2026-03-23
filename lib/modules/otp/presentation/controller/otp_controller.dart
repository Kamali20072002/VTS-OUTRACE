import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notix_pro/notix_pro.dart';
import '../../../../core/exceptions/app_exception.dart';
import '../../../../core/utils/token_storage.dart';
import '../../../login/domain/repositories/login_repository.dart';
import '../../../../widgets/loading_screen.dart';

class OtpController extends GetxController {
  final List<TextEditingController> ctrls =
      List.generate(4, (_) => TextEditingController());
  final List<FocusNode> nodes =
      List.generate(4, (_) => FocusNode());

  final RxInt    seconds   = 60.obs;
  final RxBool   canResend = false.obs;
  final RxString otp       = ''.obs;
  final RxBool   isLoading = false.obs;

  Timer? _timer;
  final LoginRepository _repo = LoginRepository();

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
    if (value.isNotEmpty && index < 3) nodes[index + 1].requestFocus();
    if (value.isEmpty   && index > 0) nodes[index - 1].requestFocus();
  }

  Future<void> verify(BuildContext context, String email) async {
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

    isLoading.value = true;
    try {
      final response = await _repo.loginOtp(
        email: email,
        otpCode: otp.value,
      );

      if (response.error) {
        NotixToast.show(
          // ignore: use_build_context_synchronously
          context,
          type: NotixType.error,
          title: 'Invalid OTP',
          message: response.message,
          position: NotixToastPosition.top,
        );
        return;
      }

      // Save tokens
      if (response.accessToken != null) {
        await TokenStorage.saveTokens(
          accessToken: response.accessToken!,
          refreshToken: response.refreshToken ?? '',
        );
      }
      if (response.user != null) {
        await TokenStorage.saveUser(
          userId: response.user!.userId,
          name: response.user!.name,
          email: response.user!.email,
        );
      }

      NotixToast.show(
        // ignore: use_build_context_synchronously
        context,
        type: NotixType.success,
        title: 'Verified!',
        message: 'Welcome to Outrace',
        position: NotixToastPosition.top,
      );

      await Future.delayed(const Duration(milliseconds: 1200));
      Get.offAll(
        () => const LoadingScreen(),
        transition: Transition.fadeIn,
        duration: const Duration(milliseconds: 500),
      );
    } on HttpException catch (e) {
      NotixToast.show(
        // ignore: use_build_context_synchronously
        context,
        type: NotixType.error,
        title: 'Error ${e.statusCode}',
        message: e.message,
        position: NotixToastPosition.top,
      );
    } catch (e) {
      NotixToast.show(
        // ignore: use_build_context_synchronously
        context,
        type: NotixType.error,
        title: 'Error',
        message: 'Something went wrong. Please try again.',
        position: NotixToastPosition.top,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> resendOtp(BuildContext context, String email) async {
    if (!canResend.value) return;
    try {
      final response = await _repo.sendOtp(email);
      NotixToast.show(
        // ignore: use_build_context_synchronously
        context,
        type: NotixType.success,
        title: 'OTP Resent',
        message: response.message,
        position: NotixToastPosition.top,
      );
      startTimer();
    } on HttpException catch (e) {
      NotixToast.show(
        // ignore: use_build_context_synchronously
        context,
        type: NotixType.error,
        title: 'Error',
        message: e.message,
        position: NotixToastPosition.top,
      );
    } catch (e) {
      NotixToast.show(
        // ignore: use_build_context_synchronously
        context,
        type: NotixType.error,
        title: 'Error',
        message: 'Failed to resend OTP.',
        position: NotixToastPosition.top,
      );
    }
  }
}