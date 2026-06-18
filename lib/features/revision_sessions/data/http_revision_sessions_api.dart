import 'package:dio/dio.dart';

import '../../activities/domain/diagnostic_quiz_activity.dart';
import '../../activities/domain/open_question_activity.dart';
import '../domain/revision_session.dart';
import 'revision_sessions_api.dart';

class HttpRevisionSessionsApi implements RevisionSessionsApi {
  HttpRevisionSessionsApi({
    required Dio dio,
    required Future<String> Function() getIdToken,
  }) : this._(dio, getIdToken);

  const HttpRevisionSessionsApi._(this._dio, this._getIdToken);

  final Dio _dio;
  final Future<String> Function() _getIdToken;

  @override
  Future<RevisionSessionResponse> startRevisionSession({
    required String subjectId,
    String? documentId,
    String? knowledgeUnitId,
    RevisionSessionPreferredAction? preferredAction,
  }) async {
    final data = <String, Object?>{'subjectId': subjectId};
    if (documentId != null) {
      data['documentId'] = documentId;
    }
    if (knowledgeUnitId != null) {
      data['knowledgeUnitId'] = knowledgeUnitId;
    }
    if (preferredAction != null) {
      data['preferredAction'] = _preferredActionJson(preferredAction);
    }

    final response = await _dio.post<Object?>(
      '/revision-sessions',
      data: data,
      options: await _authorizedOptions(),
    );

    return RevisionSessionResponseJson(response.data).toResponse();
  }

  @override
  Future<RevisionSessionResponse> getRevisionSession({
    required String sessionId,
  }) async {
    final response = await _dio.get<Object?>(
      '/revision-sessions/$sessionId',
      options: await _authorizedOptions(),
    );

    return RevisionSessionResponseJson(response.data).toResponse();
  }

  Future<Options> _authorizedOptions() async {
    final token = (await _getIdToken()).trim();

    if (token.isEmpty) {
      throw StateError('A Firebase ID token is required for revision sessions');
    }

    return Options(headers: {'Authorization': 'Bearer $token'});
  }

  String _preferredActionJson(RevisionSessionPreferredAction action) {
    return switch (action) {
      RevisionSessionPreferredAction.diagnosticQuiz => 'diagnostic_quiz',
      RevisionSessionPreferredAction.openQuestion => 'open_question',
      RevisionSessionPreferredAction.richClosedExercise =>
        'rich_closed_exercise',
    };
  }
}

class RevisionSessionResponseJson {
  const RevisionSessionResponseJson(this.value);

  final Object? value;

  RevisionSessionResponse toResponse() {
    final json = value;

    if (json is! Map<String, Object?>) {
      throw const FormatException('Invalid revision session response');
    }

    final session = json['session'];
    final currentAction = json['currentAction'];
    final history = json['history'];

    if (session is! Map<String, Object?> || history is! List) {
      throw const FormatException('Invalid revision session response');
    }

    return RevisionSessionResponse(
      session: _RevisionSessionJson(session).toSession(),
      currentAction: currentAction == null
          ? null
          : _RevisionSessionActionJson(
              currentAction,
              allowPayload: true,
            ).toAction(),
      history: history
          .map(
            (action) => _RevisionSessionActionJson(
              action,
              allowPayload: false,
            ).toAction(),
          )
          .toList(growable: false),
    );
  }
}

class _RevisionSessionJson {
  const _RevisionSessionJson(this.value);

  final Map<String, Object?> value;

  RevisionSession toSession() {
    final id = value['id'];
    final status = value['status'];
    final subjectId = value['subjectId'];
    final courseId = value['courseId'];
    final documentId = value['documentId'];
    final knowledgeUnitId = value['knowledgeUnitId'];
    final createdAt = value['createdAt'];
    final completedAt = value['completedAt'];

    if (id is! String ||
        status is! String ||
        subjectId is! String ||
        createdAt is! String) {
      throw const FormatException('Invalid revision session response');
    }

    return RevisionSession(
      id: id,
      status: _sessionStatus(status),
      subjectId: subjectId,
      courseId: courseId is String ? courseId : null,
      documentId: documentId is String ? documentId : null,
      knowledgeUnitId: knowledgeUnitId is String ? knowledgeUnitId : null,
      createdAt: DateTime.parse(createdAt),
      completedAt: completedAt is String ? DateTime.parse(completedAt) : null,
    );
  }

