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
    final title = json['title'];
    final questions = json['questions'];

    if (sessionId is! String || title is! String || questions is! List) {
      throw const FormatException('Invalid activity response');
    }

    return DiagnosticQuizActivity(
      sessionId: sessionId,
      title: title,
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
    final prompt = json['prompt'];
    final choices = json['choices'];

    if (id is! String || prompt is! String || choices is! List) {
      throw const FormatException('Invalid question response');
    }

    return DiagnosticQuizQuestion(
      id: id,
      prompt: prompt,
      choices: choices
          .map((choice) => _ChoiceJson(choice).toChoice())
          .toList(growable: false),
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

    if (correctAnswers is! int || totalQuestions is! int) {
      throw const FormatException('Invalid activity result response');
    }

    return DiagnosticQuizResult(
      correctAnswers: correctAnswers,
      totalQuestions: totalQuestions,
    );
  }
}
