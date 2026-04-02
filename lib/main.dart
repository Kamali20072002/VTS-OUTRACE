import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:outrace/core/utils/firebase_messaging_utils.dart';
import 'package:outrace/widgets/loading_screen.dart';
import 'theme/app_theme.dart';
import 'modules/splash/presentation/pages/splash_screen.dart';
import 'core/utils/token_storage.dart';

void main() async {
  // 1. Ensure Flutter framework is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Initialize Firebase
  try {
    await Firebase.initializeApp();
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    await FirebaseMessagingUtils.initialize();
  } catch (e) {
    debugPrint('Firebase initialization failed: $e');
  }
  
  // 3. Set preferred system UI styles
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  
  // 3. Await orientation lock
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  
  // 4. Determine initial landing page based on session
  bool isLoggedIn = false;
  try {
    isLoggedIn = await TokenStorage.isLoggedIn();
  } catch (e) {
    debugPrint('Error checking session: $e');
  }
  
  runApp(OutraceApp(isLoggedIn: isLoggedIn));
}

class OutraceApp extends StatelessWidget {
  final bool isLoggedIn;
  
  const OutraceApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Outrace',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      // If session exists, bypass Splash/Onboarding and go directly to Loading
      home: isLoggedIn ? const LoadingScreen() : const SplashScreen(),
    );
  }
}
