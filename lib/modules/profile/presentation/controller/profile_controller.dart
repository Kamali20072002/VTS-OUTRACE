// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notix_pro/notix_pro.dart';
import 'package:outrace/modules/home/presentation/controller/home_controller.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/exceptions/app_exception.dart';
import '../../../../core/utils/token_storage.dart';
import '../../../../core/utils/cache_service.dart';
import '../../domain/models/profile_model.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../../login/presentation/pages/login_screen.dart';

class ProfileController extends GetxController {
  final ProfileRepository _repo = ProfileRepository();

  // ── Profile data ───────────────────────────
  final RxString name   = 'User'.obs;
  final RxString email  = ''.obs;
  final RxString phone  = ''.obs;
  final RxString userId = ''.obs;

  // ── Stats ──────────────────────────────────
  final RxInt    vehicleCount       = 0.obs;
  final RxInt    totalTrips         = 0.obs;
  final RxString totalKm            = '0.0'.obs;
  final RxInt    notificationCount  = 0.obs;

  // ── Vehicles ───────────────────────────────
  final RxList<VehicleModel> vehicles = <VehicleModel>[].obs;

  // ── Loading states ─────────────────────────
  final RxBool isLoading          = false.obs;
  final RxBool isUpdating         = false.obs;
  final RxBool isChangingPass     = false.obs;
  final RxBool isLoadingDevices   = false.obs;

  // ── Validation states ──────────────────────
  final RxBool isProfileChanged    = false.obs;
  final RxString profileError      = ''.obs;
  final RxBool isPasswordChanged   = false.obs;
  final RxString passwordError     = ''.obs;
  final RxBool isPasswordFormValid = false.obs;

  // ── Edit profile controllers ───────────────
  final TextEditingController nameEditCtrl  = TextEditingController();
  final TextEditingController phoneEditCtrl = TextEditingController();

  // ── Password controllers ───────────────────
  final TextEditingController oldPassCtrl  = TextEditingController();
  final TextEditingController newPassCtrl  = TextEditingController();
  final TextEditingController confPassCtrl = TextEditingController();
  final RxBool showOldPass  = false.obs;
  final RxBool showNewPass  = false.obs;
  final RxBool showConfPass = false.obs;

  @override
  void onInit() {
    super.onInit();
    refreshProfile();

    // Listeners for change detection and validation
    nameEditCtrl.addListener(_validateProfile);
    phoneEditCtrl.addListener(_validateProfile);
    
    oldPassCtrl.addListener(_validatePassword);
    newPassCtrl.addListener(_validatePassword);
    confPassCtrl.addListener(_validatePassword);
  }

  void _validateProfile() {
    final n = nameEditCtrl.text.trim();
    final p = phoneEditCtrl.text.trim();

    // Change detection
    isProfileChanged.value = n != name.value || p != phone.value;

    // Validation
    if (n.isEmpty) {
      profileError.value = 'Name cannot be empty';
    } else if (n.length > 20) {
      profileError.value = 'Name must be max 20 characters';
    } else if (p.isNotEmpty) {
      if (p.length != 10) {
        profileError.value = 'Phone number must be 10 digits';
      } else if (RegExp(r'^[0]+$').hasMatch(p)) {
        profileError.value = 'Invalid phone number';
      } else {
        profileError.value = '';
      }
    } else {
      profileError.value = '';
    }
  }

  bool _isValidPassword(String password) {
    // Min 6 max 15, at least one upper, one lower, one number and one special char
    return RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{6,15}$')
        .hasMatch(password);
  }

  void _validatePassword() {
    final old = oldPassCtrl.text;
    final n = newPassCtrl.text;
    final c = confPassCtrl.text;

    isPasswordChanged.value = old.isNotEmpty || n.isNotEmpty || c.isNotEmpty;

    if (old.isEmpty && (n.isNotEmpty || c.isNotEmpty)) {
      passwordError.value = 'Current password is required';
    } else if (n.isNotEmpty && !_isValidPassword(n)) {
      passwordError.value = 'Password must be 6-15 chars with Upper, Lower, Number & Special char';
    } else if (n.isNotEmpty && old.isNotEmpty && n == old) {
      passwordError.value = 'New password cannot be same as current password';
    } else if (n.isNotEmpty && c.isNotEmpty && n != c) {
      passwordError.value = 'Passwords do not match';
    } else if (n.isNotEmpty && c.isEmpty) {
      passwordError.value = 'Please confirm your new password';
    } else {
      passwordError.value = '';
    }

    isPasswordFormValid.value = old.isNotEmpty && n.isNotEmpty && c.isNotEmpty && passwordError.value.isEmpty;
  }

