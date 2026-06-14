import 'package:dio/dio.dart';

import '../application/activity_controller.dart';
import '../domain/diagnostic_quiz_activity.dart';

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
    final data = {'subjectId': subjectId};
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
        'answers': [
          for (final answer in answers)
            {'questionId': answer.questionId, 'choiceId': answer.choiceId},
        ],
      },
      options: await _authorizedOptions(),
    );

    return _ResultJson(response.data).toResult();
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

    if (id is! String || prompt is! String || choices is! List) {
      throw const FormatException('Invalid question response');
    }

    return DiagnosticQuizQuestion(
      id: id,
      knowledgeUnitId: knowledgeUnitId is String ? knowledgeUnitId : null,
      prompt: prompt,
      difficulty: difficulty is String ? difficulty : null,
      choices: choices
          .map((choice) => _ChoiceJson(choice).toChoice())
          .toList(growable: false),
      sources: sources is List
          ? sources
                .map((source) => _SourceRefJson(source).toSourceRef())
                .toList(growable: false)
          : const [],
    );
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
    final isCorrect = json['isCorrect'];
    final explanation = json['explanation'];
    final choiceFeedback = json['choiceFeedback'];
    final sources = json['sources'];

    if (questionId is! String ||
        prompt is! String ||
        selectedChoiceId is! String ||
        correctChoiceId is! String ||
        isCorrect is! bool ||
        explanation is! String) {
      throw const FormatException('Invalid correction item response');
    }

    return DiagnosticQuizCorrectionItem(
      questionId: questionId,
      knowledgeUnitId: knowledgeUnitId is String ? knowledgeUnitId : null,
      prompt: prompt,
      selectedChoiceId: selectedChoiceId,
      correctChoiceId: correctChoiceId,
      isCorrect: isCorrect,
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
