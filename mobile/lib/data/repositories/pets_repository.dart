import '../api/api_client.dart';
import '../models/pet.dart';

class PetsRepository {
  PetsRepository(this._api);

  final ApiClient _api;

  Future<List<Pet>> listByUser(String userId) async {
    final response = await _api.get<List<dynamic>>(
      '/pets',
      queryParameters: {'user_id': userId},
    );
    return (response.data ?? [])
        .map((e) => Pet.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Pet> create({
    required String userId,
    required String name,
    required String type,
    required double age,
  }) async {
    final response = await _api.post<Map<String, dynamic>>(
      '/pets',
      data: {
        'user_id': userId,
        'name': name,
        'type': type,
        'age': age,
      },
    );
    return Pet.fromJson(response.data!);
  }

  Future<void> delete(String id) async {
    await _api.delete('/pets/$id');
  }
}
