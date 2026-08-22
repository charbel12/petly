import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/app_providers.dart';
import '../../../data/models/review.dart';
import '../../stores/providers/stores_providers.dart';
import '../../vets/providers/vets_providers.dart';

/// Reviews for one entity, most-recent-first (the backend already orders
/// this way; we don't re-sort here).
final reviewsProvider =
    FutureProvider.autoDispose.family<List<Review>, (String, String)>(
  (ref, key) {
    final repo = ref.watch(reviewsRepositoryProvider);
    return repo.list(entityType: key.$1, entityId: key.$2);
  },
);

/// Submits/deletes reviews and invalidates the affected [reviewsProvider]
/// entry plus the store/vet detail provider (so the average rating shown
/// there refreshes). Has no state of its own — errors are thrown for the
/// caller (the review form sheet) to catch and surface.
class ReviewsController {
  ReviewsController(this._ref);

  final Ref _ref;

  Future<void> submit({
    required String entityType,
    required String entityId,
    required int rating,
    String? comment,
  }) async {
    final repo = _ref.read(reviewsRepositoryProvider);
    await repo.upsert(
      entityType: entityType,
      entityId: entityId,
      rating: rating,
      comment: comment,
    );
    _invalidate(entityType, entityId);
  }

  Future<void> delete({
    required String reviewId,
    required String entityType,
    required String entityId,
  }) async {
    final repo = _ref.read(reviewsRepositoryProvider);
    await repo.delete(reviewId);
    _invalidate(entityType, entityId);
  }

  void _invalidate(String entityType, String entityId) {
    _ref.invalidate(reviewsProvider((entityType, entityId)));
    if (entityType == 'store') {
      _ref.invalidate(storeDetailProvider(entityId));
    } else if (entityType == 'vet') {
      _ref.invalidate(vetDetailProvider(entityId));
    }
  }
}

final reviewsControllerProvider = Provider<ReviewsController>(
  (ref) => ReviewsController(ref),
);
