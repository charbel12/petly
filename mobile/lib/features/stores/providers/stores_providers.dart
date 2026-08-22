import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/pet_taxonomy.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/providers/location_provider.dart';
import '../../../data/models/store.dart';
import '../../../data/models/store_item.dart';

final featuredStoresProvider = FutureProvider<List<Store>>((ref) async {
  final repo = ref.watch(storesRepositoryProvider);
  return repo.list(
    featured: true,
    lat: ref.watch(userLatProvider),
    lng: ref.watch(userLngProvider),
  );
});

class ExploreStoresFilters {
  const ExploreStoresFilters({
    this.search = '',
    this.type,
    this.openNow = false,
    this.maxDistanceKm,
    this.petType,
    this.sort = 'distance',
  });

  final String search;
  final String? type;
  final bool openNow;
  final double? maxDistanceKm;
  final PetType? petType;

  /// 'distance' (default) | 'rating' | 'name'.
  final String sort;

  ExploreStoresFilters copyWith({
    String? search,
    String? type,
    bool? openNow,
    double? maxDistanceKm,
    PetType? petType,
    String? sort,
    bool clearType = false,
    bool clearDistance = false,
    bool clearPetType = false,
  }) {
    return ExploreStoresFilters(
      search: search ?? this.search,
      type: clearType ? null : (type ?? this.type),
      openNow: openNow ?? this.openNow,
      maxDistanceKm:
          clearDistance ? null : (maxDistanceKm ?? this.maxDistanceKm),
      petType: clearPetType ? null : (petType ?? this.petType),
      sort: sort ?? this.sort,
    );
  }
}

class ExploreStoresFiltersNotifier extends Notifier<ExploreStoresFilters> {
  @override
  ExploreStoresFilters build() => const ExploreStoresFilters();

  void setSearch(String value) {
    if (state.search == value) return;
    state = state.copyWith(search: value);
  }
  void toggleOpenNow() => state = state.copyWith(openNow: !state.openNow);
  void setType(String? type) =>
      state = state.copyWith(type: type, clearType: type == null);
  void setMaxDistance(double? km) =>
      state = state.copyWith(maxDistanceKm: km, clearDistance: km == null);
  void setPetType(PetType? petType) => state =
      state.copyWith(petType: petType, clearPetType: petType == null);
  void setSort(String sort) => state = state.copyWith(sort: sort);
}

final exploreStoresFiltersProvider =
    NotifierProvider<ExploreStoresFiltersNotifier, ExploreStoresFilters>(
  ExploreStoresFiltersNotifier.new,
);

final exploreStoresProvider = FutureProvider<List<Store>>((ref) async {
  final filters = ref.watch(exploreStoresFiltersProvider);
  final repo = ref.watch(storesRepositoryProvider);
  return repo.list(
    search: filters.search,
    type: filters.type,
    openNow: filters.openNow ? true : null,
    maxDistanceKm: filters.maxDistanceKm,
    petType: filters.petType?.apiValue,
    sort: filters.sort,
    lat: ref.watch(userLatProvider),
    lng: ref.watch(userLngProvider),
  );
});

final storeDetailProvider =
    FutureProvider.autoDispose.family<Store, String>((ref, id) async {
  final repo = ref.watch(storesRepositoryProvider);
  return repo.getById(
    id,
    lat: ref.watch(userLatProvider),
    lng: ref.watch(userLngProvider),
  );
});

final nearestStoreItemsProvider =
    FutureProvider<NearestStoreItems>((ref) async {
  final repo = ref.watch(storesRepositoryProvider);
  return repo.nearestItems(
    lat: ref.watch(userLatProvider),
    lng: ref.watch(userLngProvider),
  );
});

/// Filter key for [storeItemsProvider] — a record so screens can vary the
/// category/pet-type chips without introducing a separate Notifier per screen.
typedef StoreItemsFilter = ({
  String storeId,
  ItemCategory? category,
  PetType? petType,
  String sort,
});

final storeItemsProvider = FutureProvider.autoDispose
    .family<List<StoreItem>, StoreItemsFilter>((ref, filter) async {
  final repo = ref.watch(storesRepositoryProvider);
  return repo.listItems(
    filter.storeId,
    category: filter.category?.apiValue,
    petType: filter.petType?.apiValue,
    sort: filter.sort,
  );
});
