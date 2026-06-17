import 'package:flutter_test/flutter_test.dart';
import 'package:revision_app/features/activities/domain/rich_closed_exercise.dart';

import 'fixtures/rich_closed_exercise_fixtures.dart';

void main() {
  group('RichClosedExercise parsing', () {
    test('parses a complete V1-A pre-submit exercise', () {
      final exercise = RichClosedExercise.fromJson(richClosedExerciseJson());

      expect(exercise.sessionId, 'rich-session-1');
      expect(exercise.type, richClosedExerciseType);
      expect(exercise.version, richClosedExerciseVersion);
      expect(exercise.documentId, 'document-1');
      expect(exercise.questions, hasLength(6));
      expect(exercise.questions[0], isA<RichClosedSingleChoiceQuestion>());
      expect(exercise.questions[1], isA<RichClosedMultipleChoiceQuestion>());
      expect(exercise.questions[2], isA<RichClosedMatchingQuestion>());
      expect(exercise.questions[3], isA<RichClosedOrderingQuestion>());
      expect(exercise.questions[4], isA<RichClosedCaseQualificationQuestion>());
      expect(exercise.questions[5], isA<RichClosedErrorDetectionQuestion>());
    });

    test('parses all V1-A question fields explicitly', () {
      final questions = RichClosedExercise.fromJson(
        richClosedExerciseJson(),
      ).questions;

      final single = questions[0] as RichClosedSingleChoiceQuestion;
      final multiple = questions[1] as RichClosedMultipleChoiceQuestion;
      final matching = questions[2] as RichClosedMatchingQuestion;
      final ordering = questions[3] as RichClosedOrderingQuestion;
      final caseQuestion = questions[4] as RichClosedCaseQualificationQuestion;
      final error = questions[5] as RichClosedErrorDetectionQuestion;

      expect(single.choices.first.label, 'Responsabilité politique');
      expect(single.difficulty, RichClosedDifficulty.medium);
      expect(single.cognitiveSkill, RichClosedCognitiveSkill.classification);
      expect(multiple.minSelections, 2);
      expect(multiple.maxSelections, 2);
      expect(matching.leftItems, hasLength(3));
      expect(matching.rightItems, hasLength(3));
      expect(ordering.items.map((item) => item.id), [
        'item-1',
        'item-2',
        'item-3',
      ]);
      expect(caseQuestion.caseText, contains('confiance'));
      expect(error.statement, contains('régime présidentiel'));
      expect(error.errorOptions.first.id, 'error-a');
    });

    test('parses timeline and date_slider public questions', () {
      final questions = RichClosedExercise.fromJson(
        richClosedV1BExerciseJson(),
      ).questions;
      final timeline = questions[6] as RichClosedTimelineQuestion;
      final dateSlider = questions[7] as RichClosedDateSliderQuestion;

      expect(questions, hasLength(8));
      expect(timeline.questionKind, RichClosedQuestionKind.timeline);
      expect(timeline.instruction, contains('événements'));
      expect(timeline.events.map((event) => event.id), [
        'event-1',
        'event-2',
        'event-3',
      ]);
      expect(timeline.events.first.description, contains('procédure'));
      expect(dateSlider.questionKind, RichClosedQuestionKind.dateSlider);
      expect(dateSlider.minYear, 1945);
      expect(dateSlider.maxYear, 1970);
      expect(dateSlider.step, 1);
      expect(dateSlider.toleranceYears, 0);
    });

    test('parses true_false_grid and cause_consequence public questions', () {
      final questions = RichClosedExercise.fromJson(
        richClosedV1BFullExerciseJson(),
      ).questions;
      final trueFalse = questions[8] as RichClosedTrueFalseGridQuestion;
      final causeConsequence =
          questions[9] as RichClosedCauseConsequenceQuestion;

      expect(questions, hasLength(10));
      expect(trueFalse.questionKind, RichClosedQuestionKind.trueFalseGrid);
      expect(trueFalse.instruction, contains('lignes'));
      expect(trueFalse.rows.map((row) => row.id), ['row-1', 'row-2', 'row-3']);
      expect(trueFalse.rows.first.context, contains('parlementaire'));
      expect(
        causeConsequence.questionKind,
        RichClosedQuestionKind.causeConsequence,
      );
      expect(causeConsequence.causes.map((cause) => cause.id), [
        'cause-1',
        'cause-2',
        'cause-3',
      ]);
      expect(
        causeConsequence.consequences.map((consequence) => consequence.id),
        ['consequence-1', 'consequence-2', 'consequence-3'],
      );
      expect(causeConsequence.causes.first.description, contains('confiance'));
    });

    test('rejects cause_consequence with fewer consequences than causes', () {
      final payload = richClosedV1BFullExerciseJson();
      final question =
          (payload['questions'] as List<Object?>)[9]! as Map<String, Object?>;
      question['causes'] = [
        ...(question['causes']! as List<Object?>),
        {'id': 'cause-4', 'label': 'Cause sans conséquence disponible'},
      ];

      expectParseError(() => RichClosedExercise.fromJson(payload));
    });

    test('rejects unsupported question kinds', () {
      expectParseError(
        () => RichClosedExercise.fromJson(richClosedExerciseWithUnknownKind()),
      );
    });

    test('rejects pre-submit correction and feedback leaks', () {
      expectParseError(
        () => RichClosedExercise.fromJson(
          richClosedExerciseWithCorrectChoiceLeak(),
        ),
      );
      expectParseError(
        () => RichClosedExercise.fromJson(richClosedExerciseWithFeedbackLeak()),
      );
    });

    test('rejects every forbidden pre-submit correction field', () {
      for (final field in [
        'correctChoiceId',
        'correctChoiceIds',
        'correctPairs',
        'correctOrder',
        'correctValues',
        'correctErrorId',
        'correctYear',
        'explanation',
        'score',
        'modelAnswer',
        'answerText',
        'freeTextAnswer',
        'textAnswer',
        'answersPayload',
      ]) {
        final json = richClosedExerciseJson();
        ((json['questions']! as List<Object?>).first!
            as Map<String, Object?>)[field] = field == 'score'
            ? 1
            : 'forbidden';

        expectParseError(() => RichClosedExercise.fromJson(json));
      }
    });

    test('rejects unknown enums and incoherent multiple choice bounds', () {
      final badDifficulty = richClosedExerciseJson();
      ((badDifficulty['questions']! as List<Object?>).first!
              as Map<String, Object?>)['difficulty'] =
          'UNKNOWN';
      expectParseError(() => RichClosedExercise.fromJson(badDifficulty));

      final badSkill = richClosedExerciseJson();
      ((badSkill['questions']! as List<Object?>).first!
              as Map<String, Object?>)['cognitiveSkill'] =
          'analysis';
      expectParseError(() => RichClosedExercise.fromJson(badSkill));

      final badBounds = richClosedExerciseJson();
      final multiple =
          (badBounds['questions']! as List<Object?>)[1]!
              as Map<String, Object?>;
      multiple['minSelections'] = 3;
      multiple['maxSelections'] = 2;
      expectParseError(() => RichClosedExercise.fromJson(badBounds));
    });

    test('rejects empty ids and labels', () {
      final badId = richClosedExerciseJson();
      ((badId['questions']! as List<Object?>).first!
              as Map<String, Object?>)['id'] =
          ' ';
      expectParseError(() => RichClosedExercise.fromJson(badId));

      final badLabel = richClosedExerciseJson();
      final question =
          (badLabel['questions']! as List<Object?>).first!
              as Map<String, Object?>;
      ((question['choices']! as List<Object?>).first!
              as Map<String, Object?>)['label'] =
          '';
      expectParseError(() => RichClosedExercise.fromJson(badLabel));
    });

    test(
      'rejects V1-B public questions carrying private correction fields',
      () {
        final timelineLeak = richClosedV1BExerciseJson();
        ((timelineLeak['questions']! as List<Object?>)[6]!
            as Map<String, Object?>)['correctOrder'] = [
          'event-1',
          'event-2',
          'event-3',
        ];
        final dateLeak = richClosedV1BExerciseJson();
        ((dateLeak['questions']! as List<Object?>)[7]!
                as Map<String, Object?>)['correctYear'] =
            1958;

        expectParseError(() => RichClosedExercise.fromJson(timelineLeak));
        expectParseError(() => RichClosedExercise.fromJson(dateLeak));
      },
    );

    test(
      'rejects V1-018 public questions carrying private correction fields',
      () {
        final trueFalseLeak = richClosedV1BFullExerciseJson();
        ((trueFalseLeak['questions']! as List<Object?>)[8]!
            as Map<String, Object?>)['correctValues'] = [
          {'rowId': 'row-1', 'value': true},
        ];
        final causeConsequenceLeak = richClosedV1BFullExerciseJson();
        ((causeConsequenceLeak['questions']! as List<Object?>)[9]!
            as Map<String, Object?>)['correctPairs'] = [
          {'causeId': 'cause-1', 'consequenceId': 'consequence-1'},
        ];

        expectParseError(() => RichClosedExercise.fromJson(trueFalseLeak));
        expectParseError(
          () => RichClosedExercise.fromJson(causeConsequenceLeak),
        );
      },
    );
  });

  group('RichClosedAnswer submit DTO', () {
    test('serializes each V1-A answer shape', () {
      expect(
        const RichClosedSingleChoiceAnswer(
          questionId: 'single-1',
          choiceId: 'choice-a',
        ).toJson(),
        {
          'questionId': 'single-1',
          'questionKind': 'single_choice',
          'choiceId': 'choice-a',
        },
      );
      expect(
        const RichClosedMultipleChoiceAnswer(
          questionId: 'multiple-1',
          choiceIds: ['choice-a', 'choice-b'],
        ).toJson(),
        {
          'questionId': 'multiple-1',
          'questionKind': 'multiple_choice',
          'choiceIds': ['choice-a', 'choice-b'],
        },
      );
      expect(
        const RichClosedMatchingAnswer(
          questionId: 'matching-1',
          pairs: [RichClosedPair(leftId: 'left-1', rightId: 'right-1')],
        ).toJson(),
        {
          'questionId': 'matching-1',
          'questionKind': 'matching',
          'pairs': [
            {'leftId': 'left-1', 'rightId': 'right-1'},
          ],
        },
      );
      expect(
        const RichClosedOrderingAnswer(
          questionId: 'ordering-1',
          orderedIds: ['item-1', 'item-2'],
        ).toJson(),
        {
          'questionId': 'ordering-1',
          'questionKind': 'ordering',
          'orderedIds': ['item-1', 'item-2'],
        },
      );
      expect(
        const RichClosedCaseQualificationAnswer(
          questionId: 'case-1',
          choiceId: 'choice-a',
        ).toJson(),
        {
          'questionId': 'case-1',
          'questionKind': 'case_qualification',
          'choiceId': 'choice-a',
        },
      );
      expect(
        const RichClosedErrorDetectionAnswer(
          questionId: 'error-1',
          errorId: 'error-a',
        ).toJson(),
        {
          'questionId': 'error-1',
          'questionKind': 'error_detection',
          'errorId': 'error-a',
        },
      );
      expect(
        const RichClosedTimelineAnswer(
          questionId: 'timeline-1',
          orderedEventIds: ['event-1', 'event-2', 'event-3'],
        ).toJson(),
        {
          'questionId': 'timeline-1',
          'questionKind': 'timeline',
          'orderedEventIds': ['event-1', 'event-2', 'event-3'],
        },
      );
      expect(
        const RichClosedDateSliderAnswer(
          questionId: 'date-slider-1',
          year: 1958,
        ).toJson(),
        {
          'questionId': 'date-slider-1',
          'questionKind': 'date_slider',
          'year': 1958,
        },
      );
      expect(
        const RichClosedTrueFalseGridAnswer(
          questionId: 'true-false-grid-1',
          values: [
            RichClosedTrueFalseGridValue(rowId: 'row-1', value: true),
            RichClosedTrueFalseGridValue(rowId: 'row-2', value: false),
          ],
        ).toJson(),
        {
          'questionId': 'true-false-grid-1',
          'questionKind': 'true_false_grid',
          'values': [
            {'rowId': 'row-1', 'value': true},
            {'rowId': 'row-2', 'value': false},
          ],
        },
      );
      expect(
        const RichClosedCauseConsequenceAnswer(
          questionId: 'cause-consequence-1',
          pairs: [
            RichClosedCauseConsequencePair(
              causeId: 'cause-1',
              consequenceId: 'consequence-1',
            ),
          ],
        ).toJson(),
        {
          'questionId': 'cause-consequence-1',
          'questionKind': 'cause_consequence',
          'pairs': [
            {'causeId': 'cause-1', 'consequenceId': 'consequence-1'},
          ],
        },
      );
    });

    test('serializes submit wrapper without correction or free text', () {
      final json = const RichClosedExerciseSubmission(
        answers: [
          RichClosedSingleChoiceAnswer(
            questionId: 'single-1',
            choiceId: 'choice-a',
          ),
        ],
      ).toJson();
      final serialized = json.toString();

      expect(json, {
        'answers': [
          {
            'questionId': 'single-1',
            'questionKind': 'single_choice',
            'choiceId': 'choice-a',
          },
        ],
      });
      expect(serialized, isNot(contains('correct')));
      expect(serialized, isNot(contains('answerText')));
      expect(serialized, isNot(contains('feedback')));
    });
  });

  group('RichClosedExerciseResult parsing', () {
    test('parses a complete post-submit result from backend score', () {
      final result = RichClosedExerciseResult.fromJson(richClosedResultJson());

      expect(result.sessionId, 'rich-session-1');
      expect(result.type, richClosedExerciseType);
      expect(result.status, 'completed');
      expect(result.correctAnswers, 5);
      expect(result.totalQuestions, 6);
      expect(result.score, 0.833);
      expect(result.items, hasLength(6));
      expect(result.items.last.isCorrect, isFalse);
    });

    test('parses submitted answers and all correction payload forms', () {
      final result = RichClosedExerciseResult.fromJson(richClosedResultJson());

      expect(
        result.items[0].submittedAnswer,
        isA<RichClosedSingleChoiceAnswer>(),
      );
      expect(
        result.items[0].correction,
        isA<RichClosedCorrectChoiceIdCorrection>(),
      );
      expect(
        result.items[1].correction,
        isA<RichClosedCorrectChoiceIdsCorrection>(),
      );
      expect(
        result.items[2].correction,
        isA<RichClosedCorrectPairsCorrection>(),
      );
      expect(
        result.items[3].correction,
        isA<RichClosedCorrectOrderCorrection>(),
      );
      expect(
        result.items[5].correction,
        isA<RichClosedCorrectErrorIdCorrection>(),
      );
    });

    test('parses timeline and date_slider post-submit corrections', () {
      final result = RichClosedExerciseResult.fromJson(
        richClosedV1BResultJson(),
      );
      final timeline = result.items[6];
      final dateSlider = result.items[7];

      expect(timeline.submittedAnswer, isA<RichClosedTimelineAnswer>());
      expect(timeline.correction, isA<RichClosedCorrectOrderCorrection>());
      expect(
        (timeline.correction as RichClosedCorrectOrderCorrection).correctOrder,
        ['event-1', 'event-2', 'event-3'],
      );
      expect(dateSlider.submittedAnswer, isA<RichClosedDateSliderAnswer>());
      expect(dateSlider.correction, isA<RichClosedCorrectYearCorrection>());
      expect(
        (dateSlider.correction as RichClosedCorrectYearCorrection).correctYear,
        1958,
      );
    });

    test(
      'parses true_false_grid and cause_consequence post-submit corrections',
      () {
        final result = RichClosedExerciseResult.fromJson(
          richClosedV1BFullResultJson(),
        );
        final trueFalse = result.items[8];
        final causeConsequence = result.items[9];

        expect(trueFalse.submittedAnswer, isA<RichClosedTrueFalseGridAnswer>());
        expect(
          trueFalse.correction,
          isA<RichClosedCorrectTrueFalseValuesCorrection>(),
        );
        expect(
          (trueFalse.correction as RichClosedCorrectTrueFalseValuesCorrection)
              .correctValues
              .map((value) => '${value.rowId}:${value.value}'),
          ['row-1:true', 'row-2:false', 'row-3:true'],
        );
        expect(
          causeConsequence.submittedAnswer,
          isA<RichClosedCauseConsequenceAnswer>(),
        );
        expect(
          causeConsequence.correction,
          isA<RichClosedCorrectCauseConsequencePairsCorrection>(),
        );
        expect(
          (causeConsequence.correction
                  as RichClosedCorrectCauseConsequencePairsCorrection)
              .correctPairs
              .map((pair) => '${pair.causeId}:${pair.consequenceId}'),
          [
            'cause-1:consequence-1',
            'cause-2:consequence-2',
            'cause-3:consequence-3',
          ],
        );
      },
    );

    test('rejects absent or incoherent correction payloads', () {
      final missing = richClosedResultJson();
      final item =
          (missing['items']! as List<Object?>).first! as Map<String, Object?>;
      item.remove('correction');
      expectParseError(() => RichClosedExerciseResult.fromJson(missing));

      expectParseError(
        () => RichClosedExerciseResult.fromJson(
          richClosedResultWithIncoherentCorrection(),
        ),
      );
    });

    test('rejects invalid result envelope and score', () {
      final wrongStatus = richClosedResultJson()..['status'] = 'pending';
      expectParseError(() => RichClosedExerciseResult.fromJson(wrongStatus));

      final wrongType = richClosedResultJson()..['type'] = 'open_question';
      expectParseError(() => RichClosedExerciseResult.fromJson(wrongType));

      final wrongScore = richClosedResultJson()..['score'] = '0.8';
      expectParseError(() => RichClosedExerciseResult.fromJson(wrongScore));
    });
  });
}

void expectParseError(Object? Function() parse) {
  expect(parse, throwsA(isA<RichClosedExerciseParseException>()));
}
