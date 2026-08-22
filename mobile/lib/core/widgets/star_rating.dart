import 'package:flutter/material.dart';
import '../theme/app_tokens.dart';

/// Read-only star rating with a review count, e.g. "★★★★☆ (23)".
///
/// Renders nothing but a muted "No reviews yet" label when [count] is 0, so
/// it's safe to drop into cards/detail headers unconditionally.
class StarRatingDisplay extends StatelessWidget {
  const StarRatingDisplay({
    super.key,
    required this.rating,
    required this.count,
    this.size = 16,
    this.showCount = true,
  });

  final double rating;
  final int count;
  final double size;
  final bool showCount;

  @override
  Widget build(BuildContext context) {
    final tokens = AppTokens.of(context);
    if (count <= 0) {
      return Text(
        'No reviews yet',
        style: Theme.of(context)
            .textTheme
            .bodySmall
            ?.copyWith(color: tokens.onCardMuted),
      );
    }

    final rounded = rating.clamp(0, 5).round();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 1; i <= 5; i++)
          Icon(
            i <= rounded ? Icons.star_rounded : Icons.star_border_rounded,
            size: size,
            color: tokens.brandAccent,
          ),
        if (showCount) ...[
          const SizedBox(width: 4),
          Text(
            '(${count.toString()})',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: tokens.onCardMuted,
                ),
          ),
        ],
      ],
    );
  }
}

/// Five tappable stars for picking a 1-5 rating, used in the review form.
class StarRatingInput extends StatelessWidget {
  const StarRatingInput({
    super.key,
    required this.value,
    required this.onChanged,
    this.size = 32,
  });

  final int value;
  final ValueChanged<int> onChanged;
  final double size;

  @override
  Widget build(BuildContext context) {
    final tokens = AppTokens.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 1; i <= 5; i++)
          IconButton(
            onPressed: () => onChanged(i),
            icon: Icon(
              i <= value ? Icons.star_rounded : Icons.star_border_rounded,
              size: size,
              color: tokens.brandAccent,
            ),
            tooltip: '$i star${i == 1 ? '' : 's'}',
          ),
      ],
    );
  }
}
