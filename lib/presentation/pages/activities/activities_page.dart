import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:Neralune/app/router/app_routes.dart';
import 'package:Neralune/core/routing/route_paths.dart';
import 'package:Neralune/features/activities/application/activity_controller.dart';
import 'package:Neralune/features/activities/domain/diagnostic_quiz_activity.dart';
import 'package:Neralune/features/activities/domain/open_question_activity.dart';
import 'package:Neralune/features/activities/genui/diagnostic_quiz_activity_validator.dart';
import 'package:Neralune/features/activities/genui/revision_activity_catalog.dart';
import 'package:Neralune/presentation/theme/app_spacing.dart';
import 'package:Neralune/presentation/widgets/revision_button.dart';
import 'package:Neralune/presentation/widgets/revision_message.dart';
import 'package:Neralune/presentation/widgets/revision_page.dart';
import 'package:Neralune/presentation/widgets/revision_panel.dart';

import 'diagnostic_quiz_page.dart';
import 'open_question_page.dart';

class ActivitiesPage extends StatefulWidget {
  const ActivitiesPage({
    required this.controller,
    required this.subjectId,
    this.knowledgeUnitId,
    super.key,
  });

  final ActivityController controller;
  final String? subjectId;
  final String? knowledgeUnitId;

  @override
  State<ActivitiesPage> createState() => _ActivitiesPageState();
}

class _ActivitiesPageState extends State<ActivitiesPage> {
  static const _activityLoadTimeout = Duration(seconds: 9);

  Future<_LoadedActivity>? _activity;
  _ActivityKind _selectedKind = _ActivityKind.diagnosticQuiz;
  final _catalog = buildRevisionActivityCatalog();

  @override
  void initState() {
    super.initState();
    _setActivityFromCurrentParams();
  }

  @override
  void didUpdateWidget(covariant ActivitiesPage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (_normalizeId(oldWidget.subjectId) != _trimmedSubjectId ||
        _normalizeId(oldWidget.knowledgeUnitId) != _trimmedKnowledgeUnitId) {
      setState(_setActivityFromCurrentParams);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasSubjectContext = _trimmedSubjectId != null;

    return RevisionPage(
      title: 'Activites',
      subtitle: 'Diagnostics rapides et exercices adaptatifs.',
      children: [
        if (!hasSubjectContext)
          _NoActivityContextPanel(onOpenCourses: _openCourses)
        else ...[
          _ActivityActions(
            selectedKind: _selectedKind,
            canStartOpenQuestion: _canStartOpenQuestion,
            canStartRevisionSession: true,
            canStartRichClosedExercise: _canStartOpenQuestion,
            onDiagnosticSelected: _startDiagnosticQuiz,
            onOpenQuestionSelected: _startOpenQuestion,
            onRevisionSessionSelected: _startRevisionSession,
            onRichClosedSelected: _startRichClosedExercise,
          ),
          const SizedBox(height: AppSpacing.l),
          SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.68,
            child: _activity == null
                ? _NoActivityContextPanel(onOpenCourses: _openCourses)
                : FutureBuilder<_LoadedActivity>(
                    future: _activity,
                    builder: (context, snapshot) {
                      final loadedActivity = snapshot.data;

                      if (snapshot.connectionState != ConnectionState.done) {
                        return const _LoadingActivityPanel();
                      }

                      if (snapshot.hasError || loadedActivity == null) {
                        if (snapshot.error is _ActivityLoadTimeoutException) {
                          return _ActivityTimeoutPanel(
                            onRetry: _restartSelectedActivity,
                            onOpenCourses: _openCourses,
                          );
                        }

                        return _ActivityUnavailablePanel(
                          onRetry: _restartSelectedActivity,
                          onOpenCourses: _openCourses,
                        );
                      }

                      return switch (loadedActivity) {
                        _LoadedDiagnosticQuiz(:final activity) =>
                          _DiagnosticQuizActivityPanel(
                            activity: activity,
                            controller: widget.controller,
                            catalogId:
                                _catalog.catalogId ?? 'revisionActivityCatalog',
                            onRetry: _restartSelectedActivity,
                            onOpenCourses: _openCourses,
                          ),
                        _LoadedOpenQuestion(:final activity) =>
                          _OpenQuestionActivityPanel(
                            activity: activity,
                            controller: widget.controller,
                          ),
                      };
                    },
                  ),
          ),
        ],
      ],
    );
  }

