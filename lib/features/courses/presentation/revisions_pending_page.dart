import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_routes.dart';
import '../../../presentation/design_system/components/revision_mvp_components.dart';
import '../../../presentation/design_system/components/revision_states.dart';
import '../../../presentation/design_system/tokens/revision_colors.dart';
import '../../../presentation/design_system/tokens/revision_spacing.dart';
import '../../../presentation/design_system/tokens/revision_subject_visuals.dart';
import '../../../presentation/design_system/tokens/revision_typography.dart';
import '../application/active_subject_provider.dart';
import '../application/courses_providers.dart';
import '../domain/course_models.dart';
import 'course_quick_revision_launcher.dart';

class RevisionsPendingPage extends ConsumerWidget {
  const RevisionsPendingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeSubject = ref.watch(activeSubjectProvider);

    return RevisionPageScaffold(
      headerChildren: [
        Text('Réviser', style: RevisionTypography.hero),
        Text(
          'Choisis une session courte et utile.',
          style: RevisionTypography.body,
        ),
      ],
      children: [
        activeSubject.when(
          loading: () =>
              const RevisionLoadingState(label: 'Chargement des matières'),
          error: (error, stackTrace) => RevisionErrorState(
            title: 'Révisions indisponibles',
            message: 'Impossible de déterminer la matière active.',
            actionLabel: 'Retour à l’accueil',
            onAction: () => context.go(AppRoutes.home),
          ),
          data: (subject) {
            if (subject == null) {
              return RevisionEmptyState(
                title: 'Aucune matière disponible',
                message:
                    'Crée une matière, puis ajoute un cours et une source pour lancer une révision rapide.',
                icon: Icons.track_changes_rounded,
                actionLabel: 'Ouvrir les matières',
                onAction: () => context.go(AppRoutes.subjects),
              );
            }

            return _RevisionHubContent(
              subjectId: subject.id,
              subjectName: subject.name,
            );
          },
        ),
      ],
    );
  }
}

class _RevisionHubContent extends ConsumerWidget {
  const _RevisionHubContent({
    required this.subjectId,
    required this.subjectName,
  });

  final String subjectId;
  final String subjectName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final courses = ref.watch(coursesProvider(subjectId));
    final visual = revisionSubjectVisualThemeFor(subjectName);

    return courses.when(
      loading: () => const RevisionLoadingState(label: 'Chargement des cours'),
      error: (error, stackTrace) => RevisionErrorState(
        title: 'Cours indisponibles',
        message: 'Impossible de charger les cours de cette matière.',
        actionLabel: 'Réessayer',
        onAction: () => ref.invalidate(coursesProvider(subjectId)),
      ),
      data: (courses) {
        final readyCourse = _firstReadyCourse(courses);
        final firstCourse = courses.isEmpty ? null : courses.first;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _RevisionHubPrimaryAction(
              subjectName: subjectName,
              visual: visual,
              readyCourse: readyCourse,
              fallbackCourse: firstCourse,
            ),
            const SizedBox(height: RevisionSpacing.l),
            RevisionModeCard(
              title: 'Révision rapide',
              description: readyCourse == null
                  ? 'Ajoute une source prête dans un cours pour réviser.'
                  : 'Session courte depuis ${readyCourse.title}.',
              icon: Icons.flash_on_rounded,
              accent: RevisionColors.blue,
              enabled: readyCourse != null,
              trailingLabel: readyCourse == null ? 'Source requise' : null,
              onTap: readyCourse == null
                  ? null
                  : () => startCourseQuickRevisionFlow(
                      context: context,
                      ref: ref,
                      courseId: readyCourse.id,
                      questionCount: 5,
                    ),
            ),
            const SizedBox(height: RevisionSpacing.m),
            RevisionModeCard(
              title: 'Révision approfondie',
              description:
                  'Question ouverte, rédaction et correction détaillée.',
              icon: Icons.menu_book_rounded,
              accent: visual.accent,
              trailingLabel: 'Bientôt',
              enabled: false,
            ),
            const SizedBox(height: RevisionSpacing.m),
            RevisionModeCard(
              title: 'Préparation examen - QCM',
              description: 'Entraînement QCM court, proche d’un sujet.',
              icon: Icons.gps_fixed_rounded,
              accent: RevisionColors.pink,
              trailingLabel: 'Bientôt',
              enabled: false,
            ),
          ],
        );
      },
    );
  }
}

class _RevisionHubPrimaryAction extends ConsumerWidget {
  const _RevisionHubPrimaryAction({
    required this.subjectName,
    required this.visual,
    required this.readyCourse,
    required this.fallbackCourse,
  });

  final String subjectName;
  final RevisionSubjectVisualTheme visual;
  final CourseListItem? readyCourse;
  final CourseListItem? fallbackCourse;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final readyCourse = this.readyCourse;

    if (readyCourse != null) {
      return RevisionGlassCard(
        borderColor: RevisionColors.blue.withValues(alpha: 0.36),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            RevisionColors.blue.withValues(alpha: 0.26),
            RevisionColors.glassStrong,
          ],
        ),
        child: Row(
          children: [
            RevisionIconTile(
              icon: Icons.flash_on_rounded,
              accent: RevisionColors.blue,
              size: 52,
            ),
            const SizedBox(width: RevisionSpacing.m),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subjectName,
                    style: RevisionTypography.caption.copyWith(
                      color: visual.accent,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: RevisionSpacing.xs),
                  Text(
                    readyCourse.title,
                    style: RevisionTypography.sectionTitle,
                  ),
                  const SizedBox(height: RevisionSpacing.xs),
                  Text(
                    'Un cours est prêt pour une session rapide.',
                    style: RevisionTypography.body,
                  ),
                  const SizedBox(height: RevisionSpacing.m),
                  RevisionGradientButton(
                    label: 'Commencer 5 questions',
                    icon: Icons.play_arrow_rounded,
                    onPressed: () => startCourseQuickRevisionFlow(
                      context: context,
                      ref: ref,
                      courseId: readyCourse.id,
                      questionCount: 5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    final fallbackCourse = this.fallbackCourse;
    return RevisionGlassCard(
      child: Row(
        children: [
          RevisionIconTile(icon: visual.icon, accent: visual.accent, size: 42),
          const SizedBox(width: RevisionSpacing.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Préparer un cours',
                  style: RevisionTypography.sectionTitle,
                ),
                const SizedBox(height: RevisionSpacing.xs),
                Text(
                  fallbackCourse == null
                      ? 'Crée un cours et ajoute une source pour lancer une révision rapide.'
                      : 'Ajoute une source prête dans un cours pour lancer une révision rapide.',
                  style: RevisionTypography.body,
                ),
              ],
            ),
          ),
          const SizedBox(width: RevisionSpacing.s),
          TextButton(
            onPressed: () {
              final course = fallbackCourse;
              if (course == null) {
                context.go(AppRoutes.home);
                return;
              }

              context.push(AppRoutes.course(course.id));
            },
            child: Text(fallbackCourse == null ? 'Accueil' : 'Ouvrir'),
          ),
        ],
      ),
    );
  }
}

CourseListItem? _firstReadyCourse(List<CourseListItem> courses) {
  for (final course in courses) {
    if (course.readySourceCount > 0) {
      return course;
    }
  }

  return null;
}
