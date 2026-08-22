import 'dart:convert';

import 'package:dio/dio.dart';
import '../api/api_client.dart';
import '../models/store.dart';
import '../models/store_item.dart';
import '../../core/cache/response_cache.dart';
import '../../core/constants/app_constants.dart';

class StoresRepository {
  StoresRepository(this._api, {ResponseCache? cache})
      : _cache = cache ?? const ResponseCache();

  final ApiClient _api;
  final ResponseCache _cache;

  Future<List<Store>> list({
    String? search,
    String? type,
    bool? openNow,
    bool? featured,
    double? maxDistanceKm,
    String? petType,
    String sort = 'distance',
    double lat = AppConstants.defaultLat,
    double lng = AppConstants.defaultLng,
  }) async {
    final Map<String, dynamic> queryParameters = {
      'lat': lat,
      'lng': lng,
      if (search != null && search.isNotEmpty) 'search': search,
      if (type != null && type.isNotEmpty) 'type': type,
      if (openNow == true) 'open_now': true,
      if (featured == true) 'featured': true,
      if (petType != null && petType.isNotEmpty) 'pet_type': petType,
      if (sort != 'distance') 'sort': sort,
      'max_distance_km': ?maxDistanceKm,
    };
    final cacheKey = ResponseCache.keyFor('/stores', queryParameters);

    try {
      final response = await _api.get<List<dynamic>>(
        '/stores',
        queryParameters: queryParameters,
      );
      final data = response.data ?? [];
      await _cache.put(cacheKey, jsonEncode(data));
      return data.map((e) => Store.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (error) {
      if (ResponseCache.isConnectivityError(error)) {
        final cached = await _cache.get(cacheKey);
        if (cached != null) {
          final decoded = jsonDecode(cached) as List<dynamic>;
          return decoded
              .map((e) => Store.fromJson(e as Map<String, dynamic>))
              .toList();
        }
      }
      rethrow;
    }
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
    String? category,
    String? petType,
    String sort = 'default',
  }) async {
    final Map<String, dynamic> queryParameters = {
      if (inStockOnly) 'in_stock': true,
      if (category != null && category.isNotEmpty) 'category': category,
      if (petType != null && petType.isNotEmpty) 'pet_type': petType,
      if (sort != 'default') 'sort': sort,
      'limit': ?limit,
    };
    final cacheKey =
        ResponseCache.keyFor('/stores/$storeId/items', queryParameters);

    try {
      final response = await _api.get<List<dynamic>>(
        '/stores/$storeId/items',
        queryParameters: queryParameters,
      );
      final data = response.data ?? [];
      await _cache.put(cacheKey, jsonEncode(data));
      return data
          .whereType<Map<String, dynamic>>()
          .map(StoreItem.fromJson)
          .toList();
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) return [];
      if (ResponseCache.isConnectivityError(error)) {
        final cached = await _cache.get(cacheKey);
        if (cached != null) {
          final decoded = jsonDecode(cached) as List<dynamic>;
          return decoded
              .whereType<Map<String, dynamic>>()
              .map(StoreItem.fromJson)
              .toList();
        }
      }
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
