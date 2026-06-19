import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:revision_app/presentation/theme/app_spacing.dart';

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

            return _RevisionSheetContent(
              courseId: widget.courseId,
              sheet: sheet,
            );
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

class CourseRevisionSheetSourcesPage extends ConsumerWidget {
  const CourseRevisionSheetSourcesPage({required this.courseId, super.key});

  final String courseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sheet = ref.watch(courseRevisionSheetProvider(courseId));

    return RevisionPageScaffold(
      children: [
        Row(
          children: [
            IconButton(
              tooltip: 'Retour à la fiche',
              onPressed: () =>
                  _popOrGo(context, AppRoutes.courseSheet(courseId)),
              icon: const Icon(Icons.arrow_back_rounded),
            ),
          ],
        ),
        Text('Sources de la fiche', style: RevisionTypography.pageTitle),
        Text(
          'Les extraits longs sont séparés pour garder la fiche lisible.',
          style: RevisionTypography.body,
        ),
        sheet.when(
          loading: () =>
              const RevisionLoadingState(label: 'Chargement des sources'),
          error: (error, stackTrace) =>
              _SheetErrorState(error: error, courseId: courseId),
          data: (sheet) {
            if (sheet == null) {
              return RevisionEmptyState(
                title: 'Fiche non générée',
                message:
                    'Génère la fiche avant de consulter ses sources détaillées.',
                icon: Icons.article_outlined,
                actionLabel: 'Retour à la fiche',
                onAction: () => context.go(AppRoutes.courseSheet(courseId)),
              );
            }

            final sections = sheet.sections
                .where((section) => section.sources.isNotEmpty)
                .toList(growable: false);

            if (sections.isEmpty) {
              return const RevisionEmptyState(
                title: 'Aucune source détaillée',
                message: 'Cette fiche ne contient pas d’extrait source long.',
                icon: Icons.source_outlined,
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final section in sections)
                  RevisionSheetSectionCard(
                    title: _readableStudyText(section.title),
                    icon: Icons.source_outlined,
                    accent: RevisionColors.mint,
                    children: [
                      for (final source in section.sources)
                        Padding(
                          padding: const EdgeInsets.only(
                            bottom: RevisionSpacing.m,
                          ),
                          child: RevisionGlassCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Page ${source.pageNumber ?? '-'}',
                                  style: RevisionTypography.caption,
                                ),
                                const SizedBox(height: RevisionSpacing.xs),
                                Text(
                                  _readableStudyText(source.text),
                                  style: RevisionTypography.body,
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _RevisionSheetContent extends StatelessWidget {
  const _RevisionSheetContent({required this.courseId, required this.sheet});

  final String courseId;
  final RevisionSheet sheet;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: AppSpacing.s,
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
              Text(
                _readableStudyText(sheet.title),
                style: RevisionTypography.pageTitle,
              ),
            ],
          ),
        ),
        if (sheet.introduction != null)
          RevisionSheetSectionCard(
            title: 'Résumé',
            icon: Icons.summarize_rounded,
            accent: RevisionColors.blue,
            children: [
              Text(
                _readableStudyText(sheet.introduction!),
                style: RevisionTypography.body,
              ),
            ],
          ),
        if (sheet.keyPoints.isNotEmpty)
          _TextListCard(
            title: 'Points clés',
            icon: Icons.check_circle_rounded,
            accent: RevisionColors.green,
            items: sheet.keyPoints.map(_readableStudyText).toList(),
          ),
        if (sheet.commonMistakes.isNotEmpty)
          _TextListCard(
            title: 'Pièges fréquents',
            icon: Icons.warning_amber_rounded,
            accent: RevisionColors.coral,
            items: sheet.commonMistakes.map(_readableStudyText).toList(),
          ),
        if (sheet.mustKnow.isNotEmpty)
          _TextListCard(
            title: 'À connaître',
            icon: Icons.school_rounded,
            accent: RevisionColors.violet,
            items: sheet.mustKnow.map(_readableStudyText).toList(),
          ),
        for (final section in sheet.sections)
          _SectionCard(courseId: courseId, section: section),
        if (sheet.practiceSuggestions.isNotEmpty)
          _TextListCard(
            title: 'S’entraîner',
            icon: Icons.fitness_center_rounded,
            accent: RevisionColors.pink,
            items: sheet.practiceSuggestions.map(_readableStudyText).toList(),
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
  const _SectionCard({required this.courseId, required this.section});

  final String courseId;
  final RevisionSheetSection section;

  @override
  Widget build(BuildContext context) {
    return RevisionSheetSectionCard(
      title: section.title,
      icon: Icons.notes_rounded,
      accent: RevisionColors.mint,
      children: [
        Text(
          _readableStudyText(section.content),
          style: RevisionTypography.body,
        ),
        if (section.sources.isNotEmpty) ...[
          const SizedBox(height: RevisionSpacing.s),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () =>
                  context.push(AppRoutes.courseSheetSources(courseId)),
              icon: const Icon(Icons.source_outlined, size: 16),
              label: const Text('Sources >'),
            ),
          ),
        ],
      ],
    );
  }
}

String _readableStudyText(String value) {
  return value
      .replaceAllMapped(
        RegExp(r'\b([A-Za-zÀ-ÖØ-öø-ÿ]+)[\.·-]e[\.·-]s\b'),
        (match) => '${match.group(1)}s',
      )
      .replaceAllMapped(
        RegExp(r'\b([A-Za-zÀ-ÖØ-öø-ÿ]+)[\.·-]es\b'),
        (match) => '${match.group(1)}s',
      )
      .replaceAllMapped(
        RegExp(r'\b([A-Za-zÀ-ÖØ-öø-ÿ]+)\(e\)s\b'),
        (match) => '${match.group(1)}s',
      )
      .replaceAllMapped(
        RegExp(r'\b([A-Za-zÀ-ÖØ-öø-ÿ]+)[\.·-]e\b'),
        (match) => match.group(1)!,
      )
      .replaceAllMapped(
        RegExp(r'\b([A-Za-zÀ-ÖØ-öø-ÿ]+)\(e\)\b'),
        (match) => match.group(1)!,
      );
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
