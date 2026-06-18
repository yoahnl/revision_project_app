import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_routes.dart';
import '../../../presentation/design_system/components/revision_mvp_components.dart';
import '../../../presentation/design_system/tokens/revision_colors.dart';
import '../../../presentation/design_system/tokens/revision_spacing.dart';
import '../../../presentation/design_system/tokens/revision_typography.dart';
import '../application/mvp_study_controller.dart';
import '../domain/mvp_study_models.dart';
import 'mvp_page_helpers.dart';

class MvpSessionResultPage extends StatelessWidget {
  const MvpSessionResultPage({
    required this.sessionId,
    this.courseId,
    this.mode,
    super.key,
  });

  final String sessionId;
  final String? courseId;
  final String? mode;

  @override
  Widget build(BuildContext context) {
    final course = MvpStudyController.instance.courseOrFallback(
      courseId ?? MvpStudyController.instance.resumeCourse.id,
    );

    return RevisionPageScaffold(
      children: [
        const MvpBackBar(title: 'Session terminée'),
        const RevisionConfettiStrip(),
        RevisionGlassCard(
          child: Column(
            children: [
              const RevisionMasteryRing(
                value: 0.78,
                label: '78%',
                caption: '4/5 bonnes',
                size: 116,
                color: RevisionColors.green,
              ),
              const SizedBox(height: RevisionSpacing.l),
              Text(
                'Belle progression !',
                style: RevisionTypography.pageTitle.copyWith(fontSize: 22),
              ),
              const SizedBox(height: RevisionSpacing.xs),
              Text(
                'Tu comprends mieux ${course.title.toLowerCase()}.',
                style: RevisionTypography.body,
              ),
            ],
          ),
        ),
        const RevisionSectionHeader(title: 'Tu maîtrises'),
        RevisionGlassCard(
          child: Row(
            children: [
              const Icon(
                Icons.check_circle_rounded,
                color: RevisionColors.green,
              ),
              const SizedBox(width: RevisionSpacing.m),
              Expanded(
                child: Text(
                  'Propriétés et utilisation',
                  style: RevisionTypography.body.copyWith(
                    color: RevisionColors.text,
                  ),
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: RevisionColors.textMuted,
              ),
            ],
          ),
        ),
        const RevisionSectionHeader(title: 'À retravailler'),
        RevisionGlassCard(
          child: Row(
            children: [
              const Icon(Icons.warning_rounded, color: RevisionColors.amber),
              const SizedBox(width: RevisionSpacing.m),
              Expanded(
                child: Text(
                  course.weakSpot,
                  style: RevisionTypography.body.copyWith(
                    color: RevisionColors.text,
                  ),
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: RevisionColors.textMuted,
              ),
            ],
          ),
        ),
        const RevisionSectionHeader(title: 'Prochaine étape'),
        RevisionGlassCard(
          onTap: () => context.go(AppRoutes.course(course.id)),
          child: Row(
            children: [
              const Icon(
                Icons.auto_awesome_rounded,
                color: RevisionColors.violet,
              ),
              const SizedBox(width: RevisionSpacing.m),
              Expanded(
                child: Text(
                  'Révision approfondie sur ${course.title.toLowerCase()}',
                  style: RevisionTypography.body.copyWith(
                    color: RevisionColors.text,
                  ),
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: RevisionColors.textMuted,
              ),
            ],
          ),
        ),
        RevisionGradientButton(
          label: 'Voir la fiche complète',
          expanded: true,
          gradient: const LinearGradient(
            colors: [RevisionColors.glassStrong, RevisionColors.glass],
          ),
          onPressed: () => context.go(AppRoutes.courseSheet(course.id)),
        ),
        RevisionGradientButton(
          label: 'Lancer la préparation examen',
          expanded: true,
          onPressed: () => context.go(
            AppRoutes.revisionSessionV2(
              sessionId: 'session-${course.id}-${MvpRevisionMode.exam.name}',
              courseId: course.id,
              mode: MvpRevisionMode.exam.name,
            ),
          ),
        ),
      ],
    );
  }
}
