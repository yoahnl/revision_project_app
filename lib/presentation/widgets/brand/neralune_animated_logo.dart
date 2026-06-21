import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:Neralune/presentation/design_system/tokens/revision_colors.dart';

class NeraluneAnimatedLogo extends StatefulWidget {
  const NeraluneAnimatedLogo({this.size = 240, super.key});

  final double size;

  @override
  State<NeraluneAnimatedLogo> createState() => _NeraluneAnimatedLogoState();
}

class _NeraluneAnimatedLogoState extends State<NeraluneAnimatedLogo>
    with SingleTickerProviderStateMixin {
  static const _bodyAsset = 'assets/brand/neralune_cat_body.svg';
  static const _tailAsset = 'assets/brand/neralune_cat_tail.svg';
  static const _tailPivot = Alignment(-0.26, 0.66);
  static const _maxTailAngleRadians = 5 * math.pi / 180;

  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3600),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final animationsDisabled = MediaQuery.disableAnimationsOf(context);

    return Semantics(
      image: true,
      label: 'Logo Neralune',
      child: ExcludeSemantics(
        child: SizedBox.square(
          dimension: widget.size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              const Positioned.fill(child: _LogoGlow()),
              Positioned.fill(
                child: SvgPicture.asset(_bodyAsset, fit: BoxFit.contain),
              ),
              Positioned.fill(
                child: animationsDisabled
                    ? SvgPicture.asset(_tailAsset, fit: BoxFit.contain)
                    : AnimatedBuilder(
                        animation: _controller,
                        builder: (context, child) {
                          final t = _controller.value * math.pi * 2;
                          final organicOffset = math.sin(t * 2 + 0.7) * 0.12;
                          final angle =
                              (math.sin(t) + organicOffset) *
                              _maxTailAngleRadians;

                          return Transform.rotate(
                            alignment: _tailPivot,
                            angle: angle,
                            child: child,
                          );
                        },
                        child: SvgPicture.asset(
                          _tailAsset,
                          fit: BoxFit.contain,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LogoGlow extends StatelessWidget {
  const _LogoGlow();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            RevisionColors.cyan.withValues(alpha: 0.22),
            RevisionColors.violet.withValues(alpha: 0.14),
            Colors.transparent,
          ],
          stops: const [0, 0.46, 1],
        ),
      ),
    );
  }
}
