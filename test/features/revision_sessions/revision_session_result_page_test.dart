import 'package:Neralune/app/router/app_routes.dart';
import 'package:Neralune/features/revision_sessions/application/revision_session_controller.dart';
import 'package:Neralune/features/revision_sessions/data/revision_sessions_api.dart';
import 'package:Neralune/features/revision_sessions/domain/revision_session.dart';
import 'package:Neralune/presentation/design_system/components/revision_mvp_components.dart';
import 'package:Neralune/presentation/pages/revision_sessions/revision_session_result_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../fakes/in_memory_revision_sessions_api.dart';

void main() {
  testWidgets('displays a pedagogical quick result without static demo score', (
    tester,
  ) async {
    final api = InMemoryRevisionSessionsApi();

    await tester.pumpWidget(_Harness(api: api));
    await tester.pumpAndSettle();

    expect(api.loadResultCount, 1);
    expect(api.loadedResultSessionId, 'revision-session-1');
    expect(find.text('Session terminée'), findsOneWidget);
    expect(find.byKey(const ValueKey('result-luna-static')), findsOneWidget);
    expect(find.text('67%'), findsWidgets);
    expect(find.text('4 / 6 bonnes réponses'), findsOneWidget);
    expect(find.text('Bonne progression.'), findsOneWidget);
    expect(find.text('À retravailler'), findsOneWidget);
    expect(find.text('Séparation des pouvoirs'), findsOneWidget);
    expect(find.text('Corrections utiles'), findsOneWidget);
    expect(find.text('Ce que tu as loupé'), findsNothing);
    expect(find.text('Quelle institution vote la loi ?'), findsOneWidget);
    expect(find.textContaining('Ta réponse'), findsOneWidget);
    expect(find.textContaining('Bonne réponse'), findsOneWidget);
    expect(find.text('À retenir'), findsOneWidget);
    expect(find.textContaining('Le préfet'), findsOneWidget);
    expect(find.textContaining('Le Parlement'), findsWidgets);
    expect(find.textContaining('Le Parlement vote la loi'), findsOneWidget);
    expect(find.text('Voir la fiche'), findsOneWidget);
    expect(find.text('Retour au cours'), findsOneWidget);
    expect(find.byType(RevisionConfettiOverlay), findsNothing);
    expect(find.text('78%'), findsNothing);
    expect(find.text('4/5 bonnes'), findsNothing);
    _expectForbiddenTermsAbsent();
  });

  testWidgets('shows confetti only for excellent results', (tester) async {
    final api = InMemoryRevisionSessionsApi()
      ..resultResponse = highButNotExcellentRevisionSessionResult();

    await tester.pumpWidget(_Harness(api: api));
    await tester.pumpAndSettle();

    expect(find.text('83%'), findsWidgets);
    expect(find.byType(RevisionConfettiOverlay), findsNothing);

    api.resultResponse = excellentRevisionSessionResult();
    await tester.pumpWidget(_Harness(api: api, sessionId: 'session-perfect'));
    await tester.pumpAndSettle();

    expect(find.text('100%'), findsWidgets);
    expect(find.byType(RevisionConfettiOverlay), findsOneWidget);
  });

  testWidgets('loads exam preparation result with non-technical header', (
    tester,
  ) async {
    final api = InMemoryRevisionSessionsApi();

    await tester.pumpWidget(
      _Harness(api: api, sessionId: 'exam-session-1', mode: 'exam'),
    );
    await tester.pumpAndSettle();

    expect(api.loadExamResultCount, 1);
    expect(api.loadedExamResultSessionId, 'exam-session-1');
    expect(api.loadResultCount, 0);
    expect(find.text('Préparation examen terminée'), findsOneWidget);
    expect(find.text('Préparation examen - QCM terminée'), findsNothing);
    expect(find.text('Examen terminé'), findsNothing);
    expect(find.text('100%'), findsWidgets);
    expect(find.text('1 / 1 bonnes réponses'), findsOneWidget);
    expect(find.text('Notions consolidées'), findsOneWidget);
    expect(find.text('Séparation des pouvoirs'), findsOneWidget);
  });

  testWidgets('does not invent explanations when correction has none', (
    tester,
  ) async {
    final api = InMemoryRevisionSessionsApi()
      ..resultResponse = resultWithoutExplanation();

    await tester.pumpWidget(_Harness(api: api));
    await tester.pumpAndSettle();

    expect(find.text('Corrections utiles'), findsOneWidget);
    expect(find.text('À retenir'), findsNothing);
    expect(find.textContaining('Bonne réponse'), findsOneWidget);
  });

  testWidgets('does not invent knowledge unit summaries when absent', (
    tester,
  ) async {
    final api = InMemoryRevisionSessionsApi()
      ..resultResponse = resultWithoutKnowledgeUnits();

    await tester.pumpWidget(_Harness(api: api));
    await tester.pumpAndSettle();

    expect(find.text('Session terminée'), findsOneWidget);
    expect(find.text('4 / 6 bonnes réponses'), findsOneWidget);
    expect(find.text('notion consolidée'), findsNothing);
    expect(find.text('notion à retravailler'), findsNothing);
    expect(find.text('Notions consolidées'), findsNothing);
    expect(find.text('À retravailler'), findsNothing);
    expect(find.text('Corrections utiles'), findsOneWidget);
  });

  testWidgets('shows fallback next action without course id', (tester) async {
    final api = InMemoryRevisionSessionsApi()
      ..resultResponse = resultWithoutCourse();

    await tester.pumpWidget(_Harness(api: api));
    await tester.pumpAndSettle();

    expect(find.text('Retour aux révisions'), findsOneWidget);
    expect(find.text('Voir la fiche'), findsNothing);
    expect(find.text('Retour au cours'), findsNothing);
  });

  testWidgets('primary action opens course sheet when errors exist', (
    tester,
  ) async {
    final api = InMemoryRevisionSessionsApi();
    final router = _resultRouter(api);
    addTearDown(router.dispose);

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();

    final primaryAction = find.widgetWithText(
      RevisionGradientButton,
      'Voir la fiche',
    );

    final button = tester.widget<RevisionGradientButton>(primaryAction);
    button.onPressed!();
    await tester.pumpAndSettle();

    expect(find.text('Fiche du cours'), findsOneWidget);
  });

  testWidgets('shows a clean loading state before the result is ready', (
    tester,
  ) async {
    final api = InMemoryRevisionSessionsApi();

    await tester.pumpWidget(_Harness(api: api));

    expect(find.text('Chargement du résultat'), findsOneWidget);
    expect(find.text('Préparation du bilan de la session.'), findsOneWidget);
  });

  testWidgets('displays a not-ready error without backend wording', (
    tester,
  ) async {
    final api = InMemoryRevisionSessionsApi()
      ..loadResultError = const RevisionSessionResultNotReadyException(
        'Revision session not completed',
      );

    await tester.pumpWidget(_Harness(api: api));
    await tester.pumpAndSettle();

    expect(find.text('Impossible de charger le résultat.'), findsOneWidget);
    expect(
      find.text('Le bilan sera disponible dès que la session sera finalisée.'),
      findsOneWidget,
    );
    expect(find.text('Réessayer'), findsOneWidget);
    expect(find.text('Revision session not completed'), findsNothing);
    expect(find.text('78%'), findsNothing);
  });
}

