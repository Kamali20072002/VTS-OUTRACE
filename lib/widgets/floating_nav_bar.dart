import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class FloatingNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const FloatingNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(
          top: BorderSide(color: AppColors.border, width: 0.5),
        ),
      ),
      padding: EdgeInsets.fromLTRB(0, 8, 0, bottomPad + 8),
      child: Row(
        children: [
          _NavItem(
            iconPath: 'assets/icons/nav_home.png',
            label: 'Home',
            isActive: currentIndex == 0,
            onTap: () => onTap(0),
          ),
          _NavItem(
            iconPath: 'assets/icons/nav_track.png',
            label: 'Track',
            isActive: currentIndex == 1,
            onTap: () => onTap(1),
          ),
          _NavItem(
            iconPath: 'assets/icons/nav_trips.png',
            label: 'Trips',
            isActive: currentIndex == 2,
            onTap: () => onTap(2),
          ),
          _NavItem(
            iconPath: 'assets/icons/nav_profile.png',
            label: 'Profile',
            isActive: currentIndex == 3,
            onTap: () => onTap(3),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final String iconPath;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.iconPath,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon with color filter for active state
            ColorFiltered(
              colorFilter: ColorFilter.mode(
                isActive
                    ? AppColors.purple
                    : AppColors.textTertiary,
                BlendMode.srcIn,
              ),
              child: Image.asset(
                iconPath,
                width: 24,
                height: 24,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: isActive
                    ? FontWeight.w700
                    : FontWeight.w500,
                color: isActive
                    ? AppColors.purple
                    : AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}