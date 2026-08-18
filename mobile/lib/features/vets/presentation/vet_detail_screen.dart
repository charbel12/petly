import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/providers/user_provider.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/utils/whatsapp.dart';
import '../../../core/widgets/async_error_view.dart';
import '../../../core/widgets/hours_schedule.dart';
import '../../../core/widgets/listing_image.dart';
import '../../../core/widgets/skeleton.dart';
import '../../../core/widgets/soft_card.dart';
import '../providers/vets_providers.dart';

class VetDetailScreen extends ConsumerWidget {
  const VetDetailScreen({
    super.key,
    required this.vetId,
    this.heroSource = 'list',
  });

  final String vetId;
  final String heroSource;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vetAsync = ref.watch(vetDetailProvider(vetId));
    final tokens = AppTokens.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Clinic details')),
      body: vetAsync.when(
        loading: () => const Padding(
          padding: EdgeInsets.all(20),
          child: ListingCardSkeleton(count: 1),
        ),
        error: (error, stackTrace) => AsyncErrorView(
          error: error,
          onRetry: () => ref.invalidate(vetDetailProvider(vetId)),
        ),
        data: (vet) {
          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: AspectRatio(
                        aspectRatio: 16 / 9,
                        child: ListingImage(
                          imageUrl: vet.imageUrl,
                          heroTag: '${vet.heroTag}-$heroSource',
                          placeholderIcon: Icons.local_hospital_rounded,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SoftCard(
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
                                      .titleLarge
                                      ?.copyWith(fontWeight: FontWeight.w700),
                                ),
                              ),
                              if (vet.verified)
                                Icon(
                                  Icons.verified_rounded,
                                  color: tokens.onCard,
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            vet.distanceAndLocation,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: tokens.onCardMuted,
                                ),
                          ),
                          const SizedBox(height: 16),
                          _InfoRow(
                            icon: Icons.place_outlined,
                            label: 'Location',
                            value: vet.location,
                          ),
                          const SizedBox(height: 10),
                          _InfoRow(
                            icon: Icons.phone_outlined,
                            label: 'Phone',
                            value: '+${WhatsAppService.normalizePhone(vet.phone)}',
                          ),
                          const SizedBox(height: 10),
                          _InfoRow(
                            icon: Icons.schedule_rounded,
                            label: 'Status',
                            value: vet.isOpenNow ? 'Open now' : 'Closed',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (vet.hours != null) ...[
                      HoursScheduleCard(hours: vet.hours!),
                      const SizedBox(height: 20),
                    ],
                    Text(
                      'Services',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 10),
                    SoftCard(
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: vet.services
                            .map(
                              (s) => Chip(
                                label: Text(
                                  s,
                                  style: TextStyle(color: tokens.onCard),
                                ),
                                backgroundColor:
                                    tokens.onCard.withValues(alpha: 0.14),
                                side: BorderSide.none,
                              ),
                            )
                            .toList(),
                      ),
                    ),
                    if (vet.isEmergency) ...[
                      const SizedBox(height: 16),
                      SoftCard(
                        child: Row(
                          children: [
                            Icon(
                              Icons.emergency_rounded,
                              color: tokens.danger,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'This clinic offers emergency care',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final user = ref.read(currentUserProvider).asData?.value;
                      final deviceId = await ref.read(deviceIdProvider.future);
                      final ok = await WhatsAppService.openChat(
                        phone: vet.phone,
                        analytics: ref.read(analyticsRepositoryProvider),
                        entityType: 'vet',
                        entityId: vet.id,
                        userId: user?.id,
                        deviceId: deviceId,
                        source: 'detail',
                      );
                      if (!context.mounted) return;
                      if (!ok) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Could not open WhatsApp'),
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.chat_rounded),
                    label: const Text('Chat on WhatsApp'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(AppConstants.whatsappGreen),
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(56),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final tokens = AppTokens.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: tokens.onCard),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: tokens.onCardMuted,
                    ),
              ),
              Text(
                value,
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
