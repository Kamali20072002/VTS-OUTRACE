import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// MapMarkerHelper
///
/// Draws a zoom-responsive Google Maps marker:
///
///   [  light outer ring  ]
///      [ dark inner ring ]
///         [orange circle]  ← vehicle PNG inside, white-tinted
///
/// Assets required (place in assets/images/vehicletype/):
///   map_car.png    – white/transparent top-down or side car PNG
///   map_truck.png  – white/transparent top-down or side truck PNG
///   map_bike.png   – white/transparent top-down or side bike PNG
///
/// Free download links (white transparent PNGs, no attribution needed):
///   Car:   https://www.freepng.es/png-car-top-view-white/download
///   Truck: https://www.pngwing.com/en/search?q=top+view+truck+white
///   Bike:  https://www.pngwing.com/en/search?q=top+view+motorcycle+white
///
/// Or generate your own with any icon tool and export as white PNG on transparent bg.
/// ─────────────────────────────────────────────────────────────────────────────
class MapMarkerHelper {
  static final Map<String, BitmapDescriptor> _cache = {};

  /// [type]     → 'CAR' | 'TRUCK' | 'BIKE' (from API, case-insensitive)
  /// [isOnline] → orange when true, grey when false
  /// [zoom]     → current map zoom level (10–18), controls marker size
  /// [course]   → rotation angle for the vehicle image
  static Future<BitmapDescriptor> createVehicleMarker({
    required String type,
    bool isOnline = true,
    double zoom = 14.0,
    double course = 0.0,
  }) async {
    final String cacheKey = '${type.toLowerCase()}_${isOnline}_${zoom.round()}_${course.round()}';
    if (_cache.containsKey(cacheKey)) return _cache[cacheKey]!;

    // ── Responsive sizing ──────────────────────────────────────────
    final double s           = _scale(zoom);  // 0.55 – 1.35
    final double canvasSize  = 260 * s;
    final double outerRadius = 110 * s;  // faint ring
    final double innerRadius = 88  * s;  // mid ring
    final double circleR     = 64  * s;  // solid fill
    final double imageSize   = 120 * s;  // vehicle image (larger)

    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(
      recorder,
      Rect.fromLTWH(0, 0, canvasSize, canvasSize),
    );
    final Offset center = Offset(canvasSize / 2, canvasSize / 2);

    // ── Colors ─────────────────────────────────────────────────────
    final Color baseColor;
    switch (type.toLowerCase()) {
      case 'truck': baseColor = const Color(0xFF2196F3); break; // Blue
      case 'bike':
      case 'motorcycle': baseColor = const Color(0xFF9C27B0); break; // Purple
      default: baseColor = const Color(0xFFFF5722); // Orange (Car)
    }

    final Color outerRing = isOnline
        ? baseColor.withOpacity(0.22)
        : baseColor.withOpacity(0.12);

    final Color innerRing = isOnline
        ? baseColor.withOpacity(0.48)
        : baseColor.withOpacity(0.24);

    final Color fill = isOnline
        ? baseColor
        : baseColor.withOpacity(0.65);

    // ── Draw rings ─────────────────────────────────────────────────
    // Outer faint ring
    canvas.drawCircle(center, outerRadius, Paint()..color = outerRing);
    // Inner darker ring
    canvas.drawCircle(center, innerRadius, Paint()..color = innerRing);
    // Solid fill circle
    canvas.drawCircle(center, circleR, Paint()..color = fill);
    // Thin white border
    canvas.drawCircle(
      center, circleR,
      Paint()
        ..color = Colors.white.withOpacity(0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8 * s,
    );

    // ── Draw vehicle image ─────────────────────────────────────────
    final String assetPath = _assetFor(type);
    try {
      final ui.Image img = await _loadAsset(assetPath);

      // Clip to circle
      canvas.save();
      canvas.clipPath(
        Path()..addOval(
          Rect.fromCircle(center: center, radius: circleR - 2 * s),
        ),
      );

      // ── Rotate the car image specifically on the canvas ────────────
      // course=0 is North. PNG asset faces LEFT (270°). 
      // To point North, rotate by (0 + 90) = 90°.
      final double rotationRad = (course + 90.0) * (3.1415926535897932 / 180.0);
      
      canvas.translate(center.dx, center.dy);
      canvas.rotate(rotationRad);
      
      paintImage(
        canvas: canvas,
        rect: Rect.fromCenter(
          center: Offset.zero,
          width: imageSize,
          height: imageSize,
        ),
        image: img,
        fit: BoxFit.contain,
        // Remove white tint to show original car image colors
      );
      canvas.restore();
    } catch (_) {
      // Fallback to Material icon if asset missing
      _drawIcon(canvas, center, s, type);
    }

    // ── Finalise ───────────────────────────────────────────────────
    final ui.Picture picture   = recorder.endRecording();
    final ui.Image   rendered  = await picture.toImage(canvasSize.toInt(), canvasSize.toInt());
    final ByteData?  bytes     = await rendered.toByteData(format: ui.ImageByteFormat.png);
    final descriptor = BitmapDescriptor.fromBytes(bytes!.buffer.asUint8List());

    _cache[cacheKey] = descriptor;
    return descriptor;
  }

  /// Call this when you want to force-regenerate (e.g. after zoom jump)
  static void clearCache() => _cache.clear();

  // ── Internals ──────────────────────────────────────────────────────────────

  static double _scale(double zoom) {
    // zoom 8 → 0.55,  zoom 20 → 1.35
    return (0.55 + ((zoom.clamp(8.0, 20.0) - 8.0) / 12.0) * 0.80);
  }

  static String _assetFor(String type) {
    switch (type.toLowerCase()) {
      case 'truck': return 'assets/images/vehicletype/map_truck.png';
      case 'bike':
      case 'motorcycle': return 'assets/images/vehicletype/map_bike.png';
      default: return 'assets/images/vehicletype/map_car.png';
    }
  }

  static Future<ui.Image> _loadAsset(String path) async {
    final data  = await rootBundle.load(path);
    final codec = await ui.instantiateImageCodec(
      data.buffer.asUint8List(),
      targetWidth: 256,
      targetHeight: 256,
    );
    return (await codec.getNextFrame()).image;
  }

  static void _drawIcon(Canvas canvas, Offset center, double s, String type) {
    final IconData icon;
    switch (type.toLowerCase()) {
      case 'truck': icon = Icons.local_shipping_rounded; break;
      case 'bike':
      case 'motorcycle': icon = Icons.two_wheeler_rounded; break;
      default: icon = Icons.directions_car_filled_rounded;
    }
    final tp = TextPainter(textDirection: TextDirection.ltr)
      ..text = TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(
          fontSize: 48 * s,
          fontFamily: icon.fontFamily,
          package: icon.fontPackage,
          color: Colors.black87,
        ),
      )
      ..layout();
    tp.paint(canvas, Offset(center.dx - tp.width / 2, center.dy - tp.height / 2));
  }
}