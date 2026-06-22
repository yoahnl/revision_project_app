import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Neralune/features/subjects/application/subjects_notifier.dart';
import 'package:Neralune/features/subjects/domain/subject.dart';
import 'package:Neralune/presentation/design_system/components/revision_mvp_components.dart';
import 'package:Neralune/presentation/design_system/components/revision_states.dart';
import 'package:Neralune/presentation/design_system/tokens/revision_colors.dart';
import 'package:Neralune/presentation/design_system/tokens/revision_spacing.dart';
import 'package:Neralune/presentation/design_system/tokens/revision_typography.dart';

enum SubjectManagementResult { changed, removed }

Future<SubjectManagementResult?> showSubjectManagementSheet({
  required BuildContext context,
  required Subject subject,
}) {
  return showModalBottomSheet<SubjectManagementResult>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _SubjectManagementSheet(subject: subject),
  );
}

class _SubjectManagementSheet extends ConsumerStatefulWidget {
  const _SubjectManagementSheet({required this.subject});

  final Subject subject;

  @override
  ConsumerState<_SubjectManagementSheet> createState() =>
      _SubjectManagementSheetState();
}

class _SubjectManagementSheetState
    extends ConsumerState<_SubjectManagementSheet> {
  late Future<SubjectLifecycleDecision> _lifecycle;

  @override
  void initState() {
    super.initState();
    _lifecycle = _loadLifecycle();
  }

  Future<SubjectLifecycleDecision> _loadLifecycle() {
    return ref
        .read(subjectsNotifierProvider.notifier)
        .getSubjectLifecycle(widget.subject.id);
  }

  void _retry() {
    setState(() {
      _lifecycle = _loadLifecycle();
    });
  }

  @override
  Widget build(BuildContext context) {
    return RevisionBottomSheetFrame(
      title: 'Gérer la matière',
      subtitle: widget.subject.name,
      children: [
        FutureBuilder<SubjectLifecycleDecision>(
          future: _lifecycle,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const RevisionLoadingState(
                label: 'Vérification de la matière',
              );
            }

            final decision = snapshot.data;
            if (snapshot.hasError || decision == null) {
              return RevisionErrorState(
                title: 'Actions indisponibles',
                message: 'Impossible de vérifier cette matière pour le moment.',
                actionLabel: 'Réessayer',
                onAction: _retry,
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _LifecycleMessage(decision: decision),
                const SizedBox(height: RevisionSpacing.m),
                _ManagementAction(
                  icon: Icons.edit_rounded,
                  title: 'Renommer',
                  message: 'Modifier le nom affiché dans tes matières.',
                  enabled: decision.canUpdate,
                  onTap: () => _renameSubject(context, ref, widget.subject),
                ),
                const SizedBox(height: RevisionSpacing.m),
                if (decision.recommendedAction ==
                    SubjectLifecycleRecommendedAction.archive)
                  _ManagementAction(
                    icon: Icons.archive_outlined,
                    title: 'Archiver',
                    message:
                        'Retirer cette matière des matières actives sans perdre l’historique.',
                    accent: RevisionColors.amber,
                    enabled: decision.canArchive,
                    onTap: () => _archiveSubject(context, ref, widget.subject),
                  )
                else
                  _ManagementAction(
                    icon: Icons.delete_outline_rounded,
                    title: 'Supprimer',
                    message:
                        'Possible uniquement si la matière est encore vide.',
                    accent: RevisionColors.red,
                    enabled: decision.canDelete,
                    onTap: () => _deleteSubject(context, ref, widget.subject),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _LifecycleMessage extends StatelessWidget {
  const _LifecycleMessage({required this.decision});

  final SubjectLifecycleDecision decision;

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

Future<void> _renameSubject(
  BuildContext context,
  WidgetRef ref,
  Subject subject,
) async {
  final controller = TextEditingController(text: subject.name);
  final name = await showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Renommer la matière'),
      content: TextField(
        controller: controller,
        autofocus: true,
        decoration: const InputDecoration(labelText: 'Nouveau nom'),
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
  final trimmed = name?.trim();
  if (trimmed == null || trimmed.length < 2 || !context.mounted) {
    return;
  }

  try {
    await ref
        .read(subjectsNotifierProvider.notifier)
        .updateSubject(
          id: subject.id,
          name: trimmed,
          priority: subject.priority,
        );
    if (context.mounted) {
      Navigator.of(context).pop(SubjectManagementResult.changed);
    }
  } on SubjectLifecycleBlockedException catch (error) {
    if (context.mounted) {
      _showBlockedSnackBar(context, error.message);
    }
  }
}

Future<void> _archiveSubject(
  BuildContext context,
  WidgetRef ref,
  Subject subject,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Archiver cette matière ?'),
      content: const Text(
        'Cette matière contient déjà des cours ou des révisions. Elle disparaîtra des matières actives, mais tes données resteront conservées.',
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
        .read(subjectsNotifierProvider.notifier)
        .archiveSubject(subject.id);
    if (context.mounted) {
      Navigator.of(context).pop(SubjectManagementResult.removed);
    }
  } on SubjectLifecycleBlockedException catch (error) {
    if (context.mounted) {
      _showBlockedSnackBar(context, error.message);
    }
  }
}

Future<void> _deleteSubject(
  BuildContext context,
  WidgetRef ref,
  Subject subject,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Supprimer cette matière ?'),
      content: const Text(
        'Cette matière ne contient encore aucun cours ni révision. Elle sera retirée définitivement.',
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
    await ref.read(subjectsNotifierProvider.notifier).deleteSubject(subject.id);
    if (context.mounted) {
      Navigator.of(context).pop(SubjectManagementResult.removed);
    }
  } on SubjectLifecycleBlockedException catch (error) {
    if (context.mounted) {
      _showBlockedSnackBar(context, error.message);
    }
  }
}

void _showBlockedSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}
