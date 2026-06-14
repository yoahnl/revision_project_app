const int maxActivityComponentTitleLength = 120;
const int maxActivityComponentPromptLength = 600;
const int maxActivityComponentDescriptionLength = 600;
const int maxActivityChoiceLabelLength = 180;
const int maxActivityChoices = 6;
const int maxActivitySources = 4;
const int maxActivitySourceTextLength = 520;
const int maxActivityExplanationLength = 1200;
const int maxActivityFeedbackLength = 600;
const int maxActivityFeedbackItems = 8;
const int maxActivityComponentActionLabelLength = 80;
const int maxQuestionVisuals = 2;
const int maxQuestionChartRows = 12;
const int maxQuestionChartColumns = 8;
const int maxQuestionChartKeyLength = 32;
const int maxQuestionChartValueLength = 120;
const int maxQuestionDiagramNodes = 12;
const int maxQuestionDiagramEdges = 20;

bool isActivityCorrectionComponentPayloadSafe(
  String component,
  Map<String, Object?> payload,
) {
  return switch (component) {
    'McqQuestionCard' => isMcqQuestionCardPayloadSafe(payload),
    'McqCorrectionPanel' => isMcqCorrectionPanelPayloadSafe(payload),
    'ActivityResultCard' => isActivityResultCardPayloadSafe(payload),
    'QuestionChartCard' => isQuestionChartCardPayloadSafe(payload),
    'QuestionDiagramCard' => isQuestionDiagramCardPayloadSafe(payload),
    _ => false,
  };
}

bool isMcqQuestionCardPayloadSafe(Map<String, Object?> payload) {
  if (!_hasOnlyKeys(payload, {
        'questionId',
        'displayOrder',
        'totalQuestions',
        'prompt',
        'difficulty',
        'selectionMode',
        'minSelections',
        'maxSelections',
        'choices',
        'selectedChoiceId',
        'selectedChoiceIds',
        'sources',
        'visuals',
      }) ||
      payload.containsKey('correctChoiceId') ||
      payload.containsKey('correctChoiceIds') ||
      payload.containsKey('isCorrect') ||
      payload.containsKey('explanation') ||
      payload.containsKey('feedback') ||
      payload.containsKey('choiceFeedback') ||
      payload.containsKey('partialScore')) {
    return false;
  }

  final displayOrder = payload['displayOrder'];
  final totalQuestions = payload['totalQuestions'];
  final selectionMode = payload['selectionMode'];
  final choiceIds = _choiceIds(payload['choices']);

  if (!_plainString(payload['questionId']) ||
      !_boundedString(payload['prompt'], maxActivityComponentPromptLength) ||
      displayOrder is! int ||
      displayOrder < 1 ||
      totalQuestions is! int ||
      totalQuestions < displayOrder ||
      !_difficultySafe(payload['difficulty']) ||
      !_selectionModeSafe(selectionMode) ||
      choiceIds == null) {
    return false;
  }

  if (!_selectionBoundsSafe(
    selectionMode,
    payload['minSelections'],
    payload['maxSelections'],
    choiceIds.length,
  )) {
    return false;
  }

  if (!_selectedChoicesSafe(
    selectionMode,
    payload['selectedChoiceId'],
    payload['selectedChoiceIds'],
    choiceIds,
  )) {
    return false;
  }

  final sources = payload['sources'];
  if (sources != null && !_sourceRefListSafe(sources, allowText: false)) {
    return false;
  }

  final visuals = payload['visuals'];
  if (visuals != null && !_visualListSafe(visuals)) {
    return false;
  }

  return true;
}

bool isMcqCorrectionPanelPayloadSafe(Map<String, Object?> payload) {
  if (!_hasOnlyKeys(payload, {
    'questionId',
    'knowledgeUnitId',
    'prompt',
    'selectionMode',
    'choices',
    'selectedChoiceId',
    'correctChoiceId',
    'selectedChoiceIds',
    'correctChoiceIds',
    'isCorrect',
    'partialScore',
    'explanation',
    'choiceFeedback',
    'sources',
  })) {
    return false;
  }

  final selectionMode = payload['selectionMode'];
  final choiceIds = _choiceIds(payload['choices']);

  if (!_plainString(payload['questionId']) ||
      !_optionalPlainString(payload['knowledgeUnitId']) ||
      !_boundedString(payload['prompt'], maxActivityComponentPromptLength) ||
      !_selectionModeSafe(selectionMode) ||
      choiceIds == null ||
      payload['isCorrect'] is! bool ||
      !_numberInRange(payload['partialScore'], min: 0, max: 1, optional: true) ||
      !_boundedString(
        payload['explanation'],
        maxActivityExplanationLength,
      )) {
    return false;
  }

  if (!_correctionChoicesSafe(
    selectionMode,
    payload['selectedChoiceId'],
    payload['correctChoiceId'],
    payload['selectedChoiceIds'],
    payload['correctChoiceIds'],
    choiceIds,
  )) {
    return false;
  }

  final choiceFeedback = payload['choiceFeedback'];
  if (choiceFeedback != null &&
      !_choiceFeedbackListSafe(choiceFeedback, choiceIds)) {
    return false;
  }

  final sources = payload['sources'];
  if (sources != null && !_sourceRefListSafe(sources, allowText: true)) {
    return false;
  }

  return true;
}

