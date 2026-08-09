import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/providers/user_provider.dart';
import '../../../core/utils/whatsapp.dart';
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
    if (horizontal) {
      return SoftCard(
        onTap: onTap,
        padding: const EdgeInsets.all(14),
        child: SizedBox(
          width: 160,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                height: 72,
                decoration: BoxDecoration(
                  color: const Color(AppColors.secondary).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  _iconForType(store.type),
                  color: const Color(AppColors.secondary),
                  size: 32,
                ),
              ),
              const SizedBox(height: 12),
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
                      color: const Color(AppColors.muted),
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                store.distanceLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: const Color(AppColors.muted),
                      fontSize: 11,
                    ),
              ),
            ],
          ),
        ),
      );
    }

    return SoftCard(
      onTap: onTap,
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(AppColors.secondary).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  _iconForType(store.type),
                  color: const Color(AppColors.secondary),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
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
                      '${store.type} · ${store.distanceLabel}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: const Color(AppColors.muted),
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (store.phone != null) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _openWhatsApp(context, ref),
                icon: const Icon(Icons.chat_rounded, size: 18),
                label: const Text('WhatsApp'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
