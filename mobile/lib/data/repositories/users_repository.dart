import '../api/api_client.dart';
import '../models/user.dart';

class UsersRepository {
  UsersRepository(this._api);

  final ApiClient _api;

  Future<User> create({
    required String name,
    required String phone,
    String? deviceId,
  }) async {
    final response = await _api.post<Map<String, dynamic>>(
      '/users',
      data: {
        'name': name,
        'phone': phone,
        'device_id': ?deviceId,
      },
    );
    return User.fromJson(response.data!);
  }

  Future<User> getById(String id) async {
    final response = await _api.get<Map<String, dynamic>>('/users/$id');
    return User.fromJson(response.data!);
  }

  Future<User?> getByDeviceId(String deviceId) async {
    try {
      final response = await _api.get<Map<String, dynamic>>(
        '/users/by-device/$deviceId',
      );
      return User.fromJson(response.data!);
    } catch (_) {
      return null;
    }
  }
}
