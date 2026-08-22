import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/favorites/providers/favorites_providers.dart';
import '../theme/app_tokens.dart';
import '../utils/api_error.dart';

/// Reusable heart toggle for favoriting a store or vet.
class FavoriteButton extends ConsumerStatefulWidget {
  const FavoriteButton({
    super.key,
    required this.entityType,
    required this.entityId,
    this.color,
    this.filledColor,
    this.compact = false,
  });

  /// 'store' or 'vet'.
  final String entityType;
  final String entityId;
  final Color? color;
  final Color? filledColor;

  /// Use a tighter hit target/padding, for card overlays.
  final bool compact;

  @override
  ConsumerState<FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends ConsumerState<FavoriteButton> {
  bool _busy = false;

  Future<void> _toggle() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final controller = ref.read(favoriteIdsProvider.notifier);
      if (widget.entityType == 'vet') {
        await controller.toggleVet(widget.entityId);
      } else {
        await controller.toggleStore(widget.entityId);
      }
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(friendlyErrorMessage(context, error))),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = AppTokens.of(context);
    final idsAsync = ref.watch(favoriteIdsProvider);
    final ids = idsAsync.asData?.value;
    final favorited = widget.entityType == 'vet'
        ? (ids?.vetIds.contains(widget.entityId) ?? false)
        : (ids?.storeIds.contains(widget.entityId) ?? false);

    return IconButton(
      onPressed: _busy ? null : _toggle,
      visualDensity: widget.compact ? VisualDensity.compact : null,
      constraints: widget.compact
          ? const BoxConstraints.tightFor(width: 36, height: 36)
          : null,
      padding: widget.compact ? const EdgeInsets.all(6) : null,
      icon: _busy
          ? SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: widget.color ?? tokens.onCard,
              ),
            )
          : Icon(
              favorited ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              size: widget.compact ? 18 : 24,
              color: favorited
                  ? (widget.filledColor ?? tokens.danger)
                  : (widget.color ?? tokens.onCard),
            ),
      tooltip: favorited ? 'Remove from favorites' : 'Add to favorites',
    );
  }
}
