import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petly/core/providers/app_providers.dart';
import 'package:petly/core/providers/auth_provider.dart';
import 'package:petly/core/utils/api_error.dart';
import 'package:petly/core/widgets/favorite_button.dart';
import 'package:petly/data/models/store.dart';
import 'package:petly/data/models/vet.dart';
import 'package:petly/data/repositories/favorites_repository.dart';
import 'package:petly/features/favorites/providers/favorites_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Test double that mimics [FavoritesRepository] without hitting the network.
class _FakeFavoritesRepository implements FavoritesRepository {
  FavoriteIds ids = const FavoriteIds();
  bool failNext = false;
  final List<String> calls = [];

  @override
  Future<FavoriteIds> listIds() async => ids;

  @override
  Future<List<Store>> listStores({double? lat, double? lng}) async => const [];

  @override
  Future<List<Vet>> listVets({double? lat, double? lng}) async => const [];

  @override
  Future<void> add(String entityType, String entityId) async {
    calls.add('add:$entityType:$entityId');
    if (failNext) throw ApiException('Could not save favorite');
  }

  @override
  Future<void> remove(String entityType, String entityId) async {
    calls.add('remove:$entityType:$entityId');
    if (failNext) throw ApiException('Could not remove favorite');
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});
  });

  group('FavoritesController', () {
    test('toggleStore optimistically updates and rolls back on failure',
        () async {
      final fake = _FakeFavoritesRepository();
      final container = ProviderContainer(
        overrides: [favoritesRepositoryProvider.overrideWithValue(fake)],
      );
      addTearDown(container.dispose);

      // Let auth settle first so its resolution doesn't trigger a
      // favoriteIdsProvider rebuild (it watches authProvider) in the middle
      // of the optimistic-update assertions below.
      await container.read(authProvider.future);
      final initial = await container.read(favoriteIdsProvider.future);
      expect(initial.storeIds, isEmpty);

      final notifier = container.read(favoriteIdsProvider.notifier);
      final toggleFuture = notifier.toggleStore('store-1');
      // The optimistic update happens synchronously, before the network call
      // resolves.
      expect(
        container.read(favoriteIdsProvider).value?.storeIds,
        contains('store-1'),
      );
      await toggleFuture;
      expect(
        container.read(favoriteIdsProvider).value?.storeIds,
        contains('store-1'),
      );
      expect(fake.calls, contains('add:store:store-1'));

      // Now force the next call to fail and toggle again (unfavorite).
      fake.failNext = true;
      await expectLater(
        notifier.toggleStore('store-1'),
        throwsA(isA<ApiException>()),
      );
      // Rolled back to the favorited state from before the failed attempt.
      expect(
        container.read(favoriteIdsProvider).value?.storeIds,
        contains('store-1'),
      );
    });
  });

  group('FavoriteButton', () {
    testWidgets('tap toggles icon and calls the repository', (tester) async {
      final fake = _FakeFavoritesRepository();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [favoritesRepositoryProvider.overrideWithValue(fake)],
          child: const MaterialApp(
            home: Scaffold(
              body: FavoriteButton(entityType: 'store', entityId: 'store-1'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.favorite_border_rounded), findsOneWidget);
      expect(find.byIcon(Icons.favorite_rounded), findsNothing);

      await tester.tap(find.byType(IconButton));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.favorite_rounded), findsOneWidget);
      expect(find.byIcon(Icons.favorite_border_rounded), findsNothing);
      expect(fake.calls, contains('add:store:store-1'));

      await tester.tap(find.byType(IconButton));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.favorite_border_rounded), findsOneWidget);
      expect(fake.calls, contains('remove:store:store-1'));
    });
  });
}
