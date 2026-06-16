import 'package:dio/dio.dart';

import '../application/activity_controller.dart';
import '../domain/diagnostic_quiz_activity.dart';
import '../domain/open_question_activity.dart';
import '../domain/rich_closed_exercise.dart';

class HttpActivitiesApi implements ActivityApi {
  HttpActivitiesApi({
    required Dio dio,
    required Future<String> Function() getIdToken,
  }) : this._(dio, getIdToken);

  const HttpActivitiesApi._(this._dio, this._getIdToken);

  final Dio _dio;
  final Future<String> Function() _getIdToken;

  @override
  Future<DiagnosticQuizActivity> startNextActivity({
    required String subjectId,
    String? knowledgeUnitId,
  }) async {
    final data = <String, Object>{
      'subjectId': subjectId,
      'selectionModes': ['single', 'multiple'],
      'visualsEnabled': true,
      'visualTypes': ['CHART', 'DIAGRAM'],
    };
    if (knowledgeUnitId != null) {
      data['knowledgeUnitId'] = knowledgeUnitId;
    }

    final response = await _dio.post<Object?>(
      '/activities/next',
      data: data,
      options: await _authorizedOptions(),
    );

    return _ActivityJson(response.data).toActivity();
  }

  @override
  Future<DiagnosticQuizResult> submitResult({
    required String sessionId,
    required List<DiagnosticQuizAnswer> answers,
  }) async {
    final response = await _dio.post<Object?>(
      '/activities/$sessionId/result',
      data: {
        'answers': [for (final answer in answers) _AnswerJson(answer).toJson()],
      },
      options: await _authorizedOptions(),
    );

    return _ResultJson(response.data).toResult();
  }

  @override
  Future<OpenQuestionActivity> startOpenQuestion({
    required String subjectId,
    required String knowledgeUnitId,
  }) async {
    final response = await _dio.post<Object?>(
      '/activities/open-question',
      data: {'subjectId': subjectId, 'knowledgeUnitId': knowledgeUnitId},
      options: await _authorizedOptions(),
    );

    return _OpenQuestionActivityJson(response.data).toActivity();
  }

  @override
  Future<OpenAnswerSubmissionResult> submitOpenAnswer({
    required String sessionId,
    required String answerText,
  }) async {
    final response = await _dio.post<Object?>(
      '/activities/$sessionId/open-answer',
      data: {'answerText': answerText},
      options: await _authorizedOptions(),
    );

    return _OpenAnswerSubmissionJson(response.data).toResult();
  }

  Future<RichClosedExercise> startRichClosedExercise({
    required String subjectId,
    required String knowledgeUnitId,
    String? documentId,
    int questionCount = 6,
    RichClosedComplexityProfile complexityProfile =
        RichClosedComplexityProfile.exam,
    Map<RichClosedQuestionKind, int>? questionTypeMix,
  }) async {
    final data = <String, Object?>{
      'subjectId': subjectId,
      'knowledgeUnitId': knowledgeUnitId,
      'questionCount': questionCount,
      'complexityProfile': complexityProfile.wireValue,
    };

    if (documentId != null) {
      data['documentId'] = documentId;
    }

    if (questionTypeMix != null) {
      data['questionTypeMix'] = {
        for (final entry in questionTypeMix.entries)
          entry.key.wireValue: entry.value,
      };
    }

    final response = await _dio.post<Object?>(
      '/activities/rich-closed/start',
      data: data,
      options: await _authorizedOptions(),
    );

    return RichClosedExercise.fromJson(response.data);
  }

  Future<RichClosedExercise> getRichClosedExercise(String sessionId) async {
    final response = await _dio.get<Object?>(
      '/activities/rich-closed/$sessionId',
      options: await _authorizedOptions(),
    );

    return RichClosedExercise.fromJson(response.data);
  }

  Future<RichClosedExerciseResult> submitRichClosedExercise({
    required String sessionId,
    required List<RichClosedAnswer> answers,
  }) async {
    final response = await _dio.post<Object?>(
      '/activities/rich-closed/$sessionId/submit',
      data: RichClosedExerciseSubmission(answers: answers).toJson(),
      options: await _authorizedOptions(),
    );

    return RichClosedExerciseResult.fromJson(response.data);
  }

