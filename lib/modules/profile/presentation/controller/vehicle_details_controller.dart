import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../domain/models/profile_model.dart';
import '../../domain/repositories/profile_repository.dart';

class VehicleDetailsController extends GetxController {
  final ProfileRepository _repo = ProfileRepository();
  final String vehicleId;

  final Rx<VehicleModel?> vehicle = Rx<VehicleModel?>(null);
  final RxBool isLoading = true.obs;

  VehicleDetailsController({required this.vehicleId});

  @override
  void onInit() {
    super.onInit();
    fetchVehicleDetails();
  }

  Future<void> fetchVehicleDetails() async {
    isLoading.value = true;
    try {
      final json = await _repo.getVehicleDetails(vehicleId);
      if (json['data'] != null) {
        vehicle.value = VehicleModel.fromJson(json['data'] as Map<String, dynamic>);
      }
    } catch (e) {
      debugPrint('Fetch Vehicle Details Error: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