  bool get _canStartOpenQuestion {
    return _trimmedSubjectId != null && _trimmedKnowledgeUnitId != null;
  }

  String? get _trimmedSubjectId {
    return _normalizeId(widget.subjectId);
  }

  String? get _trimmedKnowledgeUnitId {
    return _normalizeId(widget.knowledgeUnitId);
  }

  String? _normalizeId(String? value) {
    final trimmedValue = value?.trim();
    return trimmedValue == null || trimmedValue.isEmpty ? null : trimmedValue;
  }

  void _setActivityFromCurrentParams() {
    final subjectId = _trimmedSubjectId;
    if (subjectId == null) {
      _selectedKind = _ActivityKind.diagnosticQuiz;
      _activity = null;
      return;
    }

    final knowledgeUnitId = _trimmedKnowledgeUnitId;
    if (knowledgeUnitId != null) {
      _selectedKind = _ActivityKind.openQuestion;
      _activity = _loadOpenQuestion(
        subjectId: subjectId,
        knowledgeUnitId: knowledgeUnitId,
      );
      return;
    }

    _selectedKind = _ActivityKind.diagnosticQuiz;
    _activity = _loadDiagnosticQuiz(subjectId);
  }

  Future<_LoadedActivity> _loadDiagnosticQuiz(String subjectId) {
    return _withActivityTimeout(
      widget.controller
          .startNextActivity(
            subjectId: subjectId,
            knowledgeUnitId: _trimmedKnowledgeUnitId,
          )
          .then<_LoadedActivity>(_LoadedDiagnosticQuiz.new),
    );
  }

  Future<_LoadedActivity> _loadOpenQuestion({
    required String subjectId,
    required String knowledgeUnitId,
  }) {
    return _withActivityTimeout(
      widget.controller
          .startOpenQuestion(
            subjectId: subjectId,
            knowledgeUnitId: knowledgeUnitId,
          )
          .then<_LoadedActivity>(_LoadedOpenQuestion.new),
    );
  }

  Future<_LoadedActivity> _withActivityTimeout(
    Future<_LoadedActivity> activity,
  ) {
    return activity.timeout(
      _activityLoadTimeout,
      onTimeout: () => throw const _ActivityLoadTimeoutException(),
    );
  }

  void _startDiagnosticQuiz() {
    final subjectId = _trimmedSubjectId;
    if (subjectId == null) {
      return;
    }

    setState(() {
      _selectedKind = _ActivityKind.diagnosticQuiz;
      _activity = _loadDiagnosticQuiz(subjectId);
    });
  }

  void _startOpenQuestion() {
    final subjectId = _trimmedSubjectId;
    final knowledgeUnitId = _trimmedKnowledgeUnitId;
    if (subjectId == null || knowledgeUnitId == null) {
      return;
    }

    setState(() {
      _selectedKind = _ActivityKind.openQuestion;
      _activity = _loadOpenQuestion(
        subjectId: subjectId,
        knowledgeUnitId: knowledgeUnitId,
      );
    });
  }

  void _startRevisionSession() {
    final subjectId = _trimmedSubjectId;
    if (subjectId == null) {
      return;
    }

    context.go(
      revisionSessionRoutePathFor(
        subjectId: subjectId,
        knowledgeUnitId: _trimmedKnowledgeUnitId,
      ),
    );
  }

  void _startRichClosedExercise() {
    final subjectId = _trimmedSubjectId;
    final knowledgeUnitId = _trimmedKnowledgeUnitId;
    if (subjectId == null || knowledgeUnitId == null) {
      return;
    }

    context.go(
      richClosedExerciseRoutePathFor(
        subjectId: subjectId,
        knowledgeUnitId: knowledgeUnitId,
      ),
    );
  }

  void _restartSelectedActivity() {
    switch (_selectedKind) {
      case _ActivityKind.diagnosticQuiz:
        _startDiagnosticQuiz();
      case _ActivityKind.openQuestion:
        _startOpenQuestion();
    }
  }

