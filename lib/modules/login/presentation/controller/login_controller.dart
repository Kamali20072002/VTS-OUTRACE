import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notix_pro/notix_pro.dart';
import '../../../../core/exceptions/app_exception.dart';
import '../../../../core/utils/token_storage.dart';
import '../../domain/repositories/login_repository.dart';
import '../../../otp/presentation/pages/otp_screen.dart';
import '../../../../widgets/loading_screen.dart';

class LoginController extends GetxController {
  // ── Login fields ───────────────────────────
  final TextEditingController emailCtrl    = TextEditingController();
  final TextEditingController passCtrl     = TextEditingController();
  final FocusNode focusNode                = FocusNode();
  final RxBool isFocused                   = false.obs;
  final RxBool isLoading                   = false.obs;
  final RxBool showLoginPass               = false.obs;

  // ── Login method toggle: otp | password ───
  final RxString loginMethod               = 'otp'.obs;

  // ── Register fields ────────────────────────
  final TextEditingController nameCtrl     = TextEditingController();
  final TextEditingController regEmailCtrl = TextEditingController();
  final TextEditingController phoneCtrl    = TextEditingController();
  final TextEditingController passwordCtrl = TextEditingController();
  final RxBool showPassword                = false.obs;
  final RxBool isRegLoading                = false.obs;

  // ── Tab: 0=login 1=register ────────────────
  final RxInt activeTab                    = 0.obs;

  final LoginRepository _repo = LoginRepository();

  @override
  void onInit() {
    super.onInit();
    focusNode.addListener(() => isFocused.value = focusNode.hasFocus);
  }

  @override
  void onClose() {
    emailCtrl.dispose();
    passCtrl.dispose();
    nameCtrl.dispose();
    regEmailCtrl.dispose();
    phoneCtrl.dispose();
    passwordCtrl.dispose();
    focusNode.dispose();
    super.onClose();
  }

  // ── Send OTP for login ─────────────────────
  Future<void> sendOtp(BuildContext context) async {
    final email = emailCtrl.text.trim();

    if (email.isEmpty || !email.contains('@')) {
      _showError(context, 'Please enter a valid email address');
      return;
    }

    isLoading.value = true;
    try {
      final response = await _repo.sendOtp(email);

      if (response.error) {
        _showError(context, response.message);
        return;
      }

      _showSuccess(context, 'OTP Sent', response.message);
      await Future.delayed(const Duration(milliseconds: 600));
      Get.to(() => OtpScreen(phone: email));
    } on HttpException catch (e) {
      _showError(context, e.message);
    } catch (e) {
      _showError(context, 'Something went wrong. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  // ── Login with password ────────────────────
  Future<void> loginWithPassword(BuildContext context) async {
  final email    = emailCtrl.text.trim();
  final password = passCtrl.text.trim();

  if (email.isEmpty || !email.contains('@')) {
    _showError(context, 'Please enter a valid email address');
    return;
  }
  if (password.isEmpty) {
    _showError(context, 'Please enter your password');
    return;
  }

  isLoading.value = true;
  try {
    final response = await _repo.loginWithPassword(
      email: email,
      password: password,
    );

    if (response.error) {
      _showError(context, response.message);
      return;
    }

    await _saveSession(
      accessToken: response.accessToken,
      refreshToken: response.refreshToken,
      user: response.user,
    );

    _showSuccess(context, 'Welcome back!', response.message);
    await Future.delayed(const Duration(milliseconds: 800));
    Get.offAll(
      () => const LoadingScreen(),
      transition: Transition.fadeIn,
      duration: const Duration(milliseconds: 500),
    );
  } on HttpException catch (e) {
    _showError(context, e.message);
  } catch (e) {
    _showError(context, 'Something went wrong. Please try again.');
  } finally {
    isLoading.value = false;
  }
}

  // ── Register ───────────────────────────────
  Future<void> register(BuildContext context) async {
    final name     = nameCtrl.text.trim();
    final email    = regEmailCtrl.text.trim();
    final phone    = phoneCtrl.text.trim();
    final password = passwordCtrl.text.trim();

    if (name.isEmpty) {
      _showError(context, 'Name is required');
      return;
    }
    if (email.isEmpty || !email.contains('@')) {
      _showError(context, 'Please enter a valid email address');
      return;
    }
    if (phone.isEmpty || phone.length < 10) {
      _showError(context, 'Please enter a valid phone number');
      return;
    }
    if (password.length < 6) {
      _showError(context, 'Password must be at least 6 characters');
      return;
    }

    isRegLoading.value = true;
    try {
      final response = await _repo.register(
        name: name,
        email: email,
        phoneNumber: phone,
        password: password,
      );

      if (response.error) {
        _showError(context, response.message);
        return;
      }

      await _saveSession(
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
        user: response.user,
      );

      _showSuccess(context, 'Registered!', response.message);
      await Future.delayed(const Duration(milliseconds: 800));
      Get.offAll(
        () => const LoadingScreen(),
        transition: Transition.fadeIn,
        duration: const Duration(milliseconds: 500),
      );
    } on HttpException catch (e) {
      _showError(context, e.message);
    } catch (e) {
      _showError(context, 'Something went wrong. Please try again.');
    } finally {
      isRegLoading.value = false;
    }
  }

  // ── Save session ───────────────────────────
  Future<void> _saveSession({
    String? accessToken,
    String? refreshToken,
    dynamic user,
  }) async {
    if (accessToken != null) {
      await TokenStorage.saveTokens(
        accessToken: accessToken,
        refreshToken: refreshToken ?? '',
      );
    }
    if (user != null) {
      await TokenStorage.saveUser(
        userId: user.userId,
        name: user.name,
        email: user.email,
      );
    }
  }

  // ── Helpers ────────────────────────────────
  void _showError(BuildContext context, String message) {
    NotixToast.show(
      context,
      type: NotixType.error,
      title: 'Error',
      message: message,
      position: NotixToastPosition.top,
    );
  }

  void _showSuccess(BuildContext context, String title, String message) {
    NotixToast.show(
      context,
      type: NotixType.success,
      title: title,
      message: message,
      position: NotixToastPosition.top,
    );
  }
}