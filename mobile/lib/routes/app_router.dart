import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/providers/auth_provider.dart';
import '../features/auth/presentation/forgot_password_screen.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/register_screen.dart';
import '../features/explore/presentation/explore_screen.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/partner/presentation/listing_form_screen.dart';
import '../features/partner/presentation/partner_dashboard_screen.dart';
import '../features/partner/presentation/store_item_form_screen.dart';
import '../features/partner/presentation/store_items_screen.dart';
import '../features/pets/presentation/add_pet_screen.dart';
import '../features/pets/presentation/pets_screen.dart';
import '../features/profile/presentation/profile_screen.dart';
import '../features/stores/presentation/store_detail_screen.dart';
import '../features/vets/presentation/vet_detail_screen.dart';
import 'shell_screen.dart';

final _rootKey = GlobalKey<NavigatorState>();

CustomTransitionPage<void> _fadeSlidePage({
  required LocalKey key,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: key,
    child: child,
    transitionDuration: const Duration(milliseconds: 280),
    reverseTransitionDuration: const Duration(milliseconds: 220),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      );
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.04),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        ),
      );
    },
  );
}

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = ValueNotifier<int>(0);
  ref.listen(authProvider, (_, _) {
    refresh.value++;
  });
  ref.onDispose(refresh.dispose);

  return GoRouter(
    navigatorKey: _rootKey,
    initialLocation: '/home',
    refreshListenable: refresh,
    redirect: (context, state) {
      final auth = ref.read(authProvider);
      if (auth.isLoading) return null;
      final loggedIn = auth.asData?.value != null;
      final role = auth.asData?.value?.role;
      final loc = state.matchedLocation;
      final onAuthPage = loc == '/login' ||
          loc == '/register' ||
          loc == '/forgot-password';
      if (loggedIn && onAuthPage) return '/home';
      if (loc.startsWith('/partner')) {
        if (!loggedIn) return '/login';
        if (role != 'partner') return '/profile';
      }
      return null;
    },
    routes: [
      GoRoute(
        parentNavigatorKey: _rootKey,
        path: '/login',
        name: 'login',
        pageBuilder: (context, state) => _fadeSlidePage(
          key: state.pageKey,
          child: const LoginScreen(),
        ),
      ),
      GoRoute(
        parentNavigatorKey: _rootKey,
        path: '/register',
        name: 'register',
        pageBuilder: (context, state) => _fadeSlidePage(
          key: state.pageKey,
          child: const RegisterScreen(),
        ),
      ),
      GoRoute(
        parentNavigatorKey: _rootKey,
        path: '/forgot-password',
        name: 'forgot-password',
        pageBuilder: (context, state) => _fadeSlidePage(
          key: state.pageKey,
          child: const ForgotPasswordScreen(),
        ),
      ),
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
        pageBuilder: (context, state) {
          final id = state.pathParameters['id']!;
          final src = state.uri.queryParameters['src'] ?? 'list';
          return _fadeSlidePage(
            key: state.pageKey,
            child: VetDetailScreen(vetId: id, heroSource: src),
          );
        },
      ),
      GoRoute(
        parentNavigatorKey: _rootKey,
        path: '/stores/:id',
        name: 'store-detail',
        pageBuilder: (context, state) {
          final id = state.pathParameters['id']!;
          final src = state.uri.queryParameters['src'] ?? 'list';
          return _fadeSlidePage(
            key: state.pageKey,
            child: StoreDetailScreen(storeId: id, heroSource: src),
          );
        },
      ),
      GoRoute(
        parentNavigatorKey: _rootKey,
        path: '/pets/add',
        name: 'add-pet',
        pageBuilder: (context, state) => _fadeSlidePage(
          key: state.pageKey,
          child: const AddPetScreen(),
        ),
      ),
      GoRoute(
        parentNavigatorKey: _rootKey,
        path: '/partner',
        name: 'partner-dashboard',
        pageBuilder: (context, state) => _fadeSlidePage(
          key: state.pageKey,
          child: const PartnerDashboardScreen(),
        ),
      ),
      GoRoute(
        parentNavigatorKey: _rootKey,
        path: '/partner/vets/new',
        name: 'partner-vet-new',
        pageBuilder: (context, state) => _fadeSlidePage(
          key: state.pageKey,
          child: const ListingFormScreen(kind: PartnerListingKind.vet),
        ),
      ),
      GoRoute(
        parentNavigatorKey: _rootKey,
        path: '/partner/vets/:id/edit',
        name: 'partner-vet-edit',
        pageBuilder: (context, state) => _fadeSlidePage(
          key: state.pageKey,
          child: ListingFormScreen(
            kind: PartnerListingKind.vet,
            listingId: state.pathParameters['id'],
          ),
        ),
      ),
      GoRoute(
        parentNavigatorKey: _rootKey,
        path: '/partner/stores/new',
        name: 'partner-store-new',
        pageBuilder: (context, state) => _fadeSlidePage(
          key: state.pageKey,
          child: const ListingFormScreen(kind: PartnerListingKind.store),
        ),
      ),
      GoRoute(
        parentNavigatorKey: _rootKey,
        path: '/partner/stores/:id/items/new',
        name: 'partner-store-item-new',
        pageBuilder: (context, state) => _fadeSlidePage(
          key: state.pageKey,
          child: StoreItemFormScreen(
            storeId: state.pathParameters['id']!,
          ),
        ),
      ),
      GoRoute(
        parentNavigatorKey: _rootKey,
        path: '/partner/stores/:id/items/:itemId/edit',
        name: 'partner-store-item-edit',
        pageBuilder: (context, state) => _fadeSlidePage(
          key: state.pageKey,
          child: StoreItemFormScreen(
            storeId: state.pathParameters['id']!,
            itemId: state.pathParameters['itemId'],
          ),
        ),
      ),
      GoRoute(
        parentNavigatorKey: _rootKey,
        path: '/partner/stores/:id/items',
        name: 'partner-store-items',
        pageBuilder: (context, state) => _fadeSlidePage(
          key: state.pageKey,
          child: StoreItemsScreen(storeId: state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        parentNavigatorKey: _rootKey,
        path: '/partner/stores/:id/edit',
        name: 'partner-store-edit',
        pageBuilder: (context, state) => _fadeSlidePage(
          key: state.pageKey,
          child: ListingFormScreen(
            kind: PartnerListingKind.store,
            listingId: state.pathParameters['id'],
          ),
        ),
      ),
    ],
  );
});
