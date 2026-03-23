import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:outrace/modules/profile/presentation/pages/profile_screen.dart';
import 'package:outrace/modules/track/presentation/pages/track_screen.dart';
import 'package:outrace/modules/trips/presentation/pages/trips_screen.dart';
import '../../../../theme/app_theme.dart';
import '../../../../widgets/floating_nav_bar.dart';
import '../controller/home_controller.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomeController());

    return Scaffold(
      backgroundColor: AppColors.white,
      extendBody: true,
      body: Obx(() => IndexedStack(
  index: controller.currentIndex.value,
  children: const [
    _HomePage(),
    TrackScreen(),
    TripsScreen(),
    ProfileScreen(),
  ],
)),
      bottomNavigationBar: Obx(() => FloatingNavBar(
        currentIndex: controller.currentIndex.value,
        onTap: controller.changeTab,
      )),
    );
  }
}

// ══════════════════════════════════════════════════════════
// HOME PAGE
// ══════════════════════════════════════════════════════════
class _HomePage extends StatelessWidget {
  const _HomePage();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();
    final topPad = MediaQuery.of(context).padding.top;

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // ── Header ──────────────────────────────────
          Container(
            color: AppColors.white,
            padding: EdgeInsets.fromLTRB(20, topPad + 16, 20, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Good Morning,',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          'Andika',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text('👋',
                            style: TextStyle(fontSize: 20)),
                      ],
                    ),
                  ],
                ),
                Row(
                  children: [
                    // Notification
                    Stack(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.bg,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.notifications_outlined,
                            color: AppColors.textPrimary,
                            size: 20,
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 8),
                    // Avatar
                    SizedBox(
  width: 40,
  height: 40,
  
  child: Center(
    child: Image.asset(
      'assets/icons/nav_profile.png',
      width: 24,
      height: 24,
      fit: BoxFit.contain,
    ),
  ),
), ],
                ),
              ],
            ),
          ),

          // ── Dark banner card ─────────────────────────
          // ── Dark banner card with real image ─────────
Padding(
  padding: const EdgeInsets.symmetric(horizontal: 20),
  child: ClipRRect(
    borderRadius: BorderRadius.circular(18),
    child: SizedBox(
      width: double.infinity,
      height: 110,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background image
          Image.asset(
            'assets/images/dashboard_banner.jpg',
            fit: BoxFit.cover,
          ),

          // Dark overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  // ignore: deprecated_member_use
                  AppColors.dark.withOpacity(0.92),
                  // ignore: deprecated_member_use
                  AppColors.dark.withOpacity(0.55),
                  Colors.transparent,
                ],
              ),
            ),
          ),

          // Text on top
          Positioned(
            left: 18,
            top: 0,
            bottom: 0,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Effortlessly Control All',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Your Vehicles',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
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
),

SizedBox(height: 10,),  

          // ── Search bar ───────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              height: 46,
              decoration: BoxDecoration(
                color: AppColors.bg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 14),
                  const Icon(Icons.search_rounded,
                      color: AppColors.textTertiary, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Search vehicle licence plate',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.all(6),
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.dark,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.search_rounded,
                        color: Colors.white, size: 16),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // ── Section label ────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              "Your Vehicle's Current Position",
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 10),

          // ── Filter chips ─────────────────────────────
          // ── Filter chips ─────────────────────────────
SingleChildScrollView(
  scrollDirection: Axis.horizontal,
  padding: const EdgeInsets.symmetric(horizontal: 20),
  child: Row(
    children: [
      _FilterChip(
        label: 'Car',
        iconPath: 'assets/icons/ic_car.png',
        isActive: true,
      ),
      const SizedBox(width: 8),
      _FilterChip(
        label: 'Motorcycle',
        iconPath: 'assets/icons/ic_moto.png',
        isActive: false,
      ),
      const SizedBox(width: 8),
      _FilterChip(
        label: 'Truck',
        iconPath: 'assets/icons/ic_truck.png',
        isActive: false,
      ),
      const SizedBox(width: 8),
      _FilterChip(
        label: 'Bus',
        iconPath: 'assets/icons/ic_bus.png',
        isActive: false,
      ),
    ],
  ),
),
const SizedBox(height: 14),

          // ── Mini map placeholder ─────────────────────
          // ── Google Map ────────────────────────────────
