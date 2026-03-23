import 'package:get/get.dart';

class TripsController extends GetxController {
  final RxString selectedFilter = 'Day'.obs;
  final RxList trips = [
    {
      'time': '08:08 PM - 10:47 PM',
      'route': 'TA. Ngantru to TA.Karangrejo',
      'distance': '10.8 km',
      'speed': 'AVG 100 km/h',
    },
    {
      'time': '8:15 AM - 10:58 AM',
      'route': 'TA. Ngunut to TA.Ngantru',
      'distance': '8.5 km',
      'speed': 'AVG 84 km/h',
    },
    {
      'time': '7:30 AM - 7:44 AM',
      'route': 'TA. Ngantru to TA.Ngunut',
      'distance': '3.8 km',
      'speed': 'AVG 58 km/h',
    },
    {
      'time': '7:08 AM - 7:05 AM',
      'route': 'TA. Ngunut to TA.Ngantru',
      'distance': '2.1 km',
      'speed': 'AVG 42 km/h',
    },
  ].obs;

  void setFilter(String filter) => selectedFilter.value = filter;
}