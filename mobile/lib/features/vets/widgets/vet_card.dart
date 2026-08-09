import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/providers/user_provider.dart';
import '../../../core/utils/whatsapp.dart';
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
    return SoftCard(
      onTap: onTap,
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(AppColors.primary).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.local_hospital_rounded,
                  color: Color(AppColors.primary),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            vet.name,
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ),
                        if (vet.verified)
                          const Icon(
                            Icons.verified_rounded,
                            size: 18,
                            color: Color(AppColors.primary),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      vet.distanceLabel,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: const Color(AppColors.muted),
                          ),
                    ),
                    if (!compact) ...[
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          if (vet.isOpenNow)
                            _Badge(
                              label: 'Open now',
                              color: const Color(AppColors.success),
                            ),
                          if (vet.isEmergency)
                            _Badge(
                              label: 'Emergency',
                              color: const Color(AppColors.danger),
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _openWhatsApp(context, ref),
              icon: const Icon(Icons.chat_rounded, size: 18),
              label: const Text('WhatsApp'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF25D366),
                minimumSize: const Size.fromHeight(44),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