  RevisionSessionStatus _sessionStatus(String status) {
    return switch (status) {
      'STARTED' => RevisionSessionStatus.started,
      'COMPLETED' => RevisionSessionStatus.completed,
      'ABANDONED' => RevisionSessionStatus.abandoned,
      _ => RevisionSessionStatus.unknown,
    };
  }
}

class _RevisionSessionActionJson {
  const _RevisionSessionActionJson(this.value, {required this.allowPayload});

  final Object? value;
  final bool allowPayload;

  RevisionSessionAction toAction() {
    final json = value;

    if (json is! Map<String, Object?>) {
      throw const FormatException('Invalid revision session action response');
    }

    final id = json['id'];
    final kind = json['kind'];
    final status = json['status'];
    final displayOrder = json['displayOrder'];
    final activitySessionId = json['activitySessionId'];
    final documentId = json['documentId'];
    final knowledgeUnitId = json['knowledgeUnitId'];

    if (id is! String ||
        kind is! String ||
        status is! String ||
        displayOrder is! int) {
      throw const FormatException('Invalid revision session action response');
    }

    return RevisionSessionAction(
      id: id,
      kind: _actionKind(kind),
      status: _actionStatus(status),
      displayOrder: displayOrder,
      activitySessionId: activitySessionId is String ? activitySessionId : null,
      documentId: documentId is String ? documentId : null,
      knowledgeUnitId: knowledgeUnitId is String ? knowledgeUnitId : null,
      payload: allowPayload
          ? _ActionPayloadJson(json['payload']).toPayload()
          : null,
    );
  }

  RevisionSessionActionKind _actionKind(String kind) {
    return switch (kind) {
      'DIAGNOSTIC_QUIZ' => RevisionSessionActionKind.diagnosticQuiz,
      'OPEN_QUESTION' => RevisionSessionActionKind.openQuestion,
      'RICH_CLOSED_EXERCISE' => RevisionSessionActionKind.richClosedExercise,
      _ => RevisionSessionActionKind.unknown,
    };
  }

  RevisionSessionActionStatus _actionStatus(String status) {
    return switch (status) {
      'READY' => RevisionSessionActionStatus.ready,
      'COMPLETED' => RevisionSessionActionStatus.completed,
      'FAILED' => RevisionSessionActionStatus.failed,
      _ => RevisionSessionActionStatus.unknown,
    };
  }
}

class _ActionPayloadJson {
  const _ActionPayloadJson(this.value);

  final Object? value;

  RevisionSessionActionPayload? toPayload() {
    final json = value;
    if (json == null) {
      return null;
    }

    if (json is! Map<String, Object?>) {
      return const RevisionSessionUnknownPayload();
    }

    final type = json['type'];
    if (type == 'diagnostic_quiz') {
      return _diagnosticQuizPayload(json);
    }
    if (type == 'open_question') {
      return _openQuestionPayload(json);
    }
    if (type == 'rich_closed_exercise') {
      return _richClosedExercisePayload(json);
    }

    return const RevisionSessionUnknownPayload();
  }

  RevisionSessionActionPayload _diagnosticQuizPayload(
    Map<String, Object?> json,
  ) {
    if (json['questions'] is List && json['title'] is String) {
      try {
        return RevisionSessionDiagnosticQuizPayload(
          _DiagnosticQuizActivityJson(json).toActivity(),
        );
      } on FormatException {
        return const RevisionSessionUnknownPayload();
      }
    }

    return RevisionSessionMinimalPayload(
      type: 'diagnostic_quiz',
      sessionId: json['sessionId'] is String
          ? json['sessionId'] as String
          : null,
    );
  }

