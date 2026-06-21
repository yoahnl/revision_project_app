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
import '../../subjects/application/subjects_notifier.dart';
import '../../subjects/domain/subject.dart';
import '../application/active_subject_provider.dart';
import '../application/courses_providers.dart';
import '../domain/course_models.dart';

class SubjectProgressPage extends ConsumerWidget {
  const SubjectProgressPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeSubject = ref.watch(activeSubjectProvider);

    return RevisionPageScaffold(
      headerChildren: [
        Text('Progrès', style: RevisionTypography.hero),
        Text(
          'Ta progression vient des notions générées depuis tes sources prêtes et de tes réponses.',
          style: RevisionTypography.body,
        ),
      ],
      children: [
        activeSubject.when(
          loading: () =>
              const RevisionLoadingState(label: 'Chargement des matières'),
          error: (error, stackTrace) => RevisionErrorState(
            title: 'Impossible de charger les matières',
            message:
                'Choisis ou crée une matière pour afficher ta progression.',
            actionLabel: 'Réessayer',
            onAction: () =>
                ref.read(subjectsNotifierProvider.notifier).reload(),
          ),
          data: (subject) {
            if (subject == null) {
              return RevisionEmptyState(
                title: 'Crée une matière pour suivre ta progression.',
                message:
                    'Ajoute ensuite un cours et une source pour commencer à voir tes notions.',
                icon: Icons.trending_up_rounded,
                actionLabel: 'Ouvrir les matières',
                onAction: () => context.go(AppRoutes.subjects),
              );
            }

            return _SubjectProgressContent(subject: subject);
          },
        ),
      ],
    );
  }
}

class _SubjectProgressContent extends ConsumerWidget {
  const _SubjectProgressContent({required this.subject});

  final Subject subject;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(subjectProgressProvider(subject.id));

    return progress.when(
      loading: () =>
          const RevisionLoadingState(label: 'Chargement de la progression'),
      error: (error, stackTrace) => RevisionErrorState(
        title: 'Progression indisponible',
        message:
            'Impossible de charger les informations de progression pour cette matière.',
        actionLabel: 'Réessayer',
        onAction: () => ref.invalidate(subjectProgressProvider(subject.id)),
      ),
      data: (progress) =>
          _SubjectProgressLoaded(subject: subject, progress: progress),
    );
  }
}

class _SubjectProgressLoaded extends StatelessWidget {
  const _SubjectProgressLoaded({required this.subject, required this.progress});

  final Subject subject;
  final SubjectProgress progress;

  @override
  Widget build(BuildContext context) {
    final visual = revisionSubjectVisualThemeFor(subject.name);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RevisionGlassCard(
          padding: const EdgeInsets.all(RevisionSpacing.xl),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              visual.accent.withValues(alpha: 0.26),
              RevisionColors.glassStrong,
            ],
          ),
          borderColor: visual.accent.withValues(alpha: 0.36),
          child: Row(
            children: [
              RevisionMasteryRing(
                value: progress.estimatedGlobalMastery,
                label: _percent(progress.estimatedGlobalMastery),
                caption: 'global',
                color: progress.mastery == null
                    ? visual.accent
                    : RevisionColors.green,
                size: 104,
              ),
              const SizedBox(width: RevisionSpacing.l),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(subject.name, style: RevisionTypography.sectionTitle),
                    const SizedBox(height: RevisionSpacing.xs),
                    Text('Matière active', style: RevisionTypography.caption),
                    const SizedBox(height: RevisionSpacing.s),
                    Text(
                      '${progress.practicedKnowledgeUnitCount}/${progress.knowledgeUnitCount} notions travaillées',
                      style: RevisionTypography.sectionTitle.copyWith(
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: RevisionSpacing.s),
                    RevisionProgressLine(
                      value: progress.coverage,
                      color: visual.accent,
                      height: 8,
                    ),
                    const SizedBox(height: RevisionSpacing.s),
                    Text(
                      _masteryLabel(progress.mastery),
                      style: RevisionTypography.caption,
                    ),
                    const SizedBox(height: RevisionSpacing.xs),
                    Text(
                      'Estimation globale : ${_percent(progress.estimatedGlobalMastery)}',
                      style: RevisionTypography.caption,
                    ),
                    const SizedBox(height: RevisionSpacing.s),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: () => context.go(AppRoutes.home),
                        icon: const Icon(Icons.swap_horiz_rounded, size: 16),
                        label: const Text('Changer de matière'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: RevisionSpacing.l),
        _SubjectProgressMeta(progress: progress, visual: visual),
        const SizedBox(height: RevisionSpacing.l),
        if (progress.courses.isEmpty)
          RevisionEmptyState(
            title: 'Aucun cours à suivre',
            message:
                'Crée un cours, ajoute une source PDF, puis révise pour suivre tes notions.',
            icon: Icons.layers_outlined,
            actionLabel: 'Retour à l’accueil',
            onAction: () => context.go(AppRoutes.home),
          )
        else ...[
          Text('Tes cours', style: RevisionTypography.sectionTitle),
          const SizedBox(height: RevisionSpacing.m),
          for (final course in progress.courses) ...[
            _SubjectCourseProgressCard(course: course, visual: visual),
            const SizedBox(height: RevisionSpacing.m),
          ],
          _WeakPointSummary(courses: progress.courses),
        ],
      ],
    );
  }
}

