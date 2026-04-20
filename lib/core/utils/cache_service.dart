import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CacheService {
  static const String _cachePrefix = 'api_cache_';

  /// Saves data to cache with a TTL (Time To Live) in minutes.
  static Future<void> save(String key, dynamic data, {int ttlMinutes = 60}) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheData = {
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'ttl': ttlMinutes * 60 * 1000,
      'data': data,
    };
    await prefs.setString('$_cachePrefix$key', jsonEncode(cacheData));
  }

  /// Retrieves data from cache if it hasn't expired.
  static Future<dynamic> get(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final cachedString = prefs.getString('$_cachePrefix$key');
    if (cachedString == null) return null;

    try {
      final cacheData = jsonDecode(cachedString) as Map<String, dynamic>;
      final timestamp = cacheData['timestamp'] as int;
      final ttl = cacheData['ttl'] as int;
      final data = cacheData['data'];

      final now = DateTime.now().millisecondsSinceEpoch;
      if (now - timestamp < ttl) {
        return data;
      } else {
        // Cache expired, but don't remove it yet - keep it as a fallback
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  /// Retrieves data from cache even if it has expired (as a fallback).
  static Future<dynamic> getExpiredFallback(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final cachedString = prefs.getString('$_cachePrefix$key');
    if (cachedString == null) return null;

    try {
      final cacheData = jsonDecode(cachedString) as Map<String, dynamic>;
      return cacheData['data'];
    } catch (e) {
      return null;
    }
  }

  /// Clears all cached API responses.
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((key) => key.startsWith(_cachePrefix));
    for (final key in keys) {
      await prefs.remove(key);
    }
  }

  /// Removes a specific cache entry.
  static Future<void> remove(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_cachePrefix$key');
  }
}
