import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/location_provider.dart';
import '../../../core/providers/user_provider.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/async_error_view.dart';
import '../../../core/widgets/hero_panel.dart';
import '../../../core/widgets/motion.dart';
import '../../../core/widgets/petly_background.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/skeleton.dart';
import '../../stores/providers/stores_providers.dart';
import '../../stores/widgets/store_card.dart';
import '../../stores/widgets/nearby_store_items_section.dart';
import '../../vets/providers/vets_providers.dart';
import '../../vets/widgets/vet_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch(String value) {
    final query = value.trim();
    if (query.isEmpty) return;
    ref.read(exploreVetsFiltersProvider.notifier).setSearch(query);
    context.go('/explore');
  }

  @override
  Widget build(BuildContext context) {
    final tokens = AppTokens.of(context);
    final userAsync = ref.watch(currentUserProvider);
    final locationAsync = ref.watch(locationProvider);
    final locationLabel = ref.watch(locationLabelProvider);
    final vetsAsync = ref.watch(nearbyVetsProvider);
    final storesAsync = ref.watch(featuredStoresProvider);
    final firstName =
        userAsync.asData?.value.name.split(' ').first ?? 'there';
    final locationHint = locationAsync.asData?.value.errorMessage;

    return PetlyBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: RefreshIndicator(
            color: tokens.brandPrimary,
            onRefresh: () async {
              await ref.read(locationProvider.notifier).refresh();
              ref.invalidate(nearbyVetsProvider);
              ref.invalidate(featuredStoresProvider);
              ref.invalidate(nearestStoreItemsProvider);
              await Future.wait([
                ref.read(nearbyVetsProvider.future),
                ref.read(featuredStoresProvider.future),
                ref.read(nearestStoreItemsProvider.future),
              ]);
            },
            child: ListView(
              cacheExtent: 2500,
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              children: [
                HeroPanel(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Hi, $firstName 👋',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(height: 4),
                                InkWell(
                                  onTap: () async {
                                    await ref
                                        .read(locationProvider.notifier)
                                        .refresh();
                                    ref.invalidate(nearbyVetsProvider);
                                    ref.invalidate(featuredStoresProvider);
                                    ref.invalidate(nearestStoreItemsProvider);
                                  },
                                  borderRadius: BorderRadius.circular(8),
                                  child: Row(
                                    children: [
                                      Icon(
                                        locationAsync.asData?.value.isGps ==
                                                true
                                            ? Icons.my_location_rounded
                                            : Icons.location_on_rounded,
                                        size: 16,
                                        color: tokens.onCard,
                                      ),
                                      const SizedBox(width: 4),
                                      Flexible(
                                        child: Text(
                                          locationAsync.isLoading
                                              ? 'Finding your location...'
                                              : locationLabel,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(
                                                color: tokens.onCardMuted,
                                              ),
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Icon(
                                        Icons.refresh_rounded,
                                        size: 14,
                                        color: tokens.onCardMuted,
                                      ),
                                    ],
                                  ),
                                ),
                                if (locationHint != null) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    locationHint,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          color: tokens.brandAccent,
                                          fontSize: 11,
                                        ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: tokens.brandPrimary.withValues(
                                alpha: 0.15,
                              ),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(
                              Icons.pets_rounded,
                              color: tokens.brandPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _searchController,
                        textInputAction: TextInputAction.search,
                        onSubmitted: _onSearch,
                        decoration: InputDecoration(
                          hintText: 'Search vets or clinics...',
                          prefixIcon: const Icon(Icons.search_rounded),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.arrow_forward_rounded),
                            onPressed: () =>
                                _onSearch(_searchController.text),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _EmergencyButton(
                        onPressed: () {
                          ref
                              .read(exploreVetsFiltersProvider.notifier)
                              .setEmergency(true);
                          context.go('/explore');
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                SectionHeader(
                  title: 'Nearby vets',
                  actionLabel: 'See all',
                  onAction: () => context.go('/explore'),
                ),
                const SizedBox(height: 12),
                vetsAsync.when(
                  skipLoadingOnReload: true,
                  skipLoadingOnRefresh: true,
                  loading: () => const ListingCardSkeleton(count: 3),
                  error: (e, _) => AsyncErrorView(
                    error: e,
                    onRetry: () => ref.invalidate(nearbyVetsProvider),
                    compact: true,
                  ),
                  data: (vets) {
                    if (vets.isEmpty) {
                      return const Text('No vets found nearby.');
                    }
                    final nearby = vets.take(4).toList();
                    return Column(
                      children: [
                        for (var i = 0; i < nearby.length; i++)
                          StaggeredListItem(
                            index: i,
                            child: VetCard(
                              vet: nearby[i],
                              source: 'home',
                              onTap: () => context
                                  .push('/vets/${nearby[i].id}?src=home'),
                            ),
                          ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 16),
                const NearbyStoreItemsSection(source: 'home'),
                const SizedBox(height: 16),
                SectionHeader(
                  title: 'Featured stores',
                  actionLabel: 'Explore',
                  onAction: () => context.go('/explore?tab=stores'),
                ),
                const SizedBox(height: 12),
                storesAsync.when(
                  skipLoadingOnReload: true,
                  skipLoadingOnRefresh: true,
                  loading: () => const HorizontalCardSkeleton(),
                  error: (e, _) => AsyncErrorView(
                    error: e,
                    onRetry: () => ref.invalidate(featuredStoresProvider),
                    compact: true,
                  ),
                  data: (stores) {
                    if (stores.isEmpty) {
                      return const Text('No featured stores yet.');
                    }
                    return SizedBox(
                      height: 228,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: stores.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(width: 12),
                        itemBuilder: (context, index) {
                          final store = stores[index];
                          return StaggeredListItem(
                            index: index,
                            child: StoreCard(
                              store: store,
                              horizontal: true,
                              source: 'home',
                              onTap: () => context
                                  .push('/stores/${store.id}?src=home'),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmergencyButton extends StatelessWidget {
  const _EmergencyButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final tokens = AppTokens.of(context);
    return ScaleOnTap(
      onTap: onPressed,
      child: Ink(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [tokens.emergencyStart, tokens.emergencyEnd],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: tokens.emergencyStart.withValues(alpha: 0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          child: Row(
            children: [
              const Icon(Icons.emergency_rounded, color: Colors.white, size: 28),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Emergency Vet',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Find open emergency clinics nearby',
                      style: TextStyle(
                        color: Color(0xE6FFFFFF),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}
