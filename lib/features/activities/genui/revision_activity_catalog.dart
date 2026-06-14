import 'package:flutter/material.dart';
import 'package:genui/genui.dart';
import 'package:json_schema_builder/json_schema_builder.dart';
import 'package:revision_app/features/activities/genui/activity_correction_component_validator.dart';
import 'package:revision_app/features/activities/genui/sourced_reading_component_validator.dart';
import 'package:revision_app/presentation/theme/app_colors.dart';
import 'package:revision_app/presentation/theme/app_radius.dart';
import 'package:revision_app/presentation/theme/app_spacing.dart';
import 'package:revision_app/presentation/widgets/documents/document_source_excerpt.dart';
import 'package:revision_app/presentation/widgets/revision_choice_tile.dart';
import 'package:revision_app/presentation/widgets/revision_message.dart';
import 'package:revision_app/presentation/widgets/revision_panel.dart';
import 'package:revision_app/presentation/widgets/revision_status_pill.dart';

const revisionActivityCatalogId = 'com.revision.activity_catalog';

const _revisionActivityCatalogRules =
    'Use McqQuestionCard only for pre-submit MCQ rendering without correction '
    'fields. Use McqCorrectionPanel and ActivityResultCard only for '
    'post-submit correction and result data already computed by the backend. '
    'Use QuestionChartCard and QuestionDiagramCard only for bounded validated '
    'question visuals. Use SummaryCard, KeyPointsList and SourceExcerptCard '
    'only for bounded sourced reading content. Do not invent sources, do not '
    'render arbitrary widgets, HTML, SVG, Mermaid or JavaScript.';

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
      return _GenUiComponentFrame(
        child: RevisionPanel(
          child: Text(
            json['prompt'] as String,
            style: Theme.of(itemContext.buildContext).textTheme.titleMedium,
          ),
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

      return _GenUiComponentFrame(
        child: RevisionPanel(
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
      return _GenUiComponentFrame(
        child: RevisionPanel(
          child: _CatalogTextList(
            title: json['title'] as String,
            items: _stringList(json['items']),
          ),
        ),
      );
    },
  );

  final sourceExcerptCard = CatalogItem(
    name: 'SourceExcerptCard',
    dataSchema: sourceSchema,
    widgetBuilder: (itemContext) {
      final source = _CatalogSource.fromJson(itemContext.data as JsonMap);
      return _GenUiComponentFrame(
        child: DocumentSourceExcerpt(
          text: source.text,
          index: source.index,
          pageNumber: source.pageNumber,
          label: source.label,
        ),
      );
    },
  );

  final mcqQuestionCard = CatalogItem(
    name: 'McqQuestionCard',
    dataSchema: _mcqQuestionSchema(),
    widgetBuilder: (itemContext) {
      final json = _jsonMap(itemContext.data);
      if (json == null || !isMcqQuestionCardPayloadSafe(json)) {
        return _safeUnavailableComponent(itemContext.buildContext);
      }
      return _GenUiComponentFrame(child: _McqQuestionCard(payload: json));
    },
  );

  final mcqCorrectionPanel = CatalogItem(
    name: 'McqCorrectionPanel',
    dataSchema: _mcqCorrectionSchema(),
    widgetBuilder: (itemContext) {
      final json = _jsonMap(itemContext.data);
      if (json == null || !isMcqCorrectionPanelPayloadSafe(json)) {
        return _safeUnavailableComponent(itemContext.buildContext);
      }
      return _GenUiComponentFrame(child: _McqCorrectionPanel(payload: json));
    },
  );

  final activityResultCard = CatalogItem(
    name: 'ActivityResultCard',
    dataSchema: _activityResultSchema(),
    widgetBuilder: (itemContext) {
      final json = _jsonMap(itemContext.data);
      if (json == null || !isActivityResultCardPayloadSafe(json)) {
        return _safeUnavailableComponent(itemContext.buildContext);
      }
      return _GenUiComponentFrame(child: _ActivityResultCard(payload: json));
    },
  );

  final questionChartCard = CatalogItem(
    name: 'QuestionChartCard',
    dataSchema: _questionChartSchema(),
    widgetBuilder: (itemContext) {
      final json = _jsonMap(itemContext.data);
      if (json == null || !isQuestionChartCardPayloadSafe(json)) {
        return _safeUnavailableComponent(itemContext.buildContext);
      }
      return _GenUiComponentFrame(child: _QuestionChartCard(payload: json));
    },
  );

  final questionDiagramCard = CatalogItem(
    name: 'QuestionDiagramCard',
    dataSchema: _questionDiagramSchema(),
    widgetBuilder: (itemContext) {
      final json = _jsonMap(itemContext.data);
      if (json == null || !isQuestionDiagramCardPayloadSafe(json)) {
        return _safeUnavailableComponent(itemContext.buildContext);
      }
      return _GenUiComponentFrame(child: _QuestionDiagramCard(payload: json));
    },
  );

  return BasicCatalogItems.asNoAssetCatalog(
    systemPromptFragments: const [_revisionActivityCatalogRules],
  ).copyWith(
    newItems: [
      questionCard,
      summaryCard,
      keyPointsList,
      sourceExcerptCard,
      mcqQuestionCard,
      mcqCorrectionPanel,
      activityResultCard,
      questionChartCard,
      questionDiagramCard,
    ],
    catalogId: revisionActivityCatalogId,
  );
}

Schema _mcqQuestionSchema() {
  return S.object(
    properties: {
      'questionId': S.string(minLength: 1),
      'displayOrder': S.integer(minimum: 1),
      'totalQuestions': S.integer(minimum: 1),
      'prompt': S.string(maxLength: maxActivityComponentPromptLength),
      'difficulty': S.string(enumValues: ['LOW', 'MEDIUM', 'HIGH']),
      'selectionMode': S.string(enumValues: ['single', 'multiple']),
      'minSelections': S.integer(minimum: 1),
      'maxSelections': S.integer(minimum: 1),
      'choices': S.list(items: S.any(), minItems: 2, maxItems: maxActivityChoices),
      'selectedChoiceId': S.string(minLength: 1),
      'selectedChoiceIds': S.list(items: S.string(minLength: 1)),
      'sources': S.list(items: S.any(), maxItems: maxActivitySources),
      'visuals': S.list(items: S.any(), maxItems: maxQuestionVisuals),
    },
    required: [
      'questionId',
      'displayOrder',
      'totalQuestions',
      'prompt',
      'selectionMode',
      'choices',
    ],
    additionalProperties: false,
  );
}

Schema _mcqCorrectionSchema() {
  return S.object(
    properties: {
      'questionId': S.string(minLength: 1),
      'knowledgeUnitId': S.string(minLength: 1),
      'prompt': S.string(maxLength: maxActivityComponentPromptLength),
      'selectionMode': S.string(enumValues: ['single', 'multiple']),
      'choices': S.list(items: S.any(), minItems: 2, maxItems: maxActivityChoices),
      'selectedChoiceId': S.string(minLength: 1),
      'correctChoiceId': S.string(minLength: 1),
      'selectedChoiceIds': S.list(items: S.string(minLength: 1)),
      'correctChoiceIds': S.list(items: S.string(minLength: 1)),
      'isCorrect': S.boolean(),
      'partialScore': S.number(minimum: 0, maximum: 1),
      'explanation': S.string(maxLength: maxActivityExplanationLength),
      'choiceFeedback': S.list(items: S.any(), maxItems: maxActivityFeedbackItems),
      'sources': S.list(items: S.any(), maxItems: maxActivitySources),
    },
    required: [
      'questionId',
      'prompt',
      'selectionMode',
      'choices',
      'isCorrect',
      'explanation',
    ],
    additionalProperties: false,
  );
}

Schema _activityResultSchema() {
  return S.object(
    properties: {
      'title': S.string(maxLength: maxActivityComponentTitleLength),
      'status': S.string(maxLength: maxActivityComponentTitleLength),
      'correctAnswers': S.integer(minimum: 0),
      'totalQuestions': S.integer(minimum: 1),
      'score': S.number(minimum: 0, maximum: 1),
      'partialScore': S.number(minimum: 0, maximum: 1),
      'message': S.string(maxLength: maxActivityComponentDescriptionLength),
      'primaryActionLabel': S.string(maxLength: maxActivityComponentActionLabelLength),
      'secondaryActionLabel': S.string(maxLength: maxActivityComponentActionLabelLength),
    },
    required: ['title', 'status', 'correctAnswers', 'totalQuestions'],
    additionalProperties: false,
  );
}

Schema _questionChartSchema() {
  return S.object(
    properties: {
      'visualId': S.string(minLength: 1),
      'chartType': S.string(enumValues: ['bar', 'line', 'pie', 'scatter']),
      'title': S.string(maxLength: maxActivityComponentTitleLength),
      'description': S.string(maxLength: maxActivityComponentDescriptionLength),
      'data': S.list(items: S.any(), minItems: 1, maxItems: maxQuestionChartRows),
      'xKey': S.string(maxLength: maxQuestionChartKeyLength),
      'yKeys': S.list(
        items: S.string(maxLength: maxQuestionChartKeyLength),
        maxItems: maxQuestionChartColumns,
      ),
      'sources': S.list(items: S.any(), maxItems: maxActivitySources),
    },
    required: ['visualId', 'chartType', 'title', 'data', 'sources'],
    additionalProperties: false,
  );
}

Schema _questionDiagramSchema() {
  return S.object(
    properties: {
      'visualId': S.string(minLength: 1),
      'title': S.string(maxLength: maxActivityComponentTitleLength),
      'description': S.string(maxLength: maxActivityComponentDescriptionLength),
      'nodes': S.list(items: S.any(), minItems: 1, maxItems: maxQuestionDiagramNodes),
      'edges': S.list(items: S.any(), maxItems: maxQuestionDiagramEdges),
      'sources': S.list(items: S.any(), maxItems: maxActivitySources),
    },
    required: ['visualId', 'title', 'nodes', 'sources'],
    additionalProperties: false,
  );
}

Widget _safeUnavailableComponent(BuildContext context) {
  return _GenUiComponentFrame(
    child: RevisionMessage(
      message: 'Composant GenUI indisponible',
      color: Theme.of(context).colorScheme.error,
      icon: Icons.warning_amber_rounded,
    ),
  );
}

class _McqQuestionCard extends StatelessWidget {
  const _McqQuestionCard({required this.payload});

  final JsonMap payload;

  @override
  Widget build(BuildContext context) {
    final choices = _choiceList(payload['choices']);
    final selectedIds = _selectedIds(payload);
    final visuals = _visualList(payload['visuals']);
    final selectionMode = payload['selectionMode'] as String;
    final displayOrder = payload['displayOrder'] as int;
    final totalQuestions = payload['totalQuestions'] as int;

    return RevisionPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: AppSpacing.s,
            runSpacing: AppSpacing.xs,
            children: [
              RevisionStatusPill(
                label: 'Question $displayOrder / $totalQuestions',
                color: Theme.of(context).colorScheme.primary,
              ),
              if (payload['difficulty'] case final String difficulty)
                RevisionStatusPill(
                  label: difficulty,
                  color: AppColors.amber,
                ),
              RevisionStatusPill(
                label: selectionMode == 'multiple'
                    ? 'Plusieurs réponses possibles'
                    : 'Une seule réponse',
                color: AppColors.primary,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.m),
          Text(
            payload['prompt'] as String,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          if (visuals.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.m),
            Column(spacing: AppSpacing.s, children: visuals),
          ],
          const SizedBox(height: AppSpacing.m),
          Text(
            'Sources disponibles après correction',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: AppSpacing.m),
          Column(
            spacing: AppSpacing.s,
            children: [
              for (final choice in choices)
                RevisionChoiceTile(
                  label: choice.label,
                  selected: selectedIds.contains(choice.id),
                  enabled: false,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _McqCorrectionPanel extends StatelessWidget {
  const _McqCorrectionPanel({required this.payload});

  final JsonMap payload;

  @override
  Widget build(BuildContext context) {
    final choices = _choiceList(payload['choices']);
    final selectedIds = _selectedCorrectionIds(payload);
    final correctIds = _correctCorrectionIds(payload);
    final isCorrect = payload['isCorrect'] as bool;
    final feedback = _feedbackList(payload['choiceFeedback']);
    final sources = _sourceList(payload['sources']);

    return RevisionPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: AppSpacing.s,
            runSpacing: AppSpacing.xs,
            children: [
              RevisionStatusPill(
                label: isCorrect ? 'Correct' : 'À revoir',
                color: isCorrect ? AppColors.primary : AppColors.coral,
              ),
              if (payload['partialScore'] case final num partialScore)
                RevisionStatusPill(
                  label: '${(partialScore * 100).round()} %',
                  color: Theme.of(context).colorScheme.primary,
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.m),
          Text(
            payload['prompt'] as String,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.m),
          _AnswerSummary(
            title: 'Réponse sélectionnée',
            labels: _labelsForIds(choices, selectedIds),
          ),
          const SizedBox(height: AppSpacing.s),
          _AnswerSummary(
            title: 'Réponse attendue',
            labels: _labelsForIds(choices, correctIds),
          ),
          const SizedBox(height: AppSpacing.m),
          Text(payload['explanation'] as String),
          if (feedback.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.m),
            _CatalogTextList(title: 'Feedback', items: feedback),
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
  }
}

class _ActivityResultCard extends StatelessWidget {
  const _ActivityResultCard({required this.payload});

  final JsonMap payload;

  @override
  Widget build(BuildContext context) {
    final score = payload['score'];
    return RevisionPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            payload['title'] as String,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.m),
          Wrap(
            spacing: AppSpacing.s,
            runSpacing: AppSpacing.xs,
            children: [
              RevisionStatusPill(
                label:
                    '${payload['correctAnswers']} / ${payload['totalQuestions']}',
                color: Theme.of(context).colorScheme.primary,
              ),
              RevisionStatusPill(
                label: payload['status'] as String,
                color: AppColors.primary,
              ),
              if (score is num)
                RevisionStatusPill(
                  label: '${(score * 100).round()} %',
                  color: AppColors.amber,
                ),
            ],
          ),
          if (payload['message'] case final String message) ...[
            const SizedBox(height: AppSpacing.m),
            Text(message),
          ],
        ],
      ),
    );
  }
}

class _QuestionChartCard extends StatelessWidget {
  const _QuestionChartCard({required this.payload});

  final JsonMap payload;

  @override
  Widget build(BuildContext context) {
    final rows = _chartRows(payload['data']);
    return RevisionPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: AppSpacing.s,
            runSpacing: AppSpacing.xs,
            children: [
              RevisionStatusPill(
                label: payload['chartType'] as String,
                color: Theme.of(context).colorScheme.primary,
              ),
              RevisionStatusPill(label: 'Graphique', color: AppColors.primary),
            ],
          ),
          const SizedBox(height: AppSpacing.m),
          Text(
            payload['title'] as String,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          if (payload['description'] case final String description) ...[
            const SizedBox(height: AppSpacing.s),
            Text(description),
          ],
          const SizedBox(height: AppSpacing.m),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: AppSpacing.xs,
            children: [for (final row in rows) Text(row)],
          ),
        ],
      ),
    );
  }
}

