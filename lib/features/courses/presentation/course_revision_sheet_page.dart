import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_routes.dart';
import '../../../presentation/design_system/components/revision_mvp_components.dart';
import '../../../presentation/design_system/components/revision_states.dart';
import '../../../presentation/design_system/tokens/revision_colors.dart';
import '../../../presentation/design_system/tokens/revision_spacing.dart';
import '../../../presentation/design_system/tokens/revision_typography.dart';
import '../../documents/domain/revision_document.dart';
import '../application/courses_providers.dart';
import '../domain/courses_repository.dart';

class CourseRevisionSheetPage extends ConsumerStatefulWidget {
  const CourseRevisionSheetPage({required this.courseId, super.key});

  final String courseId;

  @override
  ConsumerState<CourseRevisionSheetPage> createState() =>
      _CourseRevisionSheetPageState();
}

class _CourseRevisionSheetPageState
    extends ConsumerState<CourseRevisionSheetPage> {
  _SheetMode _mode = _SheetMode.fast;

  @override
  Widget build(BuildContext context) {
    final sheet = ref.watch(courseRevisionSheetProvider(widget.courseId));

    return RevisionPageScaffold(
      children: [
        Row(
          children: [
            IconButton(
              tooltip: 'Retour au cours',
              onPressed: () =>
                  _popOrGo(context, AppRoutes.course(widget.courseId)),
              icon: const Icon(Icons.arrow_back_rounded),
            ),
            const Spacer(),
            RevisionHeaderActionPill(
              label: 'Sources',
              icon: Icons.description_outlined,
              onTap: () => _popOrGo(context, AppRoutes.course(widget.courseId)),
            ),
          ],
        ),
        RevisionSegmentedControl<_SheetMode>(
          values: _SheetMode.values,
          selected: _mode,
          labelOf: _sheetModeLabel,
          onChanged: (mode) => setState(() => _mode = mode),
        ),
        sheet.when(
          loading: () =>
              const RevisionLoadingState(label: 'Chargement de la fiche'),
          error: (error, stackTrace) =>
              _SheetErrorState(error: error, courseId: widget.courseId),
          data: (sheet) {
            if (sheet == null) {
              return _GenerateSheetCard(courseId: widget.courseId);
            }

            if (_mode != _SheetMode.fast) {
              return RevisionEmptyState(
                title: '${_sheetModeLabel(_mode)} bientôt',
                message:
                    'Ce format de fiche est prévu plus tard. Le contenu rapide ci-dessus reste le format réel disponible aujourd’hui.',
                icon: Icons.lock_outline_rounded,
              );
            }

            return _RevisionSheetContent(sheet: sheet);
          },
        ),
      ],
    );
  }
}

class _GenerateSheetCard extends ConsumerWidget {
  const _GenerateSheetCard({required this.courseId});

  final String courseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(generateCourseRevisionSheetControllerProvider);

    if (state.isLoading) {
      return const RevisionProcessingState(
        title: 'Génération de la fiche',
        message: 'La fiche est créée depuis la première source PDF prête.',
      );
    }

    if (state.hasError) {
      return _SheetErrorState(error: state.error!, courseId: courseId);
    }

    return RevisionEmptyState(
      title: 'Fiche non générée',
      message:
          'Une source est prête, mais aucune fiche n’a encore été créée pour ce cours.',
      icon: Icons.article_outlined,
      actionLabel: 'Générer la fiche',
      onAction: () async {
        try {
          await ref
              .read(generateCourseRevisionSheetControllerProvider.notifier)
              .generate(courseId: courseId);
        } catch (_) {
          // The controller stores the error state; the provider refresh below
          // renders a domain-specific message if the backend rejected it.
        }
      },
    );
  }
}

class _SheetErrorState extends StatelessWidget {
  const _SheetErrorState({required this.error, required this.courseId});

  final Object error;
  final String courseId;

  @override
  Widget build(BuildContext context) {
    if (error is CourseRevisionSheetNotReadyException) {
      return RevisionErrorState(
        title: 'Aucune source prête',
        message:
            'Ajoute ou attends une source PDF traitée avec succès avant de créer une fiche.',
        actionLabel: 'Retour au cours',
        onAction: () => context.go(AppRoutes.course(courseId)),
      );
    }

    if (error is CourseNotFoundException) {
      return RevisionNotFoundState(
        title: 'Cours introuvable',
        message: 'Ce cours n’existe pas dans les données réelles.',
        actionLabel: 'Retour à l’accueil',
        onAction: () => context.go(AppRoutes.home),
      );
    }

    return RevisionErrorState(
      title: 'Fiche indisponible',
      message:
          'Impossible de charger cette fiche pour le moment. Aucune donnée fictive ne sera affichée.',
      actionLabel: 'Réessayer',
      onAction: () => context.go(AppRoutes.courseSheet(courseId)),
    );
  }
}

