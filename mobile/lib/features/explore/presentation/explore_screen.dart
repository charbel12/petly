import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/async_error_view.dart';
import '../../../data/models/store.dart';
import '../../../data/models/vet.dart';
import '../../stores/providers/stores_providers.dart';
import '../../stores/widgets/store_card.dart';
import '../../vets/providers/vets_providers.dart';
import '../../vets/widgets/vet_card.dart';

class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({super.key, this.initialTab = 0});

  final int initialTab;

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTab.clamp(0, 1),
    );
    final vetSearch = ref.read(exploreVetsFiltersProvider).search;
    if (vetSearch.isNotEmpty) {
      _searchController.text = vetSearch;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    ref.read(exploreVetsFiltersProvider.notifier).setSearch(value);
    ref.read(exploreStoresFiltersProvider.notifier).setSearch(value);
  }

  @override
  Widget build(BuildContext context) {
    final vetFilters = ref.watch(exploreVetsFiltersProvider);
    final storeFilters = ref.watch(exploreStoresFiltersProvider);
    final vetsAsync = ref.watch(exploreVetsProvider);
    final storesAsync = ref.watch(exploreStoresProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Explore'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(AppColors.primary),
          unselectedLabelColor: const Color(AppColors.muted),
          indicatorColor: const Color(AppColors.primary),
          tabs: const [
            Tab(text: 'Vets'),
            Tab(text: 'Stores'),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: const InputDecoration(
                hintText: 'Search by name or area...',
                prefixIcon: Icon(Icons.search_rounded),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _VetsTab(
                  filters: vetFilters,
                  asyncList: vetsAsync,
                  onToggleOpen: () =>
                      ref.read(exploreVetsFiltersProvider.notifier).toggleOpenNow(),
                  onDistance: (km) => ref
                      .read(exploreVetsFiltersProvider.notifier)
                      .setMaxDistance(km),
                  onRetry: () => ref.invalidate(exploreVetsProvider),
                ),
                _StoresTab(
                  filters: storeFilters,
                  asyncList: storesAsync,
                  onToggleOpen: () => ref
                      .read(exploreStoresFiltersProvider.notifier)
                      .toggleOpenNow(),
                  onType: (type) =>
                      ref.read(exploreStoresFiltersProvider.notifier).setType(type),
                  onDistance: (km) => ref
                      .read(exploreStoresFiltersProvider.notifier)
                      .setMaxDistance(km),
                  onRetry: () => ref.invalidate(exploreStoresProvider),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChipRow extends StatelessWidget {
  const _FilterChipRow({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(children: children),
    );
  }
}

Widget _gapChip(Widget child) => Padding(
      padding: const EdgeInsets.only(right: 8),
      child: child,
    );

class _VetsTab extends StatelessWidget {
  const _VetsTab({
    required this.filters,
    required this.asyncList,
    required this.onToggleOpen,
    required this.onDistance,
    required this.onRetry,
  });

  final ExploreVetsFilters filters;
  final AsyncValue<List<Vet>> asyncList;
  final VoidCallback onToggleOpen;
  final ValueChanged<double?> onDistance;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _FilterChipRow(
          children: [
            _gapChip(
              FilterChip(
                label: const Text('Open now'),
                selected: filters.openNow,
                onSelected: (_) => onToggleOpen(),
              ),
            ),
            _gapChip(
              FilterChip(
                label: const Text('< 5 km'),
                selected: filters.maxDistanceKm == 5,
                onSelected: (selected) => onDistance(selected ? 5 : null),
              ),
            ),
            _gapChip(
              FilterChip(
                label: const Text('< 15 km'),
                selected: filters.maxDistanceKm == 15,
                onSelected: (selected) => onDistance(selected ? 15 : null),
              ),
            ),
          ],
        ),
        Expanded(
          child: asyncList.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stackTrace) => AsyncErrorView(
              error: error,
              onRetry: onRetry,
            ),
            data: (items) {
              if (items.isEmpty) {
                return const Center(child: Text('No vets match your filters'));
              }
              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final vet = items[index];
                  return VetCard(
                    vet: vet,
                    onTap: () => context.push('/vets/${vet.id}'),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _StoresTab extends StatelessWidget {
  const _StoresTab({
    required this.filters,
    required this.asyncList,
    required this.onToggleOpen,
    required this.onType,
    required this.onDistance,
    required this.onRetry,
  });

  final ExploreStoresFilters filters;
  final AsyncValue<List<Store>> asyncList;
  final VoidCallback onToggleOpen;
  final ValueChanged<String?> onType;
  final ValueChanged<double?> onDistance;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _FilterChipRow(
          children: [
            _gapChip(
              FilterChip(
                label: const Text('Open now'),
                selected: filters.openNow,
                onSelected: (_) => onToggleOpen(),
              ),
            ),
            _gapChip(
              FilterChip(
                label: const Text('Pet Store'),
                selected: filters.type == 'Pet Store',
                onSelected: (s) => onType(s ? 'Pet Store' : null),
              ),
            ),
            _gapChip(
              FilterChip(
                label: const Text('Grooming'),
                selected: filters.type == 'Grooming',
                onSelected: (s) => onType(s ? 'Grooming' : null),
              ),
            ),
            _gapChip(
              FilterChip(
                label: const Text('< 10 km'),
                selected: filters.maxDistanceKm == 10,
                onSelected: (s) => onDistance(s ? 10 : null),
              ),
            ),
          ],
        ),
        Expanded(
          child: asyncList.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stackTrace) => AsyncErrorView(
              error: error,
              onRetry: onRetry,
            ),
            data: (items) {
              if (items.isEmpty) {
                return const Center(child: Text('No stores match your filters'));
              }
              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final store = items[index];
                  return StoreCard(
                    store: store,
                    onTap: () => context.push('/stores/${store.id}'),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
