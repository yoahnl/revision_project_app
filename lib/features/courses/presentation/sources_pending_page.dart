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
      headerChildren: [
        Text('Sources', style: RevisionTypography.pageTitle),
        const SizedBox(height: RevisionSpacing.xs),
        Text(
          'Les sources se gèrent depuis les cours.',
          style: RevisionTypography.body,
        ),
      ],
      children: [
        RevisionEmptyState(
          title: 'Les sources se gèrent depuis les cours',
          message:
              'Ouvre un cours pour importer, consulter ou supprimer ses PDF. Le catalogue global arrivera plus tard.',
          icon: Icons.description_outlined,
          actionLabel: 'Ouvrir les cours',
          onAction: () => context.go(AppRoutes.home),
        ),
      ],
    );
  }
}
