import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../../../core/utils/token_storage.dart';
import '../../../home/presentation/pages/home_screen.dart';
import '../../../login/presentation/pages/login_screen.dart';
import '../../../track/domain/repositories/track_repository.dart';
import '../../../profile/domain/repositories/profile_repository.dart';
import '../../../trips/domain/repositories/trips_repository.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    _checkSession();
  }

  Future<void> _checkSession() async {
    final loggedIn = await TokenStorage.isLoggedIn();

    if (loggedIn) {
      final startTime = DateTime.now();
      
      // Preload critical data in parallel while splash is showing
      try {
        await Future.wait([
          TrackRepository().getActiveVehicles(),
          ProfileRepository().getProfile(),
          TripsRepository().getMyTrips(),
        ]).timeout(const Duration(seconds: 5));
      } catch (e) {
        debugPrint('Preloading error: $e');
      }

      final elapsed = DateTime.now().difference(startTime).inSeconds;
      if (elapsed < 2) {
        await Future.delayed(Duration(seconds: 2 - elapsed));
      }

      Get.offAll(
        () => const HomeScreen(),
        transition: Transition.fadeIn,
        duration: const Duration(milliseconds: 600),
      );
    } else {
      await Future.delayed(const Duration(seconds: 2));
      Get.offAll(
        () => const LoginScreen(),
        transition: Transition.fadeIn,
        duration: const Duration(milliseconds: 600),
      );
    }
  }
}
