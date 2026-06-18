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
          title: 'Route V2 en attente',
          message:
              'Les sessions réelles du MVP Core passent par Activités. Cette route sera reprise plus tard pour le parcours V2.',
          icon: Icons.track_changes_rounded,
          actionLabel: 'Ouvrir les activités',
          onAction: () => context.go(AppRoutes.activities),
        ),
      ],
    );
  }
}
