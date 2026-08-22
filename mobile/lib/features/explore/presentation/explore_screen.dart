import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/pet_taxonomy.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/async_error_view.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/motion.dart';
import '../../../core/widgets/petly_background.dart';
import '../../../core/widgets/skeleton.dart';
import '../../../data/models/store.dart';
import '../../../data/models/vet.dart';
import '../../../l10n/app_localizations.dart';
import '../../stores/providers/stores_providers.dart';
import '../../stores/widgets/nearby_store_items_section.dart';
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
    final tokens = AppTokens.of(context);
    final l10n = AppLocalizations.of(context)!;
    final vetFilters = ref.watch(exploreVetsFiltersProvider);
    final storeFilters = ref.watch(exploreStoresFiltersProvider);
    final vetsAsync = ref.watch(exploreVetsProvider);
    final storesAsync = ref.watch(exploreStoresProvider);

    ref.listen(exploreVetsFiltersProvider, (prev, next) {
      if (next.search != _searchController.text) {
        _searchController.text = next.search;
      }
    });

    return PetlyBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(l10n.exploreTitle),
          bottom: TabBar(
            controller: _tabController,
            labelColor: tokens.brandPrimary,
            unselectedLabelColor: tokens.textMuted,
            indicatorColor: tokens.brandPrimary,
            tabs: [
              Tab(text: l10n.exploreTabVets),
              Tab(text: l10n.exploreTabStores),
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
                decoration: InputDecoration(
                  hintText: l10n.exploreSearchHint,
                  prefixIcon: const Icon(Icons.search_rounded),
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
                    onToggleOpen: () => ref
                        .read(exploreVetsFiltersProvider.notifier)
                        .toggleOpenNow(),
                    onToggleEmergency: () => ref
                        .read(exploreVetsFiltersProvider.notifier)
                        .toggleEmergency(),
                    onDistance: (km) => ref
                        .read(exploreVetsFiltersProvider.notifier)
                        .setMaxDistance(km),
                    onPetType: (type) => ref
                        .read(exploreVetsFiltersProvider.notifier)
                        .setPetType(type),
                    onSort: (sort) => ref
                        .read(exploreVetsFiltersProvider.notifier)
                        .setSort(sort),
                    onRetry: () => ref.invalidate(exploreVetsProvider),
                  ),
                  _StoresTab(
                    filters: storeFilters,
                    asyncList: storesAsync,
                    onToggleOpen: () => ref
                        .read(exploreStoresFiltersProvider.notifier)
                        .toggleOpenNow(),
                    onType: (type) => ref
                        .read(exploreStoresFiltersProvider.notifier)
                        .setType(type),
                    onDistance: (km) => ref
                        .read(exploreStoresFiltersProvider.notifier)
                        .setMaxDistance(km),
                    onPetType: (type) => ref
                        .read(exploreStoresFiltersProvider.notifier)
                        .setPetType(type),
                    onSort: (sort) => ref
                        .read(exploreStoresFiltersProvider.notifier)
                        .setSort(sort),
                    onRetry: () => ref.invalidate(exploreStoresProvider),
                    showNearbyItems: storeFilters.search.trim().isEmpty &&
                        storeFilters.type == null,
                  ),
                ],
              ),
            ),
          ],
        ),
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
      padding: const EdgeInsetsDirectional.only(end: 8),
      child: child,
    );

/// Horizontal All/Dog/Cat/Bird/Fish/Rabbit filter row, shared by the Vets
/// and Stores tabs. Distinct from the store `type` (business category) chips.
class _PetTypeChipRow extends StatelessWidget {
  const _PetTypeChipRow({required this.selected, required this.onSelected});

  final PetType? selected;
  final ValueChanged<PetType?> onSelected;

