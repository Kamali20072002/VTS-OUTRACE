import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import '../../../../theme/app_theme.dart';

class TripDetailsScreen extends StatefulWidget {
  final dynamic trip;
  const TripDetailsScreen({super.key, required this.trip});

  @override
  State<TripDetailsScreen> createState() => _TripDetailsScreenState();
}

class _TripDetailsScreenState extends State<TripDetailsScreen> {
  GoogleMapController? _mapController;
  final Set<Polyline> _polylines = {};
  final Set<Marker> _markers = {};

  // ── Derived data ────────────────────────────────────────────────────────────
  String get _vehicleReg =>
      widget.trip['vehicleId']?['registrationNumber'] ?? 'Unknown Vehicle';
  String get _vehicleModel =>
      widget.trip['vehicleId']?['model'] ?? 'Unknown';
  String get _status =>
      (widget.trip['status'] ?? 'COMPLETED').toString().toUpperCase();
  double get _distanceKm {
    final d = widget.trip['distance'];
    if (d is num) return d.toDouble();
    if (d is String) {
      return double.tryParse(d.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;
    }
    return 0.0;
  }
  double get _durationSec =>
      (widget.trip['duration'] as num? ?? 0).toDouble();
  String get _startArea =>
      widget.trip['startLocation']?['area'] ?? 'Start Point';
  String get _startAddress =>
      widget.trip['startLocation']?['address'] ?? '';
  String get _startLandmark =>
      widget.trip['startLocation']?['landmark'] ?? '';
  String get _endArea =>
      widget.trip['endLocation']?['area'] ?? 'End Point';
  String get _endAddress =>
      widget.trip['endLocation']?['address'] ?? '';
  String get _batteryLevel =>
      '${widget.trip['deviceId']?['battery_level'] ?? '--'}%';
  String get _fuelLevel =>
      '${widget.trip['deviceId']?['fuel_level'] ?? '--'}%';
  String get _moduleModel =>
      widget.trip['deviceId']?['module_model'] ?? '--';

  String get _timeRange {
    try {
      final start = DateTime.parse(widget.trip['startTime']).toLocal();
      final end = DateTime.parse(widget.trip['endTime']).toLocal();
      final fmt = DateFormat('hh:mm a');
      return '${fmt.format(start)} - ${fmt.format(end)}';
    } catch (_) {
      return widget.trip['time'] ?? '';
    }
  }

  String get _dateLabel {
    try {
      final dt = DateTime.parse(widget.trip['startTime']).toLocal();
      return DateFormat('EEE, dd MMM yyyy').format(dt);
    } catch (_) {
      return '';
    }
  }

  String get _distanceLabel {
    if (_distanceKm < 1) {
      return '${(_distanceKm * 1000).toStringAsFixed(0)} m';
    }
    return '${_distanceKm.toStringAsFixed(2)} km';
  }

  String get _durationLabel {
    final mins = (_durationSec / 60).floor();
    final secs = (_durationSec % 60).floor();
    if (mins >= 60) {
      final hrs = (mins / 60).floor();
      final rem = mins % 60;
      return '${hrs}h ${rem}m';
    }
    return '${mins}m ${secs}s';
  }

  double get _avgSpeed {
    final path = widget.trip['path'] as List<dynamic>? ?? [];
    if (path.isEmpty) return 0;
    final speeds = path
        .map((p) => (p['speed'] as num?)?.toDouble() ?? 0.0)
        .where((s) => s > 0)
        .toList();
    if (speeds.isEmpty) return 0;
    return speeds.reduce((a, b) => a + b) / speeds.length;
  }

  String get _avgSpeedLabel => '${_avgSpeed.toStringAsFixed(1)} km/h';

  // ── Map init ─────────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _buildMapData();
  }

  void _buildMapData() {
    final path = widget.trip['path'] as List<dynamic>? ?? [];
    if (path.isEmpty) return;

    final points = path
        .map((p) => LatLng(
              (p['lat'] as num).toDouble(),
              (p['lon'] as num).toDouble(),
            ))
        .toList();

    _polylines.add(Polyline(
      polylineId: const PolylineId('route'),
      points: points,
      color: AppColors.purple,
      width: 5,
      jointType: JointType.round,
      startCap: Cap.roundCap,
      endCap: Cap.roundCap,
    ));

    _markers.add(Marker(
      markerId: const MarkerId('start'),
      position: points.first,
      infoWindow: InfoWindow(title: _startArea),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
    ));
    _markers.add(Marker(
      markerId: const MarkerId('end'),
      position: points.last,
      infoWindow: InfoWindow(title: _endArea),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    ));
  }

  void _onMapCreated(GoogleMapController c) {
    _mapController = c;
    _fitBounds();
  }

