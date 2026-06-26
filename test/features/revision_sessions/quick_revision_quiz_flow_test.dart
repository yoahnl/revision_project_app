import 'package:Neralune/app/router/app_routes.dart';
import 'package:Neralune/features/activities/application/activity_controller.dart';
import 'package:Neralune/features/activities/domain/diagnostic_quiz_activity.dart';
import 'package:Neralune/features/courses/application/courses_providers.dart';
import 'package:Neralune/features/courses/domain/course_models.dart';
import 'package:Neralune/features/revision_sessions/application/revision_session_controller.dart';
import 'package:Neralune/features/revision_sessions/domain/revision_session.dart';
import 'package:Neralune/features/revision_sessions/presentation/quick_revision_quiz_flow.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../fakes/in_memory_activity_api.dart';
import '../../fakes/in_memory_courses_repository.dart';
import '../../fakes/in_memory_revision_sessions_api.dart';

void main() {
  testWidgets('renders an immersive one-question-at-a-time quick flow', (
    tester,
  ) async {
    final response = courseQuickRevisionSessionResponse();
    final harness = _QuickFlowHarness(response: response);
    addTearDown(harness.dispose);

    await tester.pumpWidget(harness.widget());
    await tester.pumpAndSettle();

    expect(find.text('Session courte'), findsOneWidget);
    expect(find.text('Question 1 sur 2'), findsOneWidget);
    expect(find.text('Quel principe organise les pouvoirs ?'), findsOneWidget);
    expect(find.text('Quelle institution vote la loi ?'), findsNothing);
    expect(find.text('Suivant'), findsOneWidget);
    expect(find.text('Terminer'), findsNothing);
    expect(find.text('Aujourd’hui'), findsNothing);
    expect(find.text('Cours'), findsNothing);
    expect(find.text('Progrès'), findsNothing);
    _expectForbiddenTermsAbsent();

    await tester.tap(find.text('La séparation des pouvoirs'));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);

    await tester.tap(find.text('Suivant'));
    await tester.pumpAndSettle();

    expect(find.text('Question 2 sur 2'), findsOneWidget);
    expect(find.text('Quel principe organise les pouvoirs ?'), findsNothing);
    expect(find.text('Quelle institution vote la loi ?'), findsOneWidget);
    expect(find.text('Terminer'), findsOneWidget);
  });

  testWidgets('submits the quick activity then routes to the existing result', (
    tester,
  ) async {
    final response = courseQuickRevisionSessionResponse();
    final revisionApi = InMemoryRevisionSessionsApi();
    final activityApi = InMemoryActivityApi();
    final harness = _QuickFlowHarness(
      response: response,
      revisionApi: revisionApi,
      activityApi: activityApi,
    );
    addTearDown(harness.dispose);

    await tester.pumpWidget(harness.widget());
    await tester.pumpAndSettle();

    await tester.tap(find.text('La séparation des pouvoirs'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Suivant'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Le Parlement'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Terminer'));
    await tester.pumpAndSettle();

    expect(activityApi.submittedDiagnosticQuizCount, 1);
    expect(activityApi.submittedDiagnosticSessionId, 'quiz-session-1');
    expect(
      activityApi.submittedAnswers
          ?.map((answer) => '${answer.questionId}:${answer.choiceId}')
          .toList(),
      ['question-1:choice-1', 'question-2:choice-3'],
    );
    expect(revisionApi.completeCount, 1);
    expect(revisionApi.completedSessionId, 'revision-session-1');
    expect(
      harness.router.routeInformationProvider.value.uri.path,
      '/revision-sessions/revision-session-1/result',
    );
    expect(find.text('Résultat de session'), findsOneWidget);
  });

  testWidgets('keeps selected answers visible when submission fails', (
    tester,
  ) async {
    final response = courseQuickRevisionSessionResponse();
    final revisionApi = InMemoryRevisionSessionsApi();
    final activityApi = InMemoryActivityApi()
      ..submitDiagnosticQuizError = StateError('submission failed');
    final harness = _QuickFlowHarness(
      response: response,
      revisionApi: revisionApi,
      activityApi: activityApi,
    );
    addTearDown(harness.dispose);

    await tester.pumpWidget(harness.widget());
    await tester.pumpAndSettle();

    await tester.tap(find.text('La séparation des pouvoirs'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Suivant'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Le Parlement'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Terminer'));
    await tester.pumpAndSettle();

    expect(find.text('Impossible de soumettre la session.'), findsOneWidget);
    expect(find.text('Tes réponses restent sur cet écran.'), findsOneWidget);
    expect(find.text('Quelle institution vote la loi ?'), findsOneWidget);
    expect(find.text('Le Parlement'), findsOneWidget);
    expect(find.text('Résultat de session'), findsNothing);
    expect(revisionApi.completeCount, 0);
  });

  testWidgets('saves drafts and asks for confirmation before leaving', (
    tester,
  ) async {
    final response = courseQuickRevisionSessionResponse();
    final revisionApi = InMemoryRevisionSessionsApi();
    final activityApi = InMemoryActivityApi();
    final harness = _QuickFlowHarness(
      response: response,
      revisionApi: revisionApi,
      activityApi: activityApi,
    );
    addTearDown(harness.dispose);

    await tester.pumpWidget(harness.widget());
    await tester.pumpAndSettle();

    await tester.tap(find.text('La séparation des pouvoirs'));
    await tester.pumpAndSettle();

    expect(revisionApi.saveDraftCount, 1);
    expect(revisionApi.savedDraftQuestionId, 'question-1');
    expect(revisionApi.savedDraftChoiceIds, ['choice-1']);

    await tester.tap(find.byIcon(Icons.arrow_back_rounded).first);
    await tester.pumpAndSettle();

    expect(find.text('Quitter la session ?'), findsOneWidget);
    expect(
      find.text('Tu pourras reprendre cette session plus tard.'),
      findsOneWidget,
    );

    await tester.tap(find.widgetWithText(TextButton, 'Continuer'));
    await tester.pumpAndSettle();

    expect(find.text('Quel principe organise les pouvoirs ?'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_back_rounded).first);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Quitter'));
    await tester.pumpAndSettle();

    expect(find.text('Détail cours'), findsOneWidget);
    expect(activityApi.submittedDiagnosticQuizCount, 0);
    expect(revisionApi.completeCount, 0);
  });

  testWidgets('supports multiple-choice bounds without changing engine', (
    tester,
  ) async {
    final activity = _multipleChoiceActivity();
    final response = _responseForActivity(activity);
    final activityApi = InMemoryActivityApi();
    final harness = _QuickFlowHarness(
      response: response,
      activityApi: activityApi,
    );
    addTearDown(harness.dispose);

    await tester.pumpWidget(harness.widget());
    await tester.pumpAndSettle();

    expect(find.text('2 à 2 réponses'), findsOneWidget);

    await tester.tap(find.text('Contrôle parlementaire'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Terminer'));
    await tester.pumpAndSettle();

    expect(activityApi.submittedDiagnosticQuizCount, 0);

    await tester.tap(find.text('Responsabilité du gouvernement'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Terminer'));
    await tester.pumpAndSettle();

    expect(activityApi.submittedDiagnosticQuizCount, 1);
    expect(activityApi.submittedAnswers, hasLength(1));
    expect(activityApi.submittedAnswers!.single.choiceIds, [
      'choice-a',
      'choice-b',
    ]);
  });
}

class _QuickFlowHarness {
  _QuickFlowHarness({
    required this.response,
    InMemoryRevisionSessionsApi? revisionApi,
    InMemoryActivityApi? activityApi,
  }) : revisionApi = revisionApi ?? InMemoryRevisionSessionsApi(),
       activityApi = activityApi ?? InMemoryActivityApi(),
       coursesRepository = InMemoryCoursesRepository() {
    coursesRepository.detailsByCourse['course-1'] = _courseDetail();
    router = GoRouter(
      initialLocation: '/quick-session',
      routes: [
        GoRoute(
          path: '/quick-session',
          builder: (context, state) => QuickRevisionQuizFlow(
            response: response,
            activity: _activityFrom(response),
            activityController: ActivityController(this.activityApi),
            revisionSessionController: RevisionSessionController(
              this.revisionApi,
            ),
          ),
        ),
        GoRoute(
          path: AppRoutes.revisionSessionResultV2Path,
          builder: (context, state) => const Text('Résultat de session'),
        ),
        GoRoute(
          path: AppRoutes.coursePath,
          builder: (context, state) => const Text('Détail cours'),
        ),
      ],
    );
  }

  final RevisionSessionResponse response;
  final InMemoryRevisionSessionsApi revisionApi;
  final InMemoryActivityApi activityApi;
  final InMemoryCoursesRepository coursesRepository;
  late final GoRouter router;

  Widget widget() {
    return ProviderScope(
      overrides: [
        coursesRepositoryProvider.overrideWithValue(coursesRepository),
      ],
      child: MaterialApp.router(routerConfig: router),
    );
  }

  void dispose() {
    router.dispose();
  }
}

DiagnosticQuizActivity _activityFrom(RevisionSessionResponse response) {
  return (response.currentAction!.payload
          as RevisionSessionDiagnosticQuizPayload)
      .activity;
}

RevisionSessionResponse _responseForActivity(DiagnosticQuizActivity activity) {
  return RevisionSessionResponse(
    session: RevisionSession(
      id: 'revision-session-1',
      status: RevisionSessionStatus.started,
      mode: RevisionSessionMode.quick,
      subjectId: 'subject-1',
      courseId: 'course-1',
      documentId: 'document-1',
      knowledgeUnitId: 'unit-1',
      createdAt: DateTime.parse('2026-06-26T10:00:00.000Z'),
      completedAt: null,
    ),
    currentAction: RevisionSessionAction(
      id: 'action-quiz-1',
      kind: RevisionSessionActionKind.diagnosticQuiz,
      status: RevisionSessionActionStatus.ready,
      displayOrder: 0,
      activitySessionId: activity.sessionId,
      documentId: 'document-1',
      knowledgeUnitId: 'unit-1',
      payload: RevisionSessionDiagnosticQuizPayload(activity),
    ),
    history: const [],
  );
}

DiagnosticQuizActivity _multipleChoiceActivity() {
  return const DiagnosticQuizActivity(
    sessionId: 'quiz-session-1',
    title: 'Session courte',
    subjectId: 'subject-1',
    documentId: 'document-1',
    questions: [
      DiagnosticQuizQuestion(
        id: 'question-1',
        prompt: 'Quels mécanismes engagent la responsabilité politique ?',
        knowledgeUnitId: 'unit-1',
        selectionMode: DiagnosticQuizSelectionMode.multiple,
        minSelections: 2,
        maxSelections: 2,
        choices: [
          DiagnosticQuizChoice(id: 'choice-a', label: 'Contrôle parlementaire'),
          DiagnosticQuizChoice(
            id: 'choice-b',
            label: 'Responsabilité du gouvernement',
          ),
          DiagnosticQuizChoice(id: 'choice-c', label: 'Dissolution'),
        ],
      ),
    ],
  );
}

CourseDetail _courseDetail() {
  const course = CourseListItem(
    id: 'course-1',
    subjectId: 'subject-1',
    title: 'Droit constitutionnel',
    sourceCount: 1,
    readySourceCount: 1,
  );

  return const CourseDetail(
    course: course,
    subject: CourseSubjectSummary(id: 'subject-1', name: 'Droits'),
    sources: [
      CourseDocument(
        id: 'document-1',
        courseId: 'course-1',
        documentId: 'document-1',
        fileName: 'source.pdf',
        status: CourseDocumentStatus.ready,
      ),
    ],
  );
}

void _expectForbiddenTermsAbsent() {
  const forbiddenTerms = [
    'MVP',
    'backend',
    'legacy',
    'fixture',
    'payload',
    'ActivitySession',
    'QuestionBank',
    'questionCount',
    'diagnostic_quiz',
    'open_question',
    'rich_closed_exercise',
    'QCM complet',
    'Question ouverte',
    'Mode examen',
    'GenUI',
    'Prisma',
  ];

  for (final term in forbiddenTerms) {
    expect(find.textContaining(term), findsNothing, reason: term);
  }
}