  static const _choices = [
    PetType.dog,
    PetType.cat,
    PetType.bird,
    PetType.fish,
    PetType.rabbit,
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return _FilterChipRow(
      children: [
        _gapChip(
          FilterChip(
            label: Text(l10n.exploreAllPets),
            selected: selected == null,
            onSelected: (_) => onSelected(null),
          ),
        ),
        for (final type in _choices)
          _gapChip(
            FilterChip(
              avatar: Icon(type.icon, size: 16),
              label: Text(type.label),
              selected: selected == type,
              onSelected: (isSelected) => onSelected(isSelected ? type : null),
            ),
          ),
      ],
    );
  }
}

/// Compact "Sort by" control shared by the Vets and Stores tabs.
class _SortMenuButton extends StatelessWidget {
  const _SortMenuButton({required this.value, required this.onChanged});

  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final tokens = AppTokens.of(context);
    final l10n = AppLocalizations.of(context)!;
    final labels = {
      'distance': l10n.exploreSortNearest,
      'rating': l10n.exploreSortTopRated,
      'name': l10n.exploreSortByName,
    };
    return PopupMenuButton<String>(
      initialValue: value,
      onSelected: onChanged,
      tooltip: l10n.exploreSortTooltip,
      itemBuilder: (context) => labels.entries
          .map(
            (entry) => PopupMenuItem<String>(
              value: entry.key,
              child: Text(entry.value),
            ),
          )
          .toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          border: Border.all(color: tokens.border),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.sort_rounded, size: 16, color: tokens.onCardMuted),
            const SizedBox(width: 4),
            Text(
              labels[value] ?? l10n.exploreSortFallback,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: tokens.onCardMuted),
            ),
          ],
        ),
      ),
    );
  }
}

class _VetsTab extends StatelessWidget {
  const _VetsTab({
    required this.filters,
    required this.asyncList,
    required this.onToggleOpen,
    required this.onToggleEmergency,
    required this.onDistance,
    required this.onPetType,
    required this.onSort,
    required this.onRetry,
  });