  RevisionSessionActionPayload _openQuestionPayload(Map<String, Object?> json) {
    if (json['question'] is Map<String, Object?>) {
      try {
        return RevisionSessionOpenQuestionPayload(
          _OpenQuestionActivityJson(json).toActivity(),
        );
      } on FormatException {
        return const RevisionSessionUnknownPayload();
      }
    }

    return RevisionSessionMinimalPayload(
      type: 'open_question',
      sessionId: json['sessionId'] is String
          ? json['sessionId'] as String
          : null,
    );
  }

  RevisionSessionActionPayload _richClosedExercisePayload(
    Map<String, Object?> json,
  ) {
    if (_containsRichClosedExerciseContent(json)) {
      return const RevisionSessionUnknownPayload();
    }

    final subjectId = json['subjectId'];
    final documentId = json['documentId'];
    final knowledgeUnitId = json['knowledgeUnitId'];
    final knowledgeUnitTitle = json['knowledgeUnitTitle'];
    final reason = json['reason'];
    final estimatedMinutes = json['estimatedMinutes'];
    final preferredAction = json['preferredAction'];

    if (subjectId is! String || knowledgeUnitId is! String) {
      return const RevisionSessionUnknownPayload();
    }

    return RevisionSessionRichClosedExercisePayload(
      subjectId: subjectId,
      documentId: documentId is String ? documentId : null,
      knowledgeUnitId: knowledgeUnitId,
      knowledgeUnitTitle: knowledgeUnitTitle is String
          ? knowledgeUnitTitle
          : null,
      reason: reason is String ? reason : 'Questions riches recommandées.',
      estimatedMinutes: estimatedMinutes is int ? estimatedMinutes : 8,
      preferredAction: preferredAction is String ? preferredAction : null,
    );
  }

  bool _containsRichClosedExerciseContent(Map<String, Object?> json) {
    return json.containsKey('questions') ||
        json.containsKey('answers') ||
        json.containsKey('correction') ||
        json.containsKey('correctAnswers') ||
        json.containsKey('score');
  }
}

class _DiagnosticQuizActivityJson {
  const _DiagnosticQuizActivityJson(this.value);

  final Map<String, Object?> value;

  DiagnosticQuizActivity toActivity() {
    final sessionId = value['sessionId'];
    final type = value['type'];
    final version = value['version'];
    final title = value['title'];
    final documentId = value['documentId'];
    final subjectId = value['subjectId'];
    final questions = value['questions'];

    if (sessionId is! String || title is! String || questions is! List) {
      throw const FormatException('Invalid revision quiz payload');
    }

    return DiagnosticQuizActivity(
      sessionId: sessionId,
      type: type is String ? type : 'diagnostic_quiz',
      version: version is int ? version : null,
      title: title,
      documentId: documentId is String ? documentId : null,
      subjectId: subjectId is String ? subjectId : null,
      questions: questions
          .map((question) => _DiagnosticQuizQuestionJson(question).toQuestion())
          .toList(growable: false),
    );
  }
}

class _DiagnosticQuizQuestionJson {
  const _DiagnosticQuizQuestionJson(this.value);

  final Object? value;

