import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notix_pro/notix_pro.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:outrace/widgets/map_marker_helper.dart';
import '../../../../core/exceptions/app_exception.dart';
import '../../domain/models/profile_model.dart';
import '../../domain/repositories/profile_repository.dart';
import 'profile_controller.dart';

class VehiclesController extends GetxController {
  final ProfileRepository _repo = ProfileRepository();
  final ProfileController _profileController = Get.find<ProfileController>();

  // ── Map controller ─────────────────────────────────────────
  GoogleMapController? mapController;
  final RxDouble currentZoom = 14.0.obs;
  final RxString mapStyle = ''.obs;

  final String _hiddenPoiStyle = '''
  [
    {
      "featureType": "poi",
      "stylers": [ { "visibility": "off" } ]
    },
    {
      "featureType": "transit",
      "stylers": [ { "visibility": "off" } ]
    }
  ]
  ''';

  final RxList<VehicleModel> vehicles    = <VehicleModel>[].obs;
  final RxSet<Marker>        markers     = <Marker>{}.obs;
  final RxString             searchQuery = ''.obs;

  List<VehicleModel> get filteredVehicles {
    if (searchQuery.value.trim().isEmpty) return vehicles;
    final query = searchQuery.value.toLowerCase().trim();
    return vehicles.where((v) {
      return v.model.toLowerCase().contains(query) ||
          v.registrationNumber.toLowerCase().contains(query) ||
          (v.imei?.toLowerCase().contains(query) ?? false) ||
          (v.trackerId?.toLowerCase().contains(query) ?? false);
    }).toList();
  }

  final RxMap<String, String> vehicleTypes    = <String, String>{}.obs;
  final RxList<DeviceModel>   availableDevices = <DeviceModel>[].obs;

  final RxBool isLoading           = false.obs;
  final RxBool isAddingVehicle     = false.obs;
  final RxBool isLoadingDevices    = false.obs;
  final RxBool isActivatingDevice  = false.obs;

  bool _hasInitialCentered = false; // Flag to center only once at start

  // ── Add vehicle form ───────────────────────────────────────
  final TextEditingController regNoCtrl = TextEditingController();
  final TextEditingController modelCtrl = TextEditingController();
  final RxString selectedType    = 'CAR'.obs;
  final RxString selectedDeviceId = ''.obs;

