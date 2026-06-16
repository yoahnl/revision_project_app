import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:revision_app/features/activities/application/activity_controller.dart';
import 'package:revision_app/features/activities/domain/diagnostic_quiz_activity.dart';
import 'package:revision_app/features/activities/domain/open_question_activity.dart';
import 'package:revision_app/features/activities/domain/rich_closed_exercise.dart';
import 'package:revision_app/features/activities/presentation/rich_closed/rich_closed_answer_controller.dart';
import 'package:revision_app/features/activities/presentation/rich_closed/rich_closed_question_renderer.dart';
import 'package:revision_app/presentation/pages/activities/rich_closed_exercise_page.dart';
import 'package:revision_app/presentation/widgets/revision_button.dart';

import 'fixtures/rich_closed_exercise_fixtures.dart';

void main() {
  late RichClosedExercise exercise;
  late RichClosedExerciseResult result;

  setUp(() {
    exercise = RichClosedExercise.fromJson(richClosedExerciseJson());
    result = RichClosedExerciseResult.fromJson(richClosedResultJson());
  });

  testWidgets('renderer rend les six widgets V1-A et propage le controller', (
    tester,
  ) async {
    final controller = RichClosedCoreAnswerController();
    final changedQuestions = <String>[];

    await tester.pumpWidget(
      _TestHost(
        scrollable: true,
        child: Column(
          children: [
            for (final question in exercise.questions)
              RichClosedQuestionRenderer(
                question: question,
                controller: controller,
                enabled: true,
                onChanged: (_) => changedQuestions.add(question.id),
              ),
          ],
        ),
      ),
    );

    expect(
      find.text('Quel critère caractérise un régime parlementaire ?'),
      findsOneWidget,
    );
    expect(
      find.text('Quels indices orientent vers un régime parlementaire ?'),
      findsOneWidget,
    );
    expect(
      find.text('Associe chaque mécanisme à sa fonction.'),
      findsOneWidget,
    );
    expect(find.text('Ordonne les étapes du raisonnement.'), findsOneWidget);
    expect(
      find.text('Choisis la qualification la plus pertinente.'),
      findsOneWidget,
    );
    expect(find.text('Repère l’erreur dominante.'), findsOneWidget);
    expect(find.textContaining('{'), findsNothing);

    await _tapVisible(tester, find.text('Responsabilité politique').first);

    expect(changedQuestions, contains('single-1'));
    expect(controller.canSubmitQuestion(exercise.questions.first), isTrue);
  });

  testWidgets('page démarre, collecte six réponses et affiche la correction', (
    tester,
  ) async {
    final submitCompleter = Completer<RichClosedExerciseResult>();
    final api = _FakeRichClosedActivityApi(
      exercise: exercise,
      result: result,
      submitCompleter: submitCompleter,
    );

    await tester.pumpWidget(
      _TestHost(
        child: RichClosedExercisePage(
          controller: ActivityController(api),
          subjectId: 'subject-1',
          knowledgeUnitId: 'unit-1',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(api.startCount, 1);
    expect(api.startedSubjectId, 'subject-1');
    expect(api.startedKnowledgeUnitId, 'unit-1');
    expect(find.text('Questions riches'), findsOneWidget);
    expect(find.text('1 / 6 répondues'), findsOneWidget);
    expect(_submitButton(tester).onPressed, isNull);
    expect(
      find.text('La responsabilité politique est centrale.'),
      findsNothing,
    );

    await _answerAllQuestions(tester);

    expect(find.text('6 / 6 répondues'), findsOneWidget);
    expect(_submitButton(tester).onPressed, isNotNull);

    await _tapVisible(
      tester,
      find.widgetWithText(RevisionButton, 'Valider mes réponses'),
    );
    await tester.pump();

    expect(find.text('Correction en cours...'), findsOneWidget);
    expect(api.submitCallCount, 1);
    expect(api.submittedAnswers, hasLength(6));
    for (final answer in api.submittedAnswers!) {
      final json = answer.toJson().toString();
      expect(json, isNot(contains('correct')));
      expect(json, isNot(contains('score')));
      expect(json, isNot(contains('explanation')));
    }

    submitCompleter.complete(result);
    await tester.pumpAndSettle();

    expect(find.text('Résultat'), findsOneWidget);
    expect(find.text('5 / 6'), findsOneWidget);
    expect(find.text('0.833'), findsOneWidget);
    expect(find.text('Réponse envoyée'), findsNWidgets(6));
    expect(
      find.text('La responsabilité politique est centrale.'),
      findsOneWidget,
    );
    expect(find.text('Valider mes réponses'), findsNothing);
  });

  testWidgets('page affiche une erreur contrôlée au démarrage', (tester) async {
    final api = _FakeRichClosedActivityApi(
      exercise: exercise,
      result: result,
      startError: StateError('network failed'),
    );

    await tester.pumpWidget(
      _TestHost(
        child: RichClosedExercisePage(
          controller: ActivityController(api),
          subjectId: 'subject-1',
          knowledgeUnitId: 'unit-1',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.textContaining('Impossible de charger les questions riches'),
      findsOneWidget,
    );
    expect(find.text('Réessayer'), findsOneWidget);
  });

  testWidgets('page affiche un état vide sans contexte notion', (tester) async {
    final api = _FakeRichClosedActivityApi(exercise: exercise, result: result);

    await tester.pumpWidget(
      _TestHost(
        child: RichClosedExercisePage(
          controller: ActivityController(api),
          subjectId: 'subject-1',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(api.startCount, 0);
    expect(find.textContaining('Sélectionne une notion'), findsOneWidget);
  });
}

RevisionButton _submitButton(WidgetTester tester) {
  return tester.widget<RevisionButton>(
    find.widgetWithText(RevisionButton, 'Valider mes réponses'),
  );
}

Future<void> _answerAllQuestions(WidgetTester tester) async {
  await _tapVisible(tester, find.text('Responsabilité politique').first);
  await _tapVisible(tester, find.text('Responsabilité du gouvernement').first);
  await _tapVisible(tester, find.text('Collaboration des pouvoirs').first);
  await _selectMatchingRight(
    tester,
    leftId: 'left-1',
    label: 'Responsabilité politique',
  );
  await _selectMatchingRight(
    tester,
    leftId: 'left-2',
    label: 'Fin anticipée d’une chambre',
  );
  await _selectMatchingRight(
    tester,
    leftId: 'left-3',
    label: 'Vérification d’une norme',
  );
  await _tapVisible(tester, find.text('Régime parlementaire').first);
  await _tapVisible(
    tester,
    find.text('Confusion avec le parlementarisme').first,
  );
}

Future<void> _selectMatchingRight(
  WidgetTester tester, {
  required String leftId,
  required String label,
}) async {
  final dropdown = find.byKey(ValueKey('matching-matching-1-$leftId'));
  await tester.ensureVisible(dropdown);
  await tester.tap(dropdown);
  await tester.pumpAndSettle();
  await tester.tap(find.text(label).last);
  await tester.pumpAndSettle();
}

Future<void> _tapVisible(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

class _TestHost extends StatelessWidget {
  const _TestHost({required this.child, this.scrollable = false});

  final Widget child;
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    final body = scrollable
        ? SingleChildScrollView(padding: const EdgeInsets.all(16), child: child)
        : child;

    return MaterialApp(home: Scaffold(body: body));
  }
}

class _FakeRichClosedActivityApi implements ActivityApi {
  _FakeRichClosedActivityApi({
    required this.exercise,
    required this.result,
    this.submitCompleter,
    this.startError,
  });

  final RichClosedExercise exercise;
  final RichClosedExerciseResult result;
  final Completer<RichClosedExerciseResult>? submitCompleter;
  final Object? startError;
  String? startedSubjectId;
  String? startedKnowledgeUnitId;
  List<RichClosedAnswer>? submittedAnswers;
  int startCount = 0;
  int submitCallCount = 0;

  @override
  Future<DiagnosticQuizActivity> startNextActivity({
    required String subjectId,
    String? knowledgeUnitId,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<DiagnosticQuizResult> submitResult({
    required String sessionId,
    required List<DiagnosticQuizAnswer> answers,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<OpenQuestionActivity> startOpenQuestion({
    required String subjectId,
    required String knowledgeUnitId,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<OpenAnswerSubmissionResult> submitOpenAnswer({
    required String sessionId,
    required String answerText,
  }) {
    throw UnimplementedError();
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
  }) async {
    startCount += 1;
    if (startError != null) {
      throw startError!;
    }

    startedSubjectId = subjectId;
    startedKnowledgeUnitId = knowledgeUnitId;
    return exercise;
  }

  @override
  Future<RichClosedExercise> getRichClosedExercise(String sessionId) async {
    return exercise;
  }

  @override
  Future<RichClosedExerciseResult> submitRichClosedExercise({
    required String sessionId,
    required List<RichClosedAnswer> answers,
  }) async {
    submitCallCount += 1;
    submittedAnswers = answers;

    final completer = submitCompleter;
    if (completer != null) {
      return completer.future;
    }

    return result;
  }

  @override
  Future<RichClosedExerciseResult> getRichClosedExerciseResult(
    String sessionId,
  ) async {
    return result;
  }
}
