import 'package:flutter/material.dart';
import 'package:Neralune/features/auth/application/auth_controller.dart';
import 'package:Neralune/presentation/design_system/components/revision_mvp_components.dart';
import 'package:Neralune/presentation/design_system/tokens/revision_colors.dart';
import 'package:Neralune/presentation/design_system/tokens/revision_spacing.dart';
import 'package:Neralune/presentation/design_system/tokens/revision_typography.dart';
import 'package:Neralune/presentation/widgets/theme_mode_selector.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({required this.authController, super.key});

  final AuthController authController;

  @override
  Widget build(BuildContext context) {
    return RevisionPageScaffold(
      headerChildren: const [
        Text('Profil', style: RevisionTypography.pageTitle),
        Text(
          'Gère ton compte et tes préférences d’affichage.',
          style: RevisionTypography.body,
        ),
      ],
      children: [ProfileContent(authController: authController)],
    );
  }
}

class ProfileContent extends StatelessWidget {
  const ProfileContent({required this.authController, super.key});

  final AuthController authController;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: authController,
      builder: (context, _) {
        final user = authController.user;
        final displayName = user?.displayName?.trim();
        final primaryLabel = displayName == null || displayName.isEmpty
            ? 'Étudiant'
            : displayName;
        final secondaryLabel = user?.email ?? user?.uid ?? 'Compte connecté';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            RevisionGlassCard(
              padding: const EdgeInsets.all(RevisionSpacing.l),
              child: Row(
                children: [
                  const RevisionIconTile(
                    icon: Icons.person_rounded,
                    accent: RevisionColors.cyan,
                    size: 56,
                  ),
                  const SizedBox(width: RevisionSpacing.l),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          primaryLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: RevisionTypography.sectionTitle.copyWith(
                            fontSize: 20,
                          ),
                        ),
                        const SizedBox(height: RevisionSpacing.xs),
                        Text(
                          secondaryLabel,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: RevisionTypography.body,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: RevisionSpacing.l),
            RevisionGlassCard(
              padding: const EdgeInsets.all(RevisionSpacing.l),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Thème', style: RevisionTypography.sectionTitle),
                  SizedBox(height: RevisionSpacing.s),
                  Text(
                    'Choisis l’apparence de l’application sur cet appareil.',
                    style: RevisionTypography.body,
                  ),
                  SizedBox(height: RevisionSpacing.m),
                  ThemeModeSelector(),
                ],
              ),
            ),
            const SizedBox(height: RevisionSpacing.l),
            RevisionActionListTile(
              onTap: authController.isBusy ? null : authController.signOut,
              enabled: !authController.isBusy,
              title: authController.isBusy
                  ? 'Déconnexion en cours...'
                  : 'Se déconnecter',
              subtitle: 'Tu pourras te reconnecter avec ton compte.',
              icon: Icons.logout_rounded,
              accent: RevisionColors.red,
              trailing: const Icon(
                Icons.arrow_forward_rounded,
                color: RevisionColors.textMuted,
              ),
            ),
          ],
        );
      },
    );
  }
}
