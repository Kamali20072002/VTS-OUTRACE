import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:outrace/modules/profile/presentation/pages/notifications_screen.dart';
import 'package:outrace/modules/profile/presentation/pages/profile_screen.dart';
import 'package:outrace/modules/profile/presentation/pages/vehicles_screen.dart';
import 'package:outrace/modules/profile/presentation/pages/vehicle_details_screen.dart';
import 'package:outrace/modules/track/presentation/pages/track_screen.dart';
import 'package:outrace/modules/trips/presentation/pages/trips_screen.dart';
import '../../../../theme/app_theme.dart';
import '../../../../widgets/floating_nav_bar.dart';
import '../controller/home_controller.dart';
import '../../../profile/presentation/controller/vehicles_controller.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../profile/presentation/controller/profile_controller.dart';
import '../../../track/domain/models/active_vehicle_model.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomeController());
    // Ensure ProfileController is available for the name
    Get.put(ProfileController());
    // Initialize VehiclesController for search navigation
    Get.put(VehiclesController());

    return Obx(() => Scaffold(
      backgroundColor: AppColors.white,
      extendBody: true,
      resizeToAvoidBottomInset: controller.currentIndex.value != 1,
      body: IndexedStack(
        index: controller.currentIndex.value,
        children: const [
          _HomePage(),
          TrackScreen(),
          TripsScreen(),
          ProfileScreen(),
        ],
      ),
      bottomNavigationBar: FloatingNavBar(
        currentIndex: controller.currentIndex.value,
        onTap: controller.changeTab,
      ),
    ));
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
    final profileController = Get.find<ProfileController>();
    final topPad = MediaQuery.of(context).padding.top;

    return RefreshIndicator(
      onRefresh: () async {
        await controller.loadActiveVehicles(forceRefresh: true);
        await profileController.refreshProfile(forceRefresh: true);
      },
      displacement: topPad + 20,
      color: AppColors.purple,
      child: SingleChildScrollView(
        controller: controller.homeScrollController,
        physics: const AlwaysScrollableScrollPhysics(),
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
                        Obx(() {
                          if (controller.isLoading.value && profileController.name.value == 'User') {
                            return Shimmer.fromColors(
                              baseColor: Colors.grey[300]!,
                              highlightColor: Colors.grey[100]!,
                              child: Container(
                                width: 120,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            );
                          }
                          return Text(
                            profileController.name.value,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          );
                        }),
                        const SizedBox(width: 6),
                        const Text('👋', style: TextStyle(fontSize: 20)),
                      ],
                    ),
                  ],
                ),
                Row(
                  children: [
                    // Notification
                    GestureDetector(
                      onTap: () => Get.to(() => const NotificationsScreen()),
                      child: Stack(
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
                    ),
                    const SizedBox(width: 8),
                    // Avatar
                    GestureDetector(
                      onTap: () => controller.changeTab(3),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.bg,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Image.asset(
                            'assets/icons/nav_profile.png',
                            width: 24,
                            height: 24,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── Dark banner card ─────────────────────────
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
                    Image.asset(
                      'assets/images/dashboard_banner.jpg',
                      fit: BoxFit.cover,
                    ),
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

          const SizedBox(height: 10),

          // ── Search bar ───────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: GestureDetector(
              onTap: () => Get.to(() => const SearchVehicleScreen()),
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
                      child: TextField(
                        enabled: false, // Navigate on tap
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          color: AppColors.textPrimary,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Search by model or vehicle number',
                          hintStyle: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            color: AppColors.textTertiary,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
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
          Obx(() => SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: controller.vehicleTypes.map((type) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _FilterChip(
                        label: type,
                        iconPath: _getIconForType(type),
                        isActive: controller.selectedType.value == type,
                        onTap: () => controller.filterVehicles(type),
                      ),
                    );
                  }).toList(),
                ),
              )),
          const SizedBox(height: 14),

          // ── Google Map ────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: SizedBox(
                height: 180,
                child: Obx(() {
                  // Explicitly read values to register dependency
                  final markers = controller.homeMarkers.value;
                  final polylines = controller.homePolylines.value;
                  return Stack(
                    children: [
                      GoogleMap(
                        onMapCreated: controller.onHomeMapCreated,
                        initialCameraPosition: CameraPosition(
                          target: controller.mapCenter,
                          zoom: 12,
                        ),
                        markers: markers,
                        polylines: polylines,
                        zoomControlsEnabled: true,
                        myLocationButtonEnabled: false,
                        mapToolbarEnabled: false,
                        compassEnabled: false,
                        scrollGesturesEnabled: true,
                        zoomGesturesEnabled: true,
                        tiltGesturesEnabled: false,
                        rotateGesturesEnabled: true,
                        gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                          Factory<OneSequenceGestureRecognizer>(
                            () => EagerGestureRecognizer(),
                          ),
                        },
                      ),
                      if (controller.isLoading.value)
                        Positioned(
                          top: 12,
                          right: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const SizedBox(
                                  width: 12,
                                  height: 12,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.purple,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Tracking...',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      // Full screen button
                      Positioned(
                        top: 12,
                        right: 12,
                        child: GestureDetector(
                          onTap: () => controller.changeTab(1),
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.fullscreen_rounded,
                              color: AppColors.dark,
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                      if (markers.isEmpty && !controller.isLoading.value)
                        Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.red,
                                width: 1.5,
                              ),
                            ),
                            child: Text(
                              'No online devices right now',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        )
                    ],
                  );
                }),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // ── Vehicle cards ────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Obx(() {
              if (controller.isLoading.value && controller.vehicles.isEmpty) {
                return Column(
                  children: List.generate(3, (index) => _buildShimmerVehicleCard()),
                );
              }
              if (controller.filteredVehicles.isEmpty) {
                return Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Text(
                      'No vehicles found',
                      style: GoogleFonts.plusJakartaSans(
                        color: AppColors.textTertiary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              }
              return Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      children: controller.filteredVehicles
                          .take(3)
                          .toList()
                          .asMap()
                          .entries
                          .map((entry) => _VehicleCard(
                                vehicle: entry.value,
                                index: entry.key,
                              ))
                          .toList(),
                    ),
                  ),
                  if (controller.filteredVehicles.length > 3) ...[
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () => Get.to(() => const VehiclesScreen()),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.dark,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'View All Vehicles',
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              );
            }),
          ),
        ],
      ),
    ),);
  }

  Widget _buildShimmerVehicleCard() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        height: 92,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 80,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 120,
                    height: 14,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 80,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 14,
              height: 14,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getIconForType(String type) {
    switch (type.toUpperCase()) {
      case 'ALL':
        return 'assets/icons/all.png';
      case 'CAR':
        return 'assets/icons/ic_car.png';
      case 'BIKE':
      case 'MOTORCYCLE':
        return 'assets/icons/ic_moto.png';
      case 'TRUCK':
        return 'assets/icons/ic_truck.png';
      case 'BUS':
        return 'assets/icons/ic_bus.png';
      default:
        return 'assets/icons/ic_car.png';
    }
  }

}

