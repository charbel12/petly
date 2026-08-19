import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/utils/api_error.dart';
import '../../../core/widgets/async_error_view.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/petly_background.dart';
import '../../../core/widgets/soft_card.dart';
import '../../../core/providers/app_providers.dart';
import '../../../data/models/store_item.dart';
import '../providers/partner_providers.dart';

class StoreItemsScreen extends ConsumerWidget {
  const StoreItemsScreen({super.key, required this.storeId});

  final String storeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync = ref.watch(partnerStoreItemsProvider(storeId));
    final tokens = AppTokens.of(context);

    return PetlyBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: const Text('Store items')),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => context.push('/partner/stores/$storeId/items/new'),
          icon: const Icon(Icons.add_rounded),
          label: const Text('Add item'),
        ),
        body: itemsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => AsyncErrorView(
            error: error,
            onRetry: () => ref.invalidate(partnerStoreItemsProvider(storeId)),
          ),
          data: (items) {
            if (items.isEmpty) {
              return EmptyState(
                icon: Icons.inventory_2_outlined,
                title: 'No items yet',
                message: 'Add products this store sells. They show on Home and the store page.',
              );
            }
            return RefreshIndicator(
              color: tokens.brandPrimary,
              onRefresh: () async =>
                  ref.invalidate(partnerStoreItemsProvider(storeId)),
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 96),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return SoftCard(
                    margin: const EdgeInsets.only(bottom: 10),
                    onTap: () => context.push(
                      '/partner/stores/$storeId/items/${item.id}/edit',
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.name,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${item.priceLabel} · ${item.inStock ? 'In stock' : 'Out of stock'}',
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          tooltip: 'Delete',
                          onPressed: () => _confirmDelete(context, ref, item),
                          icon: const Icon(Icons.delete_outline_rounded),
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    StoreItem item,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete this item?'),
        content: Text('“${item.name}” will be removed from the store catalog.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    try {
      await ref.read(partnersRepositoryProvider).deleteStoreItem(storeId, item.id);
      ref.invalidate(partnerStoreItemsProvider(storeId));
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(friendlyErrorMessage(error))),
      );
    }
  }
}
