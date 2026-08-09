import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/providers/user_provider.dart';
import '../../../core/utils/whatsapp.dart';
import '../../../core/widgets/async_error_view.dart';
import '../../../core/widgets/soft_card.dart';
import '../providers/vets_providers.dart';

class VetDetailScreen extends ConsumerWidget {
  const VetDetailScreen({super.key, required this.vetId});

  final String vetId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vetAsync = ref.watch(vetDetailProvider(vetId));

    return Scaffold(
      appBar: AppBar(title: const Text('Clinic details')),
      body: vetAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
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
                    SoftCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: const Color(AppColors.primary)
                                      .withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Icon(
                                  Icons.local_hospital_rounded,
                                  color: Color(AppColors.primary),
                                  size: 28,
                                ),
                              ),
                              const SizedBox(width: 14),
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
                                                .titleLarge
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w700,
                                                ),
                                          ),
                                        ),
                                        if (vet.verified)
                                          const Icon(
                                            Icons.verified_rounded,
                                            color: Color(AppColors.primary),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      vet.distanceLabel,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            color: const Color(AppColors.muted),
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
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
                                label: Text(s),
                                backgroundColor: const Color(AppColors.primary)
                                    .withValues(alpha: 0.08),
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
                            const Icon(
                              Icons.emergency_rounded,
                              color: Color(AppColors.danger),
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
                      backgroundColor: const Color(0xFF25D366),
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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: const Color(AppColors.primary)),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: const Color(AppColors.muted),
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