  Future<RichClosedExerciseResult> getRichClosedExerciseResult(
    String sessionId,
  ) async {
    final response = await _dio.get<Object?>(
      '/activities/rich-closed/$sessionId/result',
      options: await _authorizedOptions(),
    );

    return RichClosedExerciseResult.fromJson(response.data);
  }

  Future<Options> _authorizedOptions() async {
    final token = (await _getIdToken()).trim();

    if (token.isEmpty) {
      throw StateError('A Firebase ID token is required for activities');
    }

    return Options(headers: {'Authorization': 'Bearer $token'});
  }
}

class _ActivityJson {
  const _ActivityJson(this.value);

  final Object? value;

  DiagnosticQuizActivity toActivity() {
    final json = value;

    if (json is! Map<String, Object?>) {
      throw const FormatException('Invalid activity response');
    }

    final sessionId = json['sessionId'];
    final type = json['type'];
    final version = json['version'];
    final title = json['title'];
    final documentId = json['documentId'];
    final subjectId = json['subjectId'];
    final questions = json['questions'];

    if (sessionId is! String || title is! String || questions is! List) {
      throw const FormatException('Invalid activity response');
    }

    return DiagnosticQuizActivity(
      sessionId: sessionId,
      type: type is String ? type : 'diagnostic_quiz',
      version: version is int ? version : null,
      title: title,
      documentId: documentId is String ? documentId : null,
      subjectId: subjectId is String ? subjectId : null,
      questions: questions
          .map((question) => _QuestionJson(question).toQuestion())
          .toList(growable: false),
    );
  }
}

class _QuestionJson {
  const _QuestionJson(this.value);

  final Object? value;

  DiagnosticQuizQuestion toQuestion() {
    final json = value;

    if (json is! Map<String, Object?>) {
      throw const FormatException('Invalid question response');
    }

    final id = json['id'];
    final knowledgeUnitId = json['knowledgeUnitId'];
    final prompt = json['prompt'];
    final difficulty = json['difficulty'];
    final choices = json['choices'];
    final sources = json['sources'];
    final visuals = json['visuals'];

    if (id is! String || prompt is! String || choices is! List) {
      throw const FormatException('Invalid question response');
    }

    final parsedChoices = choices
        .map((choice) => _ChoiceJson(choice).toChoice())
        .toList(growable: false);
    final selectionMode = _selectionMode(json['selectionMode']);
    final minSelections = _selectionCount(
      json['minSelections'],
      fallback: 1,
      fieldName: 'minSelections',
    );
    final maxSelections = _selectionCount(
      json['maxSelections'],
      fallback: selectionMode == DiagnosticQuizSelectionMode.multiple
          ? parsedChoices.length
          : 1,
      fieldName: 'maxSelections',
    );

    if (selectionMode == DiagnosticQuizSelectionMode.multiple &&
        (minSelections < 1 ||
            maxSelections < minSelections ||
            maxSelections > parsedChoices.length)) {
      throw const FormatException('Invalid question selection response');
    }

    final parsedVisuals = <DiagnosticQuizVisual>[];
    if (visuals is List) {
      parsedVisuals.addAll([
        for (final (index, visual) in visuals.indexed)
          _VisualJson(visual, index).toVisual(),
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
                .map((source) => _SourceRefJson(source).toSourceRef())
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

    throw const FormatException('Invalid question selection response');
  }

  int _selectionCount(
    Object? value, {
    required int fallback,
    required String fieldName,
  }) {
    if (value == null) {
      return fallback;
    }

    if (value is int) {
      return value;
    }

    throw FormatException('Invalid question selection response: $fieldName');
  }
}

class _ChoiceJson {
  const _ChoiceJson(this.value);

  final Object? value;

  DiagnosticQuizChoice toChoice() {
    final json = value;

    if (json is! Map<String, Object?>) {
      throw const FormatException('Invalid choice response');
    }

    final id = json['id'];
    final label = json['label'];

    if (id is! String || label is! String) {
      throw const FormatException('Invalid choice response');
    }

    return DiagnosticQuizChoice(id: id, label: label);
  }
}

class _VisualJson {
  const _VisualJson(this.value, this.fallbackIndex);

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

    throw const FormatException('Invalid visual response');
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

    throw const FormatException('Invalid visual response');
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
      _ => throw const FormatException('Invalid chart visual response'),
    };
  }

  Map<String, Object?> _chartRow(Object? value) {
    final json = value;
    if (json is! Map<String, Object?>) {
      throw const FormatException('Invalid chart visual response');
    }

    return json.map((key, value) {
      if (value == null || value is String || value is num) {
        return MapEntry(key, value);
      }

      throw const FormatException('Invalid chart visual response');
    });
  }

  DiagnosticQuizDiagramNode _diagramNode(Object? value) {
    final json = value;
    if (json is! Map<String, Object?>) {
      throw const FormatException('Invalid diagram visual response');
    }

    final id = json['id'];
    final label = json['label'];
    if (id is! String || label is! String) {
      throw const FormatException('Invalid diagram visual response');
    }

    return DiagnosticQuizDiagramNode(id: id, label: label);
  }

  DiagnosticQuizDiagramEdge _diagramEdge(Object? value) {
    final json = value;
    if (json is! Map<String, Object?>) {
      throw const FormatException('Invalid diagram visual response');
    }

    final from = json['from'];
    final to = json['to'];
    final label = json['label'];
    if (from is! String || to is! String) {
      throw const FormatException('Invalid diagram visual response');
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

          throw const FormatException('Invalid visual response');
        })
        .toList(growable: false);
  }