  void _fitBounds() {
    final path = widget.trip['path'] as List<dynamic>? ?? [];
    if (path.isEmpty || _mapController == null) return;

    double minLat = 90, maxLat = -90, minLon = 180, maxLon = -180;
    for (final p in path) {
      final lat = (p['lat'] as num).toDouble();
      final lon = (p['lon'] as num).toDouble();
      if (lat < minLat) minLat = lat;
      if (lat > maxLat) maxLat = lat;
      if (lon < minLon) minLon = lon;
      if (lon > maxLon) maxLon = lon;
    }
    _mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLat, minLon),
          northeast: LatLng(maxLat, maxLon),
        ),
        60,
      ),
    );
  }

  // ── Build ────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final path = widget.trip['path'] as List<dynamic>? ?? [];
    final initialPos = path.isNotEmpty
        ? LatLng(
            (path.first['lat'] as num).toDouble(),
            (path.first['lon'] as num).toDouble(),
          )
        : const LatLng(12.9716, 77.5946);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // ── Full screen map ─────────────────────────────────────────────────
          Positioned.fill(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: initialPos,
                zoom: 14,
              ),
              onMapCreated: _onMapCreated,
              polylines: _polylines,
              markers: _markers,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              mapToolbarEnabled: false,
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).size.height * 0.52,
              ),
            ),
          ),

          // ── Dark AppBar overlay ─────────────────────────────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF1E2632).withOpacity(0.96),
                    const Color(0xFF1E2632).withOpacity(0.0),
                  ],
                ),
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Text(
                      'Trip Details',
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                      ),
                    ),
                    const Spacer(),
                    // Status badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 5),
                      margin: const EdgeInsets.only(right: 16),
                      decoration: BoxDecoration(
                        color: _status == 'COMPLETED'
                            ? AppColors.green.withOpacity(0.2)
                            : AppColors.amber.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _status == 'COMPLETED'
                              ? AppColors.green
                              : AppColors.amber,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        _status,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: _status == 'COMPLETED'
                              ? AppColors.green
                              : AppColors.amber,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── White bottom sheet ──────────────────────────────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.54,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 24,
                    offset: Offset(0, -6),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // Drag handle
                    Center(
                      child: Container(
                        margin: const EdgeInsets.only(top: 12, bottom: 16),
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE0E0E0),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),

                    // ── Vehicle + time row ────────────────────────────────────
                    Row(
                      children: [
                        // Vehicle pill
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.purple.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.purple.withOpacity(0.2),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.directions_car_rounded,
                                  size: 16, color: AppColors.purple),
                              const SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _vehicleReg,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    _vehicleModel,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.textTertiary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        // Date + time
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              _timeRange,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _dateLabel,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                color: AppColors.textTertiary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // ── Stats row ─────────────────────────────────────────────
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F8FF),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: AppColors.purple.withOpacity(0.1),
                        ),
                      ),
                      child: Row(
                        children: [
                          _StatTile(
                            icon: Icons.route_rounded,
                            iconColor: AppColors.purple,
                            value: _distanceLabel,
                            label: 'Distance',
                          ),
                          _VerticalDivider(),
                          _StatTile(
                            icon: Icons.timer_rounded,
                            iconColor: AppColors.green,
                            value: _durationLabel,
                            label: 'Duration',
                          ),
                          _VerticalDivider(),
                          _StatTile(
                            icon: Icons.speed_rounded,
                            iconColor: AppColors.amber,
                            value: _avgSpeedLabel,
                            label: 'Avg Speed',
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    // ── Route timeline ────────────────────────────────────────
                    Text(
                      'Route',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),

                    _RouteTimeline(
                      startArea: _startArea,
                      startAddress: _startAddress,
                      startLandmark: _startLandmark,
                      endArea: _endArea,
                      endAddress: _endAddress,
                    ),

                    const SizedBox(height: 18),

                    // ── Device info row ───────────────────────────────────────
                    Text(
                      'Device Info',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        _DeviceChip(
                          icon: Icons.battery_charging_full_rounded,
                          color: AppColors.green,
                          label: 'Battery',
                          value: _batteryLevel,
                        ),
                        const SizedBox(width: 10),
                        _DeviceChip(
                          icon: Icons.local_gas_station_rounded,
                          color: AppColors.amber,
                          label: 'Fuel',
                          value: _fuelLevel,
                        ),
                        const SizedBox(width: 10),
                        _DeviceChip(
                          icon: Icons.memory_rounded,
                          color: AppColors.purple,
                          label: 'Module',
                          value: _moduleModel,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Stat tile ──────────────────────────────────────────────────────────────────
class _StatTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  const _StatTile({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              color: AppColors.textTertiary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ── Vertical divider ───────────────────────────────────────────────────────────
class _VerticalDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 50,
      color: const Color(0xFFEEEEEE),
      margin: const EdgeInsets.symmetric(horizontal: 4),
    );
  }
}

// ── Route timeline ─────────────────────────────────────────────────────────────
class _RouteTimeline extends StatelessWidget {
  final String startArea;
  final String startAddress;
  final String startLandmark;
  final String endArea;
  final String endAddress;

  const _RouteTimeline({
    required this.startArea,
    required this.startAddress,
    required this.startLandmark,
    required this.endArea,
    required this.endAddress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFEEEEEE)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Start row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: AppColors.green,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.green.withOpacity(0.4),
                          blurRadius: 6,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 2,
                    height: 44,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.green.withOpacity(0.6),
                          AppColors.red.withOpacity(0.6),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      startArea,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (startLandmark.isNotEmpty &&
                        startLandmark != 'No Landmark') ...[
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(Icons.place_rounded,
                              size: 12, color: AppColors.textTertiary),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              startLandmark,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.purple,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (startAddress.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        startAddress,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          color: AppColors.textTertiary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),

          // End row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: AppColors.red,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.red.withOpacity(0.4),
                      blurRadius: 6,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      endArea,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (endAddress.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        endAddress,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          color: AppColors.textTertiary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Device chip ────────────────────────────────────────────────────────────────
class _DeviceChip extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String value;

  const _DeviceChip({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.07),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.15)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 6),
            Text(
              value,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10,
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}