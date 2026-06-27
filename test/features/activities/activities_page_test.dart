import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:Neralune/features/activities/application/activity_controller.dart';
import 'package:Neralune/features/activities/domain/diagnostic_quiz_activity.dart';
import 'package:Neralune/features/activities/domain/open_question_activity.dart';
import 'package:Neralune/features/activities/domain/rich_closed_exercise.dart';
import 'package:Neralune/presentation/pages/activities/activities_page.dart';
import 'package:Neralune/presentation/widgets/revision_button.dart';

import '../../fakes/in_memory_activity_api.dart';

void main() {
  testWidgets('starts open question directly with subject and knowledge unit', (
    tester,
  ) async {
    final api = InMemoryActivityApi();

    await tester.pumpWidget(
      _ActivitiesHarness(
        api: api,
        subjectId: 'subject-1',
        knowledgeUnitId: 'unit-1',
      ),
    );
    await tester.pumpAndSettle();

    expect(api.startedOpenQuestionSubjectId, 'subject-1');
    expect(api.startedOpenQuestionKnowledgeUnitId, 'unit-1');
    expect(api.startedOpenQuestionCount, 1);
    expect(api.startedDiagnosticQuizCount, 0);
    expect(find.text('Question ouverte test'), findsOneWidget);
    expect(find.text('Question test'), findsNothing);
  });

  testWidgets('keeps diagnostic quiz as default with subject only', (
    tester,
  ) async {
    final api = InMemoryActivityApi();

    await tester.pumpWidget(
      _ActivitiesHarness(api: api, subjectId: 'subject-1'),
    );
    await tester.pumpAndSettle();

    expect(api.startedSubjectId, 'subject-1');
    expect(api.startedDiagnosticQuizCount, 1);
    expect(api.startedOpenQuestionCount, 0);
    expect(find.text('Question test'), findsOneWidget);

    await tester.tap(find.widgetWithText(RevisionButton, 'Question ouverte'));
    await tester.pumpAndSettle();

    expect(api.startedOpenQuestionCount, 0);
  });

  testWidgets('can switch from direct open question to diagnostic quiz', (
    tester,
  ) async {
    final api = InMemoryActivityApi();

    await tester.pumpWidget(
      _ActivitiesHarness(
        api: api,
        subjectId: 'subject-1',
        knowledgeUnitId: 'unit-1',
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(RevisionButton, 'QCM'));
    await tester.pumpAndSettle();

    expect(api.startedSubjectId, 'subject-1');
    expect(api.startedKnowledgeUnitId, 'unit-1');
    expect(api.startedDiagnosticQuizCount, 1);
    expect(find.text('Question test'), findsOneWidget);
  });

  testWidgets('can switch back to open question when a knowledge unit exists', (
    tester,
  ) async {
    final api = InMemoryActivityApi();

    await tester.pumpWidget(
      _ActivitiesHarness(
        api: api,
        subjectId: 'subject-1',
        knowledgeUnitId: 'unit-1',
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(RevisionButton, 'QCM'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(RevisionButton, 'Question ouverte'));
    await tester.pumpAndSettle();

    expect(api.startedOpenQuestionSubjectId, 'subject-1');
    expect(api.startedOpenQuestionKnowledgeUnitId, 'unit-1');
    expect(api.startedOpenQuestionCount, 2);
    expect(find.text('Question ouverte test'), findsOneWidget);
  });

  testWidgets('reloads when activity params change', (tester) async {
    final api = InMemoryActivityApi();

    await tester.pumpWidget(
      _ActivitiesHarness(api: api, subjectId: 'subject-1'),
    );
    await tester.pumpAndSettle();

    expect(api.startedDiagnosticQuizCount, 1);
    expect(api.startedOpenQuestionCount, 0);
    expect(find.text('Question test'), findsOneWidget);

    await tester.pumpWidget(
      _ActivitiesHarness(
        api: api,
        subjectId: 'subject-1',
        knowledgeUnitId: 'unit-1',
      ),
    );
    await tester.pumpAndSettle();

    expect(api.startedOpenQuestionKnowledgeUnitId, 'unit-1');
    expect(api.startedOpenQuestionCount, 1);
    expect(find.text('Question ouverte test'), findsOneWidget);

    await tester.pumpWidget(
      _ActivitiesHarness(
        api: api,
        subjectId: 'subject-1',
        knowledgeUnitId: 'unit-2',
      ),
    );
    await tester.pumpAndSettle();

    expect(api.startedOpenQuestionKnowledgeUnitId, 'unit-2');
    expect(api.startedOpenQuestionCount, 2);

    await tester.pumpWidget(
      _ActivitiesHarness(api: api, subjectId: 'subject-1'),
    );
    await tester.pumpAndSettle();

    expect(api.startedDiagnosticQuizCount, 2);
    expect(find.text('Question test'), findsOneWidget);
  });

  testWidgets('does not load an activity without subject', (tester) async {
    final api = InMemoryActivityApi();

    await tester.pumpWidget(_ActivitiesHarness(api: api));
    await tester.pumpAndSettle();

    expect(api.startedDiagnosticQuizCount, 0);
    expect(api.startedOpenQuestionCount, 0);
    expect(find.text('Choisis une notion depuis un cours'), findsOneWidget);
    expect(
      find.text(
        'Les activités se lancent depuis le parcours d’un cours. Ouvre un cours, choisis une notion, puis lance une activité adaptée.',
      ),
      findsOneWidget,
    );
    expect(find.text('Ouvrir les cours'), findsOneWidget);
    expect(find.text('Aucune activite selectionnee'), findsNothing);
    expect(find.textContaining('backend'), findsNothing);
    expect(find.textContaining('payload'), findsNothing);
    expect(find.textContaining('legacy'), findsNothing);
    expect(find.textContaining('409'), findsNothing);
  });

  testWidgets('shows an actionable timeout when activity loading is too long', (
    tester,
  ) async {
    final api = _NeverCompletingActivityApi();

    await tester.pumpWidget(
      _ActivitiesHarness(api: api, subjectId: 'subject-1'),
    );
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pump(const Duration(seconds: 10));
    await tester.pump();

    expect(
      find.text('Cette activité prend plus de temps que prévu'),
      findsOneWidget,
    );
    expect(
      find.text(
        'Neralune prépare encore cette question. Tu peux réessayer ou ouvrir tes cours en attendant.',
      ),
      findsOneWidget,
    );
    expect(find.text('Réessayer'), findsOneWidget);
    expect(find.text('Ouvrir les cours'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.textContaining('backend'), findsNothing);
    expect(find.textContaining('payload'), findsNothing);
    expect(find.textContaining('legacy'), findsNothing);
    expect(find.textContaining('409'), findsNothing);
  });
}

class _ActivitiesHarness extends StatelessWidget {
  const _ActivitiesHarness({
    required this.api,
    this.subjectId,
    this.knowledgeUnitId,
  });

  final ActivityApi api;
  final String? subjectId;
  final String? knowledgeUnitId;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ActivitiesPage(
        controller: ActivityController(api),
        subjectId: subjectId,
        knowledgeUnitId: knowledgeUnitId,
      ),
    );
  }
}

class _NeverCompletingActivityApi implements ActivityApi {
  @override
  Future<DiagnosticQuizActivity> startNextActivity({
    required String subjectId,
    String? knowledgeUnitId,
  }) {
    return Completer<DiagnosticQuizActivity>().future;
  }

  @override
  Future<DiagnosticQuizResult> submitResult({
    required String sessionId,
    required List<DiagnosticQuizAnswer> answers,
  }) {
    return Completer<DiagnosticQuizResult>().future;
  }

  @override
  Future<OpenQuestionActivity> startOpenQuestion({
    required String subjectId,
    required String knowledgeUnitId,
  }) {
    return Completer<OpenQuestionActivity>().future;
  }

  @override
  Future<OpenAnswerSubmissionResult> submitOpenAnswer({
    required String sessionId,
    required String answerText,
  }) {
    return Completer<OpenAnswerSubmissionResult>().future;
  }

  @override
  Future<RichClosedExercise> startRichClosedExercise({
    required String subjectId,
    required String knowledgeUnitId,
    String? documentId,
    int questionCount = 6,
    RichClosedComplexityProfile complexityProfile =
        RichClosedComplexityProfile.exam,
    Map<RichClosedQuestionKind, int>? questionTypeMix,
  }) {
    return Completer<RichClosedExercise>().future;
  }

  @override
  Future<RichClosedExercise> getRichClosedExercise(String sessionId) {
    return Completer<RichClosedExercise>().future;
  }

  @override
  Future<RichClosedExerciseResult> submitRichClosedExercise({
    required String sessionId,
    required List<RichClosedAnswer> answers,
  }) {
    return Completer<RichClosedExerciseResult>().future;
  }

  @override
  Future<RichClosedExerciseResult> getRichClosedExerciseResult(
    String sessionId,
  ) {
    return Completer<RichClosedExerciseResult>().future;
  }
}