  final ExploreVetsFilters filters;
  final AsyncValue<List<Vet>> asyncList;
  final VoidCallback onToggleOpen;
  final VoidCallback onToggleEmergency;
  final ValueChanged<double?> onDistance;
  final ValueChanged<PetType?> onPetType;
  final ValueChanged<String> onSort;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _FilterChipRow(
                children: [
                  _gapChip(
                    FilterChip(
                      label: Text(l10n.exploreFilterEmergency),
                      selected: filters.emergency,
                      onSelected: (_) => onToggleEmergency(),
                    ),
                  ),
                  _gapChip(
                    FilterChip(
                      label: Text(l10n.exploreFilterOpenNow),
                      selected: filters.openNow,
                      onSelected: (_) => onToggleOpen(),
                    ),
                  ),
                  _gapChip(
                    FilterChip(
                      label: Text(l10n.exploreFilterUnder5km),
                      selected: filters.maxDistanceKm == 5,
                      onSelected: (selected) => onDistance(selected ? 5 : null),
                    ),
                  ),
                  _gapChip(
                    FilterChip(
                      label: Text(l10n.exploreFilterUnder15km),
                      selected: filters.maxDistanceKm == 15,
                      onSelected: (selected) => onDistance(selected ? 15 : null),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsetsDirectional.only(end: 20),
              child: _SortMenuButton(value: filters.sort, onChanged: onSort),
            ),
          ],
        ),
        _PetTypeChipRow(selected: filters.petType, onSelected: onPetType),
        Expanded(
          child: asyncList.when(
            skipLoadingOnReload: true,
            skipLoadingOnRefresh: true,
            loading: () => const Padding(
              padding: EdgeInsets.fromLTRB(20, 8, 20, 24),
              child: ListingCardSkeleton(count: 4),
            ),
            error: (error, stackTrace) => AsyncErrorView(
              error: error,
              onRetry: onRetry,
            ),
            data: (items) {
              if (items.isEmpty) {
                final q = filters.search.trim();
                if (q.isNotEmpty) {
                  return EmptyState(
                    title: l10n.exploreNoClinicsMatchQuery(q),
                    message: l10n.exploreTryAnotherArea,
                  );
                }
                return EmptyState(
                  title: l10n.exploreNoVetsMatchFilters,
                  message: l10n.exploreAdjustFilters,
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final vet = items[index];
                  return StaggeredListItem(
                    index: index,
                    child: VetCard(
                      vet: vet,
                      source: 'explore',
                      onTap: () => context.push('/vets/${vet.id}?src=explore'),
                    ),
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
    required this.onPetType,
    required this.onSort,
    required this.onRetry,
    required this.showNearbyItems,
  });

  final ExploreStoresFilters filters;
  final AsyncValue<List<Store>> asyncList;
  final VoidCallback onToggleOpen;
  final ValueChanged<String?> onType;
  final ValueChanged<double?> onDistance;
  final ValueChanged<PetType?> onPetType;
  final ValueChanged<String> onSort;
  final VoidCallback onRetry;
  final bool showNearbyItems;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _FilterChipRow(
                children: [
                  _gapChip(
                    FilterChip(
                      label: Text(l10n.exploreFilterOpenNow),
                      selected: filters.openNow,
                      onSelected: (_) => onToggleOpen(),
                    ),
                  ),
                  _gapChip(
                    FilterChip(
                      label: Text(l10n.exploreFilterPetStore),
                      selected: filters.type == 'Pet Store',
                      onSelected: (s) => onType(s ? 'Pet Store' : null),
                    ),
                  ),
                  _gapChip(
                    FilterChip(
                      label: Text(l10n.exploreFilterGrooming),
                      selected: filters.type == 'Grooming',
                      onSelected: (s) => onType(s ? 'Grooming' : null),
                    ),
                  ),
                  _gapChip(
                    FilterChip(
                      label: Text(l10n.exploreFilterUnder10km),
                      selected: filters.maxDistanceKm == 10,
                      onSelected: (s) => onDistance(s ? 10 : null),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsetsDirectional.only(end: 20),
              child: _SortMenuButton(value: filters.sort, onChanged: onSort),
            ),
          ],
        ),
        _PetTypeChipRow(selected: filters.petType, onSelected: onPetType),
        Expanded(
          child: asyncList.when(
            skipLoadingOnReload: true,
            skipLoadingOnRefresh: true,
            loading: () => ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              children: [
                if (showNearbyItems)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 16),
                    child: NearbyStoreItemsSection(source: 'explore'),
                  ),
                const ListingCardSkeleton(count: 4),
              ],
            ),
            error: (error, stackTrace) => AsyncErrorView(
              error: error,
              onRetry: onRetry,
            ),
            data: (items) {
              if (items.isEmpty) {
                final q = filters.search.trim();
                return ListView(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                  children: [
                    if (showNearbyItems)
                      const Padding(
                        padding: EdgeInsets.only(bottom: 16),
                        child: NearbyStoreItemsSection(source: 'explore'),
                      ),
                    EmptyState(
                      title: q.isNotEmpty
                          ? l10n.exploreNoStoresMatchQuery(q)
                          : l10n.exploreNoStoresMatchFilters,
                      message: q.isNotEmpty
                          ? l10n.exploreTryAnotherArea
                          : l10n.exploreAdjustFilters,
                      icon: Icons.storefront_outlined,
                    ),
                  ],
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                itemCount: items.length + (showNearbyItems ? 1 : 0),
                itemBuilder: (context, index) {
                  if (showNearbyItems && index == 0) {
                    return const Padding(
                      padding: EdgeInsets.only(bottom: 16),
                      child: NearbyStoreItemsSection(source: 'explore'),
                    );
                  }
                  final store = items[showNearbyItems ? index - 1 : index];
                  return StaggeredListItem(
                    index: index,
                    child: StoreCard(
                      store: store,
                      source: 'explore',
                      onTap: () =>
                          context.push('/stores/${store.id}?src=explore'),
                    ),
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
