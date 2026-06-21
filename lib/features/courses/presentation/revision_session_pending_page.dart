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
          'Cette page sera utilisée par les prochains parcours de révision.',
          style: RevisionTypography.body,
        ),
        RevisionEmptyState(
          title: 'Session indisponible',
          message:
              'Pour le moment, lance une session rapide depuis un cours prêt.',
          icon: Icons.track_changes_rounded,
          actionLabel: 'Retour aux révisions',
          onAction: () => context.go(AppRoutes.revisions),
        ),
      ],
    );
  }
}
