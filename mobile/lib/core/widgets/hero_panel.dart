import 'package:flutter/material.dart';
import '../theme/app_tokens.dart';

/// A solid hero surface for header/greeting blocks — the bigger sibling of [SoftCard].
class HeroPanel extends StatelessWidget {
  const HeroPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.margin = EdgeInsets.zero,
    this.borderRadius = const BorderRadius.all(Radius.circular(24)),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    final tokens = AppTokens.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: tokens.card,
        borderRadius: borderRadius,
        border: Border.all(color: tokens.border),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
        ],
      ),
      child: Theme(
        data: theme.copyWith(
          textTheme: theme.textTheme.apply(
            bodyColor: tokens.onCard,
            displayColor: tokens.onCard,
          ),
          iconTheme: IconThemeData(color: tokens.onCard),
        ),
        child: DefaultTextStyle.merge(
          style: TextStyle(color: tokens.onCard),
          child: IconTheme(
            data: IconThemeData(color: tokens.onCard),
            child: child,
          ),
        ),
      ),
    );
  }
}
