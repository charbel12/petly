import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/providers/user_provider.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/utils/whatsapp.dart';
import '../../../core/widgets/listing_image.dart';
import '../../../core/widgets/soft_card.dart';
import '../../../data/models/vet.dart';

class VetCard extends ConsumerWidget {
  const VetCard({
    super.key,
    required this.vet,
    this.onTap,
    this.compact = false,
    this.source = 'list',
  });

  final Vet vet;
  final VoidCallback? onTap;
  final bool compact;
  final String source;

  Future<void> _openWhatsApp(BuildContext context, WidgetRef ref) async {
    final user = ref.read(currentUserProvider).asData?.value;
    final deviceId = await ref.read(deviceIdProvider.future);
    final ok = await WhatsAppService.openChat(
      phone: vet.phone,
      analytics: ref.read(analyticsRepositoryProvider),
      entityType: 'vet',
      entityId: vet.id,
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = AppTokens.of(context);
    final services = vet.services.take(2).toList();

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
                  imageUrl: vet.imageUrl,
                  heroTag: '${vet.heroTag}-$source',
                  placeholderIcon: Icons.local_hospital_rounded,
                ),
              ),
              Positioned(
                top: 10,
                left: 10,
                child: Row(
                  children: [
                    if (vet.isOpenNow)
                      _OverlayChip(
                        label: 'Open',
                        color: tokens.success,
                      ),
                    if (vet.isEmergency) ...[
                      if (vet.isOpenNow) const SizedBox(width: 6),
                      _OverlayChip(
                        label: 'Emergency',
                        color: tokens.danger,
                      ),
                    ],
                  ],
                ),
              ),
              if (vet.verified)
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: tokens.surface.withValues(alpha: 0.92),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.verified_rounded,
                      size: 18,
                      color: tokens.brandPrimary,
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
                  vet.name,
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  vet.distanceAndLocation,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: tokens.textMuted,
                      ),
                ),
                if (!compact && services.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: services
                        .map(
                          (s) => Text(
                            s,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  color: tokens.brandPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        )
                        .toList(),
                  ),
                ],
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

class _OverlayChip extends StatelessWidget {
  const _OverlayChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
