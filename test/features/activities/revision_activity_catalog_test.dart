import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genui/genui.dart';
import 'package:revision_app/features/activities/genui/revision_activity_catalog.dart';

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
          home: Column(
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
            ],
          ),
        ),
      );

      expect(find.text('genUI'), findsNWidgets(4));
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
