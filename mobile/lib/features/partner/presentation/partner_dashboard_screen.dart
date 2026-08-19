import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/async_error_view.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/hero_panel.dart';
import '../../../core/widgets/petly_background.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/soft_card.dart';
import '../../../core/widgets/status_chip.dart';
import '../../../data/models/store.dart';
import '../../../data/models/vet.dart';
import '../providers/partner_providers.dart';

class PartnerDashboardScreen extends ConsumerWidget {
  const PartnerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listings = ref.watch(partnerListingsProvider);
    final tokens = AppTokens.of(context);

    return PetlyBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: const Text('Partner dashboard')),
        body: listings.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => AsyncErrorView(
            error: error,
            onRetry: () => ref.invalidate(partnerListingsProvider),
          ),
          data: (data) {
            return RefreshIndicator(
              color: tokens.brandPrimary,
              onRefresh: () async => ref.invalidate(partnerListingsProvider),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                children: [
                  HeroPanel(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your listings',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'New and edited listings stay pending until an admin approves them.',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: tokens.onCardMuted,
                              ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => context.push('/partner/vets/new'),
                          icon: const Icon(Icons.add_rounded),
                          label: const Text('Add clinic'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => context.push('/partner/stores/new'),
                          icon: const Icon(Icons.add_rounded),
                          label: const Text('Add store'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  if (data.isEmpty)
                    EmptyState(
                      icon: Icons.storefront_outlined,
                      title: 'No listings yet',
                      message:
                          'Add your clinic or store. It will appear in Explore after approval.',
                    )
                  else ...[
                    if (data.vets.isNotEmpty) ...[
                      const SectionHeader(title: 'Clinics'),
                      const SizedBox(height: 10),
                      for (final vet in data.vets) ...[
                        _VetListingTile(
                          vet: vet,
                          onTap: () => context.push('/partner/vets/${vet.id}/edit'),
                        ),
                        const SizedBox(height: 10),
                      ],
                    ],
                    if (data.stores.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      const SectionHeader(title: 'Stores'),
                      const SizedBox(height: 10),
                      for (final store in data.stores) ...[
                        _StoreListingTile(
                          store: store,
                          onTap: () =>
                              context.push('/partner/stores/${store.id}/edit'),
                          onItems: () =>
                              context.push('/partner/stores/${store.id}/items'),
                        ),
                        const SizedBox(height: 10),
                      ],
                    ],
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _VetListingTile extends StatelessWidget {
  const _VetListingTile({required this.vet, required this.onTap});

  final Vet vet;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      onTap: onTap,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vet.name,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 4),
                Text(vet.location),
                if (vet.status == 'rejected' &&
                    (vet.rejectionReason?.isNotEmpty ?? false)) ...[
                  const SizedBox(height: 6),
                  Text('Reason: ${vet.rejectionReason}'),
                ],
              ],
            ),
          ),
          StatusChip(status: vet.status ?? 'pending'),
        ],
      ),
    );
  }
}

class _StoreListingTile extends StatelessWidget {
  const _StoreListingTile({
    required this.store,
    required this.onTap,
    required this.onItems,
  });

  final Store store;
  final VoidCallback onTap;
  final VoidCallback onItems;

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      onTap: onTap,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  store.name,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 4),
                Text('${store.type} · ${store.location}'),
                if (store.status == 'rejected' &&
                    (store.rejectionReason?.isNotEmpty ?? false)) ...[
                  const SizedBox(height: 6),
                  Text('Reason: ${store.rejectionReason}'),
                ],
              ],
            ),
          ),
          StatusChip(status: store.status ?? 'pending'),
          IconButton(
            tooltip: 'Manage items',
            onPressed: onItems,
            icon: const Icon(Icons.inventory_2_outlined),
          ),
        ],
      ),
    );
  }
}
