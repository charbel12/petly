import 'package:dio/dio.dart';
import '../api/api_client.dart';
import '../models/store.dart';
import '../models/store_item.dart';
import '../../core/constants/app_constants.dart';

class StoresRepository {
  StoresRepository(this._api);

  final ApiClient _api;

  Future<List<Store>> list({
    String? search,
    String? type,
    bool? openNow,
    bool? featured,
    double? maxDistanceKm,
    double lat = AppConstants.defaultLat,
    double lng = AppConstants.defaultLng,
  }) async {
    final response = await _api.get<List<dynamic>>(
      '/stores',
      queryParameters: {
        'lat': lat,
        'lng': lng,
        if (search != null && search.isNotEmpty) 'search': search,
        if (type != null && type.isNotEmpty) 'type': type,
        if (openNow == true) 'open_now': true,
        if (featured == true) 'featured': true,
        'max_distance_km': ?maxDistanceKm,
      },
    );

    return (response.data ?? [])
        .map((e) => Store.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Store> getById(
    String id, {
    double lat = AppConstants.defaultLat,
    double lng = AppConstants.defaultLng,
  }) async {
    final response = await _api.get<Map<String, dynamic>>(
      '/stores/$id',
      queryParameters: {'lat': lat, 'lng': lng},
    );
    return Store.fromJson(response.data!);
  }

  Future<List<StoreItem>> listItems(
    String storeId, {
    bool inStockOnly = false,
    int? limit,
  }) async {
    try {
      final response = await _api.get<List<dynamic>>(
        '/stores/$storeId/items',
        queryParameters: {
          if (inStockOnly) 'in_stock': true,
          'limit': ?limit,
        },
      );
      return (response.data ?? [])
          .whereType<Map<String, dynamic>>()
          .map(StoreItem.fromJson)
          .toList();
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) return [];
      rethrow;
    }
  }

  Future<NearestStoreItems> nearestItems({
    double lat = AppConstants.defaultLat,
    double lng = AppConstants.defaultLng,
    int limit = 6,
  }) async {
    final stores = await list(lat: lat, lng: lng);
    for (final store in stores.take(8)) {
      final items = await listItems(
        store.id,
        inStockOnly: true,
        limit: limit,
      );
      if (items.isNotEmpty) {
        return NearestStoreItems(store: store, items: items);
      }
    }
    return const NearestStoreItems();
  }
}