RevisionSessionResult resultWithoutKnowledgeUnits() {
  final base = revisionSessionResult();
  return RevisionSessionResult(
    session: base.session,
    summary: base.summary,
    knowledgeUnits: const [],
    corrections: base.corrections,
  );
}

RevisionSessionResult highButNotExcellentRevisionSessionResult() {
  return RevisionSessionResult(
    session: RevisionSessionResultSession(
      id: 'revision-session-1',
      subjectId: 'subject-1',
      courseId: 'course-1',
      mode: RevisionSessionMode.quick,
      status: RevisionSessionStatus.completed,
      createdAt: DateTime.parse('2026-06-15T12:00:00.000Z'),
      completedAt: DateTime.parse('2026-06-15T12:04:12.000Z'),
    ),
    summary: const RevisionSessionResultSummary(
      correctAnswers: 5,
      totalQuestions: 6,
      score: 5 / 6,
      durationSeconds: 252,
    ),
    knowledgeUnits: const [
      RevisionSessionKnowledgeUnitResult(
        knowledgeUnitId: 'unit-1',
        title: 'Séparation des pouvoirs',
        correctAnswers: 5,
        totalQuestions: 6,
        score: 5 / 6,
        state: RevisionSessionKnowledgeUnitResultState.mastered,
      ),
    ],
  );
}

