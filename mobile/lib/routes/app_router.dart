import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/explore/presentation/explore_screen.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/pets/presentation/add_pet_screen.dart';
import '../features/pets/presentation/pets_screen.dart';
import '../features/profile/presentation/profile_screen.dart';
import '../features/stores/presentation/store_detail_screen.dart';
import '../features/vets/presentation/vet_detail_screen.dart';
import 'shell_screen.dart';

final _rootKey = GlobalKey<NavigatorState>();

GoRouter createRouter() {
  return GoRouter(
    navigatorKey: _rootKey,
    initialLocation: '/home',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ShellScreen(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                name: 'home',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/explore',
                name: 'explore',
                builder: (context, state) {
                  final tab = state.uri.queryParameters['tab'];
                  final initialTab = tab == 'stores' ? 1 : 0;
                  return ExploreScreen(initialTab: initialTab);
                },
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/pets',
                name: 'pets',
                builder: (context, state) => const PetsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                name: 'profile',
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        parentNavigatorKey: _rootKey,
        path: '/vets/:id',
        name: 'vet-detail',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return VetDetailScreen(vetId: id);
        },
      ),
      GoRoute(
        parentNavigatorKey: _rootKey,
        path: '/stores/:id',
        name: 'store-detail',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return StoreDetailScreen(storeId: id);
        },
      ),
      GoRoute(
        parentNavigatorKey: _rootKey,
        path: '/pets/add',
        name: 'add-pet',
        builder: (context, state) => const AddPetScreen(),
      ),
    ],
  );
}
