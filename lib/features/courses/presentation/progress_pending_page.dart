import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_routes.dart';
import '../../../presentation/design_system/components/revision_mvp_components.dart';
import '../../../presentation/design_system/components/revision_states.dart';
import '../../../presentation/design_system/tokens/revision_spacing.dart';
import '../../../presentation/design_system/tokens/revision_typography.dart';

class ProgressPendingPage extends StatelessWidget {
  const ProgressPendingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return RevisionPageScaffold(
      children: [
        Text('Progrès', style: RevisionTypography.pageTitle),
        const SizedBox(height: RevisionSpacing.xs),
        Text(
          'La progression réelle sera calculée depuis les cours, sources et résultats persistés.',
          style: RevisionTypography.body,
        ),
        RevisionEmptyState(
          title: 'Progression réelle en attente',
          message:
              'Aucun pourcentage fictif n’est affiché. Les métriques seront calculées depuis des résultats backend réels.',
          icon: Icons.trending_up_rounded,
          actionLabel: 'Retour à l’accueil',
          onAction: () => context.go(AppRoutes.home),
        ),
      ],
    );
  }
}
