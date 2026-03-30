import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../home/presentation/controller/home_controller.dart';
import '../../../../widgets/map_marker_helper.dart';
import '../../domain/models/active_vehicle_model.dart';
import '../../domain/repositories/track_repository.dart';

class TrackController extends GetxController {
  final TrackRepository _repo = TrackRepository();
  GoogleMapController? mapController;
  final Rx<MapType> mapType = MapType.normal.obs;
  final PageController pageController = PageController(viewportFraction: 0.94);

  final RxList<ActiveVehicleModel> vehicles = <ActiveVehicleModel>[].obs;
  final RxString searchQuery = ''.obs;
  final RxInt selectedIndex = 0.obs;
  final RxBool isLoading = false.obs;
  final RxBool showSearchDropdown = false.obs;

  // ── User Location & Geofencing ───────────────────
  final Rx<LatLng?> userLocation = Rx<LatLng?>(null);
  final RxDouble geofenceRadius = 0.0.obs;
  Timer? _bloomTimer;
  bool _expanding = true;

  void toggleMapType() {
    mapType.value = mapType.value == MapType.normal ? MapType.satellite : MapType.normal;
  }

  void shareVehicleLocation() {
    if (vehicles.isEmpty || selectedIndex.value < 0) return;
    final v = vehicles[selectedIndex.value];
    if (v.latitude != null && v.longitude != null) {
      Share.share(
        'Check out my vehicle ${v.model} (${v.registrationNumber}) location: https://www.google.com/maps/search/?api=1&query=${v.latitude},${v.longitude}',
      );
    }
  }

  Future<void> navigateToVehicle() async {
    if (vehicles.isEmpty || selectedIndex.value < 0) return;
    final v = vehicles[selectedIndex.value];
    if (v.latitude != null && v.longitude != null) {
      final url = 'google.navigation:q=${v.latitude},${v.longitude}';
      final fallbackUrl = 'https://www.google.com/maps/search/?api=1&query=${v.latitude},${v.longitude}';
      
      try {
        if (await canLaunchUrl(Uri.parse(url))) {
          await launchUrl(Uri.parse(url));
        } else {
          await launchUrl(Uri.parse(fallbackUrl), mode: LaunchMode.externalApplication);
        }
      } catch (e) {
        debugPrint('Could not launch navigation: $e');
      }
    }
  }

