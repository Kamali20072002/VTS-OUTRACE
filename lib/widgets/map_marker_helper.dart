import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// MapMarkerHelper  —  sharp markers on every screen density
///
/// THE ONLY CORRECT WAY TO DO DPR-AWARE CUSTOM MARKERS:
///
///   1. Choose a LOGICAL canvas size   (e.g. 160 × 200 pts)
///   2. Multiply by dpr to get the     PHYSICAL canvas size  (480 × 600 px @ 3×)
///   3. Scale the Canvas with          canvas.scale(dpr, dpr)
///      → now every draw call you write in logical coords paints at physical res
///   4. TextPainter font sizes stay    LOGICAL  (no dpr multiply on text)
///      → TextPainter layout engine works in logical pixels; dpr-scaling the
///        canvas handles the rest automatically
///   5. Pass                           size: Size(logicalW, logicalH)
///      to BitmapDescriptor.fromBytes  so the map uses the correct logical size
///      and does NOT upscale the bitmap  (no blur)
///
/// WRONG approach (previous version):
///   p = s * dpr  ← multiplied both canvas size AND every shape by dpr
///                  but TextPainter font also got *dpr → text 3× too big
///
/// ── USAGE IN TrackController ──────────────────────────────────────────────────
///
///   final RxDouble currentZoom = 14.0.obs;
///
///   Future<void> buildMarkers() async {
///     final List<Marker> built = [];
///     for (final v in vehicles) {
///       if (v.latitude == null || v.longitude == null) continue;
///       final icon = await MapMarkerHelper.createVehicleMarker(
///         type: v.type ?? 'CAR',
///         model: v.model,
///         regNumber: v.registrationNumber,
///         isOnline: v.isOnline,
///         zoom: currentZoom.value,
///         course: v.course ?? 0.0,
///       );
///       built.add(Marker(
///         markerId: MarkerId(v.id),
///         position: LatLng(v.latitude!, v.longitude!),
///         icon: icon,
///         anchor: const Offset(0.5, 0.85),
///       ));
///     }
///     markers.assignAll(built);
///   }
///
///   void onMapCreated(GoogleMapController c) async {
///     mapController = c;
///     await buildMarkers();
///   }
///
///   void onCameraIdle() async {
///     final z = await mapController?.getZoomLevel() ?? 14.0;
///     if ((z - currentZoom.value).abs() >= 1.5) {
///       currentZoom.value = z;
///       MapMarkerHelper.clearCache();
///       await buildMarkers();
///     }
///   }
///
///   // Call after getUserLocation() resolves
///   Future<void> updateUserLocationMarker(LatLng pos) async {
///     userLocation.value = pos;
///     final icon = await MapMarkerHelper.createUserLocationMarker();
///     final m = Marker(
///       markerId: const MarkerId('user_location'),
///       position: pos,
///       icon: icon,
///       anchor: const Offset(0.5, 0.5),
///       zIndex: 99,
///     );
///     final idx = markers.indexWhere((x) => x.markerId.value == 'user_location');
///     if (idx >= 0) markers[idx] = m; else markers.add(m);
///   }
///
/// ── GEOFENCE CIRCLE ───────────────────────────────────────────────────────────
///   circles: {
///     if (userLocation.value != null)
///       MapMarkerHelper.geofenceCircle(
///         userLocation.value!,
///         radiusMetres: geofenceRadius.value,
///       ),
///   },
/// ─────────────────────────────────────────────────────────────────────────────
class MapMarkerHelper {
  static final Map<String, BitmapDescriptor> _cache = {};

  static double get _dpr =>
      ui.PlatformDispatcher.instance.views.first.devicePixelRatio;

  // ── Vehicle marker ──────────────────────────────────────────────────────────

