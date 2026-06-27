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

        return SingleChildScrollView(
          key: const ValueKey('neralune-auth-scroll'),
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            verticalPadding,
            horizontalPadding,
            verticalPadding,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: contentHeight),
            child: Align(
              alignment: Alignment.topCenter,
              child: SizedBox(
                width: contentWidth,
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
                    final actionTopGap = compact
                        ? RevisionSpacing.l
                        : math.max(sectionGap, contentHeight * 0.28);

                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(height: compact ? 0 : RevisionSpacing.s),
                        _WelcomeBrandBlock(
                          logoSize: logoSize,
                          sectionGap: compact
                              ? RevisionSpacing.m
                              : RevisionSpacing.l,
                        ),
                        SizedBox(height: actionTopGap),
                        _WelcomeActionBlock(
                          isBusy: isBusy,
                          errorMessage: errorMessage,
                          authController: authController,
                          sectionGap: sectionGap,
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  double _logoSizeFor(double height, {required bool hasError}) {
    final ratio = hasError ? 0.13 : 0.15;
    return (height * ratio)
        .clamp(hasError ? 104.0 : 116.0, hasError ? 154.0 : 168.0)
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

class _WelcomeActionBlock extends StatefulWidget {
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
  State<_WelcomeActionBlock> createState() => _WelcomeActionBlockState();
}

class _WelcomeActionBlockState extends State<_WelcomeActionBlock> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _showEmailForm = false;
  bool _isCreatingAccount = false;
  bool _obscurePassword = true;
  String? _localErrorMessage;
  String? _infoMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _openEmailForm() {
    setState(() {
      _showEmailForm = true;
      _localErrorMessage = null;
      _infoMessage = null;
    });
  }

  void _showProviderOptions() {
    setState(() {
      _showEmailForm = false;
      _isCreatingAccount = false;
      _obscurePassword = true;
      _localErrorMessage = null;
      _infoMessage = null;
    });
  }

  Future<void> _submitEmailAuth() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final validationMessage = _validateCredentials(email, password);

    if (validationMessage != null) {
      setState(() {
        _localErrorMessage = validationMessage;
        _infoMessage = null;
      });
      return;
    }

    setState(() {
      _localErrorMessage = null;
      _infoMessage = null;
    });

    if (_isCreatingAccount) {
      await widget.authController.createAccountWithEmailAndPassword(
        email: email,
        password: password,
      );
      return;
    }

    await widget.authController.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> _sendPasswordReset() async {
    final email = _emailController.text.trim();
    final validationMessage = _validateEmail(email);

    if (validationMessage != null) {
      setState(() {
        _localErrorMessage = validationMessage;
        _infoMessage = null;
      });
      return;
    }

    setState(() {
      _localErrorMessage = null;
      _infoMessage = null;
    });

    await widget.authController.sendPasswordResetEmail(email: email);

    if (!mounted || widget.authController.errorMessage != null) {
      return;
    }

    setState(() {
      _infoMessage = 'Email de réinitialisation envoyé. Vérifie ta boîte mail.';
    });
  }

  void _toggleMode() {
    setState(() {
      _isCreatingAccount = !_isCreatingAccount;
      _localErrorMessage = null;
      _infoMessage = null;
    });
  }

  String? _validateCredentials(String email, String password) {
    final emailMessage = _validateEmail(email);
    if (emailMessage != null) {
      return emailMessage;
    }
    if (password.isEmpty) {
      return 'Entre ton mot de passe.';
    }
    if (_isCreatingAccount && password.length < 6) {
      return 'Choisis un mot de passe d’au moins 6 caractères.';
    }

    return null;
  }

  String? _validateEmail(String email) {
    if (email.isEmpty) {
      return 'Entre ton adresse email.';
    }
    if (!email.contains('@') || email.endsWith('@')) {
      return 'Adresse email invalide.';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final isBusy = widget.isBusy;
    final visibleErrorMessage = widget.errorMessage ?? _localErrorMessage;

    return Column(
      key: const ValueKey('neralune-auth-actions'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (visibleErrorMessage != null) ...[
          _AuthErrorMessage(message: visibleErrorMessage),
          const SizedBox(height: RevisionSpacing.m),
        ],
        if (_infoMessage != null) ...[
          _AuthInfoMessage(message: _infoMessage!),
          const SizedBox(height: RevisionSpacing.m),
        ],
        AnimatedSize(
          duration: const Duration(milliseconds: 320),
          curve: Curves.easeOutCubic,
          alignment: Alignment.topCenter,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 360),
            reverseDuration: const Duration(milliseconds: 220),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: _buildAuthPanelTransition,
            child: _showEmailForm
                ? _EmailAuthForm(
                    key: const ValueKey('email-auth-form-panel'),
                    emailController: _emailController,
                    passwordController: _passwordController,
                    enabled: !isBusy,
                    isCreatingAccount: _isCreatingAccount,
                    obscurePassword: _obscurePassword,
                    onTogglePassword: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                    onSubmit: _submitEmailAuth,
                    onToggleMode: _toggleMode,
                    onResetPassword: _sendPasswordReset,
                    onShowProviderOptions: _showProviderOptions,
                  )
                : _AuthProviderOptions(
                    key: const ValueKey('email-auth-provider-panel'),
                    enabled: !isBusy,
                    isBusy: isBusy,
                    onGoogle: widget.authController.signInWithGoogle,
                    onApple: widget.authController.signInWithApple,
                    onEmail: _openEmailForm,
                  ),
          ),
        ),
        SizedBox(height: widget.sectionGap),
        const _LegalConsentText(),
      ],
    );
  }

  Widget _buildAuthPanelTransition(Widget child, Animation<double> animation) {
    final curvedAnimation = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    final slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(curvedAnimation);
    final scaleAnimation = Tween<double>(
      begin: 0.96,
      end: 1,
    ).animate(curvedAnimation);

    return FadeTransition(
      opacity: curvedAnimation,
      child: SlideTransition(
        position: slideAnimation,
        child: ScaleTransition(scale: scaleAnimation, child: child),
      ),
    );
  }
}

class _AuthProviderOptions extends StatelessWidget {
  const _AuthProviderOptions({
    required this.enabled,
    required this.isBusy,
    required this.onGoogle,
    required this.onApple,
    required this.onEmail,
    super.key,
  });

  final bool enabled;
  final bool isBusy;
  final VoidCallback onGoogle;
  final VoidCallback onApple;
  final VoidCallback onEmail;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _NeraluneAuthButton.google(
          enabled: enabled,
          label: isBusy ? 'Connexion en cours...' : 'Continuer avec Google',
          onPressed: onGoogle,
        ),
        const SizedBox(height: RevisionSpacing.m),
        _NeraluneAuthButton.apple(
          enabled: enabled,
          label: 'Continuer avec Apple',
          onPressed: onApple,
        ),
        const SizedBox(height: RevisionSpacing.m),
        _NeraluneAuthButton.email(
          key: const ValueKey('email-auth-open-button'),
          enabled: enabled,
          label: 'Continuer avec email',
          onPressed: onEmail,
        ),
      ],
    );
  }
}

