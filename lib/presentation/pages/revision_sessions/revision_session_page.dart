import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:Neralune/app/router/app_routes.dart';
import 'package:Neralune/features/activities/application/activity_controller.dart';
import 'package:Neralune/features/activities/domain/diagnostic_quiz_activity.dart';
import 'package:Neralune/features/revision_sessions/application/revision_session_controller.dart';
import 'package:Neralune/features/revision_sessions/data/revision_sessions_api.dart';
import 'package:Neralune/features/revision_sessions/domain/revision_session.dart';
import 'package:Neralune/features/revision_sessions/presentation/exam_revision_session_flow.dart';
import 'package:Neralune/features/revision_sessions/presentation/quick_revision_quiz_flow.dart';
import 'package:Neralune/core/routing/route_paths.dart';
import 'package:Neralune/presentation/pages/activities/diagnostic_quiz_page.dart';
import 'package:Neralune/presentation/pages/activities/open_question_page.dart';
import 'package:Neralune/presentation/theme/app_spacing.dart';
import 'package:Neralune/presentation/widgets/revision_button.dart';
import 'package:Neralune/presentation/widgets/revision_message.dart';
import 'package:Neralune/presentation/widgets/revision_page.dart';
import 'package:Neralune/presentation/widgets/revision_panel.dart';
import 'package:Neralune/presentation/widgets/revision_status_pill.dart';

class RevisionSessionPage extends StatefulWidget {
  const RevisionSessionPage({
    required this.revisionSessionController,
    required this.activityController,
    this.sessionId,
    this.subjectId,
    this.documentId,
    this.knowledgeUnitId,
    this.preferredAction,
    this.mode,
    super.key,
  });

  final RevisionSessionController revisionSessionController;
  final ActivityController activityController;
  final String? sessionId;
  final String? subjectId;
  final String? documentId;
  final String? knowledgeUnitId;
  final RevisionSessionPreferredAction? preferredAction;
  final String? mode;

  @override
  State<RevisionSessionPage> createState() => _RevisionSessionPageState();
}

class _RevisionSessionPageState extends State<RevisionSessionPage> {
  Future<RevisionSessionResponse>? _session;

  @override
  void initState() {
    super.initState();
    _session = _loadFromParams();
  }

