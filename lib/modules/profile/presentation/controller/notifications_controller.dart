import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../domain/models/notification_model.dart';
import '../../domain/repositories/profile_repository.dart';

class NotificationsController extends GetxController {
  final ProfileRepository _repo = ProfileRepository();

  final RxList<NotificationModel> notifications = <NotificationModel>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    isLoading.value = true;
    try {
      final list = await _repo.getMyAlerts();
      notifications.value = list;
    } catch (e) {
      debugPrint('Notifications Error: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
