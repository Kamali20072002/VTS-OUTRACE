import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:notix_pro/notix_pro.dart';
import '../core/services/connectivity_service.dart';
import '../theme/app_theme.dart';

class NoInternetScreen extends StatefulWidget {
  const NoInternetScreen({super.key});

  @override
  State<NoInternetScreen> createState() => _NoInternetScreenState();
}

class _NoInternetScreenState extends State<NoInternetScreen> {
  bool _isChecking = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/offline.png',
                width: 280,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.wifi_off_rounded,
                    size: 100,
                    color: AppColors.textTertiary,
                  );
                },
              ),
              const SizedBox(height: 40),
              Text(
                'NO INTERNET',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppColors.dark,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Please check your connection and try again.',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _isChecking
                      ? null
                        : () async {
                          setState(() => _isChecking = true);
                          debugPrint('🌐 Checking connectivity manually...');
                          
                          final connectivity = Get.find<ConnectivityService>();
                          // Manual check
                          await connectivity.checkInitialConnectivity();
                          
                          // Give a small delay for UI feel
                          await Future.delayed(const Duration(milliseconds: 1000));
                          
                          if (mounted) {
                            setState(() => _isChecking = false);
                            
                            if (!connectivity.isConnected) {
                              debugPrint('❌ Still offline.');
                              NotixDialog.show(
                                context,
                                type: NotixType.error,
                                theme: NotixTheme(
                                  animationStyle: NotixAnimationStyle.flip,
                                ),
                                title: 'No Internet',
                                message: 'Check your internet connection and try again.',
                                confirmText: 'Okay',
                                onConfirm: () {},
                              );
                            } else {
                              debugPrint('✅ Online! Obx in main.dart should remove this screen.');
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.dark,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: _isChecking
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          'Try Again',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
