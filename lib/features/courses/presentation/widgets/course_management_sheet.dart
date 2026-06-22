import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../presentation/design_system/components/revision_mvp_components.dart';
import '../../../../presentation/design_system/components/revision_states.dart';
import '../../../../presentation/design_system/tokens/revision_colors.dart';
import '../../../../presentation/design_system/tokens/revision_spacing.dart';
import '../../../../presentation/design_system/tokens/revision_typography.dart';
import '../../application/courses_providers.dart';
import '../../domain/course_models.dart';
import '../../domain/courses_repository.dart';

enum CourseManagementResult { changed, removed }

Future<CourseManagementResult?> showCourseManagementSheet({
  required BuildContext context,
  required CourseDetail detail,
}) {
  return showModalBottomSheet<CourseManagementResult>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _CourseManagementSheet(detail: detail),
  );
}

class _CourseManagementSheet extends ConsumerWidget {
  const _CourseManagementSheet({required this.detail});

  final CourseDetail detail;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lifecycle = ref.watch(courseLifecycleProvider(detail.course.id));

    return RevisionBottomSheetFrame(
      title: 'Gérer le cours',
      subtitle: detail.course.title,
      children: [
        lifecycle.when(
          loading: () =>
              const RevisionLoadingState(label: 'Vérification du cours'),
          error: (error, stackTrace) => RevisionErrorState(
            title: 'Actions indisponibles',
            message: 'Impossible de vérifier ce cours pour le moment.',
            actionLabel: 'Réessayer',
            onAction: () =>
                ref.invalidate(courseLifecycleProvider(detail.course.id)),
          ),
          data: (decision) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _LifecycleMessage(decision: decision),
              const SizedBox(height: RevisionSpacing.m),
              _ManagementAction(
                icon: Icons.edit_rounded,
                title: 'Renommer',
                message: 'Modifier le titre affiché dans tes cours.',
                enabled: decision.canUpdate,
                onTap: () => _renameCourse(context, ref, detail),
              ),
              const SizedBox(height: RevisionSpacing.m),
              if (decision.recommendedAction ==
                  LifecycleRecommendedAction.archive)
                _ManagementAction(
                  icon: Icons.archive_outlined,
                  title: 'Archiver',
                  message:
                      'Retirer ce cours de tes cours actifs sans perdre l’historique.',
                  accent: RevisionColors.amber,
                  enabled: decision.canArchive,
                  onTap: () => _archiveCourse(context, ref, detail),
                )
              else
                _ManagementAction(
                  icon: Icons.delete_outline_rounded,
                  title: 'Supprimer',
                  message: 'Possible uniquement si le cours est encore vide.',
                  accent: RevisionColors.red,
                  enabled: decision.canDelete,
                  onTap: () => _deleteCourse(context, ref, detail),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LifecycleMessage extends StatelessWidget {
  const _LifecycleMessage({required this.decision});

  final CourseLifecycleDecision decision;

  @override
  Widget build(BuildContext context) {
    return RevisionGlassCard(
      padding: const EdgeInsets.all(RevisionSpacing.m),
      borderColor: RevisionColors.border,
      child: Text(decision.userMessage, style: RevisionTypography.body),
    );
  }
}

class _ManagementAction extends StatelessWidget {
  const _ManagementAction({
    required this.icon,
    required this.title,
    required this.message,
    required this.onTap,
    this.enabled = true,
    this.accent = RevisionColors.blue,
  });

  final IconData icon;
  final String title;
  final String message;
  final VoidCallback onTap;
  final bool enabled;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return RevisionGlassCard(
      onTap: enabled ? onTap : null,
      padding: const EdgeInsets.all(RevisionSpacing.m),
      borderColor: accent.withValues(alpha: enabled ? 0.34 : 0.16),
      child: Opacity(
        opacity: enabled ? 1 : 0.55,
        child: Row(
          children: [
            RevisionIconTile(icon: icon, accent: accent, size: 44),
            const SizedBox(width: RevisionSpacing.m),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: RevisionTypography.sectionTitle),
                  const SizedBox(height: RevisionSpacing.xs),
                  Text(message, style: RevisionTypography.caption),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> _renameCourse(
  BuildContext context,
  WidgetRef ref,
  CourseDetail detail,
) async {
  final controller = TextEditingController(text: detail.course.title);
  final title = await showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Renommer le cours'),
      content: TextField(
        controller: controller,
        autofocus: true,
        decoration: const InputDecoration(labelText: 'Nouveau titre'),
        textInputAction: TextInputAction.done,
        onSubmitted: (value) => Navigator.of(context).pop(value),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annuler'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(controller.text),
          child: const Text('Enregistrer'),
        ),
      ],
    ),
  );

  controller.dispose();
  final trimmed = title?.trim();
  if (trimmed == null || trimmed.length < 2 || !context.mounted) {
    return;
  }

  try {
    await ref
        .read(updateCourseControllerProvider.notifier)
        .update(
          detail: detail,
          input: UpdateCourseInput(title: trimmed),
        );
    if (context.mounted) {
      Navigator.of(context).pop(CourseManagementResult.changed);
    }
  } on CourseLifecycleBlockedException catch (error) {
    if (context.mounted) {
      _showBlockedSnackBar(context, error.message);
    }
  }
}

Future<void> _archiveCourse(
  BuildContext context,
  WidgetRef ref,
  CourseDetail detail,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Archiver ce cours ?'),
      content: const Text(
        'Ce cours contient déjà des sources ou des révisions. Il sera retiré de tes cours actifs, mais l’historique sera conservé.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Annuler'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Archiver'),
        ),
      ],
    ),
  );

  if (confirmed != true || !context.mounted) {
    return;
  }

  try {
    await ref
        .read(archiveCourseControllerProvider.notifier)
        .archive(detail: detail);
    if (context.mounted) {
      Navigator.of(context).pop(CourseManagementResult.removed);
    }
  } on CourseLifecycleBlockedException catch (error) {
    if (context.mounted) {
      _showBlockedSnackBar(context, error.message);
    }
  }
}

Future<void> _deleteCourse(
  BuildContext context,
  WidgetRef ref,
  CourseDetail detail,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Supprimer ce cours ?'),
      content: const Text(
        'Ce cours ne contient encore aucune source ni révision. Il sera retiré définitivement.',
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
    await ref
        .read(deleteCourseControllerProvider.notifier)
        .delete(detail: detail);
    if (context.mounted) {
      Navigator.of(context).pop(CourseManagementResult.removed);
    }
  } on CourseLifecycleBlockedException catch (error) {
    if (context.mounted) {
      _showBlockedSnackBar(context, error.message);
    }
  }
}

void _showBlockedSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}
