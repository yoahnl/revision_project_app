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

  testWidgets('renderer rend timeline et date_slider', (tester) async {
    final controller = RichClosedCoreAnswerController();
    final v1bExercise = RichClosedExercise.fromJson(
      richClosedV1BExerciseJson(),
    );
    final changedQuestions = <String>[];

    await tester.pumpWidget(
      _TestHost(
        scrollable: true,
        child: Column(
          children: [
            for (final question in v1bExercise.questions.skip(6))
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
    await tester.pump();

    expect(find.text('Dépôt de la motion'), findsOneWidget);
    expect(find.text('Année sélectionnée : 1958'), findsOneWidget);
    expect(changedQuestions, containsAll(['timeline-1', 'date-slider-1']));
    expect(find.text('correctOrder'), findsNothing);
    expect(find.text('correctYear'), findsNothing);
  });

  testWidgets('renderer rend true_false_grid et cause_consequence', (
    tester,
  ) async {
    final controller = RichClosedCoreAnswerController();
    final v1bFullExercise = RichClosedExercise.fromJson(
      richClosedV1BFullExerciseJson(),
    );
    final changedQuestions = <String>[];

    await tester.pumpWidget(
      _TestHost(
        scrollable: true,
        child: Column(
          children: [
            for (final question in v1bFullExercise.questions.skip(8))
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
      find.text('Le gouvernement peut être responsable devant le Parlement.'),
      findsOneWidget,
    );
    expect(find.text('Motion de censure adoptée'), findsOneWidget);
    expect(find.text('correctValues'), findsNothing);
    expect(find.text('correctPairs'), findsNothing);

    await tester.tap(find.byKey(const ValueKey('true-false-row-1-true')));
    await tester.pump();

    expect(changedQuestions, contains('true-false-grid-1'));
  });

  testWidgets('renderer rend institution_matrix', (tester) async {
    final controller = RichClosedCoreAnswerController();
    final v1cExercise = RichClosedExercise.fromJson(
      richClosedV1CExerciseJson(),
    );
    final changedQuestions = <String>[];

    await tester.pumpWidget(
      _TestHost(
        scrollable: true,
        child: Column(
          children: [
            RichClosedQuestionRenderer(
              question: v1cExercise.questions.last,
              controller: controller,
              enabled: true,
              onChanged: (_) =>
                  changedQuestions.add(v1cExercise.questions.last.id),
            ),
          ],
        ),
      ),
    );

    expect(find.text('Président de la République'), findsOneWidget);
    expect(find.text('Mode de légitimité'), findsOneWidget);
    expect(find.text('correctValues'), findsNothing);
    expect(find.text('explanation'), findsNothing);

    final dropdown = tester.widget<DropdownButton<String>>(
      find.byKey(
        const ValueKey(
          'institution-matrix-institution-matrix-1-cell-president-legitimacy',
        ),
      ),
    );
    dropdown.onChanged!('option-legitimacy-election');
    await tester.pump();

    expect(changedQuestions, contains('institution-matrix-1'));
    expect(controller.canSubmitQuestion(v1cExercise.questions.last), isFalse);
  });

  testWidgets('renderer rend diagram_labeling', (tester) async {
    final controller = RichClosedCoreAnswerController();
    final v1cFullExercise = RichClosedExercise.fromJson(
      richClosedV1CFullExerciseJson(),
    );
    final changedQuestions = <String>[];

    await tester.pumpWidget(
      _TestHost(
        scrollable: true,
        child: Column(
          children: [
            RichClosedQuestionRenderer(
              question: v1cFullExercise.questions.last,
              controller: controller,
              enabled: true,
              onChanged: (_) =>
                  changedQuestions.add(v1cFullExercise.questions.last.id),
            ),
          ],
        ),
      ),
    );

    expect(find.text('Rapports institutionnels'), findsOneWidget);
    expect(find.text('Président de la République'), findsOneWidget);
    expect(
      find.text('Quel organe conduit la politique nationale ?'),
      findsOneWidget,
    );
    expect(find.text('correctValues'), findsNothing);
    expect(find.text('explanation'), findsNothing);
    expect(find.text('svg'), findsNothing);
    expect(find.text('renderPayload'), findsNothing);

    final dropdown = tester.widget<DropdownButton<String>>(
      find.byKey(
        const ValueKey(
          'diagram-labeling-diagram-labeling-1-slot-government-role',
        ),
      ),
    );
    dropdown.onChanged!('option-government');
    await tester.pump();

    expect(changedQuestions, contains('diagram-labeling-1'));
    expect(
      controller.canSubmitQuestion(v1cFullExercise.questions.last),
      isFalse,
    );
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

  testWidgets('page submit et affiche les corrections V1-B', (tester) async {
    final v1bExercise = RichClosedExercise.fromJson(
      richClosedV1BExerciseJson(),
    );
    final v1bResult = RichClosedExerciseResult.fromJson(
      richClosedV1BResultJson(),
    );
    final api = _FakeRichClosedActivityApi(
      exercise: v1bExercise,
      result: v1bResult,
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

    expect(find.text('3 / 8 répondues'), findsOneWidget);

    await _answerAllQuestions(tester);

    expect(find.text('8 / 8 répondues'), findsOneWidget);
    expect(_submitButton(tester).onPressed, isNotNull);

    await _tapVisible(
      tester,
      find.widgetWithText(RevisionButton, 'Valider mes réponses'),
    );
    await tester.pumpAndSettle();

    expect(api.submittedAnswers, hasLength(8));
    expect(
      api.submittedAnswers!
          .whereType<RichClosedTimelineAnswer>()
          .single
          .orderedEventIds,
      ['event-1', 'event-2', 'event-3'],
    );
    expect(
      api.submittedAnswers!.whereType<RichClosedDateSliderAnswer>().single.year,
      1958,
    );
    expect(find.text('Année correcte : 1958'), findsOneWidget);
    expect(find.text('Plage acceptée : 1958 - 1958'), findsOneWidget);
  });

  testWidgets('page submit et affiche les corrections V1-018', (tester) async {
    final v1bFullExercise = RichClosedExercise.fromJson(
      richClosedV1BFullExerciseJson(),
    );
    final v1bFullResult = RichClosedExerciseResult.fromJson(
      richClosedV1BFullResultJson(),
    );
    final api = _FakeRichClosedActivityApi(
      exercise: v1bFullExercise,
      result: v1bFullResult,
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

    expect(find.text('3 / 10 répondues'), findsOneWidget);

    await _answerAllQuestions(tester);

    expect(find.text('10 / 10 répondues'), findsOneWidget);
    expect(_submitButton(tester).onPressed, isNotNull);

    await _tapVisible(
      tester,
      find.widgetWithText(RevisionButton, 'Valider mes réponses'),
    );
    await tester.pumpAndSettle();

    expect(api.submittedAnswers, hasLength(10));
    expect(
      api.submittedAnswers!
          .whereType<RichClosedTrueFalseGridAnswer>()
          .single
          .values
          .map((value) => '${value.rowId}:${value.value}'),
      ['row-1:true', 'row-2:true', 'row-3:true'],
    );
    expect(
      api.submittedAnswers!
          .whereType<RichClosedCauseConsequenceAnswer>()
          .single
          .pairs
          .map((pair) => '${pair.causeId}:${pair.consequenceId}'),
      [
        'cause-1:consequence-1',
        'cause-2:consequence-2',
        'cause-3:consequence-3',
      ],
    );
    expect(
      find.text(
        'La séparation des pouvoirs interdit toute collaboration. : Faux',
      ),
      findsOneWidget,
    );
    expect(
      find.text('Motion de censure adoptée → Démission du gouvernement'),
      findsWidgets,
    );
  });

  testWidgets('page submit et affiche les corrections V1-C', (tester) async {
    final v1cExercise = RichClosedExercise.fromJson(
      richClosedV1CExerciseJson(),
    );
    final v1cResult = RichClosedExerciseResult.fromJson(
      richClosedV1CResultJson(),
    );
    final api = _FakeRichClosedActivityApi(
      exercise: v1cExercise,
      result: v1cResult,
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

    expect(find.text('3 / 11 répondues'), findsOneWidget);

    await _answerAllQuestions(tester);

    expect(find.text('11 / 11 répondues'), findsOneWidget);
    expect(_submitButton(tester).onPressed, isNotNull);

    await _tapVisible(
      tester,
      find.widgetWithText(RevisionButton, 'Valider mes réponses'),
    );
    await tester.pumpAndSettle();

    expect(api.submittedAnswers, hasLength(11));
    expect(
      api.submittedAnswers!
          .whereType<RichClosedInstitutionMatrixAnswer>()
          .single
          .values
          .map((value) => '${value.cellId}:${value.optionId}'),
      [
        'cell-president-legitimacy:option-legitimacy-election',
        'cell-government-responsibility:option-responsibility-assembly',
        'cell-assembly-action:option-action-censure',
      ],
    );
    expect(
      find.text(
        'Président de la République / Mode de légitimité : Élection nationale',
      ),
      findsWidgets,
    );
  });

  testWidgets('page submit et affiche les corrections V1-020', (tester) async {
    final v1cFullExercise = RichClosedExercise.fromJson(
      richClosedV1CFullExerciseJson(),
    );
    final v1cFullResult = RichClosedExerciseResult.fromJson(
      richClosedV1CFullResultJson(),
    );
    final api = _FakeRichClosedActivityApi(
      exercise: v1cFullExercise,
      result: v1cFullResult,
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

    expect(find.text('3 / 12 répondues'), findsOneWidget);

    await _answerAllQuestions(tester);

    expect(find.text('12 / 12 répondues'), findsOneWidget);
    expect(_submitButton(tester).onPressed, isNotNull);

    await _tapVisible(
      tester,
      find.widgetWithText(RevisionButton, 'Valider mes réponses'),
    );
    await tester.pumpAndSettle();

    expect(api.submittedAnswers, hasLength(12));
    expect(
      api.submittedAnswers!
          .whereType<RichClosedDiagramLabelingAnswer>()
          .single
          .values
          .map((value) => '${value.slotId}:${value.optionId}'),
      [
        'slot-government-role:option-government',
        'slot-censure:option-motion-censure',
        'slot-nomination:option-nomination',
      ],
    );
    expect(find.text('Gouvernement : Gouvernement'), findsWidgets);
    expect(
      find.text(
        'Assemblée nationale -> Gouvernement / contrôle : Motion de censure',
      ),
      findsWidgets,
    );
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
  await _tapIfPresent(
    tester,
    find.byKey(const ValueKey('true-false-row-1-true')),
  );
  await _tapIfPresent(
    tester,
    find.byKey(const ValueKey('true-false-row-2-true')),
  );
  await _tapIfPresent(
    tester,
    find.byKey(const ValueKey('true-false-row-3-true')),
  );
  await _selectCauseConsequence(
    tester,
    causeId: 'cause-1',
    consequenceId: 'consequence-1',
  );
  await _selectCauseConsequence(
    tester,
    causeId: 'cause-2',
    consequenceId: 'consequence-2',
  );
  await _selectCauseConsequence(
    tester,
    causeId: 'cause-3',
    consequenceId: 'consequence-3',
  );
  await _selectInstitutionMatrix(
    tester,
    cellId: 'cell-president-legitimacy',
    optionId: 'option-legitimacy-election',
  );
  await _selectInstitutionMatrix(
    tester,
    cellId: 'cell-government-responsibility',
    optionId: 'option-responsibility-assembly',
  );
  await _selectInstitutionMatrix(
    tester,
    cellId: 'cell-assembly-action',
    optionId: 'option-action-censure',
  );
  await _selectDiagramLabeling(
    tester,
    slotId: 'slot-government-role',
    optionId: 'option-government',
  );
  await _selectDiagramLabeling(
    tester,
    slotId: 'slot-censure',
    optionId: 'option-motion-censure',
  );
  await _selectDiagramLabeling(
    tester,
    slotId: 'slot-nomination',
    optionId: 'option-nomination',
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

Future<void> _selectCauseConsequence(
  WidgetTester tester, {
  required String causeId,
  required String consequenceId,
}) async {
  final finder = find.byKey(
    ValueKey('cause-consequence-cause-consequence-1-$causeId'),
  );
  if (finder.evaluate().isEmpty) {
    return;
  }

  await tester.ensureVisible(finder);
  final dropdown = tester.widget<DropdownButton<String>>(finder);
  dropdown.onChanged!(consequenceId);
  await tester.pumpAndSettle();
}

Future<void> _selectInstitutionMatrix(
  WidgetTester tester, {
  required String cellId,
  required String optionId,
}) async {
  final finder = find.byKey(
    ValueKey('institution-matrix-institution-matrix-1-$cellId'),
  );
  if (finder.evaluate().isEmpty) {
    return;
  }

  await tester.ensureVisible(finder);
  final dropdown = tester.widget<DropdownButton<String>>(finder);
  dropdown.onChanged!(optionId);
  await tester.pumpAndSettle();
}

Future<void> _selectDiagramLabeling(
  WidgetTester tester, {
  required String slotId,
  required String optionId,
}) async {
  final finder = find.byKey(
    ValueKey('diagram-labeling-diagram-labeling-1-$slotId'),
  );
  if (finder.evaluate().isEmpty) {
    return;
  }

  await tester.ensureVisible(finder);
  final dropdown = tester.widget<DropdownButton<String>>(finder);
  dropdown.onChanged!(optionId);
  await tester.pumpAndSettle();
}

Future<void> _tapIfPresent(WidgetTester tester, Finder finder) async {
  if (finder.evaluate().isEmpty) {
    return;
  }

  await _tapVisible(tester, finder);
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
