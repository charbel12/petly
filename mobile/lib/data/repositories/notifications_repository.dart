import '../api/api_client.dart';

/// Registers/unregisters this device's push token with the backend so it can
/// receive push notifications (partner status updates, etc). See
/// `core/services/push_notification_service.dart` for the caller.
class NotificationsRepository {
  NotificationsRepository(this._api);

  final ApiClient _api;

  Future<void> registerToken({
    required String token,
    required String platform,
  }) async {
    await _api.post<void>(
      '/notifications/device-tokens',
      data: {'token': token, 'platform': platform},
    );
  }

  Future<void> unregisterToken(String token) async {
    await _api.delete<void>('/notifications/device-tokens/$token');
  }
}
