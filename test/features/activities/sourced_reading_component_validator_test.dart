import 'package:flutter_test/flutter_test.dart';
import 'package:Neralune/features/activities/genui/sourced_reading_component_validator.dart';

void main() {
  test('accepts valid summary card payloads', () {
    expect(
      isSummaryCardPayloadSafe({
        'title': 'Résumé',
        'content': 'Contenu',
        'keyPoints': ['Point'],
        'sources': [
          {'text': 'Source', 'pageNumber': null, 'index': 0},
        ],
      }),
      isTrue,
    );
  });

  test('rejects summary card unknown fields and empty sources', () {
    expect(
      isSummaryCardPayloadSafe({
        'title': 'Résumé',
        'content': 'Contenu',
        'keyPoints': ['Point'],
        'extra': true,
      }),
      isFalse,
    );
    expect(
      isSummaryCardPayloadSafe({
        'title': 'Résumé',
        'content': 'Contenu',
        'keyPoints': ['Point'],
        'sources': [
          {'text': ' ', 'index': 0},
        ],
      }),
      isFalse,
    );
  });

  test('accepts and rejects key points list payloads', () {
    expect(
      isKeyPointsListPayloadSafe({
        'title': 'Points clés',
        'items': ['Point'],
      }),
      isTrue,
    );
    expect(
      isKeyPointsListPayloadSafe({
        'title': 'Points clés',
        'items': List.filled(maxSourcedReadingItems + 1, 'Point'),
      }),
      isFalse,
    );
  });

  test('accepts and rejects source excerpt payloads', () {
    expect(
      isSourceExcerptCardPayloadSafe({
        'text': 'Source',
        'pageNumber': 1,
        'index': 0,
        'label': 'Cours',
      }),
      isTrue,
    );
    expect(
      isSourceExcerptCardPayloadSafe({'text': 'Source', 'index': -1}),
      isFalse,
    );
  });

  test('rejects unknown components', () {
    expect(
      isSourcedReadingComponentPayloadSafe('UnknownCard', {'title': 'Rien'}),
      isFalse,
    );
  });
}
