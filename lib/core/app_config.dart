import 'package:flutter/foundation.dart';

class AppConfig {
  // ── Base URLs ──────────────────────────────
  static const String prodBaseUrl    = 'http://192.168.0.40:4000/api';
  static const String devBaseUrl     = 'http://192.168.0.40:4000/api';
  static const String testingBaseUrl = 'http://192.168.0.40:4000/api';

  // ── Socket URLs ────────────────────────────
  static const String prodSocketUrl    = 'http://192.168.0.40:4000';
  static const String devSocketUrl     = 'http://192.168.0.40:4000';
  static const String testingSocketUrl = 'http://192.168.0.40:4000';

  // ── Dynamic URLs ───────────────────────────
  static final String baseUrl   = _getBaseUrl();
  static final String socketUrl = _getSocketUrl();

  static String _getBaseUrl() {
    if (kDebugMode)   return testingBaseUrl;
    if (kProfileMode) return devBaseUrl;
    if (kReleaseMode) return prodBaseUrl;
    return prodBaseUrl;
  }

  static String _getSocketUrl() {
    if (kDebugMode)   return testingSocketUrl;
    if (kProfileMode) return devSocketUrl;
    if (kReleaseMode) return prodSocketUrl;
    return prodSocketUrl;
  }
}