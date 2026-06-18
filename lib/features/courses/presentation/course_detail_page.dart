import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_routes.dart';
import '../../../presentation/design_system/components/revision_mvp_components.dart';
import '../../../presentation/design_system/components/revision_states.dart';
import '../../../presentation/design_system/tokens/revision_colors.dart';
import '../../../presentation/design_system/tokens/revision_spacing.dart';
import '../../../presentation/design_system/tokens/revision_typography.dart';
import '../application/courses_providers.dart';
import '../domain/course_models.dart';
import '../domain/courses_repository.dart';
import 'course_not_found_page.dart';

class CourseDetailPage extends ConsumerWidget {
  const CourseDetailPage({required this.courseId, super.key});

  final String courseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(courseDetailProvider(courseId));

    return detail.when(
      loading: () => const RevisionPageScaffold(
        children: [RevisionLoadingState(label: 'Chargement du cours réel')],
      ),
      error: (error, stackTrace) {
        if (error is CourseNotFoundException) {
          return CourseNotFoundPage(courseId: courseId);
        }

        return RevisionPageScaffold(
          children: [
            Text('Cours indisponible', style: RevisionTypography.pageTitle),
            RevisionErrorState(
              title: 'Impossible de charger ce cours',
              message:
                  'Aucune fixture ne remplacera ce cours. Réessaie ou retourne à l’accueil.',
              actionLabel: 'Retour à l’accueil',
              onAction: () => context.go(AppRoutes.home),
            ),
          ],
        );
      },
      data: (detail) => _CourseDetailContent(detail: detail),
    );
  }
}

class _CourseDetailContent extends StatelessWidget {
  const _CourseDetailContent({required this.detail});

  final CourseDetail detail;

  @override
  Widget build(BuildContext context) {
    final course = detail.course;

    return RevisionPageScaffold(
      children: [
        Row(
          children: [
            IconButton(
              tooltip: 'Retour',
              onPressed: () => context.go(AppRoutes.home),
              icon: const Icon(Icons.arrow_back_rounded),
            ),
            const Spacer(),
          ],
        ),
        RevisionGlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(detail.subject.name, style: RevisionTypography.caption),
              const SizedBox(height: RevisionSpacing.xs),
              Text(course.title, style: RevisionTypography.pageTitle),
              if (course.description != null) ...[
                const SizedBox(height: RevisionSpacing.s),
                Text(course.description!, style: RevisionTypography.body),
              ],
              const SizedBox(height: RevisionSpacing.l),
              Wrap(
                spacing: RevisionSpacing.s,
                runSpacing: RevisionSpacing.s,
                children: [
                  _InfoPill(label: _courseMeta(course)),
                  _InfoPill(label: _sourceMeta(course)),
                ],
              ),
            ],
          ),
        ),
        const _CourseActions(),
        _SourcesSection(sources: detail.sources),
      ],
    );
  }
}

class _CourseActions extends StatelessWidget {
  const _CourseActions();

  @override
  Widget build(BuildContext context) {
    return RevisionGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Actions', style: RevisionTypography.sectionTitle),
          const SizedBox(height: RevisionSpacing.m),
          RevisionGradientButton(
            label: 'Ajouter une source · CORE-03',
            icon: Icons.upload_file_rounded,
            expanded: true,
          ),
          const SizedBox(height: RevisionSpacing.m),
          RevisionGradientButton(
            label: 'Fiche bientôt disponible',
            icon: Icons.article_outlined,
            expanded: true,
            onPressed: null,
          ),
          const SizedBox(height: RevisionSpacing.m),
          RevisionGradientButton(
            label: 'Révision rapide bientôt disponible',
            icon: Icons.flash_on_rounded,
            expanded: true,
            onPressed: null,
          ),
          const SizedBox(height: RevisionSpacing.s),
          Text(
            'Révision approfondie et préparation examen restent MVP+.',
            style: RevisionTypography.caption,
          ),
        ],
      ),
    );
  }
}

class _SourcesSection extends StatelessWidget {
  const _SourcesSection({required this.sources});

  final List<CourseDocument> sources;

  @override
  Widget build(BuildContext context) {
    if (sources.isEmpty) {
      return const RevisionEmptyState(
        title: 'Aucune source attachée',
        message:
            'Ce cours existe réellement, mais l’ajout de PDF sous cours arrive en CORE-03.',
        icon: Icons.source_outlined,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Sources', style: RevisionTypography.sectionTitle),
        const SizedBox(height: RevisionSpacing.m),
        for (final source in sources) ...[
          RevisionGlassCard(
            child: Row(
              children: [
                RevisionIconTile(
                  icon: Icons.picture_as_pdf_rounded,
                  accent: _statusColor(source.status),
                ),
                const SizedBox(width: RevisionSpacing.m),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(source.fileName, style: RevisionTypography.body),
                      const SizedBox(height: RevisionSpacing.xs),
                      Text(
                        _statusLabel(source.status),
                        style: RevisionTypography.caption,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: RevisionSpacing.m),
        ],
      ],
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.label});

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

String _courseMeta(CourseListItem course) {
  final parts = <String>[
    if (course.chapterLabel != null) course.chapterLabel!,
    if (course.estimatedMinutes != null) '${course.estimatedMinutes} min',
  ];

  return parts.isEmpty ? 'Cours réel' : parts.join(' · ');
}

String _sourceMeta(CourseListItem course) {
  final sourceLabel = course.sourceCount <= 1 ? 'source' : 'sources';
  final readyLabel = course.readySourceCount <= 1 ? 'prête' : 'prêtes';

  return '${course.sourceCount} $sourceLabel · ${course.readySourceCount} $readyLabel';
}

String _statusLabel(CourseDocumentStatus status) {
  return switch (status) {
    CourseDocumentStatus.uploaded => 'Téléversée',
    CourseDocumentStatus.processing => 'Traitement en cours',
    CourseDocumentStatus.ready => 'Prête',
    CourseDocumentStatus.failed => 'Erreur',
    CourseDocumentStatus.unknown => 'Statut inconnu',
  };
}

Color _statusColor(CourseDocumentStatus status) {
  return switch (status) {
    CourseDocumentStatus.ready => RevisionColors.mint,
    CourseDocumentStatus.processing => RevisionColors.blue,
    CourseDocumentStatus.failed => RevisionColors.red,
    CourseDocumentStatus.uploaded => RevisionColors.amber,
    CourseDocumentStatus.unknown => RevisionColors.violet,
  };
}
