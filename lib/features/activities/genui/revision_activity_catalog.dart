import 'package:flutter/material.dart';
import 'package:genui/genui.dart';
import 'package:json_schema_builder/json_schema_builder.dart';

const revisionActivityCatalogId = 'com.revision.activity_catalog';

const _revisionActivityCatalogRules =
    'Use QuestionCard for diagnostic quiz question prompts before rendering '
    'the available answer choices with basic catalog widgets.';

Catalog buildRevisionActivityCatalog() {
  final questionCardSchema = S.object(
    properties: {'prompt': S.string(description: 'The quiz question prompt.')},
    required: ['prompt'],
  );

  final questionCard = CatalogItem(
    name: 'QuestionCard',
    dataSchema: questionCardSchema,
    widgetBuilder: (itemContext) {
      final json = itemContext.data as JsonMap;
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            json['prompt'] as String,
            style: Theme.of(itemContext.buildContext).textTheme.titleMedium,
          ),
        ),
      );
    },
  );

  return BasicCatalogItems.asNoAssetCatalog(
    systemPromptFragments: const [_revisionActivityCatalogRules],
  ).copyWith(newItems: [questionCard], catalogId: revisionActivityCatalogId);
}
