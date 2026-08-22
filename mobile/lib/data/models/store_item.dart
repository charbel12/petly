import 'package:intl/intl.dart';
import '../../core/constants/pet_taxonomy.dart';
import 'store.dart';

class StoreItem {
  const StoreItem({
    required this.id,
    required this.storeId,
    required this.name,
    required this.currency,
    required this.inStock,
    this.description,
    this.price,
    this.imageUrl,
    this.sortOrder = 0,
    this.category = ItemCategory.other,
    this.petTypes = const [],
  });

  final String id;
  final String storeId;
  final String name;
  final String? description;
  final double? price;
  final String currency;
  final String? imageUrl;
  final bool inStock;
  final int sortOrder;
  final ItemCategory category;
  final List<PetType> petTypes;

  factory StoreItem.fromJson(Map<String, dynamic> json) {
    return StoreItem(
      id: json['id'] as String,
      storeId: json['store_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      price: (json['price'] as num?)?.toDouble(),
      currency: json['currency'] as String? ?? 'USD',
      imageUrl: json['image_url'] as String?,
      inStock: json['in_stock'] as bool? ?? true,
      sortOrder: json['sort_order'] as int? ?? 0,
      category: ItemCategoryX.fromApi(json['category'] as String?),
      petTypes: petTypesFromJson(json['pet_types']),
    );
  }

  String get priceLabel {
    if (price == null) return 'Ask in store';
    if (currency == 'LBP') {
      return 'LBP ${NumberFormat('#,##0').format(price)}';
    }
    return NumberFormat.simpleCurrency(name: 'USD').format(price);
  }
}

class NearestStoreItems {
  const NearestStoreItems({this.store, this.items = const []});

  final Store? store;
  final List<StoreItem> items;

  bool get isEmpty => items.isEmpty || store == null;

  factory NearestStoreItems.fromJson(Map<String, dynamic> json) {
    final storeJson = json['store'];
    return NearestStoreItems(
      store: storeJson is Map<String, dynamic> ? Store.fromJson(storeJson) : null,
      items: (json['items'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(StoreItem.fromJson)
          .toList(),
    );
  }
}
