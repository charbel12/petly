import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/providers/user_provider.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/utils/whatsapp.dart';
import '../../../core/widgets/listing_image.dart';
import '../../../core/widgets/soft_card.dart';
import '../../../data/models/store.dart';

class StoreCard extends ConsumerWidget {
  const StoreCard({
    super.key,
    required this.store,
    this.onTap,
    this.horizontal = false,
    this.source = 'list',
  });

  final Store store;
  final VoidCallback? onTap;
  final bool horizontal;
  final String source;

  Future<void> _openWhatsApp(BuildContext context, WidgetRef ref) async {
    if (store.phone == null || store.phone!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No WhatsApp number for this store')),
      );
      return;
    }
    final user = ref.read(currentUserProvider).asData?.value;
    final deviceId = await ref.read(deviceIdProvider.future);
    final ok = await WhatsAppService.openChat(
      phone: store.phone!,
      analytics: ref.read(analyticsRepositoryProvider),
      entityType: 'store',
      entityId: store.id,
      userId: user?.id,
      deviceId: deviceId,
      source: source,
    );
    if (!context.mounted) return;
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open WhatsApp')),
      );
    }
  }

  IconData _iconForType(String type) {
    final t = type.toLowerCase();
    if (t.contains('groom')) return Icons.content_cut_rounded;
    if (t.contains('aqua')) return Icons.water_rounded;
    return Icons.storefront_rounded;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = AppTokens.of(context);
    if (horizontal) {
      return SoftCard(
        onTap: onTap,
        padding: EdgeInsets.zero,
        child: SizedBox(
          width: 180,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 16 / 9,
                child: ListingImage(
                  imageUrl: store.imageUrl,
                  heroTag: '${store.heroTag}-$source',
                  placeholderIcon: _iconForType(store.type),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      store.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      store.type,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: tokens.brandSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      store.distanceAndLocation,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: tokens.textMuted,
                            fontSize: 11,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SoftCard(
      onTap: onTap,
      padding: EdgeInsets.zero,
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              AspectRatio(
                aspectRatio: 16 / 9,
                child: ListingImage(
                  imageUrl: store.imageUrl,
                  heroTag: '${store.heroTag}-$source',
                  placeholderIcon: _iconForType(store.type),
                ),
              ),
              if (store.isOpenNow)
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.55),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Open',
                      style: TextStyle(
                        color: tokens.success,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  store.name,
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  '${store.type} · ${store.distanceAndLocation}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: tokens.textMuted,
                      ),
                ),
                if (store.phone != null)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: () => _openWhatsApp(context, ref),
                      icon: const Icon(Icons.chat_outlined, size: 16),
                      label: const Text('WhatsApp'),
                      style: TextButton.styleFrom(
                        foregroundColor: tokens.textMuted,
                        padding: const EdgeInsets.symmetric(horizontal: 0),
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
