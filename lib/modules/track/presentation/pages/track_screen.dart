import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../theme/app_theme.dart';
import '../controller/track_controller.dart';

class TrackScreen extends StatelessWidget {
  const TrackScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(TrackController());
    final topPad = MediaQuery.of(context).padding.top;

    return Scaffold(
      extendBody: true,
      body: Stack(
        fit: StackFit.expand,
        children: [

          // ── Google Map full screen ───────────────────
          GoogleMap(
            onMapCreated: controller.onMapCreated,
            initialCameraPosition: CameraPosition(
              target: controller.initialPosition,
              zoom: 15,
            ),
            markers: controller.markers,
            polylines: controller.polylines,
            myLocationEnabled: false,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            compassEnabled: false,
          ),

          // ── Top bar ──────────────────────────────────
          Positioned(
            top: topPad + 12,
            left: 16,
            right: 16,
            child: Row(
              children: [
                _TopBtn(
                  child: const Icon(
                    Icons.arrow_back_ios_rounded,
                    size: 16,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 10),

                // Status pill
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
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
                  child: Obx(() => Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: controller.isEngineOn.value
                              ? AppColors.green
                              : AppColors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        controller.isEngineOn.value
                            ? 'Moving'
                            : 'Stopped',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  )),
                ),

                const Spacer(),

                _TopBtn(
                  child: const Icon(
                    Icons.share_rounded,
                    size: 16,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),

          // ── Map controls right ────────────────────────
          Positioned(
            right: 16,
            top: topPad + 68,
            child: Column(
              children: [
                _MapBtn(
                  icon: Icons.layers_rounded,
                  onTap: () {},
                ),
                const SizedBox(height: 6),
                _MapBtn(
                  icon: Icons.my_location_rounded,
                  onTap: controller.centerOnVehicle,
                ),
                const SizedBox(height: 6),
                _MapBtn(
                  icon: Icons.navigation_rounded,
                  onTap: () {},
                ),
                const SizedBox(height: 6),
                _MapBtn(
                  icon: Icons.add_rounded,
                  onTap: () => controller.mapController
                      ?.animateCamera(CameraUpdate.zoomIn()),
                ),
                const SizedBox(height: 6),
                _MapBtn(
                  icon: Icons.remove_rounded,
                  onTap: () => controller.mapController
                      ?.animateCamera(CameraUpdate.zoomOut()),
                ),
              ],
            ),
          ),

          // ── Bottom vehicle card ───────────────────────
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
                mainAxisSize: MainAxisSize.min,
                children: [

                  // Vehicle row
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          width: 54,
                          height: 44,
                          color: AppColors.bg,
                          child: Image.asset(
                            'assets/images/bmw_x6.jpg',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Obx(() => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            controller.selectedVehicle.value,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            controller.selectedReg.value,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              color: AppColors.textTertiary,
                            ),
                          ),
                        ],
                      )),
                      const Spacer(),
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
                      const Icon(
                        Icons.local_gas_station_rounded,
                        size: 16,
                        color: AppColors.textTertiary,
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),
                  const Divider(height: 1, color: AppColors.border),
                  const SizedBox(height: 12),

                  // Stats
                  Obx(() => Row(
                    children: [
                      _TrackStat(
                        icon: Icons.location_on_rounded,
                        value: '${controller.distance.value} km',
                        label: 'Distance',
                      ),
                      Container(
                        width: 1,
                        height: 32,
                        color: AppColors.border,
                      ),
                      _TrackStat(
                        icon: Icons.speed_rounded,
                        value: '${controller.speed.value} km/h',
                        label: 'Avg Speed',
                      ),
                      Container(
                        width: 1,
                        height: 32,
                        color: AppColors.border,
                      ),
                      _TrackStat(
                        icon: Icons.thermostat_rounded,
                        value: '${controller.temperature.value}°C',
                        label: 'Temp',
                      ),
                    ],
                  )),

                  const SizedBox(height: 14),

                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {},
                          child: Container(
                            height: 46,
                            decoration: BoxDecoration(
                              color: AppColors.dark,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.notifications_rounded,
                                  color: Colors.white,
                                  size: 16,
                                ),
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
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Obx(() => GestureDetector(
                          onTap: controller.toggleEngine,
                          child: Container(
                            height: 46,
                            decoration: BoxDecoration(
                              color: controller.isEngineOn.value
                                  ? AppColors.purple
                                  : AppColors.red,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.power_settings_new_rounded,
                                  color: Colors.white,
                                  size: 16,
                                ),
                                const SizedBox(width: 6),
                                Obx(() => Text(
                                  controller.isEngineOn.value
                                      ? 'Stop Engine'
                                      : 'Start Engine',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                )),
                              ],
                            ),
                          ),
                        )),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Widgets ───────────────────────────────────────────────
class _TopBtn extends StatelessWidget {
  final Widget child;
  const _TopBtn({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Center(child: child),
    );
  }
}

class _MapBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _MapBtn({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              // ignore: deprecated_member_use
              color: Colors.black.withOpacity(0.07),
              blurRadius: 6,
            ),
          ],
        ),
        child: Icon(icon, size: 16, color: AppColors.textPrimary),
      ),
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