  @override
  void didUpdateWidget(covariant RevisionSessionPage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (_normalizeId(oldWidget.sessionId) != _trimmedSessionId ||
        _normalizeId(oldWidget.subjectId) != _trimmedSubjectId ||
        _normalizeId(oldWidget.documentId) != _trimmedDocumentId ||
        _normalizeId(oldWidget.knowledgeUnitId) != _trimmedKnowledgeUnitId ||
        oldWidget.preferredAction != widget.preferredAction ||
        oldWidget.mode != widget.mode) {
      setState(() {
        _session = _loadFromParams();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = _session;

    if (session == null) {
      return const RevisionPage(
        title: 'Révision IA',
        subtitle: 'Une session contrôlée à partir de tes activités existantes.',
        children: [_EmptyRevisionSessionState()],
      );
    }

    return FutureBuilder<RevisionSessionResponse>(
      future: session,
      builder: (context, snapshot) {
        final response = snapshot.data;

        if (snapshot.connectionState != ConnectionState.done) {
          return const RevisionPage(
            title: 'Révision rapide',
            subtitle: 'Préparation de ta session.',
            children: [Center(child: CircularProgressIndicator())],
          );
        }

        if (snapshot.hasError || response == null) {
          return RevisionPage(
            title: 'Révision IA',
            subtitle:
                'Une session contrôlée à partir de tes activités existantes.',
            children: [_RevisionSessionErrorState(onRetry: _retry)],
          );
        }

        if (_isCompletedCourseQuickSession(response) ||
            _isCompletedCourseQuickAction(response)) {
          return _CompletedCourseQuickSessionRedirect(response: response);
        }

        if (_isCompletedCourseExamSession(response)) {
          return _CompletedCourseExamSessionRedirect(response: response);
        }

        final premiumActivity = _premiumQuickActivity(response);
        if (premiumActivity != null) {
          return QuickRevisionQuizFlow(
            response: response,
            activity: premiumActivity,
            activityController: widget.activityController,
            revisionSessionController: widget.revisionSessionController,
          );
        }

        final examActivity = _examActivity(response);
        if (examActivity != null) {
          return ExamRevisionSessionFlow(
            response: response,
            activity: examActivity,
            revisionSessionController: widget.revisionSessionController,
          );
        }

        return RevisionPage(
          title: 'Révision IA',
          subtitle:
              'Une session contrôlée à partir de tes activités existantes.',
          children: [
            _RevisionSessionContent(
              response: response,
              activityController: widget.activityController,
            ),
          ],
        );
      },
    );
  }

  String? get _trimmedSessionId => _normalizeId(widget.sessionId);
  String? get _trimmedSubjectId => _normalizeId(widget.subjectId);
  String? get _trimmedDocumentId => _normalizeId(widget.documentId);
  String? get _trimmedKnowledgeUnitId => _normalizeId(widget.knowledgeUnitId);

  Future<RevisionSessionResponse>? _loadFromParams() {
    final sessionId = _trimmedSessionId;
    if (sessionId != null) {
      if (_isExamMode) {
        return widget.revisionSessionController.loadExamPreparationSession(
          sessionId: sessionId,
        );
      }
      return widget.revisionSessionController.loadSession(sessionId: sessionId);
    }

    final subjectId = _trimmedSubjectId;
    if (subjectId == null) {
      return null;
    }

    return widget.revisionSessionController.startSession(
      subjectId: subjectId,
      documentId: _trimmedDocumentId,
      knowledgeUnitId: _trimmedKnowledgeUnitId,
      preferredAction: widget.preferredAction,
    );
  }

  String? _normalizeId(String? value) {
    final trimmedValue = value?.trim();
    return trimmedValue == null || trimmedValue.isEmpty ? null : trimmedValue;
  }

  void _retry() {
    setState(() {
      _session = _loadFromParams();
    });
  }

  bool get _isExamMode => widget.mode?.trim().toLowerCase() == 'exam';
}

DiagnosticQuizActivity? _premiumQuickActivity(
  RevisionSessionResponse response,
) {
  final action = response.currentAction;
  final payload = action?.payload;
  if (response.session.status != RevisionSessionStatus.started ||
      response.session.mode != RevisionSessionMode.quick ||
      response.session.courseId == null ||
      action?.kind != RevisionSessionActionKind.diagnosticQuiz ||
      action?.status != RevisionSessionActionStatus.ready ||
      payload is! RevisionSessionDiagnosticQuizPayload) {
    return null;
  }

  if (payload.activity.questions.isEmpty) {
    return null;
  }

  return payload.activity;
}

DiagnosticQuizActivity? _examActivity(RevisionSessionResponse response) {
  final action = response.currentAction;
  final payload = action?.payload;
  if (response.session.status != RevisionSessionStatus.started ||
      response.session.mode != RevisionSessionMode.exam ||
      response.session.courseId == null ||
      action?.kind != RevisionSessionActionKind.diagnosticQuiz ||
      action?.status != RevisionSessionActionStatus.ready ||
      payload is! RevisionSessionDiagnosticQuizPayload) {
    return null;
  }

  if (payload.activity.questions.isEmpty) {
    return null;
  }

  return payload.activity;
}

bool _isCompletedCourseQuickSession(RevisionSessionResponse response) {
  return response.session.status == RevisionSessionStatus.completed &&
      response.session.mode == RevisionSessionMode.quick &&
      response.session.courseId != null;
}

bool _isCompletedCourseExamSession(RevisionSessionResponse response) {
  return response.session.status == RevisionSessionStatus.completed &&
      response.session.mode == RevisionSessionMode.exam &&
      response.session.courseId != null;
}

bool _isCompletedCourseQuickAction(RevisionSessionResponse response) {
  final action = response.currentAction;
  return response.session.mode == RevisionSessionMode.quick &&
      response.session.courseId != null &&
      action?.kind == RevisionSessionActionKind.diagnosticQuiz &&
      action?.status == RevisionSessionActionStatus.completed;
}

class _CompletedCourseExamSessionRedirect extends StatefulWidget {
  const _CompletedCourseExamSessionRedirect({required this.response});

  final RevisionSessionResponse response;

  @override
  State<_CompletedCourseExamSessionRedirect> createState() =>
      _CompletedCourseExamSessionRedirectState();
}

class _CompletedCourseExamSessionRedirectState
    extends State<_CompletedCourseExamSessionRedirect> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
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
    });
  }

  @override
  Widget build(BuildContext context) {
    return const RevisionPage(
      title: 'Préparation examen - QCM terminée',
      subtitle: 'Ouverture du résultat.',
      children: [Center(child: CircularProgressIndicator())],
    );
  }
}