  List<DiagnosticQuizSourceRef> _sourceRefs(List<Object?> values) {
    return values
        .map((source) => _SourceRefJson(source).toSourceRef())
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

class _SourceRefJson {
  const _SourceRefJson(this.value);

  final Object? value;

  DiagnosticQuizSourceRef toSourceRef() {
    final json = value;

    if (json is! Map<String, Object?>) {
      throw const FormatException('Invalid question source response');
    }

    final chunkId = json['chunkId'];
    final pageNumber = json['pageNumber'];
    final index = json['index'];

    if (chunkId is! String || index is! int) {
      throw const FormatException('Invalid question source response');
    }

    return DiagnosticQuizSourceRef(
      chunkId: chunkId,
      pageNumber: pageNumber is int ? pageNumber : null,
      index: index,
    );
  }
}

class _AnswerJson {
  const _AnswerJson(this.answer);

  final DiagnosticQuizAnswer answer;

  Map<String, Object?> toJson() {
    final choiceId = answer.choiceId;
    if (choiceId != null) {
      return {'questionId': answer.questionId, 'choiceId': choiceId};
    }

    return {'questionId': answer.questionId, 'choiceIds': answer.choiceIds};
  }
}

class _ResultJson {
  const _ResultJson(this.value);

  final Object? value;

  DiagnosticQuizResult toResult() {
    final json = value;

    if (json is! Map<String, Object?>) {
      throw const FormatException('Invalid activity result response');
    }

    final correctAnswers = json['correctAnswers'];
    final totalQuestions = json['totalQuestions'];
    final score = json['score'];
    final items = json['items'];

    if (correctAnswers is! int || totalQuestions is! int) {
      throw const FormatException('Invalid activity result response');
    }

    return DiagnosticQuizResult(
      correctAnswers: correctAnswers,
      totalQuestions: totalQuestions,
      score: score is num ? score.toDouble() : null,
      items: items is List
          ? items
                .map((item) => _CorrectionItemJson(item).toCorrectionItem())
                .toList(growable: false)
          : const [],
    );
  }
}

class _CorrectionItemJson {
  const _CorrectionItemJson(this.value);

  final Object? value;

  DiagnosticQuizCorrectionItem toCorrectionItem() {
    final json = value;

    if (json is! Map<String, Object?>) {
      throw const FormatException('Invalid correction item response');
    }

    final questionId = json['questionId'];
    final knowledgeUnitId = json['knowledgeUnitId'];
    final prompt = json['prompt'];
    final selectedChoiceId = json['selectedChoiceId'];
    final correctChoiceId = json['correctChoiceId'];
    final selectedChoiceIds = json['selectedChoiceIds'];
    final correctChoiceIds = json['correctChoiceIds'];
    final isCorrect = json['isCorrect'];
    final partialScore = json['partialScore'];
    final explanation = json['explanation'];
    final choiceFeedback = json['choiceFeedback'];
    final sources = json['sources'];

    if (questionId is! String ||
        prompt is! String ||
        isCorrect is! bool ||
        explanation is! String) {
      throw const FormatException('Invalid correction item response');
    }

    final parsedSelectedChoiceIds = selectedChoiceIds is List
        ? _stringList(selectedChoiceIds)
        : const <String>[];
    final parsedCorrectChoiceIds = correctChoiceIds is List
        ? _stringList(correctChoiceIds)
        : const <String>[];

    if (selectedChoiceId is! String &&
        correctChoiceId is! String &&
        (parsedSelectedChoiceIds.isEmpty || parsedCorrectChoiceIds.isEmpty)) {
      throw const FormatException('Invalid correction item response');
    }

    return DiagnosticQuizCorrectionItem(
      questionId: questionId,
      knowledgeUnitId: knowledgeUnitId is String ? knowledgeUnitId : null,
      prompt: prompt,
      selectedChoiceId: selectedChoiceId is String ? selectedChoiceId : null,
      correctChoiceId: correctChoiceId is String ? correctChoiceId : null,
      selectedChoiceIds: parsedSelectedChoiceIds,
      correctChoiceIds: parsedCorrectChoiceIds,
      isCorrect: isCorrect,
      partialScore: partialScore is num ? partialScore.toDouble() : null,
      explanation: explanation,
      choiceFeedback: choiceFeedback is List
          ? choiceFeedback
                .map(
                  (feedback) =>
                      _ChoiceFeedbackJson(feedback).toChoiceFeedback(),
                )
                .toList(growable: false)
          : const [],
      sources: sources is List
          ? sources
                .map((source) => _CorrectionSourceJson(source).toSource())
                .toList(growable: false)
          : const [],
    );
  }

  List<String> _stringList(List<Object?> values) {
    return values
        .map((value) {
          if (value is String) {
            return value;
          }

          throw const FormatException('Invalid correction item response');
        })
        .toList(growable: false);
  }
}

class _ChoiceFeedbackJson {
  const _ChoiceFeedbackJson(this.value);

  final Object? value;

  DiagnosticQuizChoiceFeedback toChoiceFeedback() {
    final json = value;

    if (json is! Map<String, Object?>) {
      throw const FormatException('Invalid choice feedback response');
    }

    final choiceId = json['choiceId'];
    final feedback = json['feedback'];

    if (choiceId is! String || feedback is! String) {
      throw const FormatException('Invalid choice feedback response');
    }

    return DiagnosticQuizChoiceFeedback(choiceId: choiceId, feedback: feedback);
  }
}

class _CorrectionSourceJson {
  const _CorrectionSourceJson(this.value);

  final Object? value;

  DiagnosticQuizCorrectionSource toSource() {
    final json = value;

    if (json is! Map<String, Object?>) {
      throw const FormatException('Invalid correction source response');
    }

    final chunkId = json['chunkId'];
    final text = json['text'];
    final pageNumber = json['pageNumber'];
    final index = json['index'];

    if (chunkId is! String || text is! String || index is! int) {
      throw const FormatException('Invalid correction source response');
    }

    return DiagnosticQuizCorrectionSource(
      chunkId: chunkId,
      text: text,
      pageNumber: pageNumber is int ? pageNumber : null,
      index: index,
    );
  }
}

class _OpenQuestionActivityJson {
  const _OpenQuestionActivityJson(this.value);

  final Object? value;

  OpenQuestionActivity toActivity() {
    final json = value;

    if (json is! Map<String, Object?>) {
      throw const FormatException('Invalid open question response');
    }

    final sessionId = json['sessionId'];
    final type = json['type'];
    final version = json['version'];
    final subjectId = json['subjectId'];
    final documentId = json['documentId'];
    final knowledgeUnitId = json['knowledgeUnitId'];
    final question = json['question'];

    if (sessionId is! String ||
        type != 'open_question' ||
        subjectId is! String ||
        knowledgeUnitId is! String ||
        question is! Map<String, Object?>) {
      throw const FormatException('Invalid open question response');
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
      throw const FormatException('Invalid open question response');
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
      throw const FormatException('Invalid open question source response');
    }

    final chunkId = json['chunkId'];
    final pageNumber = json['pageNumber'];
    final index = json['index'];

    if (chunkId is! String || index is! int) {
      throw const FormatException('Invalid open question source response');
    }

    return OpenQuestionSource(
      chunkId: chunkId,
      pageNumber: pageNumber is int ? pageNumber : null,
      index: index,
    );
  }
}

class _OpenAnswerSubmissionJson {
  const _OpenAnswerSubmissionJson(this.value);

  final Object? value;

  OpenAnswerSubmissionResult toResult() {
    final json = value;

    if (json is! Map<String, Object?>) {
      throw const FormatException('Invalid open answer response');
    }

    final sessionId = json['sessionId'];
    final type = json['type'];
    final status = json['status'];
    final evaluation = json['evaluation'];

    if (sessionId is! String ||
        type != 'open_question' ||
        status is! String ||
        evaluation is! Map<String, Object?>) {
      throw const FormatException('Invalid open answer response');
    }

    return OpenAnswerSubmissionResult(
      sessionId: sessionId,
      type: type as String,
      status: status,
      evaluation: _OpenAnswerEvaluationJson(evaluation).toEvaluation(),
    );
  }
}

class _OpenAnswerEvaluationJson {
  const _OpenAnswerEvaluationJson(this.value);

  final Map<String, Object?> value;

  OpenAnswerEvaluation toEvaluation() {
    final id = value['id'];
    final status = value['status'];
    final score = value['score'];
    final maxScore = value['maxScore'];
    final feedback = value['feedback'];
    final presentPoints = value['presentPoints'];
    final missingPoints = value['missingPoints'];
    final errors = value['errors'];
    final modelAnswer = value['modelAnswer'];
    final advice = value['advice'];
    final sources = value['sources'];

    if (id is! String || status is! String) {
      throw const FormatException('Invalid open answer evaluation response');
    }

    return OpenAnswerEvaluation(
      id: id,
      status: _openAnswerEvaluationStatus(status),
      score: score is num ? score.toDouble() : null,
      maxScore: maxScore is num ? maxScore.toDouble() : null,
      feedback: feedback is String ? feedback : null,
      presentPoints: presentPoints is List
          ? _stringList(
              presentPoints,
              'Invalid open answer evaluation response',
            )
          : const [],
      missingPoints: missingPoints is List
          ? _stringList(
              missingPoints,
              'Invalid open answer evaluation response',
            )
          : const [],
      errors: errors is List
          ? _stringList(errors, 'Invalid open answer evaluation response')
          : const [],
      modelAnswer: modelAnswer is String ? modelAnswer : null,
      advice: advice is String ? advice : null,
      sources: sources is List
          ? sources
                .map((source) => _OpenAnswerSourceJson(source).toSource())
                .toList(growable: false)
          : const [],
    );
  }

  OpenAnswerEvaluationStatus _openAnswerEvaluationStatus(String status) {
    return switch (status) {
      'PENDING' => OpenAnswerEvaluationStatus.pending,
      'READY' => OpenAnswerEvaluationStatus.ready,
      'FAILED' => OpenAnswerEvaluationStatus.failed,
      _ => throw const FormatException(
        'Invalid open answer evaluation response',
      ),
    };
  }
}

class _OpenAnswerSourceJson {
  const _OpenAnswerSourceJson(this.value);

  final Object? value;

  OpenAnswerCorrectionSource toSource() {
    final json = value;

    if (json is! Map<String, Object?>) {
      throw const FormatException('Invalid open answer source response');
    }

    final chunkId = json['chunkId'];
    final text = json['text'];
    final pageNumber = json['pageNumber'];
    final index = json['index'];

    if (chunkId is! String || text is! String || index is! int) {
      throw const FormatException('Invalid open answer source response');
    }

    return OpenAnswerCorrectionSource(
      chunkId: chunkId,
      text: text,
      pageNumber: pageNumber is int ? pageNumber : null,
      index: index,
    );
  }
}

List<String> _stringList(List<Object?> values, String errorMessage) {
  return values
      .map((value) {
        if (value is String) {
          return value;
        }

        throw FormatException(errorMessage);
      })
      .toList(growable: false);
}
