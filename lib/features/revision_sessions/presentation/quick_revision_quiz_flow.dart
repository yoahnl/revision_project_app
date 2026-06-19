import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_routes.dart';
import '../../activities/application/activity_controller.dart';
import '../../activities/domain/diagnostic_quiz_activity.dart';
import '../../courses/application/courses_providers.dart';
import '../../courses/domain/course_models.dart';
import '../application/revision_session_controller.dart';
import '../domain/revision_session.dart';
import '../../../presentation/design_system/components/revision_mvp_components.dart';
import '../../../presentation/design_system/tokens/revision_colors.dart';
import '../../../presentation/design_system/tokens/revision_spacing.dart';
import '../../../presentation/design_system/tokens/revision_typography.dart';

class QuickRevisionQuizFlow extends ConsumerStatefulWidget {
  const QuickRevisionQuizFlow({
    required this.response,
    required this.activity,
    required this.activityController,
    required this.revisionSessionController,
    super.key,
  });

  final RevisionSessionResponse response;
  final DiagnosticQuizActivity activity;
  final ActivityController activityController;
  final RevisionSessionController revisionSessionController;

  @override
  ConsumerState<QuickRevisionQuizFlow> createState() =>
      _QuickRevisionQuizFlowState();
}

class _QuickRevisionQuizFlowState extends ConsumerState<QuickRevisionQuizFlow> {
  final Map<String, Set<String>> _selectedChoiceIds = {};
  int _questionIndex = 0;
  bool _isSubmitting = false;
  bool _activitySubmitted = false;
  Object? _submitError;

  List<DiagnosticQuizQuestion> get _questions => widget.activity.questions;

  @override
  Widget build(BuildContext context) {
    final courseId = widget.response.session.courseId;
    final course = courseId == null
        ? const AsyncValue<CourseDetail?>.data(null)
        : ref
              .watch(courseDetailProvider(courseId))
              .whenData((detail) => detail);
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
                onPressed: () => _confirmExit(context),
                icon: const Icon(
                  Icons.arrow_back_rounded,
                  color: RevisionColors.text,
                ),
              ),
              const Expanded(
                child: Text(
                  'Révision rapide',
                  textAlign: TextAlign.center,
                  style: RevisionTypography.sectionTitle,
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
          course.when(
            data: (detail) => _QuickHeader(
              courseTitle: detail?.course.title ?? widget.activity.title,
              subjectName: detail?.subject.name,
              sourceName: _sourceName(detail, widget.response.currentAction),
            ),
            loading: () => _QuickHeader(
              courseTitle: widget.activity.title,
              subjectName: null,
              sourceName: null,
            ),
            error: (_, _) => _QuickHeader(
              courseTitle: widget.activity.title,
              subjectName: null,
              sourceName: null,
            ),
          ),
          _QuestionProgress(
            current: _questionIndex + 1,
            total: _questions.length,
          ),
          RevisionGlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(question.prompt, style: RevisionTypography.sectionTitle),
                if (question.visuals.isNotEmpty) ...[
                  const SizedBox(height: RevisionSpacing.m),
                  _QuestionVisualsPreview(visuals: question.visuals),
                ],
                const SizedBox(height: RevisionSpacing.l),
                for (final entry in question.choices.indexed) ...[
                  _AnswerChoiceCard(
                    label: _choiceLetter(entry.$1),
                    text: entry.$2.label,
                    selected: selected.contains(entry.$2.id),
                    onTap: () => _toggleChoice(question, entry.$2.id),
                  ),
                  if (entry.$1 != question.choices.length - 1)
                    const SizedBox(height: RevisionSpacing.s),
                ],
                if (question.selectionMode ==
                    DiagnosticQuizSelectionMode.multiple)
                  Padding(
                    padding: const EdgeInsets.only(top: RevisionSpacing.m),
                    child: Text(
                      '${question.minSelections} à ${question.maxSelections} réponses',
                      style: RevisionTypography.caption,
                    ),
                  ),
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
                      ? (_isSubmitting ? 'Validation...' : 'Terminer')
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
                    _activitySubmitted
                        ? 'La session est soumise, mais pas encore finalisée.'
                        : 'Impossible de soumettre la session.',
                    style: RevisionTypography.sectionTitle.copyWith(
                      color: RevisionColors.red,
                    ),
                  ),
                  const SizedBox(height: RevisionSpacing.s),
                  Text(
                    _activitySubmitted
                        ? 'Relance uniquement la finalisation côté backend.'
                        : 'Tes réponses restent sur cet écran.',
                    style: RevisionTypography.body,
                  ),
                  const SizedBox(height: RevisionSpacing.m),
                  RevisionGradientButton(
                    label: _activitySubmitted
                        ? 'Finaliser la session'
                        : 'Réessayer',
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
      if (!_activitySubmitted) {
        await widget.activityController.submitResult(
          sessionId: widget.activity.sessionId,
          answers: _buildAnswers(),
        );
        _activitySubmitted = true;
      }

      await widget.revisionSessionController.completeSession(
        sessionId: widget.response.session.id,
      );

      _invalidateCourseState();

      if (!mounted) {
        return;
      }

      context.go(
        AppRoutes.revisionSessionResultV2(
          sessionId: widget.response.session.id,
          courseId: widget.response.session.courseId,
          mode: 'quick',
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
    ref.invalidate(subjectProgressProvider(widget.response.session.subjectId));
  }

  Future<void> _confirmExit(BuildContext context) async {
    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Quitter la session ?'),
        content: const Text('Les réponses non soumises seront perdues.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Continuer'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Quitter'),
          ),
        ],
      ),
    );

    if (shouldExit != true || !context.mounted) {
      return;
    }

    final courseId = widget.response.session.courseId;
    if (courseId != null) {
      context.go(AppRoutes.course(courseId));
      return;
    }

    context.go(AppRoutes.revisions);
  }

