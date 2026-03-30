import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:outrace/modules/profile/presentation/pages/notifications_screen.dart';
import 'package:outrace/modules/home/presentation/controller/home_controller.dart';
import '../../../../theme/app_theme.dart';
import '../controller/profile_controller.dart';
import 'vehicles_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProfileController());
    final homeController = Get.find<HomeController>();
    final topPad = MediaQuery.of(context).padding.top;

    return RefreshIndicator(
      onRefresh: () => controller.refreshProfile(forceRefresh: true),
      color: AppColors.purple,
      child: SingleChildScrollView(
        controller: homeController.profileScrollController,
        physics: const AlwaysScrollableScrollPhysics(),
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
                  Positioned(
                    top: -30,
                    right: -30,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.purple.withOpacity(0.12),
                      ),
                    ),
                  ),
                  Column(
                    children: [
                      // Avatar
                      Obx(
                        () => Container(
                          width: 76,
                          height: 76,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: controller.isLoading.value
                                  ? Colors.transparent
                                  : AppColors.purple,
                              width: 2.5,
                            ),
                            color: AppColors.dark2,
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              if (controller.isLoading.value)
                                SizedBox.expand(
                                  child: Shimmer.fromColors(
                                    baseColor: AppColors.purple.withOpacity(
                                      0.12,
                                    ),
                                    highlightColor: AppColors.purple,
                                    period: const Duration(milliseconds: 1500),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 2.5,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              const Icon(
                                Icons.person_rounded,
                                color: Colors.white,
                                size: 36,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      Obx(
                        () => controller.isLoading.value
                            ? Shimmer.fromColors(
                                baseColor: Colors.white.withOpacity(0.1),
                                highlightColor: Colors.white.withOpacity(0.3),
                                child: Container(
                                  width: 140,
                                  height: 22,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              )
                            : Text(
                                controller.name.value,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                      const SizedBox(height: 4),

                      Obx(
                        () => Text(
                          controller.email.value,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            color: Colors.white.withOpacity(0.5),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),

                      Obx(
                        () => controller.phone.value.isNotEmpty
                            ? Text(
                                controller.phone.value,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  color: Colors.white.withOpacity(0.4),
                                ),
                              )
                            : const SizedBox.shrink(),
                      ),

                      const SizedBox(height: 16),

                      // Stats row
                      Obx(
                        () => Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _ProfileStat(
                              value: '${controller.vehicleCount.value}',
                              label: 'Vehicles',
                            ),
                            _Divider(),
                            _ProfileStat(
                              value: '${controller.totalTrips.value}',
                              label: 'Total Trips',
                            ),
                            _Divider(),
                            _ProfileStat(
                              value: '${controller.totalKm.value} km',
                              label: 'Tracked',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Fleet section ────────────────────
                  _SectionLabel(label: 'Fleet'),
                  _MenuItem(
                    icon: Icons.directions_car_rounded, // fallback icon
                    customIconAsset: 'assets/icons/car.png',
                    iconBg: AppColors.purpleSoft,
                    iconColor: AppColors.purple,
                    label: 'My Vehicles',
                    trailingObs: controller.vehicleCount,
                    onTap: () => Get.to(() => const VehiclesScreen()),
                  ),

                  const SizedBox(height: 8),

                  // ── Activity section ─────────────────
                  _SectionLabel(label: 'Activity'),
                  Obx(
                    () => _MenuItem(
                      icon: Icons.history_rounded,
                      iconBg: AppColors.purpleSoft,
                      iconColor: AppColors.purple,
                      label: 'Trip History',
                      isLoading: controller.isLoading.value,
                      onTap: () {
                        if (Get.isRegistered<HomeController>()) {
                          Get.find<HomeController>().changeTab(2);
                        }
                      },
                    ),
                  ),
                  Obx(
                    () => _MenuItem(
                      icon: Icons.notifications_outlined,
                      iconBg: const Color(0xFFFFF4E6),
                      iconColor: AppColors.amber,
                      label: 'Notifications',
                      trailingObs: controller.notificationCount,
                      isLoading: controller.isLoading.value,
                      onTap: () => Get.to(() => const NotificationsScreen()),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // ── Account section ──────────────────
                  _SectionLabel(label: 'Account'),
                  Obx(
                    () => _MenuItem(
                      icon: Icons.person_outline_rounded,
                      iconBg: AppColors.purpleSoft,
                      iconColor: AppColors.purple,
                      label: 'Edit Profile',
                      isLoading: controller.isLoading.value,
                      onTap: () => _showEditProfileSheet(context, controller),
                    ),
                  ),
                  Obx(
                    () => _MenuItem(
                      icon: Icons.lock_outline_rounded,
                      iconBg: AppColors.purpleSoft,
                      iconColor: AppColors.purple,
                      label: 'Privacy & Security',
                      isLoading: controller.isLoading.value,
                      onTap: () => _showPrivacySheet(context, controller),
                    ),
                  ),
                  Obx(
                    () => _MenuItem(
                      icon: Icons.help_outline_rounded,
                      iconBg: AppColors.bg,
                      iconColor: AppColors.textSecondary,
                      label: 'Help & Support',
                      isLoading: controller.isLoading.value,
                      onTap: () => _showHelpSheet(context),
                    ),
                  ),

                  const SizedBox(height: 8),

                  _MenuItem(
                    icon: Icons.logout_rounded,
                    iconBg: AppColors.redSoft,
                    iconColor: AppColors.red,
                    label: 'Logout',
                    isDestructive: true,
                    onTap: () => controller.logout(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── My Vehicles Bottom Sheet ──────────────
  void _showMyVehiclesSheet(
    BuildContext context,
    ProfileController controller,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _BottomSheet(
        title: 'My Vehicles',
        child: Obx(
          () => controller.vehicles.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.directions_car_outlined,
                        size: 48,
                        color: AppColors.textTertiary,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No vehicles found',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: controller.vehicles.length,
                  itemBuilder: (_, i) {
                    final v = controller.vehicles[i];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: AppColors.purpleSoft,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.directions_car_rounded,
                              color: AppColors.purple,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  v.model,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                Text(
                                  v.registrationNumber,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    color: AppColors.textTertiary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: v.isOnline
                                  ? AppColors.green.withOpacity(0.1)
                                  : AppColors.bg,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: v.isOnline
                                        ? AppColors.green
                                        : AppColors.textTertiary,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  v.isOnline ? 'Online' : 'Offline',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: v.isOnline
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
                  },
                ),
        ),
      ),
    );
  }

  // ── Edit Profile Bottom Sheet ─────────────
  void _showEditProfileSheet(
    BuildContext context,
    ProfileController controller,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: _BottomSheet(
          title: 'Edit Profile',
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(() => _SheetInputField(
                  label: 'Full Name',
                  controller: controller.nameEditCtrl,
                  icon: Icons.person_outline_rounded,
                  errorText: controller.profileError.value.contains('Name') 
                      ? controller.profileError.value 
                      : null,
                )),
                const SizedBox(height: 14),
                Obx(() => _SheetInputField(
                  label: 'Phone Number',
                  controller: controller.phoneEditCtrl,
                  icon: Icons.phone_outlined,
                  inputType: TextInputType.phone,
                  maxLength: 10,
                  errorText: controller.profileError.value.contains('Phone') 
                      ? controller.profileError.value 
                      : null,
                )),
                const SizedBox(height: 24),
                Obx(
                  () {
                    final isEnabled = controller.isProfileChanged.value && 
                                    controller.profileError.value.isEmpty && 
                                    !controller.isUpdating.value;
                    
                    return GestureDetector(
                      onTap: isEnabled ? () => controller.updateProfile(context) : null,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: double.infinity,
                        height: 50,
                        decoration: BoxDecoration(
                          color: isEnabled ? AppColors.purple : AppColors.border,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Center(
                          child: controller.isUpdating.value
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  'Save Changes',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: isEnabled ? Colors.white : AppColors.textTertiary,
                                  ),
                                ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Privacy & Security Bottom Sheet ──────
  void _showPrivacySheet(BuildContext context, ProfileController controller) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: _BottomSheet(
          title: 'Privacy & Security',
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Change password section
                Text(
                  'Change Password',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 14),
  
                Obx(
                  () => _PasswordField(
                    label: 'Current Password',
                    controller: controller.oldPassCtrl,
                    showPass: controller.showOldPass.value,
                    onToggle: () => controller.showOldPass.toggle(),
                    errorText: controller.passwordError.value.contains('Current') 
                        ? controller.passwordError.value 
                        : null,
                  ),
                ),
                const SizedBox(height: 12),
                Obx(
                  () => _PasswordField(
                    label: 'New Password',
                    controller: controller.newPassCtrl,
                    showPass: controller.showNewPass.value,
                    onToggle: () => controller.showNewPass.toggle(),
                    errorText: controller.passwordError.value.contains('New') 
                        ? controller.passwordError.value 
                        : null,
                  ),
                ),
                const SizedBox(height: 12),
                Obx(
                  () => _PasswordField(
                    label: 'Confirm New Password',
                    controller: controller.confPassCtrl,
                    showPass: controller.showConfPass.value,
                    onToggle: () => controller.showConfPass.toggle(),
                    errorText: controller.passwordError.value.contains('match') 
                        ? controller.passwordError.value 
                        : null,
                  ),
                ),
                const SizedBox(height: 24),
  
                Obx(
                  () {
                    final isEnabled = controller.isPasswordChanged.value && 
                                    controller.passwordError.value.isEmpty && 
                                    !controller.isChangingPass.value;
                    
                    return GestureDetector(
                      onTap: isEnabled ? () => controller.changePassword(context) : null,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: double.infinity,
                        height: 50,
                        decoration: BoxDecoration(
                          color: isEnabled ? AppColors.dark : AppColors.border,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Center(
                          child: controller.isChangingPass.value
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  'Update Password',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: isEnabled ? Colors.white : AppColors.textTertiary,
                                  ),
                                ),
                        ),
                      ),
                    );
                  },
                ),
  
                const SizedBox(height: 24),
                const Divider(color: AppColors.border),
                const SizedBox(height: 16),
  
                // Privacy info section
                Text(
                  'Privacy Information',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                _PrivacyInfoRow(
                  icon: Icons.shield_outlined,
                  title: 'Data Encryption',
                  subtitle: 'All your data is encrypted with 256-bit SSL',
                ),
                _PrivacyInfoRow(
                  icon: Icons.location_off_outlined,
                  title: 'Location Privacy',
                  subtitle: 'Location data is only used for vehicle tracking',
                ),
                _PrivacyInfoRow(
                  icon: Icons.delete_outline_rounded,
                  title: 'Data Deletion',
                  subtitle: 'You can request data deletion by contacting support',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Help & Support Bottom Sheet ───────────
  void _showHelpSheet(BuildContext context) {
    final controller = Get.find<ProfileController>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _BottomSheet(
        title: 'Help & Support',
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _HelpItem(
              icon: Icons.chat_bubble_outline_rounded,
              title: 'Live Chat',
              subtitle: 'Chat with our support team',
              onTap: () {},
              isComingSoon: true,
            ),
            _HelpItem(
              icon: Icons.email_outlined,
              title: 'Email Support',
              subtitle: 'kamalivs20@gmail.com',
              onTap: () => controller.launchURL('mailto:kamalivs20@gmail.com'),
            ),
            _HelpItem(
              icon: Icons.phone_outlined,
              title: 'Call Support',
              subtitle: '+91 6381779723',
              onTap: () => controller.launchURL('tel:+916381779723'),
            ),
            _HelpItem(
              icon: Icons.menu_book_outlined,
              title: 'Documentation',
              subtitle: 'Read our user guide & FAQs',
              onTap: () => controller.generateUserGuide(),
            ),
            _HelpItem(
              icon: Icons.bug_report_outlined,
              title: 'Report a Bug',
              subtitle: 'Help us improve the app',
              onTap: () {},
              isComingSoon: true,
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.purpleSoft,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    'Outrace VTS',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.purple,
                    ),
                  ),
                  Text(
                    'Version 1.0.0 • Build 100',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      color: AppColors.textTertiary,
                    ),
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

// ── Bottom Sheet wrapper ──────────────────────────────────
class _BottomSheet extends StatelessWidget {
  final String title;
  final Widget child;

  const _BottomSheet({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }
}

// ── Sheet input field ─────────────────────────────────────
class _SheetInputField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final IconData icon;
  final TextInputType inputType;
  final int? maxLength;
  final String? errorText;

  const _SheetInputField({
    required this.label,
    required this.controller,
    required this.icon,
    this.inputType = TextInputType.text,
    this.maxLength,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: errorText != null ? AppColors.red : AppColors.border,
              width: 1.5,
            ),
          ),
          child: TextField(
            controller: controller,
            keyboardType: inputType,
            maxLength: maxLength,
            inputFormatters: maxLength != null
                ? [FilteringTextInputFormatter.digitsOnly]
                : null,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              color: AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: AppColors.textTertiary, size: 18),
              border: InputBorder.none,
              counterText: '',
              contentPadding: const EdgeInsets.symmetric(
                vertical: 14,
                horizontal: 14,
              ),
            ),
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 4),
          Text(
            errorText!,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              color: AppColors.red,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }
}

// ── Password field ────────────────────────────────────────
class _PasswordField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool showPass;
  final VoidCallback onToggle;
  final String? errorText;

  const _PasswordField({
    required this.label,
    required this.controller,
    required this.showPass,
    required this.onToggle,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: errorText != null ? AppColors.red : AppColors.border,
              width: 1.5,
            ),
          ),
          child: TextField(
            controller: controller,
            obscureText: !showPass,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              color: AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.lock_outline_rounded,
                  color: AppColors.textTertiary, size: 18),
              suffixIcon: GestureDetector(
                onTap: onToggle,
                child: Icon(
                  showPass ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                  color: AppColors.textTertiary,
                  size: 18,
                ),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 14,
                horizontal: 14,
              ),
            ),
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 4),
          Text(
            errorText!,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              color: AppColors.red,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }
}
// ── Privacy info row ──────────────────────────────────────
class _PrivacyInfoRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _PrivacyInfoRow({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.purpleSoft,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.purple, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
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

// ── Help item ─────────────────────────────────────────────
class _HelpItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isComingSoon;

  const _HelpItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isComingSoon = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isComingSoon ? null : onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.bg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isComingSoon
                    ? AppColors.textTertiary
                    : AppColors.textSecondary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: isComingSoon
                              ? AppColors.textTertiary
                              : AppColors.textPrimary,
                        ),
                      ),
                      if (isComingSoon) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.bg,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Coming Soon',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textTertiary,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 13,
              color: isComingSoon
                  ? AppColors.textTertiary.withOpacity(0.3)
                  : AppColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Widgets ───────────────────────────────────────────────
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
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11,
            color: Colors.white.withOpacity(0.5),
          ),
        ),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 28,
      color: Colors.white.withOpacity(0.15),
      margin: const EdgeInsets.symmetric(horizontal: 20),
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
  final RxInt? trailingObs;
  final bool isDestructive;
  final VoidCallback? onTap;
  final String? customIconAsset;
  final bool isComingSoon;
  final bool isLoading;

  const _MenuItem({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.label,
    this.trailing,
    this.trailingObs,
    this.isDestructive = false,
    this.onTap,
    this.customIconAsset,
    this.isComingSoon = false,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Container(
        margin: const EdgeInsets.only(bottom: 8),
        height: 62,
        child: Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      );
    }
    return GestureDetector(
      onTap: isComingSoon ? null : onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
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
              child: customIconAsset != null
                  ? Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Image.asset(customIconAsset!, color: iconColor),
                    )
                  : Icon(icon, size: 18, color: iconColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        label,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDestructive
                              ? AppColors.red
                              : isComingSoon
                              ? AppColors.textTertiary
                              : AppColors.textPrimary,
                        ),
                      ),
                      if (isComingSoon) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.bg,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Coming Soon',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textTertiary,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            // Static trailing
            if (trailing != null && !isComingSoon) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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

            // Reactive trailing from API
            if (trailingObs != null && !isComingSoon) ...[
              Obx(
                () => trailingObs!.value > 0
                    ? Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.purpleSoft,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${trailingObs!.value}',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.purple,
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
              const SizedBox(width: 6),
            ],

            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 13,
              color: isDestructive ? AppColors.red : AppColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }
}
