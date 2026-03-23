import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../theme/app_theme.dart';
import '../../../login/presentation/pages/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  final List<_VehicleSlide> _slides = [
    _VehicleSlide(
      image: 'assets/images/car_hero.jpg',
      type: 'Car Fleet',
      label: 'Track every car in real-time',
    ),
    _VehicleSlide(
      image: 'assets/images/truck_hero.jpg',
      type: 'Truck Fleet',
      label: 'Monitor long-haul routes',
    ),
    _VehicleSlide(
      image: 'assets/images/bike_hero.jpg',
      type: 'Delivery Bikes',
      label: 'Last-mile delivery tracking',
    ),
    _VehicleSlide(
      image: 'assets/images/bus_hero.jpg',
      type: 'Bus Fleet',
      label: 'Passenger fleet management',
    ),
    _VehicleSlide(
      image: 'assets/images/suv_hero.jpg',
      type: 'Night Tracking',
      label: '24/7 live location monitoring',
    ),
  ];

  int _current = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();

    _timer = Timer.periodic(const Duration(milliseconds: 1500), (_) {
      if (mounted) {
        setState(() => _current = (_current + 1) % _slides.length);
      }
    });
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final topPad = MediaQuery.of(context).padding.top;
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── IMAGE + TITLE BLOCK (green zone) ─────────
          // Image covers top, title sits on top of bottom fade
          SizedBox(
            height: size.height * 0.62,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Sliding images
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 900),
                  child: Image.asset(
                    _slides[_current].image,
                    key: ValueKey(_current),
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),

                // Dark overlay top
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xEE1C1C1E),
                        Color(0xAA1C1C1E),
                        Color(0x221C1C1E),
                        Colors.transparent,
                      ],
                      stops: [0.0, 0.2, 0.55, 0.75],
                    ),
                  ),
                ),

                // White fade from bottom — blends into white bg
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  height: size.height * 0.22,
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          AppColors.white,
                          AppColors.white,
                          Color(0xCCFFFFFF),
                          Color(0x55FFFFFF),
                          Colors.transparent,
                        ],
                        stops: [0.0, 0.25, 0.5, 0.75, 1.0],
                      ),
                    ),
                  ),
                ),

                // Top bar — logo + GPS badge
                Positioned(
                  top: topPad + 14,
                  left: 24,
                  right: 24,
                  child: FadeTransition(
                    opacity: _fadeAnim,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Logo
                        Row(
                          children: [
                            Image.asset(
                              'assets/logo/outrace_icon.png',
                              height: 38,
                              width: 38,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Outrace',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: -0.3,
                              ),
                            ),
                          ],
                        ),
                        // GPS badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            // ignore: deprecated_member_use
                            color: Colors.black.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              // ignore: deprecated_member_use
                              color: Colors.white.withOpacity(0.15),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: AppColors.green,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                'GPS Live',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Vehicle type chip — on image, above title
                Positioned(
                  bottom: size.height * 0.14,
                  left: 24,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    child: Container(
                      key: ValueKey(_current),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.purple,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        _slides[_current].type,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),

                // Dots — bottom right on image
                Positioned(
                  bottom: size.height * 0.145,
                  right: 24,
                  child: Row(
                    children: List.generate(
                      _slides.length,
                      (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 400),
                        margin: const EdgeInsets.only(left: 4),
                        width: i == _current ? 18 : 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: i == _current
                              ? AppColors.purple
                              // ignore: deprecated_member_use
                              : Colors.white.withOpacity(0.45),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ),
                ),

                // Title ON image (bottom of image block)
                Positioned(
                  bottom: 12,
                  left: 24,
                  right: 24,
                  child: FadeTransition(
                    opacity: _fadeAnim,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your Fleet,',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                            height: 1.1,
                          ),
                        ),
                        Text(
                          'Under Control.',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            color: AppColors.purple,
                            height: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── RED ZONE — subtitle ───────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 10, 24, 0),
            child: Text(
              'Real-time GPS tracking, trip history and smart alerts — all in one place.',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.55,
              ),
            ),
          ),

          const Spacer(),

          // ── BLUE ZONE — button + trust ────────────────
          Padding(
            padding: EdgeInsets.fromLTRB(24, 0, 24, bottomPad + 24),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2C2C2E),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Get Started',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.arrow_forward_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.lock_outline_rounded,
                      size: 13,
                      color: AppColors.textTertiary,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'End-to-end encrypted · SSL secured',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Data model ────────────────────────────────────────────
class _VehicleSlide {
  final String image;
  final String type;
  final String label;

  const _VehicleSlide({
    required this.image,
    required this.type,
    required this.label,
  });
}
