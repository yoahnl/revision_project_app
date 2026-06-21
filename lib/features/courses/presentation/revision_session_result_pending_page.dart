import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_routes.dart';
import '../../../presentation/design_system/components/revision_mvp_components.dart';
import '../../../presentation/design_system/components/revision_states.dart';
import '../../../presentation/design_system/tokens/revision_spacing.dart';
import '../../../presentation/design_system/tokens/revision_typography.dart';

class RevisionSessionResultPendingPage extends StatelessWidget {
  const RevisionSessionResultPendingPage({required this.sessionId, super.key});

  final String sessionId;

  @override
  Widget build(BuildContext context) {
    return RevisionPageScaffold(
      children: [
        Text('Résultat de session', style: RevisionTypography.pageTitle),
        const SizedBox(height: RevisionSpacing.xs),
        Text(
          'Le résultat sera affiché après une session terminée.',
          style: RevisionTypography.body,
        ),
        RevisionEmptyState(
          title: 'Résultat indisponible',
          message:
              'Aucun score n’est affiché tant qu’une session n’a pas été finalisée.',
          icon: Icons.emoji_events_outlined,
          actionLabel: 'Retour aux révisions',
          onAction: () => context.go(AppRoutes.revisions),
        ),
      ],
    );
  }
}
