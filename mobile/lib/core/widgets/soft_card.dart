import 'package:flutter/material.dart';
import '../theme/app_tokens.dart';

class SoftCard extends StatelessWidget {
  const SoftCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(16),
    this.margin = EdgeInsets.zero,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;

  @override
  Widget build(BuildContext context) {
    final tokens = AppTokens.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: tokens.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: tokens.border),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Theme(
            data: theme.copyWith(
              textTheme: theme.textTheme.apply(
                bodyColor: tokens.onCard,
                displayColor: tokens.onCard,
              ),
              iconTheme: IconThemeData(color: tokens.onCard),
              dividerColor: tokens.onCard.withValues(alpha: 0.18),
              listTileTheme: ListTileThemeData(
                iconColor: tokens.onCard,
                textColor: tokens.onCard,
                subtitleTextStyle: theme.textTheme.bodySmall?.copyWith(
                  color: tokens.onCardMuted,
                ),
              ),
            ),
            child: IconTheme(
              data: IconThemeData(color: tokens.onCard),
              child: DefaultTextStyle.merge(
                style: TextStyle(color: tokens.onCard),
                child: Padding(padding: padding, child: child),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
