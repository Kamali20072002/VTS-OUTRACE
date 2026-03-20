import 'package:get/get.dart';

class HomeController extends GetxController {
  final RxInt currentIndex = 0.obs;

  // Static vehicle data — backend will replace later
  final RxList vehicles = [
    {
      'name': 'Honda City',
      'reg': 'KA 01 AB 2345',
      'type': 'Car',
      'status': 'online',
      'location': 'MG Road, Bengaluru',
      'lastSeen': '1 min ago',
      'speed': '42',
      'distance': '24.3',
    },
    {
      'name': 'Toyota Innova',
      'reg': 'KA 05 CD 7890',
      'type': 'SUV',
      'status': 'offline',
      'location': 'Koramangala, Bengaluru',
      'lastSeen': '3 hrs ago',
      'speed': '0',
      'distance': '0',
    },
    {
      'name': 'Tata Ace',
      'reg': 'KA 02 EF 4567',
      'type': 'Truck',
      'status': 'online',
      'location': 'Whitefield, Bengaluru',
      'lastSeen': 'Just now',
      'speed': '28',
      'distance': '12.1',
    },
  ].obs;

  // Stats
  int get totalVehicles => vehicles.length;
  int get onlineVehicles =>
      vehicles.where((v) => v['status'] == 'online').length;
  int get offlineVehicles =>
      vehicles.where((v) => v['status'] == 'offline').length;

  void changeTab(int index) {
    currentIndex.value = index;
  }
}