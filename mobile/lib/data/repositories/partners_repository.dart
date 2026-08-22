import '../../core/constants/pet_taxonomy.dart';
import '../api/api_client.dart';
import '../models/listing_hours.dart';
import '../models/store.dart';
import '../models/store_item.dart';
import '../models/vet.dart';

class PartnerListings {
  const PartnerListings({required this.vets, required this.stores});

  final List<Vet> vets;
  final List<Store> stores;

  bool get isEmpty => vets.isEmpty && stores.isEmpty;
}

class PartnersRepository {
  PartnersRepository(this._api);

  final ApiClient _api;

  Future<PartnerListings> listMine() async {
    final response = await _api.get<Map<String, dynamic>>('/partners/me/listings');
    final body = response.data ?? {};
    return PartnerListings(
      vets: (body['vets'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(Vet.fromJson)
          .toList(),
      stores: (body['stores'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(Store.fromJson)
          .toList(),
    );
  }

  Future<Vet> getVet(String id) async {
    final response = await _api.get<Map<String, dynamic>>('/partners/vets/$id');
    return Vet.fromJson(response.data!);
  }

  Future<Store> getStore(String id) async {
    final response = await _api.get<Map<String, dynamic>>('/partners/stores/$id');
    return Store.fromJson(response.data!);
  }

  Future<Vet> createVet(Map<String, dynamic> body) async {
    final response = await _api.post<Map<String, dynamic>>(
      '/partners/vets',
      data: body,
    );
    return Vet.fromJson(response.data!);
  }

  Future<Vet> updateVet(String id, Map<String, dynamic> body) async {
    final response = await _api.patch<Map<String, dynamic>>(
      '/partners/vets/$id',
      data: body,
    );
    return Vet.fromJson(response.data!);
  }

  Future<Store> createStore(Map<String, dynamic> body) async {
    final response = await _api.post<Map<String, dynamic>>(
      '/partners/stores',
      data: body,
    );
    return Store.fromJson(response.data!);
  }

  Future<Store> updateStore(String id, Map<String, dynamic> body) async {
    final response = await _api.patch<Map<String, dynamic>>(
      '/partners/stores/$id',
      data: body,
    );
    return Store.fromJson(response.data!);
  }

  Future<List<StoreItem>> listStoreItems(String storeId) async {
    final response = await _api.get<List<dynamic>>(
      '/partners/stores/$storeId/items',
    );
    return (response.data ?? [])
        .whereType<Map<String, dynamic>>()
        .map(StoreItem.fromJson)
        .toList();
  }

  Future<StoreItem> createStoreItem(
    String storeId,
    Map<String, dynamic> body,
  ) async {
    final response = await _api.post<Map<String, dynamic>>(
      '/partners/stores/$storeId/items',
      data: body,
    );
    return StoreItem.fromJson(response.data!);
  }

  Future<StoreItem> updateStoreItem(
    String storeId,
    String itemId,
    Map<String, dynamic> body,
  ) async {
    final response = await _api.patch<Map<String, dynamic>>(
      '/partners/stores/$storeId/items/$itemId',
      data: body,
    );
    return StoreItem.fromJson(response.data!);
  }

  Future<void> deleteStoreItem(String storeId, String itemId) async {
    await _api.delete('/partners/stores/$storeId/items/$itemId');
  }

  static Map<String, dynamic> storeItemPayload({
    required String name,
    String? description,
    double? price,
    String currency = 'USD',
    String? imageUrl,
    bool inStock = true,
    ItemCategory category = ItemCategory.other,
    List<PetType> petTypes = const [],
  }) {
    return {
      'name': name,
      if (description != null && description.isNotEmpty) 'description': description,
      'price': price,
      'currency': currency,
      if (imageUrl != null && imageUrl.isNotEmpty) 'image_url': imageUrl,
      'in_stock': inStock,
      'category': category.apiValue,
      'pet_types': petTypesToJson(petTypes),
    };
  }

  static Map<String, dynamic> vetPayload({
    required String name,
    required String phone,
    required String location,
    required List<String> services,
    required bool isEmergency,
    required bool isOpenNow,
    double? latitude,
    double? longitude,
    String? imageUrl,
    ListingHours? hours,
    List<PetType> petTypes = const [],
  }) {
    return {
      'name': name,
      'phone': phone,
      'location': location,
      'services': services,
      'is_emergency': isEmergency,
      'is_open_now': isOpenNow,
      'latitude': ?latitude,
      'longitude': ?longitude,
      if (imageUrl != null && imageUrl.isNotEmpty) 'image_url': imageUrl,
      if (hours != null) 'hours': hours.toJson(),
      'pet_types': petTypesToJson(petTypes),
    };
  }

  static Map<String, dynamic> storePayload({
    required String name,
    required String type,
    required String location,
    required List<String> services,
    required bool isOpenNow,
    String? phone,
    double? latitude,
    double? longitude,
    String? imageUrl,
    ListingHours? hours,
    List<PetType> petTypes = const [],
  }) {
    return {
      'name': name,
      'type': type,
      'location': location,
      'services': services,
      'is_open_now': isOpenNow,
      if (phone != null && phone.isNotEmpty) 'phone': phone,
      'latitude': ?latitude,
      'longitude': ?longitude,
      if (imageUrl != null && imageUrl.isNotEmpty) 'image_url': imageUrl,
      if (hours != null) 'hours': hours.toJson(),
      'pet_types': petTypesToJson(petTypes),
    };
  }
}
