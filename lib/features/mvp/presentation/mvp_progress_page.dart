import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_routes.dart';
import '../../../presentation/design_system/components/revision_mvp_components.dart';
import '../../../presentation/design_system/tokens/revision_colors.dart';
import '../../../presentation/design_system/tokens/revision_spacing.dart';
import '../../../presentation/design_system/tokens/revision_typography.dart';
import '../application/mvp_study_controller.dart';
import 'mvp_page_helpers.dart';

class MvpProgressPage extends StatelessWidget {
  const MvpProgressPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: MvpStudyController.instance,
      builder: (context, child) {
        final controller = MvpStudyController.instance;
        final subject = controller.activeSubject;
        final mastery = controller.activeMastery;
        final weakCourse = subject.courses.reduce(
          (a, b) => a.mastery <= b.mastery ? a : b,
        );

        return RevisionPageScaffold(
          children: [
            const MvpTopBar(),
            const RevisionSectionHeader(
              title: 'Progrès',
              subtitle: 'Ta progression en un coup d’œil',
            ),
            RevisionGlassCard(
              child: Row(
                children: [
                  RevisionMasteryRing(
                    value: mastery,
                    label: '${(mastery * 100).round()}%',
                    size: 72,
                    color: RevisionColors.green,
                  ),
                  const SizedBox(width: RevisionSpacing.l),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bien joué !',
                          style: RevisionTypography.sectionTitle,
                        ),
                        const SizedBox(height: RevisionSpacing.xs),
                        Text(
                          'Tu es sur la bonne voie.',
                          style: RevisionTypography.body,
                        ),
                        const SizedBox(height: RevisionSpacing.m),
                        RevisionProgressLine(
                          value: mastery,
                          color: RevisionColors.blue,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            RevisionSectionHeader(title: 'Tes cours de ${subject.name}'),
            Column(
              children: [
                for (final course in subject.courses) ...[
                  RevisionCourseCard(
                    title: course.title,
                    progressLabel: course.progressLabel,
                    durationLabel: '${(course.mastery * 100).round()}%',
                    progress: course.mastery,
                    accent: course.accent,
                    icon: course.icon,
                    onTap: () => context.go(AppRoutes.course(course.id)),
                  ),
                  if (course != subject.courses.last)
                    const SizedBox(height: RevisionSpacing.m),
                ],
              ],
            ),
            const RevisionSectionHeader(title: 'Points faibles'),
            RevisionGlassCard(
              onTap: () => context.go(AppRoutes.course(weakCourse.id)),
              child: Row(
                children: [
                  RevisionIconTile(
                    icon: Icons.priority_high_rounded,
                    accent: RevisionColors.amber,
                    size: 38,
                  ),
                  const SizedBox(width: RevisionSpacing.m),
                  Expanded(
                    child: Text(
                      weakCourse.weakSpot,
                      style: RevisionTypography.sectionTitle.copyWith(
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Text(
                    'À revoir',
                    style: RevisionTypography.caption.copyWith(
                      color: RevisionColors.amber,
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: RevisionColors.textMuted,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