// ── Filter chip ───────────────────────────────────────────
class _FilterChip extends StatelessWidget {
  final String label;
  final String iconPath;
  final bool isActive;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.iconPath,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
            Image.asset(
              iconPath,
              width: 16,
              height: 16,
              color: isActive ? Colors.white : AppColors.textPrimary,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isActive ? Colors.white : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// ── Vehicle card ──────────────────────────────────────────
class _VehicleCard extends StatelessWidget {
  final ActiveVehicleModel vehicle;
  final int index;

  const _VehicleCard({
    required this.vehicle,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();
   
    

    return GestureDetector(
      onTap: () => Get.to(() => VehicleDetailsScreen(
            vehicleId: vehicle.vehicleId,
            vehicleImage: _getBannerForType(vehicle.type),
          )),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            // Vehicle icon/image
            Container(
              width: 80,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.bg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  controller.getVehicleImage(vehicle, index),
                  width: 80,
                  height: 64,
                  fit: BoxFit.fill,
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    vehicle.model,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    vehicle.registrationNumber,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: AppColors.textTertiary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: vehicle.isOnline
                              ? AppColors.green
                              : AppColors.textTertiary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        vehicle.isOnline ? 'Online' : 'Offline',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: vehicle.isOnline
                              ? AppColors.green
                              : AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: AppColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }

  String _getIconForType(String type) {
    switch (type.toUpperCase()) {
      case 'CAR':
        return 'assets/icons/ic_car.png';
      case 'BIKE':
      case 'MOTORCYCLE':
        return 'assets/icons/ic_moto.png';
      case 'TRUCK':
        return 'assets/icons/ic_truck.png';
      case 'BUS':
        return 'assets/icons/ic_bus.png';
      default:
        return 'assets/icons/ic_car.png';
    }
  }

  String _getBannerForType(String type) {
    switch (type.toUpperCase()) {
      case 'CAR':
        return 'assets/images/bmw_x6.jpg';
      case 'BIKE':
      case 'MOTORCYCLE':
        return 'assets/images/bmw_z4.jpg';
      case 'TRUCK':
        return 'assets/images/toyota_innova.jpg';
      default:
        return 'assets/images/bmw_x6.jpg';
    }
  }
}
