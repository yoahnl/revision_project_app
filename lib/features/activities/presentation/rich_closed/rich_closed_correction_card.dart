import 'package:flutter/material.dart';
import 'package:revision_app/features/activities/presentation/rich_closed/rich_closed_correction_presenter.dart';
import 'package:revision_app/presentation/theme/app_spacing.dart';
import 'package:revision_app/presentation/widgets/revision_panel.dart';
import 'package:revision_app/presentation/widgets/revision_status_pill.dart';

class RichClosedCorrectionCard extends StatelessWidget {
  const RichClosedCorrectionCard({required this.item, super.key});

  final RichClosedCorrectionItemViewModel item;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final statusColor = item.isCorrect
        ? colorScheme.tertiary
        : colorScheme.error;
    final statusIcon = item.isCorrect
        ? Icons.check_circle_outline
        : Icons.cancel_outlined;

    return RevisionPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: AppSpacing.s,
            runSpacing: AppSpacing.s,
            children: [
              RevisionStatusPill(
                label: item.kindLabel,
                color: colorScheme.primary,
                icon: Icons.checklist_rtl,
              ),
              RevisionStatusPill(
                label: item.statusLabel,
                color: statusColor,
                icon: statusIcon,
              ),
              RevisionStatusPill(
                label: 'Score partiel ${item.partialScoreLabel}',
                color: colorScheme.secondary,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.m),
          Text(item.prompt, style: Theme.of(context).textTheme.titleMedium),
          if (item.contextText != null) ...[
            const SizedBox(height: AppSpacing.s),
            _TextBlock(label: 'Contexte', lines: [item.contextText!]),
          ],
          const SizedBox(height: AppSpacing.m),
          _TextBlock(
            label: 'Réponse envoyée',
            lines: item.submittedAnswerLines,
          ),
          const SizedBox(height: AppSpacing.m),
          _TextBlock(label: 'Réponse attendue', lines: item.correctAnswerLines),
          const SizedBox(height: AppSpacing.m),
          _TextBlock(label: 'Explication', lines: [item.explanation]),
          if (item.sourceLabels.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.m),
            Wrap(
              spacing: AppSpacing.s,
              runSpacing: AppSpacing.s,
              children: [
                for (final sourceLabel in item.sourceLabels)
                  RevisionStatusPill(
                    label: sourceLabel,
                    color: colorScheme.secondary,
                    icon: Icons.source_outlined,
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _TextBlock extends StatelessWidget {
  const _TextBlock({required this.label, required this.lines});

  final String label;
  final List<String> lines;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: AppSpacing.xs),
        for (final line in lines)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.xs),
            child: Text(line, style: textTheme.bodyMedium),
          ),
      ],
    );
  }
}
