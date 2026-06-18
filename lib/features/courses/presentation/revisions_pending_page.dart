import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_routes.dart';
import '../../../presentation/design_system/components/revision_mvp_components.dart';
import '../../../presentation/design_system/components/revision_states.dart';
import '../../../presentation/design_system/tokens/revision_colors.dart';
import '../../../presentation/design_system/tokens/revision_spacing.dart';
import '../../../presentation/design_system/tokens/revision_typography.dart';

class RevisionsPendingPage extends StatelessWidget {
  const RevisionsPendingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return RevisionPageScaffold(
      children: [
        Text('Révisions', style: RevisionTypography.pageTitle),
        const SizedBox(height: RevisionSpacing.xs),
        Text(
          'Les sessions réelles seront lancées depuis un cours réel. Aucun exercice local n’est utilisé ici.',
          style: RevisionTypography.body,
        ),
        const RevisionEmptyState(
          title: 'Révisions réelles en attente',
          message:
              'CORE-05 branchera la révision rapide sur RevisionSession et les résultats backend.',
          icon: Icons.track_changes_rounded,
        ),
        _ModeAvailabilityCard(
          title: 'Révision rapide',
          label: 'MVP Core · à brancher en CORE-05',
          icon: Icons.flash_on_rounded,
          accent: RevisionColors.blue,
        ),
        _ModeAvailabilityCard(
          title: 'Révision approfondie',
          label: 'MVP+ · bientôt',
          icon: Icons.menu_book_rounded,
          accent: RevisionColors.violet,
        ),
        _ModeAvailabilityCard(
          title: 'Préparation examen',
          label: 'MVP+ · bientôt',
          icon: Icons.gps_fixed_rounded,
          accent: RevisionColors.pink,
        ),
        RevisionEmptyState(
          title: 'Besoin d’un flow réel maintenant ?',
          message:
              'Les anciens exercices réels restent disponibles dans Activités.',
          icon: Icons.check_circle_outline_rounded,
          actionLabel: 'Ouvrir les activités',
          onAction: () => context.go(AppRoutes.activities),
        ),
      ],
    );
  }
}

class _ModeAvailabilityCard extends StatelessWidget {
  const _ModeAvailabilityCard({
    required this.title,
    required this.label,
    required this.icon,
    required this.accent,
  });

  final String title;
  final String label;
  final IconData icon;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return RevisionGlassCard(
      child: Row(
        children: [
          RevisionIconTile(icon: icon, accent: accent),
          const SizedBox(width: RevisionSpacing.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: RevisionTypography.sectionTitle),
                const SizedBox(height: RevisionSpacing.xs),
                Text(label, style: RevisionTypography.body),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
