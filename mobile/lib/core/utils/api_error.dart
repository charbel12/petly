import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import '../../l10n/app_localizations.dart';
import '../auth/google_sign_in_errors.dart';

/// Broad classification of an [ApiException] so the UI layer can render a
/// localized message. `serverMessage` and `custom` carry dynamic/server- or
/// call-site-provided text that is intentionally not translated.
enum ApiErrorKind {
  timeout,
  connectionError,
  serverMessage,
  badResponseGeneric,
  unexpectedNetwork,
  custom,
}

/// Typed API failure for UI messaging.
class ApiException implements Exception {
  ApiException(
    this.message, {
    this.isOffline = false,
    this.statusCode,
    this.kind = ApiErrorKind.custom,
  });

  final String message;
  final bool isOffline;
  final int? statusCode;
  final ApiErrorKind kind;

  factory ApiException.fromDio(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiException(
          'Connection timed out. Check your network and try again.',
          isOffline: true,
          kind: ApiErrorKind.timeout,
        );
      case DioExceptionType.connectionError:
        return ApiException(
          'Cannot reach Petly servers. Is the API running?',
          isOffline: true,
          kind: ApiErrorKind.connectionError,
        );
      case DioExceptionType.badResponse:
        final data = error.response?.data;
        final statusCode = error.response?.statusCode;
        if (data is Map && data['error'] is String) {
          return ApiException(
            data['error'] as String,
            statusCode: statusCode,
            kind: ApiErrorKind.serverMessage,
          );
        }
        return ApiException(
          'Something went wrong ($statusCode)',
          statusCode: statusCode,
          kind: ApiErrorKind.badResponseGeneric,
        );
      default:
        return ApiException(
          error.message ?? 'Unexpected network error',
          kind: ApiErrorKind.unexpectedNetwork,
        );
    }
  }

  @override
  String toString() => message;
}

/// Renders [error] as a user-facing, localized message. Dynamic/server- or
/// call-site-provided text (e.g. a specific "Item not found") is passed
/// through untranslated since it isn't part of the app's static copy.
String friendlyErrorMessage(BuildContext context, Object error) {
  final l10n = AppLocalizations.of(context)!;
  if (error is ApiException) {
    switch (error.kind) {
      case ApiErrorKind.timeout:
        return l10n.errorConnectionTimeout;
      case ApiErrorKind.connectionError:
        return l10n.errorCannotReachServer;
      case ApiErrorKind.badResponseGeneric:
        return l10n.errorGenericWithCode(error.statusCode ?? 0);
      case ApiErrorKind.unexpectedNetwork:
        return l10n.errorUnexpectedNetwork;
      case ApiErrorKind.serverMessage:
      case ApiErrorKind.custom:
        return error.message;
    }
  }
  if (error is DioException) {
    return friendlyErrorMessage(context, ApiException.fromDio(error));
  }
  if (error is GoogleSignInUnavailable) return error.message;
  return l10n.errorGeneric;
}
