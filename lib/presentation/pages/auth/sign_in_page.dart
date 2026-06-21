import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:Neralune/features/auth/application/auth_controller.dart';
import 'package:Neralune/presentation/design_system/components/revision_mvp_components.dart';
import 'package:Neralune/presentation/design_system/tokens/revision_colors.dart';
import 'package:Neralune/presentation/design_system/tokens/revision_radius.dart';
import 'package:Neralune/presentation/design_system/tokens/revision_spacing.dart';
import 'package:Neralune/presentation/design_system/tokens/revision_typography.dart';
import 'package:Neralune/presentation/widgets/brand/neralune_animated_logo.dart';

class SignInPage extends StatelessWidget {
  const SignInPage({required this.authController, super.key});

  final AuthController authController;

  @override
  Widget build(BuildContext context) {
    return NeraluneWelcomePage(authController: authController);
  }
}

class NeraluneWelcomePage extends StatelessWidget {
  const NeraluneWelcomePage({required this.authController, super.key});

  final AuthController authController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RevisionColors.ink,
      body: _NeraluneWelcomeBackground(
        child: SafeArea(
          child: _NeraluneWelcomeContent(authController: authController),
        ),
      ),
    );
  }
}

class _NeraluneWelcomeContent extends StatelessWidget {
  const _NeraluneWelcomeContent({required this.authController});

  final AuthController authController;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxHeight < 740;
        final horizontalPadding = constraints.maxWidth < 380
            ? RevisionSpacing.xl
            : RevisionSpacing.xxl;
        final verticalPadding = compact
            ? RevisionSpacing.m
            : RevisionSpacing.xl;
        final contentWidth = math
            .min(460.0, constraints.maxWidth - horizontalPadding * 2)
            .clamp(0.0, 460.0);
        final contentHeight = math.max(
          0.0,
          constraints.maxHeight - verticalPadding * 2,
        );

        return Padding(
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            verticalPadding,
            horizontalPadding,
            verticalPadding,
          ),
          child: Align(
            alignment: Alignment.topCenter,
            child: SizedBox(
              width: contentWidth,
              height: contentHeight,
              child: ListenableBuilder(
                listenable: authController,
                builder: (context, _) {
                  final isBusy = authController.isBusy;
                  final errorMessage = authController.errorMessage;
                  final logoSize = _logoSizeFor(
                    constraints.maxHeight,
                    hasError: errorMessage != null,
                  );
                  final sectionGap = compact
                      ? RevisionSpacing.l
                      : RevisionSpacing.xl;

                  return Column(
                    children: [
                      Expanded(
                        flex: errorMessage == null ? 6 : 5,
                        child: Align(
                          alignment: Alignment.center,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: SizedBox(
                              width: contentWidth,
                              child: _WelcomeBrandBlock(
                                logoSize: logoSize,
                                sectionGap: sectionGap,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Flexible(
                        flex: errorMessage == null ? 4 : 5,
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.bottomCenter,
                            child: SizedBox(
                              width: contentWidth,
                              child: _WelcomeActionBlock(
                                isBusy: isBusy,
                                errorMessage: errorMessage,
                                authController: authController,
                                sectionGap: sectionGap,
                              ),
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
        );
      },
    );
  }

  double _logoSizeFor(double height, {required bool hasError}) {
    final ratio = hasError ? 0.21 : 0.24;
    return (height * ratio)
        .clamp(hasError ? 142.0 : 156.0, hasError ? 206.0 : 224.0)
        .toDouble();
  }
}

class _WelcomeBrandBlock extends StatelessWidget {
  const _WelcomeBrandBlock({required this.logoSize, required this.sectionGap});

  final double logoSize;
  final double sectionGap;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(child: NeraluneAnimatedLogo(size: logoSize)),
        SizedBox(height: sectionGap),
        const _NeraluneWordmark(),
        const SizedBox(height: RevisionSpacing.s),
        const _NeraluneTagline(),
      ],
    );
  }
}

class _WelcomeActionBlock extends StatelessWidget {
  const _WelcomeActionBlock({
    required this.isBusy,
    required this.errorMessage,
    required this.authController,
    required this.sectionGap,
  });

  final bool isBusy;
  final String? errorMessage;
  final AuthController authController;
  final double sectionGap;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('neralune-auth-actions'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (errorMessage != null) ...[
          _AuthErrorMessage(message: errorMessage!),
          const SizedBox(height: RevisionSpacing.m),
        ],
        _NeraluneAuthButton.google(
          enabled: !isBusy,
          label: isBusy ? 'Connexion en cours...' : 'Continuer avec Google',
          onPressed: authController.signInWithGoogle,
        ),
        const SizedBox(height: RevisionSpacing.m),
        _NeraluneAuthButton.apple(
          enabled: !isBusy,
          label: 'Continuer avec Apple',
          onPressed: authController.signInWithApple,
        ),
        SizedBox(height: sectionGap),
        const _LegalConsentText(),
      ],
    );
  }
}

class _NeraluneWordmark extends StatelessWidget {
  const _NeraluneWordmark();

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: ShaderMask(
        blendMode: BlendMode.srcIn,
        shaderCallback: (bounds) => const LinearGradient(
          colors: [
            RevisionColors.text,
            RevisionColors.cyan,
            RevisionColors.blue,
            RevisionColors.violet,
          ],
        ).createShader(bounds),
        child: const Text(
          'NERALUNE',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: RevisionColors.text,
            fontSize: 41,
            fontWeight: FontWeight.w300,
            letterSpacing: 10,
            height: 1,
          ),
        ),
      ),
    );
  }
}

