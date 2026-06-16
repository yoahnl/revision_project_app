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
