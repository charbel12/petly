import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/location_provider.dart';
import '../../../data/models/store.dart';
import '../../../data/models/vet.dart';
import '../../../data/repositories/favorites_repository.dart';

/// Holds the set of favorited store/vet ids and exposes optimistic
/// toggle methods. Refetches whenever auth state changes (login/logout),
/// same as other user-scoped providers.
class FavoritesController extends AsyncNotifier<FavoriteIds> {
  @override
  Future<FavoriteIds> build() async {
    ref.watch(authProvider);
    return ref.read(favoritesRepositoryProvider).listIds();
  }

  Future<void> toggleStore(String id) => _toggle(
        entityType: 'store',
        id: id,
        isFavorited: (ids) => ids.storeIds.contains(id),
        apply: (ids, favorited) {
          final next = Set<String>.from(ids.storeIds);
          if (favorited) {
            next.add(id);
          } else {
            next.remove(id);
          }
          return ids.copyWith(storeIds: next);
        },
      );

  Future<void> toggleVet(String id) => _toggle(
        entityType: 'vet',
        id: id,
        isFavorited: (ids) => ids.vetIds.contains(id),
        apply: (ids, favorited) {
          final next = Set<String>.from(ids.vetIds);
          if (favorited) {
            next.add(id);
          } else {
            next.remove(id);
          }
          return ids.copyWith(vetIds: next);
        },
      );

  Future<void> _toggle({
    required String entityType,
    required String id,
    required bool Function(FavoriteIds) isFavorited,
    required FavoriteIds Function(FavoriteIds, bool favorited) apply,
  }) async {
    final previous = state.asData?.value ?? const FavoriteIds();
    final wasFavorited = isFavorited(previous);
    final nextFavorited = !wasFavorited;

    state = AsyncData(apply(previous, nextFavorited));

    try {
      final repo = ref.read(favoritesRepositoryProvider);
      if (nextFavorited) {
        await repo.add(entityType, id);
      } else {
        await repo.remove(entityType, id);
      }
    } catch (error) {
      // Roll back the optimistic update and surface the error.
      state = AsyncData(previous);
      rethrow;
    }
  }
}

final favoriteIdsProvider =
    AsyncNotifierProvider<FavoritesController, FavoriteIds>(
  FavoritesController.new,
);

final favoriteStoresProvider = FutureProvider<List<Store>>((ref) async {
  final repo = ref.watch(favoritesRepositoryProvider);
  // Watching favoriteIdsProvider keeps this list in sync after a toggle.
  ref.watch(favoriteIdsProvider);
  return repo.listStores(
    lat: ref.watch(userLatProvider),
    lng: ref.watch(userLngProvider),
  );
});

final favoriteVetsProvider = FutureProvider<List<Vet>>((ref) async {
  final repo = ref.watch(favoritesRepositoryProvider);
  ref.watch(favoriteIdsProvider);
  return repo.listVets(
    lat: ref.watch(userLatProvider),
    lng: ref.watch(userLngProvider),
  );
});
