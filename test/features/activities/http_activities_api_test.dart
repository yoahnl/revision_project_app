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
    expect(adapter.lastOptions?.path, '/activities/session-1/result');
    expect(adapter.lastOptions?.data, {
      'answers': [
        {'questionId': 'question-1', 'choiceId': 'a'},
      ],
    });
  });

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

ResponseBody jsonResponse(Object body) {
  return ResponseBody.fromString(
    jsonEncode(body),
    200,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );
}
