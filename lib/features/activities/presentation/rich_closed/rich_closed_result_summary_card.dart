import 'package:flutter/material.dart';
import 'package:revision_app/features/activities/presentation/rich_closed/rich_closed_correction_presenter.dart';
import 'package:revision_app/presentation/theme/app_spacing.dart';
import 'package:revision_app/presentation/widgets/revision_panel.dart';
import 'package:revision_app/presentation/widgets/revision_status_pill.dart';

class RichClosedResultSummaryCard extends StatelessWidget {
  const RichClosedResultSummaryCard({required this.summary, super.key});

  final RichClosedResultSummaryViewModel summary;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return RevisionPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: AppSpacing.s,
            runSpacing: AppSpacing.s,
            children: [
              RevisionStatusPill(
                label: summary.status,
                color: colorScheme.tertiary,
                icon: Icons.check_circle_outline,
              ),
              RevisionStatusPill(
                label: summary.answerRatioLabel,
                color: colorScheme.primary,
                icon: Icons.fact_check_outlined,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.m),
          Text('Résultat', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.s),
          Text('Score backend', style: Theme.of(context).textTheme.labelMedium),
          Text(
            summary.scoreLabel,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: AppSpacing.s),
          Text(summary.message, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}
