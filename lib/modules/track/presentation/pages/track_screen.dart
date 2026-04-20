import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
      body: RefreshIndicator(
        onRefresh: () => controller.loadVehicles(forceRefresh: true),
        color: AppColors.purple,
        displacement: topPad + 60,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: SizedBox(
                height: MediaQuery.of(context).size.height,
                child: Stack(
                  fit: StackFit.expand,
                  children: [

          // ── Google Map full screen ───────────────────────────────────
          Obx(() => GoogleMap(
            padding: const EdgeInsets.only(bottom: 120),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _TopBtn(
                        onTap: () {
                          // Force unfocus search if active
                          _searchFocus.unfocus();
                          
                          if (Navigator.canPop(context)) {
                            Get.back();
                          } else {
                            Get.find<HomeController>().changeTab(0);
                          }
                        },
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
                                    inputFormatters: [
                                      FilteringTextInputFormatter.deny(
                                        RegExp(r'[\u{1f300}-\u{1f5ff}\u{1f600}-\u{1f64f}\u{1f680}-\u{1f6ff}\u{1f900}-\u{1f9ff}\u{1f1e6}-\u{1f1ff}\u{2600}-\u{26ff}\u{2700}-\u{27bf}\u{1f3fb}-\u{1f3ff}\u{1f191}-\u{1f251}\u{1f004}\u{1f0cf}\u{1f170}-\u{1f171}\u{1f17e}-\u{1f17f}\u{1f18e}\u{3030}\u{2b50}\u{2b55}\u{2934}-\u{2935}\u{2b05}-\u{2b07}\u{2b1b}-\u{2b1c}\u{3297}\u{3299}\u{303d}\u{00a9}\u{00ae}\u{2122}]', unicode: true),
                                      ),
                                    ],
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

                  const SizedBox(height: 12),
                  Obx(() => SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        clipBehavior: Clip.none, // Allow shadows to overflow
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Row(
                          children: [
                            if (controller.isSocketConnected.value) ...[
                              _LiveStreamingIndicator(
                                visible: controller.isSocketConnected.value,
                              ),
                              const SizedBox(width: 10),
                            ],
                            _FilterChip(
                              label: 'All',
                              count: controller.vehicles.length,
                              isSelected: controller.statusFilter.value == 'ALL',
                              onTap: () => controller.setStatusFilter('ALL'),
                            ),
                            const SizedBox(width: 8),
                            _FilterChip(
                              label: 'Online',
                              color: AppColors.green,
                              count: controller.vehicles.where((v) => v.isOnline).length,
                              isSelected: controller.statusFilter.value == 'ONLINE',
                              onTap: () => controller.setStatusFilter('ONLINE'),
                            ),
                            const SizedBox(width: 8),
                            _FilterChip(
                              label: 'Offline',
                              color: AppColors.textTertiary,
                              count: controller.vehicles.where((v) => !v.isOnline).length,
                              isSelected: controller.statusFilter.value == 'OFFLINE',
                              onTap: () => controller.setStatusFilter('OFFLINE'),
                            ),
                            const SizedBox(width: 32), // Extra space at end for better scrolling
                          ],
                        ),
                      )),

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
                            : RefreshIndicator(
                                onRefresh: () => controller.loadVehicles(forceRefresh: true),
                                color: AppColors.purple,
                                child: ListView(
                                  shrinkWrap: true,
                                  physics: const AlwaysScrollableScrollPhysics(),
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
                    onTap: () {
                      controller.stopGeofenceAnimation();
                      controller.toggleMapType();
                    },
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
                    onTap: () {
                      controller.stopGeofenceAnimation();
                      controller.zoomIn();
                    },
                  ),
                  const SizedBox(height: 6),
                  _MapBtn(
                    icon: Icons.remove_rounded,
                    onTap: () {
                      controller.stopGeofenceAnimation();
                      controller.zoomOut();
                    },
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
                                                        : AppColors.textTertiary,
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
                                                        : AppColors.textTertiary,
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
                                          label: 'Odometer',
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
                                          icon: Icons.battery_charging_full_rounded,
                                          value:
                                              '${controller.batteryLevel.value}%',
                                          label: 'Battery',
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
            ),
          ),
        ],
      ),
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
              size: 20,
              color: AppColors.purple.withOpacity(0.7)),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w800,
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
                color: vehicle.isOnline ? AppColors.green : AppColors.textTertiary,
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
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      // ignore: deprecated_member_use
      shadowColor: Colors.black.withOpacity(0.1),
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: 40,
          height: 40,
          child: Center(child: child),
        ),
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
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      // ignore: deprecated_member_use
      shadowColor: Colors.black.withOpacity(0.2),
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 20, color: AppColors.textPrimary),
        ),
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

class _LiveStreamingIndicator extends StatefulWidget {
  final bool visible;

  const _LiveStreamingIndicator({required this.visible});

  @override
  State<_LiveStreamingIndicator> createState() => _LiveStreamingIndicatorState();
}

class _LiveStreamingIndicatorState extends State<_LiveStreamingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      child: widget.visible
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    // ignore: deprecated_member_use
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const _PulsingDot(),
                  const SizedBox(width: 8),
                  AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      final dotCount = (_controller.value * 3).floor() + 1;
                      final dots = '.' * dotCount;
                      return Opacity(
                        opacity: 0.7 + (_controller.value * 0.3),
                        child: SizedBox(
                          width: 110, // Fixed width to prevent row jumping when dots change
                          child: Text(
                            'Live Streaming$dots',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            )
          : const SizedBox.shrink(),
    );
  }
}

class _PulsingDot extends StatefulWidget {
  const _PulsingDot();
  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: AppColors.green,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.green.withOpacity(0.4),
                blurRadius: 12 * _controller.value,
                spreadRadius: 4 * _controller.value,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final int count;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? color;

  const _FilterChip({
    required this.label,
    required this.count,
    required this.isSelected,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final Color activeColor = color ?? AppColors.purple;
    
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? activeColor : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: isSelected 
                  ? activeColor.withOpacity(0.2) 
                  : Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? Colors.white : AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected 
                    ? Colors.white.withOpacity(0.2) 
                    : activeColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                count.toString(),
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: isSelected ? Colors.white : activeColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