class _NeraluneTagline extends StatelessWidget {
  const _NeraluneTagline();

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        text: 'Révise mieux, ',
        children: [
          TextSpan(
            text: 'progresse',
            style: RevisionTypography.body.copyWith(
              color: RevisionColors.cyan,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const TextSpan(text: ' chaque jour.'),
        ],
      ),
      textAlign: TextAlign.center,
      style: RevisionTypography.body.copyWith(
        color: RevisionColors.textMuted,
        fontSize: 18,
        height: 1.28,
      ),
    );
  }
}

class _NeraluneAuthButton extends StatelessWidget {
  const _NeraluneAuthButton._({
    required this.label,
    required this.onPressed,
    required this.enabled,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.icon,
    required this.semanticLabel,
    this.borderColor,
  });

  factory _NeraluneAuthButton.google({
    required String label,
    required VoidCallback onPressed,
    required bool enabled,
  }) {
    return _NeraluneAuthButton._(
      label: label,
      onPressed: onPressed,
      enabled: enabled,
      backgroundColor: Colors.white,
      foregroundColor: const Color(0xFF121212),
      borderColor: Colors.white.withValues(alpha: 0.72),
      semanticLabel: 'Continuer avec Google',
      icon: SvgPicture.asset(
        'assets/brand/google_g.svg',
        width: 24,
        height: 24,
        semanticsLabel: 'Google',
      ),
    );
  }

  factory _NeraluneAuthButton.apple({
    required String label,
    required VoidCallback onPressed,
    required bool enabled,
  }) {
    return _NeraluneAuthButton._(
      label: label,
      onPressed: onPressed,
      enabled: enabled,
      backgroundColor: Colors.black,
      foregroundColor: Colors.white,
      borderColor: Colors.white.withValues(alpha: 0.22),
      semanticLabel: 'Continuer avec Apple',
      icon: const Icon(Icons.apple, color: Colors.white, size: 27),
    );
  }

  final String label;
  final VoidCallback onPressed;
  final bool enabled;
  final Color backgroundColor;
  final Color foregroundColor;
  final Color? borderColor;
  final Widget icon;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: enabled,
      label: semanticLabel,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? onPressed : null,
          borderRadius: RevisionRadius.radiusL,
          child: AnimatedOpacity(
            opacity: enabled ? 1 : 0.58,
            duration: const Duration(milliseconds: 160),
            child: Container(
              height: 54,
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: RevisionRadius.radiusL,
                border: Border.all(
                  color: borderColor ?? Colors.transparent,
                  width: 1.1,
                ),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: RevisionSpacing.xl,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  icon,
                  const SizedBox(width: RevisionSpacing.l),
                  Flexible(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: foregroundColor,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LegalConsentText extends StatelessWidget {
  const _LegalConsentText();

  @override
  Widget build(BuildContext context) {
    final mutedStyle = RevisionTypography.body.copyWith(
      color: RevisionColors.textMuted,
      fontSize: 13,
      height: 1.32,
    );
    final linkStyle = mutedStyle.copyWith(
      color: const Color(0xFF6F8BFF),
      fontWeight: FontWeight.w800,
    );

    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text('En continuant, tu acceptes nos ', style: mutedStyle),
        _LegalLink(label: 'Conditions d’utilisation', style: linkStyle),
        Text(' et notre ', style: mutedStyle),
        _LegalLink(label: 'Politique de confidentialité', style: linkStyle),
        Text('.', style: mutedStyle),
      ],
    );
  }
}

class _LegalLink extends StatelessWidget {
  const _LegalLink({required this.label, required this.style});

  final String label;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      link: true,
      child: InkWell(
        borderRadius: RevisionRadius.radiusS,
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: RevisionSpacing.xs,
            vertical: RevisionSpacing.xxs,
          ),
          child: Text(label, style: style),
        ),
      ),
    );
  }
}

class _AuthErrorMessage extends StatelessWidget {
  const _AuthErrorMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return RevisionGlassCard(
      padding: const EdgeInsets.all(RevisionSpacing.m),
      borderColor: RevisionColors.red.withValues(alpha: 0.55),
      backgroundColor: RevisionColors.red.withValues(alpha: 0.08),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: RevisionColors.red),
          const SizedBox(width: RevisionSpacing.s),
          Expanded(
            child: Text(
              message,
              style: RevisionTypography.body.copyWith(
                color: RevisionColors.text,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NeraluneWelcomeBackground extends StatelessWidget {
  const _NeraluneWelcomeBackground({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF010714), Color(0xFF031120), Color(0xFF070B21)],
        ),
      ),
      child: Stack(
        children: [
          const Positioned(
            top: -170,
            left: -120,
            right: -120,
            height: 500,
            child: _WelcomeGlow(
              colors: [Color(0x66268DFF), Colors.transparent],
            ),
          ),
          const Positioned(
            top: 120,
            left: 48,
            right: 48,
            height: 520,
            child: _WelcomeGlow(
              colors: [Color(0x552F4EFF), Colors.transparent],
            ),
          ),
          const Positioned(
            top: 76,
            left: 0,
            right: 0,
            height: 520,
            child: _VerticalLightBeam(),
          ),
          child,
        ],
      ),
    );
  }
}

class _WelcomeGlow extends StatelessWidget {
  const _WelcomeGlow({required this.colors});

  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: RadialGradient(colors: colors, stops: const [0, 1]),
      ),
    );
  }
}

class _VerticalLightBeam extends StatelessWidget {
  const _VerticalLightBeam();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            RevisionColors.blue.withValues(alpha: 0.18),
            RevisionColors.cyan.withValues(alpha: 0.12),
            Colors.transparent,
          ],
          stops: const [0, 0.28, 0.62, 1],
        ),
      ),
    );
  }
}