  DiagnosticQuizQuestion toQuestion() {
    final json = value;

    if (json is! Map<String, Object?>) {
      throw const FormatException('Invalid revision quiz payload');
    }

    final id = json['id'];
    final knowledgeUnitId = json['knowledgeUnitId'];
    final prompt = json['prompt'];
    final difficulty = json['difficulty'];
    final choices = json['choices'];
    final sources = json['sources'];
    final visuals = json['visuals'];

    if (id is! String || prompt is! String || choices is! List) {
      throw const FormatException('Invalid revision quiz payload');
    }

    final parsedChoices = choices
        .map((choice) => _DiagnosticQuizChoiceJson(choice).toChoice())
        .toList(growable: false);
    final selectionMode = _selectionMode(json['selectionMode']);
    final minSelections = _selectionCount(json['minSelections'], fallback: 1);
    final maxSelections = _selectionCount(
      json['maxSelections'],
      fallback: selectionMode == DiagnosticQuizSelectionMode.multiple
          ? parsedChoices.length
          : 1,
    );

    if (selectionMode == DiagnosticQuizSelectionMode.multiple &&
        (minSelections < 1 ||
            maxSelections < minSelections ||
            maxSelections > parsedChoices.length)) {
      throw const FormatException('Invalid revision quiz payload');
    }

    final parsedVisuals = <DiagnosticQuizVisual>[];
    if (visuals is List) {
      parsedVisuals.addAll([
        for (final (index, visual) in visuals.indexed)
          _DiagnosticQuizVisualJson(visual, index).toVisual(),
      ]);
      parsedVisuals.sort(
        (left, right) => left.displayOrder.compareTo(right.displayOrder),
      );
    }

    return DiagnosticQuizQuestion(
      id: id,
      knowledgeUnitId: knowledgeUnitId is String ? knowledgeUnitId : null,
      prompt: prompt,
      difficulty: difficulty is String ? difficulty : null,
      selectionMode: selectionMode,
      minSelections: selectionMode == DiagnosticQuizSelectionMode.multiple
          ? minSelections
          : 1,
      maxSelections: selectionMode == DiagnosticQuizSelectionMode.multiple
          ? maxSelections
          : 1,
      choices: parsedChoices,
      sources: sources is List
          ? sources
                .map(
                  (source) =>
                      _DiagnosticQuizSourceRefJson(source).toSourceRef(),
                )
                .toList(growable: false)
          : const [],
      visuals: parsedVisuals,
    );
  }

  DiagnosticQuizSelectionMode _selectionMode(Object? value) {
    if (value == null || value == 'single') {
      return DiagnosticQuizSelectionMode.single;
    }

    if (value == 'multiple') {
      return DiagnosticQuizSelectionMode.multiple;
    }

    throw const FormatException('Invalid revision quiz payload');
  }

  int _selectionCount(Object? value, {required int fallback}) {
    if (value == null) {
      return fallback;
    }

    if (value is int) {
      return value;
    }

    throw const FormatException('Invalid revision quiz payload');
  }
}

class _DiagnosticQuizChoiceJson {
  const _DiagnosticQuizChoiceJson(this.value);

  final Object? value;

  DiagnosticQuizChoice toChoice() {
    final json = value;

    if (json is! Map<String, Object?>) {
      throw const FormatException('Invalid revision quiz payload');
    }

    final id = json['id'];
    final label = json['label'];

    if (id is! String || label is! String) {
      throw const FormatException('Invalid revision quiz payload');
    }

    return DiagnosticQuizChoice(id: id, label: label);
  }
}

class _DiagnosticQuizVisualJson {
  const _DiagnosticQuizVisualJson(this.value, this.fallbackIndex);

  final Object? value;
  final int fallbackIndex;

  DiagnosticQuizVisual toVisual() {
    final json = value;

    if (json is! Map<String, Object?>) {
      return _unsupported('UNKNOWN');
    }

    final type = json['type'];
    if (type is! String) {
      return _unsupported('UNKNOWN', json: json);
    }

    return switch (type) {
      'CHART' => _chart(json),
      'DIAGRAM' => _diagram(json),
      _ => _unsupported(type, json: json),
    };
  }

  DiagnosticQuizVisual _chart(Map<String, Object?> json) {
    try {
      final id = _id(json);
      final displayOrder = _displayOrder(json);
      final chartType = _chartType(json['chartType']);
      final title = json['title'];
      final description = json['description'];
      final data = json['data'];
      final xKey = json['xKey'];
      final yKeys = json['yKeys'];
      final sources = json['sources'];

      if (title is! String || data is! List) {
        return _unsupported('CHART', json: json);
      }

      return DiagnosticQuizChartVisual(
        id: id,
        displayOrder: displayOrder,
        chartType: chartType,
        title: title,
        description: description is String ? description : null,
        data: data.map(_chartRow).toList(growable: false),
        xKey: xKey is String ? xKey : null,
        yKeys: yKeys is List ? _stringList(yKeys) : const [],
        sources: sources is List ? _sourceRefs(sources) : const [],
      );
    } on FormatException {
      return _unsupported('CHART', json: json);
    }
  }

