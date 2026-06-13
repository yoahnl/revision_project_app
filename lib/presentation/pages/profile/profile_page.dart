import 'package:flutter/material.dart';
import 'package:revision_app/features/auth/application/auth_controller.dart';
import 'package:revision_app/presentation/theme/app_colors.dart';
import 'package:revision_app/presentation/theme/app_spacing.dart';
import 'package:revision_app/presentation/widgets/revision_button.dart';
import 'package:revision_app/presentation/widgets/revision_icon_badge.dart';
import 'package:revision_app/presentation/widgets/revision_page.dart';
import 'package:revision_app/presentation/widgets/revision_panel.dart';
import 'package:revision_app/presentation/widgets/theme_mode_selector.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({required this.authController, super.key});

  final AuthController authController;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: authController,
      builder: (context, _) {
        final user = authController.user;

        return RevisionPage(
          title: 'Profil',
          children: [
            RevisionPanel(
              child: Row(
                children: [
                  const RevisionIconBadge(
                    icon: Icons.person_outline,
                    color: AppColors.aqua,
                  ),
                  const SizedBox(width: AppSpacing.l),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.displayName ?? 'Etudiant',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          user?.email ?? user?.uid ?? '',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.l),
            RevisionPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Theme', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: AppSpacing.m),
                  const ThemeModeSelector(),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.l),
            Align(
              alignment: Alignment.centerLeft,
              child: RevisionButton(
                onPressed: authController.signOut,
                icon: Icons.logout,
                label: 'Se deconnecter',
                style: RevisionButtonStyle.ghost,
              ),
            ),
          ],
        );
      },
    );
  }
}
