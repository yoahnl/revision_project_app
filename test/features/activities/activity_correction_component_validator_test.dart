import 'package:flutter_test/flutter_test.dart';
import 'package:Neralune/features/activities/genui/activity_correction_component_validator.dart';

void main() {
  group('activity correction GenUI validators', () {
    test('accepts valid McqQuestionCard payloads', () {
      expect(isMcqQuestionCardPayloadSafe(validQuestionPayload()), isTrue);
    });

    test('rejects McqQuestionCard correction leaks before submit', () {
      for (final entry in {
        'correctChoiceId': 'choice-a',
        'correctChoiceIds': ['choice-a'],
        'isCorrect': true,
        'explanation': 'Explication interdite.',
        'feedback': 'Feedback interdit.',
        'choiceFeedback': [
          {'choiceId': 'choice-a', 'feedback': 'Interdit'},
        ],
      }.entries) {
        expect(
          isMcqQuestionCardPayloadSafe({
            ...validQuestionPayload(),
            entry.key: entry.value,
          }),
          isFalse,
          reason: entry.key,
        );
      }
    });

    test('rejects McqQuestionCard source text before submit', () {
      expect(
        isMcqQuestionCardPayloadSafe({
          ...validQuestionPayload(),
          'sources': [
            {
              'chunkId': 'chunk-1',
              'text': 'Texte source interdit avant correction.',
              'pageNumber': null,
              'index': 0,
            },
          ],
        }),
        isFalse,
      );
    });

    test('rejects McqQuestionCard unknown fields and unsafe text', () {
      expect(
        isMcqQuestionCardPayloadSafe({
          ...validQuestionPayload(),
          'extra': true,
        }),
        isFalse,
      );
      expect(
        isMcqQuestionCardPayloadSafe({
          ...validQuestionPayload(),
          'prompt': '<script>alert(1)</script>',
        }),
        isFalse,
      );
    });

    test('accepts valid McqCorrectionPanel payloads', () {
      expect(isMcqCorrectionPanelPayloadSafe(validCorrectionPayload()), isTrue);
    });

    test('rejects invalid McqCorrectionPanel payloads', () {
      expect(
        isMcqCorrectionPanelPayloadSafe({
          ...validCorrectionPayload(),
          'selectedChoiceId': 'choice-a',
          'selectedChoiceIds': ['choice-a'],
        }),
        isFalse,
      );
      expect(
        isMcqCorrectionPanelPayloadSafe({
          ...validCorrectionPayload(),
          'explanation': '',
        }),
        isFalse,
      );
    });

    test('accepts and rejects ActivityResultCard payloads', () {
      expect(
        isActivityResultCardPayloadSafe({
          'title': 'Résultat',
          'status': 'completed',
          'correctAnswers': 7,
          'totalQuestions': 10,
          'score': 0.7,
          'message': 'Bon début.',
        }),
        isTrue,
      );
      expect(
        isActivityResultCardPayloadSafe({
          'title': 'Résultat',
          'status': 'completed',
          'correctAnswers': 11,
          'totalQuestions': 10,
        }),
        isFalse,
      );
    });

    test('accepts valid QuestionChartCard payloads', () {
      expect(isQuestionChartCardPayloadSafe(validChartPayload()), isTrue);
    });

    test('rejects unsafe or unbounded chart payloads', () {
      expect(
        isQuestionChartCardPayloadSafe({
          ...validChartPayload(),
          'chartType': 'radar',
        }),
        isFalse,
      );
      expect(
        isQuestionChartCardPayloadSafe({
          ...validChartPayload(),
          'data': List.generate(
            maxQuestionChartRows + 1,
            (index) => {'label': 'L$index', 'value': index},
          ),
        }),
        isFalse,
      );
      expect(
        isQuestionChartCardPayloadSafe({
          ...validChartPayload(),
          'data': [
            {
              for (var index = 0; index < maxQuestionChartColumns + 1; index++)
                'column$index': index,
            },
          ],
        }),
        isFalse,
      );
      expect(
        isQuestionChartCardPayloadSafe({
          ...validChartPayload(),
          'xKey': 'invalid key with spaces',
        }),
        isFalse,
      );
      expect(
        isQuestionChartCardPayloadSafe({
          ...validChartPayload(),
          'title': '<svg></svg>',
        }),
        isFalse,
      );
    });

    test('accepts valid QuestionDiagramCard payloads', () {
      expect(isQuestionDiagramCardPayloadSafe(validDiagramPayload()), isTrue);
    });

    test('rejects unsafe or incoherent diagram payloads', () {
      expect(
        isQuestionDiagramCardPayloadSafe({
          ...validDiagramPayload(),
          'edges': [
            {'from': 'node-1', 'to': 'missing-node'},
          ],
        }),
        isFalse,
      );
      expect(
        isQuestionDiagramCardPayloadSafe({
          ...validDiagramPayload(),
          'nodes': List.generate(
            maxQuestionDiagramNodes + 1,
            (index) => {'id': 'node-$index', 'label': 'Node $index'},
          ),
        }),
        isFalse,
      );
      expect(
        isQuestionDiagramCardPayloadSafe({
          ...validDiagramPayload(),
          'edges': List.generate(
            maxQuestionDiagramEdges + 1,
            (index) => {'from': 'node-1', 'to': 'node-2'},
          ),
        }),
        isFalse,
      );
      expect(
        isQuestionDiagramCardPayloadSafe({
          ...validDiagramPayload(),
          'description': '```mermaid\ngraph TD\n```',
        }),
        isFalse,
      );
    });

    test('rejects unknown components', () {
      expect(
        isActivityCorrectionComponentPayloadSafe('UnknownCard', {
          'title': 'Rien',
        }),
        isFalse,
      );
    });
  });
}

