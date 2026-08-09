import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/providers/location_provider.dart';
import '../../../data/models/vet.dart';

final nearbyVetsProvider = FutureProvider.autoDispose<List<Vet>>((ref) async {
  final repo = ref.watch(vetsRepositoryProvider);
  return repo.list(
    lat: ref.watch(userLatProvider),
    lng: ref.watch(userLngProvider),
  );
});

final emergencyVetsProvider = FutureProvider.autoDispose<List<Vet>>((ref) async {
  final repo = ref.watch(vetsRepositoryProvider);
  return repo.emergency(
    lat: ref.watch(userLatProvider),
    lng: ref.watch(userLngProvider),
  );
});

final vetDetailProvider =
    FutureProvider.autoDispose.family<Vet, String>((ref, id) async {
  final repo = ref.watch(vetsRepositoryProvider);
  return repo.getById(
    id,
    lat: ref.watch(userLatProvider),
    lng: ref.watch(userLngProvider),
  );
});

class ExploreVetsFilters {
  const ExploreVetsFilters({
    this.search = '',
    this.openNow = false,
    this.maxDistanceKm,
  });

  final String search;
  final bool openNow;
  final double? maxDistanceKm;

  ExploreVetsFilters copyWith({
    String? search,
    bool? openNow,
    double? maxDistanceKm,
    bool clearDistance = false,
  }) {
    return ExploreVetsFilters(
      search: search ?? this.search,
      openNow: openNow ?? this.openNow,
      maxDistanceKm:
          clearDistance ? null : (maxDistanceKm ?? this.maxDistanceKm),
    );
  }
}

class ExploreVetsFiltersNotifier extends Notifier<ExploreVetsFilters> {
  @override
  ExploreVetsFilters build() => const ExploreVetsFilters();

  void setSearch(String value) => state = state.copyWith(search: value);
  void toggleOpenNow() => state = state.copyWith(openNow: !state.openNow);
  void setMaxDistance(double? km) =>
      state = state.copyWith(maxDistanceKm: km, clearDistance: km == null);
}

final exploreVetsFiltersProvider =
    NotifierProvider<ExploreVetsFiltersNotifier, ExploreVetsFilters>(
  ExploreVetsFiltersNotifier.new,
);

final exploreVetsProvider = FutureProvider.autoDispose<List<Vet>>((ref) async {
  final filters = ref.watch(exploreVetsFiltersProvider);
  final repo = ref.watch(vetsRepositoryProvider);
  return repo.list(
    search: filters.search,
    openNow: filters.openNow ? true : null,
    maxDistanceKm: filters.maxDistanceKm,
    lat: ref.watch(userLatProvider),
    lng: ref.watch(userLngProvider),
  );
});
