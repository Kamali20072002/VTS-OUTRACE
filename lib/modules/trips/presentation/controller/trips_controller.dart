import 'dart:io';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import '../../domain/repositories/trips_repository.dart';

class TripsController extends GetxController {
  final TripsRepository _repository = TripsRepository();
  final RxString selectedFilter = 'Day'.obs;
  
  // Data
  final RxList allTrips = [].obs;
  final RxList filteredTrips = [].obs;
  final RxMap summary = {}.obs;
  
  // Sorting
  final RxString selectedSort = 'Recent Trips'.obs;
  final List<String> sortOptions = ['Recent Trips', 'Oldest Trips'];
  
  // Filters
  final RxList<String> vehicleTypes = <String>['All'].obs;
  final RxString selectedVehicleType = 'All'.obs;
  
  final RxList<String> vehicleRegNumbers = <String>['All Vehicles'].obs;
  final RxString selectedVehicleReg = 'All Vehicles'.obs;

  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchTrips();
  }

  Future<void> fetchTrips({bool forceRefresh = false}) async {
    if (allTrips.isEmpty) {
      isLoading.value = true;
    }
    try {
      final response = await _repository.getMyTrips(forceRefresh: forceRefresh);
      
      // Extract trips list and summary
      final List<dynamic> rawTrips = response['data'] as List<dynamic>? ?? [];
      if (response.containsKey('summary')) {
        summary.value = response['summary'] as Map<String, dynamic>? ?? {};
      }

      final mappedTrips = rawTrips.map((t) {
        final start = DateTime.parse(t['startTime']).toLocal();
        final duration = (t['duration'] as num).toDouble();
        final end = start.add(Duration(seconds: duration.toInt()));
        
        final timeFormatter = DateFormat('hh:mm a');
        final timeStr = '${timeFormatter.format(start)} - ${timeFormatter.format(end)}';
        
        final startArea = t['startLocation']?['area'] ?? 'Unknown';
        final endArea = t['endLocation']?['area'] ?? 'Unknown';
        
        final distance = (t['distance'] as num).toDouble();
        final avgSpeed = duration > 0 ? (distance / (duration / 3600)).round() : 0;

        return {
          ...t,
          'time': timeStr,
          'route': '$startArea to $endArea',
          'distance': '${distance.toStringAsFixed(1)} km',
          'speed': 'AVG $avgSpeed km/h',
          'vehicleType': t['vehicleId']?['type'] ?? 'Unknown',
          'regNo': t['vehicleId']?['registrationNumber'] ?? 'Unknown',
        };
      }).toList();

      allTrips.value = mappedTrips;
      
      // Extract unique vehicle types
      final types = mappedTrips.map((t) => t['vehicleType'].toString().toUpperCase()).toSet().toList();
      vehicleTypes.value = ['All', ...types];

      // Extract unique registration numbers
      final regs = mappedTrips.map((t) => t['regNo'].toString()).toSet().toList();
      vehicleRegNumbers.value = ['All Vehicles', ...regs];

      applyFilters();
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch trip history: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void setVehicleTypeFilter(String type) {
    selectedVehicleType.value = type;
    applyFilters();
  }

  void setVehicleRegFilter(String? reg) {
    if (reg == null) return;
    selectedVehicleReg.value = reg;
    applyFilters();
  }

  void applyFilters() {
    var result = allTrips.toList();

    if (selectedVehicleType.value != 'All') {
      result = result.where((t) => t['vehicleType'].toString().toUpperCase() == selectedVehicleType.value).toList();
    }

    if (selectedVehicleReg.value != 'All Vehicles') {
      result = result.where((t) => t['regNo'] == selectedVehicleReg.value).toList();
    }

    // Apply Sorting
    if (selectedSort.value == 'Recent Trips') {
      result.sort((a, b) => b['startTime'].toString().compareTo(a['startTime'].toString()));
    } else {
      result.sort((a, b) => a['startTime'].toString().compareTo(b['startTime'].toString()));
    }

    filteredTrips.value = result;
  }

  String formatDuration(num seconds) {
    final duration = Duration(seconds: seconds.toInt());
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final secs = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '${hours}h : ${minutes}m : ${secs}s';
  }

  // ── PDF REPORT GENERATION ─────────────────────────
  Future<pw.Document> _generateReportPDF() async {
    final pdf = pw.Document();
    final now = DateTime.now();
    final dateStr = DateFormat('dd MMM yyyy, hh:mm a').format(now);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('OVER ALL RUNNING SUMMARY', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                  pw.Text(dateStr, style: const pw.TextStyle(fontSize: 12)),
                ],
              ),
            ),
            pw.SizedBox(height: 20),
            
            // Summary Table
            pw.Table(
              border: pw.TableBorder.all(),
              children: [
                pw.TableRow(
                  children: [
                    pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('Metric', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                    pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('Value', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                  ],
                ),
                pw.TableRow(
                  children: [
                    pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('Total Distance')),
                    pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('${(summary['totalDistance'] as num? ?? 0).toStringAsFixed(2)} km')),
                  ],
                ),
                pw.TableRow(
                  children: [
                    pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('Total Duration')),
                    pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text(formatDuration(summary['totalDuration'] as num? ?? 0))),
                  ],
                ),
                pw.TableRow(
                  children: [
                    pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('Total Trips')),
                    pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('${summary['totalTrips'] ?? 0}')),
                  ],
                ),
              ],
            ),
            
            pw.SizedBox(height: 30),
            pw.Text('Trip Details', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),

            // Trips Table
            pw.Table(
              border: pw.TableBorder.all(),
              children: [
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey300),
                  children: [
                    pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('Time', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold))),
                    pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('Vehicle', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold))),
                    pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('Route', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold))),
                    pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('Distance', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold))),
                  ],
                ),
                ...filteredTrips.map((t) {
                  return pw.TableRow(
                    children: [
                      pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text(t['time'].toString(), style: const pw.TextStyle(fontSize: 9))),
                      pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('${t['regNo']}\n(${t['vehicleType']})', style: const pw.TextStyle(fontSize: 9))),
                      pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text(t['route'].toString(), style: const pw.TextStyle(fontSize: 9))),
                      pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text(t['distance'].toString(), style: const pw.TextStyle(fontSize: 9))),
                    ],
                  );
                }),
              ],
            ),
          ];
        },
      ),
    );
    return pdf;
  }

  Future<void> downloadReport() async {
    try {
      final pdf = await _generateReportPDF();
      await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
    } catch (e) {
      Get.snackbar('Error', 'Failed to generate report: $e');
    }
  }

  Future<void> shareReport() async {
    try {
      final pdf = await _generateReportPDF();
      final bytes = await pdf.save();
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/running_summary_report.pdf');
      await file.writeAsBytes(bytes);
      
      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'Overall Running Summary Report',
        text: 'Please find the attached running summary report.',
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to share report: $e');
    }
  }

  void setFilter(String filter) => selectedFilter.value = filter;

  void clearFilters() {
    selectedVehicleType.value = 'All';
    selectedVehicleReg.value = 'All Vehicles';
    applyFilters();
  }

  void setSort(String? sort) {
    if (sort == null) return;
    selectedSort.value = sort;
    applyFilters();
  }
}
