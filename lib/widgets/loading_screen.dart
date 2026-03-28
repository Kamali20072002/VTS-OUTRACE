import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import '../theme/app_theme.dart';
import '../modules/home/presentation/pages/home_screen.dart';
import '../modules/home/presentation/controller/home_controller.dart';
import '../modules/profile/presentation/controller/profile_controller.dart';
import '../modules/trips/presentation/controller/trips_controller.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen>
    with TickerProviderStateMixin {
  late AnimationController _progressCtrl;
  late AnimationController _fadeCtrl;
  late AnimationController _pulseCtrl;
  late AnimationController _carCtrl;

  late Animation<double> _fadeAnim;
  late Animation<double> _progressAnim;
  late Animation<double> _pulseAnim;
  late Animation<double> _carAnim;

  bool _isOnline = false;

  int _msgIndex = 0;
  final List<String> _messages = [
    'Connecting to GPS network...',
    'Loading vehicle data...',
    'Syncing fleet locations...',
    'Initialising dashboard...',
  ];

  @override
  void initState() {
    super.initState();

    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();

    _progressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _progressAnim = CurvedAnimation(
      parent: _progressCtrl,
      curve: Curves.easeInOut,
    );

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
    _pulseCtrl.repeat(reverse: true);

    _carCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3500),
    );
    _carAnim = Tween<double>(begin: -0.15, end: 1.1).animate(
      CurvedAnimation(parent: _carCtrl, curve: Curves.easeInOut),
    );
    _carCtrl.repeat();

    _startLoadingProcess();
  }

  Future<void> _startLoadingProcess() async {
    // 0. Initialize controllers immediately so they are available for build()
    Get.put(HomeController());
    Get.put(TripsController());
    Get.put(ProfileController());

    try {
      // 1. Check Internet
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _msgIndex = 0);
      });
      await _progressCtrl.animateTo(0.15);
      
      final hasInternet = await _checkInternet();
      if (mounted) setState(() => _isOnline = hasInternet);
      
      if (!hasInternet) {
        _handleError('No internet connection found');
        return;
      }
      await _progressCtrl.animateTo(0.3);

      // 2. Load Vehicle Data
      if (mounted) setState(() => _msgIndex = 1);
      final homeCtrl = Get.find<HomeController>();
      await homeCtrl.loadActiveVehicles();
      await _progressCtrl.animateTo(0.5);

      // 3. Sync Fleet Locations & Trips
      if (mounted) setState(() => _msgIndex = 2);
      final tripsCtrl = Get.find<TripsController>();
      await tripsCtrl.fetchTrips();
      await _progressCtrl.animateTo(0.75);

      // 4. Initialise Dashboard
      if (mounted) setState(() => _msgIndex = 3);
      final profileCtrl = Get.find<ProfileController>();
      await profileCtrl.refreshProfile();
      await _progressCtrl.animateTo(1.0);

      // Success - Navigate
      if (mounted) {
        await Future.delayed(const Duration(milliseconds: 500));
        Get.offAll(
          () => const HomeScreen(),
          transition: Transition.fadeIn,
          duration: const Duration(milliseconds: 500),
        );
      }
    } catch (e) {
      _handleError('Initialization failed: $e');
    }
  }

  Future<bool> _checkInternet() async {
    try {
      // Simple head request to check connectivity
      final response = await http
          .head(Uri.parse('https://www.google.com'))
          .timeout(const Duration(seconds: 5));
      return response.statusCode >= 200 && response.statusCode < 400;
    } catch (_) {
      return false;
    }
  }

  void _handleError(String message) {
    if (!mounted) return;
    Get.snackbar(
      'Connection Error',
      message,
      backgroundColor: Colors.red.withOpacity(0.8),
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 5),
      mainButton: TextButton(
        onPressed: () {
          Get.closeCurrentSnackbar();
          _startLoadingProcess();
        },
        child: const Text('Retry', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  @override
  void dispose() {
    _progressCtrl.dispose();
    _fadeCtrl.dispose();
    _pulseCtrl.dispose();
    _carCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final topPad = MediaQuery.of(context).padding.top;
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Dark top header ───────────────────────
            Container(
              width: double.infinity,
              color: AppColors.dark,
              padding: EdgeInsets.fromLTRB(24, topPad + 16, 24, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Image.asset(
                        'assets/logo/outrace_icon.png',
                        height: 32,
                        width: 32,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Outrace',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          // ignore: deprecated_member_use
                          color: Colors.white.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            // ignore: deprecated_member_use
                            color: Colors.white.withOpacity(0.1),
                          ),
                        ),
                        child: Row(
                          children: [
                            AnimatedBuilder(
                              animation: _pulseCtrl,
                              builder: (_, _) => Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: AppColors.green,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      // ignore: deprecated_member_use
                                      color: AppColors.green.withOpacity(
                                        0.4 * _pulseAnim.value,
                                      ),
                                      blurRadius: 4,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'GPS Active',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                // ignore: deprecated_member_use
                                color: Colors.white.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Initialising your\ndashboard',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Please wait while we connect to your fleet',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      // ignore: deprecated_member_use
                      color: Colors.white.withOpacity(0.45),
                    ),
                  ),
                ],
              ),
            ),

            // ── White body ────────────────────────────
            Expanded(
              child: Container(
                color: AppColors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // ── Car animation strip ─────────────
                    Container(
                      width: double.infinity,
                      height: 80,
                      color: AppColors.bg,
                      child: Stack(
                        children: [
                          Positioned(
                            bottom: 18,
                            left: 0,
                            right: 0,
                            child: Container(
                              height: 1,
                              color: AppColors.border,
                            ),
                          ),
                          Positioned(
                            bottom: 17,
                            left: 0,
                            right: 0,
                            child: AnimatedBuilder(
                              animation: _carCtrl,
                              builder: (_, _) => CustomPaint(
                                painter: _DashPainter(
                                  progress: _carAnim.value,
                                ),
                                child: const SizedBox(height: 3),
                              ),
                            ),
                          ),
                          AnimatedBuilder(
                            animation: _carAnim,
                            builder: (_, _) {
                              final x = _carAnim.value * size.width;
                              return Positioned(
                                left: x - 24,
                                bottom: 12,
                                child: Image.asset(
                                  'assets/icons/loading_car.png',
                                  width: 48,
                                  height: 48,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ── Status cards row ────────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          Expanded(
                            child: _StatusCard(
                              icon: Icons.location_on_rounded,
                              label: 'GPS Signal',
                              value: _isOnline ? 'Strong' : 'None',
                              valueColor: _isOnline ? AppColors.green : AppColors.red,
                              iconColor: _isOnline ? AppColors.green : AppColors.red,
                              iconBg: _isOnline ? AppColors.greenSoft : AppColors.red.withOpacity(0.1),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Obx(() {
                              final homeCtrl = Get.find<HomeController>();
                              final count = homeCtrl.vehicles.length;
                              return _StatusCardWithImage(
                                imagePath: 'assets/icons/loading_car.png',
                                label: 'Vehicles',
                                value: '$count Found',
                                valueColor: AppColors.purple,
                                iconBg: AppColors.purpleSoft,
                              );
                            }),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _StatusCard(
                              icon: Icons.cloud_done_rounded,
                              label: 'Server',
                              value: _isOnline ? 'Connected' : 'Offline',
                              valueColor: _isOnline ? AppColors.green : AppColors.red,
                              iconColor: _isOnline ? AppColors.green : AppColors.red,
                              iconBg: _isOnline ? AppColors.greenSoft : AppColors.red.withOpacity(0.1),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    // ── Step list ───────────────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: AnimatedBuilder(
                        animation: _progressAnim,
                        builder: (_, _) {
                          final p = _progressAnim.value;
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _StepRow(
                                label: 'GPS network connected',
                                done: p > 0.25,
                                active: p <= 0.25,
                              ),
                              _StepRow(
                                label: 'Vehicle data loaded',
                                done: p > 0.45,
                                active: p > 0.25 && p <= 0.45,
                              ),
                              _StepRow(
                                label: 'Fleet locations synced',
                                done: p > 0.7,
                                active: p > 0.45 && p <= 0.7,
                              ),
                              _StepRow(
                                label: 'Dashboard ready',
                                done: p > 0.95,
                                active: p > 0.7 && p <= 0.95,
                              ),
                            ],
                          );
                        },
                      ),
                    ),

                    const Spacer(),

                    // ── Progress bar + message ──────────
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        20,
                        0,
                        20,
                        bottomPad + 20,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 400),
                            transitionBuilder: (child, anim) =>
                                FadeTransition(opacity: anim, child: child),
                            child: Row(
                              key: ValueKey(_msgIndex),
                              children: [
                                Container(
                                  width: 4,
                                  height: 4,
                                  decoration: const BoxDecoration(
                                    color: AppColors.purple,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _messages[_msgIndex],
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          AnimatedBuilder(
                            animation: _progressAnim,
                            builder: (_, _) => Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: _progressAnim.value,
                                    backgroundColor: AppColors.bg,
                                    valueColor:
                                        const AlwaysStoppedAnimation<Color>(
                                      AppColors.purple,
                                    ),
                                    minHeight: 4,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${(_progressAnim.value * 100).toInt()}%',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    color: AppColors.textTertiary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Status card ───────────────────────────────────────────
class _StatusCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color valueColor;
  final Color iconColor;
  final Color iconBg;

  const _StatusCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.valueColor,
    required this.iconColor,
    required this.iconBg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: iconColor, size: 15),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: valueColor,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10,
                color: AppColors.textTertiary,
              ),
            ),
          ],
       ),
);
  }
}

class _StatusCardWithImage extends StatelessWidget {
  final String imagePath;
  final String label;
  final String value;
  final Color valueColor;
  final Color iconBg;

  const _StatusCardWithImage({
    required this.imagePath,
    required this.label,
    required this.value,
    required this.valueColor,
    required this.iconBg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Image.asset(imagePath, fit: BoxFit.contain),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: valueColor,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10,
                color: AppColors.textTertiary,
              ),
            ),
          ],
  ),
);
  }
}

// ── Step row ──────────────────────────────────────────────
class _StepRow extends StatelessWidget {
  final String label;
  final bool done;
  final bool active;

  const _StepRow({
    required this.label,
    required this.done,
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: done
                  ? AppColors.purple
                  : active
                      ? AppColors.purpleSoft
                      : AppColors.bg,
              shape: BoxShape.circle,
              border: Border.all(
                color: done
                    ? AppColors.purple
                    : active
                        ? AppColors.purple
                        : AppColors.border,
                width: 1.5,
              ),
            ),
            child: done
                ? const Icon(Icons.check_rounded,
                    color: Colors.white, size: 12)
                : active
                    ? Center(
                        child: SizedBox(
                          width: 9,
                          height: 9,
                          child: CircularProgressIndicator(
                            strokeWidth: 1.5,
                            color: AppColors.purple,
                          ),
                        ),
                      )
                    : null,
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight:
                  done || active ? FontWeight.w600 : FontWeight.w400,
              color: done
                  ? AppColors.textPrimary
                  : active
                      ? AppColors.purple
                      : AppColors.textTertiary,
            ),
          ),
          const Spacer(),
          if (done)
            Text(
              'Done',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.green,
              ),
            )
          else if (active)
            Text(
              'Loading...',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                color: AppColors.purple,
                fontWeight: FontWeight.w500,
              ),
            ),
        ],
      ),
    );
  }
}

// ── Dash road painter ─────────────────────────────────────
class _DashPainter extends CustomPainter {
  final double progress;
  _DashPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.border
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    const dashW = 16.0;
    const gapW = 12.0;
    const total = dashW + gapW;
    final offset = (progress * total * 3) % total;

    double x = -offset;
    while (x < size.width) {
      canvas.drawLine(
        Offset(x, size.height / 2),
        Offset(x + dashW, size.height / 2),
        paint,
      );
      x += total;
    }
  }

  @override
  bool shouldRepaint(_DashPainter old) => old.progress != progress;
}
