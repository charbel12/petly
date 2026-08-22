import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petly/core/providers/app_providers.dart';
import 'package:petly/data/models/review.dart';
import 'package:petly/data/repositories/reviews_repository.dart';
import 'package:petly/features/reviews/providers/reviews_providers.dart';

/// Test double that mimics [ReviewsRepository] without hitting the network.
class _FakeReviewsRepository implements ReviewsRepository {
  final List<Review> reviews = [];
  final List<String> calls = [];

  @override
  Future<List<Review>> list({
    required String entityType,
    required String entityId,
    int? limit,
    int? offset,
  }) async {
    calls.add('list:$entityType:$entityId');
    return reviews
        .where((r) => r.entityType == entityType && r.entityId == entityId)
        .toList();
  }

  @override
  Future<Review> upsert({
    required String entityType,
    required String entityId,
    required int rating,
    String? comment,
  }) async {
    calls.add('upsert:$entityType:$entityId:$rating');
    final review = Review(
      id: 'review-1',
      userId: 'user-1',
      userName: 'Test User',
      entityType: entityType,
      entityId: entityId,
      rating: rating,
      comment: comment,
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 1),
    );
    reviews.removeWhere((r) => r.id == review.id);
    reviews.add(review);
    return review;
  }

  @override
  Future<Review> update({
    required String reviewId,
    required String entityType,
    required String entityId,
    required int rating,
    String? comment,
  }) async {
    calls.add('update:$reviewId');
    throw UnimplementedError('not used by this test');
  }

  @override
  Future<void> delete(String reviewId) async {
    calls.add('delete:$reviewId');
    reviews.removeWhere((r) => r.id == reviewId);
  }
}

void main() {
  group('ReviewsController', () {
    test('submit upserts a review and invalidates the reviews list',
        () async {
      final fake = _FakeReviewsRepository();
      final container = ProviderContainer(
        overrides: [reviewsRepositoryProvider.overrideWithValue(fake)],
      );
      addTearDown(container.dispose);

      final initial =
          await container.read(reviewsProvider(('store', 'store-1')).future);
      expect(initial, isEmpty);

      await container.read(reviewsControllerProvider).submit(
            entityType: 'store',
            entityId: 'store-1',
            rating: 5,
            comment: 'Great store!',
          );

      final after =
          await container.read(reviewsProvider(('store', 'store-1')).future);
      expect(after, hasLength(1));
      expect(after.first.rating, 5);
      expect(after.first.comment, 'Great store!');
      expect(fake.calls, contains('upsert:store:store-1:5'));
    });

    test('delete removes the review and invalidates the reviews list',
        () async {
      final fake = _FakeReviewsRepository();
      final container = ProviderContainer(
        overrides: [reviewsRepositoryProvider.overrideWithValue(fake)],
      );
      addTearDown(container.dispose);

      await container.read(reviewsControllerProvider).submit(
            entityType: 'vet',
            entityId: 'vet-1',
            rating: 4,
          );
      final beforeDelete =
          await container.read(reviewsProvider(('vet', 'vet-1')).future);
      expect(beforeDelete, hasLength(1));

      await container.read(reviewsControllerProvider).delete(
            reviewId: beforeDelete.first.id,
            entityType: 'vet',
            entityId: 'vet-1',
          );

      final afterDelete =
          await container.read(reviewsProvider(('vet', 'vet-1')).future);
      expect(afterDelete, isEmpty);
      expect(fake.calls, contains('delete:review-1'));
    });
  });
}
