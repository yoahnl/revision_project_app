import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:revision_app/core/routing/route_paths.dart';
import 'package:revision_app/features/subjects/application/subjects_notifier.dart';
import 'package:revision_app/features/subjects/domain/subject.dart';
import 'package:revision_app/presentation/theme/app_colors.dart';
import 'package:revision_app/presentation/theme/app_spacing.dart';
import 'package:revision_app/presentation/widgets/revision_button.dart';
import 'package:revision_app/presentation/widgets/revision_icon_badge.dart';
import 'package:revision_app/presentation/widgets/revision_page.dart';
import 'package:revision_app/presentation/widgets/revision_panel.dart';
import 'package:revision_app/presentation/widgets/revision_progress_bar.dart';
import 'package:revision_app/presentation/widgets/revision_status_pill.dart';

class SubjectsHomePage extends ConsumerWidget {
  const SubjectsHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subjects = ref.watch(subjectsNotifierProvider);
    final notifier = ref.read(subjectsNotifierProvider.notifier);

    return RevisionPage(
      title: 'Tes matieres',
      subtitle: 'Choisis un cours et laisse le coach adapter la revision.',
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: RevisionButton(
            onPressed: () => context.go(onboardingRoutePath),
            icon: Icons.add,
            label: 'Ajouter une matiere',
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        subjects.when(
          loading: () => const LinearProgressIndicator(),
          error: (error, stackTrace) =>
              _SubjectsErrorState(onRetry: notifier.reload),
          data: (subjects) {
            if (subjects.isEmpty) {
              return const Text('Aucune matiere pour le moment');
            }

            return Column(
              spacing: AppSpacing.itemGap,
              children: [
                for (final subject in subjects)
                  _SubjectListItem(
                    subject: subject,
                    onTap: () => context.go(subjectDetailRoutePath(subject.id)),
                    onDelete: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Supprimer la matiere ?'),
                          content: const Text(
                            'Cette action supprimera aussi ses cours et activites.',
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
                          const SnackBar(
                            content: Text(
                              'Impossible de supprimer la matiere',
                            ),
                          ),
                        );
                      }
                    },
                  ),
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
    final priorityColor = _priorityColor(subject.priority);
    final progress = (subject.priority / 5).clamp(0, 1).toDouble();

    return RevisionPanel(
      onTap: onTap,
      child: Row(
        children: [
          _SubjectIcon(color: priorityColor),
          const SizedBox(width: AppSpacing.l),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        subject.name,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    RevisionStatusPill(
                      label: 'Priorite ${subject.priority}',
                      color: priorityColor,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.s),
                RevisionProgressBar(value: progress),
                const SizedBox(height: AppSpacing.s),
                Text(
                  _subjectSubtitle(subject),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.m),
          IconButton(
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Supprimer la matiere',
          ),
          const SizedBox(width: AppSpacing.s),
          Icon(
            Icons.chevron_right,
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ],
      ),
    );
  }
}

class _SubjectIcon extends StatelessWidget {
  const _SubjectIcon({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return RevisionIconBadge(icon: Icons.menu_book_outlined, color: color);
  }
}

class _SubjectsErrorState extends StatelessWidget {
  const _SubjectsErrorState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Impossible de charger les matieres',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.error,
          ),
        ),
        const SizedBox(height: AppSpacing.m),
        RevisionButton(
          onPressed: onRetry,
          icon: Icons.refresh,
          label: 'Reessayer',
          style: RevisionButtonStyle.ghost,
        ),
      ],
    );
  }
}

Color _priorityColor(int priority) {
  if (priority >= 5) {
    return AppColors.coral;
  }

  if (priority >= 4) {
    return AppColors.primaryDark;
  }

  if (priority >= 3) {
    return AppColors.amber;
  }

  return AppColors.aqua;
}

String _subjectSubtitle(Subject subject) {
  if (subject.weeklyMinutes <= 0) {
    return 'Priorite ${subject.priority}';
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