Padding(
  padding: const EdgeInsets.symmetric(horizontal: 20),
  child: ClipRRect(
    borderRadius: BorderRadius.circular(16),
    child: SizedBox(
      height: 180,
      child: GetBuilder<HomeController>(
  builder: (c) => GoogleMap(
    onMapCreated: c.onHomeMapCreated,
    initialCameraPosition: CameraPosition(
      target: c.mapCenter,
      zoom: 14,
    ),
    markers: c.homeMarkers,
    polylines: c.homePolylines,
    zoomControlsEnabled: false,
    myLocationButtonEnabled: false,
    mapToolbarEnabled: false,
    compassEnabled: false,
    scrollGesturesEnabled: true,
    zoomGesturesEnabled: true,
    tiltGesturesEnabled: false,
    rotateGesturesEnabled: false,
  ),
),
    ),
  ),
),const SizedBox(height: 14),


          // ── Vehicle cards ────────────────────────────
         Padding(
  padding: const EdgeInsets.symmetric(horizontal: 20),
  child: Obx(() => Column(
    children: controller.vehicles
        .map((v) => _VehicleCard(vehicle: v))
        .toList(),
  )),
),
        ],
      ),
    );
  }
}

// ── Filter chip ───────────────────────────────────────────
class _FilterChip extends StatelessWidget {
  final String label;
  final String iconPath;
  final bool isActive;

