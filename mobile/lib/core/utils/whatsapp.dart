import 'package:url_launcher/url_launcher.dart';
import '../constants/app_constants.dart';
import '../../data/repositories/analytics_repository.dart';

/// Builds and opens WhatsApp deep links (wa.me), optionally tracking clicks.
class WhatsAppService {
  static String normalizePhone(String phone) {
    return phone.replaceAll(RegExp(r'[^\d]'), '');
  }

  static Uri buildUri({
    required String phone,
    String? message,
  }) {
    final digits = normalizePhone(phone);
    final text = Uri.encodeComponent(message ?? AppConstants.whatsappMessage);
    return Uri.parse('https://wa.me/$digits?text=$text');
  }

  static Future<bool> openChat({
    required String phone,
    String? message,
    AnalyticsRepository? analytics,
    String entityType = 'vet',
    String? entityId,
    String? userId,
    String? deviceId,
    String? source,
  }) async {
    // Fire-and-forget analytics — never block WhatsApp open.
    if (analytics != null) {
      // ignore: unawaited_futures
      analytics
          .trackWhatsAppClick(
            entityType: entityType,
            entityId: entityId,
            userId: userId,
            deviceId: deviceId,
            source: source,
          )
          .then((_) {}, onError: (_) {});
    }

    final uri = buildUri(phone: phone, message: message);
    if (await canLaunchUrl(uri)) {
      return launchUrl(uri, mode: LaunchMode.externalApplication);
    }
    return false;
  }
}
