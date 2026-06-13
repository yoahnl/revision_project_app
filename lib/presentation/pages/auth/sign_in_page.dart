import 'package:flutter/material.dart';
import 'package:revision_app/features/auth/application/auth_controller.dart';
import 'package:revision_app/presentation/theme/app_colors.dart';
import 'package:revision_app/presentation/theme/app_spacing.dart';
import 'package:revision_app/presentation/widgets/revision_background.dart';
import 'package:revision_app/presentation/widgets/revision_button.dart';
import 'package:revision_app/presentation/widgets/revision_icon_badge.dart';
import 'package:revision_app/presentation/widgets/revision_message.dart';
import 'package:revision_app/presentation/widgets/revision_panel.dart';

class SignInPage extends StatelessWidget {
  const SignInPage({required this.authController, super.key});

  final AuthController authController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: RevisionBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 430),
                child: RevisionPanel(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: ListenableBuilder(
                    listenable: authController,
                    builder: (context, _) {
                      final errorMessage = authController.errorMessage;

                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Align(
                            child: RevisionIconBadge(
                              icon: Icons.auto_awesome,
                              color: AppColors.primaryDark,
                              size: 52,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.l),
                          Text(
                            'Connexion',
                            style: Theme.of(context).textTheme.headlineMedium,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppSpacing.s),
                          Text(
                            'Retrouve tes matieres, tes cours et ton coach IA.',
                            style: Theme.of(context).textTheme.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppSpacing.xl),
                          if (errorMessage != null) ...[
                            RevisionMessage(
                              message: errorMessage,
                              color: Theme.of(context).colorScheme.error,
                              icon: Icons.error_outline,
                            ),
                            const SizedBox(height: AppSpacing.l),
                          ],
                          RevisionButton(
                            onPressed: authController.isBusy
                                ? null
                                : authController.signInWithGoogle,
                            icon: Icons.login,
                            label: 'Continuer avec Google',
                            expand: true,
                          ),
                          const SizedBox(height: AppSpacing.m),
                          RevisionButton(
                            onPressed: authController.isBusy
                                ? null
                                : authController.signInWithApple,
                            icon: Icons.apple,
                            label: 'Continuer avec Apple',
                            style: RevisionButtonStyle.ghost,
                            expand: true,
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