class _QuestionDiagramCard extends StatelessWidget {
  const _QuestionDiagramCard({required this.payload});

  final JsonMap payload;

  @override
  Widget build(BuildContext context) {
    final nodes = _diagramNodes(payload['nodes']);
    final edges = _diagramEdges(payload['edges']);
    return RevisionPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RevisionStatusPill(label: 'Diagramme', color: AppColors.primary),
          const SizedBox(height: AppSpacing.m),
          Text(
            payload['title'] as String,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          if (payload['description'] case final String description) ...[
            const SizedBox(height: AppSpacing.s),
            Text(description),
          ],
          const SizedBox(height: AppSpacing.m),
          _CatalogTextList(title: 'Étapes', items: nodes),
          if (edges.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.m),
            _CatalogTextList(title: 'Relations', items: edges),
          ],
        ],
      ),
    );
  }
}

class _AnswerSummary extends StatelessWidget {
  const _AnswerSummary({required this.title, required this.labels});

  final String title;
  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: AppSpacing.xs),
        for (final label in labels) Text(label),
      ],
    );
  }
}

class _GenUiComponentFrame extends StatelessWidget {
  const _GenUiComponentFrame({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Align(alignment: Alignment.centerRight, child: _GenUiBadge()),
        const SizedBox(height: AppSpacing.xs),
        child,
      ],
    );
  }
}

