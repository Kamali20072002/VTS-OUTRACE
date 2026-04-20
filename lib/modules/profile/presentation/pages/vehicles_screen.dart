import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:notix_pro/notix_pro.dart';
import '../../../../theme/app_theme.dart';
import '../../../../widgets/common_widgets.dart';
import '../controller/vehicles_controller.dart';
import '../../domain/models/profile_model.dart';
import 'vehicle_details_screen.dart';

class VehiclesScreen extends StatefulWidget {
  const VehiclesScreen({super.key});

  @override
  State<VehiclesScreen> createState() => _VehiclesScreenState();
}

class _VehiclesScreenState extends State<VehiclesScreen> {
  final Completer<GoogleMapController> _mapController =
      Completer<GoogleMapController>();

  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(12.90577, 77.60588),
    zoom: 12.0,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.isRegistered<VehiclesController>()) {
        Get.find<VehiclesController>().centerToFirstVehicle(force: true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(VehiclesController());

    return Scaffold(
      backgroundColor: AppColors.bg,
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: false,
      body: RefreshIndicator(
        onRefresh: () => controller.loadVehicles(forceRefresh: true),
        color: AppColors.purple,
        displacement: MediaQuery.of(context).padding.top + 80,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: SizedBox(
                height: MediaQuery.of(context).size.height,
                child: Stack(
                  children: [
                    // Background Map
                    Positioned.fill(
                      child: Obx(
                        () => GoogleMap(
                          initialCameraPosition: _initialPosition,
                          onMapCreated: (GoogleMapController c) {
                            if (!_mapController.isCompleted) {
                              _mapController.complete(c);
                            }
                            controller.onMapCreated(c);
                          },
                          onCameraMove: (CameraPosition pos) =>
                              controller.onCameraMove(pos),
                          markers: controller.markers.toSet(),
                          style: controller.mapStyle.value.isEmpty
                              ? null
                              : controller.mapStyle.value,
                          padding: EdgeInsets.only(
                              bottom: MediaQuery.of(context).size.height * 0.55),
                          myLocationButtonEnabled: false,
                          zoomControlsEnabled: false,
                          compassEnabled: false,
                        ),
                      ),
                    ),

                    // Custom Top App Bar floating over map
                    Positioned(
                      top: MediaQuery.of(context).padding.top + 16,
                      left: 16,
                      right: 16,
                      child: Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: IconButton(
                              icon: const Icon(
                                Icons.arrow_back_ios_new_rounded,
                                color: AppColors.dark,
                                size: 20,
                              ),
                              onPressed: () => Get.back(),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 14,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.08),
                                    blurRadius: 15,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: Text(
                                'My Vehicle Locations',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.dark,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Draggable Bottom Sheet for the vehicles list
                    DraggableScrollableSheet(
                      initialChildSize: 0.55,
                      minChildSize: 0.3,
                      maxChildSize: 0.9,
                      builder: (context, scrollController) {
                        return Container(
                          decoration: const BoxDecoration(
                            color: AppColors.bg,
                            borderRadius:
                                BorderRadius.vertical(top: Radius.circular(32)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 20,
                                offset: Offset(0, -5),
                              ),
                            ],
                          ),
                          child: RefreshIndicator(
                            onRefresh: () => controller.loadVehicles(forceRefresh: true),
                            color: AppColors.purple,
                            child: CustomScrollView(
                              controller: scrollController,
                              physics: const AlwaysScrollableScrollPhysics(),
                              slivers: [
                                SliverToBoxAdapter(
                                  child: Column(
                                    children: [
                                      const SizedBox(height: 12),
                                      Container(
                                        width: 40,
                                        height: 4,
                                        decoration: BoxDecoration(
                                          color: AppColors.border,
                                          borderRadius: BorderRadius.circular(2),
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                    ],
                                  ),
                                ),
                                SliverPersistentHeader(
                                  pinned: true,
                                  delegate: _StickyHeaderDelegate(
                                    height: 66,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 8),
                                      child: GestureDetector(
                                        onTap: () {
                                          controller.searchQuery.value = '';
                                          Get.to(
                                            () => const SearchVehicleScreen(),
                                            transition: Transition.fadeIn,
                                          );
                                        },
                                        child: Container(
                                          height: 50,
                                          padding:
                                              const EdgeInsets.symmetric(horizontal: 16),
                                          decoration: BoxDecoration(
                                            color: AppColors.white,
                                            borderRadius: BorderRadius.circular(16),
                                            border:
                                                Border.all(color: AppColors.border),
                                          ),
                                          child: Row(
                                            children: [
                                              const Icon(
                                                Icons.search_rounded,
                                                color: AppColors.textSecondary,
                                              ),
                                              const SizedBox(width: 12),
                                              Text(
                                                'Search by model, ID or reg no...',
                                                style: GoogleFonts.plusJakartaSans(
                                                  color: AppColors.textTertiary,
                                                  fontSize: 15,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Obx(() {
                                  if (controller.isLoading.value) {
                                    return SliverPadding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 8),
                                      sliver: SliverList(
                                        delegate: SliverChildBuilderDelegate(
                                          (context, index) => VehicleListSkeleton(),
                                          childCount: 5,
                                        ),
                                      ),
                                    );
                                  }

                                  if (controller.vehicles.isEmpty) {
                                    return SliverFillRemaining(
                                      hasScrollBody: false,
                                      child: Center(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Opacity(
                                              opacity: 0.15,
                                              child: Image.asset(
                                                'assets/icons/car.png',
                                                width: 140,
                                                fit: BoxFit.contain,
                                              ),
                                            ),
                                            const SizedBox(height: 16),
                                            Text(
                                              'No Vehicles Found',
                                              style: GoogleFonts.plusJakartaSans(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w700,
                                                color: AppColors.dark,
                                              ),
                                            ),
                                            const SizedBox(height: 80),
                                          ],
                                        ),
                                      ),
                                    );
                                  }

                                  return SliverPadding(
                                    padding: const EdgeInsets.only(
                                      left: 20,
                                      right: 20,
                                      top: 8,
                                      bottom: 100,
                                    ),
                                    sliver: SliverList(
                                      delegate: SliverChildBuilderDelegate(
                                        (context, index) {
                                          final vehicle = controller.vehicles[index];
                                          return TweenAnimationBuilder<double>(
                                            tween: Tween<double>(begin: 0, end: 1),
                                            duration: Duration(
                                              milliseconds: 300 + (index * 50),
                                            ),
                                            curve: Curves.easeOut,
                                            builder: (context, value, child) {
                                              return Transform.translate(
                                                offset: Offset(0, 50 * (1 - value)),
                                                child: Opacity(
                                                  opacity: value,
                                                  child: child,
                                                ),
                                              );
                                            },
                                            child: _VehicleListCard(
                                              vehicle: vehicle,
                                              controller: controller,
                                              listIndex: index,
                                            ),
                                          );
                                        },
                                        childCount: controller.vehicles.length,
                                      ),
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          controller.loadUnassignedDevices();
          Get.to(
            () => const AddVehicleScreen(),
            transition: Transition.rightToLeft,
          );
        },
        backgroundColor: AppColors.dark,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text(
          'Add Vehicle',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

// --------------------------------------------------------------------------
// SEARCH VEHICLE SCREEN
// --------------------------------------------------------------------------
class SearchVehicleScreen extends StatefulWidget {
  const SearchVehicleScreen({super.key});

  @override
  State<SearchVehicleScreen> createState() => _SearchVehicleScreenState();
}

class _SearchVehicleScreenState extends State<SearchVehicleScreen> {
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<VehiclesController>();

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        titleSpacing: 0,
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.dark,
          ),
          onPressed: () {
            controller.searchQuery.value = '';
            Get.back();
          },
        ),
        title: Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: Container(
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.bg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              focusNode: _focusNode,
              onChanged: (val) => controller.searchQuery.value = val,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                color: AppColors.dark,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.deny(
                  RegExp(r'[\u{1f300}-\u{1f5ff}\u{1f600}-\u{1f64f}\u{1f680}-\u{1f6ff}\u{1f900}-\u{1f9ff}\u{1f1e6}-\u{1f1ff}\u{2600}-\u{26ff}\u{2700}-\u{27bf}\u{1f3fb}-\u{1f3ff}\u{1f191}-\u{1f251}\u{1f004}\u{1f0cf}\u{1f170}-\u{1f171}\u{1f17e}-\u{1f17f}\u{1f18e}\u{3030}\u{2b50}\u{2b55}\u{2934}-\u{2935}\u{2b05}-\u{2b07}\u{2b1b}-\u{2b1c}\u{3297}\u{3299}\u{303d}\u{00a9}\u{00ae}\u{2122}]', unicode: true),
                ),
              ],
              decoration: InputDecoration(
                hintText: 'Search by model, ID or reg no...',
                hintStyle: GoogleFonts.plusJakartaSans(
                  color: AppColors.textTertiary,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),
        ),
      ),
      body: Obx(() {
        if (controller.filteredVehicles.isEmpty) {
          final noVehicles = controller.vehicles.isEmpty;
          return RefreshIndicator(
            onRefresh: () => controller.loadVehicles(forceRefresh: true),
            color: AppColors.purple,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: SizedBox(
                height: MediaQuery.of(context).size.height -
                    AppBar().preferredSize.height -
                    MediaQuery.of(context).padding.top,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Opacity(
                        opacity: 0.15,
                        child: Image.asset(
                          'assets/icons/car.png',
                          width: 140,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        noVehicles ? 'No Vehicles Found' : 'No matching vehicles',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.dark,
                        ),
                      ),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.loadVehicles(forceRefresh: true),
          color: AppColors.purple,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: controller.filteredVehicles.length,
            itemBuilder: (context, index) {
              final vehicle = controller.filteredVehicles[index];
              return _VehicleListCard(
                vehicle: vehicle,
                controller: controller,
                listIndex: index,
              );
            },
          ),
        );
      }),
    );
  }
}

// --------------------------------------------------------------------------
// ADD VEHICLE SCREEN
// --------------------------------------------------------------------------
class AddVehicleScreen extends StatelessWidget {
  const AddVehicleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<VehiclesController>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Text(
          'Register Vehicle',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.dark,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.dark,
            size: 20,
          ),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Obx(
              () => _CustomTextField(
                label: 'Registration Number',
                controller: controller.regNoCtrl,
                icon: Icons.numbers_rounded,
                hintText: 'KA-01-AB-1234',
                inputFormatters: [
                  LengthLimitingTextInputFormatter(13),
                  _RegistrationNumberFormatter(),
                ],
                errorText: controller.regNoErrorMessage.value.isEmpty
                    ? null
                    : controller.regNoErrorMessage.value,
              ),
            ),
            const SizedBox(height: 20),
            _CustomTextField(
              label: 'Vehicle Model',
              controller: controller.modelCtrl,
              icon: 'assets/icons/car.png',
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9 ]')),
              ],
            ),
            const SizedBox(height: 20),

            Text(
              'Vehicle Type',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border, width: 1.5),
                color: AppColors.white,
              ),
              child: Obx(
                () => DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: controller.selectedType.value,
                    isExpanded: true,
                    icon: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: AppColors.textSecondary,
                    ),
                    items: controller.vehicleTypes.entries.map((entry) {
                      return DropdownMenuItem(
                        value: entry.key,
                        child: Text(
                          entry.value,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.dark,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) controller.selectedType.value = val;
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tracking Device',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    Get.to(
                      () => const ActivateDeviceScreen(),
                      transition: Transition.cupertino,
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      '+ Activate New',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.purple,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border, width: 1.5),
                color: AppColors.white,
              ),
              child: Obx(() {
                if (controller.isLoadingDevices.value) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                }
                if (controller.availableDevices.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      'No devices available. Activate one first.',
                      style: GoogleFonts.plusJakartaSans(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  );
                }
                return DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: controller.selectedDeviceId.value.isEmpty
                        ? null
                        : controller.selectedDeviceId.value,
                    hint: Text(
                      'Select Device',
                      style: GoogleFonts.plusJakartaSans(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    isExpanded: true,
                    icon: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: AppColors.textSecondary,
                    ),
                    items: controller.availableDevices.map((d) {
                      return DropdownMenuItem(
                        value: d.id,
                        child: Text(
                          '${d.imei} (${d.trackerId})',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.dark,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        controller.selectedDeviceId.value = val;
                      }
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).padding.bottom + 16,
          left: 24,
          right: 24,
          top: 16,
        ),
        child: Obx(
          () => GestureDetector(
            onTap: controller.isAddingVehicle.value
                ? null
                : () => controller.addVehicle(context).then((success) {
                      if (success) Get.back();
                    }),
            child: Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                color: controller.isAddingVehicle.value
                    ? AppColors.dark3
                    : AppColors.dark,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.dark.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: controller.isAddingVehicle.value
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        'Register Vehicle',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// --------------------------------------------------------------------------
// ACTIVATE DEVICE SCREEN
// --------------------------------------------------------------------------
class ActivateDeviceScreen extends StatelessWidget {
  const ActivateDeviceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<VehiclesController>();
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Text(
          'Activate Device',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.dark,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.dark,
            size: 20,
          ),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _CustomTextField(
              label: 'IMEI Number',
              controller: controller.imeiCtrl,
              icon: Icons.qr_code_2_rounded,
              inputType: TextInputType.number,
               ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                    child: Divider(color: AppColors.border, thickness: 1)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'OR',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ),
                Expanded(
                    child: Divider(color: AppColors.border, thickness: 1)),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                // ── FIX 2: scan button QR scan ──────────────────────────────
                onPressed: () async {
                  final result = await Get.to<String>(
                    () => const QRScannerScreen(),
                    transition: Transition.cupertino,
                  );
                  if (result != null) {
                    NotixDialog.show(
                      context,
                      type: NotixType.info,
                      theme: NotixTheme(
                        animationStyle: NotixAnimationStyle.flip,
                      ),
                      title: 'Confirm Activation',
                      message:
                          'IMEI: $result\n\nThis is the data scanned. Are you sure you want to proceed to activate?',
                      confirmText: 'Activate',
                      cancelText: 'Cancel',
                      // Let NotixDialog dismiss itself — no Get.back() here
                      onCancel: () {},
                      onConfirm: () {
                        controller.imeiCtrl.text = result;
                        // Defer so dialog finishes closing before we navigate
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          controller.activateDevice(context).then((success) {
                            if (success) Get.back();
                          });
                        });
                      },
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.white,
                  foregroundColor: AppColors.purple,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side:
                        const BorderSide(color: AppColors.purple, width: 1.5),
                  ),
                ),
                icon: const Icon(Icons.qr_code_scanner_rounded),
                label: Text(
                  'Scan QR to Activate',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).padding.bottom + 16,
          left: 24,
          right: 24,
          top: 16,
        ),
        child: Obx(
          () => GestureDetector(
            onTap: controller.isActivatingDevice.value
                ? null
                : () => controller.activateDevice(context).then((success) {
                      if (success) Get.back();
                    }),
            child: Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.dark,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: controller.isActivatingDevice.value
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        'Activate & Continue',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// --------------------------------------------------------------------------
// LIST ITEM CARD WIDGET
// --------------------------------------------------------------------------
class _VehicleListCard extends StatelessWidget {
  final VehicleModel vehicle;
  final VehiclesController controller;
  final int listIndex;

  const _VehicleListCard({
    required this.vehicle,
    required this.controller,
    required this.listIndex,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.to(
          () => VehicleDetailsScreen(
            vehicleId: vehicle.id,
            vehicleImage: controller.getVehicleImage(vehicle, listIndex),
          ),
          transition: Transition.cupertino,
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    vehicle.model,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: AppColors.dark,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        vehicle.isOnline
                            ? Icons.signal_cellular_alt_rounded
                            : Icons.signal_cellular_off_rounded,
                        size: 16,
                        color: vehicle.isOnline
                            ? AppColors.green
                            : AppColors.red,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        vehicle.isOnline ? 'Online' : 'Offline',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: vehicle.isOnline
                              ? AppColors.green
                              : AppColors.red,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        vehicle.registrationNumber,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.location_on_rounded,
                        size: 14,
                        color: AppColors.textTertiary,
                      ),
                      Text(
                        'Tracked',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      _IconDetail(
                        icon: Icons.battery_charging_full_rounded,
                        value: '${vehicle.batteryLevel}%',
                        color: AppColors.green,
                      ),
                      _IconDetail(
                        icon: Icons.local_gas_station_rounded,
                        value: '${vehicle.fuelLevel}%',
                        color: AppColors.amber,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 120,
              height: 90,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(16),
              ),
              clipBehavior: Clip.antiAlias,
              child: Center(
                child: Image.asset(
                  controller.getVehicleImage(vehicle, listIndex),
                  fit: BoxFit.cover,
                  width: 120,
                  height: 90,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.directions_car_rounded,
                    color: AppColors.textTertiary,
                    size: 40,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IconDetail extends StatelessWidget {
  final IconData icon;
  final String value;
  final Color color;

  const _IconDetail({
    required this.icon,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.dark,
          ),
        ),
      ],
    );
  }
}

class _CustomTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final dynamic icon;
  final TextInputType inputType;
  final Widget? suffixIcon;
  final String? hintText;
  final String? errorText;
  final List<TextInputFormatter>? inputFormatters;

  const _CustomTextField({
    required this.label,
    required this.controller,
    required this.icon,
    this.inputType = TextInputType.text,
    this.suffixIcon,
    this.hintText,
    this.errorText,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: errorText != null ? AppColors.red : AppColors.border,
              width: 1.5,
            ),
            color: AppColors.white,
          ),
          child: TextField(
            controller: controller,
            keyboardType: inputType,
            inputFormatters: [
              FilteringTextInputFormatter.deny(
                RegExp(r'[\u{1f300}-\u{1f5ff}\u{1f600}-\u{1f64f}\u{1f680}-\u{1f6ff}\u{1f900}-\u{1f9ff}\u{1f1e6}-\u{1f1ff}\u{2600}-\u{26ff}\u{2700}-\u{27bf}\u{1f3fb}-\u{1f3ff}\u{1f191}-\u{1f251}\u{1f004}\u{1f0cf}\u{1f170}-\u{1f171}\u{1f17e}-\u{1f17f}\u{1f18e}\u{3030}\u{2b50}\u{2b55}\u{2934}-\u{2935}\u{2b05}-\u{2b07}\u{2b1b}-\u{2b1c}\u{3297}\u{3299}\u{303d}\u{00a9}\u{00ae}\u{2122}]', unicode: true),
              ),
              if (inputFormatters != null) ...inputFormatters!,
            ],
            style: GoogleFonts.plusJakartaSans(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                color: AppColors.textTertiary,
              ),
              prefixIcon: icon is IconData
                  ? Icon(icon as IconData,
                      color: AppColors.textSecondary, size: 20)
                  : Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Image.asset(
                        icon as String,
                        width: 20,
                        height: 20,
                        color: AppColors.textSecondary,
                        fit: BoxFit.contain,
                      ),
                    ),
              suffixIcon: suffixIcon,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 16,
                horizontal: 16,
              ),
            ),
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 4),
            child: Text(
              errorText!,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                color: AppColors.red,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }
}

class _StickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double height;

  _StickyHeaderDelegate({required this.child, required this.height});

  @override
  double get minExtent => height;
  @override
  double get maxExtent => height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: AppColors.bg,
      child: child,
    );
  }

  @override
  bool shouldRebuild(_StickyHeaderDelegate oldDelegate) {
    return false;
  }
}

class _RegistrationNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var text = newValue.text.toUpperCase().replaceAll('-', '');
    
    // Only allow letters and numbers
    text = text.replaceAll(RegExp(r'[^A-Z0-9]'), '');

    var newString = '';
    for (var i = 0; i < text.length; i++) {
      newString += text[i];
      if (i == 1 || i == 3 || i == 5) {
        if (i != text.length - 1) {
          newString += '-';
        }
      }
    }

    return TextEditingValue(
      text: newString,
      selection: TextSelection.fromPosition(TextPosition(offset: newString.length)),
    );
  }
}

// --------------------------------------------------------------------------
// QR SCANNER SCREEN
// --------------------------------------------------------------------------
class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  final MobileScannerController _scannerController = MobileScannerController();
  bool _hasScanned = false; // guard against duplicate detections

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Scan QR Code',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.dark,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.dark),
          onPressed: () => Get.back(),
        ),
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _scannerController,
            onDetect: (capture) {
              // ── FIX 3: guard against firing Get.back() multiple times ──
              if (_hasScanned) return;
              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                if (barcode.rawValue != null) {
                  _hasScanned = true;
                  // Use Navigator directly with explicit result type
                  Navigator.of(context).pop(barcode.rawValue);
                  break;
                }
              }
            },
          ),
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.purple, width: 3),
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ),
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'Place the QR code inside the frame',
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}