bool isActivityResultCardPayloadSafe(Map<String, Object?> payload) {
  if (!_hasOnlyKeys(payload, {
    'title',
    'status',
    'correctAnswers',
    'totalQuestions',
    'score',
    'partialScore',
    'message',
    'primaryActionLabel',
    'secondaryActionLabel',
  })) {
    return false;
  }

  final correctAnswers = payload['correctAnswers'];
  final totalQuestions = payload['totalQuestions'];

  return _boundedString(payload['title'], maxActivityComponentTitleLength) &&
      _boundedString(payload['status'], maxActivityComponentTitleLength) &&
      correctAnswers is int &&
      totalQuestions is int &&
      totalQuestions > 0 &&
      correctAnswers >= 0 &&
      correctAnswers <= totalQuestions &&
      _numberInRange(payload['score'], min: 0, max: 1, optional: true) &&
      _numberInRange(payload['partialScore'], min: 0, max: 1, optional: true) &&
      _optionalBoundedString(
        payload['message'],
        maxActivityComponentDescriptionLength,
      ) &&
      _optionalBoundedString(
        payload['primaryActionLabel'],
        maxActivityComponentActionLabelLength,
      ) &&
      _optionalBoundedString(
        payload['secondaryActionLabel'],
        maxActivityComponentActionLabelLength,
      );
}

bool isQuestionChartCardPayloadSafe(Map<String, Object?> payload) {
  if (!_hasOnlyKeys(payload, {
    'visualId',
    'chartType',
    'title',
    'description',
    'data',
    'xKey',
    'yKeys',
    'sources',
  })) {
    return false;
  }

  final data = payload['data'];
  final xKey = payload['xKey'];
  final yKeys = payload['yKeys'];
  final columns = _chartColumns(data);

  if (!_plainString(payload['visualId']) ||
      !_chartTypeSafe(payload['chartType']) ||
      !_boundedString(payload['title'], maxActivityComponentTitleLength) ||
      !_optionalBoundedString(
        payload['description'],
        maxActivityComponentDescriptionLength,
      ) ||
      columns == null ||
      !_optionalChartKeySafe(xKey) ||
      !_chartKeyListSafe(yKeys, optional: true) ||
      !_sourceRefListSafe(payload['sources'], allowText: false)) {
    return false;
  }

  if (xKey is String && !columns.contains(xKey)) {
    return false;
  }

  if (yKeys is List &&
      yKeys.any((key) => key is! String || !columns.contains(key))) {
    return false;
  }

  return true;
}

bool isQuestionDiagramCardPayloadSafe(Map<String, Object?> payload) {
  if (!_hasOnlyKeys(payload, {
    'visualId',
    'title',
    'description',
    'nodes',
    'edges',
    'sources',
  })) {
    return false;
  }

  final nodes = _diagramNodeIds(payload['nodes']);
  if (!_plainString(payload['visualId']) ||
      !_boundedString(payload['title'], maxActivityComponentTitleLength) ||
      !_optionalBoundedString(
        payload['description'],
        maxActivityComponentDescriptionLength,
      ) ||
      nodes == null ||
      !_diagramEdgesSafe(payload['edges'], nodes) ||
      !_sourceRefListSafe(payload['sources'], allowText: false)) {
    return false;
  }

  return true;
}

bool _visualListSafe(Object? value) {
  if (value is! List || value.length > maxQuestionVisuals) {
    return false;
  }

  return value.every((item) {
    final payload = _jsonMap(item);
    if (payload == null) {
      return false;
    }
    return isQuestionChartCardPayloadSafe(payload) ||
        isQuestionDiagramCardPayloadSafe(payload);
  });
}