RevisionSessionResult excellentRevisionSessionResult() {
  return RevisionSessionResult(
    session: RevisionSessionResultSession(
      id: 'session-perfect',
      subjectId: 'subject-1',
      courseId: 'course-1',
      mode: RevisionSessionMode.quick,
      status: RevisionSessionStatus.completed,
      createdAt: DateTime.parse('2026-06-15T12:00:00.000Z'),
      completedAt: DateTime.parse('2026-06-15T12:04:12.000Z'),
    ),
    summary: const RevisionSessionResultSummary(
      correctAnswers: 6,
      totalQuestions: 6,
      score: 1,
      durationSeconds: 252,
    ),
    knowledgeUnits: const [
      RevisionSessionKnowledgeUnitResult(
        knowledgeUnitId: 'unit-1',
        title: 'Séparation des pouvoirs',
        correctAnswers: 6,
        totalQuestions: 6,
        score: 1,
        state: RevisionSessionKnowledgeUnitResultState.mastered,
      ),
    ],
  );
}

RevisionSessionResult resultWithoutExplanation() {
  final base = revisionSessionResult();
  return RevisionSessionResult(
    session: base.session,
    summary: base.summary,
    knowledgeUnits: base.knowledgeUnits,
    corrections: const [
      RevisionSessionQuestionCorrection(
        prompt: 'Quelle institution vote la loi ?',
        isCorrect: false,
        selectedAnswers: ['Le préfet'],
        correctAnswers: ['Le Parlement'],
        explanation: null,
      ),
    ],
  );
}

RevisionSessionResult resultWithoutCourse() {
  final base = revisionSessionResult();
  return RevisionSessionResult(
    session: RevisionSessionResultSession(
      id: base.session.id,
      subjectId: base.session.subjectId,
      mode: base.session.mode,
      status: base.session.status,
      createdAt: base.session.createdAt,
      completedAt: base.session.completedAt,
    ),
    summary: base.summary,
    knowledgeUnits: base.knowledgeUnits,
    corrections: base.corrections,
  );
}

GoRouter _resultRouter(InMemoryRevisionSessionsApi api) {
  return GoRouter(
    initialLocation: AppRoutes.revisionSessionResultV2(
      sessionId: 'revision-session-1',
      courseId: 'course-1',
      mode: 'quick',
    ),
    routes: [
      GoRoute(
        path: AppRoutes.revisionSessionResultV2Path,
        builder: (context, state) => RevisionSessionResultPage(
          sessionId: state.pathParameters['sessionId']!,
          mode: state.uri.queryParameters['mode'],
          controller: RevisionSessionController(api),
        ),
      ),
      GoRoute(
        path: AppRoutes.courseSheetPath,
        builder: (context, state) => const Text('Fiche du cours'),
      ),
      GoRoute(
        path: AppRoutes.coursePath,
        builder: (context, state) => const Text('Détail cours'),
      ),
      GoRoute(
        path: AppRoutes.revisions,
        builder: (context, state) => const Text('Révisions'),
      ),
    ],
  );
}

class _Harness extends StatelessWidget {
  const _Harness({
    required this.api,
    this.sessionId = 'revision-session-1',
    this.mode,
  });

  final InMemoryRevisionSessionsApi api;
  final String sessionId;
  final String? mode;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: RevisionSessionResultPage(
        sessionId: sessionId,
        mode: mode,
        controller: RevisionSessionController(api),
      ),
    );
  }
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
    'global',
    'Ce que tu as loupé',
  ];

  for (final term in forbiddenTerms) {
    expect(find.textContaining(term), findsNothing, reason: term);
  }
}
