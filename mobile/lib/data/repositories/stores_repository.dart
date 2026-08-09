import '../api/api_client.dart';
import '../models/store.dart';
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
}