class _CompletedCourseQuickSessionRedirect extends StatefulWidget {
  const _CompletedCourseQuickSessionRedirect({required this.response});

  final RevisionSessionResponse response;

  @override
  State<_CompletedCourseQuickSessionRedirect> createState() =>
      _CompletedCourseQuickSessionRedirectState();
}

class _CompletedCourseQuickSessionRedirectState
    extends State<_CompletedCourseQuickSessionRedirect> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
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
    });
  }

  @override
  Widget build(BuildContext context) {
    return const RevisionPage(
      title: 'Révision terminée',
      subtitle: 'Ouverture du résultat.',
      children: [Center(child: CircularProgressIndicator())],
    );
  }
}

class _EmptyRevisionSessionState extends StatelessWidget {
  const _EmptyRevisionSessionState();

  @override
  Widget build(BuildContext context) {
    return RevisionMessage(
      message: 'Choisis une matière pour lancer une session de révision IA.',
      color: Theme.of(context).colorScheme.secondary,
      icon: Icons.info_outline,
    );
  }
}

class _RevisionSessionErrorState extends StatelessWidget {
  const _RevisionSessionErrorState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RevisionMessage(
          message: 'Impossible de charger la session de révision.',
          color: Theme.of(context).colorScheme.error,
          icon: Icons.error_outline,
        ),
        const SizedBox(height: AppSpacing.m),
        RevisionButton(
          label: 'Réessayer',
          icon: Icons.refresh,
          onPressed: onRetry,
          style: RevisionButtonStyle.ghost,
        ),
      ],
    );
  }
}

class _RevisionSessionContent extends StatelessWidget {
  const _RevisionSessionContent({
    required this.response,
    required this.activityController,
  });

  final RevisionSessionResponse response;
  final ActivityController activityController;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SessionSummaryPanel(session: response.session),
        const SizedBox(height: AppSpacing.l),
        _CurrentActionPanel(action: response.currentAction),
        const SizedBox(height: AppSpacing.l),
        _CurrentActionRenderer(
          action: response.currentAction,
          activityController: activityController,
        ),
        const SizedBox(height: AppSpacing.l),
        _HistoryPanel(actions: response.history),
      ],
    );
  }
}

class _SessionSummaryPanel extends StatelessWidget {
  const _SessionSummaryPanel({required this.session});

  final RevisionSession session;