  static Future<BitmapDescriptor> createVehicleMarker({
    required String type,
    String? model,
    String? regNumber,
    bool isOnline = true,
    double zoom = 14.0,
    double course = 0.0,
  }) async {
    final double dpr = _dpr;
    final String cacheKey =
        '${type.toLowerCase()}_${isOnline}_${zoom.round()}_'
        '${course.round()}_${model ?? ''}_${regNumber ?? ''}_'
        '${dpr.toStringAsFixed(1)}';

    if (_cache.containsKey(cacheKey)) return _cache[cacheKey]!;

    // ── LOGICAL sizes (what you "see" in pts) ────────────────────────
    final double s = _scale(zoom);    // 0.45 – 1.15

    final double outerR  = 40.0 * s; // logical pts (was 38)
    final double innerR  = 32.0 * s; // (was 30)
    final double circleR = 25.0 * s; // (was 23)
    final double imgSize = 42.0 * s; // (was 40)

    // Label measurements (TextPainter works in logical px)
    final bool hasModel = model != null && model.isNotEmpty;
    final bool hasReg   = regNumber != null && regNumber.isNotEmpty;

    double labelBoxW = 0;
    double labelBoxH = 0;
    TextPainter? modelTP;
    TextPainter? regTP;

    if (hasModel || hasReg) {
      modelTP = _tp(
        hasModel ? model! : regNumber!,
        fontSize: 11.0 * s, // (was 10.5)
        weight: FontWeight.w800,
        color: Colors.black,
      );
      regTP = _tp(
        (hasModel && hasReg) ? regNumber! : '',
        fontSize: 9.0 * s, // (was 8.5)
        weight: FontWeight.w500,
        color: const Color(0xFF888888),
      );
      final double lp = 7.0 * s; // (was 8)
      labelBoxW = (modelTP.width > regTP.width
              ? modelTP.width
              : regTP.width) +
          lp * 2;
      labelBoxH = modelTP.height +
          (regTP.text?.toPlainText().isNotEmpty == true
              ? regTP.height + 2.5 * s // (was 3)
              : 0) +
          lp * 1.2;
    }

    // Total logical canvas
    final double labelGap   = labelBoxH > 0 ? 6.0 * s : 0; // gap label→rings (was 8)
    final double triH       = 5.0 * s;                       // triangle height (was 6)
    final double logicalW   = (labelBoxW > outerR * 2
        ? labelBoxW
        : outerR * 2) + 4;
    final double logicalH   = labelBoxH + labelGap + triH + outerR * 2 + 4;

    // ── PHYSICAL canvas (logical × dpr) ─────────────────────────────
    final double physW = logicalW * dpr;
    final double physH = logicalH * dpr;

    final ui.PictureRecorder rec = ui.PictureRecorder();
    final Canvas canvas = Canvas(rec, Rect.fromLTWH(0, 0, physW, physH));

    // Scale once: now ALL draw calls use logical coordinates
    canvas.scale(dpr, dpr);

    // Centre of the ring cluster (logical coords)
    final double cx = logicalW / 2;
    final double cy = labelBoxH + labelGap + triH + outerR;

    // ── Colors ───────────────────────────────────────────────────────
    final Color base      = _baseColor(type);
    final Color outerRing = base.withOpacity(isOnline ? 0.22 : 0.12);
    final Color innerRing = base.withOpacity(isOnline ? 0.48 : 0.24);
    final Color fill      = isOnline ? base : base.withOpacity(0.65);

    // ── Label box ────────────────────────────────────────────────────
    if ((hasModel || hasReg) && modelTP != null && regTP != null) {
      final double lp     = 7.0 * s; // (was 8)
      final double cr     = 5.0 * s; // (was 6)
      final double boxLeft = (logicalW - labelBoxW) / 2;
      final double boxTop  = 0;

      final RRect box = RRect.fromLTRBR(
        boxLeft, boxTop,
        boxLeft + labelBoxW, boxTop + labelBoxH,
        Radius.circular(cr),
      );

      // Shadow
      canvas.drawRRect(
        box.shift(const Offset(0, 1.5)), // (was 2)
        Paint()
          ..color = Colors.black.withOpacity(0.10)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3), // (was 4)
      );
      // White card
      canvas.drawRRect(box, Paint()..color = Colors.white);

      // Triangle pointer (pointing down toward the circle)
      final double triBase = 5.0 * s; // (was 6)
      final double triTop  = labelBoxH;
      canvas.drawPath(
        Path()
          ..moveTo(cx - triBase, triTop)
          ..lineTo(cx + triBase, triTop)
          ..lineTo(cx, triTop + triH)
          ..close(),
        Paint()..color = Colors.white,
      );

      // Texts
      modelTP.paint(canvas, Offset(boxLeft + lp, boxTop + lp / 1.5));
      if (regTP.text?.toPlainText().isNotEmpty == true) {
        regTP.paint(
          canvas,
          Offset(boxLeft + lp,
              boxTop + lp / 1.5 + modelTP.height + 2.5 * s), // (was 3)
        );
      }
    }

