import 'package:get/get.dart';

class ProfileController extends GetxController {
  final RxString name = 'Arjun Kumar'.obs;
  final RxString phone = '+91 98765 43210'.obs;
  final RxInt vehicleCount = 3.obs;
}