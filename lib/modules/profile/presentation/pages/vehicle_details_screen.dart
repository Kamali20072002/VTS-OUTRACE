import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../theme/app_theme.dart';
import '../../../../widgets/common_widgets.dart';
import '../controller/vehicle_details_controller.dart';
import '../../domain/models/profile_model.dart';
import 'package:intl/intl.dart';
import '../../../track/presentation/pages/track_screen.dart';

class VehicleDetailsScreen extends StatelessWidget {
  final String vehicleId;
  final String vehicleImage;

  const VehicleDetailsScreen({
    super.key,
    required this.vehicleId,
    required this.vehicleImage,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(
      VehicleDetailsController(vehicleId: vehicleId),
      tag: vehicleId,
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: Obx(() {
        final vehicle = controller.vehicle.value;
        final isLoading = controller.isLoading.value;

        if (!isLoading && vehicle == null) {
          return const Center(child: Text('Vehicle not found'));
        }

        return Stack(
          children: [
            // Top Image Header with Blending
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: MediaQuery.of(context).size.height * 0.45,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    vehicleImage,
                    fit: BoxFit.cover,
                    alignment: Alignment.center,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.3),
                          Colors.transparent,
                          Colors.white.withOpacity(0.8),
                          Colors.white,
                        ],
                        stops: const [0.0, 0.4, 0.8, 1.0],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Back Button
            Positioned(
              top: MediaQuery.of(context).padding.top + 10,
              left: 20,
              child: _CircleButton(
                icon: Icons.arrow_back_ios_new_rounded,
                onPressed: () => Get.back(),
              ),
            ),

            // Content Area
            Positioned.fill(
              top: MediaQuery.of(context).size.height * 0.38,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Stats Badges
                    isLoading 
                      ? Row(
                          children: const [
                            Skeleton(height: 35, width: 80, borderRadius: 12),
                            SizedBox(width: 8),
                            Skeleton(height: 35, width: 80, borderRadius: 12),
                            SizedBox(width: 8),
                            Skeleton(height: 35, width: 80, borderRadius: 12),
                          ],
                        )
                      : Row(
                          children: [
                            _StatusBadge(
                              icon: Icons.battery_charging_full_rounded,
                              label: '${vehicle?.batteryLevel ?? 0}%',
                              color: AppColors.green,
                            ),
                            const SizedBox(width: 8),
                            _StatusBadge(
                              icon: Icons.local_gas_station_rounded,
                              label: '${vehicle?.fuelLevel ?? 0}%',
                              color: AppColors.amber,
                            ),
                            const SizedBox(width: 8),
                            _StatusBadge(
                              icon: Icons.sensors_rounded,
                              label: (vehicle?.isOnline ?? false) ? 'Online' : 'Offline',
                              color: (vehicle?.isOnline ?? false) ? AppColors.green : AppColors.red,
                            ),
                          ],
                        ),
                    const SizedBox(height: 20),

                    // Reg Number and Model
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        isLoading
                          ? const Skeleton(height: 40, width: 220)
                          : Text(
                              vehicle?.registrationNumber ?? '',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                color: AppColors.purple,
                              ),
                            ),
                        const SizedBox(height: 4),
                        isLoading
                          ? const Skeleton(height: 24, width: 140)
                          : Text(
                              vehicle?.model ?? '',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textSecondary,
                              ),
                            ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // About / Device Info
                    Text(
                      'About Vehicle',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.dark,
                      ),
                    ),
                    const SizedBox(height: 12),
                    isLoading
                      ? const Skeleton(height: 60)
                      : Text(
                          'This ${vehicle?.type.toLowerCase() ?? 'vehicle'} is currently ${vehicle?.status.toLowerCase() ?? 'unknown'}. Equipped with tracker ID ${vehicle?.trackerId ?? 'N/A'} (IMEI: ${vehicle?.imei ?? 'N/A'}). Last updated ${_formatLastSeen(vehicle?.lastSeen)}.',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 15,
                            color: AppColors.textSecondary,
                            height: 1.6,
                          ),
                        ),
                    const SizedBox(height: 32),

                    // Recent Trips Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Recent Trips',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.dark,
                          ),
                        ),
                        if (!isLoading && vehicle?.recentTrips != null && vehicle!.recentTrips!.length > 2)
                          TextButton(
                            onPressed: () => Get.to(
                              () => TripHistoryScreen(vehicle: vehicle),
                              transition: Transition.rightToLeft,
                            ),
                            child: Text(
                              'View All',
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.w700,
                                color: AppColors.purple,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Recent Trips List (Top 2)
                    if (isLoading)
                      Column(
                        children: const [
                          Skeleton(height: 80, borderRadius: 20),
                          SizedBox(height: 12),
                          Skeleton(height: 80, borderRadius: 20),
                        ],
                      )
                    else if (vehicle?.recentTrips == null || vehicle!.recentTrips!.isEmpty)
                      _buildEmptyTrips()
                    else
                      ...vehicle.recentTrips!.take(2).map((trip) => _TripCard(trip: trip)),

                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),

            // Bottom Floating Button
            if (!isLoading)
              Positioned(
                bottom: MediaQuery.of(context).padding.bottom + 20,
                left: 24,
                right: 24,
                child: GestureDetector(
                  onTap: () => Get.to(() => const TrackScreen()),
                  child: Container(
                    height: 64,
                    decoration: BoxDecoration(
                      color: AppColors.dark,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.dark.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.location_on_rounded, color: Colors.white),
                        const SizedBox(width: 12),
                        Text(
                          'Track on Live Map',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        );
      }),
    );
  }

  Widget _buildEmptyTrips({String message = 'No recent trips recorded'}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      decoration: BoxDecoration(
        color: AppColors.purple.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.purple.withOpacity(0.15), width: 1.5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.purple.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.history_rounded,
              color: AppColors.purple,
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.purple,
            ),
          ),
        ],
      ),
    );
  }

  String _formatLastSeen(String? lastSeen) {
    if (lastSeen == null) return 'Never';
    try {
      final date = DateTime.parse(lastSeen).toLocal();
      final now = DateTime.now();
      final diff = now.difference(date);
      if (diff.inMinutes < 1) return 'just now';
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      return DateFormat('MMM dd').format(date);
    } catch (_) {
      return 'Unknown';
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SUPPORTING WIDGETS
// ─────────────────────────────────────────────────────────────────────────────

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  const _CircleButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: AppColors.dark, size: 20),
        onPressed: onPressed,
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _StatusBadge({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.dark,
            ),
          ),
        ],
      ),
    );
  }
}

