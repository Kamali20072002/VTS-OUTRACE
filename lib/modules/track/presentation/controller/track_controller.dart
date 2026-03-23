import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class TrackController extends GetxController {
  GoogleMapController? mapController;

  final RxString selectedVehicle = 'Honda City'.obs;
  final RxString selectedReg = 'KA 01 AB 2345'.obs;
  final RxBool isEngineOn = true.obs;
  final RxString speed = '42'.obs;
  final RxString distance = '10.8'.obs;
  final RxString temperature = '28'.obs;

  // Bengaluru - MG Road coordinates
  final LatLng initialPosition = const LatLng(12.9716, 77.5946);

  final RxSet<Marker> markers = <Marker>{}.obs;
  final RxSet<Polyline> polylines = <Polyline>{}.obs;

  @override
  void onInit() {
    super.onInit();
    _addMarkers();
    _addRoute();
  }

  void onMapCreated(GoogleMapController controller) {
    mapController = controller;
    // Apply dark style to match app theme
    // ignore: deprecated_member_use
    mapController?.setMapStyle(_mapStyle);
  }

  void _addMarkers() {
    markers.add(
      Marker(
        markerId: const MarkerId('vehicle_1'),
        position: const LatLng(12.9716, 77.5946),
        infoWindow: InfoWindow(
          title: selectedVehicle.value,
          snippet: selectedReg.value,
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueViolet,
        ),
      ),
    );
  }

  void _addRoute() {
    polylines.add(
      const Polyline(
        polylineId: PolylineId('route_1'),
        color: Color(0xFF6C5CE7),
        width: 4,
        points: [
          LatLng(12.9616, 77.5846),
          LatLng(12.9650, 77.5880),
          LatLng(12.9680, 77.5910),
          LatLng(12.9716, 77.5946),
        ],
      ),
    );
  }

  void toggleEngine() {
    isEngineOn.value = !isEngineOn.value;
  }

  void centerOnVehicle() {
    mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(initialPosition, 15),
    );
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
    mapController?.dispose();
    super.onClose();
  }
}