import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
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

    return SingleChildScrollView(
      controller: homeController.tripsScrollController,
      padding: const EdgeInsets.only(bottom: 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── HEADER ───────────────────────────────────────────────────────
          SizedBox(
            height: topPad + 230,
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
                      width: 260,
                      fit: BoxFit.contain,
                      errorBuilder: (c, e, s) => const SizedBox.shrink(),
                    ),
                  ),
                ),
                Positioned(
                  top: topPad + 24,
                  left: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Trip History',
                          style: GoogleFonts.plusJakartaSans(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: Colors.white)),
                      Text('Report',
                          style: GoogleFonts.plusJakartaSans(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: Colors.white)),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  height: 80,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.only(topLeft: Radius.circular(55)),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 10,
                  right: -15,
                  child: Image.asset(
                    'assets/images/bmw_x6.png',
                    width: screenWidth * 0.78,
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
                const SizedBox(height: 10),

                // ── RUNNING REPORT CARD ──────────────────────────────────────
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFFF0F0F0)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Header: title (Expanded) + icon buttons (fixed width)
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
                                const SizedBox(height: 4),
                                Obx(() => Text(
                                  'Total Trips : ${controller.summary['totalTrips'] ?? 0}',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13,
                                    color: AppColors.textTertiary,
                                  ),
                                )),
                              ],
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _CircleIconBtn(
                                icon: Icons.file_download_outlined,
                                onTap: () => controller.downloadReport(),
                              ),
                              const SizedBox(width: 10),
                              _CircleIconBtn(
                                icon: Icons.share_outlined,
                                onTap: () => controller.shareReport(),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Stats: icon stacked above value, FittedBox prevents overflow
                      Obx(() => IntrinsicHeight(
                            child: Row(
                              children: [
                                Expanded(
                                  child: _ReportStat(
                                    icon: Icons.access_time_rounded,
                                    label: 'Time Spend',
                                    value: controller.summary
                                            .containsKey('totalDuration')
                                        ? controller.formatDuration(
                                            controller.summary['totalDuration'])
                                        : '0h 0m',
                                  ),
                                ),
                                VerticalDivider(
                                  width: 1,
                                  thickness: 1,
                                  color: const Color(0xFFEEEEEE),
                                ),
                                Expanded(
                                  child: _ReportStat(
                                    icon: Icons.map_outlined,
                                    label: 'Mileage',
                                    value: controller.summary
                                            .containsKey('totalDistance')
                                        ? '${(controller.summary['totalDistance'] as num).toStringAsFixed(1)} km'
                                        : '0.0 km',
                                  ),
                                ),
                           
                              ],
                            ),
                          )),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ── VEHICLE TYPE FILTER ──────────────────────────────────────
                Obx(() => SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: controller.vehicleTypes.map((type) {
                          final isSelected =
                              controller.selectedVehicleType.value == type;
                          return GestureDetector(
                            onTap: () => controller.setVehicleTypeFilter(type),
                            child: Container(
                              margin: const EdgeInsets.only(right: 10),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.purple
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.purple
                                      : const Color(0xFFF0F0F0),
                                ),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: AppColors.purple
                                              .withOpacity(0.3),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        )
                                      ]
                                    : [],
                              ),
                              child: Text(
                                type,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: isSelected
                                      ? Colors.white
                                      : AppColors.textSecondary,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    )),

                const SizedBox(height: 16),

                // ── VEHICLE REGISTRATION FILTER ──────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Obx(() => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9FAFB),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE5E7EB)),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: controller.selectedVehicleReg.value,
                            isExpanded: true,
                            icon: const Icon(Icons.keyboard_arrow_down_rounded,
                                color: AppColors.textSecondary),
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                            onChanged: (val) =>
                                controller.setVehicleRegFilter(val),
                            items: controller.vehicleRegNumbers.map((reg) {
                              return DropdownMenuItem(
                                value: reg,
                                child: Text(reg),
                              );
                            }).toList(),
                          ),
                        ),
                      )),
                ),

                const SizedBox(height: 24),

                // ── TRIP LIST ────────────────────────────────────────────────
                Obx(() {
                  if (controller.isLoading.value) {
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: 5,
                      padding: const EdgeInsets.only(bottom: 20),
                      itemBuilder: (context, index) =>
                          const _ShimmerTripItem(),
                    );
                  }
                  if (controller.filteredTrips.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 40),
                      child: Center(
                        child: Text(
                          'No trip history found',
                          style: GoogleFonts.plusJakartaSans(
                              color: AppColors.textTertiary),
                        ),
                      ),
                    );
                  }
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: controller.filteredTrips.length,
                    padding: const EdgeInsets.only(bottom: 20),
                    itemBuilder: (context, index) {
                      final trip = controller.filteredTrips[index];
                      return GestureDetector(
                        onTap: () =>
                            Get.to(() => TripDetailsScreen(trip: trip)),
                        child: _TripItem(trip: trip),
                      );
                    },
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Report Stat Widget ────────────────────────────────────────────────────────
// KEY FIX: icon above value (Column, not Row) + FittedBox on value text.
// This prevents the horizontal overflow when time string is long.
class _ReportStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ReportStat({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: AppColors.purple),
          const SizedBox(height: 6),
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
          const SizedBox(height: 4),
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
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFE0E0E0), width: 1.5),
          color: Colors.white,
        ),
        child: Icon(icon, size: 17, color: AppColors.textSecondary),
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
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 14),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF2F2F2), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: SizedBox(
              width: 90,
              height: 75,
              child: CustomPaint(
                painter: _MiniMapPainter(path: trip['path'] ?? []),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  trip['time'],
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textTertiary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  trip['route'],
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                // Flexible on text children prevents overflow here too
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined,
                        size: 14, color: AppColors.textTertiary),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        trip['distance'],
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textTertiary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Container(
                        width: 4,
                        height: 4,
                        decoration: const BoxDecoration(
                          color: Color(0xFFD0D0D0),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    const Icon(Icons.speed_rounded,
                        size: 14, color: AppColors.textTertiary),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        trip['speed'],
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
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
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 14),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF2F2F2), width: 1.5),
      ),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[200]!,
        highlightColor: Colors.grey[50]!,
        child: Row(
          children: [
            Container(
              width: 90,
              height: 75,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(width: 80, height: 10, color: Colors.white),
                  const SizedBox(height: 8),
                  Container(
                      width: double.infinity, height: 14, color: Colors.white),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(width: 60, height: 10, color: Colors.white),
                      const SizedBox(width: 10),
                      Container(width: 60, height: 10, color: Colors.white),
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
        Rect.fromLTWH(size.width * 0.05, size.height * 0.05,
            size.width * 0.35, size.height * 0.38),
        const Radius.circular(4),
      ),
      parkPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.58, size.height * 0.55,
            size.width * 0.38, size.height * 0.38),
        const Radius.circular(4),
      ),
      parkPaint,
    );

    final roadPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.square;

    for (var i = 1; i < 4; i++) {
      canvas.drawLine(Offset(0, size.height * (i * 0.25)),
          Offset(size.width, size.height * (i * 0.25)), roadPaint);
      canvas.drawLine(Offset(size.width * (i * 0.25), 0),
          Offset(size.width * (i * 0.25), size.height), roadPaint);
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
      ..strokeWidth = 3.5
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

    canvas.drawCircle(firstPt, 6, Paint()..color = const Color(0xFF1A1A2E));
    canvas.drawCircle(firstPt, 3, Paint()..color = Colors.white);

    final endPt = toOffset(path.last);
    canvas.drawCircle(endPt, 6,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill);
    canvas.drawCircle(endPt, 6,
        Paint()
          ..color = AppColors.purple
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2);
    canvas.drawCircle(endPt, 2.5, Paint()..color = AppColors.purple);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}