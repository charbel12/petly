import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../constants/app_constants.dart';
import '../theme/app_tokens.dart';

class _PawSpec {
  const _PawSpec(this.dx, this.dy, this.angleDeg, this.size);

  final double dx;
  final double dy;
  final double angleDeg;
  final double size;
}

class PetlyBackground extends StatelessWidget {
  const PetlyBackground({super.key, required this.child});

  final Widget child;

  static const _paws = [
    _PawSpec(0.08, 0.10, -18, 58),
    _PawSpec(0.78, 0.06, 22, 46),
    _PawSpec(0.88, 0.42, -8, 40),
    _PawSpec(0.04, 0.52, 14, 36),
    _PawSpec(0.62, 0.78, -24, 52),
    _PawSpec(0.28, 0.88, 10, 34),
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
                              tokens.brandPrimary.withValues(
                                alpha: tokens.pawOpacity,
                              ),
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
