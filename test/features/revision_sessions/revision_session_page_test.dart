import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:Neralune/app/router/app_routes.dart';
import 'package:Neralune/features/activities/application/activity_controller.dart';
import 'package:Neralune/features/activities/domain/diagnostic_quiz_activity.dart';
import 'package:Neralune/features/courses/application/courses_providers.dart';
import 'package:Neralune/features/courses/domain/course_models.dart';
import 'package:Neralune/features/revision_sessions/application/revision_session_controller.dart';
import 'package:Neralune/features/revision_sessions/domain/revision_session.dart';
import 'package:Neralune/presentation/pages/revision_sessions/revision_session_page.dart';
import 'package:Neralune/presentation/widgets/revision_button.dart';

import '../../fakes/in_memory_activity_api.dart';
import '../../fakes/in_memory_courses_repository.dart';
import '../../fakes/in_memory_revision_sessions_api.dart';

void main() {
  testWidgets(
    'start mode starts a revision session and renders open question',
    (tester) async {
      final api = InMemoryRevisionSessionsApi();

      await tester.pumpWidget(
        _Harness(api: api, subjectId: 'subject-1', knowledgeUnitId: 'unit-1'),
      );
      await tester.pumpAndSettle();

      expect(api.startCount, 1);
      expect(api.startedSubjectId, 'subject-1');
      expect(find.text('Révision IA'), findsOneWidget);
      expect(find.text('Question ouverte test'), findsOneWidget);
      expect(find.text('Historique'), findsOneWidget);
    },
  );

  testWidgets('start mode renders diagnostic quiz full payload', (
    tester,
  ) async {
    final api = InMemoryRevisionSessionsApi()
      ..startResponse = diagnosticQuizRevisionSessionResponse();

    await tester.pumpWidget(_Harness(api: api, subjectId: 'subject-1'));
    await tester.pumpAndSettle();

    expect(api.startCount, 1);
    expect(find.text('QCM de session'), findsOneWidget);
    expect(find.text('Question test'), findsOneWidget);
  });

  testWidgets(
    'start mode renders rich closed launcher without exercise content',
    (tester) async {
      final api = InMemoryRevisionSessionsApi()
        ..startResponse = richClosedRevisionSessionResponse();

      await tester.pumpWidget(
        _Harness(api: api, subjectId: 'subject-1', knowledgeUnitId: 'unit-1'),
      );
      await tester.pumpAndSettle();

      expect(api.startCount, 1);
      expect(find.text('QCM complet'), findsWidgets);
      expect(find.text('Notion : Institutions politiques'), findsOneWidget);
      expect(find.text('QCM complet recommandé.'), findsOneWidget);
      expect(find.textContaining('Questions riches'), findsNothing);
      expect(find.text('Commencer'), findsOneWidget);
      expect(find.text('question-1'), findsNothing);
      expect(find.text('correctChoiceId'), findsNothing);
    },
  );

  testWidgets('load mode loads existing session and renders minimal fallback', (
    tester,
  ) async {
    final api = InMemoryRevisionSessionsApi();

    await tester.pumpWidget(
      _Harness(api: api, sessionId: 'revision-session-1'),
    );
    await tester.pumpAndSettle();

    expect(api.loadCount, 1);
    expect(api.loadedSessionId, 'revision-session-1');
    expect(
      find.textContaining("détail complet n'est pas encore rechargeable"),
      findsOneWidget,
    );
    expect(find.textContaining('open-session-1'), findsOneWidget);
  });

  testWidgets('empty state is shown without subject or session id', (
    tester,
  ) async {
    final api = InMemoryRevisionSessionsApi();

    await tester.pumpWidget(_Harness(api: api));
    await tester.pumpAndSettle();

    expect(api.startCount, 0);
    expect(api.loadCount, 0);
    expect(find.textContaining('Choisis une matière'), findsOneWidget);
  });

  testWidgets('error state keeps retry action', (tester) async {
    final api = InMemoryRevisionSessionsApi()..startError = StateError('boom');

    await tester.pumpWidget(_Harness(api: api, subjectId: 'subject-1'));
    await tester.pumpAndSettle();

    expect(
      find.text('Impossible de charger la session de révision.'),
      findsOneWidget,
    );

    api.startError = null;
    await tester.tap(find.widgetWithText(RevisionButton, 'Réessayer'));
    await tester.pumpAndSettle();

    expect(api.startCount, 2);
    expect(find.text('Question ouverte test'), findsOneWidget);
  });

  testWidgets('does not show sensitive correction fields before submit', (
    tester,
  ) async {
    final api = InMemoryRevisionSessionsApi()
      ..startResponse = diagnosticQuizRevisionSessionResponse();

    await tester.pumpWidget(_Harness(api: api, subjectId: 'subject-1'));
    await tester.pumpAndSettle();

    expect(find.text('correctChoiceId'), findsNothing);
    expect(find.text('feedback'), findsNothing);
    expect(find.text('modelAnswer'), findsNothing);
    expect(find.text('score'), findsNothing);
  });

  testWidgets(
    'course quick session renders one question at a time and completes remotely',
    (tester) async {
      final revisionApi = InMemoryRevisionSessionsApi()
        ..loadResponse = courseQuickRevisionSessionResponse();
      final activityApi = InMemoryActivityApi();
      final coursesRepository = InMemoryCoursesRepository()
        ..detailsByCourse['course-1'] = _courseDetail();
      final router = GoRouter(
        initialLocation: AppRoutes.revisionSessionV2(
          sessionId: 'revision-session-1',
        ),
        routes: [
          GoRoute(
            path: AppRoutes.revisionSessionV2Path,
            builder: (context, state) => RevisionSessionPage(
              revisionSessionController: RevisionSessionController(revisionApi),
              activityController: ActivityController(activityApi),
              sessionId: state.pathParameters['sessionId'],
            ),
          ),
          GoRoute(
            path: AppRoutes.revisionSessionResultV2Path,
            builder: (context, state) => const Text('Result route'),
          ),
          GoRoute(
            path: AppRoutes.coursePath,
            builder: (context, state) => const Text('Course route'),
          ),
        ],
      );
      addTearDown(router.dispose);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            coursesRepositoryProvider.overrideWithValue(coursesRepository),
          ],
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Session courte'), findsOneWidget);
      expect(find.text('Question 1 sur 2'), findsOneWidget);
      expect(
        find.text('Quel principe organise les pouvoirs ?'),
        findsOneWidget,
      );
      expect(find.text('Quelle institution vote la loi ?'), findsNothing);
      expect(find.text('quiz-session-1'), findsNothing);
      expect(find.text('correctChoiceId'), findsNothing);

      await tester.tap(find.text('La séparation des pouvoirs'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Suivant'));
      await tester.pumpAndSettle();

      expect(find.text('Question 2 sur 2'), findsOneWidget);
      expect(find.text('Quelle institution vote la loi ?'), findsOneWidget);

      await tester.tap(find.text('Le Parlement'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Terminer'));
      await tester.pumpAndSettle();

      expect(activityApi.submittedDiagnosticQuizCount, 1);
      expect(activityApi.submittedDiagnosticSessionId, 'quiz-session-1');
      expect(activityApi.submittedAnswers, hasLength(2));
      expect(revisionApi.completeCount, 1);
      expect(revisionApi.completedSessionId, 'revision-session-1');
      expect(
        router.routeInformationProvider.value.uri.path,
        '/revision-sessions/revision-session-1/result',
      );
      expect(find.text('Result route'), findsOneWidget);
    },
  );

  testWidgets(
    'exam preparation session loads and submits through exam endpoints',
    (tester) async {
      _useTallSurface(tester);
      final revisionApi = InMemoryRevisionSessionsApi();
      final activityApi = InMemoryActivityApi();
      final router = _quickRouter(
        revisionApi: revisionApi,
        activityApi: activityApi,
        initialLocation: AppRoutes.revisionSessionV2(
          sessionId: 'exam-session-1',
          courseId: 'course-1',
          mode: 'exam',
        ),
      );
      addTearDown(router.dispose);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            coursesRepositoryProvider.overrideWithValue(
              InMemoryCoursesRepository()
                ..detailsByCourse['course-1'] = _courseDetail(),
            ),
          ],
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();

      expect(revisionApi.loadExamCount, 1);
      expect(revisionApi.loadedExamSessionId, 'exam-session-1');
      expect(revisionApi.loadCount, 0);
      expect(find.text('Préparation examen - QCM'), findsWidgets);
      expect(find.text('Préparation examen'), findsNothing);
      expect(find.text('Question 1 sur 1'), findsOneWidget);
      expect(
        find.text('Quel principe organise les pouvoirs ?'),
        findsOneWidget,
      );
      expect(find.text('correctChoiceId'), findsNothing);

      await tester.tap(find.text('La séparation des pouvoirs'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Valider'));
      await tester.pumpAndSettle();

      expect(revisionApi.submitExamCount, 1);
      expect(revisionApi.submittedExamSessionId, 'exam-session-1');
      expect(
        revisionApi.submittedExamAnswers
            ?.map((answer) => '${answer.questionId}:${answer.choiceId}')
            .toList(),
        ['question-1:choice-1'],
      );
      expect(revisionApi.completeCount, 0);
      expect(revisionApi.saveDraftCount, 0);
      expect(activityApi.submittedDiagnosticQuizCount, 0);
      expect(
        router.routeInformationProvider.value.uri.path,
        '/revision-sessions/exam-session-1/result',
      );
      expect(
        router.routeInformationProvider.value.uri.queryParameters['mode'],
        'exam',
      );
      expect(find.text('Result route exam'), findsOneWidget);
    },
  );

  testWidgets('course quick session renders diagnostic question visuals', (
    tester,
  ) async {
    final revisionApi = InMemoryRevisionSessionsApi()
      ..loadResponse = _courseQuickRevisionSessionWithVisuals();
    final coursesRepository = InMemoryCoursesRepository()
      ..detailsByCourse['course-1'] = _courseDetail();
    final router = _quickRouter(
      revisionApi: revisionApi,
      activityApi: InMemoryActivityApi(),
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          coursesRepositoryProvider.overrideWithValue(coursesRepository),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Répartition des pouvoirs'), findsOneWidget);
    expect(find.textContaining('Exécutif'), findsOneWidget);
    expect(find.text('Visuel non pris en charge'), findsOneWidget);
    expect(find.text('correctChoiceId'), findsNothing);
  });

  testWidgets(
    'course quick session flags the current question without submit',
    (tester) async {
      final revisionApi = InMemoryRevisionSessionsApi()
        ..loadResponse = courseQuickRevisionSessionResponse();
      final activityApi = InMemoryActivityApi();
      final router = _quickRouter(
        revisionApi: revisionApi,
        activityApi: activityApi,
      );
      addTearDown(router.dispose);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            coursesRepositoryProvider.overrideWithValue(
              InMemoryCoursesRepository()
                ..detailsByCourse['course-1'] = _courseDetail(),
            ),
          ],
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Signaler'));
      await tester.pumpAndSettle();

      expect(revisionApi.flagCount, 1);
      expect(revisionApi.flaggedSessionId, 'revision-session-1');
      expect(revisionApi.flaggedQuestionId, 'question-1');
      expect(find.text('Question signalée'), findsOneWidget);
      expect(activityApi.submittedDiagnosticQuizCount, 0);
      expect(revisionApi.completeCount, 0);
    },
  );

  testWidgets('completed course quick session redirects to result route', (
    tester,
  ) async {
    final revisionApi = InMemoryRevisionSessionsApi()
      ..loadResponse = _completedCourseQuickRevisionSessionResponse();
    final router = _quickRouter(
      revisionApi: revisionApi,
      activityApi: InMemoryActivityApi(),
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          coursesRepositoryProvider.overrideWithValue(
            InMemoryCoursesRepository()
              ..detailsByCourse['course-1'] = _courseDetail(),
          ),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Result route'), findsOneWidget);
    expect(find.text('Quel principe organise les pouvoirs ?'), findsNothing);
  });

  testWidgets('completed exam preparation session redirects to exam result', (
    tester,
  ) async {
    final revisionApi = InMemoryRevisionSessionsApi()
      ..examLoadResponse = _completedCourseExamRevisionSessionResponse();
    final router = _quickRouter(
      revisionApi: revisionApi,
      activityApi: InMemoryActivityApi(),
      initialLocation: AppRoutes.revisionSessionV2(
        sessionId: 'exam-session-1',
        courseId: 'course-1',
        mode: 'exam',
      ),
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          coursesRepositoryProvider.overrideWithValue(
            InMemoryCoursesRepository()
              ..detailsByCourse['course-1'] = _courseDetail(),
          ),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    expect(revisionApi.loadExamCount, 1);
    expect(find.text('Result route exam'), findsOneWidget);
    expect(find.text('Quel principe organise les pouvoirs ?'), findsNothing);
  });

  testWidgets('completed quick action does not reopen the premium quiz', (
    tester,
  ) async {
    final revisionApi = InMemoryRevisionSessionsApi()
      ..loadResponse = _courseQuickRevisionSessionWithCompletedAction();
    final router = _quickRouter(
      revisionApi: revisionApi,
      activityApi: InMemoryActivityApi(),
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          coursesRepositoryProvider.overrideWithValue(
            InMemoryCoursesRepository()
              ..detailsByCourse['course-1'] = _courseDetail(),
          ),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Quel principe organise les pouvoirs ?'), findsNothing);
    expect(find.text('Result route'), findsOneWidget);
  });

  testWidgets('multiple choice respects min and max selections', (
    tester,
  ) async {
    _useTallSurface(tester);
    final revisionApi = InMemoryRevisionSessionsApi()
      ..loadResponse = _multipleChoiceQuickRevisionSession();
    final activityApi = InMemoryActivityApi();
    final router = _quickRouter(
      revisionApi: revisionApi,
      activityApi: activityApi,
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          coursesRepositoryProvider.overrideWithValue(
            InMemoryCoursesRepository()
              ..detailsByCourse['course-1'] = _courseDetail(),
          ),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Contrôle parlementaire'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Terminer', skipOffstage: false));
    await tester.tap(find.text('Terminer'), warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(activityApi.submittedDiagnosticQuizCount, 0);

    await tester.tap(find.text('Responsabilité du gouvernement'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Dissolution'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Motion de censure'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Terminer', skipOffstage: false));
    await tester.tap(find.text('Terminer'));
    await tester.pumpAndSettle();

    expect(activityApi.submittedDiagnosticQuizCount, 1);
    expect(activityApi.submittedAnswers, hasLength(1));
    expect(activityApi.submittedAnswers!.single.choiceIds, [
      'choice-a',
      'choice-b',
      'choice-c',
    ]);
    expect(revisionApi.completeCount, 1);
  });

  testWidgets('previous and next keep selected answers before submit', (
    tester,
  ) async {
    final revisionApi = InMemoryRevisionSessionsApi()
      ..loadResponse = courseQuickRevisionSessionResponse();
    final activityApi = InMemoryActivityApi();
    final router = _quickRouter(
      revisionApi: revisionApi,
      activityApi: activityApi,
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          coursesRepositoryProvider.overrideWithValue(
            InMemoryCoursesRepository()
              ..detailsByCourse['course-1'] = _courseDetail(),
          ),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('La séparation des pouvoirs'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Suivant'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Le Parlement'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Précédent'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Suivant'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Terminer'));
    await tester.pumpAndSettle();

    expect(
      activityApi.submittedAnswers
          ?.map((answer) => '${answer.questionId}:${answer.choiceId}')
          .toList(),
      ['question-1:choice-1', 'question-2:choice-3'],
    );
  });

  testWidgets('course quick session restores draft answers on load', (
    tester,
  ) async {
    final revisionApi = InMemoryRevisionSessionsApi()
      ..loadResponse = _courseQuickRevisionSessionWithDraft();
    final activityApi = InMemoryActivityApi();
    final router = _quickRouter(
      revisionApi: revisionApi,
      activityApi: activityApi,
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          coursesRepositoryProvider.overrideWithValue(
            InMemoryCoursesRepository()
              ..detailsByCourse['course-1'] = _courseDetail(),
          ),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Suivant'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Le Parlement'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Terminer'));
    await tester.pumpAndSettle();

    expect(activityApi.submittedAnswers, hasLength(2));
    expect(
      activityApi.submittedAnswers
          ?.map((answer) => '${answer.questionId}:${answer.choiceId}')
          .toList(),
      ['question-1:choice-1', 'question-2:choice-3'],
    );
  });

  testWidgets('course quick session saves a draft answer on selection', (
    tester,
  ) async {
    final revisionApi = InMemoryRevisionSessionsApi()
      ..loadResponse = courseQuickRevisionSessionResponse();
    final router = _quickRouter(
      revisionApi: revisionApi,
      activityApi: InMemoryActivityApi(),
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          coursesRepositoryProvider.overrideWithValue(
            InMemoryCoursesRepository()
              ..detailsByCourse['course-1'] = _courseDetail(),
          ),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('La séparation des pouvoirs'));
    await tester.pumpAndSettle();

    expect(revisionApi.saveDraftCount, 1);
    expect(revisionApi.savedDraftSessionId, 'revision-session-1');
    expect(revisionApi.savedDraftQuestionId, 'question-1');
    expect(revisionApi.savedDraftChoiceIds, ['choice-1']);
  });

  testWidgets(
    'retry completion does not submit the diagnostic activity twice',
    (tester) async {
      _useTallSurface(tester);
      final revisionApi = InMemoryRevisionSessionsApi()
        ..loadResponse = courseQuickRevisionSessionResponse()
        ..completeError = StateError('complete failed');
      final activityApi = InMemoryActivityApi();
      final router = _quickRouter(
        revisionApi: revisionApi,
        activityApi: activityApi,
      );
      addTearDown(router.dispose);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            coursesRepositoryProvider.overrideWithValue(
              InMemoryCoursesRepository()
                ..detailsByCourse['course-1'] = _courseDetail(),
            ),
          ],
          child: MaterialApp.router(routerConfig: router),
        ),
      );
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
      expect(revisionApi.completeCount, 1);
      expect(find.text('Finaliser la session'), findsOneWidget);

      revisionApi.completeError = null;
      await tester.ensureVisible(
        find.text('Finaliser la session', skipOffstage: false),
      );
      await tester.tap(find.text('Finaliser la session'));
      await tester.pumpAndSettle();

      expect(activityApi.submittedDiagnosticQuizCount, 1);
      expect(revisionApi.completeCount, 2);
      expect(find.text('Result route'), findsOneWidget);
    },
  );

  testWidgets('back button asks for confirmation before abandoning the quiz', (
    tester,
  ) async {
    final revisionApi = InMemoryRevisionSessionsApi()
      ..loadResponse = courseQuickRevisionSessionResponse();
    final activityApi = InMemoryActivityApi();
    final router = _quickRouter(
      revisionApi: revisionApi,
      activityApi: activityApi,
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          coursesRepositoryProvider.overrideWithValue(
            InMemoryCoursesRepository()
              ..detailsByCourse['course-1'] = _courseDetail(),
          ),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.arrow_back_rounded).first);
    await tester.pumpAndSettle();

    expect(find.text('Quitter la session ?'), findsOneWidget);

    await tester.tap(find.widgetWithText(TextButton, 'Continuer'));
    await tester.pumpAndSettle();

    expect(find.text('Quel principe organise les pouvoirs ?'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_back_rounded).first);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Quitter'));
    await tester.pumpAndSettle();

    expect(find.text('Course route'), findsOneWidget);
    expect(activityApi.submittedDiagnosticQuizCount, 0);
    expect(revisionApi.completeCount, 0);
  });
}

class _Harness extends StatelessWidget {
  const _Harness({
    required this.api,
    this.sessionId,
    this.subjectId,
    this.knowledgeUnitId,
  });

  final InMemoryRevisionSessionsApi api;
  final String? sessionId;
  final String? subjectId;
  final String? knowledgeUnitId;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: RevisionSessionPage(
        revisionSessionController: RevisionSessionController(api),
        activityController: ActivityController(InMemoryActivityApi()),
        sessionId: sessionId,
        subjectId: subjectId,
        knowledgeUnitId: knowledgeUnitId,
      ),
    );
  }
}

void _useTallSurface(WidgetTester tester) {
  tester.view.physicalSize = const Size(900, 1200);
  tester.view.devicePixelRatio = 1;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
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

GoRouter _quickRouter({
  required InMemoryRevisionSessionsApi revisionApi,
  required InMemoryActivityApi activityApi,
  String? initialLocation,
}) {
  return GoRouter(
    initialLocation:
        initialLocation ??
        AppRoutes.revisionSessionV2(sessionId: 'revision-session-1'),
    routes: [
      GoRoute(
        path: AppRoutes.revisionSessionV2Path,
        builder: (context, state) => RevisionSessionPage(
          revisionSessionController: RevisionSessionController(revisionApi),
          activityController: ActivityController(activityApi),
          sessionId: state.pathParameters['sessionId'],
          mode: state.uri.queryParameters['mode'],
        ),
      ),
      GoRoute(
        path: AppRoutes.revisionSessionResultV2Path,
        builder: (context, state) => Text(
          state.uri.queryParameters['mode'] == 'exam'
              ? 'Result route exam'
              : 'Result route',
        ),
      ),
      GoRoute(
        path: AppRoutes.coursePath,
        builder: (context, state) => const Text('Course route'),
      ),
    ],
  );
}

RevisionSessionResponse _courseQuickRevisionSessionWithVisuals() {
  final base = courseQuickRevisionSessionResponse();
  return RevisionSessionResponse(
    session: base.session,
    currentAction: const RevisionSessionAction(
      id: 'action-quiz-1',
      kind: RevisionSessionActionKind.diagnosticQuiz,
      status: RevisionSessionActionStatus.ready,
      displayOrder: 0,
      activitySessionId: 'quiz-session-1',
      documentId: 'document-1',
      knowledgeUnitId: 'unit-1',
      payload: RevisionSessionDiagnosticQuizPayload(
        DiagnosticQuizActivity(
          sessionId: 'quiz-session-1',
          title: 'Révision rapide réelle',
          subjectId: 'subject-1',
          documentId: 'document-1',
          questions: [
            DiagnosticQuizQuestion(
              id: 'question-1',
              prompt: 'Quel principe organise les pouvoirs ?',
              knowledgeUnitId: 'unit-1',
              visuals: [
                DiagnosticQuizChartVisual(
                  id: 'visual-1',
                  displayOrder: 0,
                  chartType: DiagnosticQuizChartType.bar,
                  title: 'Répartition des pouvoirs',
                  description: 'Lecture synthétique du cours.',
                  xKey: 'branche',
                  yKeys: ['poids'],
                  data: [
                    {'branche': 'Exécutif', 'poids': 2},
                    {'branche': 'Législatif', 'poids': 3},
                  ],
                ),
                DiagnosticQuizUnsupportedVisual(
                  id: 'visual-2',
                  displayOrder: 1,
                  type: 'MAP',
                ),
              ],
              choices: [
                DiagnosticQuizChoice(
                  id: 'choice-1',
                  label: 'La séparation des pouvoirs',
                ),
                DiagnosticQuizChoice(
                  id: 'choice-2',
                  label: 'La confusion des pouvoirs',
                ),
              ],
            ),
          ],
        ),
      ),
    ),
    history: base.history,
  );
}

RevisionSessionResponse _completedCourseQuickRevisionSessionResponse() {
  final base = courseQuickRevisionSessionResponse();
  return RevisionSessionResponse(
    session: RevisionSession(
      id: base.session.id,
      status: RevisionSessionStatus.completed,
      mode: RevisionSessionMode.quick,
      subjectId: base.session.subjectId,
      courseId: base.session.courseId,
      documentId: base.session.documentId,
      knowledgeUnitId: base.session.knowledgeUnitId,
      createdAt: base.session.createdAt,
      completedAt: DateTime.parse('2026-06-15T12:04:12.000Z'),
    ),
    currentAction: base.currentAction,
    history: base.history,
  );
}

RevisionSessionResponse _completedCourseExamRevisionSessionResponse() {
  final base = examRevisionSessionResponse();
  return RevisionSessionResponse(
    session: RevisionSession(
      id: base.session.id,
      status: RevisionSessionStatus.completed,
      mode: RevisionSessionMode.exam,
      subjectId: base.session.subjectId,
      courseId: base.session.courseId,
      documentId: base.session.documentId,
      knowledgeUnitId: base.session.knowledgeUnitId,
      createdAt: base.session.createdAt,
      completedAt: DateTime.parse('2026-06-15T12:05:00.000Z'),
    ),
    currentAction: base.currentAction,
    history: base.history,
  );
}

RevisionSessionResponse _courseQuickRevisionSessionWithCompletedAction() {
  final base = courseQuickRevisionSessionResponse();
  return RevisionSessionResponse(
    session: base.session,
    currentAction: RevisionSessionAction(
      id: base.currentAction!.id,
      kind: base.currentAction!.kind,
      status: RevisionSessionActionStatus.completed,
      displayOrder: base.currentAction!.displayOrder,
      activitySessionId: base.currentAction!.activitySessionId,
      documentId: base.currentAction!.documentId,
      knowledgeUnitId: base.currentAction!.knowledgeUnitId,
      payload: base.currentAction!.payload,
    ),
    history: base.history,
  );
}

RevisionSessionResponse _courseQuickRevisionSessionWithDraft() {
  final base = courseQuickRevisionSessionResponse();
  return RevisionSessionResponse(
    session: base.session,
    currentAction: base.currentAction,
    history: base.history,
    draftAnswers: [
      RevisionSessionDraftAnswer(
        questionId: 'question-1',
        selectedChoiceIds: ['choice-1'],
        updatedAt: DateTime.parse('2026-06-15T12:01:00.000Z'),
      ),
    ],
  );
}

RevisionSessionResponse _multipleChoiceQuickRevisionSession() {
  final base = courseQuickRevisionSessionResponse();
  return RevisionSessionResponse(
    session: base.session,
    currentAction: const RevisionSessionAction(
      id: 'action-quiz-1',
      kind: RevisionSessionActionKind.diagnosticQuiz,
      status: RevisionSessionActionStatus.ready,
      displayOrder: 0,
      activitySessionId: 'quiz-session-1',
      documentId: 'document-1',
      knowledgeUnitId: 'unit-1',
      payload: RevisionSessionDiagnosticQuizPayload(
        DiagnosticQuizActivity(
          sessionId: 'quiz-session-1',
          title: 'Révision rapide réelle',
          subjectId: 'subject-1',
          documentId: 'document-1',
          questions: [
            DiagnosticQuizQuestion(
              id: 'question-multiple',
              prompt: 'Quels mécanismes relèvent du contrôle parlementaire ?',
              knowledgeUnitId: 'unit-1',
              selectionMode: DiagnosticQuizSelectionMode.multiple,
              minSelections: 2,
              maxSelections: 3,
              choices: [
                DiagnosticQuizChoice(
                  id: 'choice-a',
                  label: 'Contrôle parlementaire',
                ),
                DiagnosticQuizChoice(
                  id: 'choice-b',
                  label: 'Responsabilité du gouvernement',
                ),
                DiagnosticQuizChoice(id: 'choice-c', label: 'Dissolution'),
                DiagnosticQuizChoice(
                  id: 'choice-d',
                  label: 'Motion de censure',
                ),
              ],
            ),
          ],
        ),
      ),
    ),
    history: base.history,
  );
}
