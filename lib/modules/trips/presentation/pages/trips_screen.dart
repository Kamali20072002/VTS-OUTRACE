import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:outrace/modules/home/presentation/controller/home_controller.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../theme/app_theme.dart';
import '../controller/trips_controller.dart';
import 'trip_details_screen.dart';

class TripsScreen extends StatelessWidget {
  const TripsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(TripsController());
    final homeController = Get.find<HomeController>();
    final topPad = MediaQuery.of(context).padding.top;
    final screenWidth = MediaQuery.of(context).size.width;

    return RefreshIndicator(
      onRefresh: () => controller.fetchTrips(forceRefresh: true),
      color: AppColors.purple,
      child: SingleChildScrollView(
        controller: homeController.tripsScrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── HEADER ───────────────────────────────────────────────────────
            // Reduced height: was topPad+190, now topPad+170
            SizedBox(
              height: topPad + 180,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned.fill(
                    child: Container(color: const Color(0xFF1E2632)),
                  ),
                  Positioned(
                    right: -30,
                    top: topPad - 10,
                    child: Opacity(
                      opacity: 0.1,
                      child: Image.asset(
                        'assets/images/bmw_logo.png',
                        width: 220,
                        fit: BoxFit.contain,
                        errorBuilder: (c, e, s) => const SizedBox.shrink(),
                      ),
                    ),
                  ),
                  Positioned(
                    top: topPad + 18,
                    left: 20,
                    right: 20,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Trip History',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                'Report',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // White rounded bottom strip
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: 50,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(48),
                        ),
                      ),
                    ),
                  ),
                  // Car
                  Positioned(
                    bottom: 5,
                    right: -15,
                    child: Image.asset(
                      'assets/images/bmw_x6.png',
                      width: screenWidth * 0.70,
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              ),
            ),

            // ── WHITE CONTENT AREA ────────────────────────────────────────────
            Container(
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 5),

