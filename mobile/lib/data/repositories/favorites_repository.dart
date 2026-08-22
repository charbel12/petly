import 'dart:convert';

import 'package:dio/dio.dart';
import '../api/api_client.dart';
import '../models/store.dart';
import '../models/vet.dart';
import '../../core/cache/response_cache.dart';

class FavoriteIds {
  const FavoriteIds({this.storeIds = const {}, this.vetIds = const {}});

  final Set<String> storeIds;
  final Set<String> vetIds;

  factory FavoriteIds.fromJson(Map<String, dynamic> json) {
    return FavoriteIds(
      storeIds: (json['store_ids'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toSet(),
      vetIds: (json['vet_ids'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toSet(),
    );
  }

  FavoriteIds copyWith({Set<String>? storeIds, Set<String>? vetIds}) {
    return FavoriteIds(
      storeIds: storeIds ?? this.storeIds,
      vetIds: vetIds ?? this.vetIds,
    );
  }
}

class FavoritesRepository {
  FavoritesRepository(this._api, {ResponseCache? cache})
      : _cache = cache ?? const ResponseCache();

  final ApiClient _api;
  final ResponseCache _cache;

  Future<FavoriteIds> listIds() async {
    final response = await _api.get<Map<String, dynamic>>('/favorites');
    return FavoriteIds.fromJson(response.data ?? {});
  }

  Future<List<Store>> listStores({double? lat, double? lng}) async {
    final Map<String, dynamic> queryParameters = {
      'lat': ?lat,
      'lng': ?lng,
    };
    final cacheKey = ResponseCache.keyFor('/favorites/stores', queryParameters);

    try {
      final response = await _api.get<List<dynamic>>(
        '/favorites/stores',
        queryParameters: queryParameters,
      );
      final data = response.data ?? [];
      await _cache.put(cacheKey, jsonEncode(data));
      return data
          .whereType<Map<String, dynamic>>()
          .map(Store.fromJson)
          .toList();
    } on DioException catch (error) {
      if (ResponseCache.isConnectivityError(error)) {
        final cached = await _cache.get(cacheKey);
        if (cached != null) {
          final decoded = jsonDecode(cached) as List<dynamic>;
          return decoded
              .whereType<Map<String, dynamic>>()
              .map(Store.fromJson)
              .toList();
        }
      }
      rethrow;
    }
  }

  Future<List<Vet>> listVets({double? lat, double? lng}) async {
    final Map<String, dynamic> queryParameters = {
      'lat': ?lat,
      'lng': ?lng,
    };
    final cacheKey = ResponseCache.keyFor('/favorites/vets', queryParameters);

    try {
      final response = await _api.get<List<dynamic>>(
        '/favorites/vets',
        queryParameters: queryParameters,
      );
      final data = response.data ?? [];
      await _cache.put(cacheKey, jsonEncode(data));
      return data.whereType<Map<String, dynamic>>().map(Vet.fromJson).toList();
    } on DioException catch (error) {
      if (ResponseCache.isConnectivityError(error)) {
        final cached = await _cache.get(cacheKey);
        if (cached != null) {
          final decoded = jsonDecode(cached) as List<dynamic>;
          return decoded
              .whereType<Map<String, dynamic>>()
              .map(Vet.fromJson)
              .toList();
        }
      }
      rethrow;
    }
  }

  Future<void> add(String entityType, String entityId) async {
    await _api.post<void>(
      '/favorites',
      data: {'entity_type': entityType, 'entity_id': entityId},
    );
  }

  Future<void> remove(String entityType, String entityId) async {
    await _api.delete<void>('/favorites/$entityType/$entityId');
  }
}
