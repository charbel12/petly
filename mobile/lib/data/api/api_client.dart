import 'dart:async';

import 'package:dio/dio.dart';
import '../../core/auth/token_storage.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/api_error.dart';

class ApiClient {
  ApiClient({
    Dio? dio,
    String? baseUrl,
    TokenStorage? tokenStorage,
  })  : _tokens = tokenStorage ?? TokenStorage(),
        _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: baseUrl ?? AppConstants.apiBaseUrl,
                connectTimeout: const Duration(seconds: 60),
                receiveTimeout: const Duration(seconds: 60),
                headers: {'Content-Type': 'application/json'},
              ),
            ) {
    _bare = Dio(
      BaseOptions(
        baseUrl: _dio.options.baseUrl,
        connectTimeout: _dio.options.connectTimeout,
        receiveTimeout: _dio.options.receiveTimeout,
        headers: {'Content-Type': 'application/json'},
      ),
    );
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          if (!_isAnonymousAuthPath(options.path)) {
            final token = await _tokens.readAccess();
            if (token != null && token.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          final req = error.requestOptions;
          final is401 = error.response?.statusCode == 401;
          final alreadyRetried = req.extra['retried'] == true;

          if (is401 && !alreadyRetried && !_isAnonymousAuthPath(req.path)) {
            final refreshed = await tryRefresh();
            if (refreshed) {
              final token = await _tokens.readAccess();
              if (token != null) {
                req.headers['Authorization'] = 'Bearer $token';
              }
              req.extra['retried'] = true;
              try {
                final response = await _dio.fetch(req);
                handler.resolve(response);
                return;
              } catch (retryError) {
                if (retryError is DioException) {
                  error = retryError;
                }
              }
            } else {
              onSessionExpired?.call();
            }
          }

          handler.reject(
            DioException(
              requestOptions: error.requestOptions,
              response: error.response,
              type: error.type,
              error: ApiException.fromDio(error),
              message: ApiException.fromDio(error).message,
            ),
          );
        },
      ),
    );
  }

  final TokenStorage _tokens;
  final Dio _dio;
  late final Dio _bare;
  Completer<bool>? _refreshLock;

  /// Invoked when a refresh fails and the stored session is cleared.
  void Function()? onSessionExpired;

  TokenStorage get tokens => _tokens;

  Dio get dio => _dio;

  static bool _isAnonymousAuthPath(String path) {
    return         path.contains('/auth/login') ||
        path.contains('/auth/register') ||
        path.contains('/auth/oauth') ||
        path.contains('/auth/refresh') ||
        path.contains('/auth/forgot-password');
  }

  Future<bool> tryRefresh() async {
    if (_refreshLock != null) return _refreshLock!.future;
    final lock = Completer<bool>();
    _refreshLock = lock;
    try {
      final refresh = await _tokens.readRefresh();
      if (refresh == null || refresh.isEmpty) {
        await _tokens.clear();
        lock.complete(false);
        return false;
      }
      final response = await _bare.post<Map<String, dynamic>>(
        '/auth/refresh',
        data: {'refresh_token': refresh},
      );
      final data = response.data;
      final access = data?['access_token'] as String?;
      final nextRefresh = data?['refresh_token'] as String?;
      if (access == null || nextRefresh == null) {
        await _tokens.clear();
        lock.complete(false);
        return false;
      }
      await _tokens.save(accessToken: access, refreshToken: nextRefresh);
      lock.complete(true);
      return true;
    } catch (_) {
      await _tokens.clear();
      lock.complete(false);
      return false;
    } finally {
      _refreshLock = null;
    }
  }

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) {
    return _dio.get<T>(path, queryParameters: queryParameters);
  }

  Future<Response<T>> post<T>(String path, {Object? data}) {
    return _dio.post<T>(path, data: data);
  }

  Future<Response<T>> patch<T>(String path, {Object? data}) {
    return _dio.patch<T>(path, data: data);
  }

  Future<Response<T>> delete<T>(String path) {
    return _dio.delete<T>(path);
  }
}
