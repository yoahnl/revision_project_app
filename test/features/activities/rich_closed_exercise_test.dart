import 'package:flutter_test/flutter_test.dart';
import 'package:Neralune/features/activities/domain/rich_closed_exercise.dart';

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

    test('parses institution_matrix public questions', () {
      final questions = RichClosedExercise.fromJson(
        richClosedV1CExerciseJson(),
      ).questions;
      final matrix = questions[10] as RichClosedInstitutionMatrixQuestion;

      expect(questions, hasLength(11));
      expect(matrix.questionKind, RichClosedQuestionKind.institutionMatrix);
      expect(matrix.instruction, contains('option fermée'));
      expect(matrix.rows.map((row) => row.id), [
        'row-president',
        'row-government',
        'row-assembly',
      ]);
      expect(matrix.columns.map((column) => column.id), [
        'column-legitimacy',
        'column-action',
        'column-responsibility',
      ]);
      expect(matrix.cells.map((cell) => cell.id), [
        'cell-president-legitimacy',
        'cell-government-responsibility',
        'cell-assembly-action',
      ]);
      expect(matrix.cells.first.options.map((option) => option.id), [
        'option-legitimacy-election',
        'option-legitimacy-confidence',
        'option-legitimacy-nomination',
      ]);
    });

    test('parses diagram_labeling public questions', () {
      final questions = RichClosedExercise.fromJson(
        richClosedV1CFullExerciseJson(),
      ).questions;
      final diagram = questions[11] as RichClosedDiagramLabelingQuestion;

      expect(questions, hasLength(12));
      expect(diagram.questionKind, RichClosedQuestionKind.diagramLabeling);
      expect(diagram.instruction, contains('option fermée'));
      expect(diagram.diagram.layout, RichClosedDiagramLayout.verticalFlow);
      expect(diagram.diagram.nodes.map((node) => node.id), [
        'node-president',
        'node-government',
        'node-assembly',
        'node-senate',
      ]);
      expect(diagram.diagram.groups.map((group) => group.id), [
        'group-executive',
        'group-parliament',
      ]);
      expect(diagram.diagram.edges.map((edge) => edge.id), [
        'edge-president-government',
        'edge-government-assembly',
        'edge-assembly-government',
      ]);
      expect(diagram.slots.map((slot) => slot.id), [
        'slot-government-role',
        'slot-censure',
        'slot-nomination',
      ]);
      expect(diagram.slots.first.anchorType, RichClosedDiagramAnchorType.node);
      expect(diagram.slots.first.options.map((option) => option.id), [
        'option-government',
        'option-president',
        'option-senate',
      ]);
    });

    test('parses calculation_mcq public questions', () {
      final questions = RichClosedExercise.fromJson(
        richClosedV1CCalculationExerciseJson(),
      ).questions;
      final calculation = questions[12] as RichClosedCalculationMcqQuestion;

      expect(questions, hasLength(13));
      expect(calculation.questionKind, RichClosedQuestionKind.calculationMcq);
      expect(calculation.instruction, contains('résultat entier'));
      expect(calculation.scenario, contains('577 suffrages'));
      expect(
        calculation.calculation,
        isA<RichClosedAbsoluteMajorityThresholdCalculation>(),
      );
      expect(
        (calculation.calculation
                as RichClosedAbsoluteMajorityThresholdCalculation)
            .validVotes,
        577,
      );
      expect(
        calculation.choices.map((choice) => '${choice.id}:${choice.value}'),
        ['choice-288:288', 'choice-289:289', 'choice-290:290'],
      );
    });

    test('parses image_choice public questions', () {
      final questions = RichClosedExercise.fromJson(
        richClosedV1DImageChoiceExerciseJson(),
      ).questions;
      final imageChoice = questions[13] as RichClosedImageChoiceQuestion;

      expect(questions, hasLength(14));
      expect(imageChoice.questionKind, RichClosedQuestionKind.imageChoice);
      expect(imageChoice.instruction, contains('catalogue contrôlé'));
      expect(imageChoice.choices.map((choice) => choice.id), [
        'choice-image-a',
        'choice-image-b',
        'choice-image-c',
      ]);
      expect(
        imageChoice.choices.first.imageAssetId,
        'image-choice-historical-figure-001-v1',
      );
      expect(
        imageChoice.choices.first.altText,
        'Portrait historique en noir et blanc d’un homme en uniforme.',
      );
      expect(imageChoice.choices.first.license, 'internal_placeholder');
    });

    test('parses largest remainder calculation data without scoring it', () {
      final payload = richClosedExerciseJson();
      payload['questions'] = [
        richClosedCalculationLargestRemainderQuestionJson(),
      ];

      final question =
          RichClosedExercise.fromJson(payload).questions.single
              as RichClosedCalculationMcqQuestion;
      final calculation =
          question.calculation
              as RichClosedLargestRemainderTargetPartySeatsCalculation;

      expect(calculation.totalSeats, 10);
      expect(calculation.targetPartyId, 'party-a');
      expect(calculation.parties.map((party) => '${party.id}:${party.votes}'), [
        'party-a:4300',
        'party-b:3100',
        'party-c:1600',
        'party-d:1000',
      ]);
      expect(question.choices.map((choice) => choice.value), [3, 4, 5]);
    });

    test('accepts zero-vote parties in largest remainder calculation data', () {
      final questionJson = richClosedCalculationLargestRemainderQuestionJson();
      final calculationJson =
          questionJson['calculation']! as Map<String, Object?>;
      ((calculationJson['parties']! as List<Object?>).last!
              as Map<String, Object?>)['votes'] =
          0;
      final payload = richClosedExerciseJson();
      payload['questions'] = [questionJson];

      final question =
          RichClosedExercise.fromJson(payload).questions.single
              as RichClosedCalculationMcqQuestion;
      final calculation =
          question.calculation
              as RichClosedLargestRemainderTargetPartySeatsCalculation;

      expect(calculation.parties.last.votes, 0);
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
        'minAcceptedYear',
        'maxAcceptedYear',
        'explanation',
        'score',
        'modelAnswer',
        'answerText',
        'freeTextAnswer',
        'textAnswer',
        'answersPayload',
        'expectedValue',
        'workedSteps',
        'render',
        'renderPayload',
        'code',
        'eval',
        'Function',
        'function',
        'formula',
        'expression',
        'rawFormula',
        'calculationCode',
        'javascript',
        'python',
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

    test(
      'rejects institution_matrix public questions carrying private fields',
      () {
        final correctValuesLeak = richClosedV1CExerciseJson();
        ((correctValuesLeak['questions']! as List<Object?>)[10]!
            as Map<String, Object?>)['correctValues'] = [
          {
            'cellId': 'cell-president-legitimacy',
            'optionId': 'option-legitimacy-election',
          },
        ];
        final explanationLeak = richClosedV1CExerciseJson();
        ((explanationLeak['questions']! as List<Object?>)[10]!
                as Map<String, Object?>)['explanation'] =
            'Ne doit pas être visible en pré-submit.';

        expectParseError(() => RichClosedExercise.fromJson(correctValuesLeak));
        expectParseError(() => RichClosedExercise.fromJson(explanationLeak));
      },
    );

    test(
      'rejects diagram_labeling public questions carrying private or render fields',
      () {
        for (final field in [
          'correctValues',
          'explanation',
          'html',
          'svg',
          'rawSvg',
          'mermaid',
          'markdown',
          'widget',
          'component',
          'render',
          'renderPayload',
          'style',
          'css',
          'script',
          'imageUrl',
          'assetUrl',
          'canvas',
          'code',
          'eval',
          'Function',
          'function',
          'markup',
        ]) {
          final payload = richClosedV1CFullExerciseJson();
          ((payload['questions']! as List<Object?>)[11]!
              as Map<String, Object?>)[field] = field == 'correctValues'
              ? [
                  {
                    'slotId': 'slot-government-role',
                    'optionId': 'option-government',
                  },
                ]
              : 'forbidden';

          expectParseError(() => RichClosedExercise.fromJson(payload));
        }
      },
    );

    test(
      'rejects calculation_mcq public questions carrying private or formula fields',
      () {
        for (final field in [
          'correctChoiceId',
          'expectedValue',
          'workedSteps',
          'explanation',
          'formula',
          'expression',
          'rawFormula',
          'calculationCode',
          'javascript',
          'python',
          'render',
          'renderPayload',
          'code',
          'eval',
          'Function',
          'function',
        ]) {
          final payload = richClosedV1CCalculationExerciseJson();
          ((payload['questions']! as List<Object?>)[12]!
              as Map<String, Object?>)[field] = field == 'workedSteps'
              ? [
                  {'id': 'step-1', 'label': 'Étape', 'detail': 'Privé'},
                ]
              : 'forbidden';

          expectParseError(() => RichClosedExercise.fromJson(payload));
        }
      },
    );

    test(
      'rejects image_choice public questions carrying private or image fields',
      () {
        for (final field in [
          'correctChoiceId',
          'explanation',
          'semanticLabel',
          'answerHint',
          'imageUrl',
          'url',
          'remoteUrl',
          'src',
          'href',
          'storagePath',
          'bucketPath',
          'cdnUrl',
          'base64',
          'dataUri',
          'blob',
          'rawImage',
          'assetPath',
          'render',
          'renderPayload',
        ]) {
          final payload = richClosedV1DImageChoiceExerciseJson();
          ((payload['questions']! as List<Object?>)[13]!
                  as Map<String, Object?>)[field] =
              'forbidden';

          expectParseError(() => RichClosedExercise.fromJson(payload));
        }
      },
    );

    test('rejects incoherent image_choice public contracts', () {
      final unknownAsset = richClosedV1DImageChoiceExerciseJson();
      final unknownAssetQuestion =
          (unknownAsset['questions']! as List<Object?>)[13]!
              as Map<String, Object?>;
      ((unknownAssetQuestion['choices']! as List<Object?>).first!
              as Map<String, Object?>)['imageAssetId'] =
          'unknown-asset';

      final duplicateAsset = richClosedV1DImageChoiceExerciseJson();
      final duplicateAssetQuestion =
          (duplicateAsset['questions']! as List<Object?>)[13]!
              as Map<String, Object?>;
      ((duplicateAssetQuestion['choices']! as List<Object?>)[1]!
              as Map<String, Object?>)['imageAssetId'] =
          'image-choice-historical-figure-001-v1';

      final wrongAltText = richClosedV1DImageChoiceExerciseJson();
      final wrongAltQuestion =
          (wrongAltText['questions']! as List<Object?>)[13]!
              as Map<String, Object?>;
      ((wrongAltQuestion['choices']! as List<Object?>).first!
              as Map<String, Object?>)['altText'] =
          'Alt text inventé.';

      expectParseError(() => RichClosedExercise.fromJson(unknownAsset));
      expectParseError(() => RichClosedExercise.fromJson(duplicateAsset));
      expectParseError(() => RichClosedExercise.fromJson(wrongAltText));
    });

    test('rejects incoherent calculation_mcq public contracts', () {
      final badMode = richClosedV1CCalculationExerciseJson();
      final badModeQuestion =
          (badMode['questions']! as List<Object?>)[12]! as Map<String, Object?>;
      badModeQuestion['calculation'] = {'mode': 'dhondt_highest_average'};

      final duplicateChoiceValue = richClosedV1CCalculationExerciseJson();
      final duplicateQuestion =
          (duplicateChoiceValue['questions']! as List<Object?>)[12]!
              as Map<String, Object?>;
      ((duplicateQuestion['choices']! as List<Object?>)[1]!
              as Map<String, Object?>)['value'] =
          288;

      final badTarget = richClosedExerciseJson();
      final remainderQuestion =
          richClosedCalculationLargestRemainderQuestionJson();
      final remainderCalculation =
          remainderQuestion['calculation']! as Map<String, Object?>;
      remainderCalculation['targetPartyId'] = 'party-unknown';
      badTarget['questions'] = [remainderQuestion];

      expectParseError(() => RichClosedExercise.fromJson(badMode));
      expectParseError(() => RichClosedExercise.fromJson(duplicateChoiceValue));
      expectParseError(() => RichClosedExercise.fromJson(badTarget));
    });

    test('rejects diagram_labeling incoherent diagram references', () {
      final badEdge = richClosedV1CFullExerciseJson();
      final badEdgeQuestion =
          (badEdge['questions']! as List<Object?>)[11]! as Map<String, Object?>;
      final badEdgeDiagram =
          badEdgeQuestion['diagram']! as Map<String, Object?>;
      ((badEdgeDiagram['edges']! as List<Object?>).first!
              as Map<String, Object?>)['fromNodeId'] =
          'node-unknown';

      final badGroup = richClosedV1CFullExerciseJson();
      final badGroupQuestion =
          (badGroup['questions']! as List<Object?>)[11]!
              as Map<String, Object?>;
      final badGroupDiagram =
          badGroupQuestion['diagram']! as Map<String, Object?>;
      ((badGroupDiagram['nodes']! as List<Object?>).first!
              as Map<String, Object?>)['groupId'] =
          'group-unknown';

      expectParseError(() => RichClosedExercise.fromJson(badEdge));
      expectParseError(() => RichClosedExercise.fromJson(badGroup));
    });

    test('rejects diagram_labeling slots with unknown anchors', () {
      final badNodeAnchor = richClosedV1CFullExerciseJson();
      final badNodeQuestion =
          (badNodeAnchor['questions']! as List<Object?>)[11]!
              as Map<String, Object?>;
      ((badNodeQuestion['slots']! as List<Object?>).first!
              as Map<String, Object?>)['anchorId'] =
          'node-unknown';

      final badEdgeAnchor = richClosedV1CFullExerciseJson();
      final badEdgeQuestion =
          (badEdgeAnchor['questions']! as List<Object?>)[11]!
              as Map<String, Object?>;
      final slot =
          (badEdgeQuestion['slots']! as List<Object?>).first!
              as Map<String, Object?>;
      slot['anchorType'] = 'edge';
      slot['anchorId'] = 'edge-unknown';

      expectParseError(() => RichClosedExercise.fromJson(badNodeAnchor));
      expectParseError(() => RichClosedExercise.fromJson(badEdgeAnchor));
    });

    test('rejects institution_matrix cells with unknown axis references', () {
      final badRow = richClosedV1CExerciseJson();
      final badRowQuestion =
          (badRow['questions']! as List<Object?>)[10]! as Map<String, Object?>;
      ((badRowQuestion['cells']! as List<Object?>).first!
              as Map<String, Object?>)['rowId'] =
          'row-unknown';
      final badColumn = richClosedV1CExerciseJson();
      final badColumnQuestion =
          (badColumn['questions']! as List<Object?>)[10]!
              as Map<String, Object?>;
      ((badColumnQuestion['cells']! as List<Object?>).first!
              as Map<String, Object?>)['columnId'] =
          'column-unknown';

      expectParseError(() => RichClosedExercise.fromJson(badRow));
      expectParseError(() => RichClosedExercise.fromJson(badColumn));
    });

    test(
      'rejects institution_matrix cells with duplicate row/column slots',
      () {
        final payload = richClosedV1CExerciseJson();
        final question =
            (payload['questions']! as List<Object?>)[10]!
                as Map<String, Object?>;
        final cells = question['cells']! as List<Object?>;
        final firstCell = cells[0]! as Map<String, Object?>;
        final secondCell = cells[1]! as Map<String, Object?>;
        secondCell['rowId'] = firstCell['rowId'];
        secondCell['columnId'] = firstCell['columnId'];

        expectParseError(() => RichClosedExercise.fromJson(payload));
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
      expect(
        const RichClosedInstitutionMatrixAnswer(
          questionId: 'institution-matrix-1',
          values: [
            RichClosedInstitutionMatrixValue(
              cellId: 'cell-president-legitimacy',
              optionId: 'option-legitimacy-election',
            ),
          ],
        ).toJson(),
        {
          'questionId': 'institution-matrix-1',
          'questionKind': 'institution_matrix',
          'values': [
            {
              'cellId': 'cell-president-legitimacy',
              'optionId': 'option-legitimacy-election',
            },
          ],
        },
      );
      expect(
        const RichClosedDiagramLabelingAnswer(
          questionId: 'diagram-labeling-1',
          values: [
            RichClosedDiagramLabelingValue(
              slotId: 'slot-government-role',
              optionId: 'option-government',
            ),
          ],
        ).toJson(),
        {
          'questionId': 'diagram-labeling-1',
          'questionKind': 'diagram_labeling',
          'values': [
            {'slotId': 'slot-government-role', 'optionId': 'option-government'},
          ],
        },
      );
      expect(
        const RichClosedCalculationMcqAnswer(
          questionId: 'calculation-mcq-majority-1',
          choiceId: 'choice-289',
        ).toJson(),
        {
          'questionId': 'calculation-mcq-majority-1',
          'questionKind': 'calculation_mcq',
          'choiceId': 'choice-289',
        },
      );
      expect(
        const RichClosedImageChoiceAnswer(
          questionId: 'image-choice-1',
          choiceId: 'choice-image-a',
        ).toJson(),
        {
          'questionId': 'image-choice-1',
          'questionKind': 'image_choice',
          'choiceId': 'choice-image-a',
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

    test('rejects forbidden formula and render fields in parsed answers', () {
      for (final field in [
        'correctChoiceId',
        'expectedValue',
        'workedSteps',
        'render',
        'renderPayload',
        'code',
        'eval',
        'Function',
        'function',
        'formula',
        'expression',
        'semanticLabel',
        'answerHint',
        'imageUrl',
        'url',
        'storagePath',
        'base64',
        'blob',
      ]) {
        expectParseError(
          () => RichClosedAnswer.fromJson({
            'questionId': 'calculation-mcq-majority-1',
            'questionKind': 'calculation_mcq',
            'choiceId': 'choice-289',
            field: field == 'workedSteps'
                ? [
                    {'id': 'step-1', 'label': 'Étape', 'detail': 'Privé'},
                  ]
                : 'forbidden',
          }),
        );
      }
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

    test('parses institution_matrix post-submit corrections', () {
      final result = RichClosedExerciseResult.fromJson(
        richClosedV1CResultJson(),
      );
      final matrix = result.items[10];

      expect(matrix.submittedAnswer, isA<RichClosedInstitutionMatrixAnswer>());
      expect(
        (matrix.submittedAnswer as RichClosedInstitutionMatrixAnswer).values
            .map((value) => '${value.cellId}:${value.optionId}'),
        [
          'cell-president-legitimacy:option-legitimacy-election',
          'cell-government-responsibility:option-responsibility-assembly',
          'cell-assembly-action:option-action-censure',
        ],
      );
      expect(
        matrix.correction,
        isA<RichClosedCorrectInstitutionMatrixValuesCorrection>(),
      );
      expect(
        (matrix.correction
                as RichClosedCorrectInstitutionMatrixValuesCorrection)
            .correctValues
            .map((value) => '${value.cellId}:${value.optionId}'),
        [
          'cell-president-legitimacy:option-legitimacy-election',
          'cell-government-responsibility:option-responsibility-assembly',
          'cell-assembly-action:option-action-censure',
        ],
      );
    });

    test('parses diagram_labeling post-submit corrections', () {
      final result = RichClosedExerciseResult.fromJson(
        richClosedV1CFullResultJson(),
      );
      final diagram = result.items[11];

      expect(diagram.submittedAnswer, isA<RichClosedDiagramLabelingAnswer>());
      expect(
        (diagram.submittedAnswer as RichClosedDiagramLabelingAnswer).values.map(
          (value) => '${value.slotId}:${value.optionId}',
        ),
        [
          'slot-government-role:option-government',
          'slot-censure:option-motion-censure',
          'slot-nomination:option-nomination',
        ],
      );
      expect(
        diagram.correction,
        isA<RichClosedCorrectDiagramLabelingValuesCorrection>(),
      );
      expect(
        (diagram.correction as RichClosedCorrectDiagramLabelingValuesCorrection)
            .correctValues
            .map((value) => '${value.slotId}:${value.optionId}'),
        [
          'slot-government-role:option-government',
          'slot-censure:option-motion-censure',
          'slot-nomination:option-nomination',
        ],
      );
    });

    test('parses calculation_mcq post-submit corrections', () {
      final result = RichClosedExerciseResult.fromJson(
        richClosedV1CCalculationResultJson(),
      );
      final calculation = result.items[12];

      expect(
        calculation.submittedAnswer,
        isA<RichClosedCalculationMcqAnswer>(),
      );
      expect(
        (calculation.submittedAnswer as RichClosedCalculationMcqAnswer)
            .choiceId,
        'choice-289',
      );
      expect(
        calculation.correction,
        isA<RichClosedCorrectCalculationMcqCorrection>(),
      );

      final correction =
          calculation.correction as RichClosedCorrectCalculationMcqCorrection;
      expect(correction.correctChoiceId, 'choice-289');
      expect(correction.expectedValue, 289);
      expect(correction.workedSteps.map((step) => step.id), [
        'valid-votes',
        'majority-rule',
        'threshold',
      ]);
    });

    test('parses image_choice post-submit corrections', () {
      final result = RichClosedExerciseResult.fromJson(
        richClosedV1DImageChoiceResultJson(),
      );
      final imageChoice = result.items[13];

      expect(imageChoice.submittedAnswer, isA<RichClosedImageChoiceAnswer>());
      expect(
        (imageChoice.submittedAnswer as RichClosedImageChoiceAnswer).choiceId,
        'choice-image-a',
      );
      expect(
        imageChoice.correction,
        isA<RichClosedCorrectChoiceIdCorrection>(),
      );
      expect(
        (imageChoice.correction as RichClosedCorrectChoiceIdCorrection)
            .correctChoiceId,
        'choice-image-a',
      );
    });

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