class _TripCard extends StatelessWidget {
  final RecentTrip trip;
  const _TripCard({required this.trip});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Journey Line
              Column(
                children: [
                  const Icon(Icons.circle, size: 12, color: Colors.blue),
                  Container(
                    width: 1,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      border: Border.all(color: AppColors.border, width: 0.5),
                    ),
                  ),
                  const Icon(Icons.location_on_rounded, size: 16, color: Colors.black),
                ],
              ),
              const SizedBox(width: 16),
              // Locations
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Start Location',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textTertiary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      trip.startLocation.displayName,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.dark,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Destination',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textTertiary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      trip.endLocation.displayName,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.dark,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              // Trip Stats (Distance/Time)
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${trip.distance.toStringAsFixed(1)} KM',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: AppColors.green,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Time',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textTertiary,
                    ),
                  ),
                  Text(
                    _formatDuration(trip.duration),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColors.dark,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateFormat('MMM dd, yyyy • hh:mm a').format(DateTime.parse(trip.startTime).toLocal()),
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.bg,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  trip.status,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDuration(double seconds) {
    final duration = Duration(seconds: seconds.toInt());
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    if (hours > 0) return '${hours}h ${minutes}m';
    return '${minutes}m';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TRIP HISTORY SCREEN
// ─────────────────────────────────────────────────────────────────────────────

class TripHistoryScreen extends StatefulWidget {
  final VehicleModel vehicle;
  const TripHistoryScreen({super.key, required this.vehicle});

  @override
  State<TripHistoryScreen> createState() => _TripHistoryScreenState();
}

class _TripHistoryScreenState extends State<TripHistoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isNewestFirst = true;
  DateTime? _selectedDate;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<RecentTrip> get _filteredTrips {
    final trips = List<RecentTrip>.from(widget.vehicle.recentTrips ?? []);
    
    // Sort
    trips.sort((a, b) {
      final dateA = DateTime.parse(a.startTime);
      final dateB = DateTime.parse(b.startTime);
      return _isNewestFirst ? dateB.compareTo(dateA) : dateA.compareTo(dateB);
    });

    return trips.where((trip) {
      // Date Filter
      if (_selectedDate != null) {
        final tripDate = DateTime.parse(trip.startTime).toLocal();
        if (tripDate.year != _selectedDate!.year || 
            tripDate.month != _selectedDate!.month || 
            tripDate.day != _selectedDate!.day) return false;
      }

      // Search Filter (Area only)
      if (_searchQuery.isEmpty) return true;
      final startLabel = trip.startLocation.displayName.toLowerCase();
      final endLabel = trip.endLocation.displayName.toLowerCase();
      final query = _searchQuery.toLowerCase();
      return startLabel.contains(query) || endLabel.contains(query);
    }).toList();
  }

  void _showSortDialog() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Sort History',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.dark,
                  ),
                ),
                GestureDetector(
                  onTap: () => Get.back(),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.bg,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close_rounded, size: 20, color: AppColors.dark),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _SortOption(
              label: 'Newest First',
              icon: Icons.south_rounded,
              isSelected: _isNewestFirst,
              onTap: () {
                setState(() => _isNewestFirst = true);
                Get.back();
              },
            ),
            const SizedBox(height: 12),
            _SortOption(
              label: 'Oldest First',
              icon: Icons.north_rounded,
              isSelected: !_isNewestFirst,
              onTap: () {
                setState(() => _isNewestFirst = false);
                Get.back();
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredTrips;
    final recentTrips = filtered.take(2).toList();
    final pastTrips = filtered.length > 2 ? filtered.sublist(2) : <RecentTrip>[];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Text(
          'Trip History',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.dark,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.dark, size: 20),
          onPressed: () => Get.back(),
        ),
      ),
      body: Column(
        children: [
          // Search, Sort, and Filter Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
            child: Column(
              children: [
                Container(
                  height: 50,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppColors.bg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.search_rounded, color: AppColors.textTertiary, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          onChanged: (val) => setState(() => _searchQuery = val),
                          style: GoogleFonts.plusJakartaSans(fontSize: 14, color: AppColors.dark),
                          inputFormatters: [
                            FilteringTextInputFormatter.deny(
                              RegExp(r'[\u{1f300}-\u{1f5ff}\u{1f600}-\u{1f64f}\u{1f680}-\u{1f6ff}\u{1f900}-\u{1f9ff}\u{1f1e6}-\u{1f1ff}\u{2600}-\u{26ff}\u{2700}-\u{27bf}\u{1f3fb}-\u{1f3ff}\u{1f191}-\u{1f251}\u{1f004}\u{1f0cf}\u{1f170}-\u{1f171}\u{1f17e}-\u{1f17f}\u{1f18e}\u{3030}\u{2b50}\u{2b55}\u{2934}-\u{2935}\u{2b05}-\u{2b07}\u{2b1b}-\u{2b1c}\u{3297}\u{3299}\u{303d}\u{00a9}\u{00ae}\u{2122}]', unicode: true),
                            ),
                          ],
                          decoration: InputDecoration(
                            hintText: 'Search by area...',
                            hintStyle: GoogleFonts.plusJakartaSans(color: AppColors.textTertiary),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    // Sort Button
                    Expanded(
                      child: GestureDetector(
                        onTap: _showSortDialog,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.sort_rounded, size: 16, color: AppColors.purple),
                              const SizedBox(width: 8),
                              Text(
                                'Sort',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.dark,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Date Filter
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: _selectedDate ?? DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now(),
                            builder: (context, child) {
                              return Theme(
                                data: Theme.of(context).copyWith(
                                  colorScheme: const ColorScheme.light(
                                    primary: AppColors.purple,
                                    onPrimary: Colors.white,
                                    onSurface: AppColors.dark,
                                  ),
                                ),
                                child: child!,
                              );
                            },
                          );
                          if (date != null) setState(() => _selectedDate = date);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                          decoration: BoxDecoration(
                            color: _selectedDate != null ? AppColors.purple.withOpacity(0.05) : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: _selectedDate != null ? AppColors.purple.withOpacity(0.3) : AppColors.border),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.calendar_today_rounded, size: 14, color: _selectedDate != null ? AppColors.purple : AppColors.textTertiary),
                              const SizedBox(width: 8),
                              Text(
                                _selectedDate == null ? 'Filter by Date' : DateFormat('MMM dd').format(_selectedDate!),
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: _selectedDate != null ? AppColors.purple : AppColors.dark,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (_selectedDate != null) ...[
                                const SizedBox(width: 4),
                                GestureDetector(
                                  onTap: () => setState(() => _selectedDate = null),
                                  child: const Icon(Icons.close_rounded, size: 14, color: AppColors.purple),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              children: [
                if (filtered.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 40),
                    child: VehicleDetailsScreen(vehicleId: '', vehicleImage: '')._buildEmptyTrips(
                      message: _selectedDate != null 
                        ? 'No trips found for ${DateFormat('MMM dd').format(_selectedDate!)}'
                        : 'No trips match your search'
                    ),
                  )
                else ...[
                  if (recentTrips.isNotEmpty) ...[
                    _buildSectionHeader('Recent Trips', Icons.history_rounded),
                    ...recentTrips.map((trip) => _TripCard(trip: trip)),
                  ],
                  if (pastTrips.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _buildSectionHeader('Past Trips', Icons.restore_rounded),
                    ...pastTrips.map((trip) => _TripCard(trip: trip)),
                  ],
                ],
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, top: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.purple),
          const SizedBox(width: 8),
          Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.dark,
            ),
          ),
        ],
      ),
    );
  }
}

class _SortOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _SortOption({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.purple.withOpacity(0.05) : AppColors.bg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.purple.withOpacity(0.3) : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.purple.withOpacity(0.1) : Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                size: 20,
                color: isSelected ? AppColors.purple : AppColors.textTertiary,
              ),
            ),
            const SizedBox(width: 16),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? AppColors.purple : AppColors.dark,
              ),
            ),
            const Spacer(),
            if (isSelected)
              const Icon(Icons.check_circle_rounded, color: AppColors.purple, size: 24),
          ],
        ),
      ),
    );
  }
}

