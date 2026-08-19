import '../api/api_client.dart';
import '../models/user.dart';

class AuthRepository {
  AuthRepository(this._api);

  final ApiClient _api;

  Future<User> register({
    required String name,
    required String email,
    required String password,
    String? phone,
    String? deviceId,
    String? role,
  }) {
    return _authenticate(
      '/auth/register',
      {
        'name': name,
        'email': email,
        'password': password,
        if (phone != null && phone.isNotEmpty) 'phone': phone,
        'device_id': ?deviceId,
        'role': ?role,
      },
    );
  }

  Future<User> becomePartner() {
    return _authenticate('/auth/become-partner', const {});
  }

  Future<User> login({
    required String email,
    required String password,
    String? deviceId,
  }) {
    return _authenticate(
      '/auth/login',
      {
        'email': email,
        'password': password,
        'device_id': ?deviceId,
      },
    );
  }

  Future<User> loginWithGoogle({
    required String idToken,
    String? deviceId,
    String? role,
  }) {
    return _authenticate(
      '/auth/oauth',
      {
        'provider': 'google',
        'id_token': idToken,
        'device_id': ?deviceId,
        'role': ?role,
      },
    );
  }

  Future<void> logout() async {
    final refresh = await _api.tokens.readRefresh();
    try {
      if (refresh != null) {
        await _api.post<void>(
          '/auth/logout',
          data: {'refresh_token': refresh},
        );
      }
    } catch (_) {
      // Still clear local tokens even if the server call fails.
    } finally {
      await _api.tokens.clear();
    }
  }

  Future<String> forgotPassword(String email) async {
    final response = await _api.post<Map<String, dynamic>>(
      '/auth/forgot-password',
      data: {'email': email},
    );
    return (response.data?['message'] as String?) ??
        'If an account exists for that email, password reset instructions have been sent.';
  }

  Future<User?> restore() async {
    final access = await _api.tokens.readAccess();
    final refresh = await _api.tokens.readRefresh();
    if ((access == null || access.isEmpty) &&
        (refresh == null || refresh.isEmpty)) {
      return null;
    }
    try {
      final response = await _api.get<Map<String, dynamic>>('/auth/me');
      return User.fromJson(response.data!);
    } catch (_) {
      await _api.tokens.clear();
      return null;
    }
  }

  Future<User> _authenticate(String path, Map<String, dynamic> data) async {
    final response = await _api.post<Map<String, dynamic>>(path, data: data);
    final body = response.data!;
    await _api.tokens.save(
      accessToken: body['access_token'] as String,
      refreshToken: body['refresh_token'] as String,
    );
    return User.fromJson(body['user'] as Map<String, dynamic>);
  }
}