class _GenUiBadge extends StatelessWidget {
  const _GenUiBadge();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.violet.withValues(alpha: 0.14),
        borderRadius: AppRadius.radiusPill,
        border: Border.all(color: AppColors.violet.withValues(alpha: 0.34)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s,
          vertical: AppSpacing.xs,
        ),
        child: Text(
          'genUI',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: AppColors.violet,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
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

class _CatalogChoice {
  const _CatalogChoice({required this.id, required this.label});

  final String id;
  final String label;

  factory _CatalogChoice.fromJson(JsonMap json) {
    return _CatalogChoice(
      id: json['id'] as String,
      label: json['label'] as String,
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
      .map(_jsonMap)
      .whereType<JsonMap>()
      .map(_CatalogSource.fromJson)
      .toList(growable: false);
}

List<_CatalogChoice> _choiceList(Object? value) {
  if (value is! List) {
    return const [];
  }

  return value
      .map(_jsonMap)
      .whereType<JsonMap>()
      .map(_CatalogChoice.fromJson)
      .toList(growable: false);
}

List<String> _selectedIds(JsonMap payload) {
  if (payload['selectedChoiceId'] case final String id) {
    return [id];
  }

  return _stringList(payload['selectedChoiceIds']);
}

List<String> _selectedCorrectionIds(JsonMap payload) {
  if (payload['selectedChoiceId'] case final String id) {
    return [id];
  }

  return _stringList(payload['selectedChoiceIds']);
}

List<String> _correctCorrectionIds(JsonMap payload) {
  if (payload['correctChoiceId'] case final String id) {
    return [id];
  }

  return _stringList(payload['correctChoiceIds']);
}

List<String> _labelsForIds(List<_CatalogChoice> choices, List<String> ids) {
  final labelsById = {for (final choice in choices) choice.id: choice.label};
  return [
    for (final id in ids)
      if (labelsById[id] case final String label) label,
  ];
}

List<String> _feedbackList(Object? value) {
  if (value is! List) {
    return const [];
  }

  return value
      .map(_jsonMap)
      .whereType<JsonMap>()
      .map((payload) => payload['feedback'])
      .whereType<String>()
      .toList(growable: false);
}

List<Widget> _visualList(Object? value) {
  if (value is! List) {
    return const [];
  }

  return value
      .map(_jsonMap)
      .whereType<JsonMap>()
      .map((payload) {
        if (isQuestionChartCardPayloadSafe(payload)) {
          return _QuestionChartCard(payload: payload);
        }
        if (isQuestionDiagramCardPayloadSafe(payload)) {
          return _QuestionDiagramCard(payload: payload);
        }
        return null;
      })
      .whereType<Widget>()
      .toList(growable: false);
}

List<String> _chartRows(Object? value) {
  if (value is! List) {
    return const [];
  }

  return value.map(_jsonMap).whereType<JsonMap>().map((row) {
    return row.entries.map((entry) => '${entry.key}: ${entry.value}').join(' · ');
  }).toList(growable: false);
}

List<String> _diagramNodes(Object? value) {
  if (value is! List) {
    return const [];
  }

  return value
      .map(_jsonMap)
      .whereType<JsonMap>()
      .map((node) => node['label'])
      .whereType<String>()
      .toList(growable: false);
}

List<String> _diagramEdges(Object? value) {
  if (value is! List) {
    return const [];
  }

  return value
      .map(_jsonMap)
      .whereType<JsonMap>()
      .map((edge) {
        final from = edge['from'];
        final to = edge['to'];
        if (from is! String || to is! String) {
          return null;
        }
        return '$from → $to';
      })
      .whereType<String>()
      .toList(growable: false);
}

JsonMap? _jsonMap(Object? value) {
  if (value is! Map) {
    return null;
  }

  final result = <String, Object?>{};
  for (final entry in value.entries) {
    final key = entry.key;
    if (key is! String) {
      return null;
    }
    result[key] = entry.value;
  }

  return result;
}
