import 'package:flutter/material.dart';
import '../../../core/widgets/skeleton.dart';
import '../../../data/models/store_item.dart';
import 'store_item_card.dart';

class StoreItemsGrid extends StatelessWidget {
  const StoreItemsGrid({
    super.key,
    required this.items,
    required this.onItemTap,
  });

  final List<StoreItem> items;
  final ValueChanged<StoreItem> onItemTap;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.72,
      ),
      itemBuilder: (context, index) {
        final item = items[index];
        return StoreItemCard(
          item: item,
          onTap: () => onItemTap(item),
        );
      },
    );
  }
}

class StoreItemsGridSkeleton extends StatelessWidget {
  const StoreItemsGridSkeleton({super.key, this.count = 4});

  final int count;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 0.72,
      children: List.generate(count, (_) => const _GridItemSkeleton()),
    );
  }
}

class _GridItemSkeleton extends StatelessWidget {
  const _GridItemSkeleton();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Expanded(
            child: ShimmerBox(height: double.infinity, borderRadius: 0),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerBox(width: 110, height: 14),
                SizedBox(height: 8),
                ShimmerBox(width: 72, height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
