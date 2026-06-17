import 'package:flutter_test/flutter_test.dart';
import 'package:revision_app/features/activities/domain/rich_closed_exercise.dart';
import 'package:revision_app/features/activities/presentation/rich_closed/rich_closed_answer_controller.dart';

import 'fixtures/rich_closed_exercise_fixtures.dart';

void main() {
  late RichClosedExercise exercise;

  setUp(() {
    exercise = RichClosedExercise.fromJson(richClosedExerciseJson());
  });

  test('single choice remplace la sélection précédente', () {
    final controller = RichClosedCoreAnswerController();
    final question = _question<RichClosedSingleChoiceQuestion>(exercise);

    controller.selectSingleChoice(question: question, choiceId: 'choice-a');
    controller.selectSingleChoice(question: question, choiceId: 'choice-b');

    final answer = controller.answerFor(question);
    expect(answer, isA<RichClosedSingleChoiceAnswer>());
    expect((answer! as RichClosedSingleChoiceAnswer).choiceId, 'choice-b');
  });

  test('case qualification remplace la sélection précédente', () {
    final controller = RichClosedCoreAnswerController();
    final question = _question<RichClosedCaseQualificationQuestion>(exercise);

    controller.selectCaseQualification(
      question: question,
      choiceId: 'choice-a',
    );
    controller.selectCaseQualification(
      question: question,
      choiceId: 'choice-b',
    );

    final answer = controller.answerFor(question);
    expect(answer, isA<RichClosedCaseQualificationAnswer>());
    expect((answer! as RichClosedCaseQualificationAnswer).choiceId, 'choice-b');
  });

  test('error detection remplace la sélection précédente', () {
    final controller = RichClosedCoreAnswerController();
    final question = _question<RichClosedErrorDetectionQuestion>(exercise);

    controller.selectErrorDetection(question: question, errorId: 'error-a');
    controller.selectErrorDetection(question: question, errorId: 'error-b');

    final answer = controller.answerFor(question);
    expect(answer, isA<RichClosedErrorDetectionAnswer>());
    expect((answer! as RichClosedErrorDetectionAnswer).errorId, 'error-b');
  });

  test('multiple choice toggle ajoute et enlève', () {
    final controller = RichClosedCoreAnswerController();
    final question = _question<RichClosedMultipleChoiceQuestion>(exercise);

    controller.toggleMultipleChoice(question: question, choiceId: 'choice-a');
    controller.toggleMultipleChoice(question: question, choiceId: 'choice-b');
    expect(controller.selectedChoiceIdsFor(question), ['choice-a', 'choice-b']);

    controller.toggleMultipleChoice(question: question, choiceId: 'choice-a');
    expect(controller.selectedChoiceIdsFor(question), ['choice-b']);
  });

  test('multiple choice ne dépasse pas maxSelections', () {
    final controller = RichClosedCoreAnswerController();
    final question = _question<RichClosedMultipleChoiceQuestion>(exercise);

    controller.toggleMultipleChoice(question: question, choiceId: 'choice-a');
    controller.toggleMultipleChoice(question: question, choiceId: 'choice-b');
    controller.toggleMultipleChoice(question: question, choiceId: 'choice-c');

    expect(controller.selectedChoiceIdsFor(question), ['choice-a', 'choice-b']);
    expect(controller.message, contains('2 réponses au maximum'));
  });

  test('multiple choice canSubmit est faux sous minSelections', () {
    final controller = RichClosedCoreAnswerController();
    final question = _question<RichClosedMultipleChoiceQuestion>(exercise);

    controller.toggleMultipleChoice(question: question, choiceId: 'choice-a');

    expect(controller.canSubmitQuestion(question), isFalse);
    expect(controller.answerFor(question), isNull);
  });

  test(
    'multiple choice canSubmit est vrai quand les bornes sont respectées',
    () {
      final controller = RichClosedCoreAnswerController();
      final question = _question<RichClosedMultipleChoiceQuestion>(exercise);

      controller.toggleMultipleChoice(question: question, choiceId: 'choice-a');
      controller.toggleMultipleChoice(question: question, choiceId: 'choice-b');

      final answer = controller.answerFor(question);
      expect(controller.canSubmitQuestion(question), isTrue);
      expect(answer, isA<RichClosedMultipleChoiceAnswer>());
      expect((answer! as RichClosedMultipleChoiceAnswer).choiceIds, [
        'choice-a',
        'choice-b',
      ]);
    },
  );

  test('produit les quatre réponses V1-010', () {
    final controller = RichClosedCoreAnswerController();
    final single = _question<RichClosedSingleChoiceQuestion>(exercise);
    final multiple = _question<RichClosedMultipleChoiceQuestion>(exercise);
    final caseQuestion = _question<RichClosedCaseQualificationQuestion>(
      exercise,
    );
    final error = _question<RichClosedErrorDetectionQuestion>(exercise);

    controller.selectSingleChoice(question: single, choiceId: 'choice-a');
    controller.toggleMultipleChoice(question: multiple, choiceId: 'choice-a');
    controller.toggleMultipleChoice(question: multiple, choiceId: 'choice-b');
    controller.selectCaseQualification(
      question: caseQuestion,
      choiceId: 'choice-a',
    );
    controller.selectErrorDetection(question: error, errorId: 'error-a');

    expect(controller.answerFor(single), isA<RichClosedSingleChoiceAnswer>());
    expect(
      controller.answerFor(multiple),
      isA<RichClosedMultipleChoiceAnswer>(),
    );
    expect(
      controller.answerFor(caseQuestion),
      isA<RichClosedCaseQualificationAnswer>(),
    );
    expect(controller.answerFor(error), isA<RichClosedErrorDetectionAnswer>());
  });

  test(
    'matching commence incomplet et devient submitable une fois complet',
    () {
      final controller = RichClosedCoreAnswerController();
      final matching = _question<RichClosedMatchingQuestion>(exercise);

      expect(controller.canSubmitQuestion(matching), isFalse);
      expect(controller.answerFor(matching), isNull);

      controller.setMatchingPair(
        question: matching,
        leftId: 'left-1',
        rightId: 'right-1',
      );

      expect(controller.selectedRightIdFor(matching.id, 'left-1'), 'right-1');
      expect(controller.answerFor(matching), isNull);

      controller.setMatchingPair(
        question: matching,
        leftId: 'left-2',
        rightId: 'right-2',
      );
      controller.setMatchingPair(
        question: matching,
        leftId: 'left-3',
        rightId: 'right-3',
      );

      final answer = controller.answerFor(matching);
      expect(controller.canSubmitQuestion(matching), isTrue);
      expect(answer, isA<RichClosedMatchingAnswer>());
      final matchingAnswer = answer! as RichClosedMatchingAnswer;
      expect(matchingAnswer.pairs.map((pair) => pair.leftId), [
        'left-1',
        'left-2',
        'left-3',
      ]);
      expect(matchingAnswer.pairs.map((pair) => pair.rightId), [
        'right-1',
        'right-2',
        'right-3',
      ]);
    },
  );

  test('matching garantit unicité des rightIds', () {
    final controller = RichClosedCoreAnswerController();
    final matching = _question<RichClosedMatchingQuestion>(exercise);

    controller.setMatchingPair(
      question: matching,
      leftId: 'left-1',
      rightId: 'right-1',
    );
    controller.setMatchingPair(
      question: matching,
      leftId: 'left-2',
      rightId: 'right-1',
    );

    expect(controller.selectedRightIdFor(matching.id, 'left-1'), isNull);
    expect(controller.selectedRightIdFor(matching.id, 'left-2'), 'right-1');
    expect(controller.canSubmitQuestion(matching), isFalse);
  });

  test('matching ignore les IDs inconnus sans casser l’état', () {
    final controller = RichClosedCoreAnswerController();
    final matching = _question<RichClosedMatchingQuestion>(exercise);

    controller.setMatchingPair(
      question: matching,
      leftId: 'left-1',
      rightId: 'right-1',
    );
    controller.setMatchingPair(
      question: matching,
      leftId: 'left-unknown',
      rightId: 'right-2',
    );
    controller.setMatchingPair(
      question: matching,
      leftId: 'left-2',
      rightId: 'right-unknown',
    );

    expect(controller.matchingPairsFor(matching).single.leftId, 'left-1');
    expect(controller.matchingPairsFor(matching).single.rightId, 'right-1');
  });

  test('ordering retourne l’ordre initial complet', () {
    final controller = RichClosedCoreAnswerController();
    final ordering = _question<RichClosedOrderingQuestion>(exercise);

    expect(controller.orderedIdsFor(ordering), ['item-1', 'item-2', 'item-3']);
    expect(controller.canSubmitQuestion(ordering), isTrue);
  });

  test('ordering move down et move up déplacent les items', () {
    final controller = RichClosedCoreAnswerController();
    final ordering = _question<RichClosedOrderingQuestion>(exercise);

    controller.moveOrderingItemDown(question: ordering, itemId: 'item-1');
    expect(controller.orderedIdsFor(ordering), ['item-2', 'item-1', 'item-3']);

    controller.moveOrderingItemUp(question: ordering, itemId: 'item-1');
    expect(controller.orderedIdsFor(ordering), ['item-1', 'item-2', 'item-3']);
  });

  test('ordering ignore les déplacements impossibles ou inconnus', () {
    final controller = RichClosedCoreAnswerController();
    final ordering = _question<RichClosedOrderingQuestion>(exercise);

    controller.moveOrderingItemUp(question: ordering, itemId: 'item-1');
    controller.moveOrderingItemDown(question: ordering, itemId: 'item-3');
    controller.moveOrderingItemDown(question: ordering, itemId: 'item-unknown');

    expect(controller.orderedIdsFor(ordering), ['item-1', 'item-2', 'item-3']);
  });

  test('ordering produit une answer complète sans doublons', () {
    final controller = RichClosedCoreAnswerController();
    final ordering = _question<RichClosedOrderingQuestion>(exercise);

    controller.moveOrderingItemDown(question: ordering, itemId: 'item-1');

    final answer = controller.answerFor(ordering);
    expect(answer, isA<RichClosedOrderingAnswer>());
    final orderingAnswer = answer! as RichClosedOrderingAnswer;
    expect(orderingAnswer.orderedIds, ['item-2', 'item-1', 'item-3']);
    expect(
      orderingAnswer.orderedIds.toSet().length,
      orderingAnswer.orderedIds.length,
    );
  });

  test('timeline retourne l’ordre initial complet', () {
    final controller = RichClosedCoreAnswerController();
    final v1bExercise = RichClosedExercise.fromJson(
      richClosedV1BExerciseJson(),
    );
    final timeline = _question<RichClosedTimelineQuestion>(v1bExercise);

    expect(controller.orderedEventIdsFor(timeline), [
      'event-1',
      'event-2',
      'event-3',
    ]);
    expect(controller.canSubmitQuestion(timeline), isTrue);
  });

  test('timeline move down et move up déplacent les événements', () {
    final controller = RichClosedCoreAnswerController();
    final v1bExercise = RichClosedExercise.fromJson(
      richClosedV1BExerciseJson(),
    );
    final timeline = _question<RichClosedTimelineQuestion>(v1bExercise);

    controller.moveTimelineEventDown(question: timeline, eventId: 'event-1');
    expect(controller.orderedEventIdsFor(timeline), [
      'event-2',
      'event-1',
      'event-3',
    ]);

    controller.moveTimelineEventUp(question: timeline, eventId: 'event-1');
    expect(controller.orderedEventIdsFor(timeline), [
      'event-1',
      'event-2',
      'event-3',
    ]);
  });

  test('timeline produit une answer orderedEventIds complète', () {
    final controller = RichClosedCoreAnswerController();
    final v1bExercise = RichClosedExercise.fromJson(
      richClosedV1BExerciseJson(),
    );
    final timeline = _question<RichClosedTimelineQuestion>(v1bExercise);

    controller.moveTimelineEventDown(question: timeline, eventId: 'event-1');

    final answer = controller.answerFor(timeline);
    expect(answer, isA<RichClosedTimelineAnswer>());
    expect((answer! as RichClosedTimelineAnswer).orderedEventIds, [
      'event-2',
      'event-1',
      'event-3',
    ]);
  });

  test('date slider produit une année initiale puis mise à jour', () {
    final controller = RichClosedCoreAnswerController();
    final v1bExercise = RichClosedExercise.fromJson(
      richClosedV1BExerciseJson(),
    );
    final dateSlider = _question<RichClosedDateSliderQuestion>(v1bExercise);

    expect(controller.canSubmitQuestion(dateSlider), isTrue);
    expect(controller.selectedYearFor(dateSlider), 1958);

    controller.setDateSliderYear(question: dateSlider, year: 1960);

    final answer = controller.answerFor(dateSlider);
    expect(answer, isA<RichClosedDateSliderAnswer>());
    expect((answer! as RichClosedDateSliderAnswer).year, 1960);
  });

  test('true_false_grid commence incomplet puis produit values', () {
    final controller = RichClosedCoreAnswerController();
    final v1bFullExercise = RichClosedExercise.fromJson(
      richClosedV1BFullExerciseJson(),
    );
    final trueFalse = _question<RichClosedTrueFalseGridQuestion>(
      v1bFullExercise,
    );

    expect(controller.canSubmitQuestion(trueFalse), isFalse);
    expect(controller.answerFor(trueFalse), isNull);

    controller.setTrueFalseValue(
      question: trueFalse,
      rowId: 'row-1',
      value: true,
    );
    controller.setTrueFalseValue(
      question: trueFalse,
      rowId: 'row-2',
      value: false,
    );

    expect(controller.canSubmitQuestion(trueFalse), isFalse);

    controller.setTrueFalseValue(
      question: trueFalse,
      rowId: 'row-3',
      value: true,
    );

    final answer = controller.answerFor(trueFalse);
    expect(answer, isA<RichClosedTrueFalseGridAnswer>());
    expect(
      (answer! as RichClosedTrueFalseGridAnswer).values.map(
        (value) => '${value.rowId}:${value.value}',
      ),
      ['row-1:true', 'row-2:false', 'row-3:true'],
    );
  });

  test('cause_consequence commence incomplet et remplace les doublons', () {
    final controller = RichClosedCoreAnswerController();
    final v1bFullExercise = RichClosedExercise.fromJson(
      richClosedV1BFullExerciseJson(),
    );
    final causeConsequence = _question<RichClosedCauseConsequenceQuestion>(
      v1bFullExercise,
    );

    expect(controller.canSubmitQuestion(causeConsequence), isFalse);
    expect(controller.answerFor(causeConsequence), isNull);

    controller.setCauseConsequencePair(
      question: causeConsequence,
      causeId: 'cause-1',
      consequenceId: 'consequence-1',
    );
    controller.setCauseConsequencePair(
      question: causeConsequence,
      causeId: 'cause-2',
      consequenceId: 'consequence-1',
    );

    expect(
      controller.selectedConsequenceIdFor(causeConsequence.id, 'cause-1'),
      isNull,
    );
    expect(
      controller.selectedConsequenceIdFor(causeConsequence.id, 'cause-2'),
      'consequence-1',
    );
    expect(controller.canSubmitQuestion(causeConsequence), isFalse);

    controller.setCauseConsequencePair(
      question: causeConsequence,
      causeId: 'cause-1',
      consequenceId: 'consequence-2',
    );
    controller.setCauseConsequencePair(
      question: causeConsequence,
      causeId: 'cause-3',
      consequenceId: 'consequence-3',
    );

    final answer = controller.answerFor(causeConsequence);
    expect(answer, isA<RichClosedCauseConsequenceAnswer>());
    expect(
      (answer! as RichClosedCauseConsequenceAnswer).pairs.map(
        (pair) => '${pair.causeId}:${pair.consequenceId}',
      ),
      [
        'cause-1:consequence-2',
        'cause-2:consequence-1',
        'cause-3:consequence-3',
      ],
    );
  });

  test('institution_matrix commence incomplet puis produit values', () {
    final controller = RichClosedCoreAnswerController();
    final v1cExercise = RichClosedExercise.fromJson(
      richClosedV1CExerciseJson(),
    );
    final matrix = _question<RichClosedInstitutionMatrixQuestion>(v1cExercise);

    expect(controller.canSubmitQuestion(matrix), isFalse);
    expect(controller.answerFor(matrix), isNull);
    expect(controller.institutionMatrixValuesFor(matrix), isEmpty);

    controller.setInstitutionMatrixValue(
      question: matrix,
      cellId: 'cell-president-legitimacy',
      optionId: 'option-legitimacy-election',
    );
    controller.setInstitutionMatrixValue(
      question: matrix,
      cellId: 'cell-government-responsibility',
      optionId: 'option-responsibility-assembly',
    );

    expect(controller.canSubmitQuestion(matrix), isFalse);

    controller.setInstitutionMatrixValue(
      question: matrix,
      cellId: 'cell-assembly-action',
      optionId: 'option-action-censure',
    );

    final answer = controller.answerFor(matrix);
    expect(controller.canSubmitQuestion(matrix), isTrue);
    expect(answer, isA<RichClosedInstitutionMatrixAnswer>());
    expect(
      (answer! as RichClosedInstitutionMatrixAnswer).values.map(
        (value) => '${value.cellId}:${value.optionId}',
      ),
      [
        'cell-president-legitimacy:option-legitimacy-election',
        'cell-government-responsibility:option-responsibility-assembly',
        'cell-assembly-action:option-action-censure',
      ],
    );
  });

  test('institution_matrix ignore ids inconnus et remplace une valeur', () {
    final controller = RichClosedCoreAnswerController();
    final v1cExercise = RichClosedExercise.fromJson(
      richClosedV1CExerciseJson(),
    );
    final matrix = _question<RichClosedInstitutionMatrixQuestion>(v1cExercise);

    controller.setInstitutionMatrixValue(
      question: matrix,
      cellId: 'cell-unknown',
      optionId: 'option-legitimacy-election',
    );
    controller.setInstitutionMatrixValue(
      question: matrix,
      cellId: 'cell-president-legitimacy',
      optionId: 'option-unknown',
    );
    controller.setInstitutionMatrixValue(
      question: matrix,
      cellId: 'cell-president-legitimacy',
      optionId: 'option-legitimacy-confidence',
    );
    controller.setInstitutionMatrixValue(
      question: matrix,
      cellId: 'cell-president-legitimacy',
      optionId: 'option-legitimacy-election',
    );

    expect(
      controller.selectedInstitutionMatrixOptionIdFor(
        matrix.id,
        'cell-president-legitimacy',
      ),
      'option-legitimacy-election',
    );
    expect(
      controller
          .institutionMatrixValuesFor(matrix)
          .map((value) => '${value.cellId}:${value.optionId}'),
      ['cell-president-legitimacy:option-legitimacy-election'],
    );
    expect(controller.canSubmitQuestion(matrix), isFalse);
  });

  test('diagram_labeling commence incomplet puis produit values', () {
    final controller = RichClosedCoreAnswerController();
    final v1cFullExercise = RichClosedExercise.fromJson(
      richClosedV1CFullExerciseJson(),
    );
    final diagram = _question<RichClosedDiagramLabelingQuestion>(
      v1cFullExercise,
    );

    expect(controller.canSubmitQuestion(diagram), isFalse);
    expect(controller.answerFor(diagram), isNull);
    expect(controller.diagramLabelingValuesFor(diagram), isEmpty);

    controller.setDiagramLabelingValue(
      question: diagram,
      slotId: 'slot-government-role',
      optionId: 'option-government',
    );
    controller.setDiagramLabelingValue(
      question: diagram,
      slotId: 'slot-censure',
      optionId: 'option-motion-censure',
    );

    expect(controller.canSubmitQuestion(diagram), isFalse);

    controller.setDiagramLabelingValue(
      question: diagram,
      slotId: 'slot-nomination',
      optionId: 'option-nomination',
    );

    final answer = controller.answerFor(diagram);
    expect(controller.canSubmitQuestion(diagram), isTrue);
    expect(answer, isA<RichClosedDiagramLabelingAnswer>());
    expect(
      (answer! as RichClosedDiagramLabelingAnswer).values.map(
        (value) => '${value.slotId}:${value.optionId}',
      ),
      [
        'slot-government-role:option-government',
        'slot-censure:option-motion-censure',
        'slot-nomination:option-nomination',
      ],
    );
  });

  test('diagram_labeling ignore ids inconnus et remplace une valeur', () {
    final controller = RichClosedCoreAnswerController();
    final v1cFullExercise = RichClosedExercise.fromJson(
      richClosedV1CFullExerciseJson(),
    );
    final diagram = _question<RichClosedDiagramLabelingQuestion>(
      v1cFullExercise,
    );

    controller.setDiagramLabelingValue(
      question: diagram,
      slotId: 'slot-unknown',
      optionId: 'option-government',
    );
    controller.setDiagramLabelingValue(
      question: diagram,
      slotId: 'slot-government-role',
      optionId: 'option-unknown',
    );
    controller.setDiagramLabelingValue(
      question: diagram,
      slotId: 'slot-government-role',
      optionId: 'option-president',
    );
    controller.setDiagramLabelingValue(
      question: diagram,
      slotId: 'slot-government-role',
      optionId: 'option-government',
    );

    expect(
      controller.selectedDiagramLabelingOptionIdFor(
        diagram.id,
        'slot-government-role',
      ),
      'option-government',
    );
    expect(
      controller
          .diagramLabelingValuesFor(diagram)
          .map((value) => '${value.slotId}:${value.optionId}'),
      ['slot-government-role:option-government'],
    );
    expect(controller.canSubmitQuestion(diagram), isFalse);
  });

  test('matching et ordering ne produisent jamais de correction', () {
    final controller = RichClosedCoreAnswerController();
    final matching = _question<RichClosedMatchingQuestion>(exercise);
    final ordering = _question<RichClosedOrderingQuestion>(exercise);

    controller.setMatchingPair(
      question: matching,
      leftId: 'left-1',
      rightId: 'right-1',
    );
    controller.setMatchingPair(
      question: matching,
      leftId: 'left-2',
      rightId: 'right-2',
    );
    controller.setMatchingPair(
      question: matching,
      leftId: 'left-3',
      rightId: 'right-3',
    );

    final matchingJson = controller.answerFor(matching)!.toJson();
    final orderingJson = controller.answerFor(ordering)!.toJson();

    for (final json in [matchingJson, orderingJson]) {
      expect(json.keys.any((key) => key.startsWith('correct')), isFalse);
      expect(json.containsKey('correction'), isFalse);
      expect(json.containsKey('score'), isFalse);
      expect(json.containsKey('explanation'), isFalse);
    }
  });

  test('timeline et date_slider ne produisent jamais de correction', () {
    final controller = RichClosedCoreAnswerController();
    final v1bExercise = RichClosedExercise.fromJson(
      richClosedV1BExerciseJson(),
    );
    final timeline = _question<RichClosedTimelineQuestion>(v1bExercise);
    final dateSlider = _question<RichClosedDateSliderQuestion>(v1bExercise);

    final timelineJson = controller.answerFor(timeline)!.toJson();
    final dateSliderJson = controller.answerFor(dateSlider)!.toJson();

    for (final json in [timelineJson, dateSliderJson]) {
      expect(json.keys.any((key) => key.startsWith('correct')), isFalse);
      expect(json.containsKey('correction'), isFalse);
      expect(json.containsKey('score'), isFalse);
      expect(json.containsKey('explanation'), isFalse);
    }
  });

  test(
    'true_false_grid et cause_consequence ne produisent jamais de correction',
    () {
      final controller = RichClosedCoreAnswerController();
      final v1bFullExercise = RichClosedExercise.fromJson(
        richClosedV1BFullExerciseJson(),
      );
      final trueFalse = _question<RichClosedTrueFalseGridQuestion>(
        v1bFullExercise,
      );
      final causeConsequence = _question<RichClosedCauseConsequenceQuestion>(
        v1bFullExercise,
      );

      for (final row in trueFalse.rows) {
        controller.setTrueFalseValue(
          question: trueFalse,
          rowId: row.id,
          value: true,
        );
      }
      for (final indexedCause in causeConsequence.causes.indexed) {
        controller.setCauseConsequencePair(
          question: causeConsequence,
          causeId: indexedCause.$2.id,
          consequenceId: causeConsequence.consequences[indexedCause.$1].id,
        );
      }

      final trueFalseJson = controller.answerFor(trueFalse)!.toJson();
      final causeConsequenceJson = controller
          .answerFor(causeConsequence)!
          .toJson();

      for (final json in [trueFalseJson, causeConsequenceJson]) {
        expect(json.keys.any((key) => key.startsWith('correct')), isFalse);
        expect(json.containsKey('correction'), isFalse);
        expect(json.containsKey('score'), isFalse);
        expect(json.containsKey('explanation'), isFalse);
      }
    },
  );

  test('institution_matrix ne produit jamais de correction', () {
    final controller = RichClosedCoreAnswerController();
    final v1cExercise = RichClosedExercise.fromJson(
      richClosedV1CExerciseJson(),
    );
    final matrix = _question<RichClosedInstitutionMatrixQuestion>(v1cExercise);

    for (final cell in matrix.cells) {
      controller.setInstitutionMatrixValue(
        question: matrix,
        cellId: cell.id,
        optionId: cell.options.first.id,
      );
    }

    final json = controller.answerFor(matrix)!.toJson();
    expect(json.keys.any((key) => key.startsWith('correct')), isFalse);
    expect(json.containsKey('correction'), isFalse);
    expect(json.containsKey('score'), isFalse);
    expect(json.containsKey('explanation'), isFalse);
  });

  test('diagram_labeling ne produit jamais de correction', () {
    final controller = RichClosedCoreAnswerController();
    final v1cFullExercise = RichClosedExercise.fromJson(
      richClosedV1CFullExerciseJson(),
    );
    final diagram = _question<RichClosedDiagramLabelingQuestion>(
      v1cFullExercise,
    );

    for (final slot in diagram.slots) {
      controller.setDiagramLabelingValue(
        question: diagram,
        slotId: slot.id,
        optionId: slot.options.first.id,
      );
    }

    final json = controller.answerFor(diagram)!.toJson();
    expect(json.keys.any((key) => key.startsWith('correct')), isFalse);
    expect(json.containsKey('correction'), isFalse);
    expect(json.containsKey('score'), isFalse);
    expect(json.containsKey('explanation'), isFalse);
    expect(json.containsKey('renderPayload'), isFalse);
  });

  test('ne produit jamais de correction dans le JSON de réponse', () {
    final controller = RichClosedCoreAnswerController();
    final question = _question<RichClosedSingleChoiceQuestion>(exercise);

    controller.selectSingleChoice(question: question, choiceId: 'choice-a');

    final json = controller.answerFor(question)!.toJson();
    expect(json.keys.any((key) => key.startsWith('correct')), isFalse);
    expect(json.containsKey('correction'), isFalse);
    expect(json.containsKey('score'), isFalse);
    expect(json.containsKey('explanation'), isFalse);
  });
}

T _question<T extends RichClosedQuestion>(RichClosedExercise exercise) {
  return exercise.questions.whereType<T>().single;
}
