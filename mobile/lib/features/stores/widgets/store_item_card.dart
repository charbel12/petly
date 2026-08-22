import 'package:flutter/material.dart';
import '../../../core/constants/pet_taxonomy.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/listing_image.dart';
import '../../../core/widgets/soft_card.dart';
import '../../../data/models/store_item.dart';

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({required this.item});

  final StoreItem item;

  @override
  Widget build(BuildContext context) {
    final tokens = AppTokens.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: tokens.brandPrimary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(item.category.icon, size: 12, color: tokens.brandPrimary),
          const SizedBox(width: 4),
          Text(
            item.category.label,
            style: TextStyle(
              color: tokens.brandPrimary,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class StoreItemCard extends StatelessWidget {
  const StoreItemCard({
    super.key,
    required this.item,
    this.onTap,
    this.compact = true,
  });

  final StoreItem item;
  final VoidCallback? onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final tokens = AppTokens.of(context);
    final image = AspectRatio(
      aspectRatio: 1,
      child: ListingImage(
        imageUrl: item.imageUrl,
        placeholderIcon: Icons.inventory_2_outlined,
      ),
    );

    final details = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item.name,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 4),
        _CategoryChip(item: item),
        const SizedBox(height: 4),
        Text(
          item.priceLabel,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: tokens.brandPrimary,
                fontWeight: FontWeight.w700,
              ),
        ),
        if (!item.inStock) ...[
          const SizedBox(height: 4),
          Text(
            'Out of stock',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: tokens.onCardMuted,
                ),
          ),
        ],
      ],
    );

    if (compact) {
      return SoftCard(
        onTap: onTap,
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: ListingImage(
                imageUrl: item.imageUrl,
                placeholderIcon: Icons.inventory_2_outlined,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                child: details,
              ),
            ),
          ],
        ),
      );
    }

    return SoftCard(
      onTap: onTap,
      padding: EdgeInsets.zero,
      margin: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          SizedBox(width: 92, child: image),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 14, 12),
              child: details,
            ),
          ),
        ],
      ),
    );
  }
}
