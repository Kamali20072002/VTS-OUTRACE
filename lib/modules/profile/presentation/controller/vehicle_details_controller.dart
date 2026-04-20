import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../domain/models/profile_model.dart';
import '../../domain/repositories/profile_repository.dart';

class VehicleDetailsController extends GetxController {
  final ProfileRepository _repo = ProfileRepository();
  final String vehicleId;
  Timer? _refreshTimer;

  final Rx<VehicleModel?> vehicle = Rx<VehicleModel?>(null);
  final RxBool isLoading = true.obs;

  VehicleDetailsController({required this.vehicleId});

  @override
  void onInit() {
    super.onInit();
    fetchVehicleDetails();
    // Refresh details every 30 seconds for live updates
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) => fetchVehicleDetails(forceRefresh: true));
  }

  @override
  void onClose() {
    _refreshTimer?.cancel();
    super.onClose();
  }

  Future<void> fetchVehicleDetails({bool forceRefresh = false}) async {
    if (vehicle.value == null) {
      isLoading.value = true;
    }
    try {
      final json = await _repo.getVehicleDetails(vehicleId, forceRefresh: forceRefresh);
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
