import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:revision_app/features/activities/application/activity_controller.dart';
import 'package:revision_app/features/revision_sessions/application/revision_session_controller.dart';
import 'package:revision_app/features/revision_sessions/data/revision_sessions_api.dart';
import 'package:revision_app/features/revision_sessions/domain/revision_session.dart';
import 'package:revision_app/core/routing/route_paths.dart';
import 'package:revision_app/presentation/pages/activities/diagnostic_quiz_page.dart';
import 'package:revision_app/presentation/pages/activities/open_question_page.dart';
import 'package:revision_app/presentation/theme/app_spacing.dart';
import 'package:revision_app/presentation/widgets/revision_button.dart';
import 'package:revision_app/presentation/widgets/revision_message.dart';
import 'package:revision_app/presentation/widgets/revision_page.dart';
import 'package:revision_app/presentation/widgets/revision_panel.dart';
import 'package:revision_app/presentation/widgets/revision_status_pill.dart';

class RevisionSessionPage extends StatefulWidget {
  const RevisionSessionPage({
    required this.revisionSessionController,
    required this.activityController,
    this.sessionId,
    this.subjectId,
    this.documentId,
    this.knowledgeUnitId,
    this.preferredAction,
    super.key,
  });

  final RevisionSessionController revisionSessionController;
  final ActivityController activityController;
  final String? sessionId;
  final String? subjectId;
  final String? documentId;
  final String? knowledgeUnitId;
  final RevisionSessionPreferredAction? preferredAction;

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
        oldWidget.preferredAction != widget.preferredAction) {
      setState(() {
        _session = _loadFromParams();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = _session;

    return RevisionPage(
      title: 'Révision IA',
      subtitle: 'Une session contrôlée à partir de tes activités existantes.',
      children: [
        if (session == null)
          const _EmptyRevisionSessionState()
        else
          FutureBuilder<RevisionSessionResponse>(
            future: session,
            builder: (context, snapshot) {
              final response = snapshot.data;

              if (snapshot.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError || response == null) {
                return _RevisionSessionErrorState(onRetry: _retry);
              }

              return _RevisionSessionContent(
                response: response,
                activityController: widget.activityController,
              );
            },
          ),
      ],
    );
  }

  String? get _trimmedSessionId => _normalizeId(widget.sessionId);
  String? get _trimmedSubjectId => _normalizeId(widget.subjectId);
  String? get _trimmedDocumentId => _normalizeId(widget.documentId);
  String? get _trimmedKnowledgeUnitId => _normalizeId(widget.knowledgeUnitId);

  Future<RevisionSessionResponse>? _loadFromParams() {
    final sessionId = _trimmedSessionId;
    if (sessionId != null) {
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
                label: 'Matière ${session.subjectId}',
                color: Theme.of(context).colorScheme.secondary,
                icon: Icons.menu_book_outlined,
              ),
              if (session.documentId != null)
                RevisionStatusPill(
                  label: 'Document ${session.documentId}',
                  color: Theme.of(context).colorScheme.secondary,
                  icon: Icons.description_outlined,
                ),
              if (session.knowledgeUnitId != null)
                RevisionStatusPill(
                  label: 'Notion ${session.knowledgeUnitId}',
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
          Text(
            'Questions riches',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.s),
          Text(_contextLabel),
          const SizedBox(height: AppSpacing.s),
          Text(payload.reason),
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
      return 'Notion: $title';
    }

    return 'Notion ${payload.knowledgeUnitId}';
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
    RevisionSessionActionKind.richClosedExercise => 'Questions riches',
    RevisionSessionActionKind.unknown => 'Action inconnue',
  };
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