  const _FilterChip({
    required this.label,
    required this.iconPath,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: isActive ? AppColors.purple : AppColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isActive ? AppColors.purple : AppColors.border,
          width: 1.2,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ColorFiltered(
            colorFilter: ColorFilter.mode(
              isActive ? Colors.white : AppColors.textSecondary,
              BlendMode.srcIn,
            ),
            child: Image.asset(
              iconPath,
              width: 16,
              height: 16,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isActive
                  ? Colors.white
                  : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
// ── Map grid painter ──────────────────────────────────────

// ── Map vehicle dot ───────────────────────────────────────
// ignore: unused_element
class _MapVehicleDot extends StatelessWidget {
  final String label;
  final bool isMoving;

  const _MapVehicleDot({
    required this.label,
    required this.isMoving,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: isMoving ? AppColors.dark : Colors.white,
            shape: BoxShape.circle,
            border: Border.all(
              color: isMoving ? AppColors.purple : AppColors.border,
              width: 1.5,
            ),
          ),
          child: const Icon(
            Icons.directions_car_rounded,
            size: 14,
            color: AppColors.purple,
          ),
        ),
        const SizedBox(height: 3),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
          decoration: BoxDecoration(
            color: isMoving ? AppColors.green : AppColors.textTertiary,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            isMoving ? 'Moving' : 'Parking',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 8,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Vehicle card ──────────────────────────────────────────
class _VehicleCard extends StatelessWidget {
  final dynamic vehicle;

  const _VehicleCard({required this.vehicle});

  @override
  Widget build(BuildContext context) {
    final isMoving = vehicle['statusLabel'] == 'Moving';
    final battery = vehicle['battery'] as int;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          // Vehicle image
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 90,
              height: 64,
              color: AppColors.bg,
              child: Image.asset(
                vehicle['image'],
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Info + battery
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vehicle['name'],
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  vehicle['reg'],
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: AppColors.textTertiary,
                  ),
                ),
                const SizedBox(height: 6),
                // Battery bars
                Row(
                  children: List.generate(5, (i) {
                    Color barColor;
                    if (i < battery) {
                      barColor = battery >= 4
                          ? AppColors.green
                          : battery >= 2
                              ? AppColors.amber
                              : AppColors.red;
                    } else {
                      barColor = AppColors.border;
                    }
                    return Container(
                      width: 10,
                      height: 8,
                      margin: const EdgeInsets.only(right: 3),
                      decoration: BoxDecoration(
                        color: barColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // Status badge
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: isMoving
                  // ignore: deprecated_member_use
                  ? AppColors.green.withOpacity(0.1)
                  : AppColors.bg,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: isMoving
                        ? AppColors.green
                        : AppColors.textTertiary,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  vehicle['statusLabel'],
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: isMoving
                        ? AppColors.green
                        : AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
// ══════════════════════════════════════════════════════════
// TRACK PAGE
// ══════════════════════════════════════════════════════════
// ignore: unused_element
class _TrackPage extends StatelessWidget {
  const _TrackPage();

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;

    return Stack(
      children: [

        // ── Full screen map ────────────────────────────
        Container(
          color: const Color(0xFFE8EDF5),
          child: CustomPaint(
            painter: _FullMapPainter(),
            size: Size.infinite,
          ),
        ),

        // ── Top bar ────────────────────────────────────
        Positioned(
          top: topPad + 12,
          left: 16,
          right: 16,
          child: Row(
            children: [
              // Back
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      // ignore: deprecated_member_use
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: const Icon(Icons.arrow_back_ios_rounded,
                    size: 16, color: AppColors.textPrimary),
              ),
              const SizedBox(width: 10),

              // Moving pill
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      // ignore: deprecated_member_use
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Moving',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Share icon
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      // ignore: deprecated_member_use
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: const Icon(Icons.share_rounded,
                    size: 16, color: AppColors.textPrimary),
              ),
            ],
          ),
        ),

        // ── Map controls ───────────────────────────────
        Positioned(
          right: 16,
          top: topPad + 64,
          child: Column(
            children: [
              _MapBtn(icon: Icons.map_rounded),
              const SizedBox(height: 6),
              _MapBtn(icon: Icons.my_location_rounded),
              const SizedBox(height: 6),
              _MapBtn(icon: Icons.navigation_rounded),
              const SizedBox(height: 6),
              _MapBtn(icon: Icons.add_rounded),
              const SizedBox(height: 6),
              _MapBtn(icon: Icons.remove_rounded),
            ],
          ),
        ),

        // ── Vehicle bottom card ─────────────────────────
        Positioned(
          bottom: 90,
          left: 16,
          right: 16,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  // ignore: deprecated_member_use
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                // Vehicle info row
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.bg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Image.asset(
                        'assets/icons/loading_car.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'BMW X6',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          'AG 5758 SS',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),

                    const Spacer(),

                    // Battery indicator
                    Row(
                      children: List.generate(5, (i) {
                        return Container(
                          width: 8,
                          height: 14,
                          margin: const EdgeInsets.only(right: 2),
                          decoration: BoxDecoration(
                            color: i < 4
                                ? AppColors.green
                                : AppColors.border,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.local_gas_station_rounded,
                        size: 16, color: AppColors.textTertiary),
                  ],
                ),

                const SizedBox(height: 14),
                const Divider(height: 1, color: AppColors.border),
                const SizedBox(height: 12),

                // Stats row
                Row(
                  children: [
                    _TrackStat(
                      icon: Icons.location_on_rounded,
                      value: '10.8 km',
                      label: 'Distance with You',
                    ),
                    Container(
                        width: 1, height: 32, color: AppColors.border),
                    _TrackStat(
                      icon: Icons.speed_rounded,
                      value: '100 km/h',
                      label: 'Average Speed',
                    ),
                    Container(
                        width: 1, height: 32, color: AppColors.border),
                    _TrackStat(
                      icon: Icons.thermostat_rounded,
                      value: '20°C',
                      label: 'Temperature',
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.dark,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.notifications_rounded,
                                color: Colors.white, size: 16),
                            const SizedBox(width: 6),
                            Text(
                              'Ring On',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.purple,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.power_settings_new_rounded,
                                color: Colors.white, size: 16),
                            const SizedBox(width: 6),
                            Text(
                              'Stop Engine',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _MapBtn extends StatelessWidget {
  final IconData icon;
  const _MapBtn({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.08),
            blurRadius: 6,
          ),
        ],
      ),
      child: Icon(icon, size: 16, color: AppColors.textPrimary),
    );
  }
}

class _TrackStat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _TrackStat({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 13, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text(
                value,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10,
              color: AppColors.textTertiary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ── Full map painter ──────────────────────────────────────
class _FullMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final buildPaint = Paint()..color = const Color(0xFFD4DCE8);
    final roadPaint = Paint()
      ..color = const Color(0xFFCDD4E0)
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;
    final routePaint = Paint()
      ..color = AppColors.purple
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Buildings
    final buildings = [
      Rect.fromLTWH(0, 80, 100, 70),
      Rect.fromLTWH(130, 60, 90, 80),
      Rect.fromLTWH(250, 90, 80, 70),
      Rect.fromLTWH(0, 220, 110, 80),
      Rect.fromLTWH(160, 210, 100, 90),
      Rect.fromLTWH(290, 200, 90, 80),
      Rect.fromLTWH(50, 350, 80, 70),
      Rect.fromLTWH(180, 340, 110, 80),
    ];
    for (final b in buildings) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(b, const Radius.circular(4)),
        buildPaint,
      );
    }

    // Roads
    canvas.drawLine(Offset(0, 160), Offset(size.width, 160), roadPaint);
    canvas.drawLine(Offset(0, 300), Offset(size.width, 300), roadPaint);
    canvas.drawLine(Offset(120, 0), Offset(120, size.height), roadPaint);
    canvas.drawLine(Offset(250, 0), Offset(250, size.height), roadPaint);

    // Route
    final routePath = Path()
      ..moveTo(120, 300)
      ..lineTo(120, 160)
      ..lineTo(250, 160)
      ..lineTo(250, 300)
      ..lineTo(180, 300);
    canvas.drawPath(routePath, routePaint);

    // Vehicle marker
    canvas.drawCircle(
      const Offset(180, 300),
      14,
      Paint()..color = AppColors.dark,
    );
    canvas.drawCircle(
      const Offset(180, 300),
      6,
      Paint()..color = Colors.white,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ══════════════════════════════════════════════════════════
// TRIPS PAGE
// ══════════════════════════════════════════════════════════
// ignore: unused_element
class _TripsPage extends StatelessWidget {
  const _TripsPage();

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // ── Header ──────────────────────────────────
          Container(
            color: AppColors.white,
            padding: EdgeInsets.fromLTRB(20, topPad + 16, 20, 16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Trip History',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'Report',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                // Vehicle image
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 90,
                    height: 60,
                    color: AppColors.bg,
                    child: Image.asset(
                      'assets/icons/loading_car.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Vehicle name + reg
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'BMW X6',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  'AG 5758 SS',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),

          // ── Date filter tabs ─────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: ['Day', 'Week', 'Month', 'Year']
                  .asMap()
                  .entries
                  .map((e) {
                final isActive = e.key == 0;
                return Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 7),
                  decoration: BoxDecoration(
                    color: isActive ? AppColors.purple : AppColors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isActive
                          ? AppColors.purple
                          : AppColors.border,
                    ),
                  ),
                  child: Text(
                    e.value,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isActive
                          ? Colors.white
                          : AppColors.textSecondary,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 14),

          // ── Running report card ──────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Running Report',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.download_rounded,
                              size: 16,
                              color: AppColors.textTertiary),
                          const SizedBox(width: 10),
                          const Icon(Icons.share_rounded,
                              size: 16,
                              color: AppColors.textTertiary),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Wed, 18 Oct 2023',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: AppColors.textTertiary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.timer_rounded,
                          size: 14, color: AppColors.green),
                      const SizedBox(width: 5),
                      Text(
                        '05h : 04m : 13s',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Time Spend',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          color: AppColors.textTertiary,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Icon(Icons.route_rounded,
                          size: 14, color: AppColors.purple),
                      const SizedBox(width: 5),
                      Text(
                        '758 km',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Total Mileage',
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
          ),
          const SizedBox(height: 14),

          // ── Trip list ────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                _TripItem(
                  time: '08:08 PM - 10:47 PM',
                  route: 'TA. Ngantru to TA.Karangrejo',
                  distance: '10.8 km',
                  speed: 'AVG 100 km/h',
                ),
                _TripItem(
                  time: '8:15 AM - 10:58 AM',
                  route: 'TA. Ngunut to TA.Ngantru',
                  distance: '8.5 km',
                  speed: 'AVG 84 km/h',
                ),
                _TripItem(
                  time: '7:30 AM - 7:44 AM',
                  route: 'TA. Ngantru to TA.Ngunut',
                  distance: '3.8 km',
                  speed: 'AVG 58 km/h',
                ),
                _TripItem(
                  time: '7:08 AM - 7:05 AM',
                  route: 'TA. Ngantru to TA.Ngunut',
                  distance: '2.1 km',
                  speed: 'AVG 42 km/h',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Trip item ─────────────────────────────────────────────
class _TripItem extends StatelessWidget {
  final String time;
  final String route;
  final String distance;
  final String speed;

  const _TripItem({
    required this.time,
    required this.route,
    required this.distance,
    required this.speed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          // Mini map thumbnail
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 52,
              height: 44,
              color: const Color(0xFFE8EDF5),
              child: CustomPaint(
                painter: _MiniTripMapPainter(),
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  route,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    const Icon(Icons.route_rounded,
                        size: 11, color: AppColors.textTertiary),
                    const SizedBox(width: 3),
                    Text(
                      '$distance  •  $speed',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
                Text(
                  time,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniTripMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final roadPaint = Paint()
      ..color = const Color(0xFFCDD4E0)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    final routePaint = Paint()
      ..color = AppColors.purple
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
        Offset(0, size.height / 2),
        Offset(size.width, size.height / 2),
        roadPaint);
    canvas.drawLine(
        Offset(size.width / 2, 0),
        Offset(size.width / 2, size.height),
        roadPaint);

    final path = Path()
      ..moveTo(6, size.height * 0.7)
      ..quadraticBezierTo(
        size.width * 0.5, size.height * 0.3,
        size.width - 6, size.height * 0.4,
      );
    canvas.drawPath(path, routePaint);

    canvas.drawCircle(
      Offset(6, size.height * 0.7),
      3,
      Paint()..color = AppColors.green,
    );
    canvas.drawCircle(
      Offset(size.width - 6, size.height * 0.4),
      3,
      Paint()..color = AppColors.red,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ══════════════════════════════════════════════════════════
// PROFILE PAGE
// ══════════════════════════════════════════════════════════
// ignore: unused_element
class _ProfilePage extends StatelessWidget {
  const _ProfilePage();

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 100),
      child: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            color: AppColors.dark,
            padding: EdgeInsets.fromLTRB(20, topPad + 20, 20, 28),
            child: Column(
              children: [
                // Avatar
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.purple, width: 2.5),
                    color: AppColors.dark2,
                  ),
                  child: const Icon(Icons.person_rounded,
                      color: Colors.white, size: 36),
                ),
                const SizedBox(height: 10),
                Text(
                  'Andika',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                Text(
                  '+91 98765 43210',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    // ignore: deprecated_member_use
                    color: Colors.white.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Menu items
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                _ProfileMenuItem(
                  icon: Icons.directions_car_rounded,
                  label: 'My Vehicles',
                  trailing: '3',
                ),
                _ProfileMenuItem(
                  icon: Icons.history_rounded,
                  label: 'Trip History',
                  trailing: null,
                ),
                _ProfileMenuItem(
                  icon: Icons.notifications_outlined,
                  label: 'Notifications',
                  trailing: '2',
                ),
                _ProfileMenuItem(
                  icon: Icons.help_outline_rounded,
                  label: 'Help & Support',
                  trailing: null,
                ),
                _ProfileMenuItem(
                  icon: Icons.logout_rounded,
                  label: 'Logout',
                  trailing: null,
                  isDestructive: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? trailing;
  final bool isDestructive;

  const _ProfileMenuItem({
    required this.icon,
    required this.label,
    this.trailing,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? AppColors.red : AppColors.textPrimary;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
          if (trailing != null)
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.purpleSoft,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                trailing!,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.purple,
                ),
              ),
            ),
          const SizedBox(width: 6),
          Icon(Icons.arrow_forward_ios_rounded,
              size: 14,
              color: isDestructive
                  ? AppColors.red
                  : AppColors.textTertiary),
        ],
      ),
    );
  }
}