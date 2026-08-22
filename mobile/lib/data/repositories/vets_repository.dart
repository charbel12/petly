import 'dart:convert';

import 'package:dio/dio.dart';
import '../api/api_client.dart';
import '../models/vet.dart';
import '../../core/cache/response_cache.dart';
import '../../core/constants/app_constants.dart';

class VetsRepository {
  VetsRepository(this._api, {ResponseCache? cache})
      : _cache = cache ?? const ResponseCache();

  final ApiClient _api;
  final ResponseCache _cache;

  Future<List<Vet>> list({
    String? search,
    bool? openNow,
    bool? emergency,
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
      if (openNow == true) 'open_now': true,
      if (emergency == true) 'emergency': true,
      if (featured == true) 'featured': true,
      if (petType != null && petType.isNotEmpty) 'pet_type': petType,
      if (sort != 'distance') 'sort': sort,
      'max_distance_km': ?maxDistanceKm,
    };
    final cacheKey = ResponseCache.keyFor('/vets', queryParameters);

    try {
      final response = await _api.get<List<dynamic>>(
        '/vets',
        queryParameters: queryParameters,
      );
      final data = response.data ?? [];
      await _cache.put(cacheKey, jsonEncode(data));
      return data.map((e) => Vet.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (error) {
      if (ResponseCache.isConnectivityError(error)) {
        final cached = await _cache.get(cacheKey);
        if (cached != null) {
          final decoded = jsonDecode(cached) as List<dynamic>;
          return decoded
              .map((e) => Vet.fromJson(e as Map<String, dynamic>))
              .toList();
        }
      }
      rethrow;
    }
  }

  Future<List<Vet>> emergency({
    double lat = AppConstants.defaultLat,
    double lng = AppConstants.defaultLng,
  }) async {
    final response = await _api.get<List<dynamic>>(
      '/vets/emergency',
      queryParameters: {'lat': lat, 'lng': lng},
    );
    return (response.data ?? [])
        .map((e) => Vet.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Vet> getById(
    String id, {
    double lat = AppConstants.defaultLat,
    double lng = AppConstants.defaultLng,
  }) async {
    final response = await _api.get<Map<String, dynamic>>(
      '/vets/$id',
      queryParameters: {'lat': lat, 'lng': lng},
    );
    return Vet.fromJson(response.data!);
  }
}