class _SubjectProgressMeta extends StatelessWidget {
  const _SubjectProgressMeta({required this.progress, required this.visual});

  final SubjectProgress progress;
  final RevisionSubjectVisualTheme visual;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: RevisionSpacing.s,
      runSpacing: RevisionSpacing.s,
      children: [
        RevisionMetricPill(
          label: '${progress.courseCount} cours',
          icon: Icons.layers_rounded,
          accent: visual.accent,
        ),
        RevisionMetricPill(
          label: '${progress.readyCourseCount} avec source prête',
          icon: Icons.check_circle_rounded,
          accent: RevisionColors.green,
        ),
        RevisionMetricPill(
          label: progress.lastPracticedAt == null
              ? 'Pas encore pratiqué'
              : 'Déjà pratiqué',
          icon: Icons.history_rounded,
          accent: RevisionColors.amber,
        ),
      ],
    );
  }
}

class _SubjectCourseProgressCard extends StatelessWidget {
  const _SubjectCourseProgressCard({
    required this.course,
    required this.visual,
  });

  final SubjectCourseProgressItem course;
  final RevisionSubjectVisualTheme visual;

  @override
  Widget build(BuildContext context) {
    final color = _stateColor(course.state, visual);

    return RevisionGlassCard(
      onTap: () => context.push(AppRoutes.course(course.courseId)),
      padding: const EdgeInsets.all(RevisionSpacing.m),
      child: Row(
        children: [
          RevisionIconTile(
            icon: visual.icon,
            accent: color,
            size: 48,
            iconSize: 26,
          ),
          const SizedBox(width: RevisionSpacing.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(course.title, style: RevisionTypography.sectionTitle),
                const SizedBox(height: RevisionSpacing.xs),
                Text(
                  '${course.practicedKnowledgeUnitCount}/${course.knowledgeUnitCount} notions travaillées',
                  style: RevisionTypography.body,
                ),
                const SizedBox(height: RevisionSpacing.s),
                RevisionProgressLine(
                  value: course.coverage,
                  color: color,
                  height: 6,
                ),
                const SizedBox(height: RevisionSpacing.s),
                Text(
                  _stateLabel(course.state),
                  style: RevisionTypography.caption,
                ),
              ],
            ),
          ),
          const SizedBox(width: RevisionSpacing.s),
          Text(
            _percent(course.estimatedGlobalMastery),
            style: RevisionTypography.sectionTitle.copyWith(
              color: RevisionColors.text,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}

class _WeakPointSummary extends StatelessWidget {
  const _WeakPointSummary({required this.courses});

  final List<SubjectCourseProgressItem> courses;

  @override
  Widget build(BuildContext context) {
    final weakCourses = courses
        .where((course) => course.state != CourseProgressState.practiced)
        .take(3)
        .toList(growable: false);

    if (weakCourses.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: RevisionSpacing.s),
        Text('À préparer', style: RevisionTypography.sectionTitle),
        const SizedBox(height: RevisionSpacing.m),
        for (final course in weakCourses) ...[
          RevisionGlassCard(
            onTap: () => context.push(AppRoutes.course(course.courseId)),
            padding: const EdgeInsets.all(RevisionSpacing.m),
            child: Row(
              children: [
                const RevisionIconTile(
                  icon: Icons.priority_high_rounded,
                  accent: RevisionColors.amber,
                  size: 36,
                  iconSize: 20,
                ),
                const SizedBox(width: RevisionSpacing.m),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        course.title,
                        style: RevisionTypography.sectionTitle,
                      ),
                      const SizedBox(height: RevisionSpacing.xs),
                      Text(
                        _stateLabel(course.state),
                        style: RevisionTypography.caption,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: RevisionSpacing.s),
        ],
      ],
    );
  }
}

String _masteryLabel(double? mastery) {
  if (mastery == null) {
    return 'Maîtrise travaillée : en attente';
  }

  return 'Maîtrise travaillée : ${_percent(mastery)}';
}

String _stateLabel(CourseProgressState state) {
  return switch (state) {
    CourseProgressState.noSource => 'Ajoute une source pour commencer.',
    CourseProgressState.processing => 'Analyse du PDF en cours.',
    CourseProgressState.failedOnly =>
      'Les sources ont échoué. Ajoute ou corrige une source.',
    CourseProgressState.noKnowledgeUnits =>
      'Source prête, mais aucune notion exploitable.',
    CourseProgressState.readyNotPracticed =>
      'Notions prêtes, pas encore travaillées.',
    CourseProgressState.practiced => 'Progression basée sur tes réponses.',
    CourseProgressState.unknown => 'Progression disponible.',
  };
}

Color _stateColor(
  CourseProgressState state,
  RevisionSubjectVisualTheme visual,
) {
  return switch (state) {
    CourseProgressState.practiced => RevisionColors.green,
    CourseProgressState.readyNotPracticed => visual.accent,
    CourseProgressState.processing => RevisionColors.amber,
    CourseProgressState.failedOnly => RevisionColors.red,
    CourseProgressState.noKnowledgeUnits => RevisionColors.violet,
    CourseProgressState.noSource => visual.accent,
    CourseProgressState.unknown => RevisionColors.mint,
  };
}

String _percent(double value) {
  return '${(value.clamp(0, 1) * 100).round()}%';
}
