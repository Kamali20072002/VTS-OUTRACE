import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../theme/app_theme.dart';
import '../controller/profile_controller.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProfileController());
    final topPad = MediaQuery.of(context).padding.top;

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 100),
      child: Column(
        children: [

          // ── Dark header ──────────────────────────
          Container(
            width: double.infinity,
            color: AppColors.dark,
            padding: EdgeInsets.fromLTRB(20, topPad + 20, 20, 28),
            child: Stack(
              children: [
                // Circles
                Positioned(
                  top: -30,
                  right: -30,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      // ignore: deprecated_member_use
                      color: AppColors.purple.withOpacity(0.12),
                    ),
                  ),
                ),

                Column(
                  children: [
                    // Avatar
                    Container(
                      width: 76,
                      height: 76,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.purple,
                          width: 2.5,
                        ),
                        color: AppColors.dark2,
                      ),
                      child: const Icon(
                        Icons.person_rounded,
                        color: Colors.white,
                        size: 36,
                      ),
                    ),
                    const SizedBox(height: 12),

                    Obx(() => Text(
                      controller.name.value,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    )),
                    const SizedBox(height: 4),

                    Obx(() => Text(
                      controller.phone.value,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        // ignore: deprecated_member_use
                        color: Colors.white.withOpacity(0.5),
                      ),
                    )),
                    const SizedBox(height: 14),

                    // Stats row
                    Obx(() => Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _ProfileStat(
                          value: '${controller.vehicleCount.value}',
                          label: 'Vehicles',
                        ),
                        Container(
                          width: 1,
                          height: 28,
                          // ignore: deprecated_member_use
                          color: Colors.white.withOpacity(0.15),
                          margin: const EdgeInsets.symmetric(
                            horizontal: 20,
                          ),
                        ),
                        const _ProfileStat(
                          value: '24',
                          label: 'Total Trips',
                        ),
                        Container(
                          width: 1,
                          height: 28,
                          // ignore: deprecated_member_use
                          color: Colors.white.withOpacity(0.15),
                          margin: const EdgeInsets.symmetric(
                            horizontal: 20,
                          ),
                        ),
                        const _ProfileStat(
                          value: '758',
                          label: 'km Tracked',
                        ),
                      ],
                    )),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ── Menu sections ────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SectionLabel(label: 'Fleet'),
                _MenuItem(
                  icon: Icons.directions_car_rounded,
                  iconBg: AppColors.purpleSoft,
                  iconColor: AppColors.purple,
                  label: 'My Vehicles',
                  trailing: '3',
                ),
                _MenuItem(
                  icon: Icons.add_circle_outline_rounded,
                  iconBg: AppColors.greenSoft,
                  iconColor: AppColors.green,
                  label: 'Add New Vehicle',
                ),

                const SizedBox(height: 8),
                _SectionLabel(label: 'Activity'),
                _MenuItem(
                  icon: Icons.history_rounded,
                  iconBg: AppColors.purpleSoft,
                  iconColor: AppColors.purple,
                  label: 'Trip History',
                ),
                _MenuItem(
                  icon: Icons.notifications_outlined,
                  iconBg: const Color(0xFFFFF4E6),
                  iconColor: AppColors.amber,
                  label: 'Notifications',
                  trailing: '2',
                ),

                const SizedBox(height: 8),
                _SectionLabel(label: 'Account'),
                _MenuItem(
                  icon: Icons.person_outline_rounded,
                  iconBg: AppColors.purpleSoft,
                  iconColor: AppColors.purple,
                  label: 'Edit Profile',
                ),
                _MenuItem(
                  icon: Icons.lock_outline_rounded,
                  iconBg: AppColors.purpleSoft,
                  iconColor: AppColors.purple,
                  label: 'Privacy & Security',
                ),
                _MenuItem(
                  icon: Icons.help_outline_rounded,
                  iconBg: AppColors.bg,
                  iconColor: AppColors.textSecondary,
                  label: 'Help & Support',
                ),

                const SizedBox(height: 8),
                _MenuItem(
                  icon: Icons.logout_rounded,
                  iconBg: AppColors.redSoft,
                  iconColor: AppColors.red,
                  label: 'Logout',
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

class _ProfileStat extends StatelessWidget {
  final String value;
  final String label;

  const _ProfileStat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11,
            // ignore: deprecated_member_use
            color: Colors.white.withOpacity(0.5),
          ),
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 2),
      child: Text(
        label.toUpperCase(),
        style: GoogleFonts.plusJakartaSans(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppColors.textTertiary,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String label;
  final String? trailing;
  final bool isDestructive;

  const _MenuItem({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.label,
    this.trailing,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 13,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: iconColor),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDestructive
                    ? AppColors.red
                    : AppColors.textPrimary,
              ),
            ),
          ),

          if (trailing != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 3,
              ),
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
          ],

          Icon(
            Icons.arrow_forward_ios_rounded,
            size: 13,
            color: isDestructive
                ? AppColors.red
                : AppColors.textTertiary,
          ),
        ],
      ),
    );
  }
}