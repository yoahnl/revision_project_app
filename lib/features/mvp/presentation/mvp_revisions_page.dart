import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_routes.dart';
import '../../../presentation/design_system/components/revision_mvp_components.dart';
import '../../../presentation/design_system/tokens/revision_colors.dart';
import '../application/mvp_study_controller.dart';
import '../domain/mvp_study_models.dart';
import 'mvp_page_helpers.dart';

class MvpRevisionsPage extends StatelessWidget {
  const MvpRevisionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: MvpStudyController.instance,
      builder: (context, child) {
        final course = MvpStudyController.instance.resumeCourse;

        return RevisionPageScaffold(
          children: [
            const MvpTopBar(),
            const RevisionSectionHeader(
              title: 'Révisions',
              subtitle: 'Choisis ton mode de travail',
            ),
            RevisionModeCard(
              title: 'Révision rapide',
              description:
                  'Sessions courtes et ciblées pour réactiver l’essentiel.',
              icon: Icons.flash_on_rounded,
              accent: RevisionColors.blue,
              onTap: () => _start(context, course, MvpRevisionMode.quick),
            ),
            RevisionModeCard(
              title: 'Révision approfondie',
              description: 'Cours complets et exemples détaillés.',
              icon: Icons.menu_book_rounded,
              accent: RevisionColors.violet,
              onTap: () => _start(context, course, MvpRevisionMode.deep),
            ),
            RevisionModeCard(
              title: 'Préparation examen',
              description:
                  'Entraînements et sujets corrigés pour être prêt le jour J.',
              icon: Icons.ads_click_rounded,
              accent: RevisionColors.pink,
              onTap: () => _start(context, course, MvpRevisionMode.exam),
            ),
            RevisionSectionHeader(title: 'Recommandé aujourd’hui'),
            RevisionCourseCard(
              title: course.title,
              progressLabel:
                  '${course.chapterLabel} · ${course.durationMinutes} min',
              durationLabel: '${course.durationMinutes} min',
              progress: course.progress,
              accent: course.accent,
              icon: course.icon,
              onTap: () => context.go(AppRoutes.course(course.id)),
            ),
          ],
        );
      },
    );
  }

  void _start(BuildContext context, MvpCourse course, MvpRevisionMode mode) {
    context.go(
      AppRoutes.revisionSessionV2(
        sessionId: 'session-${course.id}-${mode.name}',
        courseId: course.id,
        mode: mode.name,
      ),
    );
  }
}
