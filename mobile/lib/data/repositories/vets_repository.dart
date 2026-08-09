import '../api/api_client.dart';
import '../models/vet.dart';
import '../../core/constants/app_constants.dart';

class VetsRepository {
  VetsRepository(this._api);

  final ApiClient _api;

  Future<List<Vet>> list({
    String? search,
    bool? openNow,
    bool? emergency,
    bool? featured,
    double? maxDistanceKm,
    double lat = AppConstants.defaultLat,
    double lng = AppConstants.defaultLng,
  }) async {
    final response = await _api.get<List<dynamic>>(
      '/vets',
      queryParameters: {
        'lat': lat,
        'lng': lng,
        if (search != null && search.isNotEmpty) 'search': search,
        if (openNow == true) 'open_now': true,
        if (emergency == true) 'emergency': true,
        if (featured == true) 'featured': true,
        'max_distance_km': ?maxDistanceKm,
      },
    );

    return (response.data ?? [])
        .map((e) => Vet.fromJson(e as Map<String, dynamic>))
        .toList();
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
