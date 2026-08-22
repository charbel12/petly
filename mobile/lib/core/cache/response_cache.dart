import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Thin key/value cache-aside wrapper over [SharedPreferences], used to keep
/// the last-known-good JSON response for a handful of list endpoints so the
/// app can still show something while offline.
///
/// Keys are prefixed with [_prefix] so they never collide with the theme/auth
/// prefs also stored in [SharedPreferences].
class ResponseCache {
  const ResponseCache();

  static const _prefix = 'cache:';

  Future<void> put(String key, String jsonBody) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_prefix$key', jsonBody);
  }

  Future<String?> get(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('$_prefix$key');
  }

  /// Builds a deterministic cache key from an endpoint path and its query
  /// parameters (sorted by key so the same logical request always hashes to
  /// the same string regardless of map insertion order).
  static String keyFor(String path, Map<String, dynamic> queryParameters) {
    final entries = queryParameters.entries
        .where((e) => e.value != null)
        .toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    final query = entries.map((e) => '${e.key}=${e.value}').join('&');
    return '$path?$query';
  }

  /// Whether [error] looks like a connectivity failure (no network / can't
  /// reach the server / timed out) rather than a real API error — the only
  /// case where falling back to a stale cached response makes sense.
  static bool isConnectivityError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionError:
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return true;
      default:
        return false;
    }
  }
}