class _RevisionSheetContent extends StatelessWidget {
  const _RevisionSheetContent({required this.sheet});

  final RevisionSheet sheet;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RevisionGlassCard(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              RevisionColors.blue.withValues(alpha: 0.30),
              RevisionColors.glassStrong,
            ],
          ),
          borderColor: RevisionColors.blue.withValues(alpha: 0.32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const RevisionIconTile(
                    icon: Icons.article_rounded,
                    accent: RevisionColors.blue,
                    size: 36,
                    iconSize: 20,
                  ),
                  const SizedBox(width: RevisionSpacing.s),
                  Text('Fiche de cours', style: RevisionTypography.caption),
                ],
              ),
              const SizedBox(height: RevisionSpacing.m),
              Text(sheet.title, style: RevisionTypography.pageTitle),
            ],
          ),
        ),
        if (sheet.introduction != null)
          RevisionSheetSectionCard(
            title: 'Résumé',
            icon: Icons.summarize_rounded,
            accent: RevisionColors.blue,
            children: [
              Text(sheet.introduction!, style: RevisionTypography.body),
            ],
          ),
        if (sheet.keyPoints.isNotEmpty)
          _TextListCard(
            title: 'Points clés',
            icon: Icons.check_circle_rounded,
            accent: RevisionColors.green,
            items: sheet.keyPoints,
          ),
        if (sheet.commonMistakes.isNotEmpty)
          _TextListCard(
            title: 'Pièges fréquents',
            icon: Icons.warning_amber_rounded,
            accent: RevisionColors.coral,
            items: sheet.commonMistakes,
          ),
        if (sheet.mustKnow.isNotEmpty)
          _TextListCard(
            title: 'À connaître',
            icon: Icons.school_rounded,
            accent: RevisionColors.violet,
            items: sheet.mustKnow,
          ),
        for (final section in sheet.sections) _SectionCard(section: section),
        if (sheet.practiceSuggestions.isNotEmpty)
          _TextListCard(
            title: 'S’entraîner',
            icon: Icons.fitness_center_rounded,
            accent: RevisionColors.pink,
            items: sheet.practiceSuggestions,
          ),
      ],
    );
  }
}

class _TextListCard extends StatelessWidget {
  const _TextListCard({
    required this.title,
    required this.icon,
    required this.accent,
    required this.items,
  });

  final String title;
  final IconData icon;
  final Color accent;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return RevisionSheetSectionCard(
      title: title,
      icon: icon,
      accent: accent,
      children: [
        for (final item in items)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('•', style: RevisionTypography.body.copyWith(color: accent)),
              const SizedBox(width: RevisionSpacing.s),
              Expanded(child: Text(item, style: RevisionTypography.body)),
            ],
          ),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.section});

  final RevisionSheetSection section;

  @override
  Widget build(BuildContext context) {
    return RevisionSheetSectionCard(
      title: section.title,
      icon: Icons.notes_rounded,
      accent: RevisionColors.mint,
      children: [
        Text(section.content, style: RevisionTypography.body),
        if (section.sources.isNotEmpty) ...[
          const SizedBox(height: RevisionSpacing.s),
          Text('Sources', style: RevisionTypography.caption),
          for (final source in section.sources)
            Text(
              'p. ${source.pageNumber ?? '-'} · ${source.text}',
              style: RevisionTypography.caption,
            ),
        ],
      ],
    );
  }
}

enum _SheetMode { fast, complete, exam }

String _sheetModeLabel(_SheetMode mode) {
  return switch (mode) {
    _SheetMode.fast => 'Rapide',
    _SheetMode.complete => 'Complète',
    _SheetMode.exam => 'Examen',
  };
}

void _popOrGo(BuildContext context, String fallbackLocation) {
  // The sheet is normally stacked above course detail; direct URLs still need a
  // deterministic fallback because there may be nothing to pop.
  if (context.canPop()) {
    context.pop();
    return;
  }

  context.go(fallbackLocation);
}
