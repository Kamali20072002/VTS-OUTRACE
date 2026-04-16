import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notix_pro/notix_pro.dart';
import '../../../../core/utils/firebase_messaging_utils.dart';
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

  // ── Validation states ──────────────────────
  final RxString loginEmailError           = ''.obs;
  final RxString loginPassError            = ''.obs;
  final RxString regNameError              = ''.obs;
  final RxString regEmailError             = ''.obs;
  final RxString regPhoneError             = ''.obs;
  final RxString regPassError              = ''.obs;

  final LoginRepository _repo = LoginRepository();

  @override
  void onInit() {
    super.onInit();
    focusNode.addListener(() => isFocused.value = focusNode.hasFocus);
    
    // Listeners for real-time validation
    emailCtrl.addListener(_validateLogin);
    passCtrl.addListener(_validateLogin);
    
    nameCtrl.addListener(_validateRegister);
    regEmailCtrl.addListener(_validateRegister);
    phoneCtrl.addListener(_validateRegister);
    passwordCtrl.addListener(_validateRegister);

    // Clear data when switching tabs to prevent "leaking" between login/register
    ever(activeTab, (_) => _clearAllFields());
  }

  void _clearAllFields() {
    emailCtrl.clear();
    passCtrl.clear();
    nameCtrl.clear();
    regEmailCtrl.clear();
    phoneCtrl.clear();
    passwordCtrl.clear();
    
    loginEmailError.value = '';
    loginPassError.value = '';
    regNameError.value = '';
    regEmailError.value = '';
    regPhoneError.value = '';
    regPassError.value = '';
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  bool _isValidPassword(String password) {
    // Min 6 max 15, at least one upper, one lower, one number and one special char
    return RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{6,15}$')
        .hasMatch(password);
  }

  void _validateLogin() {
    final email = emailCtrl.text.trim();
    final pass = passCtrl.text.trim();

    if (email.isNotEmpty && !_isValidEmail(email)) {
      loginEmailError.value = 'Invalid email address';
    } else {
      loginEmailError.value = '';
    }

    if (loginMethod.value == 'password' && pass.isNotEmpty && !_isValidPassword(pass)) {
      loginPassError.value = 'Password must be 6-15 chars with Upper, Lower, Number & Special char';
    } else {
      loginPassError.value = '';
    }
  }

  void _validateRegister() {
    final name = nameCtrl.text.trim();
    final email = regEmailCtrl.text.trim();
    final phone = phoneCtrl.text.trim();
    final pass = passwordCtrl.text.trim();

    if (name.isNotEmpty && (name.length < 3 || name.length > 20)) {
      regNameError.value = name.length < 3 ? 'Min 3 characters' : 'Max 20 characters';
    } else {
      regNameError.value = '';
    }

    if (email.isNotEmpty && !_isValidEmail(email)) {
      regEmailError.value = 'Invalid email address';
    } else {
      regEmailError.value = '';
    }

    if (phone.isNotEmpty) {
      if (phone.length != 10) {
        regPhoneError.value = 'Must be 10 digits';
      } else if (RegExp(r'^[0]+$').hasMatch(phone)) {
        regPhoneError.value = 'Invalid phone number';
      } else {
        regPhoneError.value = '';
      }
    } else {
      regPhoneError.value = '';
    }

    if (pass.isNotEmpty && !_isValidPassword(pass)) {
      regPassError.value = 'Password must be 6-15 chars with Upper, Lower, Number & Special char';
    } else {
      regPassError.value = '';
    }
  }

  @override
  void onClose() {
    emailCtrl.removeListener(_validateLogin);
    passCtrl.removeListener(_validateLogin);
    nameCtrl.removeListener(_validateRegister);
    regEmailCtrl.removeListener(_validateRegister);
    phoneCtrl.removeListener(_validateRegister);
    passwordCtrl.removeListener(_validateRegister);
    
    super.onClose();
  }

  // ── Send OTP for login ─────────────────────
  Future<void> sendOtp(BuildContext context) async {
    final email = emailCtrl.text.trim();

    if (email.isEmpty) {
      loginEmailError.value = 'Email address is required';
      return;
    }
    if (!_isValidEmail(email)) {
      loginEmailError.value = 'Please enter a valid email address';
      return;
    }

    isLoading.value = true;
    try {
      final response = await _repo.sendOtp(email);

      if (response.error) {
        // ignore: use_build_context_synchronously
        _showError(context, response.message);
        return;
      }

      // ignore: use_build_context_synchronously
      _showSuccess(context, 'OTP Sent', response.message);
      await Future.delayed(const Duration(milliseconds: 600));
      Get.to(() => OtpScreen(phone: email));
    } on HttpException catch (e) {
      // ignore: use_build_context_synchronously
      _showError(context, e.message);
    } catch (e) {
      // ignore: use_build_context_synchronously
      _showError(context, 'Something went wrong. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  // ── Login with password ────────────────────
  Future<void> loginWithPassword(BuildContext context) async {
  final email    = emailCtrl.text.trim();
  final password = passCtrl.text.trim();

  if (email.isEmpty) {
    loginEmailError.value = 'Email address is required';
    return;
  }
  if (!_isValidEmail(email)) {
    loginEmailError.value = 'Please enter a valid email address';
    return;
  }
  if (password.isEmpty) {
    loginPassError.value = 'Please enter your password';
    return;
  }
  if (!_isValidPassword(password)) {
    loginPassError.value = 'Password must be 6-15 chars with Upper, Lower, Number & Special char';
    return;
  }

  isLoading.value = true;
  try {
    final response = await _repo.loginWithPassword(
      email: email,
      password: password,
    );

    if (response.error) {
      // ignore: use_build_context_synchronously
      _showError(context, response.message);
      return;
    }

    await _saveSession(
      accessToken: response.accessToken,
      refreshToken: response.refreshToken,
      user: response.user,
    );

    // ignore: use_build_context_synchronously
    _showSuccess(context, 'Welcome back!', response.message);
    await Future.delayed(const Duration(milliseconds: 800));
    Get.offAll(
      () => const LoadingScreen(),
      transition: Transition.fadeIn,
      duration: const Duration(milliseconds: 500),
    );
  } on HttpException catch (e) {
    // ignore: use_build_context_synchronously
    _showError(context, e.message);
  } catch (e) {
    // ignore: use_build_context_synchronously
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

    bool hasError = false;

    if (name.isEmpty) {
      regNameError.value = 'Full name is required';
      hasError = true;
    } else if (name.length < 3) {
      regNameError.value = 'Name too short';
      hasError = true;
    }

    if (email.isEmpty) {
      regEmailError.value = 'Email address is required';
      hasError = true;
    } else if (!_isValidEmail(email)) {
      regEmailError.value = 'Invalid email address';
      hasError = true;
    }

    if (phone.isEmpty) {
      regPhoneError.value = 'Phone number is required';
      hasError = true;
    } else if (phone.length != 10) {
      regPhoneError.value = 'Must be 10 digits';
      hasError = true;
    } else if (RegExp(r'^[0]+$').hasMatch(phone)) {
      regPhoneError.value = 'Invalid phone number';
      hasError = true;
    }

    if (password.isEmpty) {
      regPassError.value = 'Password is required';
      hasError = true;
    } else if (!_isValidPassword(password)) {
      regPassError.value = 'Password must be 6-15 chars with Upper, Lower, Number & Special char';
      hasError = true;
    }

    if (hasError) return;

    isRegLoading.value = true;
    try {
      final fcmToken = await FirebaseMessagingUtils.getFcmToken();
      final response = await _repo.register(
        name: name,
        email: email,
        phoneNumber: phone,
        password: password,
        fcmToken: fcmToken,
      );

      if (response.error) {
        // ignore: use_build_context_synchronously
        _showError(context, response.message);
        return;
      }

      await _saveSession(
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
        user: response.user,
      );

      // ignore: use_build_context_synchronously
      _showSuccess(context, 'Registered!', response.message);
      await Future.delayed(const Duration(milliseconds: 800));
      Get.offAll(
        () => const LoadingScreen(),
        transition: Transition.fadeIn,
        duration: const Duration(milliseconds: 500),
      );
    } on HttpException catch (e) {
      // ignore: use_build_context_synchronously
      _showError(context, e.message);
    } catch (e) {
      // ignore: use_build_context_synchronously
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