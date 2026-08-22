import '../api/api_client.dart';
import '../models/review.dart';

class ReviewsRepository {
  ReviewsRepository(this._api);

  final ApiClient _api;

  Future<List<Review>> list({
    required String entityType,
    required String entityId,
    int? limit,
    int? offset,
  }) async {
    final response = await _api.get<List<dynamic>>(
      '/reviews',
      queryParameters: {
        'entity_type': entityType,
        'entity_id': entityId,
        'limit': ?limit,
        'offset': ?offset,
      },
    );
    return (response.data ?? [])
        .whereType<Map<String, dynamic>>()
        .map(Review.fromJson)
        .toList();
  }

  /// Upserts the current user's review for this entity.
  Future<Review> upsert({
    required String entityType,
    required String entityId,
    required int rating,
    String? comment,
  }) async {
    final response = await _api.post<Map<String, dynamic>>(
      '/reviews',
      data: {
        'entity_type': entityType,
        'entity_id': entityId,
        'rating': rating,
        if (comment != null && comment.isNotEmpty) 'comment': comment,
      },
    );
    return Review.fromJson(response.data!);
  }

  Future<Review> update({
    required String reviewId,
    required String entityType,
    required String entityId,
    required int rating,
    String? comment,
  }) async {
    final response = await _api.patch<Map<String, dynamic>>(
      '/reviews/$reviewId',
      data: {
        'entity_type': entityType,
        'entity_id': entityId,
        'rating': rating,
        if (comment != null && comment.isNotEmpty) 'comment': comment,
      },
    );
    return Review.fromJson(response.data!);
  }

  Future<void> delete(String reviewId) async {
    await _api.delete<void>('/reviews/$reviewId');
  }
}