    // ── Rings ────────────────────────────────────────────────────────
    canvas.drawCircle(
        Offset(cx, cy), outerR, Paint()..color = outerRing);
    canvas.drawCircle(
        Offset(cx, cy), innerR, Paint()..color = innerRing);
    canvas.drawCircle(
        Offset(cx, cy), circleR, Paint()..color = fill);
    canvas.drawCircle(
      Offset(cx, cy),
      circleR,
      Paint()
        ..color = Colors.white.withOpacity(0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );

    // ── Vehicle image ────────────────────────────────────────────────
    try {
      final ui.Image img = await _loadAsset(_assetFor(type));
      canvas.save();
      canvas.clipPath(Path()
        ..addOval(Rect.fromCircle(
            center: Offset(cx, cy), radius: circleR - 1)));
      final double rad = (course + 90.0) * (3.14159265358979 / 180.0);
      canvas.translate(cx, cy);
      canvas.rotate(rad);
      paintImage(
        canvas: canvas,
        rect: Rect.fromCenter(
            center: Offset.zero, width: imgSize, height: imgSize),
        image: img,
        fit: BoxFit.contain,
      );
      canvas.restore();
    } catch (_) {
      _iconFallback(canvas, Offset(cx, cy), s, type);
    }

    // ── Render & encode ──────────────────────────────────────────────
    final ui.Picture  pic    = rec.endRecording();
    final ui.Image    bitmap = await pic.toImage(physW.round(), physH.round());
    final ByteData?   bytes  =
        await bitmap.toByteData(format: ui.ImageByteFormat.png);

    // imagePixelRatio: tells the map that the physical pixels in the 
    // buffer should be mapped to logical pixels at this ratio.
    // This is the most reliable way to prevent blur on high-DPI screens.
    final BitmapDescriptor desc = BitmapDescriptor.bytes(
      bytes!.buffer.asUint8List(),
      imagePixelRatio: dpr,
    );

    _cache[cacheKey] = desc;
    return desc;
  }

  // ── User location marker ────────────────────────────────────────────────────

  /// Google-Maps-style blue dot rendered sharp at device DPI.
  /// Marker anchor: const Offset(0.5, 0.5)
  static Future<BitmapDescriptor> createUserLocationMarker() async {
    const String key = 'user_location_dot';
    if (_cache.containsKey(key)) return _cache[key]!;

    final double dpr = _dpr;
    const double logicalSize = 34.0; // (was 44)
    final double physSize    = logicalSize * dpr;

    final ui.PictureRecorder rec = ui.PictureRecorder();
    final Canvas canvas = Canvas(
        rec, Rect.fromLTWH(0, 0, physSize, physSize));

    canvas.scale(dpr, dpr);

    const double cx = logicalSize / 2;
    const double cy = logicalSize / 2;
    const Color blue = Color(0xFF4285F4);

    // Outer glow
    canvas.drawCircle(Offset(cx, cy), 14, // (was 18)
        Paint()..color = blue.withOpacity(0.18));
    // White ring
    canvas.drawCircle(Offset(cx, cy), 8.5, Paint()..color = Colors.white); // (was 11)
    // Shadow on white ring
    canvas.drawCircle(
      Offset(cx, cy), 8.5,
      Paint()
        ..color = Colors.black.withOpacity(0.15)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.5
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.2), // (was 1.5)
    );
    // Blue dot
    canvas.drawCircle(Offset(cx, cy), 6.5, Paint()..color = blue); // (was 8)
    // Inner specular
    canvas.drawCircle(Offset(cx, cy), 3,
        Paint()..color = Colors.white.withOpacity(0.28));

