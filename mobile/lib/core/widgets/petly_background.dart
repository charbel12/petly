import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../constants/app_constants.dart';
import '../theme/app_tokens.dart';

class _PawSpec {
  const _PawSpec(this.dx, this.dy, this.angleDeg, this.size, this.accent);

  final double dx;
  final double dy;
  final double angleDeg;
  final double size;
  final bool accent;
}

class PetlyBackground extends StatelessWidget {
  const PetlyBackground({super.key, required this.child});

  final Widget child;

  static const _paws = [
    _PawSpec(0.06, 0.08, -18, 64, false),
    _PawSpec(0.80, 0.05, 22, 50, true),
    _PawSpec(0.90, 0.22, 8, 34, false),
    _PawSpec(0.88, 0.42, -8, 46, true),
    _PawSpec(0.04, 0.30, 30, 38, true),
    _PawSpec(0.02, 0.52, 14, 40, false),
    _PawSpec(0.46, 0.06, -10, 30, true),
    _PawSpec(0.62, 0.78, -24, 58, false),
    _PawSpec(0.30, 0.90, 10, 40, true),
    _PawSpec(0.10, 0.86, -16, 34, false),
    _PawSpec(0.94, 0.70, 20, 42, false),
    _PawSpec(0.50, 0.46, -6, 30, true),
  ];

  @override
  Widget build(BuildContext context) {
    final tokens = AppTokens.of(context);
    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  tokens.gradientStart,
                  tokens.gradientMid,
                  tokens.gradientEnd,
                ],
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: IgnorePointer(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Stack(
                  children: [
                    for (final paw in _paws)
                      Positioned(
                        left: constraints.maxWidth * paw.dx,
                        top: constraints.maxHeight * paw.dy,
                        child: Transform.rotate(
                          angle: paw.angleDeg * 3.1415926535 / 180,
                          child: SvgPicture.asset(
                            AppConstants.pawAsset,
                            width: paw.size,
                            height: paw.size,
                            colorFilter: ColorFilter.mode(
                              (paw.accent ? tokens.pawAccent : tokens.brandPrimary)
                                  .withValues(alpha: tokens.pawOpacity),
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ),
        Positioned.fill(child: child),
      ],
    );
  }
}