                  // ── RUNNING REPORT CARD ──────────────────────────────────────
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFF0F0F0)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Header row
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'OVER ALL SUMMARY',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Obx(
                                    () => Text(
                                      'Total Trips : ${controller.summary['totalTrips'] ?? 0}',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 12,
                                        color: AppColors.textTertiary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Obx(() {
                              if (controller.allTrips.isEmpty) return const SizedBox.shrink();
                              return Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _CircleIconBtn(
                                    icon: Icons.file_download_outlined,
                                    onTap: () => controller.downloadReport(),
                                  ),
                                  const SizedBox(width: 8),
                                  _CircleIconBtn(
                                    icon: Icons.share_outlined,
                                    onTap: () => controller.shareReport(),
                                  ),
                                ],
                              );
                            }),
                          ],
                        ),

                        const SizedBox(height: 10),

                        // Stats row
                        Obx(
                          () => IntrinsicHeight(
                            child: Row(
                              children: [
                                Expanded(
                                  child: _ReportStat(
                                    icon: Icons.access_time_rounded,
                                    label: 'Time Spend',
                                    value:
                                        controller.summary.containsKey(
                                          'totalDuration',
                                        )
                                        ? controller.formatDuration(
                                            controller.summary['totalDuration'],
                                          )
                                        : '0h 0m',
                                  ),
                                ),
                                const VerticalDivider(
                                  width: 1,
                                  thickness: 1,
                                  color: Color(0xFFEEEEEE),
                                ),
                                Expanded(
                                  child: _ReportStat(
                                    assetIcon: 'assets/icons/mileage.png',
                                    label: 'Mileage',
                                    value:
                                        controller.summary.containsKey(
                                          'totalDistance',
                                        )
                                        ? '${(controller.summary['totalDistance'] as num).toStringAsFixed(1)} km'
                                        : '0.0 km',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  // ── SORT & FILTER ROW ──────────────────────────────────────
                  Obx(() {
                    if (controller.allTrips.isEmpty) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              // SORT
                              Expanded(
                                child: GestureDetector(
                                  onTap: () =>
                                      _showSortMenu(context, controller),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF9FAFB),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: const Color(0xFFE5E7EB),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.sort_rounded,
                                          color: AppColors.purple,
                                          size: 18,
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            controller.selectedSort.value,
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.textPrimary,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const Icon(
                                          Icons.keyboard_arrow_down_rounded,
                                          color: AppColors.textSecondary,
                                          size: 18,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              // FILTER
                              Expanded(
                                child: GestureDetector(
                                  onTap: () =>
                                      _showFilterSheet(context, controller),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF9FAFB),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: const Color(0xFFE5E7EB),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.filter_list_rounded,
                                          color: AppColors.purple,
                                          size: 18,
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            controller
                                                            .selectedVehicleType
                                                            .value ==
                                                        'All' &&
                                                    controller
                                                            .selectedVehicleReg
                                                            .value ==
                                                        'All Vehicles'
                                                ? 'Filter By'
                                                : 'Filtered',
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.textPrimary,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const Icon(
                                          Icons.keyboard_arrow_down_rounded,
                                          color: AppColors.textSecondary,
                                          size: 18,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          // Clear filter option
                          if (controller.selectedVehicleType.value != 'All' ||
                              controller.selectedVehicleReg.value !=
                                  'All Vehicles')
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: InkWell(
                                onTap: () => controller.clearFilters(),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    const Icon(
                                      Icons.close_rounded,
                                      size: 14,
                                      color: AppColors.red,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Clear Filters',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.red,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  }),

                  const SizedBox(height: 10),

                  // ── TRIP LIST ────────────────────────────────────────────────
                  Obx(() {
                    if (controller.isLoading.value) {
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: 5,
                        padding: const EdgeInsets.only(bottom: 10),
                        itemBuilder: (context, index) =>
                            const _ShimmerTripItem(),
                      );
                    }
                    if (controller.filteredTrips.isEmpty) {
                      return Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 20,
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: 40,
                          horizontal: 20,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: AppColors.border),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.02),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.asset(
                                'assets/gif/redcar.gif',
                                width: 220,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(
                                  Icons.history_rounded,
                                  size: 64,
                                  color: AppColors.textTertiary,
                                ),
                              ),
                              const SizedBox(height: 24),
                              Text(
                                'No History found',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Your tracked trips will appear here',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13,
                                  color: AppColors.textTertiary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    return Column(
                      children: [
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: controller.paginatedTrips.length,
                          padding: const EdgeInsets.only(bottom: 10),
                          itemBuilder: (context, index) {
                            final trip = controller.paginatedTrips[index];
                            return GestureDetector(
                              onTap: () =>
                                  Get.to(() => TripDetailsScreen(trip: trip)),
                              child: _TripItem(trip: trip),
                            );
                          },
                        ),
                        
                        // Pagination Controls
                        if (controller.totalPages > 1)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _PaginationBtn(
                                  label: 'Previous',
                                  icon: Icons.arrow_back_ios_new_rounded,
                                  onTap: controller.currentPage.value > 1 
                                    ? controller.previousPage 
                                    : null,
                                ),
                                Text(
                                  'Page ${controller.currentPage.value} of ${controller.totalPages}',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                _PaginationBtn(
                                  label: 'Next',
                                  icon: Icons.arrow_forward_ios_rounded,
                                  isRight: true,
                                  onTap: controller.currentPage.value < controller.totalPages 
                                    ? controller.nextPage 
                                    : null,
                                ),
                              ],
                            ),
                          ),
                      ],
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSortMenu(BuildContext context, TripsController controller) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Sort Trips By',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            ...controller.sortOptions.map(
              (opt) => ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                leading: Icon(
                  opt == 'Recent Trips'
                      ? Icons.history_rounded
                      : Icons.update_rounded,
                  color: controller.selectedSort.value == opt
                      ? AppColors.purple
                      : AppColors.textTertiary,
                ),
                title: Text(
                  opt,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: controller.selectedSort.value == opt
                        ? FontWeight.w700
                        : FontWeight.w500,
                    color: controller.selectedSort.value == opt
                        ? AppColors.purple
                        : AppColors.textPrimary,
                  ),
                ),
                trailing: controller.selectedSort.value == opt
                    ? const Icon(
                        Icons.check_circle_rounded,
                        color: AppColors.purple,
                        size: 20,
                      )
                    : null,
                onTap: () {
                  controller.setSort(opt);
                  Navigator.pop(context);
                },
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  void _showFilterSheet(BuildContext context, TripsController controller) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                'Filter Trips',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Vehicle Type
            Text(
              'Vehicle Type',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Obx(
              () => Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: controller.selectedVehicleType.value,
                    isExpanded: true,
                    icon: const Icon(Icons.keyboard_arrow_down_rounded),
                    onChanged: (val) =>
                        controller.setVehicleTypeFilter(val ?? 'All'),
                    items: controller.vehicleTypes.map((type) {
                      return DropdownMenuItem(value: type, child: Text(type));
                    }).toList(),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Registration Number
            Text(
              'Registration Number',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Obx(
              () => Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: controller.selectedVehicleReg.value,
                    isExpanded: true,
                    icon: const Icon(Icons.keyboard_arrow_down_rounded),
                    onChanged: (val) => controller.setVehicleRegFilter(val),
                    items: controller.vehicleRegNumbers.map((reg) {
                      return DropdownMenuItem(value: reg, child: Text(reg));
                    }).toList(),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.dark,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Apply Filters',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReportStat extends StatelessWidget {
  final IconData? icon;
  final String? assetIcon;
  final String label;
  final String value;

  const _ReportStat({
    this.icon,
    this.assetIcon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    Widget iconWidget;

    if (assetIcon != null) {
      iconWidget = Image.asset(
        assetIcon!,
        width: 18,
        height: 18,
        color: AppColors.purple, // optional tint
      );
    } else {
      iconWidget = Icon(
        icon,
        size: 18,
        color: AppColors.purple,
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          iconWidget,
          const SizedBox(height: 5),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: AppColors.purple,
              ),
              maxLines: 1,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppColors.textTertiary,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
// ── Circle icon button ────────────────────────────────────────────────────────
class _CircleIconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const _CircleIconBtn({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFE0E0E0), width: 1.5),
          color: Colors.white,
        ),
        child: Icon(icon, size: 16, color: AppColors.textSecondary),
      ),
    );
  }
}

// ── Trip list item ────────────────────────────────────────────────────────────
class _TripItem extends StatelessWidget {
  final dynamic trip;
  const _TripItem({required this.trip});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF2F2F2), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 82,
              height: 68,
              child: CustomPaint(
                painter: _MiniMapPainter(path: trip['path'] ?? []),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  trip['time'],
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textTertiary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  trip['route'],
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 13,
                      color: AppColors.textTertiary,
                    ),
                    const SizedBox(width: 3),
                    Flexible(
                      child: Text(
                        trip['distance'],
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textTertiary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: Container(
                        width: 3,
                        height: 3,
                        decoration: const BoxDecoration(
                          color: Color(0xFFD0D0D0),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.speed_rounded,
                      size: 13,
                      color: AppColors.textTertiary,
                    ),
                    const SizedBox(width: 3),
                    Flexible(
                      child: Text(
                        trip['speed'],
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textTertiary,
                        ),
                        overflow: TextOverflow.ellipsis,
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

// ── Shimmer Trip Item ─────────────────────────────────────────────────────────
class _ShimmerTripItem extends StatelessWidget {
  const _ShimmerTripItem();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF2F2F2), width: 1.5),
      ),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[200]!,
        highlightColor: Colors.grey[50]!,
        child: Row(
          children: [
            Container(
              width: 82,
              height: 68,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(width: 80, height: 9, color: Colors.white),
                  const SizedBox(height: 7),
                  Container(
                    width: double.infinity,
                    height: 13,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 7),
                  Row(
                    children: [
                      Container(width: 55, height: 9, color: Colors.white),
                      const SizedBox(width: 8),
                      Container(width: 55, height: 9, color: Colors.white),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Mini map painter ──────────────────────────────────────────────────────────
class _MiniMapPainter extends CustomPainter {
  final List<dynamic> path;
  _MiniMapPainter({required this.path});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = const Color(0xFFE8F0E0),
    );

    final parkPaint = Paint()..color = const Color(0xFFC8DFB0);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * 0.05,
          size.height * 0.05,
          size.width * 0.35,
          size.height * 0.38,
        ),
        const Radius.circular(4),
      ),
      parkPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * 0.58,
          size.height * 0.55,
          size.width * 0.38,
          size.height * 0.38,
        ),
        const Radius.circular(4),
      ),
      parkPaint,
    );

    final roadPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.square;

    for (var i = 1; i < 4; i++) {
      canvas.drawLine(
        Offset(0, size.height * (i * 0.25)),
        Offset(size.width, size.height * (i * 0.25)),
        roadPaint,
      );
      canvas.drawLine(
        Offset(size.width * (i * 0.25), 0),
        Offset(size.width * (i * 0.25), size.height),
        roadPaint,
      );
    }

    if (path.isEmpty) return;

    double minLat = double.infinity;
    double maxLat = -double.infinity;
    double minLon = double.infinity;
    double maxLon = -double.infinity;

    for (var point in path) {
      final lat = (point['lat'] as num).toDouble();
      final lon = (point['lon'] as num).toDouble();
      if (lat < minLat) minLat = lat;
      if (lat > maxLat) maxLat = lat;
      if (lon < minLon) minLon = lon;
      if (lon > maxLon) maxLon = lon;
    }

    final latPadding = (maxLat - minLat).clamp(0.0001, double.infinity) * 0.2;
    final lonPadding = (maxLon - minLon).clamp(0.0001, double.infinity) * 0.2;
    minLat -= latPadding;
    maxLat += latPadding;
    minLon -= lonPadding;
    maxLon += lonPadding;

    final latRange = (maxLat - minLat).clamp(0.0001, double.infinity);
    final lonRange = (maxLon - minLon).clamp(0.0001, double.infinity);

    Offset toOffset(dynamic point) {
      final lat = (point['lat'] as num).toDouble();
      final lon = (point['lon'] as num).toDouble();
      final x = ((lon - minLon) / lonRange) * size.width;
      final y = size.height - (((lat - minLat) / latRange) * size.height);
      return Offset(x, y);
    }

    final routePaint = Paint()
      ..color = AppColors.purple
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final routePath = Path();
    final firstPt = toOffset(path.first);
    routePath.moveTo(firstPt.dx, firstPt.dy);

    for (var i = 1; i < path.length; i++) {
      final pt = toOffset(path[i]);
      routePath.lineTo(pt.dx, pt.dy);
    }
    canvas.drawPath(routePath, routePaint);

    canvas.drawCircle(firstPt, 5, Paint()..color = const Color(0xFF1A1A2E));
    canvas.drawCircle(firstPt, 2.5, Paint()..color = Colors.white);

    final endPt = toOffset(path.last);
    canvas.drawCircle(
      endPt,
      5,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      endPt,
      5,
      Paint()
        ..color = AppColors.purple
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
    canvas.drawCircle(endPt, 2, Paint()..color = AppColors.purple);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _PaginationBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isRight;
  final VoidCallback? onTap;

  const _PaginationBtn({
    required this.label,
    required this.icon,
    this.isRight = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool disabled = onTap == null;
    final Color color = disabled ? AppColors.textTertiary.withOpacity(0.3) : AppColors.purple;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: color.withOpacity(0.2)),
          borderRadius: BorderRadius.circular(8),
          color: color.withOpacity(0.05),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isRight) ...[
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            if (isRight) ...[
              const SizedBox(width: 6),
              Icon(icon, size: 14, color: color),
            ],
          ],
        ),
      ),
    );
  }
}
