import 'package:flutter/material.dart';
import 'package:revision_app/features/activities/application/activity_controller.dart';
import 'package:revision_app/features/activities/domain/diagnostic_quiz_activity.dart';
import 'package:revision_app/features/activities/domain/open_question_activity.dart';
import 'package:revision_app/features/activities/genui/diagnostic_quiz_activity_validator.dart';
import 'package:revision_app/features/activities/genui/revision_activity_catalog.dart';
import 'package:revision_app/presentation/theme/app_spacing.dart';
import 'package:revision_app/presentation/widgets/revision_button.dart';
import 'package:revision_app/presentation/widgets/revision_message.dart';
import 'package:revision_app/presentation/widgets/revision_page.dart';
import 'package:revision_app/presentation/widgets/revision_panel.dart';

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
  Future<_LoadedActivity>? _activity;
  _ActivityKind _selectedKind = _ActivityKind.diagnosticQuiz;
  final _catalog = buildRevisionActivityCatalog();

  @override
  void initState() {
    super.initState();
    final subjectId = widget.subjectId?.trim();
    if (subjectId != null && subjectId.isNotEmpty) {
      _activity = _loadDiagnosticQuiz(subjectId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return RevisionPage(
      title: 'Activites',
      subtitle: 'Diagnostics rapides et exercices adaptatifs.',
      children: [
        _ActivityActions(
          selectedKind: _selectedKind,
          canStartOpenQuestion: _canStartOpenQuestion,
          onDiagnosticSelected: _startDiagnosticQuiz,
          onOpenQuestionSelected: _startOpenQuestion,
        ),
        const SizedBox(height: AppSpacing.l),
        SizedBox(
          height: MediaQuery.sizeOf(context).height * 0.68,
          child: _activity == null
              ? const Center(child: Text('Aucune activite selectionnee'))
              : FutureBuilder<_LoadedActivity>(
                  future: _activity,
                  builder: (context, snapshot) {
                    final loadedActivity = snapshot.data;

                    if (snapshot.connectionState != ConnectionState.done) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError || loadedActivity == null) {
                      return const Center(
                        child: Text("Impossible de charger l'activite"),
                      );
                    }

                    return switch (loadedActivity) {
                      _LoadedDiagnosticQuiz(:final activity) =>
                        _DiagnosticQuizActivityPanel(
                          activity: activity,
                          controller: widget.controller,
                          catalogId: _catalog.catalogId ?? 'revisionActivityCatalog',
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
    );
  }

  bool get _canStartOpenQuestion {
    final subjectId = widget.subjectId?.trim();
    final knowledgeUnitId = widget.knowledgeUnitId?.trim();

    return subjectId != null &&
        subjectId.isNotEmpty &&
        knowledgeUnitId != null &&
        knowledgeUnitId.isNotEmpty;
  }

  String? get _trimmedKnowledgeUnitId {
    final knowledgeUnitId = widget.knowledgeUnitId?.trim();
    return knowledgeUnitId == null || knowledgeUnitId.isEmpty
        ? null
        : knowledgeUnitId;
  }

  Future<_LoadedActivity> _loadDiagnosticQuiz(String subjectId) async {
    final activity = await widget.controller.startNextActivity(
      subjectId: subjectId,
      knowledgeUnitId: _trimmedKnowledgeUnitId,
    );

    return _LoadedDiagnosticQuiz(activity);
  }

  Future<_LoadedActivity> _loadOpenQuestion({
    required String subjectId,
    required String knowledgeUnitId,
  }) async {
    final activity = await widget.controller.startOpenQuestion(
      subjectId: subjectId,
      knowledgeUnitId: knowledgeUnitId,
    );

    return _LoadedOpenQuestion(activity);
  }

  void _startDiagnosticQuiz() {
    final subjectId = widget.subjectId?.trim();
    if (subjectId == null || subjectId.isEmpty) {
      return;
    }

    setState(() {
      _selectedKind = _ActivityKind.diagnosticQuiz;
      _activity = _loadDiagnosticQuiz(subjectId);
    });
  }

  void _startOpenQuestion() {
    final subjectId = widget.subjectId?.trim();
    final knowledgeUnitId = _trimmedKnowledgeUnitId;
    if (subjectId == null ||
        subjectId.isEmpty ||
        knowledgeUnitId == null ||
        knowledgeUnitId.isEmpty) {
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
    required this.onDiagnosticSelected,
    required this.onOpenQuestionSelected,
  });

  final _ActivityKind selectedKind;
  final bool canStartOpenQuestion;
  final VoidCallback onDiagnosticSelected;
  final VoidCallback onOpenQuestionSelected;

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
          ],
        ),
        if (!canStartOpenQuestion) ...[
          const SizedBox(height: AppSpacing.s),
          RevisionMessage(
            message:
                'Question ouverte disponible depuis une notion précise du cours.',
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
  });

  final DiagnosticQuizActivity activity;
  final ActivityController controller;
  final String catalogId;

  @override
  Widget build(BuildContext context) {
    if (!isDiagnosticQuizActivityCatalogSafe(activity)) {
      return const Center(child: Text('Activite indisponible'));
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
