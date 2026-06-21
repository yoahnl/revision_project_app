import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_routes.dart';
import '../../../presentation/design_system/components/revision_mvp_components.dart';
import '../../../presentation/design_system/components/revision_states.dart';
import '../../../presentation/design_system/tokens/revision_spacing.dart';
import '../../../presentation/design_system/tokens/revision_typography.dart';

class CoursePendingPage extends StatelessWidget {
  const CoursePendingPage({
    required this.title,
    required this.message,
    this.actionLabel = 'Retour à l’accueil',
    super.key,
  });

  final String title;
  final String message;
  final String actionLabel;

  @override
  Widget build(BuildContext context) {
    return RevisionPageScaffold(
      children: [
        Text(title, style: RevisionTypography.pageTitle),
        const SizedBox(height: RevisionSpacing.xs),
        Text(message, style: RevisionTypography.body),
        RevisionEmptyState(
          title: 'Page bientôt disponible',
          message:
              'Cette page est conservée pour un prochain parcours. Reviens à l’accueil pour continuer.',
          icon: Icons.pending_actions_rounded,
          actionLabel: actionLabel,
          onAction: () => context.go(AppRoutes.home),
        ),
      ],
    );
  }
}
