import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/providers/location_provider.dart';
import '../../../core/providers/user_provider.dart';
import '../../../core/widgets/async_error_view.dart';
import '../../../core/widgets/section_header.dart';
import '../../stores/providers/stores_providers.dart';
import '../../stores/widgets/store_card.dart';
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
    final userAsync = ref.watch(currentUserProvider);
    final locationAsync = ref.watch(locationProvider);
    final locationLabel = ref.watch(locationLabelProvider);
    final vetsAsync = ref.watch(nearbyVetsProvider);
    final storesAsync = ref.watch(featuredStoresProvider);
    final firstName =
        userAsync.asData?.value.name.split(' ').first ?? 'there';
    final locationHint = locationAsync.asData?.value.errorMessage;

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          color: const Color(AppColors.primary),
          onRefresh: () async {
            await ref.read(locationProvider.notifier).refresh();
            ref.invalidate(nearbyVetsProvider);
            ref.invalidate(featuredStoresProvider);
            await Future.wait([
              ref.read(nearbyVetsProvider.future),
              ref.read(featuredStoresProvider.future),
            ]);
          },
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
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
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Row(
                            children: [
                              Icon(
                                locationAsync.asData?.value.isGps == true
                                    ? Icons.my_location_rounded
                                    : Icons.location_on_rounded,
                                size: 16,
                                color: const Color(AppColors.primary),
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
                                        color: const Color(AppColors.muted),
                                      ),
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.refresh_rounded,
                                size: 14,
                                color: Color(AppColors.muted),
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
                                  color: const Color(AppColors.secondary),
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
                      color: const Color(AppColors.primary).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.pets_rounded,
                      color: Color(AppColors.primary),
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
                    onPressed: () => _onSearch(_searchController.text),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _EmergencyButton(
                onPressed: () async {
                  final emergency = await ref.read(emergencyVetsProvider.future);
                  if (!context.mounted) return;
                  if (emergency.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('No emergency vets available right now'),
                      ),
                    );
                    return;
                  }
                  context.push('/vets/${emergency.first.id}');
                },
              ),
              const SizedBox(height: 24),
              SectionHeader(
                title: 'Nearby vets',
                actionLabel: 'See all',
                onAction: () => context.go('/explore'),
              ),
              const SizedBox(height: 12),
              vetsAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (e, _) => AsyncErrorView(
                  error: e,
                  onRetry: () => ref.invalidate(nearbyVetsProvider),
                  compact: true,
                ),
                data: (vets) {
                  if (vets.isEmpty) {
                    return const Text('No vets found nearby.');
                  }
                  return Column(
                    children: vets
                        .take(4)
                        .map(
                          (vet) => VetCard(
                            vet: vet,
                            source: 'home',
                            onTap: () => context.push('/vets/${vet.id}'),
                          ),
                        )
                        .toList(),
                  );
                },
              ),
              const SizedBox(height: 16),
              SectionHeader(
                title: 'Featured stores',
                actionLabel: 'Explore',
                onAction: () => context.go('/explore?tab=stores'),
              ),
              const SizedBox(height: 12),
              storesAsync.when(
                loading: () => const SizedBox(
                  height: 140,
                  child: Center(child: CircularProgressIndicator()),
                ),
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
                    height: 200,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: stores.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final store = stores[index];
                        return StoreCard(
                          store: store,
                          horizontal: true,
                          source: 'home',
                          onTap: () => context.push('/stores/${store.id}'),
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
    );
  }
}

class _EmergencyButton extends StatelessWidget {
  const _EmergencyButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFF6B4A), Color(AppColors.secondary)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(AppColors.secondary).withValues(alpha: 0.35),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            child: Row(
              children: [
                Icon(Icons.emergency_rounded, color: Colors.white, size: 28),
                SizedBox(width: 12),
                Expanded(
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
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: Colors.white),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
