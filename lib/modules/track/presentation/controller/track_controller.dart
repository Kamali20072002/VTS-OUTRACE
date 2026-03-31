import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:notix_pro/notix_pro.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../core/services/socket_service.dart';
import '../../../../core/utils/token_storage.dart';
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
  final RxString statusFilter = 'ALL'.obs; // ALL, ONLINE, OFFLINE
  final RxBool isLoading = false.obs;
  final RxBool showSearchDropdown = false.obs;
  final RxBool isSocketConnected = false.obs;

  // ── User Location & Geofencing ───────────────────
  final Rx<LatLng?> userLocation = Rx<LatLng?>(null);
  final RxDouble geofenceRadius = 0.0.obs;
  Timer? _bloomTimer;
  bool _expanding = true;

  void toggleMapType() {
    mapType.value = mapType.value == MapType.normal ? MapType.satellite : MapType.normal;
  }

  void setStatusFilter(String filter) {
    statusFilter.value = filter;
    selectedIndex.value = 0; // Reset selection to the first in the filtered list
    _updateMarkers();
    if (filteredVehicles.isNotEmpty) {
      fitAllMarkers();
    }
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
    stopGeofenceAnimation();
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
    final context = Get.context;
    if (context == null) return;

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        NotixDialog.show(
          context,
          type: NotixType.warning,
          theme: NotixTheme(
            animationStyle: NotixAnimationStyle.flip,
          ),
          title: 'Location Disabled',
          message: 'Please enable location services to find your position.',
          confirmText: 'Settings',
          cancelText: 'Cancel',
          onConfirm: () => Geolocator.openLocationSettings(),
        );
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          NotixDialog.show(
            context,
            type: NotixType.error,
            theme: NotixTheme(
              animationStyle: NotixAnimationStyle.flip,
            ),
            title: 'Permission Denied',
            message: 'Location permission is required to find your position.',
            confirmText: 'Retry',
            cancelText: 'Cancel',
            onConfirm: () => getUserLocation(),
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        NotixDialog.show(
          context,
          type: NotixType.error,
          theme: NotixTheme(
            animationStyle: NotixAnimationStyle.flip,
          ),
          title: 'Permission Blocked',
          message: 'Location permissions are permanently denied. Please enable them in settings.',
          confirmText: 'Open Settings',
          cancelText: 'Cancel',
          onConfirm: () => Geolocator.openAppSettings(),
        );
        return;
      }

      // Try last known first for immediate response
      Position? lastKnown = await Geolocator.getLastKnownPosition();
      if (lastKnown != null) {
        userLocation.value = LatLng(lastKnown.latitude, lastKnown.longitude);
        await updateUserLocationMarker(userLocation.value!, lastKnown.heading);
        mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(userLocation.value!, 18),
        );
        _startGeofenceAnimation();
      }

      // Get current position (might take a few seconds)
      Position position = await Geolocator.getCurrentPosition(
        // ignore: deprecated_member_use
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 5),
      ).catchError((e) async {
        // If timeout or other error, fallback to last known if we don't have it yet
        if (userLocation.value == null) {
          throw e;
        }
        return lastKnown!; // Already handled
      });

      userLocation.value = LatLng(position.latitude, position.longitude);
      
      // Update user location marker with heading if available
      await updateUserLocationMarker(userLocation.value!, position.heading);

      // Animate map to user location (zooming in)
      mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(userLocation.value!, 18),
      );

      _startGeofenceAnimation();
    } catch (e) {
      debugPrint('Error getting user location: $e');
      if (userLocation.value == null) {
        NotixToast.show(
          context,
          type: NotixType.error,
          title: 'Location Error',
          message: 'Could not retrieve your current location. Please try again.',
          position: NotixToastPosition.top,
        );
      }
    }
  }

  // Call after getUserLocation() resolves
  Future<void> updateUserLocationMarker(LatLng pos, double heading) async {
    userLocation.value = pos;
    final icon = await MapMarkerHelper.createUserLocationMarker(heading: heading);
    final m = Marker(
      markerId: const MarkerId('user_location'),
      position: pos,
      icon: icon,
      anchor: const Offset(0.5, 0.5),
      zIndex: 99,
    );
    
    // RxSet doesn't support indexWhere or []=
    // We remove the old one by ID and add the updated one
    markers.removeWhere((x) => x.markerId.value == 'user_location');
    markers.add(m);
  }

  void stopGeofenceAnimation() {
    _bloomTimer?.cancel();
    _bloomTimer = null;
    geofenceRadius.value = 0.0;
  }

  void stopGeofencing() {
    stopGeofenceAnimation();
    userLocation.value = null;
    // Also remove the user location marker
    markers.removeWhere((m) => m.markerId.value == 'user_location');
  }

  void zoomIn() {
    if (userLocation.value != null) {
      mapController?.animateCamera(CameraUpdate.newLatLngZoom(userLocation.value!, currentZoom.value + 1));
    } else {
      mapController?.animateCamera(CameraUpdate.zoomIn());
    }
  }

  void zoomOut() {
    if (userLocation.value != null) {
      mapController?.animateCamera(CameraUpdate.newLatLngZoom(userLocation.value!, currentZoom.value - 1));
    } else {
      mapController?.animateCamera(CameraUpdate.zoomOut());
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
    var list = vehicles.toList();
    
    // Status filter
    if (statusFilter.value == 'ONLINE') {
      list = list.where((v) => v.isOnline).toList();
    } else if (statusFilter.value == 'OFFLINE') {
      list = list.where((v) => !v.isOnline).toList();
    }

    // Search query filter
    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      list = list.where((v) {
        return v.model.toLowerCase().contains(query) ||
            v.registrationNumber.toLowerCase().contains(query);
      }).toList();
    }
    
    return list;
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
    _initSocket();
  }

  Future<void> _initSocket() async {
    final token = await TokenStorage.getAccessToken();
    if (token != null) {
      SocketService.connect(token);
      
      // Update local connection status
      isSocketConnected.value = SocketService.socket?.connected ?? false;
      
      SocketService.socket?.on('connect', (_) {
        isSocketConnected.value = true;
      });

      SocketService.socket?.on('disconnect', (_) {
        isSocketConnected.value = false;
      });

      SocketService.listenForFleet((data) {
        if (data != null) {
          // ignore: avoid_print
          print('🛰️ Incoming Frame: $data');
          final vehicleUpdate = ActiveVehicleModel.fromJson(data);
          _updateFromVehicle(vehicleUpdate);
        }
      });
      
      // If we already have a selected vehicle, start following it
      if (vehicles.isNotEmpty && selectedIndex.value != -1) {
        final v = vehicles[selectedIndex.value];
        SocketService.followDevice(v.deviceId);
      }
    }
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

  void fitAllMarkers({double padding = 150.0}) {
    if (mapController == null) return;
    
    final list = filteredVehicles;
    if (list.isEmpty) {
      markers.clear();
      return;
    }
    
    // Filter vehicles with valid positions
    final validVehicles = list.where((v) => v.latitude != null && v.longitude != null).toList();
    if (validVehicles.isEmpty) return;
    
    LatLngBounds bounds;

    if (validVehicles.length == 1) {
      final v = validVehicles.first;
      final pos = LatLng(v.latitude!, v.longitude!);
      bounds = LatLngBounds(southwest: pos, northeast: pos);
      mapController?.animateCamera(CameraUpdate.newLatLngZoom(pos, 15));
      return;
    } else {
      double minLat = validVehicles.first.latitude!;
      double maxLat = validVehicles.first.latitude!;
      double minLng = validVehicles.first.longitude!;
      double maxLng = validVehicles.first.longitude!;
      
      for (var v in validVehicles) {
        if (v.latitude! < minLat) minLat = v.latitude!;
        if (v.latitude! > maxLat) maxLat = v.latitude!;
        if (v.longitude! < minLng) minLng = v.longitude!;
        if (v.longitude! > maxLng) maxLng = v.longitude!;
      }
      bounds = LatLngBounds(
        southwest: LatLng(minLat, minLng),
        northeast: LatLng(maxLat, maxLng),
      );
    }
    
    mapController?.animateCamera(CameraUpdate.newLatLngBounds(bounds, padding));
  }

  void selectVehicle(int index, {bool animate = true, bool scrollPage = true}) {
    final list = filteredVehicles;
    if (index < 0 || index >= list.length) return;
    
    final v = list[index];
    
    // Update local reactive stats
    speed.value = v.speed?.toStringAsFixed(0) ?? '0';
    distance.value = '10.8';
    temperature.value = '28';
    isEngineOn.value = v.isOnline;
    selectedIndex.value = vehicles.indexWhere((element) => element.deviceId == v.deviceId);

    // Keep all markers in view but with the selected one centered
    // This provides the "see both" behavior requested
    fitAllMarkers(padding: 150.0);
    
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
    
    // Start following the selected device via socket for live updates
    SocketService.followDevice(v.deviceId);
    
    fetchLatestGps(v.deviceId);
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
    }

    _updateMarkers();
    
    // Automatically adjust view to include all vehicles including the newly updated one
    // Use a slightly larger padding for live updates to avoid constant micro-zooming
    fitAllMarkers(padding: 180.0);
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
      if (markers.length >= 1) {
        fitAllMarkers();
      }
    }
  }

  Future<void> _updateMarkers() async {
    final list = filteredVehicles;
    if (list.isEmpty) {
      markers.clear();
      return;
    }
    
    // Create markers in parallel for better performance
    final results = await Future.wait(list.asMap().entries.map((entry) async {
      final i = entry.key;
      final v = entry.value;
      // We check if this vehicle is the one currently selected in the FULL vehicles list
      final isSelected = selectedIndex.value != -1 && vehicles[selectedIndex.value].deviceId == v.deviceId;
      
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

    // Re-add the user location marker if we have userLocation
    if (userLocation.value != null) {
      // Re-create it with current heading or 0
      final icon = await MapMarkerHelper.createUserLocationMarker(heading: 0);
      newMarkers.add(Marker(
        markerId: const MarkerId('user_location'),
        position: userLocation.value!,
        icon: icon,
        anchor: const Offset(0.5, 0.5),
        zIndex: 99,
      ));
    }
    
    markers.assignAll(newMarkers);
  }

  void toggleEngine() {
    isEngineOn.value = !isEngineOn.value;
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
    SocketService.disconnect();
    _bloomTimer?.cancel();
    super.onClose();
  }
}