import 'package:flutter/material.dart';

import '../../../../presentation/design_system/components/revision_mvp_components.dart';
import '../../../../presentation/design_system/tokens/revision_colors.dart';
import '../../../../presentation/design_system/tokens/revision_radius.dart';
import '../../../../presentation/design_system/tokens/revision_spacing.dart';
import '../../../../presentation/design_system/tokens/revision_typography.dart';

class QuickRevisionQuestionCountSheet extends StatefulWidget {
  const QuickRevisionQuestionCountSheet({super.key});

  @override
  State<QuickRevisionQuestionCountSheet> createState() =>
      _QuickRevisionQuestionCountSheetState();
}

class _QuickRevisionQuestionCountSheetState
    extends State<QuickRevisionQuestionCountSheet> {
  static const _choices = [5, 10, 20, 30];

  int _selectedQuestionCount = 10;

  @override
  Widget build(BuildContext context) {
    return RevisionBottomSheetFrame(
      title: 'Révision rapide',
      subtitle: 'Choisis le nombre de questions pour cette session.',
      children: [
        Wrap(
          spacing: RevisionSpacing.s,
          runSpacing: RevisionSpacing.s,
          children: [
            for (final choice in _choices)
              _QuestionCountChip(
                count: choice,
                selected: choice == _selectedQuestionCount,
                onTap: () => setState(() {
                  _selectedQuestionCount = choice;
                }),
              ),
          ],
        ),
        const SizedBox(height: RevisionSpacing.l),
        RevisionGradientButton(
          label: 'Démarrer',
          icon: Icons.play_arrow_rounded,
          expanded: true,
          onPressed: () => Navigator.of(context).pop(_selectedQuestionCount),
        ),
        const SizedBox(height: RevisionSpacing.s),
        Text(
          'Les questions viennent de la banque du cours. Si elle en manque, le service en prépare par petits lots.',
          style: RevisionTypography.caption,
        ),
      ],
    );
  }
}

class _QuestionCountChip extends StatelessWidget {
  const _QuestionCountChip({
    required this.count,
    required this.selected,
    required this.onTap,
  });

  final int count;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: RevisionRadius.pill,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(
          horizontal: RevisionSpacing.l,
          vertical: RevisionSpacing.s,
        ),
        decoration: BoxDecoration(
          gradient: selected
              ? const LinearGradient(
                  colors: [RevisionColors.blue, RevisionColors.blueDeep],
                )
              : null,
          color: selected ? null : RevisionColors.glassSoft,
          borderRadius: RevisionRadius.pill,
          border: Border.all(
            color: selected ? RevisionColors.blue : RevisionColors.border,
          ),
        ),
        child: Text(
          '$count questions',
          style: RevisionTypography.body.copyWith(
            color: selected ? RevisionColors.text : RevisionColors.textMuted,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
