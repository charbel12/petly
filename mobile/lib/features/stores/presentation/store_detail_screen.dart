import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/pet_taxonomy.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/providers/user_provider.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/utils/whatsapp.dart';
import '../../../core/widgets/async_error_view.dart';
import '../../../core/widgets/favorite_button.dart';
import '../../../core/widgets/hours_schedule.dart';
import '../../../core/widgets/listing_image.dart';
import '../../../core/widgets/skeleton.dart';
import '../../../core/widgets/soft_card.dart';
import '../../../core/widgets/star_rating.dart';
import '../../reviews/presentation/reviews_section.dart';
import '../providers/stores_providers.dart';
import '../widgets/store_item_sheet.dart';
import '../widgets/store_items_grid.dart';

class StoreDetailScreen extends ConsumerStatefulWidget {
  const StoreDetailScreen({
    super.key,
    required this.storeId,
    this.heroSource = 'list',
  });

  final String storeId;
  final String heroSource;

  @override
  ConsumerState<StoreDetailScreen> createState() => _StoreDetailScreenState();
}

class _StoreDetailScreenState extends ConsumerState<StoreDetailScreen> {
  ItemCategory? _category;
  PetType? _petType;
  String _itemsSort = 'default';

  static const _itemsSortLabels = {
    'default': 'Featured',
    'price_asc': 'Price: low to high',
    'price_desc': 'Price: high to low',
  };

  IconData _iconForType(String type) {
    final t = type.toLowerCase();
    if (t.contains('groom')) return Icons.content_cut_rounded;
    if (t.contains('aqua')) return Icons.water_rounded;
    return Icons.storefront_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final storeId = widget.storeId;
    final heroSource = widget.heroSource;
    final storeAsync = ref.watch(storeDetailProvider(storeId));
    final itemsFilter = (
      storeId: storeId,
      category: _category,
      petType: _petType,
      sort: _itemsSort,
    );
    final itemsAsync = ref.watch(storeItemsProvider(itemsFilter));
    final tokens = AppTokens.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Store details'),
        actions: [
          FavoriteButton(entityType: 'store', entityId: storeId),
        ],
      ),
      body: storeAsync.when(
        loading: () => const Padding(
          padding: EdgeInsets.all(20),
          child: ListingCardSkeleton(count: 1),
        ),
        error: (error, stackTrace) => AsyncErrorView(
          error: error,
          onRetry: () => ref.invalidate(storeDetailProvider(storeId)),
        ),
        data: (store) {
          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: AspectRatio(
                        aspectRatio: 16 / 9,
                        child: ListingImage(
                          imageUrl: store.imageUrl,
                          heroTag: '${store.heroTag}-$heroSource',
                          placeholderIcon: _iconForType(store.type),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SoftCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            store.name,
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 6),
                          StarRatingDisplay(
                            rating: store.avgRating,
                            count: store.ratingCount,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            store.type,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: tokens.brandSecondary,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Icon(Icons.place_outlined, color: tokens.onCard),
                              const SizedBox(width: 8),
                              Expanded(child: Text(store.location)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.near_me_outlined, color: tokens.onCard),
                              const SizedBox(width: 8),
                              Text(store.distanceAndLocation),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.schedule_rounded, color: tokens.onCard),
                              const SizedBox(width: 8),
                              Text(store.isOpenNow ? 'Open now' : 'Closed'),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (store.hours != null) ...[
                      const SizedBox(height: 20),
                      HoursScheduleCard(hours: store.hours!),
                    ],
                    if (store.services.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      Text(
                        'Services',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 10),
                      SoftCard(
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: store.services
                              .map(
                                (s) => Chip(
                                  label: Text(
                                    s,
                                    style: TextStyle(color: tokens.onCard),
                                  ),
                                  backgroundColor:
                                      tokens.onCard.withValues(alpha: 0.14),
                                  side: BorderSide.none,
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'In this store',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ),
                        PopupMenuButton<String>(
                          initialValue: _itemsSort,
                          tooltip: 'Sort by',
                          onSelected: (sort) =>
                              setState(() => _itemsSort = sort),
                          itemBuilder: (context) => _itemsSortLabels.entries
                              .map(
                                (entry) => PopupMenuItem<String>(
                                  value: entry.key,
                                  child: Text(entry.value),
                                ),
                              )
                              .toList(),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(color: tokens.border),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.sort_rounded,
                                  size: 16,
                                  color: tokens.onCardMuted,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _itemsSortLabels[_itemsSort] ?? 'Sort',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(color: tokens.onCardMuted),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          ChoiceChip(
                            label: const Text('All categories'),
                            selected: _category == null,
                            onSelected: (_) =>
                                setState(() => _category = null),
                          ),
                          const SizedBox(width: 8),
                          for (final category in ItemCategory.values)
                            Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ChoiceChip(
                                avatar: Icon(category.icon, size: 16),
                                label: Text(category.label),
                                selected: _category == category,
                                onSelected: (isSelected) => setState(
                                  () => _category =
                                      isSelected ? category : null,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          ChoiceChip(
                            label: const Text('All pets'),
                            selected: _petType == null,
                            onSelected: (_) =>
                                setState(() => _petType = null),
                          ),
                          const SizedBox(width: 8),
                          for (final type in [
                            PetType.dog,
                            PetType.cat,
                            PetType.bird,
                            PetType.fish,
                            PetType.rabbit,
                          ])
                            Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ChoiceChip(
                                avatar: Icon(type.icon, size: 16),
                                label: Text(type.label),
                                selected: _petType == type,
                                onSelected: (isSelected) => setState(
                                  () => _petType = isSelected ? type : null,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    itemsAsync.when(
                      skipLoadingOnReload: true,
                      skipLoadingOnRefresh: true,
                      loading: () => const StoreItemsGridSkeleton(count: 4),
                      error: (error, _) => AsyncErrorView(
                        error: error,
                        onRetry: () =>
                            ref.invalidate(storeItemsProvider(itemsFilter)),
                        compact: true,
                      ),
                      data: (items) {
                        if (items.isEmpty) {
                          return Text(
                            'This store has not listed items yet.',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: tokens.onCardMuted,
                                ),
                          );
                        }
                        return StoreItemsGrid(
                          items: items,
                          onItemTap: (item) => showStoreItemSheet(
                            context: context,
                            ref: ref,
                            item: item,
                            store: store,
                            source: 'store-item',
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    ReviewsSection(entityType: 'store', entityId: store.id),
                  ],
                ),
              ),
              if (store.phone != null)
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final user = ref.read(currentUserProvider).asData?.value;
                        final deviceId = await ref.read(deviceIdProvider.future);
                        final ok = await WhatsAppService.openChat(
                          phone: store.phone!,
                          analytics: ref.read(analyticsRepositoryProvider),
                          entityType: 'store',
                          entityId: store.id,
                          userId: user?.id,
                          deviceId: deviceId,
                          source: 'detail',
                        );
                        if (!context.mounted) return;
                        if (!ok) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Could not open WhatsApp'),
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.chat_rounded),
                      label: const Text('Chat on WhatsApp'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(AppConstants.whatsappGreen),
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(56),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