  @override
  void onClose() {
    nameEditCtrl.removeListener(_validateProfile);
    phoneEditCtrl.removeListener(_validateProfile);
    oldPassCtrl.removeListener(_validatePassword);
    newPassCtrl.removeListener(_validatePassword);
    confPassCtrl.removeListener(_validatePassword);
    
    super.onClose();
  }

  void resetProfileEdit() {
    nameEditCtrl.text = name.value;
    phoneEditCtrl.text = phone.value;
    profileError.value = '';
    isProfileChanged.value = false;
  }

  void resetPasswordEdit() {
    oldPassCtrl.clear();
    newPassCtrl.clear();
    confPassCtrl.clear();
    passwordError.value = '';
    isPasswordChanged.value = false;
    isPasswordFormValid.value = false;
  }

  // ── Load profile ───────────────────────────
  Future<void> refreshProfile({bool forceRefresh = false}) async {
    if (email.isEmpty) {
      isLoading.value = true;
    }
    try {
      final json = await _repo.getProfile(forceRefresh: forceRefresh);
      final data = json['data'] as Map<String, dynamic>?;
      if (data != null) {
        final user  = ProfileModel.fromJson(
            data['user'] as Map<String, dynamic>? ?? {});
        final stats = ProfileStatsModel.fromJson(
            data['stats'] as Map<String, dynamic>? ?? {});

        name.value             = user.name;
        email.value            = user.email;
        phone.value            = user.phoneNumber?.toString() ?? '';
        userId.value           = user.userId;
        vehicleCount.value     = stats.totalVehicles;
        totalTrips.value       = stats.totalTrips;
        totalKm.value          = stats.totalKm;
        notificationCount.value = stats.notificationCount;

        // Fetch actual alerts to sync count if needed
        try {
          final alerts = await _repo.getMyAlerts(forceRefresh: forceRefresh);
          notificationCount.value = alerts.length;
        } catch (e) {
          debugPrint('Alerts sync error: $e');
        }

        await TokenStorage.saveUser(
          userId: user.userId,
          name: user.name,
          email: user.email,
        );

        nameEditCtrl.text  = user.name;
        phoneEditCtrl.text = user.phoneNumber?.toString() ?? '';
      }
    } on HttpException catch (e) {
      debugPrint('Profile Error: ${e.message}');
      if (Get.context != null) {
        _showError(Get.context!, e.message);
      }
      await _loadFromLocal();
    } catch (e) {
      debugPrint('Profile Error: $e');
      if (Get.context != null) {
        _showError(Get.context!, 'Failed to load profile');
      }
      await _loadFromLocal();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadFromLocal() async {
    final savedName  = await TokenStorage.getUserName();
    final savedEmail = await TokenStorage.getUserEmail();
    if (savedName  != null) name.value  = savedName;
    if (savedEmail != null) email.value = savedEmail;
  }

  // ── Update profile ─────────────────────────
  Future<void> updateProfile(BuildContext context) async {
    final newName  = nameEditCtrl.text.trim();
    final newPhone = phoneEditCtrl.text.trim();

    if (newName.isEmpty) {
      _showError(context, 'Name cannot be empty');
      return;
    }

    if (newPhone.isNotEmpty) {
      if (newPhone.length != 10) {
        _showError(context, 'Phone number must be 10 digits');
        return;
      }
      if (RegExp(r'^[0]+$').hasMatch(newPhone)) {
        _showError(context, 'Invalid phone number');
        return;
      }
    }

    isUpdating.value = true;
    try {
      final json = await _repo.updateProfile(
        name: newName,
        phoneNumber: newPhone,
      );

      if (json['error'] == true) {
        _showError(context,
            json['message'] as String? ?? 'Update failed');
        return;
      }

      name.value  = newName;
      phone.value = newPhone;

      await TokenStorage.saveUser(
        userId: userId.value,
        name: newName,
        email: email.value,
      );

      _showSuccess(context, 'Updated!', 'Profile updated successfully');
      Get.back();
    } on HttpException catch (e) {
      _showError(context, e.message);
    } catch (e) {
      _showError(context, 'Something went wrong. Please try again.');
    } finally {
      isUpdating.value = false;
    }
  }

  // ── Change password ────────────────────────
  Future<void> changePassword(BuildContext context) async {
    final oldPass  = oldPassCtrl.text.trim();
    final newPass  = newPassCtrl.text.trim();
    final confPass = confPassCtrl.text.trim();

    if (oldPass.isEmpty) {
      _showError(context, 'Please enter your current password');
      return;
    }
    if (!_isValidPassword(newPass)) {
      _showError(context, 'Password must be 6-15 chars with Upper, Lower, Number & Special char');
      return;
    }
    if (newPass == oldPass) {
      _showError(context, 'New password cannot be same as current password');
      return;
    }
    if (newPass != confPass) {
      _showError(context, 'Passwords do not match');
      return;
    }

    isChangingPass.value = true;
    try {
      final json = await _repo.changePassword(
        oldPassword: oldPass,
        newPassword: newPass,
      );

      if (json['error'] == true) {
        _showError(context,
            json['message'] as String? ?? 'Password change failed');
        return;
      }

      oldPassCtrl.clear();
      newPassCtrl.clear();
      confPassCtrl.clear();

      _showSuccess(context, 'Success!', 'Password changed successfully');
      Get.back();
    } on HttpException catch (e) {
      _showError(context, e.message);
    } catch (e) {
      _showError(context, 'Something went wrong. Please try again.');
    } finally {
      isChangingPass.value = false;
    }
  }

  // ── Logout ─────────────────────────────────
  Future<void> logout(BuildContext context) async {
    NotixDialog.show(
      context,
      type: NotixType.warning,
      theme: NotixTheme(
        animationStyle: NotixAnimationStyle.flip,
      ),
      title: 'Logout',
      message: 'Are you sure you want to logout?',
      confirmText: 'Logout',
      cancelText: 'Cancel',
      onCancel: () {},
      onConfirm: () async {
        await CacheService.clearAll();
        await TokenStorage.clearAll();
        
        Get.offAll(
          () => const LoginScreen(),
          transition: Transition.fadeIn,
          duration: const Duration(milliseconds: 500),
        );
      },
    );
  }

  // ── Helpers ────────────────────────────────
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

  // ── Support Helpers ────────────────────────
  Future<void> launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    try {
      if (urlString.startsWith('tel:') || urlString.startsWith('mailto:')) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch $urlString';
      }
    } catch (e) {
      debugPrint('Launch Error: $e');
      Get.snackbar(
        'Launch Error',
        'Could not open the link. Please ensure a supporting app is installed.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
    }
  }

  Future<void> generateUserGuide() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        header: (context) => pw.Column(
          children: [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Outrace VTS Documentation',
                    style: pw.TextStyle(color: PdfColors.grey700, fontSize: 10)),
                pw.Text('Page ${context.pageNumber} of ${context.pagesCount}',
                    style: pw.TextStyle(color: PdfColors.grey700, fontSize: 10)),
              ],
            ),
            pw.Divider(thickness: 0.5),
            pw.SizedBox(height: 10),
          ],
        ),
        footer: (context) => pw.Column(
          children: [
            pw.SizedBox(height: 10),
            pw.Divider(thickness: 0.5),
            pw.Center(
              child: pw.Text('Copyright © 2026 Outrace. All rights reserved.',
                  style: pw.TextStyle(color: PdfColors.grey600, fontSize: 9)),
            ),
          ],
        ),
        build: (pw.Context context) {
          return [
            pw.Center(
              child: pw.Text('USER GUIDE & MANUAL',
                  style: pw.TextStyle(
                      fontSize: 28, fontWeight: pw.FontWeight.bold)),
            ),
            pw.SizedBox(height: 30),
            
            pw.Text('1. Welcome to Outrace',
                style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
            pw.SizedBox(height: 10),
            pw.Text(
                'Outrace Vehicle Tracking System (VTS) provides state-of-the-art fleet management solutions. Our platform allows you to monitor your vehicles in real-time, analyze journey history, and receive critical security alerts.'),
            pw.SizedBox(height: 20),

            pw.Text('2. Getting Started',
                style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
            pw.SizedBox(height: 10),
            pw.Text('Step 1: Account Creation', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.Paragraph(text: 'Download the app and create your account using your email address. Ensure you verify your email to unlock all tracking features.'),
            pw.SizedBox(height: 5),
            pw.Text('Step 2: Device Activation', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.Paragraph(text: 'Navigate to "My Devices" and click on "Activate Device". Enter the 15-digit IMEI number found on your Outrace GPS hardware unit.'),
            pw.SizedBox(height: 5),
            pw.Text('Step 3: Vehicle Registration', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.Paragraph(text: 'Once a device is activated, you can link it to a vehicle by providing the registration number, make, and model.'),
            pw.SizedBox(height: 20),

            pw.Text('3. Dashboard Navigation',
                style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
            pw.SizedBox(height: 10),
            pw.Bullet(text: 'Live Map: View current positions of all active vehicles.'),
            pw.Bullet(text: 'Search: Quickly find vehicles by registration number.'),
            pw.Bullet(text: 'Filters: Filter your fleet by vehicle type (Car, Bike, Truck).'),
            pw.Bullet(text: 'Status Cards: Monitor GPS signal strength and server connectivity status.'),
            pw.SizedBox(height: 20),

            pw.Text('4. Real-time Tracking Features',
                style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
            pw.SizedBox(height: 10),
            pw.Text('Our tracking system updates every 5-10 seconds to provide the most accurate location data available. You can view:'),
            pw.Bullet(text: 'Current Speed & Heading direction.'),
            pw.Bullet(text: 'Ignition Status (On/Off).'),
            pw.Bullet(text: 'Last updated timestamp.'),
            pw.Bullet(text: 'Nearby landmarks and full address details.'),
            
            pw.NewPage(), // Force start of second page

            pw.Text('5. Trip History & Analytics',
                style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
            pw.SizedBox(height: 10),
            pw.Text('The Trips section archives every journey taken by your fleet. Each trip record includes:'),
            pw.Bullet(text: 'Start and End locations with timestamps.'),
            pw.Bullet(text: 'Total distance traveled in kilometers.'),
            pw.Bullet(text: 'Total driving time.'),
            pw.Bullet(text: 'Average and maximum speed attained.'),
            pw.Paragraph(text: 'You can generate and share PDF reports of these journeys for expense claims or maintenance scheduling.'),
            pw.SizedBox(height: 20),

            pw.Text('6. Security & Alerts',
                style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
            pw.SizedBox(height: 10),
            pw.Text('Configure custom alerts to stay informed about your vehicle\'s safety:'),
            pw.Bullet(text: 'Overspeeding: Get notified when a vehicle exceeds a set speed limit.'),
            pw.Bullet(text: 'Geofencing: Create virtual boundaries and receive alerts when a vehicle enters or exits the area.'),
            pw.Bullet(text: 'Tamper Alerts: Receive immediate notification if the GPS device is disconnected.'),
            pw.SizedBox(height: 20),

            pw.Text('7. Frequently Asked Questions',
                style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
            pw.SizedBox(height: 10),
            pw.Text('Q: What happens if the vehicle goes into a basement or tunnel?',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.Text('A: The device will store data in its internal memory and upload it once it reconnects to the cellular network.'),
            pw.SizedBox(height: 10),
            pw.Text('Q: How many vehicles can I track on one account?',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.Text('A: There is no limit to the number of vehicles you can add to your enterprise account.'),
            pw.SizedBox(height: 10),
            pw.Text('Q: Is my location data shared with third parties?',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.Text('A: No, your data is strictly private and encrypted using industry-standard AES-256 protocols.'),
            pw.SizedBox(height: 30),

            pw.Container(
              padding: const pw.EdgeInsets.all(15),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey200,
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10)),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Need Technical Assistance?', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 5),
                  pw.Text('Our support team is available 24/7 to help you with hardware installation or software queries.'),
                  pw.SizedBox(height: 5),
                  pw.Text('Email: kamalivs20@gmail.com'),
                  pw.Text('Phone: +91 6381779723'),
                ],
              ),
            ),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save());
  }
}