  DiagnosticQuizVisual _diagram(Map<String, Object?> json) {
    try {
      final id = _id(json);
      final displayOrder = _displayOrder(json);
      final title = json['title'];
      final description = json['description'];
      final nodes = json['nodes'];
      final edges = json['edges'];
      final sources = json['sources'];

      if (title is! String || nodes is! List) {
        return _unsupported('DIAGRAM', json: json);
      }

      return DiagnosticQuizDiagramVisual(
        id: id,
        displayOrder: displayOrder,
        title: title,
        description: description is String ? description : null,
        nodes: nodes.map(_diagramNode).toList(growable: false),
        edges: edges is List
            ? edges.map(_diagramEdge).toList(growable: false)
            : const [],
        sources: sources is List ? _sourceRefs(sources) : const [],
      );
    } on FormatException {
      return _unsupported('DIAGRAM', json: json);
    }
  }

  DiagnosticQuizUnsupportedVisual _unsupported(
    String type, {
    Map<String, Object?>? json,
  }) {
    final sources = json?['sources'];

    return DiagnosticQuizUnsupportedVisual(
      id: json == null ? 'visual-$fallbackIndex' : _safeId(json),
      displayOrder: json == null ? fallbackIndex : _safeDisplayOrder(json),
      type: type,
      sources: sources is List ? _safeSourceRefs(sources) : const [],
    );
  }

  String _id(Map<String, Object?> json) {
    final id = json['id'];
    if (id is String && id.trim().isNotEmpty) {
      return id;
    }

    throw const FormatException('Invalid revision quiz payload');
  }

  String _safeId(Map<String, Object?> json) {
    final id = json['id'];
    return id is String && id.trim().isNotEmpty ? id : 'visual-$fallbackIndex';
  }

  int _displayOrder(Map<String, Object?> json) {
    final displayOrder = json['displayOrder'];
    if (displayOrder == null) {
      return fallbackIndex;
    }

    if (displayOrder is int) {
      return displayOrder;
    }

    throw const FormatException('Invalid revision quiz payload');
  }

  int _safeDisplayOrder(Map<String, Object?> json) {
    final displayOrder = json['displayOrder'];
    return displayOrder is int ? displayOrder : fallbackIndex;
  }

  DiagnosticQuizChartType _chartType(Object? value) {
    return switch (value) {
      'bar' => DiagnosticQuizChartType.bar,
      'line' => DiagnosticQuizChartType.line,
      'pie' => DiagnosticQuizChartType.pie,
      'scatter' => DiagnosticQuizChartType.scatter,
      _ => throw const FormatException('Invalid revision quiz payload'),
    };
  }

  Map<String, Object?> _chartRow(Object? value) {
    final json = value;
    if (json is! Map<String, Object?>) {
      throw const FormatException('Invalid revision quiz payload');
    }

    return json.map((key, value) {
      if (value == null || value is String || value is num) {
        return MapEntry(key, value);
      }

      throw const FormatException('Invalid revision quiz payload');
    });
  }

  DiagnosticQuizDiagramNode _diagramNode(Object? value) {
    final json = value;
    if (json is! Map<String, Object?>) {
      throw const FormatException('Invalid revision quiz payload');
    }

    final id = json['id'];
    final label = json['label'];
    if (id is! String || label is! String) {
      throw const FormatException('Invalid revision quiz payload');
    }

    return DiagnosticQuizDiagramNode(id: id, label: label);
  }

  DiagnosticQuizDiagramEdge _diagramEdge(Object? value) {
    final json = value;
    if (json is! Map<String, Object?>) {
      throw const FormatException('Invalid revision quiz payload');
    }

    final from = json['from'];
    final to = json['to'];
    final label = json['label'];
    if (from is! String || to is! String) {
      throw const FormatException('Invalid revision quiz payload');
    }

    return DiagnosticQuizDiagramEdge(
      from: from,
      to: to,
      label: label is String ? label : null,
    );
  }

