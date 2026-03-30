import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:outrace/modules/home/presentation/controller/home_controller.dart';
import 'package:outrace/widgets/map_marker_helper.dart';
import '../../../../theme/app_theme.dart';
import '../controller/track_controller.dart';

class TrackScreen extends StatefulWidget {
  const TrackScreen({super.key});

  @override
  State<TrackScreen> createState() => _TrackScreenState();
}

class _TrackScreenState extends State<TrackScreen> {
  final LayerLink _layerLink = LayerLink();
  final FocusNode _searchFocus = FocusNode();

  @override
  void dispose() {
    _searchFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(TrackController());
    final topPad = MediaQuery.of(context).padding.top;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    return Scaffold(
      // FIX 4: Keep resizeToAvoidBottomInset false so scaffold doesn't resize,
      // but we handle the card position manually to keep it fixed at bottom.
      extendBody: true,
      resizeToAvoidBottomInset: false,
      body: Stack(
        fit: StackFit.expand,
        children: [

          // ── Google Map full screen ───────────────────────────────────
          Obx(() => GoogleMap(
            onMapCreated: controller.onMapCreated,
            onCameraIdle: controller.onCameraIdle,
            onTap: (_) {
              controller.showSearchDropdown.value = false;
              _searchFocus.unfocus();
            },
            initialCameraPosition: CameraPosition(
              target: controller.initialPosition,
              zoom: 13,
            ),
            mapType: controller.mapType.value,
            markers: controller.markers.toSet(),
            circles: {
              // Use MapMarkerHelper.geofenceCircle() for a consistent
              // blue circle that matches the custom user-location dot.
              if (controller.userLocation.value != null)
                MapMarkerHelper.geofenceCircle(
                  controller.userLocation.value!,
                  radiusMetres: controller.geofenceRadius.value,
                ),
            },
            // Disable the native blue dot — we render our own via
            // MapMarkerHelper.createUserLocationMarker() so the dot
            // shares the same DPR-aware rendering path as vehicle markers.
            myLocationEnabled: false,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            compassEnabled: false,
          )),

          // ── Top bar ──────────────────────────────────────────────────
          // FIX 1: Wrap in Material so GestureDetectors work on top of GoogleMap
          Positioned(
            top: topPad + 12,
            left: 16,
            right: 16,
            child: Material(
              color: Colors.transparent,
              child: Column(
                children: [
                  Row(
                    children: [
                      _TopBtn(
                        onTap: () => Get.find<HomeController>().changeTab(0),
                        child: const Icon(
                          Icons.arrow_back_ios_rounded,
                          size: 16,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(width: isSmallScreen ? 6 : 10),

                      // Search bar
                      Expanded(
                        child: CompositedTransformTarget(
                          link: _layerLink,
                          child: Container(
                            height: 40,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
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
                            child: Row(
                              children: [
                                const Icon(Icons.search_rounded,
                                    size: 18, color: AppColors.textSecondary),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextField(
                                    focusNode: _searchFocus,
                                    onChanged: (val) {
                                      controller.searchQuery.value = val;
                                      controller.showSearchDropdown.value =
                                          val.isNotEmpty;
                                    },
                                    onTap: () {
                                      if (controller.searchQuery.isNotEmpty) {
                                        controller.showSearchDropdown.value =
                                            true;
                                      }
                                    },
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: isSmallScreen ? 12 : 13,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: isSmallScreen
                                          ? 'Search...'
                                          : 'Search by model or reg no...',
                                      hintStyle: GoogleFonts.plusJakartaSans(
                                        fontSize: isSmallScreen ? 12 : 13,
                                        color: AppColors.textTertiary,
                                      ),
                                      border: InputBorder.none,
                                      isDense: true,
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      SizedBox(width: isSmallScreen ? 6 : 10),

                      _TopBtn(
                        onTap: controller.shareVehicleLocation,
                        child: const Icon(
                          Icons.share_rounded,
                          size: 16,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),

                  // Search Recommendations Dropdown
                  Obx(() {
                    if (!controller.showSearchDropdown.value) {
                      return const SizedBox.shrink();
                    }

                    final onlineVehicles = controller.filteredVehicles
                        .where((v) => v.isOnline)
                        .toList();
                    final offlineVehicles = controller.filteredVehicles
                        .where((v) => !v.isOnline)
                        .toList();

                    return CompositedTransformFollower(
                      link: _layerLink,
                      showWhenUnlinked: false,
                      offset: const Offset(0, 45),
                      child: Container(
                        width: screenWidth - 128,
                        constraints: const BoxConstraints(maxHeight: 300),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              // ignore: deprecated_member_use
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: controller.filteredVehicles.isEmpty
                            ? Padding(
                                padding: const EdgeInsets.all(16),
                                child: Text(
                                  'No results found',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13,
                                    color: AppColors.textTertiary,
                                  ),
                                ),
                              )
                            : ListView(
                                shrinkWrap: true,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                children: [
                                  if (onlineVehicles.isNotEmpty) ...[
                                    _SearchHeader(label: 'ONLINE'),
                                    ...onlineVehicles.map((v) => _SearchItem(
                                          vehicle: v,
                                          onTap: () => _onSearchSelect(
                                              controller, v),
                                        )),
                                  ],
                                  if (offlineVehicles.isNotEmpty) ...[
                                    _SearchHeader(label: 'OFFLINE'),
                                    ...offlineVehicles.map((v) => _SearchItem(
                                          vehicle: v,
                                          onTap: () => _onSearchSelect(
                                              controller, v),
                                        )),
                                  ],
                                ],
                              ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),

          // ── Map controls right ────────────────────────────────────────
          // FIX 1: Wrap in Material so buttons get proper hit-testing on
          // top of the GoogleMap widget which consumes pointer events.
          Positioned(
            right: 16,
            top: topPad + 68,
            child: Material(
              color: Colors.transparent,
              child: Column(
                children: [
                  _MapBtn(
                    icon: Icons.layers_rounded,
                    onTap: controller.toggleMapType,
                  ),
                  const SizedBox(height: 6),
                  _MapBtn(
                    icon: Icons.my_location_rounded,
                    onTap: controller.getUserLocation,
                  ),
                  const SizedBox(height: 6),
                  _MapBtn(
                    icon: Icons.navigation_rounded,
                    onTap: controller.navigateToVehicle,
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
          ),

          // ── Bottom vehicle card ───────────────────────────────────────
          Positioned(
                bottom: 90,
                left: 0,
                right: 0,
                child: SizedBox(
                  height: 125,
                  child: Obx(() {
                        if (controller.filteredVehicles.isEmpty) {
                          return const SizedBox.shrink();
                        }
                        return PageView.builder(
                          itemCount: controller.filteredVehicles.length,
                          onPageChanged: (index) =>
                              controller.selectVehicle(index,
                                  scrollPage: false),
                          controller: controller.pageController,
                          itemBuilder: (context, index) {
                            final vehicle =
                                controller.filteredVehicles[index];
                            final bool hasLocation =
                                vehicle.latitude != null &&
                                    vehicle.longitude != null;

                            return Container(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 0),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    // ignore: deprecated_member_use
                                    color: Colors.black.withOpacity(0.06),
                                    blurRadius: 10,
                                    offset: const Offset(0, 2),
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
                                        borderRadius:
                                            BorderRadius.circular(8),
                                        child: Container(
                                          width: 44,
                                          height: 36,
                                          color: AppColors.bg,
                                          child: Image.asset(
                                            controller.getVehicleImage(
                                                vehicle, index),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Flexible(
                                                  child: Text(
                                                    vehicle.model,
                                                    style: GoogleFonts
                                                        .plusJakartaSans(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w800,
                                                      color: AppColors
                                                          .textPrimary,
                                                    ),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                const SizedBox(width: 6),
                                                Container(
                                                  width: 6,
                                                  height: 6,
                                                  decoration: BoxDecoration(
                                                    color: vehicle.isOnline
                                                        ? AppColors.green
                                                        : AppColors.red,
                                                    shape: BoxShape.circle,
                                                  ),
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  vehicle.isOnline
                                                      ? 'Online'
                                                      : 'Offline',
                                                  style: GoogleFonts
                                                      .plusJakartaSans(
                                                    fontSize: 10,
                                                    fontWeight:
                                                        FontWeight.w600,
                                                    color: vehicle.isOnline
                                                        ? AppColors.green
                                                        : AppColors.red,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Text(
                                              vehicle.registrationNumber,
                                              style: GoogleFonts
                                                  .plusJakartaSans(
                                                fontSize: 11,
                                                color:
                                                    AppColors.textTertiary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Row(
                                        children: List.generate(5, (i) {
                                          return Container(
                                            width: 6,
                                            height: 10,
                                            margin: const EdgeInsets.only(
                                                right: 2),
                                            decoration: BoxDecoration(
                                              color: i < 4
                                                  ? AppColors.green
                                                  : AppColors.border,
                                              borderRadius:
                                                  BorderRadius.circular(1.5),
                                            ),
                                          );
                                        }),
                                      ),
                                      const SizedBox(width: 4),
                                      const Icon(
                                        Icons.local_gas_station_rounded,
                                        size: 14,
                                        color: AppColors.textTertiary,
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 8),
                                  const Divider(
                                      height: 1, color: AppColors.border),
                                  const SizedBox(height: 8),

                                  // Stats or Alert
                                  if (hasLocation)
                                    Row(
                                      children: [
                                        _TrackStat(
                                          icon: Icons.location_on_rounded,
                                          value:
                                              '${controller.distance.value} km',
                                          label: 'Distance',
                                        ),
                                        Container(
                                          width: 1,
                                          height: 24,
                                          color: AppColors.border,
                                        ),
                                        _TrackStat(
                                          icon: Icons.speed_rounded,
                                          value:
                                              '${vehicle.speed?.toStringAsFixed(0) ?? '0'} km/h',
                                          label: 'Avg Speed',
                                        ),
                                        Container(
                                          width: 1,
                                          height: 24,
                                          color: AppColors.border,
                                        ),
                                        _TrackStat(
                                          icon: Icons.thermostat_rounded,
                                          value:
                                              '${controller.temperature.value}°C',
                                          label: 'Temp',
                                        ),
                                      ],
                                    )
                                  else
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 4),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                            // ignore: deprecated_member_use
                                            color: AppColors.red
                                                .withOpacity(0.3)),
                                        borderRadius:
                                            BorderRadius.circular(8),
                                        // ignore: deprecated_member_use
                                        color:
                                            AppColors.red.withOpacity(0.05),
                                      ),
                                      child: Text(
                                        'Status of this device is not available',
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.red,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            );
                          },
                        );
                      }),
                ),
              ),
        ],
      ),
    );
  }
}

// ── Search Helpers ──────────────────────────────────────────────────────────
void _onSearchSelect(TrackController controller, dynamic vehicle) {
  controller.searchQuery.value = '';
  controller.showSearchDropdown.value = false;

  // Find index in the full list
  final fullIndex = controller.vehicles.indexOf(vehicle);
  if (fullIndex != -1) {
    controller.selectVehicle(fullIndex, scrollPage: true);
  }
  FocusManager.instance.primaryFocus?.unfocus();
}

class _SearchHeader extends StatelessWidget {
  final String label;
  const _SearchHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Row(
        children: [
          Icon(Icons.arrow_drop_down_rounded,
              // ignore: deprecated_member_use
              size: 20,
              color: AppColors.purple.withOpacity(0.7)),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              // ignore: deprecated_member_use
              color: AppColors.purple.withOpacity(0.7),
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchItem extends StatelessWidget {
  final dynamic vehicle;
  final VoidCallback onTap;
  const _SearchItem({required this.vehicle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Expanded(
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: vehicle.registrationNumber,
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    TextSpan(
                      text: ' • ${vehicle.model}',
                      style: GoogleFonts.plusJakartaSans(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: vehicle.isOnline ? AppColors.green : AppColors.red,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Widgets ─────────────────────────────────────────────────────────────────
class _TopBtn extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  const _TopBtn({required this.child, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
      ),
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