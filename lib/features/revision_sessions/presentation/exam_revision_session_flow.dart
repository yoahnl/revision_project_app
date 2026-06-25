import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_routes.dart';
import '../../activities/domain/diagnostic_quiz_activity.dart';
import '../../courses/application/courses_providers.dart';
import '../application/revision_session_controller.dart';
import '../domain/revision_session.dart';
import '../../../presentation/design_system/components/revision_mvp_components.dart';
import '../../../presentation/design_system/tokens/revision_colors.dart';
import '../../../presentation/design_system/tokens/revision_spacing.dart';
import '../../../presentation/design_system/tokens/revision_typography.dart';

class ExamRevisionSessionFlow extends ConsumerStatefulWidget {
  const ExamRevisionSessionFlow({
    required this.response,
    required this.activity,
    required this.revisionSessionController,
    super.key,
  });

  final RevisionSessionResponse response;
  final DiagnosticQuizActivity activity;
  final RevisionSessionController revisionSessionController;

  @override
  ConsumerState<ExamRevisionSessionFlow> createState() =>
      _ExamRevisionSessionFlowState();
}

class _ExamRevisionSessionFlowState
    extends ConsumerState<ExamRevisionSessionFlow> {
  final Map<String, Set<String>> _selectedChoiceIds = {};
  int _questionIndex = 0;
  bool _isSubmitting = false;
  Object? _submitError;

  List<DiagnosticQuizQuestion> get _questions => widget.activity.questions;

  @override
  Widget build(BuildContext context) {
    if (_questions.isEmpty) {
      return RevisionPageScaffold(
        children: [
          Text(
            'Préparation examen - QCM',
            style: RevisionTypography.sectionTitle,
          ),
          const RevisionGlassCard(
            child: Text('Aucune question disponible pour cette session.'),
          ),
        ],
      );
    }

    final question = _questions[_questionIndex];
    final selected = _selectedChoiceIds[question.id] ?? <String>{};
    final canContinue = _isQuestionAnswered(question);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          _confirmExit(context);
        }
      },
      child: RevisionPageScaffold(
        children: [
          Row(
            children: [
              IconButton(
                tooltip: 'Retour au cours',
                onPressed: () => _confirmExit(context),
                icon: const Icon(
                  Icons.arrow_back_rounded,
                  color: RevisionColors.text,
                ),
              ),
              const Expanded(
                child: Text(
                  'Préparation examen - QCM',
                  textAlign: TextAlign.center,
                  style: RevisionTypography.sectionTitle,
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
          _ExamHeader(courseTitle: _examQcmTitle(widget.activity.title)),
          _ExamProgress(current: _questionIndex + 1, total: _questions.length),
          RevisionGlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(question.prompt, style: RevisionTypography.sectionTitle),
                if (question.selectionMode ==
                    DiagnosticQuizSelectionMode.multiple)
                  Padding(
                    padding: const EdgeInsets.only(top: RevisionSpacing.s),
                    child: Text(
                      '${question.minSelections} à ${question.maxSelections} réponses',
                      style: RevisionTypography.caption,
                    ),
                  ),
                const SizedBox(height: RevisionSpacing.l),
                for (final entry in question.choices.indexed) ...[
                  _ExamChoiceCard(
                    label: _choiceLetter(entry.$1),
                    text: entry.$2.label,
                    selected: selected.contains(entry.$2.id),
                    onTap: _isSubmitting
                        ? null
                        : () => _toggleChoice(question, entry.$2.id),
                  ),
                  if (entry.$1 != question.choices.length - 1)
                    const SizedBox(height: RevisionSpacing.s),
                ],
              ],
            ),
          ),
          Row(
            children: [
              Expanded(
                child: RevisionGradientButton(
                  label: 'Précédent',
                  icon: Icons.chevron_left_rounded,
                  onPressed: _questionIndex == 0 || _isSubmitting
                      ? null
                      : () => setState(() => _questionIndex -= 1),
                  gradient: const LinearGradient(
                    colors: [RevisionColors.glassStrong, RevisionColors.ink3],
                  ),
                ),
              ),
              const SizedBox(width: RevisionSpacing.m),
              Expanded(
                child: RevisionGradientButton(
                  label: _questionIndex == _questions.length - 1
                      ? (_isSubmitting ? 'Validation...' : 'Valider')
                      : 'Suivant',
                  icon: _questionIndex == _questions.length - 1
                      ? Icons.check_rounded
                      : Icons.chevron_right_rounded,
                  onPressed: canContinue && !_isSubmitting ? _continue : null,
                ),
              ),
            ],
          ),
          if (_submitError != null)
            RevisionGlassCard(
              borderColor: RevisionColors.red,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Validation impossible',
                    style: RevisionTypography.sectionTitle.copyWith(
                      color: RevisionColors.red,
                    ),
                  ),
                  const SizedBox(height: RevisionSpacing.s),
                  const Text(
                    'Tes réponses restent sur cet écran. Réessaie dans un instant.',
                    style: RevisionTypography.body,
                  ),
                  const SizedBox(height: RevisionSpacing.m),
                  RevisionGradientButton(
                    label: 'Réessayer',
                    icon: Icons.refresh_rounded,
                    onPressed: _isSubmitting ? null : _submit,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  bool _isQuestionAnswered(DiagnosticQuizQuestion question) {
    final selected = _selectedChoiceIds[question.id] ?? <String>{};

    return selected.length >= question.minSelections &&
        selected.length <= question.maxSelections;
  }

  void _toggleChoice(DiagnosticQuizQuestion question, String choiceId) {
    setState(() {
      final current = {...?_selectedChoiceIds[question.id]};
      if (question.selectionMode == DiagnosticQuizSelectionMode.single) {
        _selectedChoiceIds[question.id] = {choiceId};
        return;
      }

      if (current.contains(choiceId)) {
        current.remove(choiceId);
      } else if (current.length < question.maxSelections) {
        current.add(choiceId);
      }

      _selectedChoiceIds[question.id] = current;
    });
  }

  void _continue() {
    if (_questionIndex < _questions.length - 1) {
      setState(() => _questionIndex += 1);
      return;
    }

    _submit();
  }

  Future<void> _submit() async {
    setState(() {
      _isSubmitting = true;
      _submitError = null;
    });

    try {
      await widget.revisionSessionController.submitExamPreparationSession(
        sessionId: widget.response.session.id,
        answers: _buildAnswers(),
      );
      _invalidateCourseState();

      if (!mounted) {
        return;
      }

      context.go(
        AppRoutes.revisionSessionResultV2(
          sessionId: widget.response.session.id,
          courseId: widget.response.session.courseId,
          mode: 'exam',
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _submitError = error;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  List<DiagnosticQuizAnswer> _buildAnswers() {
    return _questions
        .map((question) {
          final selected = _selectedChoiceIds[question.id] ?? <String>{};
          final ordered = question.choices
              .map((choice) => choice.id)
              .where(selected.contains)
              .toList(growable: false);

          if (question.selectionMode == DiagnosticQuizSelectionMode.single) {
            return DiagnosticQuizAnswer(
              questionId: question.id,
              choiceId: ordered.first,
            );
          }

          return DiagnosticQuizAnswer(
            questionId: question.id,
            choiceIds: ordered,
          );
        })
        .toList(growable: false);
  }

  void _invalidateCourseState() {
    final courseId = widget.response.session.courseId;
    if (courseId == null) {
      return;
    }

    ref.invalidate(courseDetailProvider(courseId));
    ref.invalidate(courseProgressProvider(courseId));
    ref.invalidate(courseExamPreparationOptionsProvider(courseId));
    ref.invalidate(courseExamPreparationHistoryProvider(courseId));
    ref.invalidate(subjectProgressProvider(widget.response.session.subjectId));
  }

  Future<void> _confirmExit(BuildContext context) async {
    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Quitter la session ?'),
        content: const Text(
          'Tu pourras relancer une préparation depuis le cours.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Continuer'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Quitter'),
          ),
        ],
      ),
    );

    if (!context.mounted || shouldExit != true) {
      return;
    }

    final courseId = widget.response.session.courseId;
    if (courseId == null) {
      context.go(AppRoutes.revisions);
      return;
    }

    context.go(AppRoutes.course(courseId));
  }
}

class _ExamHeader extends StatelessWidget {
  const _ExamHeader({required this.courseTitle});

  final String courseTitle;

  @override
  Widget build(BuildContext context) {
    return RevisionGlassCard(
      child: Row(
        children: [
          const RevisionIconTile(
            icon: Icons.school_rounded,
            accent: RevisionColors.pink,
            size: 44,
          ),
          const SizedBox(width: RevisionSpacing.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(courseTitle, style: RevisionTypography.sectionTitle),
                const SizedBox(height: RevisionSpacing.xs),
                Text(
                  'Entraînement QCM · score calculé à la validation',
                  style: RevisionTypography.caption,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ExamProgress extends StatelessWidget {
  const _ExamProgress({required this.current, required this.total});

  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    final progress = total == 0 ? 0.0 : current / total;

    return RevisionGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Question $current sur $total',
            style: RevisionTypography.caption,
          ),
          const SizedBox(height: RevisionSpacing.s),
          LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            borderRadius: BorderRadius.circular(8),
            color: RevisionColors.pink,
            backgroundColor: RevisionColors.glassStrong,
          ),
        ],
      ),
    );
  }
}

class _ExamChoiceCard extends StatelessWidget {
  const _ExamChoiceCard({
    required this.label,
    required this.text,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String text;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? RevisionColors.pink.withValues(alpha: 0.16) : null,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(RevisionSpacing.m),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? RevisionColors.pink : RevisionColors.border,
            ),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: selected
                    ? RevisionColors.pink
                    : RevisionColors.glassStrong,
                child: Text(
                  label,
                  style: RevisionTypography.caption.copyWith(
                    color: selected ? Colors.white : RevisionColors.text,
                  ),
                ),
              ),
              const SizedBox(width: RevisionSpacing.m),
              Expanded(child: Text(text, style: RevisionTypography.body)),
            ],
          ),
        ),
      ),
    );
  }
}

String _choiceLetter(int index) {
  return String.fromCharCode('A'.codeUnitAt(0) + index);
}

String _examQcmTitle(String title) {
  return title.trim() == 'Préparation examen'
      ? 'Préparation examen - QCM'
      : title;
}
