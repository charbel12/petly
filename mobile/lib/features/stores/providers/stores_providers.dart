import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/providers/location_provider.dart';
import '../../../data/models/store.dart';

final featuredStoresProvider =
    FutureProvider.autoDispose<List<Store>>((ref) async {
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
  });

  final String search;
  final String? type;
  final bool openNow;
  final double? maxDistanceKm;

  ExploreStoresFilters copyWith({
    String? search,
    String? type,
    bool? openNow,
    double? maxDistanceKm,
    bool clearType = false,
    bool clearDistance = false,
  }) {
    return ExploreStoresFilters(
      search: search ?? this.search,
      type: clearType ? null : (type ?? this.type),
      openNow: openNow ?? this.openNow,
      maxDistanceKm:
          clearDistance ? null : (maxDistanceKm ?? this.maxDistanceKm),
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
}

final exploreStoresFiltersProvider =
    NotifierProvider<ExploreStoresFiltersNotifier, ExploreStoresFilters>(
  ExploreStoresFiltersNotifier.new,
);

final exploreStoresProvider =
    FutureProvider.autoDispose<List<Store>>((ref) async {
  final filters = ref.watch(exploreStoresFiltersProvider);
  final repo = ref.watch(storesRepositoryProvider);
  return repo.list(
    search: filters.search,
    type: filters.type,
    openNow: filters.openNow ? true : null,
    maxDistanceKm: filters.maxDistanceKm,
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