  @override
  Widget build(BuildContext context) {
    return RevisionPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Session', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.s),
          Wrap(
            spacing: AppSpacing.s,
            runSpacing: AppSpacing.s,
            children: [
              RevisionStatusPill(
                label: _sessionStatusLabel(session.status),
                color: Theme.of(context).colorScheme.primary,
                icon: Icons.play_circle_outline,
              ),
              RevisionStatusPill(
                label: 'Matière liée',
                color: Theme.of(context).colorScheme.secondary,
                icon: Icons.menu_book_outlined,
              ),
              if (session.documentId != null)
                RevisionStatusPill(
                  label: 'Document lié',
                  color: Theme.of(context).colorScheme.secondary,
                  icon: Icons.description_outlined,
                ),
              if (session.knowledgeUnitId != null)
                RevisionStatusPill(
                  label: 'Notion liée',
                  color: Theme.of(context).colorScheme.tertiary,
                  icon: Icons.psychology_outlined,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CurrentActionPanel extends StatelessWidget {
  const _CurrentActionPanel({required this.action});

  final RevisionSessionAction? action;

  @override
  Widget build(BuildContext context) {
    final action = this.action;

    if (action == null) {
      return const RevisionMessage(
        message: 'Aucune action courante dans cette session.',
        color: Colors.teal,
        icon: Icons.info_outline,
      );
    }

    return RevisionPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Action courante',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.s),
          Wrap(
            spacing: AppSpacing.s,
            runSpacing: AppSpacing.s,
            children: [
              RevisionStatusPill(
                label: _actionKindLabel(action.kind),
                color: Theme.of(context).colorScheme.primary,
                icon: _actionKindIcon(action.kind),
              ),
              RevisionStatusPill(
                label: _actionStatusLabel(action.status),
                color: Theme.of(context).colorScheme.secondary,
                icon: Icons.check_circle_outline,
              ),
              RevisionStatusPill(
                label: 'Ordre ${action.displayOrder + 1}',
                color: Theme.of(context).colorScheme.tertiary,
                icon: Icons.format_list_numbered,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CurrentActionRenderer extends StatelessWidget {
  const _CurrentActionRenderer({
    required this.action,
    required this.activityController,
  });

  final RevisionSessionAction? action;
  final ActivityController activityController;

  @override
  Widget build(BuildContext context) {
    final action = this.action;
    final payload = action?.payload;

    if (action == null || payload == null) {
      return const _MinimalPayloadFallback();
    }

    return switch (payload) {
      RevisionSessionDiagnosticQuizPayload(:final activity) => SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.68,
        child: DiagnosticQuizPage(
          activity: activity,
          onSubmit: (answers) {
            return activityController.submitResult(
              sessionId: activity.sessionId,
              answers: answers,
            );
          },
        ),
      ),
      RevisionSessionOpenQuestionPayload(:final activity) => SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.68,
        child: OpenQuestionPage(
          activity: activity,
          onSubmit: (answerText) {
            return activityController.submitOpenAnswer(
              sessionId: activity.sessionId,
              answerText: answerText,
            );
          },
        ),
      ),
      RevisionSessionRichClosedExercisePayload() => _RichClosedLauncher(
        payload: payload,
      ),
      RevisionSessionMinimalPayload(:final type, :final sessionId) =>
        _MinimalPayloadFallback(type: type, sessionId: sessionId),
      RevisionSessionUnknownPayload() => const _UnknownPayloadFallback(),
    };
  }
}

class _RichClosedLauncher extends StatelessWidget {
  const _RichClosedLauncher({required this.payload});

  final RevisionSessionRichClosedExercisePayload payload;

  @override
  Widget build(BuildContext context) {
    return RevisionPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('QCM complet', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.s),
          Text(_contextLabel),
          const SizedBox(height: AppSpacing.s),
          Text(_richClosedReasonLabel(payload.reason)),
          const SizedBox(height: AppSpacing.s),
          RevisionStatusPill(
            label: '${payload.estimatedMinutes} min',
            color: Theme.of(context).colorScheme.tertiary,
            icon: Icons.timer_outlined,
          ),
          const SizedBox(height: AppSpacing.m),
          RevisionButton(
            label: 'Commencer',
            icon: Icons.play_arrow,
            onPressed: () {
              context.go(
                richClosedExerciseRoutePathFor(
                  subjectId: payload.subjectId,
                  documentId: payload.documentId,
                  knowledgeUnitId: payload.knowledgeUnitId,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  String get _contextLabel {
    final title = payload.knowledgeUnitTitle?.trim();
    if (title != null && title.isNotEmpty) {
      return 'Notion : $title';
    }

    return 'Notion à travailler';
  }
}

class _MinimalPayloadFallback extends StatelessWidget {
  const _MinimalPayloadFallback({this.type, this.sessionId});

  final String? type;
  final String? sessionId;

  @override
  Widget build(BuildContext context) {
    return RevisionPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Action à reprendre',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.s),
          const Text(
            "Cette action existe déjà, mais son détail complet n'est pas encore rechargeable.",
          ),
          const SizedBox(height: AppSpacing.s),
          if (type != null) Text('Type: $type'),
          if (sessionId != null) Text("Session d'activité: $sessionId"),
        ],
      ),
    );
  }
}

class _UnknownPayloadFallback extends StatelessWidget {
  const _UnknownPayloadFallback();

  @override
  Widget build(BuildContext context) {
    return const RevisionMessage(
      message: 'Cette action ne peut pas encore être affichée.',
      color: Colors.teal,
      icon: Icons.widgets_outlined,
    );
  }
}

class _HistoryPanel extends StatelessWidget {
  const _HistoryPanel({required this.actions});

  final List<RevisionSessionAction> actions;

  @override
  Widget build(BuildContext context) {
    return RevisionPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Historique', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.s),
          if (actions.isEmpty)
            const Text('Aucune action enregistrée.')
          else
            for (final action in actions)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.s),
                child: Wrap(
                  spacing: AppSpacing.s,
                  runSpacing: AppSpacing.s,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    RevisionStatusPill(
                      label: '#${action.displayOrder + 1}',
                      color: Theme.of(context).colorScheme.tertiary,
                    ),
                    Text(_actionKindLabel(action.kind)),
                    Text(_actionStatusLabel(action.status)),
                  ],
                ),
              ),
        ],
      ),
    );
  }
}

String _sessionStatusLabel(RevisionSessionStatus status) {
  return switch (status) {
    RevisionSessionStatus.started => 'Démarrée',
    RevisionSessionStatus.completed => 'Terminée',
    RevisionSessionStatus.abandoned => 'Abandonnée',
    RevisionSessionStatus.unknown => 'Statut inconnu',
  };
}

String _actionKindLabel(RevisionSessionActionKind kind) {
  return switch (kind) {
    RevisionSessionActionKind.diagnosticQuiz => 'QCM',
    RevisionSessionActionKind.openQuestion => 'Question ouverte',
    RevisionSessionActionKind.richClosedExercise => 'QCM complet',
    RevisionSessionActionKind.unknown => 'Action inconnue',
  };
}

String _richClosedReasonLabel(String reason) {
  return reason
      .replaceAll('Questions riches recommandées.', 'QCM complet recommandé.')
      .replaceAll('Questions riches', 'QCM complet');
}

IconData _actionKindIcon(RevisionSessionActionKind kind) {
  return switch (kind) {
    RevisionSessionActionKind.diagnosticQuiz => Icons.quiz_outlined,
    RevisionSessionActionKind.openQuestion => Icons.rate_review_outlined,
    RevisionSessionActionKind.richClosedExercise => Icons.extension_outlined,
    RevisionSessionActionKind.unknown => Icons.help_outline,
  };
}

String _actionStatusLabel(RevisionSessionActionStatus status) {
  return switch (status) {
    RevisionSessionActionStatus.ready => 'Prête',
    RevisionSessionActionStatus.completed => 'Terminée',
    RevisionSessionActionStatus.failed => 'Échouée',
    RevisionSessionActionStatus.unknown => 'Statut inconnu',
  };
}
