import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_routes.dart';
import '../../../presentation/design_system/components/revision_mvp_components.dart';
import '../../../presentation/design_system/components/revision_states.dart';
import '../../../presentation/design_system/tokens/revision_spacing.dart';
import '../../../presentation/design_system/tokens/revision_typography.dart';

class SourcesPendingPage extends StatelessWidget {
  const SourcesPendingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return RevisionPageScaffold(
      children: [
        Text('Sources', style: RevisionTypography.pageTitle),
        const SizedBox(height: RevisionSpacing.xs),
        Text(
          'Les PDF réels sont déjà gérés par l’ancien flow documents. Leur rattachement aux cours arrive après Course.',
          style: RevisionTypography.body,
        ),
        RevisionEmptyState(
          title: 'Sources réelles en attente',
          message:
              'CORE-03 branchera l’ajout de PDF depuis un cours réel. Aucun fichier fictif n’est listé ici.',
          icon: Icons.description_outlined,
          actionLabel: 'Ouvrir les matières',
          onAction: () => context.go(AppRoutes.subjects),
        ),
      ],
    );
  }
}
