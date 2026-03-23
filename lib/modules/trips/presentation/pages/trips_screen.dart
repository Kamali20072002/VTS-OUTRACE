import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../theme/app_theme.dart';
import '../controller/trips_controller.dart';

class TripsScreen extends StatelessWidget {
  const TripsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(TripsController());
    final topPad = MediaQuery.of(context).padding.top;

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // ── Header ────────────────────────────────
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
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          height: 1.1,
                        ),
                      ),
                      Text(
                        'Report',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 24,
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
                    width: 100,
                    height: 68,
                    color: AppColors.bg,
                    child: Image.asset(
                      'assets/images/bmw_x6.jpg',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Vehicle name
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'BMW X6',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 17,
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

          // ── Date filter tabs ───────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Obx(() => Row(
              children: ['Day', 'Week', 'Month', 'Year'].map((f) {
                final isActive = controller.selectedFilter.value == f;
                return GestureDetector(
                  onTap: () => controller.setFilter(f),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isActive
                          ? AppColors.purple
                          : AppColors.white,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: isActive
                            ? AppColors.purple
                            : AppColors.border,
                      ),
                    ),
                    child: Text(
                      f,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: isActive
                            ? Colors.white
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                );
              }).toList(),
            )),
          ),
          const SizedBox(height: 14),

          // ── Running report card ────────────────────
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
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Row(
                        children: [
                          Icon(Icons.download_rounded,
                              size: 18,
                              color: AppColors.textTertiary),
                          const SizedBox(width: 12),
                          Icon(Icons.share_rounded,
                              size: 18,
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
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      _ReportStat(
                        icon: Icons.timer_rounded,
                        iconColor: AppColors.green,
                        value: '05h : 04m : 13s',
                        label: 'Time Spend',
                      ),
                      const SizedBox(width: 20),
                      _ReportStat(
                        icon: Icons.route_rounded,
                        iconColor: AppColors.purple,
                        value: '758 km',
                        label: 'Total Mileage',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),

          // ── Trip list ──────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Obx(() => Column(
              children: controller.trips
                  .map((t) => _TripItem(trip: t))
                  .toList(),
            )),
          ),
        ],
      ),
    );
  }
}

class _ReportStat extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  const _ReportStat({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: iconColor),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _TripItem extends StatelessWidget {
  final dynamic trip;
  const _TripItem({required this.trip});

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
          // Mini map
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 54,
              height: 46,
              color: const Color(0xFFE8EDF5),
              child: CustomPaint(
                painter: _MiniMapPainter(),
              ),
            ),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  trip['route'],
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Icon(Icons.route_rounded,
                        size: 11,
                        color: AppColors.textTertiary),
                    const SizedBox(width: 3),
                    Text(
                      '${trip['distance']}  •  ${trip['speed']}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
                Text(
                  trip['time'],
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),

          const Icon(
            Icons.arrow_forward_ios_rounded,
            size: 13,
            color: AppColors.textTertiary,
          ),
        ],
      ),
    );
  }
}

class _MiniMapPainter extends CustomPainter {
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
      roadPaint,
    );
    canvas.drawLine(
      Offset(size.width / 2, 0),
      Offset(size.width / 2, size.height),
      roadPaint,
    );

    final path = Path()
      ..moveTo(6, size.height * 0.75)
      ..quadraticBezierTo(
        size.width * 0.5,
        size.height * 0.25,
        size.width - 6,
        size.height * 0.4,
      );
    canvas.drawPath(path, routePaint);

    canvas.drawCircle(
      Offset(6, size.height * 0.75),
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