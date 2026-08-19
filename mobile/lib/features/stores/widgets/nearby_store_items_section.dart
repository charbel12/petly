import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/async_error_view.dart';
import '../../../core/widgets/section_header.dart';
import '../providers/stores_providers.dart';
import 'store_item_sheet.dart';
import 'store_items_grid.dart';

class NearbyStoreItemsSection extends ConsumerWidget {
  const NearbyStoreItemsSection({
    super.key,
    this.source = 'home',
  });

  final String source;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(nearestStoreItemsProvider);
    return async.when(
      skipLoadingOnReload: true,
      skipLoadingOnRefresh: true,
      loading: () => const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(title: 'From a nearby store'),
          SizedBox(height: 12),
          StoreItemsGridSkeleton(),
        ],
      ),
      error: (error, _) => AsyncErrorView(
        error: error,
        onRetry: () => ref.invalidate(nearestStoreItemsProvider),
        compact: true,
      ),
      data: (payload) {
        if (payload.isEmpty) return const SizedBox.shrink();
        final store = payload.store!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(
              title: 'From ${store.name}',
              actionLabel: 'See store',
              onAction: () => context.push('/stores/${store.id}?src=$source'),
            ),
            const SizedBox(height: 12),
            StoreItemsGrid(
              items: payload.items,
              onItemTap: (item) => showStoreItemSheet(
                context: context,
                ref: ref,
                item: item,
                store: store,
                source: '$source-item',
              ),
            ),
          ],
        );
      },
    );
  }
}