  String? _sourceName(CourseDetail? detail, RevisionSessionAction? action) {
    final documentId = action?.documentId;
    if (detail == null || documentId == null) {
      return null;
    }

    for (final source in detail.sources) {
      if (source.documentId == documentId || source.id == documentId) {
        return source.fileName;
      }
    }

    return null;
  }
}

class _QuickHeader extends StatelessWidget {
  const _QuickHeader({
    required this.courseTitle,
    required this.subjectName,
    required this.sourceName,
  });

  final String courseTitle;
  final String? subjectName;
  final String? sourceName;

  @override
  Widget build(BuildContext context) {
    return RevisionGlassCard(
      gradient: const LinearGradient(
        colors: [RevisionColors.blue, RevisionColors.blueDeep],
      ),
      child: Row(
        children: [
          const RevisionIconTile(
            icon: Icons.flash_on_rounded,
            accent: RevisionColors.cyan,
          ),
          const SizedBox(width: RevisionSpacing.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (subjectName != null)
                  Text(
                    subjectName!,
                    style: RevisionTypography.caption.copyWith(
                      color: RevisionColors.cyan,
                    ),
                  ),
                Text(courseTitle, style: RevisionTypography.pageTitle),
                if (sourceName != null) ...[
                  const SizedBox(height: RevisionSpacing.xs),
                  Text('Source : $sourceName', style: RevisionTypography.body),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuestionProgress extends StatelessWidget {
  const _QuestionProgress({required this.current, required this.total});

  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Question $current sur $total',
          style: RevisionTypography.body.copyWith(color: RevisionColors.text),
        ),
        const SizedBox(height: RevisionSpacing.s),
        RevisionProgressLine(
          value: current / total,
          color: RevisionColors.blue,
        ),
      ],
    );
  }
}

class _QuestionVisualsPreview extends StatelessWidget {
  const _QuestionVisualsPreview({required this.visuals});

  final List<DiagnosticQuizVisual> visuals;

  @override
  Widget build(BuildContext context) {
    final sorted = [...visuals]
      ..sort((a, b) => a.displayOrder.compareTo(b.displayOrder));

    return Column(
      children: [
        for (final visual in sorted) ...[
          _QuestionVisualPreview(visual: visual),
          if (visual != sorted.last) const SizedBox(height: RevisionSpacing.s),
        ],
      ],
    );
  }
}

class _QuestionVisualPreview extends StatelessWidget {
  const _QuestionVisualPreview({required this.visual});

  final DiagnosticQuizVisual visual;

  @override
  Widget build(BuildContext context) {
    return switch (visual) {
      DiagnosticQuizChartVisual chart => _ChartVisualPreview(chart: chart),
      DiagnosticQuizDiagramVisual diagram => _DiagramVisualPreview(
        diagram: diagram,
      ),
      DiagnosticQuizUnsupportedVisual unsupported => _UnsupportedVisualPreview(
        visual: unsupported,
      ),
    };
  }
}

class _VisualPreviewFrame extends StatelessWidget {
  const _VisualPreviewFrame({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(RevisionSpacing.m),
      decoration: BoxDecoration(
        color: RevisionColors.ink2.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: RevisionColors.border),
      ),
      child: child,
    );
  }
}

class _ChartVisualPreview extends StatelessWidget {
  const _ChartVisualPreview({required this.chart});

  final DiagnosticQuizChartVisual chart;

  @override
  Widget build(BuildContext context) {
    return _VisualPreviewFrame(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(chart.title, style: RevisionTypography.sectionTitle),
          if (chart.description != null) ...[
            const SizedBox(height: RevisionSpacing.xs),
            Text(chart.description!, style: RevisionTypography.caption),
          ],
          const SizedBox(height: RevisionSpacing.s),
          for (final row in chart.data.take(4))
            Text(_compactChartRow(row), style: RevisionTypography.caption),
        ],
      ),
    );
  }
}

