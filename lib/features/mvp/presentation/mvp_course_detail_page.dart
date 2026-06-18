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

class MvpCourseDetailPage extends StatelessWidget {
  const MvpCourseDetailPage({required this.courseId, super.key});

  final String courseId;

  @override
  Widget build(BuildContext context) {
    final course = MvpStudyController.instance.courseOrFallback(courseId);
    final subject = MvpStudyController.instance.subjects.firstWhere(
      (subject) => subject.id == course.subjectId,
    );

    return RevisionPageScaffold(
      children: [
        MvpBackBar(
          trailing: Wrap(
            spacing: RevisionSpacing.s,
            children: [
              mvpSmallPill(
                icon: Icons.description_outlined,
                label: 'Fiche',
                color: RevisionColors.textMuted,
              ),
              GestureDetector(
                onTap: () => showMvpSourcesSheet(context, course),
                child: mvpSmallPill(
                  icon: Icons.folder_copy_outlined,
                  label: 'Sources',
                  color: RevisionColors.textMuted,
                ),
              ),
            ],
          ),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RevisionIconTile(
              icon: course.icon,
              accent: course.accent,
              size: 64,
              iconSize: 36,
            ),
            const SizedBox(width: RevisionSpacing.l),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subject.name,
                    style: RevisionTypography.caption.copyWith(
                      color: subject.accent,
                    ),
                  ),
                  Text(course.title, style: RevisionTypography.pageTitle),
                  const SizedBox(height: RevisionSpacing.xs),
                  Text(
                    '${course.chapterLabel} · ${course.durationMinutes} min',
                    style: RevisionTypography.body,
                  ),
                ],
              ),
            ),
          ],
        ),
        Text(
          course.description,
          style: RevisionTypography.body.copyWith(color: RevisionColors.text),
        ),
        RevisionStatTriplet(
          items: [
            RevisionStatItem(
              icon: Icons.track_changes_rounded,
              label: 'Progression',
              value: course.progressLabel,
              color: RevisionColors.cyan,
            ),
            RevisionStatItem(
              icon: Icons.schedule_rounded,
              label: 'Temps estimé',
              value: '${course.durationMinutes} min',
              color: RevisionColors.textMuted,
            ),
            RevisionStatItem(
              icon: Icons.star_border_rounded,
              label: 'Difficulté',
              value: course.difficulty,
              color: RevisionColors.amber,
            ),
          ],
        ),
        Column(
          children: [
            RevisionModeCard(
              title: 'Révision rapide',
              description: 'Synthèse essentielle',
              icon: Icons.flash_on_rounded,
              accent: RevisionColors.blue,
              onTap: () =>
                  _startSession(context, course, MvpRevisionMode.quick),
            ),
            const SizedBox(height: RevisionSpacing.m),
            RevisionModeCard(
              title: 'Révision approfondie',
              description: 'Cours complet et exemples',
              icon: Icons.menu_book_rounded,
              accent: RevisionColors.violet,
              onTap: () => _startSession(context, course, MvpRevisionMode.deep),
            ),
            const SizedBox(height: RevisionSpacing.m),
            RevisionModeCard(
              title: 'Préparation examen',
              description: 'Exercices et sujets corrigés',
              icon: Icons.ads_click_rounded,
              accent: RevisionColors.pink,
              onTap: () => _startSession(context, course, MvpRevisionMode.exam),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: RevisionGradientButton(
                label: 'Voir la fiche',
                icon: Icons.article_outlined,
                expanded: true,
                onPressed: () => context.go(AppRoutes.courseSheet(course.id)),
              ),
            ),
            const SizedBox(width: RevisionSpacing.m),
            Expanded(
              child: RevisionGradientButton(
                label: 'Sources',
                icon: Icons.folder_copy_outlined,
                expanded: true,
                gradient: const LinearGradient(
                  colors: [RevisionColors.glassStrong, RevisionColors.glass],
                ),
                onPressed: () => showMvpSourcesSheet(context, course),
              ),
            ),
          ],
        ),
        RevisionSectionHeader(title: 'Ce que tu vas apprendre'),
        RevisionGlassCard(
          child: Column(
            children: [
              for (final item in course.learnItems) ...[
                mvpLearnItem(item),
                if (item != course.learnItems.last)
                  const SizedBox(height: RevisionSpacing.m),
              ],
            ],
          ),
        ),
      ],
    );
  }

  void _startSession(
    BuildContext context,
    MvpCourse course,
    MvpRevisionMode mode,
  ) {
    context.go(
      AppRoutes.revisionSessionV2(
        sessionId: 'session-${course.id}-${mode.name}',
        courseId: course.id,
        mode: mode.name,
      ),
    );
  }
}