    final ui.Picture  pic    = rec.endRecording();
    final ui.Image    bitmap = await pic.toImage(physSize.round(), physSize.round());
    final ByteData?   bytes  =
        await bitmap.toByteData(format: ui.ImageByteFormat.png);

    final BitmapDescriptor desc = BitmapDescriptor.bytes(
      bytes!.buffer.asUint8List(),
      imagePixelRatio: dpr,
    );
    _cache[key] = desc;
    return desc;
  }

  // ── Geofence circle ─────────────────────────────────────────────────────────

  /// Returns a styled [Circle] matching the user-location blue dot.
  static Circle geofenceCircle(
    LatLng center, {
    double radiusMetres = 300.0,
  }) {
    return Circle(
      circleId: const CircleId('user_geofence'),
      center: center,
      radius: radiusMetres,
      fillColor: const Color(0xFF4285F4).withOpacity(0.15),
      strokeColor: const Color(0xFF4285F4).withOpacity(0.50),
      strokeWidth: 1,
    );
  }

  /// Clears bitmap cache — call before rebuilding after a zoom jump.
  static void clearCache() => _cache.clear();

  // ── Internals ─────────────────────────────────────────────────────────────

  static double _scale(double zoom) =>
      0.45 + ((zoom.clamp(8.0, 20.0) - 8.0) / 12.0) * 0.65;

  static Color _baseColor(String type) {
    switch (type.toLowerCase()) {
      case 'truck':      return const Color(0xFF2196F3);
      case 'bike':
      case 'motorcycle': return const Color(0xFF9C27B0);
      default:           return const Color(0xFFFF5722);
    }
  }

  static String _assetFor(String type) {
    switch (type.toLowerCase()) {
      case 'truck':      return 'assets/images/vehicletype/map_truck.png';
      case 'bike':
      case 'motorcycle': return 'assets/images/vehicletype/map_bike.png';
      default:           return 'assets/images/vehicletype/map_car.png';
    }
  }

  static TextPainter _tp(
    String text, {
    required double fontSize,
    required FontWeight weight,
    required Color color,
  }) =>
      TextPainter(textDirection: TextDirection.ltr)
        ..text = TextSpan(
          text: text,
          style: TextStyle(
            fontSize: fontSize,   // LOGICAL — no dpr multiplication here
            fontWeight: weight,
            color: color,
            fontFamily: 'PlusJakartaSans',
          ),
        )
        ..layout();

  static Future<ui.Image> _loadAsset(String path) async {
    final ByteData  data  = await rootBundle.load(path);
    final ui.Codec  codec = await ui.instantiateImageCodec(
      data.buffer.asUint8List(),
      targetWidth: 256,
      targetHeight: 256,
    );
    return (await codec.getNextFrame()).image;
  }

  static void _iconFallback(
      Canvas canvas, Offset center, double s, String type) {
    final IconData icon;
    switch (type.toLowerCase()) {
      case 'truck':      icon = Icons.local_shipping_rounded;   break;
      case 'bike':
      case 'motorcycle': icon = Icons.two_wheeler_rounded;      break;
      default:           icon = Icons.directions_car_filled_rounded;
    }
    final TextPainter tp = TextPainter(textDirection: TextDirection.ltr)
      ..text = TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(
          fontSize: 24.0 * s,   // logical size — canvas.scale handles DPR
          fontFamily: icon.fontFamily,
          package: icon.fontPackage,
          color: Colors.black87,
        ),
      )
      ..layout();
    tp.paint(canvas,
        Offset(center.dx - tp.width / 2, center.dy - tp.height / 2));
  }
}