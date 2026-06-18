import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_routes.dart';
import '../../../presentation/design_system/components/revision_mvp_components.dart';
import '../../../presentation/design_system/components/revision_states.dart';
import '../../../presentation/design_system/tokens/revision_spacing.dart';
import '../../../presentation/design_system/tokens/revision_typography.dart';

class RevisionSessionPendingPage extends StatelessWidget {
  const RevisionSessionPendingPage({required this.sessionId, super.key});

  final String sessionId;

  @override
  Widget build(BuildContext context) {
    return RevisionPageScaffold(
      children: [
        Text('Session de révision', style: RevisionTypography.pageTitle),
        const SizedBox(height: RevisionSpacing.xs),
        Text(
          'Cette route est conservée pour le futur parcours Course.',
          style: RevisionTypography.body,
        ),
        RevisionEmptyState(
          title: 'Session réelle indisponible',
          message:
              'Aucune question locale n’est chargée. CORE-05 branchera cette route sur RevisionSession et advance.',
          icon: Icons.track_changes_rounded,
          actionLabel: 'Ouvrir les activités',
          onAction: () => context.go(AppRoutes.activities),
        ),
      ],
    );
  }
}