  // ── Activate device form ───────────────────────────────────
  final TextEditingController imeiCtrl = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    loadVehicles();
    loadVehicleTypes();
  }

  @override
  void onClose() {
    regNoCtrl.dispose();
    modelCtrl.dispose();
    imeiCtrl.dispose();
    super.onClose();
  }

  // ── Called by GoogleMap's onMapCreated ─────────────────────
  void onMapCreated(GoogleMapController controller) {
    mapController = controller;
    // Apply initial style if any
    if (mapStyle.value.isNotEmpty) {
      mapController?.setMapStyle(mapStyle.value);
    }
    // Once map is ready, animate to first vehicle with a location
    centerToFirstVehicle(force: true);
  }

  // ── Called by GoogleMap's onCameraMove ─────────────────────
  Future<void> onCameraMove(CameraPosition position) async {
    final newZoom = position.zoom;

    // 1. Zoom-dependent POI hiding:
    // Hide icons (hotels, parks, etc.) if zoom is below 15
    if (newZoom < 15.0) {
      if (mapStyle.value != _hiddenPoiStyle) {
        mapStyle.value = _hiddenPoiStyle;
        mapController?.setMapStyle(_hiddenPoiStyle);
      }
    } else {
      if (mapStyle.value != '') {
        mapStyle.value = '';
        mapController?.setMapStyle(null);
      }
    }

    // 2. Only regenerate markers if zoom changed significantly
    if ((newZoom - currentZoom.value).abs() >= 1.0) {
      currentZoom.value = newZoom;
      MapMarkerHelper.clearCache();
      await _generateMarkers(zoom: currentZoom.value);
    }
  }

  // ── Center map on the first vehicle in the list ────────────
  void centerToFirstVehicle({bool force = false}) {
    if (mapController == null || vehicles.isEmpty) return;
    if (!force && _hasInitialCentered) return;
    
    // Use a slight delay to ensure the map is ready for animation
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mapController == null || vehicles.isEmpty) return;
      if (!force && _hasInitialCentered) return;

      // 1. Try to find the first ONLINE vehicle with coordinates
      VehicleModel? target = vehicles.firstWhereOrNull(
        (v) => v.isOnline && v.lastLatitude != null && v.lastLongitude != null,
      );

      // 2. Fallback to any vehicle with coordinates if no online ones found
      target ??= vehicles.firstWhereOrNull(
        (v) => v.lastLatitude != null && v.lastLongitude != null,
      );

      if (target == null) return;

      mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(target.lastLatitude!, target.lastLongitude!),
            zoom: 15.5,
          ),
        ),
      ).then((_) {
        _hasInitialCentered = true;
      });
    });
  }

  // ── Asset path by vehicle type (from API) ──────────────────
  /// Returns the asset path to show inside the map marker circle.
  /// Place these PNGs in  assets/images/vehicletype/
  ///   map_car.png   – white top-down car silhouette
  ///   map_truck.png – white top-down truck silhouette
  ///   map_bike.png  – white top-down bike silhouette
  String getVehicleMapAsset(String type) {
  switch (type.toLowerCase()) {
    case 'truck': return 'assets/images/vehicletype/map_truck.png';
    case 'bike':
    case 'motorcycle': return 'assets/images/vehicletype/map_bike.png';
    default: return 'assets/images/vehicletype/map_car.png';
  }
}

  /// Returns the card image (side view) shown in the vehicle list card
  String getVehicleImage(VehicleModel vehicle, int listIndex) {
  final typeStr = vehicle.type.toLowerCase();
  final int index = (listIndex % 3) + 1; // 1, 2, or 3 — never repeats same for 3 in a row
 
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

  // ── Generate markers ────────────────────────────────────────
  Future<void> _generateMarkers({double zoom = 14.0}) async {
    final Set<Marker> newMarkers = {};

    for (final v in vehicles) {
      if (v.lastLatitude != null && v.lastLongitude != null) {
        final double course = v.lastCourse?.toDouble() ?? 0.0;
        
        final BitmapDescriptor icon = await MapMarkerHelper.createVehicleMarker(
          type: v.type,
          isOnline: v.isOnline,
          zoom: zoom,
          course: course,
        );

        newMarkers.add(Marker(
          markerId: MarkerId(v.id),
          position: LatLng(v.lastLatitude!, v.lastLongitude!),
          rotation: 0.0, // Fixed: car rotates on canvas, rings stay upright
          anchor: const Offset(0.5, 0.5),
          icon: icon,
          infoWindow: InfoWindow(
            title: v.model,
            snippet: v.registrationNumber,
          ),
        ));
      }
    }

    markers.value = newMarkers;
  }

  // ── Load vehicles ───────────────────────────────────────────
  Future<void> loadVehicles() async {
    isLoading.value = true;
    try {
      final list = await _repo.getMyVehicles();
      vehicles.value = list;
      await _generateMarkers(zoom: currentZoom.value);
      // If map is already ready, animate to first vehicle
      centerToFirstVehicle();
    } catch (e) {
      debugPrint('Load Vehicles Error: $e');
      if (Get.context != null) {
        _showError(Get.context!, 'Failed to load vehicles');
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadVehicleTypes() async {
    try {
      final types = await _repo.getVehicleTypes();
      vehicleTypes.value = types;
      if (types.isNotEmpty && !types.containsKey(selectedType.value)) {
        selectedType.value = types.keys.first;
      }
    } catch (e) {
      debugPrint('Load Vehicle Types Error: $e');
      if (Get.context != null) {
        _showError(Get.context!, 'Failed to load vehicle types');
      }
    }
  }

  Future<void> loadUnassignedDevices() async {
    isLoadingDevices.value = true;
    try {
      final list = await _repo.getUnassignedDevices();
      availableDevices.value = list;
    } catch (e) {
      debugPrint('Load Unassigned Devices Error: $e');
      if (Get.context != null) {
        _showError(Get.context!, 'Failed to load devices');
      }
    } finally {
      isLoadingDevices.value = false;
    }
  }

  Future<bool> activateDevice(BuildContext context) async {
    final imei = imeiCtrl.text.trim();
    if (imei.isEmpty) {
      _showError(context, 'Please enter IMEI number');
      return false;
    }
    isActivatingDevice.value = true;
    try {
      await _repo.activateDevice(imei);
      await loadUnassignedDevices();
      imeiCtrl.clear();
      _showSuccess(context, 'Success', 'Device activated successfully');
      return true;
    } on HttpException catch (e) {
      _showError(context, e.message);
      return false;
    } catch (e) {
      _showError(context, 'Failed to activate device');
      return false;
    } finally {
      isActivatingDevice.value = false;
    }
  }

  Future<void> addVehicle(BuildContext context) async {
    final regNo = regNoCtrl.text.trim();
    final model = modelCtrl.text.trim();
    final type  = selectedType.value;
    final devId = selectedDeviceId.value;

    if (regNo.isEmpty) { _showError(context, 'Please enter registration number'); return; }
    if (model.isEmpty) { _showError(context, 'Please enter vehicle model'); return; }
    if (devId.isEmpty) { _showError(context, 'Please select a device'); return; }

    isAddingVehicle.value = true;
    try {
      final json = await _repo.addVehicle(
        registrationNumber: regNo,
        model: model,
        vehicleType: type,
        deviceId: devId,
      );

      if (json['error'] == true) {
        _showError(context, json['message'] as String? ?? 'Failed to add vehicle');
        return;
      }

      await loadVehicles();
      _profileController.vehicleCount.value = vehicles.length;

      regNoCtrl.clear();
      modelCtrl.clear();
      selectedDeviceId.value = '';

      _showSuccess(context, 'Success', 'Vehicle registered successfully');
      Get.back();
    } on HttpException catch (e) {
      _showError(context, e.message);
    } catch (e) {
      _showError(context, 'Something went wrong. Please try again.');
    } finally {
      isAddingVehicle.value = false;
    }
  }

  void _showError(BuildContext context, String message) {
    NotixToast.show(context,
        type: NotixType.error,
        title: 'Error',
        message: message,
        position: NotixToastPosition.top);
  }

  void _showSuccess(BuildContext context, String title, String message) {
    NotixToast.show(context,
        type: NotixType.success,
        title: title,
        message: message,
        position: NotixToastPosition.top);
  }
}