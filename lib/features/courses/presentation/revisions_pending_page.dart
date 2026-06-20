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

class RevisionsPendingPage extends ConsumerWidget {
  const RevisionsPendingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeSubject = ref.watch(activeSubjectProvider);

    return RevisionPageScaffold(
      headerChildren: [
        Text('Révisions', style: RevisionTypography.hero),
        Text('Choisis ton mode de travail', style: RevisionTypography.body),
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
                    'Crée une matière et un cours avec source prête pour lancer une révision rapide.',
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

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RevisionModeCard(
              title: 'Révision rapide',
              description: readyCourse == null
                  ? 'Ajoute une source prête dans un cours pour réviser.'
                  : 'Session courte depuis ${readyCourse.title}.',
              icon: Icons.flash_on_rounded,
              accent: RevisionColors.blue,
              enabled: readyCourse != null,
              trailingLabel: readyCourse == null ? 'À préparer' : null,
              onTap: readyCourse == null
                  ? null
                  : () => context.push(AppRoutes.course(readyCourse.id)),
            ),
            const SizedBox(height: RevisionSpacing.m),
            RevisionModeCard(
              title: 'Révision approfondie',
              description: 'Cours complet et exemples détaillés.',
              icon: Icons.menu_book_rounded,
              accent: visual.accent,
              trailingLabel: 'MVP+',
              enabled: false,
            ),
            const SizedBox(height: RevisionSpacing.m),
            RevisionModeCard(
              title: 'Préparation examen',
              description: 'Entraînements et sujets corrigés.',
              icon: Icons.gps_fixed_rounded,
              accent: RevisionColors.pink,
              trailingLabel: 'MVP+',
              enabled: false,
            ),
            const SizedBox(height: RevisionSpacing.l),
            RevisionGlassCard(
              child: Row(
                children: [
                  RevisionIconTile(
                    icon: visual.icon,
                    accent: visual.accent,
                    size: 42,
                  ),
                  const SizedBox(width: RevisionSpacing.m),
                  Expanded(
                    child: Text(
                      readyCourse == null
                          ? 'Les révisions rapides se lancent depuis un cours avec une source prête.'
                          : 'Ouvre le cours recommandé puis démarre la révision rapide.',
                      style: RevisionTypography.body,
                    ),
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

CourseListItem? _firstReadyCourse(List<CourseListItem> courses) {
  for (final course in courses) {
    if (course.readySourceCount > 0) {
      return course;
    }
  }

  return null;
}
