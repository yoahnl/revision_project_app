import 'package:flutter/material.dart';
import 'package:genui/genui.dart';
import 'package:json_schema_builder/json_schema_builder.dart';
import 'package:revision_app/features/activities/genui/sourced_reading_component_validator.dart';
import 'package:revision_app/presentation/theme/app_spacing.dart';
import 'package:revision_app/presentation/widgets/documents/document_source_excerpt.dart';
import 'package:revision_app/presentation/widgets/revision_panel.dart';

const revisionActivityCatalogId = 'com.revision.activity_catalog';

const _revisionActivityCatalogRules =
    'Use QuestionCard for diagnostic quiz question prompts before rendering '
    'the available answer choices with basic catalog widgets. Use SummaryCard, '
    'KeyPointsList and SourceExcerptCard only for bounded sourced reading '
    'content. Do not invent sources and do not render arbitrary widgets.';

Catalog buildRevisionActivityCatalog() {
  final questionCardSchema = S.object(
    properties: {'prompt': S.string(description: 'The quiz question prompt.')},
    required: ['prompt'],
    additionalProperties: false,
  );

  final questionCard = CatalogItem(
    name: 'QuestionCard',
    dataSchema: questionCardSchema,
    widgetBuilder: (itemContext) {
      final json = itemContext.data as JsonMap;
      return RevisionPanel(
        child: Text(
          json['prompt'] as String,
          style: Theme.of(itemContext.buildContext).textTheme.titleMedium,
        ),
      );
    },
  );

  final sourceSchema = S.object(
    properties: {
      'text': S.string(
        minLength: 1,
        maxLength: maxSourcedReadingSourceTextLength,
      ),
      'pageNumber': S.any(),
      'index': S.integer(minimum: 0),
      'label': S.string(maxLength: maxSourcedReadingSourceLabelLength),
    },
    required: ['text', 'index'],
    additionalProperties: false,
  );

  final summaryCard = CatalogItem(
    name: 'SummaryCard',
    dataSchema: S.object(
      properties: {
        'title': S.string(
          minLength: 1,
          maxLength: maxSourcedReadingTitleLength,
        ),
        'content': S.string(
          minLength: 1,
          maxLength: maxSourcedReadingContentLength,
        ),
        'keyPoints': S.list(
          items: S.string(maxLength: maxSourcedReadingItemLength),
          minItems: 1,
          maxItems: maxSourcedReadingItems,
        ),
        'sources': S.list(
          items: sourceSchema,
          maxItems: maxSourcedReadingSources,
        ),
      },
      required: ['title', 'content', 'keyPoints'],
      additionalProperties: false,
    ),
    widgetBuilder: (itemContext) {
      final json = itemContext.data as JsonMap;
      final keyPoints = _stringList(json['keyPoints']);
      final sources = _sourceList(json['sources']);

      return RevisionPanel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              json['title'] as String,
              style: Theme.of(itemContext.buildContext).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.s),
            Text(json['content'] as String),
            if (keyPoints.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.m),
              _CatalogTextList(title: 'Points cles', items: keyPoints),
            ],
            if (sources.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.m),
              Column(
                spacing: AppSpacing.s,
                children: [
                  for (final source in sources)
                    DocumentSourceExcerpt(
                      text: source.text,
                      index: source.index,
                      pageNumber: source.pageNumber,
                      label: source.label,
                    ),
                ],
              ),
            ],
          ],
        ),
      );
    },
  );

  final keyPointsList = CatalogItem(
    name: 'KeyPointsList',
    dataSchema: S.object(
      properties: {
        'title': S.string(
          minLength: 1,
          maxLength: maxSourcedReadingTitleLength,
        ),
        'items': S.list(
          items: S.string(maxLength: maxSourcedReadingItemLength),
          minItems: 1,
          maxItems: maxSourcedReadingItems,
        ),
      },
      required: ['title', 'items'],
      additionalProperties: false,
    ),
    widgetBuilder: (itemContext) {
      final json = itemContext.data as JsonMap;
      return RevisionPanel(
        child: _CatalogTextList(
          title: json['title'] as String,
          items: _stringList(json['items']),
        ),
      );
    },
  );

  final sourceExcerptCard = CatalogItem(
    name: 'SourceExcerptCard',
    dataSchema: sourceSchema,
    widgetBuilder: (itemContext) {
      final source = _CatalogSource.fromJson(itemContext.data as JsonMap);
      return DocumentSourceExcerpt(
        text: source.text,
        index: source.index,
        pageNumber: source.pageNumber,
        label: source.label,
      );
    },
  );

  return BasicCatalogItems.asNoAssetCatalog(
    systemPromptFragments: const [_revisionActivityCatalogRules],
  ).copyWith(
    newItems: [questionCard, summaryCard, keyPointsList, sourceExcerptCard],
    catalogId: revisionActivityCatalogId,
  );
}

class _CatalogTextList extends StatelessWidget {
  const _CatalogTextList({required this.title, required this.items});

  final String title;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: AppSpacing.s),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: AppSpacing.xs,
          children: [
            for (final item in items)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• '),
                  Expanded(child: Text(item)),
                ],
              ),
          ],
        ),
      ],
    );
  }
}

class _CatalogSource {
  const _CatalogSource({
    required this.text,
    required this.index,
    required this.pageNumber,
    required this.label,
  });

  final String text;
  final int index;
  final int? pageNumber;
  final String? label;

  factory _CatalogSource.fromJson(JsonMap json) {
    final pageNumber = json['pageNumber'];
    return _CatalogSource(
      text: json['text'] as String,
      index: json['index'] as int,
      pageNumber: pageNumber is int ? pageNumber : null,
      label: json['label'] as String?,
    );
  }
}

List<String> _stringList(Object? value) {
  if (value is! List) {
    return const [];
  }

  return value.whereType<String>().toList(growable: false);
}

List<_CatalogSource> _sourceList(Object? value) {
  if (value is! List) {
    return const [];
  }

  return value
      .whereType<JsonMap>()
      .map(_CatalogSource.fromJson)
      .toList(growable: false);
}
