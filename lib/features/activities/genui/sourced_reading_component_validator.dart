const int maxSourcedReadingTitleLength = 120;
const int maxSourcedReadingContentLength = 2400;
const int maxSourcedReadingItemLength = 180;
const int maxSourcedReadingItems = 8;
const int maxSourcedReadingSources = 4;
const int maxSourcedReadingSourceTextLength = 520;
const int maxSourcedReadingSourceLabelLength = 80;

bool isSourcedReadingComponentPayloadSafe(
  String component,
  Map<String, Object?> payload,
) {
  return switch (component) {
    'SummaryCard' => isSummaryCardPayloadSafe(payload),
    'KeyPointsList' => isKeyPointsListPayloadSafe(payload),
    'SourceExcerptCard' => isSourceExcerptCardPayloadSafe(payload),
    _ => false,
  };
}

bool isSummaryCardPayloadSafe(Map<String, Object?> payload) {
  if (!_hasOnlyKeys(payload, {'title', 'content', 'keyPoints', 'sources'})) {
    return false;
  }

  if (!_boundedString(payload['title'], maxSourcedReadingTitleLength) ||
      !_boundedString(payload['content'], maxSourcedReadingContentLength) ||
      !_stringListSafe(
        payload['keyPoints'],
        minItems: 1,
        maxItems: maxSourcedReadingItems,
        maxLength: maxSourcedReadingItemLength,
      )) {
    return false;
  }

  final sources = payload['sources'];
  if (sources == null) {
    return true;
  }

  return _sourceListSafe(sources);
}

bool isKeyPointsListPayloadSafe(Map<String, Object?> payload) {
  if (!_hasOnlyKeys(payload, {'title', 'items'})) {
    return false;
  }

  return _boundedString(payload['title'], maxSourcedReadingTitleLength) &&
      _stringListSafe(
        payload['items'],
        minItems: 1,
        maxItems: maxSourcedReadingItems,
        maxLength: maxSourcedReadingItemLength,
      );
}

bool isSourceExcerptCardPayloadSafe(Map<String, Object?> payload) {
  if (!_hasOnlyKeys(payload, {'text', 'pageNumber', 'index', 'label'})) {
    return false;
  }

  return _sourcePayloadSafe(payload);
}

bool _sourceListSafe(Object? value) {
  if (value is! List || value.length > maxSourcedReadingSources) {
    return false;
  }

  return value.every(_sourcePayloadSafe);
}

bool _sourcePayloadSafe(Object? value) {
  if (value is! Map) {
    return false;
  }

  final payload = _jsonMap(value);
  if (payload == null ||
      !_hasOnlyKeys(payload, {'text', 'pageNumber', 'index', 'label'})) {
    return false;
  }

  final pageNumber = payload['pageNumber'];
  final index = payload['index'];
  final label = payload['label'];

  return _boundedString(payload['text'], maxSourcedReadingSourceTextLength) &&
      (pageNumber == null || pageNumber is int) &&
      index is int &&
      index >= 0 &&
      (label == null ||
          _boundedString(label, maxSourcedReadingSourceLabelLength));
}

bool _stringListSafe(
  Object? value, {
  required int minItems,
  required int maxItems,
  required int maxLength,
}) {
  if (value is! List || value.length < minItems || value.length > maxItems) {
    return false;
  }

  return value.every((item) => _boundedString(item, maxLength));
}

bool _boundedString(Object? value, int maxLength) {
  return value is String &&
      value.trim().isNotEmpty &&
      value.runes.length <= maxLength;
}

bool _hasOnlyKeys(Map<String, Object?> payload, Set<String> allowedKeys) {
  return payload.keys.every(allowedKeys.contains);
}

Map<String, Object?>? _jsonMap(Map value) {
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