  void _openCourses() {
    context.go(AppRoutes.home);
  }
}

class _ActivityLoadTimeoutException implements Exception {
  const _ActivityLoadTimeoutException();
}

enum _ActivityKind { diagnosticQuiz, openQuestion }

sealed class _LoadedActivity {
  const _LoadedActivity();
}

class _LoadedDiagnosticQuiz extends _LoadedActivity {
  const _LoadedDiagnosticQuiz(this.activity);

  final DiagnosticQuizActivity activity;
}

class _LoadedOpenQuestion extends _LoadedActivity {
  const _LoadedOpenQuestion(this.activity);

  final OpenQuestionActivity activity;
}

class _ActivityActions extends StatelessWidget {
  const _ActivityActions({
    required this.selectedKind,
    required this.canStartOpenQuestion,
    required this.canStartRevisionSession,
    required this.canStartRichClosedExercise,
    required this.onDiagnosticSelected,
    required this.onOpenQuestionSelected,
    required this.onRevisionSessionSelected,
    required this.onRichClosedSelected,
  });

  final _ActivityKind selectedKind;
  final bool canStartOpenQuestion;
  final bool canStartRevisionSession;
  final bool canStartRichClosedExercise;
  final VoidCallback onDiagnosticSelected;
  final VoidCallback onOpenQuestionSelected;
  final VoidCallback onRevisionSessionSelected;
  final VoidCallback onRichClosedSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: AppSpacing.s,
          runSpacing: AppSpacing.s,
          children: [
            RevisionButton(
              onPressed: onDiagnosticSelected,
              icon: Icons.quiz_outlined,
              label: 'QCM',
              style: selectedKind == _ActivityKind.diagnosticQuiz
                  ? RevisionButtonStyle.primary
                  : RevisionButtonStyle.ghost,
            ),
            RevisionButton(
              onPressed: canStartOpenQuestion ? onOpenQuestionSelected : null,
              icon: Icons.rate_review_outlined,
              label: 'Question ouverte',
              style: selectedKind == _ActivityKind.openQuestion
                  ? RevisionButtonStyle.primary
                  : RevisionButtonStyle.ghost,
            ),
            RevisionButton(
              onPressed: canStartRevisionSession
                  ? onRevisionSessionSelected
                  : null,
              icon: Icons.auto_awesome_outlined,
              label: 'Révision IA',
              style: RevisionButtonStyle.ghost,
            ),
            RevisionButton(
              onPressed: canStartRichClosedExercise
                  ? onRichClosedSelected
                  : null,
              icon: Icons.extension_outlined,
              label: 'QCM complet',
              style: RevisionButtonStyle.ghost,
            ),
          ],
        ),
        if (!canStartOpenQuestion) ...[
          const SizedBox(height: AppSpacing.s),
          RevisionMessage(
            message:
                'Question ouverte et QCM complet disponibles depuis une notion précise du cours.',
            color: Theme.of(context).colorScheme.secondary,
            icon: Icons.info_outline,
          ),
        ],
      ],
    );
  }
}

class _DiagnosticQuizActivityPanel extends StatelessWidget {
  const _DiagnosticQuizActivityPanel({
    required this.activity,
    required this.controller,
    required this.catalogId,
    required this.onRetry,
    required this.onOpenCourses,
  });

  final DiagnosticQuizActivity activity;
  final ActivityController controller;
  final String catalogId;
  final VoidCallback onRetry;
  final VoidCallback onOpenCourses;

  @override
  Widget build(BuildContext context) {
    if (!isDiagnosticQuizActivityCatalogSafe(activity)) {
      return _ActivityUnavailablePanel(
        onRetry: onRetry,
        onOpenCourses: onOpenCourses,
      );
    }

    return RevisionPanel(
      padding: const EdgeInsets.all(AppSpacing.l),
      child: Semantics(
        label: catalogId,
        child: DiagnosticQuizPage(
          activity: activity,
          onSubmit: (answers) {
            return controller.submitResult(
              sessionId: activity.sessionId,
              answers: answers,
            );
          },
        ),
      ),
    );
  }
}

class _NoActivityContextPanel extends StatelessWidget {
  const _NoActivityContextPanel({required this.onOpenCourses});