class _EmailAuthForm extends StatelessWidget {
  const _EmailAuthForm({
    required this.emailController,
    required this.passwordController,
    required this.enabled,
    required this.isCreatingAccount,
    required this.obscurePassword,
    required this.onTogglePassword,
    required this.onSubmit,
    required this.onToggleMode,
    required this.onResetPassword,
    required this.onShowProviderOptions,
    super.key,
  });

  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool enabled;
  final bool isCreatingAccount;
  final bool obscurePassword;
  final VoidCallback onTogglePassword;
  final VoidCallback onSubmit;
  final VoidCallback onToggleMode;
  final VoidCallback onResetPassword;
  final VoidCallback onShowProviderOptions;

  @override
  Widget build(BuildContext context) {
    final submitLabel = isCreatingAccount ? 'Créer mon compte' : 'Se connecter';

    return AutofillGroup(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              key: const ValueKey('email-auth-back-button'),
              onPressed: enabled ? onShowProviderOptions : null,
              icon: const Icon(Icons.arrow_back_rounded, size: 18),
              label: const Text('Autres méthodes'),
              style: TextButton.styleFrom(
                foregroundColor: RevisionColors.textMuted,
                textStyle: RevisionTypography.caption.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(height: RevisionSpacing.xs),
          _EmailAuthTextField(
            key: const ValueKey('email-auth-email-field'),
            controller: emailController,
            label: 'Adresse email',
            enabled: enabled,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.email],
            icon: Icons.alternate_email_rounded,
          ),
          const SizedBox(height: RevisionSpacing.s),
          _EmailAuthTextField(
            key: const ValueKey('email-auth-password-field'),
            controller: passwordController,
            label: 'Mot de passe',
            enabled: enabled,
            obscureText: obscurePassword,
            textInputAction: TextInputAction.done,
            autofillHints: isCreatingAccount
                ? const [AutofillHints.newPassword]
                : const [AutofillHints.password],
            icon: Icons.lock_outline_rounded,
            onSubmitted: (_) => enabled ? onSubmit() : null,
            suffixIcon: IconButton(
              tooltip: obscurePassword
                  ? 'Afficher le mot de passe'
                  : 'Masquer le mot de passe',
              onPressed: enabled ? onTogglePassword : null,
              icon: Icon(
                obscurePassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
              ),
            ),
          ),
          const SizedBox(height: RevisionSpacing.m),
          _EmailAuthPrimaryButton(
            key: const ValueKey('email-auth-submit-button'),
            label: submitLabel,
            enabled: enabled,
            onPressed: onSubmit,
          ),
          const SizedBox(height: RevisionSpacing.s),
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: RevisionSpacing.s,
            runSpacing: RevisionSpacing.xs,
            children: [
              TextButton(
                key: const ValueKey('email-auth-toggle-mode-button'),
                onPressed: enabled ? onToggleMode : null,
                style: _emailTextButtonStyle(),
                child: Text(
                  isCreatingAccount ? 'J’ai déjà un compte' : 'Créer un compte',
                ),
              ),
              if (!isCreatingAccount)
                TextButton(
                  key: const ValueKey('email-auth-reset-button'),
                  onPressed: enabled ? onResetPassword : null,
                  style: _emailTextButtonStyle(),
                  child: const Text('Mot de passe oublié'),
                ),
            ],
          ),
        ],
      ),
    );
  }

  ButtonStyle _emailTextButtonStyle() {
    return TextButton.styleFrom(
      foregroundColor: RevisionColors.cyan,
      disabledForegroundColor: RevisionColors.textFaint,
      textStyle: RevisionTypography.caption.copyWith(
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

class _EmailAuthTextField extends StatelessWidget {
  const _EmailAuthTextField({
    required this.controller,
    required this.label,
    required this.enabled,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.icon,
    this.suffixIcon,
    this.obscureText = false,
    this.onSubmitted,
    super.key,
  });

  final TextEditingController controller;
  final String label;
  final bool enabled;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final IconData? icon;
  final Widget? suffixIcon;
  final bool obscureText;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      autofillHints: autofillHints,
      obscureText: obscureText,
      onSubmitted: onSubmitted,
      style: RevisionTypography.body.copyWith(color: RevisionColors.text),
      cursorColor: RevisionColors.cyan,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: RevisionTypography.caption,
        prefixIcon: icon == null ? null : Icon(icon),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: RevisionColors.glassSoft,
        border: OutlineInputBorder(
          borderRadius: RevisionRadius.radiusL,
          borderSide: const BorderSide(color: RevisionColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: RevisionRadius.radiusL,
          borderSide: const BorderSide(color: RevisionColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: RevisionRadius.radiusL,
          borderSide: const BorderSide(color: RevisionColors.cyan, width: 1.4),
        ),
      ),
    );
  }
}

class _EmailAuthPrimaryButton extends StatelessWidget {
  const _EmailAuthPrimaryButton({
    required this.label,
    required this.enabled,
    required this.onPressed,
    super.key,
  });

  final String label;
  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onPressed : null,
        borderRadius: RevisionRadius.radiusL,
        child: AnimatedOpacity(
          opacity: enabled ? 1 : 0.58,
          duration: const Duration(milliseconds: 160),
          child: Ink(
            height: 54,
            decoration: BoxDecoration(
              borderRadius: RevisionRadius.radiusL,
              gradient: const LinearGradient(
                colors: [RevisionColors.cyan, RevisionColors.blue],
              ),
              boxShadow: [
                BoxShadow(
                  color: RevisionColors.cyan.withValues(alpha: 0.28),
                  blurRadius: 18,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Center(
              child: Text(
                label,
                style: const TextStyle(
                  color: RevisionColors.ink,
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AuthInfoMessage extends StatelessWidget {
  const _AuthInfoMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return RevisionGlassCard(
      padding: const EdgeInsets.all(RevisionSpacing.m),
      borderColor: RevisionColors.mint.withValues(alpha: 0.50),
      backgroundColor: RevisionColors.mint.withValues(alpha: 0.08),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle_outline_rounded,
            color: RevisionColors.mint,
          ),
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
    super.key,
  });

  factory _NeraluneAuthButton.google({
    required String label,
    required VoidCallback onPressed,
    required bool enabled,
    Key? key,
  }) {
    return _NeraluneAuthButton._(
      key: key,
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
    Key? key,
  }) {
    return _NeraluneAuthButton._(
      key: key,
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

  factory _NeraluneAuthButton.email({
    required String label,
    required VoidCallback onPressed,
    required bool enabled,
    Key? key,
  }) {
    return _NeraluneAuthButton._(
      key: key,
      label: label,
      onPressed: onPressed,
      enabled: enabled,
      backgroundColor: RevisionColors.glassSoft,
      foregroundColor: RevisionColors.text,
      borderColor: RevisionColors.cyan.withValues(alpha: 0.48),
      semanticLabel: 'Continuer avec email',
      icon: const Icon(
        Icons.mail_outline_rounded,
        color: RevisionColors.cyan,
        size: 24,
      ),
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
