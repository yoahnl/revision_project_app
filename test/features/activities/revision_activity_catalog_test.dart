import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genui/genui.dart';
import 'package:Neralune/features/activities/genui/revision_activity_catalog.dart';

void main() {
  group('buildRevisionActivityCatalog', () {
    test('combines activity widgets with the no-asset basic catalog', () {
      final catalog = buildRevisionActivityCatalog();

      expect(catalog.catalogId, revisionActivityCatalogId);

      final itemNames = catalog.items.map((item) => item.name).toSet();
      expect(itemNames, contains('QuestionCard'));
      expect(itemNames, contains('SummaryCard'));
      expect(itemNames, contains('KeyPointsList'));
      expect(itemNames, contains('SourceExcerptCard'));
      expect(itemNames, contains('McqQuestionCard'));
      expect(itemNames, contains('McqCorrectionPanel'));
      expect(itemNames, contains('ActivityResultCard'));
      expect(itemNames, contains('QuestionChartCard'));
      expect(itemNames, contains('QuestionDiagramCard'));
      expect(itemNames, contains('Text'));
      expect(itemNames, contains('Column'));
      expect(itemNames, isNot(contains('Image')));

      expect(
        catalog.systemPromptFragments,
        contains(
          predicate<String>((fragment) => fragment.contains('QuestionCard')),
        ),
      );
    });

    test('exposes the stable catalog id and QuestionCard schema', () {
      final catalog = buildRevisionActivityCatalog();

      final capabilities = catalog.toCapabilitiesJson();

      expect(capabilities['catalogId'], revisionActivityCatalogId);

      final components = capabilities['components'] as Map<String, Object?>;
      expect(components, contains('QuestionCard'));
      expect(components, contains('SummaryCard'));
      expect(components, contains('KeyPointsList'));
      expect(components, contains('SourceExcerptCard'));
      expect(components, contains('McqQuestionCard'));
      expect(components, contains('McqCorrectionPanel'));
      expect(components, contains('ActivityResultCard'));
      expect(components, contains('QuestionChartCard'));
      expect(components, contains('QuestionDiagramCard'));

      final questionCard = components['QuestionCard'] as Map<String, Object?>;
      expect(questionCard['required'], containsAll(['component', 'prompt']));

      final properties = questionCard['properties'] as Map<String, Object?>;
      expect(properties, contains('prompt'));

      final summaryCard = components['SummaryCard'] as Map<String, Object?>;
      expect(
        summaryCard['required'],
        containsAll(['component', 'title', 'content', 'keyPoints']),
      );
      expect(summaryCard['additionalProperties'], isFalse);
    });

    testWidgets('renders activity and correction components with safe payloads', (
      tester,
    ) async {
      final catalog = buildRevisionActivityCatalog();

      await tester.pumpWidget(
        MaterialApp(
          home: SingleChildScrollView(
            child: Column(
              children: [
                catalogWidget(
                  catalog,
                  type: 'McqQuestionCard',
                  data: mcqQuestionPayload(),
                ),
                catalogWidget(
                  catalog,
                  type: 'McqCorrectionPanel',
                  data: mcqCorrectionPayload(),
                ),
                catalogWidget(
                  catalog,
                  type: 'ActivityResultCard',
                  data: {
                    'title': 'Résultat',
                    'status': 'completed',
                    'correctAnswers': 7,
                    'totalQuestions': 10,
                    'score': 0.7,
                    'message': 'Bon début.',
                  },
                ),
                catalogWidget(
                  catalog,
                  type: 'QuestionChartCard',
                  data: chartPayload(),
                ),
                catalogWidget(
                  catalog,
                  type: 'QuestionDiagramCard',
                  data: diagramPayload(),
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Quelle conséquence découle de cette règle ?'), findsNWidgets(2));
      expect(find.text('Plusieurs réponses possibles'), findsOneWidget);
      expect(find.text('Réponse A'), findsWidgets);
      expect(find.text('Réponse attendue'), findsOneWidget);
      expect(find.text('La réponse attendue découle du passage source.'), findsOneWidget);
      expect(find.text('7 / 10'), findsOneWidget);
      expect(find.text('Répartition'), findsOneWidget);
      expect(find.text('Enchaînement'), findsOneWidget);
      expect(find.text('node-1 → node-2'), findsOneWidget);
    });

    testWidgets('uses a safe fallback for invalid McqQuestionCard payloads', (
      tester,
    ) async {
      final catalog = buildRevisionActivityCatalog();

      await tester.pumpWidget(
        MaterialApp(
          home: catalogWidget(
            catalog,
            type: 'McqQuestionCard',
            data: {
              ...mcqQuestionPayload(),
              'correctChoiceId': 'choice-a',
              'explanation': 'Explication qui ne doit pas fuiter.',
            },
          ),
        ),
      );

      expect(find.text('Composant GenUI indisponible'), findsOneWidget);
      expect(find.text('choice-a'), findsNothing);
      expect(find.text('Explication qui ne doit pas fuiter.'), findsNothing);
      expect(find.text('Quelle conséquence découle de cette règle ?'), findsNothing);
    });

    testWidgets('renders sourced reading components with bounded payloads', (
      tester,
    ) async {
      final catalog = buildRevisionActivityCatalog();

      await tester.pumpWidget(
        MaterialApp(
          home: Column(
            children: [
              catalogWidget(
                catalog,
                type: 'SummaryCard',
                data: {
                  'title': 'Résumé',
                  'content': 'Contenu synthétique.',
                  'keyPoints': ['Point 1'],
                  'sources': [
                    {'text': 'Extrait source.', 'pageNumber': null, 'index': 0},
                  ],
                },
              ),
              catalogWidget(
                catalog,
                type: 'KeyPointsList',
                data: {
                  'title': 'Points clés',
                  'items': ['Point A'],
                },
              ),
              catalogWidget(
                catalog,
                type: 'SourceExcerptCard',
                data: {
                  'text': 'Source isolée.',
                  'pageNumber': 2,
                  'index': 1,
                  'label': 'Cours',
                },
              ),
            ],
          ),
        ),
      );

      expect(find.text('Résumé'), findsOneWidget);
      expect(find.text('Contenu synthétique.'), findsOneWidget);
      expect(find.text('Point 1'), findsOneWidget);
      expect(find.text('Extrait source.'), findsOneWidget);
      expect(find.text('Points clés'), findsOneWidget);
      expect(find.text('Point A'), findsOneWidget);
      expect(find.text('Source isolée.'), findsOneWidget);
    });

    testWidgets('renders a genUI badge on catalog-rendered components', (
      tester,
    ) async {
      final catalog = buildRevisionActivityCatalog();

      await tester.pumpWidget(
        MaterialApp(
          home: SingleChildScrollView(
            child: Column(
              children: [
                catalogWidget(
                  catalog,
                  type: 'QuestionCard',
                  data: {'prompt': 'Quelle est la bonne réponse ?'},
                ),
                catalogWidget(
                  catalog,
                  type: 'SummaryCard',
                  data: {
                    'title': 'Résumé',
                    'content': 'Contenu synthétique.',
                    'keyPoints': ['Point 1'],
                  },
                ),
                catalogWidget(
                  catalog,
                  type: 'KeyPointsList',
                  data: {
                    'title': 'Points clés',
                    'items': ['Point A'],
                  },
                ),
                catalogWidget(
                  catalog,
                  type: 'SourceExcerptCard',
                  data: {
                    'text': 'Source isolée.',
                    'pageNumber': null,
                    'index': 1,
                  },
                ),
                catalogWidget(
                  catalog,
                  type: 'McqQuestionCard',
                  data: mcqQuestionPayload(),
                ),
                catalogWidget(
                  catalog,
                  type: 'McqCorrectionPanel',
                  data: mcqCorrectionPayload(),
                ),
                catalogWidget(
                  catalog,
                  type: 'ActivityResultCard',
                  data: {
                    'title': 'Résultat',
                    'status': 'completed',
                    'correctAnswers': 1,
                    'totalQuestions': 2,
                  },
                ),
                catalogWidget(
                  catalog,
                  type: 'QuestionChartCard',
                  data: chartPayload(),
                ),
                catalogWidget(
                  catalog,
                  type: 'QuestionDiagramCard',
                  data: diagramPayload(),
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('genUI'), findsNWidgets(9));
    });
  });
}

Widget catalogWidget(
  Catalog catalog, {
  required String type,
  required Map<String, Object?> data,
}) {
  final item = catalog.items.firstWhere((item) => item.name == type);
  return Builder(
    builder: (context) {
      return item.widgetBuilder(
        CatalogItemContext(
          data: data,
          id: type,
          type: type,
          buildChild: (id, [dataContext]) => const SizedBox.shrink(),
          dispatchEvent: (_) {},
          buildContext: context,
          dataContext: DataContext(InMemoryDataModel(), DataPath.root),
          getComponent: (_) => null,
          getCatalogItem: (_) => null,
          surfaceId: 'test-surface',
          reportError: (error, stack) {},
        ),
      );
    },
  );
}

Map<String, Object?> mcqQuestionPayload() {
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
  };
}

Map<String, Object?> mcqCorrectionPayload() {
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

Map<String, Object?> chartPayload() {
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

Map<String, Object?> diagramPayload() {
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
