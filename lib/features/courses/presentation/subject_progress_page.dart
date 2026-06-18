import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_routes.dart';
import '../../../presentation/design_system/components/revision_mvp_components.dart';
import '../../../presentation/design_system/components/revision_states.dart';
import '../../../presentation/design_system/tokens/revision_colors.dart';
import '../../../presentation/design_system/tokens/revision_spacing.dart';
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
      children: [
        Text('Progrès', style: RevisionTypography.pageTitle),
        Text(
          'Ta progression vient des notions générées depuis tes sources prêtes et de tes réponses.',
          style: RevisionTypography.body,
        ),
        activeSubject.when(
          loading: () =>
              const RevisionLoadingState(label: 'Chargement des matières'),
          error: (error, stackTrace) => RevisionErrorState(
            title: 'Impossible de charger les matières',
            message:
                'La progression réelle ne peut pas être calculée sans matière chargée.',
            actionLabel: 'Réessayer',
            onAction: () =>
                ref.read(subjectsNotifierProvider.notifier).reload(),
          ),
          data: (subject) {
            if (subject == null) {
              return RevisionEmptyState(
                title: 'Aucune matière réelle',
                message:
                    'Crée une matière puis ajoute des cours et sources pour suivre ta progression.',
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
            'Impossible de charger les métriques réelles de cette matière.',
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RevisionGlassCard(
          child: Row(
            children: [
              RevisionMasteryRing(
                value: progress.estimatedGlobalMastery,
                label: _percent(progress.estimatedGlobalMastery),
                caption: 'global',
                color: progress.mastery == null
                    ? RevisionColors.blue
                    : RevisionColors.green,
              ),
              const SizedBox(width: RevisionSpacing.l),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(subject.name, style: RevisionTypography.sectionTitle),
                    const SizedBox(height: RevisionSpacing.s),
                    Text(
                      '${progress.practicedKnowledgeUnitCount}/${progress.knowledgeUnitCount} notions travaillées',
                      style: RevisionTypography.body,
                    ),
                    const SizedBox(height: RevisionSpacing.s),
                    RevisionProgressLine(
                      value: progress.coverage,
                      color: RevisionColors.blue,
                      height: 7,
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
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: RevisionSpacing.l),
        _SubjectProgressMeta(progress: progress),
        const SizedBox(height: RevisionSpacing.l),
        if (progress.courses.isEmpty)
          RevisionEmptyState(
            title: 'Aucun cours réel à suivre',
            message:
                'Crée un cours réel, ajoute une source PDF, puis révise pour faire progresser ces métriques.',
            icon: Icons.layers_outlined,
            actionLabel: 'Retour à l’accueil',
            onAction: () => context.go(AppRoutes.home),
          )
        else ...[
          Text('Cours', style: RevisionTypography.sectionTitle),
          const SizedBox(height: RevisionSpacing.m),
          for (final course in progress.courses) ...[
            _SubjectCourseProgressCard(course: course),
            const SizedBox(height: RevisionSpacing.m),
          ],
        ],
      ],
    );
  }
}

class _SubjectProgressMeta extends StatelessWidget {
  const _SubjectProgressMeta({required this.progress});

  final SubjectProgress progress;

  @override
  Widget build(BuildContext context) {
    return RevisionGlassCard(
      child: Wrap(
        spacing: RevisionSpacing.m,
        runSpacing: RevisionSpacing.m,
        children: [
          _ProgressPill(label: '${progress.courseCount} cours'),
          _ProgressPill(label: '${progress.readyCourseCount} prêts'),
          _ProgressPill(
            label: progress.lastPracticedAt == null
                ? 'Pas encore pratiqué'
                : 'Déjà pratiqué',
          ),
        ],
      ),
    );
  }
}

class _SubjectCourseProgressCard extends StatelessWidget {
  const _SubjectCourseProgressCard({required this.course});

  final SubjectCourseProgressItem course;

  @override
  Widget build(BuildContext context) {
    return RevisionGlassCard(
      onTap: () => context.go(AppRoutes.course(course.courseId)),
      child: Row(
        children: [
          RevisionIconTile(
            icon: Icons.auto_stories_outlined,
            accent: _stateColor(course.state),
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
                  color: _stateColor(course.state),
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
            style: RevisionTypography.caption.copyWith(
              color: RevisionColors.text,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressPill extends StatelessWidget {
  const _ProgressPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: RevisionColors.glassSoft,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: RevisionColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: RevisionSpacing.m,
          vertical: RevisionSpacing.s,
        ),
        child: Text(label, style: RevisionTypography.caption),
      ),
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
    CourseProgressState.practiced =>
      'Progression réelle basée sur tes réponses.',
    CourseProgressState.unknown => 'Progression réelle disponible.',
  };
}

Color _stateColor(CourseProgressState state) {
  return switch (state) {
    CourseProgressState.practiced => RevisionColors.green,
    CourseProgressState.readyNotPracticed => RevisionColors.blue,
    CourseProgressState.processing => RevisionColors.amber,
    CourseProgressState.failedOnly => RevisionColors.red,
    CourseProgressState.noKnowledgeUnits => RevisionColors.violet,
    CourseProgressState.noSource => RevisionColors.blue,
    CourseProgressState.unknown => RevisionColors.mint,
  };
}

String _percent(double value) {
  return '${(value.clamp(0, 1) * 100).round()}%';
}
