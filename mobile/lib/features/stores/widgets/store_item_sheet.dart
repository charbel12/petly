import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/pet_taxonomy.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/providers/user_provider.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/utils/whatsapp.dart';
import '../../../data/models/store.dart';
import '../../../data/models/store_item.dart';

Future<void> showStoreItemSheet({
  required BuildContext context,
  required WidgetRef ref,
  required StoreItem item,
  required Store store,
  required String source,
}) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (sheetContext) {
      final tokens = AppTokens.of(sheetContext);
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.name,
              style: Theme.of(sheetContext).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(item.category.icon, size: 16, color: tokens.onCardMuted),
                const SizedBox(width: 6),
                Text(
                  item.category.label,
                  style: TextStyle(color: tokens.onCardMuted),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              item.priceLabel,
              style: Theme.of(sheetContext).textTheme.titleMedium?.copyWith(
                    color: tokens.brandPrimary,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            if (item.description != null && item.description!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(item.description!),
            ],
            if (!item.inStock) ...[
              const SizedBox(height: 12),
              Text(
                'Currently out of stock',
                style: TextStyle(color: tokens.onCardMuted),
              ),
            ],
            const SizedBox(height: 18),
            if (store.phone != null)
              ElevatedButton.icon(
                onPressed: () async {
                  Navigator.of(sheetContext).pop();
                  final user = ref.read(currentUserProvider).asData?.value;
                  final deviceId = await ref.read(deviceIdProvider.future);
                  final ok = await WhatsAppService.openChat(
                    phone: store.phone!,
                    message:
                        'Hello, I found ${item.name} at ${store.name} on Petly and would like to ask about it.',
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
                },
                icon: const Icon(Icons.chat_rounded),
                label: const Text('Ask on WhatsApp'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(AppConstants.whatsappGreen),
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(48),
                ),
              ),
          ],
        ),
      );
    },
  );
}
