import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_routes.dart';
import '../../../presentation/design_system/components/revision_mvp_components.dart';
import '../../../presentation/design_system/components/revision_states.dart';
import '../../../presentation/design_system/tokens/revision_spacing.dart';
import '../../../presentation/design_system/tokens/revision_typography.dart';

class CourseNotFoundPage extends StatelessWidget {
  const CourseNotFoundPage({required this.courseId, super.key});

  final String courseId;

  @override
  Widget build(BuildContext context) {
    return RevisionPageScaffold(
      children: [
        Text('Cours introuvable', style: RevisionTypography.pageTitle),
        const SizedBox(height: RevisionSpacing.xs),
        Text(
          'Ce cours n’existe pas encore dans les données réelles.',
          style: RevisionTypography.body,
        ),
        RevisionNotFoundState(
          title: 'Aucun fallback vers un cours fictif',
          message:
              'La route demandée ne peut pas afficher de fixture. CORE-02 branchera les vrais cours sur cette page.',
          actionLabel: 'Retour à l’accueil',
          onAction: () => context.go(AppRoutes.home),
        ),
      ],
    );
  }
}
