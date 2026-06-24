import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:Neralune/features/revision_sessions/application/revision_session_controller.dart';
import 'package:Neralune/features/revision_sessions/data/revision_sessions_api.dart';
import 'package:Neralune/features/revision_sessions/domain/revision_session.dart';
import 'package:Neralune/presentation/design_system/components/revision_mvp_components.dart';
import 'package:Neralune/presentation/pages/revision_sessions/revision_session_result_page.dart';

import '../../fakes/in_memory_revision_sessions_api.dart';

void main() {
  testWidgets(
    'displays real revision session result without static MVP score',
    (tester) async {
      final api = InMemoryRevisionSessionsApi();

      await tester.pumpWidget(_Harness(api: api));
      await tester.pumpAndSettle();

      expect(api.loadResultCount, 1);
      expect(api.loadedResultSessionId, 'revision-session-1');
      expect(find.text('Session terminée'), findsOneWidget);
      expect(find.text('67%'), findsWidgets);
      expect(find.text('4/6 bonnes réponses'), findsOneWidget);
      expect(find.text('À retravailler'), findsOneWidget);
      expect(find.text('Séparation des pouvoirs'), findsOneWidget);
      expect(find.text('Ce que tu as loupé'), findsOneWidget);
      expect(find.text('Quelle institution vote la loi ?'), findsOneWidget);
      expect(find.textContaining('Le préfet'), findsOneWidget);
      expect(find.textContaining('Le Parlement'), findsWidgets);
      expect(find.byType(RevisionConfettiOverlay), findsNothing);
      expect(find.text('78%'), findsNothing);
      expect(find.text('4/5 bonnes'), findsNothing);
    },
  );

  testWidgets('shows confetti only for strong results above seventy percent', (
    tester,
  ) async {
    final api = InMemoryRevisionSessionsApi()
      ..resultResponse = highScoreRevisionSessionResult();

    await tester.pumpWidget(_Harness(api: api));
    await tester.pumpAndSettle();

    expect(find.text('83%'), findsWidgets);
    expect(find.byType(RevisionConfettiOverlay), findsOneWidget);
  });

  testWidgets('loads exam preparation result when mode is exam', (
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
    expect(find.text('Examen terminé'), findsOneWidget);
    expect(find.text('100%'), findsWidgets);
    expect(find.text('1/1 bonnes réponses'), findsOneWidget);
    expect(find.text('Tu maîtrises'), findsOneWidget);
    expect(find.text('Séparation des pouvoirs'), findsOneWidget);
  });

  testWidgets('displays a not-ready error from backend result contract', (
    tester,
  ) async {
    final api = InMemoryRevisionSessionsApi()
      ..loadResultError = const RevisionSessionResultNotReadyException(
        'Revision session not completed',
      );

    await tester.pumpWidget(_Harness(api: api));
    await tester.pumpAndSettle();

    expect(find.text('Résultat indisponible'), findsOneWidget);
    expect(find.text('Revision session not completed'), findsOneWidget);
    expect(find.text('78%'), findsNothing);
  });
}

RevisionSessionResult highScoreRevisionSessionResult() {
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
