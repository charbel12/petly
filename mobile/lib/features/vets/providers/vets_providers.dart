import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/pet_taxonomy.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/providers/location_provider.dart';
import '../../../data/models/vet.dart';

final nearbyVetsProvider = FutureProvider<List<Vet>>((ref) async {
  final repo = ref.watch(vetsRepositoryProvider);
  return repo.list(
    lat: ref.watch(userLatProvider),
    lng: ref.watch(userLngProvider),
  );
});

final emergencyVetsProvider = FutureProvider<List<Vet>>((ref) async {
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
    this.emergency = false,
    this.maxDistanceKm,
    this.petType,
    this.sort = 'distance',
  });

  final String search;
  final bool openNow;
  final bool emergency;
  final double? maxDistanceKm;
  final PetType? petType;

  /// 'distance' (default) | 'rating' | 'name'.
  final String sort;

  ExploreVetsFilters copyWith({
    String? search,
    bool? openNow,
    bool? emergency,
    double? maxDistanceKm,
    PetType? petType,
    String? sort,
    bool clearDistance = false,
    bool clearPetType = false,
  }) {
    return ExploreVetsFilters(
      search: search ?? this.search,
      openNow: openNow ?? this.openNow,
      emergency: emergency ?? this.emergency,
      maxDistanceKm:
          clearDistance ? null : (maxDistanceKm ?? this.maxDistanceKm),
      petType: clearPetType ? null : (petType ?? this.petType),
      sort: sort ?? this.sort,
    );
  }
}

class ExploreVetsFiltersNotifier extends Notifier<ExploreVetsFilters> {
  @override
  ExploreVetsFilters build() => const ExploreVetsFilters();

  void setSearch(String value) {
    if (state.search == value) return;
    state = state.copyWith(search: value);
  }
  void toggleOpenNow() => state = state.copyWith(openNow: !state.openNow);
  void toggleEmergency() =>
      state = state.copyWith(emergency: !state.emergency);
  void setEmergency(bool value) =>
      state = state.copyWith(emergency: value);
  void setMaxDistance(double? km) =>
      state = state.copyWith(maxDistanceKm: km, clearDistance: km == null);
  void setPetType(PetType? petType) => state =
      state.copyWith(petType: petType, clearPetType: petType == null);
  void setSort(String sort) => state = state.copyWith(sort: sort);
}

final exploreVetsFiltersProvider =
    NotifierProvider<ExploreVetsFiltersNotifier, ExploreVetsFilters>(
  ExploreVetsFiltersNotifier.new,
);

final exploreVetsProvider = FutureProvider<List<Vet>>((ref) async {
  final filters = ref.watch(exploreVetsFiltersProvider);
  final repo = ref.watch(vetsRepositoryProvider);
  return repo.list(
    search: filters.search,
    openNow: filters.openNow ? true : null,
    emergency: filters.emergency ? true : null,
    maxDistanceKm: filters.maxDistanceKm,
    petType: filters.petType?.apiValue,
    sort: filters.sort,
    lat: ref.watch(userLatProvider),
    lng: ref.watch(userLngProvider),
  );
});
