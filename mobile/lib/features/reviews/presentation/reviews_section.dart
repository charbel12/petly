import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/async_error_view.dart';
import '../../../core/widgets/soft_card.dart';
import '../../../core/widgets/star_rating.dart';
import '../providers/reviews_providers.dart';
import 'review_form_sheet.dart';

/// Reviews list (most recent first) plus a "Write a review" button, shared
/// by the store and vet detail screens.
class ReviewsSection extends ConsumerWidget {
  const ReviewsSection({
    super.key,
    required this.entityType,
    required this.entityId,
  });

  final String entityType;
  final String entityId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = AppTokens.of(context);
    final reviewsAsync = ref.watch(reviewsProvider((entityType, entityId)));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Reviews',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            TextButton(
              onPressed: () => showReviewFormSheet(
                context,
                entityType: entityType,
                entityId: entityId,
              ),
              child: const Text('Write a review'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        reviewsAsync.when(
          skipLoadingOnReload: true,
          skipLoadingOnRefresh: true,
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (error, _) => AsyncErrorView(
            error: error,
            onRetry: () =>
                ref.invalidate(reviewsProvider((entityType, entityId))),
            compact: true,
          ),
          data: (reviews) {
            if (reviews.isEmpty) {
              return Text(
                'No reviews yet — be the first to share your experience.',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: tokens.onCardMuted),
              );
            }
            return Column(
              children: [
                for (final review in reviews)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: SoftCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  review.userName,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleSmall
                                      ?.copyWith(fontWeight: FontWeight.w700),
                                ),
                              ),
                              Text(
                                DateFormat.yMMMd().format(review.createdAt),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(color: tokens.onCardMuted),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          StarRatingDisplay(
                            rating: review.rating.toDouble(),
                            count: 1,
                            showCount: false,
                            size: 14,
                          ),
                          if (review.comment != null &&
                              review.comment!.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(review.comment!),
                          ],
                        ],
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}