  List<String> _stringList(List<Object?> values) {
    return values
        .map((value) {
          if (value is String) {
            return value;
          }

          throw const FormatException('Invalid revision quiz payload');
        })
        .toList(growable: false);
  }

  List<DiagnosticQuizSourceRef> _sourceRefs(List<Object?> values) {
    return values
        .map((source) => _DiagnosticQuizSourceRefJson(source).toSourceRef())
        .toList(growable: false);
  }

  List<DiagnosticQuizSourceRef> _safeSourceRefs(List<Object?> values) {
    try {
      return _sourceRefs(values);
    } on FormatException {
      return const [];
    }
  }
}

class _DiagnosticQuizSourceRefJson {
  const _DiagnosticQuizSourceRefJson(this.value);

  final Object? value;

  DiagnosticQuizSourceRef toSourceRef() {
    final json = value;

    if (json is! Map<String, Object?>) {
      throw const FormatException('Invalid revision quiz source payload');
    }

    final chunkId = json['chunkId'];
    final pageNumber = json['pageNumber'];
    final index = json['index'];

    if (chunkId is! String || index is! int) {
      throw const FormatException('Invalid revision quiz source payload');
    }

    return DiagnosticQuizSourceRef(
      chunkId: chunkId,
      pageNumber: pageNumber is int ? pageNumber : null,
      index: index,
    );
  }
}

class _OpenQuestionActivityJson {
  const _OpenQuestionActivityJson(this.value);

  final Map<String, Object?> value;

  OpenQuestionActivity toActivity() {
    final sessionId = value['sessionId'];
    final type = value['type'];
    final version = value['version'];
    final subjectId = value['subjectId'];
    final documentId = value['documentId'];
    final knowledgeUnitId = value['knowledgeUnitId'];
    final question = value['question'];

    if (sessionId is! String ||
        type != 'open_question' ||
        subjectId is! String ||
        knowledgeUnitId is! String ||
        question is! Map<String, Object?>) {
      throw const FormatException('Invalid revision open question payload');
    }

    return OpenQuestionActivity(
      sessionId: sessionId,
      type: type as String,
      version: version is int ? version : null,
      subjectId: subjectId,
      documentId: documentId is String ? documentId : null,
      knowledgeUnitId: knowledgeUnitId,
      question: _OpenQuestionJson(question).toQuestion(),
    );
  }
}

class _OpenQuestionJson {
  const _OpenQuestionJson(this.value);

  final Map<String, Object?> value;

  OpenQuestion toQuestion() {
    final id = value['id'];
    final prompt = value['prompt'];
    final instructions = value['instructions'];
    final maxAnswerLength = value['maxAnswerLength'];
    final sources = value['sources'];

    if (id is! String || prompt is! String || maxAnswerLength is! int) {
      throw const FormatException('Invalid revision open question payload');
    }

    return OpenQuestion(
      id: id,
      prompt: prompt,
      instructions: instructions is String ? instructions : null,
      maxAnswerLength: maxAnswerLength,
      sources: sources is List
          ? sources
                .map((source) => _OpenQuestionSourceJson(source).toSource())
                .toList(growable: false)
          : const [],
    );
  }
}

class _OpenQuestionSourceJson {
  const _OpenQuestionSourceJson(this.value);

  final Object? value;

  OpenQuestionSource toSource() {
    final json = value;

    if (json is! Map<String, Object?>) {
      throw const FormatException(
        'Invalid revision open question source payload',
      );
    }

    final chunkId = json['chunkId'];
    final pageNumber = json['pageNumber'];
    final index = json['index'];

    if (chunkId is! String || index is! int) {
      throw const FormatException(
        'Invalid revision open question source payload',
      );
    }

    return OpenQuestionSource(
      chunkId: chunkId,
      pageNumber: pageNumber is int ? pageNumber : null,
      index: index,
    );
  }
}
