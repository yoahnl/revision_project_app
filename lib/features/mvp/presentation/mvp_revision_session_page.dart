import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_routes.dart';
import '../../../presentation/design_system/components/revision_mvp_components.dart';
import '../../../presentation/design_system/tokens/revision_colors.dart';
import '../../../presentation/design_system/tokens/revision_spacing.dart';
import '../../../presentation/design_system/tokens/revision_typography.dart';
import '../application/mvp_study_controller.dart';
import '../domain/mvp_study_models.dart';
import 'mvp_page_helpers.dart';

class MvpRevisionSessionPage extends StatefulWidget {
  const MvpRevisionSessionPage({
    required this.sessionId,
    this.courseId,
    this.mode,
    super.key,
  });

  final String sessionId;
  final String? courseId;
  final String? mode;

  @override
  State<MvpRevisionSessionPage> createState() => _MvpRevisionSessionPageState();
}

class _MvpRevisionSessionPageState extends State<MvpRevisionSessionPage> {
  int _questionIndex = 0;
  String? _selectedChoice;
  bool _validated = false;

  @override
  Widget build(BuildContext context) {
    final course = MvpStudyController.instance.courseOrFallback(
      widget.courseId ?? MvpStudyController.instance.resumeCourse.id,
    );
    final mode = _modeFromName(widget.mode);
    final question = mvpSessionQuestions[_questionIndex];
    final isCorrect = _selectedChoice == question.correctChoice;

    return RevisionPageScaffold(
      children: [
        MvpBackBar(
          title: mode.sessionTitle,
          trailing: mvpSmallPill(
            icon: Icons.timer_outlined,
            label: '20 min',
            color: RevisionColors.textMuted,
          ),
        ),
        Row(
          children: [
            RevisionIconTile(
              icon: course.icon,
              accent: course.accent,
              size: 58,
            ),
            const SizedBox(width: RevisionSpacing.m),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(course.title, style: RevisionTypography.sectionTitle),
                  Text(course.chapterLabel, style: RevisionTypography.body),
                ],
              ),
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Question ${_questionIndex + 1} sur ${mvpSessionQuestions.length}',
              style: RevisionTypography.body.copyWith(
                color: RevisionColors.text,
              ),
            ),
            const SizedBox(height: RevisionSpacing.s),
            RevisionProgressLine(
              value: (_questionIndex + 1) / mvpSessionQuestions.length,
              color: RevisionColors.blue,
            ),
          ],
        ),
        RevisionGlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                question.prompt,
                style: RevisionTypography.body.copyWith(
                  color: RevisionColors.text,
                ),
              ),
              const SizedBox(height: RevisionSpacing.l),
              for (var index = 0; index < question.choices.length; index++) ...[
                _ChoiceTile(
                  letter: String.fromCharCode(65 + index),
                  label: question.choices[index],
                  selected: _selectedChoice == question.choices[index],
                  correct:
                      _validated &&
                      question.choices[index] == question.correctChoice,
                  incorrect:
                      _validated &&
                      _selectedChoice == question.choices[index] &&
                      question.choices[index] != question.correctChoice,
                  onTap: _validated
                      ? null
                      : () => setState(
                          () => _selectedChoice = question.choices[index],
                        ),
                ),
                if (index != question.choices.length - 1)
                  const SizedBox(height: RevisionSpacing.s),
              ],
              if (_validated) ...[
                const SizedBox(height: RevisionSpacing.l),
                Text(
                  isCorrect
                      ? 'Bonne réponse, on continue.'
                      : 'À revoir : pense à standardiser avant de lire la table.',
                  style: RevisionTypography.body.copyWith(
                    color: isCorrect
                        ? RevisionColors.green
                        : RevisionColors.amber,
                  ),
                ),
              ],
            ],
          ),
        ),
        RevisionGradientButton(
          label: _validated ? 'Continuer' : 'Valider',
          expanded: true,
          onPressed: _selectedChoice == null
              ? null
              : () {
                  if (!_validated) {
                    setState(() => _validated = true);
                    return;
                  }

                  if (_questionIndex < mvpSessionQuestions.length - 1) {
                    setState(() {
                      _questionIndex++;
                      _selectedChoice = null;
                      _validated = false;
                    });
                    return;
                  }

                  context.go(
                    AppRoutes.revisionSessionResultV2(
                      sessionId: widget.sessionId,
                      courseId: course.id,
                      mode: mode.name,
                    ),
                  );
                },
        ),
      ],
    );
  }
}

class _ChoiceTile extends StatelessWidget {
  const _ChoiceTile({
    required this.letter,
    required this.label,
    required this.selected,
    required this.correct,
    required this.incorrect,
    required this.onTap,
  });

  final String letter;
  final String label;
  final bool selected;
  final bool correct;
  final bool incorrect;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final borderColor = correct
        ? RevisionColors.green
        : incorrect
        ? RevisionColors.coral
        : selected
        ? RevisionColors.blue
        : RevisionColors.border;

    return RevisionGlassCard(
      onTap: onTap,
      selected: selected || correct || incorrect,
      borderColor: borderColor,
      padding: const EdgeInsets.all(RevisionSpacing.m),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: borderColor.withValues(alpha: 0.18),
            child: Text(
              letter,
              style: TextStyle(
                color: borderColor,
                fontWeight: FontWeight.w900,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: RevisionSpacing.m),
          Expanded(
            child: Text(
              label,
              style: RevisionTypography.body.copyWith(
                color: RevisionColors.text,
              ),
            ),
          ),
          if (correct)
            const Icon(Icons.check_circle_rounded, color: RevisionColors.green)
          else if (incorrect)
            const Icon(Icons.cancel_rounded, color: RevisionColors.coral)
          else if (selected)
            const Icon(
              Icons.radio_button_checked_rounded,
              color: RevisionColors.blue,
            ),
        ],
      ),
    );
  }
}

MvpRevisionMode _modeFromName(String? name) {
  return MvpRevisionMode.values.firstWhere(
    (mode) => mode.name == name,
    orElse: () => MvpRevisionMode.quick,
  );
}
