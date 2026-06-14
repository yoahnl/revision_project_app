import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:revision_app/features/activities/data/http_activities_api.dart';
import 'package:revision_app/features/activities/domain/diagnostic_quiz_activity.dart';

class CapturingHttpClientAdapter implements HttpClientAdapter {
  CapturingHttpClientAdapter(this.response);

  ResponseBody response;
  int fetchCallCount = 0;
  RequestOptions? lastOptions;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    fetchCallCount += 1;
    lastOptions = options;
    return response;
  }
}

void main() {
  test('starts the next activity with subject id and bearer token', () async {
    final adapter = CapturingHttpClientAdapter(jsonResponse(activityJson()));
    final dio = Dio()..httpClientAdapter = adapter;
    final api = HttpActivitiesApi(
      dio: dio,
      getIdToken: () async => 'firebase-id-token',
    );

    final activity = await api.startNextActivity(subjectId: 'subject-1');

    expect(activity.sessionId, 'session-1');
    expect(adapter.lastOptions?.path, '/activities/next');
    expect(adapter.lastOptions?.data, {'subjectId': 'subject-1'});
    expect(
      adapter.lastOptions?.headers['Authorization'],
      'Bearer firebase-id-token',
    );
  });

  test(
    'parses an enriched pre-submit quiz without correction fields',
    () async {
      final adapter = CapturingHttpClientAdapter(
        jsonResponse(enrichedActivityJsonWithAccidentalCorrection()),
      );
      final dio = Dio()..httpClientAdapter = adapter;
      final api = HttpActivitiesApi(
        dio: dio,
        getIdToken: () async => 'firebase-id-token',
      );

      final activity = await api.startNextActivity(subjectId: 'subject-1');
      final question = activity.questions.single;

      expect(activity.version, 2);
      expect(activity.documentId, 'document-1');
      expect(activity.subjectId, 'subject-1');
      expect(question.knowledgeUnitId, 'unit-1');
      expect(question.difficulty, 'MEDIUM');
      expect(question.sources.single.chunkId, 'chunk-1');
      expect(question.sources.single.pageNumber, isNull);
      expect(question.sources.single.index, 0);
      expect(question.choices.single.label, 'Réponse A');
    },
  );

  test('submits answers and maps the public score', () async {
    final adapter = CapturingHttpClientAdapter(
      jsonResponse({'correctAnswers': 1, 'totalQuestions': 2}),
    );
    final dio = Dio()..httpClientAdapter = adapter;
    final api = HttpActivitiesApi(
      dio: dio,
      getIdToken: () async => 'firebase-id-token',
    );

    final result = await api.submitResult(
      sessionId: 'session-1',
      answers: const [
        DiagnosticQuizAnswer(questionId: 'question-1', choiceId: 'a'),
      ],
    );

    expect(result.correctAnswers, 1);
    expect(result.items, isEmpty);
    expect(adapter.lastOptions?.path, '/activities/session-1/result');
    expect(adapter.lastOptions?.data, {
      'answers': [
        {'questionId': 'question-1', 'choiceId': 'a'},
      ],
    });
  });

  test(
    'parses enriched correction result with score feedback and sources',
    () async {
      final adapter = CapturingHttpClientAdapter(
        jsonResponse(enrichedResultJson()),
      );
      final dio = Dio()..httpClientAdapter = adapter;
      final api = HttpActivitiesApi(
        dio: dio,
        getIdToken: () async => 'firebase-id-token',
      );

      final result = await api.submitResult(
        sessionId: 'session-1',
        answers: const [
          DiagnosticQuizAnswer(questionId: 'question-1', choiceId: 'b'),
        ],
      );
      final item = result.items.single;

      expect(result.correctAnswers, 0);
      expect(result.totalQuestions, 1);
      expect(result.score, 0);
      expect(item.questionId, 'question-1');
      expect(item.knowledgeUnitId, 'unit-1');
      expect(item.selectedChoiceId, 'b');
      expect(item.correctChoiceId, 'a');
      expect(item.isCorrect, isFalse);
      expect(item.explanation, 'Le myocarde assure la contraction.');
      expect(item.choiceFeedback.single.choiceId, 'b');
      expect(item.sources.single.text, 'Le myocarde est le muscle cardiaque.');
    },
  );

  test(
    'rejects invalid activity JSON with a controlled format error',
    () async {
      final adapter = CapturingHttpClientAdapter(jsonResponse({'bad': true}));
      final dio = Dio()..httpClientAdapter = adapter;
      final api = HttpActivitiesApi(
        dio: dio,
        getIdToken: () async => 'firebase-id-token',
      );

      await expectLater(
        api.startNextActivity(subjectId: 'subject-1'),
        throwsFormatException,
      );
    },
  );

  test('rejects blank Firebase ID tokens before calling the API', () async {
    final adapter = CapturingHttpClientAdapter(jsonResponse(activityJson()));
    final dio = Dio()..httpClientAdapter = adapter;
    final api = HttpActivitiesApi(dio: dio, getIdToken: () async => '  ');

    await expectLater(
      api.startNextActivity(subjectId: 'subject-1'),
      throwsStateError,
    );

    expect(adapter.fetchCallCount, 0);
  });
}

Map<String, Object?> activityJson() {
  return {
    'sessionId': 'session-1',
    'type': 'diagnostic_quiz',
    'title': 'Diagnostic rapide',
    'questions': [
      {
        'id': 'question-1',
        'prompt': 'Question test',
        'choices': [
          {'id': 'a', 'label': 'Reponse A'},
          {'id': 'b', 'label': 'Reponse B'},
        ],
      },
    ],
  };
}

Map<String, Object?> enrichedActivityJsonWithAccidentalCorrection() {
  return {
    'sessionId': 'session-1',
    'type': 'diagnostic_quiz',
    'version': 2,
    'documentId': 'document-1',
    'subjectId': 'subject-1',
    'title': 'Diagnostic sourcé',
    'questions': [
      {
        'id': 'question-1',
        'knowledgeUnitId': 'unit-1',
        'prompt': 'Question test',
        'difficulty': 'MEDIUM',
        'correctChoiceId': 'a',
        'isCorrect': true,
        'explanation': 'Ne doit jamais être mappée avant submit.',
        'choices': [
          {
            'id': 'a',
            'label': 'Réponse A',
            'feedback': 'Ne doit jamais être mappé avant submit.',
          },
        ],
        'sources': [
          {
            'chunkId': 'chunk-1',
            'pageNumber': null,
            'index': 0,
            'text': 'Ne doit pas être lu avant submit.',
          },
        ],
      },
    ],
  };
}

Map<String, Object?> enrichedResultJson() {
  return {
    'correctAnswers': 0,
    'totalQuestions': 1,
    'score': 0.0,
    'items': [
      {
        'questionId': 'question-1',
        'knowledgeUnitId': 'unit-1',
        'prompt': 'Question test',
        'selectedChoiceId': 'b',
        'correctChoiceId': 'a',
        'isCorrect': false,
        'explanation': 'Le myocarde assure la contraction.',
        'choiceFeedback': [
          {'choiceId': 'b', 'feedback': 'Le péricarde protège le coeur.'},
        ],
        'sources': [
          {
            'chunkId': 'chunk-1',
            'text': 'Le myocarde est le muscle cardiaque.',
            'pageNumber': null,
            'index': 0,
          },
        ],
      },
    ],
  };
}

ResponseBody jsonResponse(Object body) {
  return ResponseBody.fromString(
    jsonEncode(body),
    200,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );
}
