import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:Neralune/core/routing/route_paths.dart';
import 'package:Neralune/features/courses/application/active_subject_provider.dart';
import 'package:Neralune/features/subjects/application/subjects_notifier.dart';
import 'package:Neralune/features/subjects/domain/subject.dart';
import 'package:Neralune/presentation/design_system/components/revision_mvp_components.dart';
import 'package:Neralune/presentation/design_system/components/revision_states.dart';
import 'package:Neralune/presentation/design_system/tokens/revision_colors.dart';
import 'package:Neralune/presentation/design_system/tokens/revision_radius.dart';
import 'package:Neralune/presentation/design_system/tokens/revision_spacing.dart';
import 'package:Neralune/presentation/design_system/tokens/revision_subject_visuals.dart';
import 'package:Neralune/presentation/design_system/tokens/revision_typography.dart';

class SubjectsHomePage extends ConsumerWidget {
  const SubjectsHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subjects = ref.watch(subjectsNotifierProvider);
    final notifier = ref.read(subjectsNotifierProvider.notifier);

    return RevisionPageScaffold(
      headerChildren: [
        const Text('Matières', style: RevisionTypography.pageTitle),
        const Text(
          'Choisis une matière ou prépare un nouveau parcours.',
          style: RevisionTypography.body,
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: RevisionGradientButton(
            onPressed: () => context.go(onboardingRoutePath),
            icon: Icons.add_rounded,
            label: 'Ajouter une matière',
          ),
        ),
      ],
      children: [
        subjects.when(
          loading: () =>
              const RevisionLoadingState(label: 'Chargement des matières'),
          error: (error, stackTrace) => RevisionErrorState(
            title: 'Matières indisponibles',
            message: 'Impossible de charger tes matières pour le moment.',
            actionLabel: 'Réessayer',
            onAction: notifier.reload,
          ),
          data: (subjects) {
            if (subjects.isEmpty) {
              return RevisionEmptyState(
                icon: Icons.school_rounded,
                title: 'Crée une matière',
                message:
                    'Ajoute une matière pour organiser tes cours et importer tes premières sources.',
                actionLabel: 'Ajouter une matière',
                onAction: () => context.go(onboardingRoutePath),
              );
            }

            return Column(
              children: [
                for (final (index, subject) in subjects.indexed) ...[
                  if (index > 0) const SizedBox(height: RevisionSpacing.m),
                  _SubjectListItem(
                    subject: subject,
                    onTap: () {
                      ref
                          .read(activeSubjectIdProvider.notifier)
                          .select(subject.id);
                      context.go(subjectDetailRoutePath(subject.id));
                    },
                    onDelete: () => _confirmAndDeleteSubject(
                      context: context,
                      notifier: notifier,
                      subject: subject,
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ],
    );
  }
}

class _SubjectListItem extends StatelessWidget {
  const _SubjectListItem({
    required this.subject,
    required this.onTap,
    required this.onDelete,
  });

  final Subject subject;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final visualTheme = revisionSubjectVisualThemeFor(subject.name);

    return RevisionGlassCard(
      onTap: onTap,
      padding: const EdgeInsets.all(RevisionSpacing.m),
      borderColor: visualTheme.accent.withValues(alpha: 0.32),
      child: Row(
        children: [
          RevisionIconTile(icon: visualTheme.icon, accent: visualTheme.accent),
          const SizedBox(width: RevisionSpacing.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subject.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: RevisionTypography.sectionTitle,
                ),
                const SizedBox(height: RevisionSpacing.s),
                Wrap(
                  spacing: RevisionSpacing.s,
                  runSpacing: RevisionSpacing.s,
                  children: [
                    _InfoChip(
                      icon: Icons.flag_rounded,
                      label: 'Priorité ${subject.priority}',
                      accent: visualTheme.accent,
                    ),
                    _InfoChip(
                      icon: Icons.schedule_rounded,
                      label: _subjectSubtitle(subject),
                      accent: RevisionColors.cyan,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: RevisionSpacing.s),
          IconButton(
            onPressed: onDelete,
            icon: const Icon(
              Icons.delete_outline_rounded,
              color: RevisionColors.textMuted,
            ),
            tooltip: 'Supprimer la matière',
          ),
          const Icon(
            Icons.chevron_right_rounded,
            color: RevisionColors.textMuted,
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.label,
    required this.accent,
  });

  final IconData icon;
  final String label;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: RevisionSpacing.s,
        vertical: RevisionSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.12),
        borderRadius: RevisionRadius.pill,
        border: Border.all(color: accent.withValues(alpha: 0.32)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: accent, size: 14),
          const SizedBox(width: RevisionSpacing.xs),
          Text(
            label,
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

Future<void> _confirmAndDeleteSubject({
  required BuildContext context,
  required SubjectsNotifier notifier,
  required Subject subject,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Supprimer la matière ?'),
      content: Text(
        'Cette action supprimera aussi les cours et activités liés à ${subject.name}.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Annuler'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Supprimer'),
        ),
      ],
    ),
  );

  if (confirmed != true || !context.mounted) {
    return;
  }

  try {
    await notifier.deleteSubject(subject.id);
  } catch (_) {
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Impossible de supprimer la matière')),
    );
  }
}

String _subjectSubtitle(Subject subject) {
  if (subject.weeklyMinutes <= 0) {
    return 'Rythme à préciser';
  }

  final hours = subject.weeklyMinutes ~/ 60;
  final minutes = subject.weeklyMinutes % 60;

  if (minutes == 0) {
    return '$hours h / semaine';
  }

  if (hours == 0) {
    return '$minutes min / semaine';
  }

  return '$hours h $minutes min / semaine';
}
