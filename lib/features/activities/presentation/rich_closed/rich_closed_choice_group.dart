import 'package:flutter/material.dart';
import 'package:revision_app/features/activities/domain/rich_closed_exercise.dart';
import 'package:revision_app/presentation/theme/app_spacing.dart';
import 'package:revision_app/presentation/widgets/revision_choice_tile.dart';

class RichClosedChoiceGroup extends StatelessWidget {
  const RichClosedChoiceGroup({
    required this.choices,
    required this.selectedChoiceIds,
    required this.onChoiceSelected,
    this.enabled = true,
    super.key,
  });

  final List<RichClosedChoice> choices;
  final List<String> selectedChoiceIds;
  final ValueChanged<String> onChoiceSelected;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final choice in choices)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.s),
            child: Semantics(
              selected: selectedChoiceIds.contains(choice.id),
              button: true,
              child: RevisionChoiceTile(
                label: choice.label,
                selected: selectedChoiceIds.contains(choice.id),
                enabled: enabled,
                onTap: () => onChoiceSelected(choice.id),
              ),
            ),
          ),
      ],
    );
  }
}