Set<String>? _choiceIds(Object? value) {
  if (value is! List ||
      value.length < 2 ||
      value.length > maxActivityChoices) {
    return null;
  }

  final ids = <String>{};
  for (final item in value) {
    final payload = _jsonMap(item);
    if (payload == null ||
        !_hasOnlyKeys(payload, {'id', 'label'}) ||
        !_plainString(payload['id']) ||
        !_boundedString(payload['label'], maxActivityChoiceLabelLength)) {
      return null;
    }
    final id = payload['id'] as String;
    if (!ids.add(id)) {
      return null;
    }
  }

  return ids;
}

bool _selectedChoicesSafe(
  Object? selectionMode,
  Object? selectedChoiceId,
  Object? selectedChoiceIds,
  Set<String> choiceIds,
) {
  if (selectedChoiceId != null && selectedChoiceIds != null) {
    return false;
  }

  if (selectedChoiceId != null) {
    return selectedChoiceId is String && choiceIds.contains(selectedChoiceId);
  }

  if (selectedChoiceIds != null) {
    final ids = _stringSet(selectedChoiceIds);
    if (ids == null || ids.isEmpty) {
      return false;
    }
    return ids.every(choiceIds.contains);
  }

  return true;
}

bool _correctionChoicesSafe(
  Object? selectionMode,
  Object? selectedChoiceId,
  Object? correctChoiceId,
  Object? selectedChoiceIds,
  Object? correctChoiceIds,
  Set<String> choiceIds,
) {
  if (selectionMode == 'single') {
    return selectedChoiceId is String &&
        correctChoiceId is String &&
        selectedChoiceIds == null &&
        correctChoiceIds == null &&
        choiceIds.contains(selectedChoiceId) &&
        choiceIds.contains(correctChoiceId);
  }

  final selectedIds = _stringSet(selectedChoiceIds);
  final correctIds = _stringSet(correctChoiceIds);

  return selectedChoiceId == null &&
      correctChoiceId == null &&
      selectedIds != null &&
      correctIds != null &&
      selectedIds.isNotEmpty &&
      correctIds.isNotEmpty &&
      selectedIds.every(choiceIds.contains) &&
      correctIds.every(choiceIds.contains);
}

bool _choiceFeedbackListSafe(Object? value, Set<String> choiceIds) {
  if (value is! List || value.length > maxActivityFeedbackItems) {
    return false;
  }

  final feedbackChoiceIds = <String>{};
  for (final item in value) {
    final payload = _jsonMap(item);
    if (payload == null ||
        !_hasOnlyKeys(payload, {'choiceId', 'feedback'}) ||
        payload['choiceId'] is! String ||
        !choiceIds.contains(payload['choiceId']) ||
        !_boundedString(payload['feedback'], maxActivityFeedbackLength)) {
      return false;
    }
    if (!feedbackChoiceIds.add(payload['choiceId'] as String)) {
      return false;
    }
  }

  return true;
}

bool _sourceRefListSafe(Object? value, {required bool allowText}) {
  if (value is! List || value.length > maxActivitySources) {
    return false;
  }

  return value.every((item) => _sourceRefSafe(item, allowText: allowText));
}

bool _sourceRefSafe(Object? value, {required bool allowText}) {
  final payload = _jsonMap(value);
  final allowedKeys = allowText
      ? {'chunkId', 'text', 'pageNumber', 'index', 'label'}
      : {'chunkId', 'pageNumber', 'index'};

  if (payload == null || !_hasOnlyKeys(payload, allowedKeys)) {
    return false;
  }

  final pageNumber = payload['pageNumber'];
  final index = payload['index'];
  final text = payload['text'];
  final label = payload['label'];

  return _plainString(payload['chunkId']) &&
      (pageNumber == null || pageNumber is int) &&
      index is int &&
      index >= 0 &&
      (!allowText ||
          _boundedString(text, maxActivitySourceTextLength)) &&
      (!allowText ||
          label == null ||
          _boundedString(label, maxActivityComponentActionLabelLength));
}

Set<String>? _chartColumns(Object? value) {
  if (value is! List ||
      value.isEmpty ||
      value.length > maxQuestionChartRows) {
    return null;
  }

  final columns = <String>{};
  for (final row in value) {
    final payload = _jsonMap(row);
    if (payload == null ||
        payload.isEmpty ||
        payload.length > maxQuestionChartColumns) {
      return null;
    }

    for (final entry in payload.entries) {
      if (!_chartKeySafe(entry.key) || !_chartValueSafe(entry.value)) {
        return null;
      }
      columns.add(entry.key);
    }
  }

  if (columns.length > maxQuestionChartColumns) {
    return null;
  }

  return columns;
}