Map<String, Object?> validQuestionPayload() {
  return {
    'questionId': 'question-1',
    'displayOrder': 1,
    'totalQuestions': 10,
    'prompt': 'Quelle conséquence découle de cette règle ?',
    'difficulty': 'MEDIUM',
    'selectionMode': 'multiple',
    'minSelections': 1,
    'maxSelections': 2,
    'choices': [
      {'id': 'choice-a', 'label': 'Réponse A'},
      {'id': 'choice-b', 'label': 'Réponse B'},
    ],
    'selectedChoiceIds': ['choice-a'],
    'sources': [
      {'chunkId': 'chunk-1', 'pageNumber': null, 'index': 0},
    ],
    'visuals': [validChartPayload()],
  };
}

Map<String, Object?> validCorrectionPayload() {
  return {
    'questionId': 'question-1',
    'prompt': 'Quelle conséquence découle de cette règle ?',
    'selectionMode': 'single',
    'choices': [
      {'id': 'choice-a', 'label': 'Réponse A'},
      {'id': 'choice-b', 'label': 'Réponse B'},
    ],
    'selectedChoiceId': 'choice-a',
    'correctChoiceId': 'choice-b',
    'isCorrect': false,
    'partialScore': 0,
    'explanation': 'La réponse attendue découle du passage source.',
    'choiceFeedback': [
      {'choiceId': 'choice-a', 'feedback': 'Ce choix confond deux notions.'},
      {'choiceId': 'choice-b', 'feedback': 'Ce choix reprend la règle.'},
    ],
    'sources': [
      {
        'chunkId': 'chunk-1',
        'text': 'Extrait source post-submit.',
        'pageNumber': null,
        'index': 0,
      },
    ],
  };
}

Map<String, Object?> validChartPayload() {
  return {
    'visualId': 'visual-chart-1',
    'chartType': 'bar',
    'title': 'Répartition',
    'description': 'Comparaison bornée.',
    'data': [
      {'label': 'A', 'value': 2},
      {'label': 'B', 'value': 3},
    ],
    'xKey': 'label',
    'yKeys': ['value'],
    'sources': [
      {'chunkId': 'chunk-1', 'pageNumber': null, 'index': 0},
    ],
  };
}

Map<String, Object?> validDiagramPayload() {
  return {
    'visualId': 'visual-diagram-1',
    'title': 'Enchaînement',
    'description': 'Relation simple.',
    'nodes': [
      {'id': 'node-1', 'label': 'Règle'},
      {'id': 'node-2', 'label': 'Conséquence'},
    ],
    'edges': [
      {'from': 'node-1', 'to': 'node-2', 'label': 'implique'},
    ],
    'sources': [
      {'chunkId': 'chunk-1', 'pageNumber': null, 'index': 0},
    ],
  };
}