  final VoidCallback onOpenCourses;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.secondary;

    return RevisionPanel(
      padding: const EdgeInsets.all(AppSpacing.l),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ActivityStateHeader(
            title: 'Choisis une notion depuis un cours',
            message:
                'Les activités se lancent depuis le parcours d’un cours. Ouvre un cours, choisis une notion, puis lance une activité adaptée.',
            icon: Icons.route_outlined,
            color: color,
          ),
          const SizedBox(height: AppSpacing.m),
          RevisionButton(
            label: 'Ouvrir les cours',
            icon: Icons.school_outlined,
            onPressed: onOpenCourses,
          ),
        ],
      ),
    );
  }
}

class _LoadingActivityPanel extends StatelessWidget {
  const _LoadingActivityPanel();

  @override
  Widget build(BuildContext context) {
    return const RevisionPanel(
      padding: EdgeInsets.all(AppSpacing.l),
      child: Center(child: CircularProgressIndicator()),
    );
  }
}

class _ActivityTimeoutPanel extends StatelessWidget {
  const _ActivityTimeoutPanel({
    required this.onRetry,
    required this.onOpenCourses,
  });

  final VoidCallback onRetry;
  final VoidCallback onOpenCourses;

  @override
  Widget build(BuildContext context) {
    return _ActivityActionStatePanel(
      title: 'Cette activité prend plus de temps que prévu',
      message:
          'Neralune prépare encore cette question. Tu peux réessayer ou ouvrir tes cours en attendant.',
      icon: Icons.hourglass_top_outlined,
      onRetry: onRetry,
      onOpenCourses: onOpenCourses,
    );
  }
}

class _ActivityUnavailablePanel extends StatelessWidget {
  const _ActivityUnavailablePanel({
    required this.onRetry,
    required this.onOpenCourses,
  });

  final VoidCallback onRetry;
  final VoidCallback onOpenCourses;

  @override
  Widget build(BuildContext context) {
    return _ActivityActionStatePanel(
      title: 'Activité indisponible pour le moment',
      message:
          'Cette notion n’a pas encore assez de contenu prêt. Tu peux réessayer ou revenir aux cours.',
      icon: Icons.info_outline,
      onRetry: onRetry,
      onOpenCourses: onOpenCourses,
    );
  }
}

class _ActivityActionStatePanel extends StatelessWidget {
  const _ActivityActionStatePanel({
    required this.title,
    required this.message,
    required this.icon,
    required this.onRetry,
    required this.onOpenCourses,
  });

  final String title;
  final String message;
  final IconData icon;
  final VoidCallback onRetry;
  final VoidCallback onOpenCourses;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.secondary;

    return RevisionPanel(
      padding: const EdgeInsets.all(AppSpacing.l),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ActivityStateHeader(
            title: title,
            message: message,
            icon: icon,
            color: color,
          ),
          const SizedBox(height: AppSpacing.m),
          Wrap(
            spacing: AppSpacing.s,
            runSpacing: AppSpacing.s,
            children: [
              RevisionButton(
                label: 'Réessayer',
                icon: Icons.refresh,
                onPressed: onRetry,
              ),
              RevisionButton(
                label: 'Ouvrir les cours',
                icon: Icons.school_outlined,
                style: RevisionButtonStyle.ghost,
                onPressed: onOpenCourses,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActivityStateHeader extends StatelessWidget {
  const _ActivityStateHeader({
    required this.title,
    required this.message,
    required this.icon,
    required this.color,
  });

  final String title;
  final String message;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: AppSpacing.s),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: textTheme.titleMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                message,
                style: textTheme.bodyMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _OpenQuestionActivityPanel extends StatelessWidget {
  const _OpenQuestionActivityPanel({
    required this.activity,
    required this.controller,
  });

  final OpenQuestionActivity activity;
  final ActivityController controller;

  @override
  Widget build(BuildContext context) {
    return RevisionPanel(
      padding: const EdgeInsets.all(AppSpacing.l),
      child: OpenQuestionPage(
        activity: activity,
        onSubmit: (answerText) {
          return controller.submitOpenAnswer(
            sessionId: activity.sessionId,
            answerText: answerText,
          );
        },
      ),
    );
  }
}