Set<String>? _diagramNodeIds(Object? value) {
  if (value is! List ||
      value.isEmpty ||
      value.length > maxQuestionDiagramNodes) {
    return null;
  }

  final ids = <String>{};
  for (final item in value) {
    final payload = _jsonMap(item);
    if (payload == null ||
        !_hasOnlyKeys(payload, {'id', 'label'}) ||
        !_plainString(payload['id']) ||
        !_boundedString(payload['label'], maxActivityComponentTitleLength)) {
      return null;
    }
    if (!ids.add(payload['id'] as String)) {
      return null;
    }
  }

  return ids;
}

bool _diagramEdgesSafe(Object? value, Set<String> nodeIds) {
  if (value == null) {
    return true;
  }

  if (value is! List || value.length > maxQuestionDiagramEdges) {
    return false;
  }

  for (final item in value) {
    final payload = _jsonMap(item);
    if (payload == null ||
        !_hasOnlyKeys(payload, {'from', 'to', 'label'}) ||
        payload['from'] is! String ||
        payload['to'] is! String ||
        !nodeIds.contains(payload['from']) ||
        !nodeIds.contains(payload['to']) ||
        !_optionalBoundedString(
          payload['label'],
          maxActivityComponentTitleLength,
        )) {
      return false;
    }
  }

  return true;
}

bool _selectionBoundsSafe(
  Object? selectionMode,
  Object? minSelections,
  Object? maxSelections,
  int choiceCount,
) {
  if (selectionMode == 'single') {
    return minSelections == null && maxSelections == null;
  }

  return minSelections is int &&
      maxSelections is int &&
      minSelections >= 1 &&
      maxSelections >= minSelections &&
      maxSelections <= choiceCount;
}

bool _selectionModeSafe(Object? value) {
  return value == 'single' || value == 'multiple';
}

bool _difficultySafe(Object? value) {
  return value == null || value == 'LOW' || value == 'MEDIUM' || value == 'HIGH';
}

bool _chartTypeSafe(Object? value) {
  return value == 'bar' ||
      value == 'line' ||
      value == 'pie' ||
      value == 'scatter';
}

bool _chartValueSafe(Object? value) {
  return value == null ||
      value is num ||
      _boundedString(value, maxQuestionChartValueLength);
}

bool _chartKeyListSafe(Object? value, {required bool optional}) {
  if (value == null) {
    return optional;
  }

  if (value is! List || value.isEmpty || value.length > maxQuestionChartColumns) {
    return false;
  }

  final keys = <String>{};
  for (final item in value) {
    if (item is! String || !_chartKeySafe(item) || !keys.add(item)) {
      return false;
    }
  }

  return true;
}

bool _optionalChartKeySafe(Object? value) {
  return value == null || value is String && _chartKeySafe(value);
}

bool _chartKeySafe(String value) {
  return RegExp(r'^[A-Za-z_][A-Za-z0-9_]*$').hasMatch(value) &&
      value.length <= maxQuestionChartKeyLength;
}

Set<String>? _stringSet(Object? value) {
  if (value is! List || value.isEmpty) {
    return null;
  }

  final ids = <String>{};
  for (final item in value) {
    if (item is! String || item.trim().isEmpty || !ids.add(item)) {
      return null;
    }
  }

  return ids;
}

bool _numberInRange(
  Object? value, {
  required num min,
  required num max,
  required bool optional,
}) {
  if (value == null) {
    return optional;
  }

  return value is num && value >= min && value <= max;
}

bool _optionalPlainString(Object? value) {
  return value == null || _plainString(value);
}

bool _plainString(Object? value) {
  return _boundedString(value, maxActivityComponentTitleLength);
}

bool _optionalBoundedString(Object? value, int maxLength) {
  return value == null || _boundedString(value, maxLength);
}

bool _boundedString(Object? value, int maxLength) {
  return value is String &&
      value.trim().isNotEmpty &&
      value.runes.length <= maxLength &&
      !_containsUnsafeMarkup(value);
}

bool _containsUnsafeMarkup(String value) {
  final normalized = value.toLowerCase();
  return normalized.contains('<script') ||
      normalized.contains('<svg') ||
      normalized.contains('<iframe') ||
      normalized.contains('javascript:') ||
      normalized.contains('```mermaid') ||
      normalized.contains('graph td') ||
      normalized.contains('graph lr') ||
      normalized.contains('flowchart');
}

bool _hasOnlyKeys(Map<String, Object?> payload, Set<String> allowedKeys) {
  return payload.keys.every(allowedKeys.contains);
}

Map<String, Object?>? _jsonMap(Object? value) {
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
