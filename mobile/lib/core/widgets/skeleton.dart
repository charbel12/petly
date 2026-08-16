import 'package:flutter/material.dart';
import '../theme/app_tokens.dart';

class ShimmerBox extends StatefulWidget {
  const ShimmerBox({
    super.key,
    this.width,
    this.height = 16,
    this.borderRadius = 10,
  });

  final double? width;
  final double height;
  final double borderRadius;

  @override
  State<ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<ShimmerBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = AppTokens.of(context);
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment(-1 + 2 * _controller.value, 0),
              end: Alignment(2 * _controller.value, 0),
              colors: [
                tokens.border,
                tokens.surface,
                tokens.border,
              ],
            ),
          ),
        );
      },
    );
  }
}

class ListingCardSkeleton extends StatelessWidget {
  const ListingCardSkeleton({super.key, this.count = 3});

  final int count;

  @override
  Widget build(BuildContext context) {
    final tokens = AppTokens.of(context);
    final cards = List.generate(count, (index) {
      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: tokens.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        clipBehavior: Clip.antiAlias,
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ShimmerBox(height: 148, borderRadius: 0),
            Padding(
              padding: EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerBox(width: 180, height: 16),
                  SizedBox(height: 10),
                  ShimmerBox(width: 120, height: 12),
                  SizedBox(height: 10),
                  ShimmerBox(width: 90, height: 12),
                ],
              ),
            ),
          ],
        ),
      );
    });

    return LayoutBuilder(
      builder: (context, constraints) {
        final column = Column(children: cards);
        if (constraints.maxHeight.isFinite) {
          return SingleChildScrollView(child: column);
        }
        return column;
      },
    );
  }
}

class HorizontalCardSkeleton extends StatelessWidget {
  const HorizontalCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 220,
      child: Row(
        children: [
          _StoreSkeletonCard(),
          SizedBox(width: 12),
          _StoreSkeletonCard(),
        ],
      ),
    );
  }
}

class _StoreSkeletonCard extends StatelessWidget {
  const _StoreSkeletonCard();

  @override
  Widget build(BuildContext context) {
    final tokens = AppTokens.of(context);
    return Container(
      width: 180,
      decoration: BoxDecoration(
        color: tokens.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerBox(height: 101, borderRadius: 0),
          Padding(
            padding: EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerBox(width: 120, height: 14),
                SizedBox(height: 8),
                ShimmerBox(width: 80, height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