class _DiagramVisualPreview extends StatelessWidget {
  const _DiagramVisualPreview({required this.diagram});

  final DiagnosticQuizDiagramVisual diagram;

  @override
  Widget build(BuildContext context) {
    return _VisualPreviewFrame(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(diagram.title, style: RevisionTypography.sectionTitle),
          if (diagram.description != null) ...[
            const SizedBox(height: RevisionSpacing.xs),
            Text(diagram.description!, style: RevisionTypography.caption),
          ],
          const SizedBox(height: RevisionSpacing.s),
          for (final node in diagram.nodes.take(5))
            Text('• ${node.label}', style: RevisionTypography.caption),
          for (final edge in diagram.edges.take(5))
            Text(
              '${edge.from} → ${edge.to}${edge.label == null ? '' : ' · ${edge.label}'}',
              style: RevisionTypography.caption,
            ),
        ],
      ),
    );
  }
}

class _UnsupportedVisualPreview extends StatelessWidget {
  const _UnsupportedVisualPreview({required this.visual});

  final DiagnosticQuizUnsupportedVisual visual;

  @override
  Widget build(BuildContext context) {
    return _VisualPreviewFrame(
      child: Text(
        'Visuel non pris en charge',
        style: RevisionTypography.caption.copyWith(color: RevisionColors.text),
      ),
    );
  }
}

String _compactChartRow(Map<String, Object?> row) {
  return row.entries
      .map((entry) => '${entry.key}: ${entry.value ?? '-'}')
      .join(' · ');
}

class _AnswerChoiceCard extends StatelessWidget {
  const _AnswerChoiceCard({
    required this.label,
    required this.text,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String text;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return RevisionGlassCard(
      selected: selected,
      onTap: onTap,
      padding: const EdgeInsets.all(RevisionSpacing.m),
      borderColor: selected ? RevisionColors.blue : RevisionColors.border,
      backgroundColor: selected
          ? RevisionColors.blue.withValues(alpha: 0.18)
          : RevisionColors.glassSoft,
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: selected
                ? RevisionColors.blue.withValues(alpha: 0.8)
                : RevisionColors.ink3,
            child: Text(
              label,
              style: RevisionTypography.caption.copyWith(
                color: RevisionColors.text,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: RevisionSpacing.m),
          Expanded(
            child: Text(
              text,
              style: RevisionTypography.body.copyWith(
                color: RevisionColors.text,
              ),
            ),
          ),
          if (selected)
            const Icon(Icons.check_circle_rounded, color: RevisionColors.cyan),
        ],
      ),
    );
  }
}

String _choiceLetter(int index) {
  const letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  if (index < letters.length) {
    return letters[index];
  }

  return '${index + 1}';
}