  Future<void> getUserLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }

      if (permission == LocationPermission.deniedForever) return;

      Position position = await Geolocator.getCurrentPosition();
      userLocation.value = LatLng(position.latitude, position.longitude);
      
      // Animate map to user location
      mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(userLocation.value!, 15),
      );

      _startGeofenceAnimation();
    } catch (e) {
      debugPrint('Error getting user location: $e');
    }
  }

  void _startGeofenceAnimation() {
    _bloomTimer?.cancel();
    geofenceRadius.value = 50.0;
    _bloomTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (_expanding) {
        geofenceRadius.value += 2.5;
        if (geofenceRadius.value >= 150) _expanding = false;
      } else {
        geofenceRadius.value -= 2.5;
        if (geofenceRadius.value <= 50) _expanding = true;
      }
    });
  }

  List<ActiveVehicleModel> get filteredVehicles {
    if (searchQuery.value.isEmpty) return vehicles;
    final query = searchQuery.value.toLowerCase();
    return vehicles.where((v) {
      return v.model.toLowerCase().contains(query) ||
          v.registrationNumber.toLowerCase().contains(query);
    }).toList();
  }

  final RxBool isEngineOn = true.obs;
  final RxString speed = '0'.obs;
  final RxString distance = '0.0'.obs;
  final RxString temperature = '0'.obs;

  final RxDouble currentZoom = 14.0.obs;
  final RxSet<Marker> markers = <Marker>{}.obs;

  // MG Road coordinates as default
  LatLng initialPosition = const LatLng(12.9716, 77.5946);

  @override
  void onInit() {
    super.onInit();
    // Try to get vehicles from HomeController to show something immediately
    try {
      if (Get.isRegistered<HomeController>()) {
        final homeController = Get.find<HomeController>();
        if (homeController.vehicles.isNotEmpty) {
          // Filter to ensure unique device IDs if HomeController has duplicates
          final uniqueVehiclesList = <ActiveVehicleModel>[];
          final uniqueDeviceIds = <String>{};
          for (var v in homeController.vehicles) {
            if (!uniqueDeviceIds.contains(v.deviceId)) {
              uniqueDeviceIds.add(v.deviceId);
              uniqueVehiclesList.add(v);
            }
          }
          
          // Sort: Has location first, then Online, then by timestamp
          uniqueVehiclesList.sort((a, b) {
            final aHasLoc = a.latitude != null && a.longitude != null;
            final bHasLoc = b.latitude != null && b.longitude != null;
            if (aHasLoc && !bHasLoc) return -1;
            if (!aHasLoc && bHasLoc) return 1;
            
            if (a.isOnline && !b.isOnline) return -1;
            if (!a.isOnline && b.isOnline) return 1;
            // Then by timestamp descending (latest first)
            if (a.timestamp != null && b.timestamp != null) {
              return b.timestamp!.compareTo(a.timestamp!);
            }
            return 0;
          });
          
          vehicles.assignAll(uniqueVehiclesList);
          
          final v = vehicles[0];
          if (v.latitude != null && v.longitude != null) {
            initialPosition = LatLng(v.latitude!, v.longitude!);
          }
          // Initial selection to update markers
          selectVehicle(0, animate: false);
        }
      }
    } catch (e) {
      debugPrint('Track init from Home Error: $e');
    }
    loadVehicles();
  }

  Future<void> onCameraIdle() async {
    final z = await mapController?.getZoomLevel() ?? 14.0;
    // Refresh markers if zoom changed significantly (threshold reduced to 0.5 for better clarity)
    if ((z - currentZoom.value).abs() >= 0.5) {
      currentZoom.value = z;
      MapMarkerHelper.clearCache();
      await _updateMarkers();
    }
  }

  Future<void> loadVehicles() async {
    isLoading.value = true;
    try {
      final list = await _repo.getActiveVehicles();
      
      // Ensure uniqueness by deviceId
      final uniqueVehicles = <String, ActiveVehicleModel>{};
      for (var v in list) {
        uniqueVehicles[v.deviceId] = v;
      }
      
      final sortedList = uniqueVehicles.values.toList();
      // Sort: Has location first, then Online, then by timestamp
      sortedList.sort((a, b) {
        final aHasLoc = a.latitude != null && a.longitude != null;
        final bHasLoc = b.latitude != null && b.longitude != null;
        if (aHasLoc && !bHasLoc) return -1;
        if (!aHasLoc && bHasLoc) return 1;
        
        if (a.isOnline && !b.isOnline) return -1;
        if (!a.isOnline && b.isOnline) return 1;
        
        if (a.timestamp != null && b.timestamp != null) {
          return b.timestamp!.compareTo(a.timestamp!);
        }
        return 0;
      });
      
      vehicles.assignAll(sortedList);
      
      if (vehicles.isNotEmpty) {
        // Fetch latest GPS for ALL vehicles in parallel
        await Future.wait(vehicles.map((v) => fetchLatestGps(v.deviceId, updateUI: false)));
        
        // Final marker update for all vehicles
        await _updateMarkers();
        
        // Initial selection without adding polyline
        selectVehicle(selectedIndex.value >= vehicles.length ? 0 : selectedIndex.value, animate: false);
        
        // Fit camera to see all markers initially if there are multiple
        if (vehicles.length > 1) {
          fitAllMarkers();
        }
      }
    } catch (e) {
      debugPrint('Track Load Error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void fitAllMarkers() {
    if (markers.isEmpty || mapController == null) return;
    
    LatLngBounds bounds;
    // Filter markers with valid positions
    final validMarkers = markers.where((m) => m.position.latitude != 0 && m.position.longitude != 0).toList();
    if (validMarkers.isEmpty) return;

    if (validMarkers.length == 1) {
      final pos = validMarkers.first.position;
      bounds = LatLngBounds(southwest: pos, northeast: pos);
    } else {
      double minLat = validMarkers.first.position.latitude;
      double maxLat = validMarkers.first.position.latitude;
      double minLng = validMarkers.first.position.longitude;
      double maxLng = validMarkers.first.position.longitude;
      
      for (var m in validMarkers) {
        if (m.position.latitude < minLat) minLat = m.position.latitude;
        if (m.position.latitude > maxLat) maxLat = m.position.latitude;
        if (m.position.longitude < minLng) minLng = m.position.longitude;
        if (m.position.longitude > maxLng) maxLng = m.position.longitude;
      }
      bounds = LatLngBounds(
        southwest: LatLng(minLat, minLng),
        northeast: LatLng(maxLat, maxLng),
      );
    }
    
    mapController?.animateCamera(CameraUpdate.newLatLngBounds(bounds, 80));
  }

  void selectVehicle(int index, {bool animate = true, bool scrollPage = true}) {
    final list = filteredVehicles;
    if (index < 0 || index >= list.length) return;
    
    final v = list[index];
    // We need to keep track of which one is selected relative to the current view
    // If we are in PageView, the 'index' passed is the index in filteredVehicles
    
    // Update local reactive stats
    speed.value = v.speed?.toStringAsFixed(0) ?? '0';
    distance.value = '10.8';
    temperature.value = '28';
    isEngineOn.value = v.isOnline;
    selectedIndex.value = vehicles.indexWhere((element) => element.deviceId == v.deviceId);

    _updateCameraFromVehicle(v, animate: animate);
    
    // We update markers but need to know which deviceId is selected
    _updateMarkers();
    
    // Scroll page if triggered from marker tap
    if (scrollPage && pageController.hasClients) {
      pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
    
    fetchLatestGps(v.deviceId);
  }

  void _updateCameraFromVehicle(ActiveVehicleModel v, {bool animate = true}) {
    if (v.latitude != null && v.longitude != null) {
      if (animate) {
        mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(LatLng(v.latitude!, v.longitude!), 19),
        );
      } else {
        mapController?.moveCamera(
          CameraUpdate.newLatLngZoom(LatLng(v.latitude!, v.longitude!), 19),
        );
      }
    }
  }

  void _updateFromVehicle(ActiveVehicleModel v) {
    // Update the vehicle in our list by merging new data with old data
    final index = vehicles.indexWhere((element) => element.deviceId == v.deviceId);
    if (index != -1) {
      final oldV = vehicles[index];
      vehicles[index] = oldV.copyWith(
        latitude: v.latitude ?? oldV.latitude,
        longitude: v.longitude ?? oldV.longitude,
        speed: v.speed ?? oldV.speed,
        course: v.course ?? oldV.course,
        status: v.status ?? oldV.status,
        batteryLevel: v.batteryLevel ?? oldV.batteryLevel,
        engineStatus: v.engineStatus ?? oldV.engineStatus,
        timestamp: v.timestamp ?? oldV.timestamp,
        // Ensure we don't overwrite model/reg if new data doesn't have it
        model: (v.model.isNotEmpty) ? v.model : oldV.model,
        registrationNumber: (v.registrationNumber.isNotEmpty) ? v.registrationNumber : oldV.registrationNumber,
      );
    }

    // If this is the selected vehicle, update stats
    if (selectedIndex.value != -1 && vehicles[selectedIndex.value].deviceId == v.deviceId) {
      speed.value = v.speed?.toStringAsFixed(0) ?? '0';
      isEngineOn.value = v.isOnline;
      _updateCamera();
      // Removed _addRoute() call
    }

    _updateMarkers();
  }

  Future<void> fetchLatestGps(String deviceId, {bool updateUI = true}) async {
    try {
      final v = await _repo.getLatestGps(deviceId);
      if (v != null) {
        if (updateUI) {
          _updateFromVehicle(v);
        } else {
          // Just update the list without triggering full UI refresh for all markers yet
          final index = vehicles.indexWhere((element) => element.deviceId == v.deviceId);
          if (index != -1) {
            final oldV = vehicles[index];
            vehicles[index] = oldV.copyWith(
              latitude: v.latitude ?? oldV.latitude,
              longitude: v.longitude ?? oldV.longitude,
              speed: v.speed ?? oldV.speed,
              course: v.course ?? oldV.course,
              status: v.status ?? oldV.status,
              batteryLevel: v.batteryLevel ?? oldV.batteryLevel,
              engineStatus: v.engineStatus ?? oldV.engineStatus,
              timestamp: v.timestamp ?? oldV.timestamp,
              model: (v.model.isNotEmpty) ? v.model : oldV.model,
              registrationNumber: (v.registrationNumber.isNotEmpty) ? v.registrationNumber : oldV.registrationNumber,
            );
          }
        }
      }
    } catch (e) {
      debugPrint('Fetch GPS Error for $deviceId: $e');
    }
  }

  void onMapCreated(GoogleMapController controller) async {
    mapController = controller;
    // ignore: deprecated_member_use
    mapController?.setMapStyle(_mapStyle);
    
    // Refresh markers with real DPR and zoom now that map is ready
    currentZoom.value = await mapController?.getZoomLevel() ?? 14.0;
    MapMarkerHelper.clearCache();
    await _updateMarkers();

    if (vehicles.isNotEmpty) {
      if (markers.length > 1) {
        fitAllMarkers();
      } else {
        _updateCamera(animate: false);
      }
    }
  }

  Future<void> _updateMarkers() async {
    if (vehicles.isEmpty) {
      markers.clear();
      return;
    }
    
    // Create markers in parallel for better performance
    final results = await Future.wait(vehicles.asMap().entries.map((entry) async {
      final i = entry.key;
      final v = entry.value;
      final isSelected = selectedIndex.value == i;
      if (v.latitude != null && v.longitude != null) {
        final icon = await MapMarkerHelper.createVehicleMarker(
          type: v.type,
          model: v.model,
          regNumber: v.registrationNumber,
          isOnline: v.isOnline,
          zoom: isSelected ? 18 : currentZoom.value,
          course: v.course ?? 0,
        );

        return Marker(
          markerId: MarkerId(v.deviceId),
          position: LatLng(v.latitude!, v.longitude!),
          icon: icon,
          zIndex: isSelected ? 100.0 : (10.0 + i),
          onTap: () => selectVehicle(i, scrollPage: true),
        );
      }
      return null;
    }));

    final Set<Marker> newMarkers = results.whereType<Marker>().toSet();
    markers.assignAll(newMarkers);
  }

  void _updateCamera({bool animate = true}) {
    if (vehicles.isEmpty) return;
    final v = vehicles[selectedIndex.value];
    if (v.latitude != null && v.longitude != null) {
      if (animate) {
        mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(LatLng(v.latitude!, v.longitude!), 19),
        );
      } else {
        mapController?.moveCamera(
          CameraUpdate.newLatLngZoom(LatLng(v.latitude!, v.longitude!), 19),
        );
      }
    }
  }

  void toggleEngine() {
    isEngineOn.value = !isEngineOn.value;
  }

  void centerOnVehicle() {
    if (vehicles.isEmpty) return;
    final v = vehicles[selectedIndex.value];
    if (v.latitude != null && v.longitude != null) {
      mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(LatLng(v.latitude!, v.longitude!), 19),
      );
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

  // Minimal light map style
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

  @override
  void onClose() {
    _bloomTimer?.cancel();
    mapController?.dispose();
    pageController.dispose();
    super.onClose();
  }
}