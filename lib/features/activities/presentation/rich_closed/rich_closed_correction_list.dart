import 'package:flutter/material.dart';
import 'package:revision_app/features/activities/domain/rich_closed_exercise.dart';
import 'package:revision_app/features/activities/presentation/rich_closed/rich_closed_correction_card.dart';
import 'package:revision_app/features/activities/presentation/rich_closed/rich_closed_correction_presenter.dart';
import 'package:revision_app/features/activities/presentation/rich_closed/rich_closed_result_summary_card.dart';
import 'package:revision_app/presentation/theme/app_spacing.dart';
import 'package:revision_app/presentation/widgets/revision_message.dart';

class RichClosedCorrectionList extends StatelessWidget {
  const RichClosedCorrectionList({
    required this.exercise,
    required this.result,
    this.presenter = const RichClosedCorrectionPresenter(),
    super.key,
  });

  final RichClosedExercise exercise;
  final RichClosedExerciseResult result;
  final RichClosedCorrectionPresenter presenter;

  @override
  Widget build(BuildContext context) {
    late final RichClosedCorrectionViewModel viewModel;
    try {
      viewModel = presenter.present(exercise: exercise, result: result);
    } on RichClosedCorrectionPresentationException catch (error) {
      return RichClosedCorrectionErrorMessage(
        message: 'Correction indisponible : ${error.message}',
        color: Theme.of(context).colorScheme.error,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichClosedResultSummaryCard(summary: viewModel.summary),
        const SizedBox(height: AppSpacing.l),
        for (final item in viewModel.items) ...[
          RichClosedCorrectionCard(item: item),
          const SizedBox(height: AppSpacing.l),
        ],
      ],
    );
  }
}

class RichClosedCorrectionErrorMessage extends StatelessWidget {
  const RichClosedCorrectionErrorMessage({
    required this.message,
    required this.color,
    super.key,
  });

  final String message;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return RevisionMessage(
      message: message,
      color: color,
      icon: Icons.error_outline,
    );
  }
}
