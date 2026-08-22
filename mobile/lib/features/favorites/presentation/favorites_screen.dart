import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/async_error_view.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/motion.dart';
import '../../../core/widgets/petly_background.dart';
import '../../../core/widgets/skeleton.dart';
import '../../../l10n/app_localizations.dart';
import '../../stores/widgets/store_card.dart';
import '../../vets/widgets/vet_card.dart';
import '../providers/favorites_providers.dart';

class FavoritesScreen extends ConsumerStatefulWidget {
  const FavoritesScreen({super.key});

  @override
  ConsumerState<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends ConsumerState<FavoritesScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = AppTokens.of(context);
    final l10n = AppLocalizations.of(context)!;
    final storesAsync = ref.watch(favoriteStoresProvider);
    final vetsAsync = ref.watch(favoriteVetsProvider);

    return PetlyBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(l10n.favoritesTitle),
          bottom: TabBar(
            controller: _tabController,
            labelColor: tokens.brandPrimary,
            unselectedLabelColor: tokens.textMuted,
            indicatorColor: tokens.brandPrimary,
            tabs: [
              Tab(text: l10n.favoritesTabStores),
              Tab(text: l10n.favoritesTabVets),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            storesAsync.when(
              skipLoadingOnReload: true,
              skipLoadingOnRefresh: true,
              loading: () => const Padding(
                padding: EdgeInsets.fromLTRB(20, 8, 20, 24),
                child: ListingCardSkeleton(count: 4),
              ),
              error: (error, stackTrace) => AsyncErrorView(
                error: error,
                onRetry: () => ref.invalidate(favoriteStoresProvider),
              ),
              data: (stores) {
                if (stores.isEmpty) {
                  return EmptyState(
                    title: l10n.favoritesNoStoresTitle,
                    message: l10n.favoritesNoStoresMessage,
                    icon: Icons.storefront_outlined,
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                  itemCount: stores.length,
                  itemBuilder: (context, index) {
                    final store = stores[index];
                    return StaggeredListItem(
                      index: index,
                      child: StoreCard(
                        store: store,
                        source: 'favorites',
                        onTap: () =>
                            context.push('/stores/${store.id}?src=favorites'),
                      ),
                    );
                  },
                );
              },
            ),
            vetsAsync.when(
              skipLoadingOnReload: true,
              skipLoadingOnRefresh: true,
              loading: () => const Padding(
                padding: EdgeInsets.fromLTRB(20, 8, 20, 24),
                child: ListingCardSkeleton(count: 4),
              ),
              error: (error, stackTrace) => AsyncErrorView(
                error: error,
                onRetry: () => ref.invalidate(favoriteVetsProvider),
              ),
              data: (vets) {
                if (vets.isEmpty) {
                  return EmptyState(
                    title: l10n.favoritesNoVetsTitle,
                    message: l10n.favoritesNoVetsMessage,
                    icon: Icons.local_hospital_outlined,
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                  itemCount: vets.length,
                  itemBuilder: (context, index) {
                    final vet = vets[index];
                    return StaggeredListItem(
                      index: index,
                      child: VetCard(
                        vet: vet,
                        source: 'favorites',
                        onTap: () =>
                            context.push('/vets/${vet.id}?src=favorites'),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
