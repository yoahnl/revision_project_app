import 'package:flutter/material.dart';
import 'package:revision_app/features/activities/domain/rich_closed_exercise.dart';
import 'package:revision_app/features/activities/presentation/rich_closed/rich_closed_answer_controller.dart';
import 'package:revision_app/features/activities/presentation/rich_closed/rich_closed_image_asset_registry.dart';
import 'package:revision_app/features/activities/presentation/rich_closed/rich_closed_question_card.dart';
import 'package:revision_app/presentation/theme/app_spacing.dart';

class RichClosedImageChoiceWidget extends StatefulWidget {
  const RichClosedImageChoiceWidget({
    required this.question,
    required this.onAnswerChanged,
    this.controller,
    this.enabled = true,
    super.key,
  });

  final RichClosedImageChoiceQuestion question;
  final ValueChanged<RichClosedImageChoiceAnswer?> onAnswerChanged;
  final RichClosedCoreAnswerController? controller;
  final bool enabled;

  @override
  State<RichClosedImageChoiceWidget> createState() =>
      _RichClosedImageChoiceWidgetState();
}

class _RichClosedImageChoiceWidgetState
    extends State<RichClosedImageChoiceWidget> {
  late RichClosedCoreAnswerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? RichClosedCoreAnswerController();
  }

  @override
  void didUpdateWidget(covariant RichClosedImageChoiceWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.question.id != widget.question.id ||
        oldWidget.controller != widget.controller) {
      _controller = widget.controller ?? RichClosedCoreAnswerController();
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedChoiceId = _controller.selectedImageChoiceIdFor(
      widget.question.id,
    );

    return RichClosedQuestionCard(
      question: widget.question,
      children: [
        if (widget.question.instruction != null) ...[
          Text(
            widget.question.instruction!,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: AppSpacing.s),
        ],
        for (final choice in widget.question.choices)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.s),
            child: _ImageChoiceTile(
              key: ValueKey('image-choice-${widget.question.id}-${choice.id}'),
              choice: choice,
              selected: selectedChoiceId == choice.id,
              enabled: widget.enabled,
              onTap: () => _selectChoice(choice.id),
            ),
          ),
      ],
    );
  }

  void _selectChoice(String choiceId) {
    if (!widget.enabled) {
      return;
    }

    setState(() {
      _controller.selectImageChoice(
        question: widget.question,
        choiceId: choiceId,
      );
    });

    final answer = _controller.answerFor(widget.question);
    widget.onAnswerChanged(
      answer is RichClosedImageChoiceAnswer ? answer : null,
    );
  }
}

class _ImageChoiceTile extends StatelessWidget {
  const _ImageChoiceTile({
    required this.choice,
    required this.selected,
    required this.enabled,
    required this.onTap,
    super.key,
  });

  final RichClosedImageChoiceOption choice;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final asset = resolveRichClosedImageAssetView(choice);

    return Semantics(
      button: true,
      image: true,
      enabled: enabled,
      selected: selected,
      label: '${choice.label}. ${asset.altText}',
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(8),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: selected ? colorScheme.primaryContainer : null,
            border: Border.all(
              color: selected
                  ? colorScheme.primary
                  : colorScheme.outlineVariant,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.m),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ImageChoicePreview(asset: asset),
                const SizedBox(width: AppSpacing.m),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(choice.label),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        choice.caption ?? asset.fallbackLabel,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      if (choice.creditLabel != null) ...[
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          choice.creditLabel!,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.s),
                Icon(
                  selected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  color: selected
                      ? colorScheme.primary
                      : colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ImageChoicePreview extends StatelessWidget {
  const _ImageChoicePreview({required this.asset});

  final RichClosedImageAssetView asset;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final assetPath = asset.assetPath;

    if (assetPath != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.asset(
          assetPath,
          width: 84,
          height: 84,
          fit: BoxFit.cover,
          semanticLabel: asset.altText,
        ),
      );
    }

    return Container(
      width: 84,
      height: 84,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_outline, color: colorScheme.onSurfaceVariant),
          const SizedBox(height: AppSpacing.xs),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
            child: Text(
              asset.fallbackLabel,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ),
        ],
      ),
    );
  }
}
