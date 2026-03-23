import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomeController extends GetxController {
  final RxInt currentIndex = 0.obs;

  // ── Map ─────────────────────────────────────
  GoogleMapController? homeMapController;
  final LatLng mapCenter = const LatLng(12.9716, 77.5946);

  Set<Marker> homeMarkers = {};
  Set<Polyline> homePolylines = {};

  @override
  void onInit() {
    super.onInit();
    _setupMapData();
  }

  void _setupMapData() {
    homeMarkers = {
      Marker(
        markerId: const MarkerId('vehicle_1'),
        position: const LatLng(12.9716, 77.5946),
        infoWindow: const InfoWindow(
          title: 'Honda City',
          snippet: 'Moving',
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueViolet,
        ),
      ),
      Marker(
        markerId: const MarkerId('vehicle_2'),
        position: const LatLng(12.9750, 77.5980),
        infoWindow: const InfoWindow(
          title: 'Toyota Innova',
          snippet: 'Parking',
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueViolet,
        ),
      ),
      Marker(
        markerId: const MarkerId('vehicle_3'),
        position: const LatLng(12.9680, 77.5910),
        infoWindow: const InfoWindow(
          title: 'BMW Z4',
          snippet: 'Parking',
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueViolet,
        ),
      ),
    };

    homePolylines = {
      const Polyline(
        polylineId: PolylineId('home_route'),
        color: Color(0xFF6C5CE7),
        width: 4,
        points: [
          LatLng(12.9680, 77.5910),
          LatLng(12.9700, 77.5930),
          LatLng(12.9716, 77.5946),
          LatLng(12.9750, 77.5980),
        ],
      ),
    };
  }

  void onHomeMapCreated(GoogleMapController controller) {
    homeMapController = controller;
    // ignore: deprecated_member_use
    homeMapController?.setMapStyle(_mapStyle);
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

  // ── Vehicles ─────────────────────────────────
  final RxList vehicles = [
    {
      'name': 'Honda City',
      'reg': 'KA 01 AB 2345',
      'type': 'Car',
      'status': 'online',
      'statusLabel': 'Moving',
      'location': 'MG Road, Bengaluru',
      'lastSeen': '1 min ago',
      'speed': '42',
      'distance': '24.3',
      'image': 'assets/images/bmw_x6.jpg',
      'battery': 4,
    },
    {
      'name': 'Toyota Innova',
      'reg': 'KA 05 CD 7890',
      'type': 'SUV',
      'status': 'offline',
      'statusLabel': 'Parking',
      'location': 'Koramangala, Bengaluru',
      'lastSeen': '3 hrs ago',
      'speed': '0',
      'distance': '0',
      'image': 'assets/images/toyota_innova.jpg',
      'battery': 2,
    },
    {
      'name': 'BMW Z4',
      'reg': 'KA 02 EF 4567',
      'type': 'Car',
      'status': 'online',
      'statusLabel': 'Parking',
      'location': 'Whitefield, Bengaluru',
      'lastSeen': 'Just now',
      'speed': '0',
      'distance': '12.1',
      'image': 'assets/images/bmw_z4.jpg',
      'battery': 3,
    },
  ].obs;

  int get totalVehicles => vehicles.length;
  int get onlineVehicles =>
      vehicles.where((v) => v['status'] == 'online').length;
  int get offlineVehicles =>
      vehicles.where((v) => v['status'] == 'offline').length;

  void changeTab(int index) => currentIndex.value = index;

  @override
  void onClose() {
    homeMapController?.dispose();
    super.onClose();
  }
}