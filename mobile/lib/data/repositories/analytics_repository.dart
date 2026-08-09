import '../api/api_client.dart';

class AnalyticsRepository {
  AnalyticsRepository(this._api);

  final ApiClient _api;

  Future<void> trackWhatsAppClick({
    required String entityType,
    String? entityId,
    String? userId,
    String? deviceId,
    String? source,
  }) async {
    await _api.post(
      '/analytics/whatsapp-clicks',
      data: {
        'entity_type': entityType,
        'entity_id': ?entityId,
        'user_id': ?userId,
        'device_id': ?deviceId,
        'source': ?source,
      },
    );
  }
}
