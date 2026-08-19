import 'package:dio/dio.dart';
import '../auth/google_sign_in_errors.dart';

/// Typed API failure for UI messaging.
class ApiException implements Exception {
  ApiException(this.message, {this.isOffline = false, this.statusCode});

  final String message;
  final bool isOffline;
  final int? statusCode;

  factory ApiException.fromDio(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiException(
          'Connection timed out. Check your network and try again.',
          isOffline: true,
        );
      case DioExceptionType.connectionError:
        return ApiException(
          'Cannot reach Petly servers. Is the API running?',
          isOffline: true,
        );
      case DioExceptionType.badResponse:
        final data = error.response?.data;
        final serverMsg = data is Map && data['error'] is String
            ? data['error'] as String
            : 'Something went wrong (${error.response?.statusCode})';
        return ApiException(serverMsg, statusCode: error.response?.statusCode);
      default:
        return ApiException(error.message ?? 'Unexpected network error');
    }
  }

  @override
  String toString() => message;
}

String friendlyErrorMessage(Object error) {
  if (error is ApiException) return error.message;
  if (error is DioException) return ApiException.fromDio(error).message;
  if (error is GoogleSignInUnavailable) return error.message;
  return 'Something went wrong. Please try again.';
}
