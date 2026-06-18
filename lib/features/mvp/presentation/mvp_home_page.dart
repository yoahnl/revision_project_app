import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_routes.dart';
import '../../../presentation/design_system/components/revision_mvp_components.dart';
import '../../../presentation/design_system/tokens/revision_colors.dart';
import '../../../presentation/design_system/tokens/revision_spacing.dart';
import '../../../presentation/design_system/tokens/revision_typography.dart';
import '../application/mvp_study_controller.dart';
import 'mvp_page_helpers.dart';

class MvpHomePage extends StatelessWidget {
  const MvpHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: MvpStudyController.instance,
      builder: (context, child) {
        final controller = MvpStudyController.instance;
        final subject = controller.activeSubject;
        final resumeCourse = controller.resumeCourse;

        return RevisionPageScaffold(
          children: [
            const MvpTopBar(),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(subject.name, style: RevisionTypography.hero),
                      const SizedBox(height: RevisionSpacing.xs),
                      Text(subject.subtitle, style: RevisionTypography.body),
                    ],
                  ),
                ),
                RevisionMasteryRing(
                  value: 0.72,
                  label: '7',
                  caption: 'jours',
                  size: 74,
                  color: subject.accent == RevisionColors.pink
                      ? RevisionColors.pink
                      : RevisionColors.green,
                ),
              ],
            ),
            RevisionResumeCourseCard(
              title: resumeCourse.title,
              subtitle: 'Reprendre le cours',
              progressLabel:
                  'Leçon ${resumeCourse.completedLessons} sur ${resumeCourse.totalLessons}',
              progress: resumeCourse.progress,
              accent: subject.accent,
              icon: resumeCourse.icon,
              onContinue: () => context.go(AppRoutes.course(resumeCourse.id)),
            ),
            RevisionSectionHeader(title: 'Tes cours de ${subject.name}'),
            Column(
              children: [
                for (final course in subject.courses) ...[
                  RevisionCourseCard(
                    title: course.title,
                    progressLabel: course.progressLabel,
                    durationLabel: '${course.durationMinutes} min',
                    progress: course.progress,
                    accent: course.accent,
                    icon: course.icon,
                    onTap: () => context.go(AppRoutes.course(course.id)),
                  ),
                  if (course != subject.courses.last)
                    const SizedBox(height: RevisionSpacing.m),
                ],
              ],
            ),
          ],
        );
      },
    );
  }
}
