import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:notix_pro/notix_pro.dart';
import '../../../../widgets/map_marker_helper.dart';
import '../../../profile/presentation/controller/profile_controller.dart';
import '../../../trips/presentation/controller/trips_controller.dart';
import '../../../track/domain/models/active_vehicle_model.dart';
import '../../../track/domain/repositories/track_repository.dart';

class HomeController extends GetxController {
  final TrackRepository _repo = TrackRepository();
  final RxInt currentIndex = 0.obs;

  // ── Scroll Controllers ────────────────────────
  final ScrollController homeScrollController = ScrollController();
  final ScrollController tripsScrollController = ScrollController();
  final ScrollController profileScrollController = ScrollController();

  // ── Map ─────────────────────────────────────
  GoogleMapController? homeMapController;
  LatLng mapCenter = const LatLng(12.9125, 77.6062);

  RxSet<Marker> homeMarkers = <Marker>{}.obs;
  RxSet<Polyline> homePolylines = <Polyline>{}.obs;

  // ── Vehicles ─────────────────────────────────
  final RxList<ActiveVehicleModel> vehicles = <ActiveVehicleModel>[].obs;
  final RxList<ActiveVehicleModel> filteredVehicles = <ActiveVehicleModel>[].obs;
  final RxList<String> vehicleTypes = <String>[].obs;
  final RxString selectedType = 'All'.obs;
  final RxString searchQuery = ''.obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    currentIndex.value = 0;
    loadActiveVehicles();
  }

  Future<void> loadActiveVehicles({bool forceRefresh = false}) async {
    // Show loading only if no vehicles are currently present
    if (vehicles.isEmpty) {
      isLoading.value = true;
    }
    
    try {
      final list = await _repo.getActiveVehicles(forceRefresh: forceRefresh);
      vehicles.value = list;
      
      // Extract unique types
      final types = list.map((v) => v.type).toSet().toList();
      vehicleTypes.value = ['All', ...types];
      
      applyFilters();
    } catch (e) {
      debugPrint('Home Load Error: $e');
      if (Get.context != null && !forceRefresh) {
        // Only show toast if it's NOT a background refresh
        NotixToast.show(
          Get.context!,
          type: NotixType.error,
          title: 'Error',
          message: e.toString().contains('AppException') ? e.toString().split(':').last.trim() : 'Failed to load vehicles',
          position: NotixToastPosition.top,
        );
      }
    } finally {
      isLoading.value = false;
    }
  }

  void filterVehicles(String type) {
    selectedType.value = type;
    applyFilters();
  }

  void onSearch(String query) {
    searchQuery.value = query;
    applyFilters();
  }

  void applyFilters() {
    List<ActiveVehicleModel> results = vehicles;

    // Type filter
    if (selectedType.value != 'All') {
      results = results.where((v) => v.type == selectedType.value).toList();
    }

    // Search filter
    if (searchQuery.value.isNotEmpty) {
      final q = searchQuery.value.toLowerCase();
      results = results.where((v) =>
          v.model.toLowerCase().contains(q) ||
          v.registrationNumber.toLowerCase().contains(q)).toList();
    }

    filteredVehicles.value = results;
    _updateMarkers();
  }

  Future<void> _updateMarkers() async {
    final Set<Marker> markers = {};
    for (var v in filteredVehicles) {
      if (v.latitude != null && v.longitude != null) {
        final icon = await MapMarkerHelper.createVehicleMarker(
          type: v.type,
          isOnline: v.isOnline,
          zoom: 12,
          course: v.course ?? 0,
        );

        markers.add(
          Marker(
            markerId: MarkerId(v.id),
            position: LatLng(v.latitude!, v.longitude!),
            infoWindow: InfoWindow(
              title: v.model,
              snippet: v.registrationNumber,
            ),
            icon: icon,
          ),
        );
      }
    }
    homeMarkers.value = markers;

    if (markers.isNotEmpty) {
      mapCenter = markers.first.position;
      homeMapController?.animateCamera(
        CameraUpdate.newLatLng(mapCenter),
      );
    }
    update();
  }

  void onHomeMapCreated(GoogleMapController controller) {
    homeMapController = controller;
    // ignore: deprecated_member_use
    homeMapController?.setMapStyle(_mapStyle);
    if (homeMarkers.isNotEmpty) {
      homeMapController?.animateCamera(
        CameraUpdate.newLatLng(homeMarkers.first.position),
      );
    }
    update();
  }

  final String _mapStyle = '''
[
  {
    "featureType": "poi",
    "stylers": [{"visibility": "off"}]
  },
  {
    "featureType": "transit",
    "stylers": [{"visibility": "off"}]
  },
  {
    "featureType": "road",
    "elementType": "geometry",
    "stylers": [{"color": "#f5f5f5"}]
  },
  {
    "featureType": "road",
    "elementType": "labels.text.fill",
    "stylers": [{"color": "#9e9e9e"}]
  },
  {
    "featureType": "water",
    "elementType": "geometry",
    "stylers": [{"color": "#c9d8e8"}]
  },
  {
    "featureType": "landscape",
    "elementType": "geometry",
    "stylers": [{"color": "#f2f2f2"}]
  },
  {
    "featureType": "road.arterial",
    "elementType": "geometry",
    "stylers": [{"color": "#ffffff"}]
  },
  {
    "featureType": "road.highway",
    "elementType": "geometry",
    "stylers": [{"color": "#dadada"}]
  }
]
''';

  int get totalVehicles => vehicles.length;
  int get onlineVehicles =>
      vehicles.where((v) => v.isOnline).length;
  int get offlineVehicles =>
      vehicles.where((v) => !v.isOnline).length;

  void changeTab(int index) {
    currentIndex.value = index;
    // Trigger refresh and scroll reset for the target tab
    switch (index) {
      case 0:
        if (homeScrollController.hasClients) {
          homeScrollController.jumpTo(0.0);
        }
        loadActiveVehicles();
        break;
      case 2:
        if (tripsScrollController.hasClients) {
          tripsScrollController.jumpTo(0.0);
        }
        if (Get.isRegistered<TripsController>()) {
          Get.find<TripsController>().fetchTrips();
        }
        break;
      case 3:
        if (profileScrollController.hasClients) {
          profileScrollController.jumpTo(0.0);
        }
        if (Get.isRegistered<ProfileController>()) {
          Get.find<ProfileController>().refreshProfile();
        }
        break;
    }
  }

  String getVehicleImage(ActiveVehicleModel vehicle, int listIndex) {
    final typeStr = vehicle.type.toLowerCase();
    final int index = (listIndex % 3) + 1;

    switch (typeStr) {
      case 'truck':
        return 'assets/images/vehicletype/truck$index.png';
      case 'bike':
      case 'motorcycle':
        return 'assets/images/vehicletype/bike$index.png';
      case 'car':
      default:
        return 'assets/images/vehicletype/car$index.png';
    }
  }

  @override
  void onClose() {
    homeMapController?.dispose();
    homeScrollController.dispose();
    tripsScrollController.dispose();
    profileScrollController.dispose();
    super.onClose();
  }
}
