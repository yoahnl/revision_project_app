import 'package:flutter_test/flutter_test.dart';
import 'package:revision_app/features/activities/genui/revision_activity_catalog.dart';

void main() {
  group('buildRevisionActivityCatalog', () {
    test('combines activity widgets with the no-asset basic catalog', () {
      final catalog = buildRevisionActivityCatalog();

      expect(catalog.catalogId, revisionActivityCatalogId);

      final itemNames = catalog.items.map((item) => item.name).toSet();
      expect(itemNames, contains('QuestionCard'));
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

      final questionCard = components['QuestionCard'] as Map<String, Object?>;
      expect(questionCard['required'], containsAll(['component', 'prompt']));

      final properties = questionCard['properties'] as Map<String, Object?>;
      expect(properties, contains('prompt'));
    });
  });
}
