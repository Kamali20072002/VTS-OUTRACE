import 'package:get/get.dart';
import '../../../../core/utils/token_storage.dart';
import '../../../home/presentation/pages/home_screen.dart';
import '../../../login/presentation/pages/login_screen.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    _checkSession();
  }

  Future<void> _checkSession() async {
    // Wait for splash animation to finish
    await Future.delayed(const Duration(seconds: 3));

    final loggedIn = await TokenStorage.isLoggedIn();

    if (loggedIn) {
      // Token exists — go directly to home
      Get.offAll(
        () => const HomeScreen(),
        transition: Transition.fadeIn,
        duration: const Duration(milliseconds: 600),
      );
    } else {
      // No token — go to login
      Get.offAll(
        () => const LoginScreen(),
        transition: Transition.fadeIn,
        duration: const Duration(milliseconds: 600),
      );
    }
  }
}