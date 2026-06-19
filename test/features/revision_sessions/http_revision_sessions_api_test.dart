import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:revision_app/features/revision_sessions/data/http_revision_sessions_api.dart';
import 'package:revision_app/features/revision_sessions/data/revision_sessions_api.dart';
import 'package:revision_app/features/revision_sessions/domain/revision_session.dart';

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
  test('starts a revision session with preferred action payload', () async {
    final adapter = CapturingHttpClientAdapter(
      jsonResponse(revisionSessionJson(payload: diagnosticQuizPayloadJson())),
    );
    final dio = Dio()..httpClientAdapter = adapter;
    final api = HttpRevisionSessionsApi(
      dio: dio,
      getIdToken: () async => 'firebase-id-token',
    );

    final response = await api.startRevisionSession(
      subjectId: 'subject-1',
      documentId: 'document-1',
      knowledgeUnitId: 'unit-1',
      preferredAction: RevisionSessionPreferredAction.openQuestion,
    );

    expect(adapter.lastOptions?.path, '/revision-sessions');
    expect(adapter.lastOptions?.data, {
      'subjectId': 'subject-1',
      'documentId': 'document-1',
      'knowledgeUnitId': 'unit-1',
      'preferredAction': 'open_question',
    });
    expect(
      adapter.lastOptions?.headers['Authorization'],
      'Bearer firebase-id-token',
    );
    expect(response.session.id, 'revision-session-1');
    expect(
      response.currentAction?.kind,
      RevisionSessionActionKind.diagnosticQuiz,
    );
    expect(
      response.currentAction?.payload,
      isA<RevisionSessionDiagnosticQuizPayload>(),
    );
  });

  test('parses courseId for course-level revision sessions', () async {
    final adapter = CapturingHttpClientAdapter(
      jsonResponse(
        revisionSessionJson(
          payload: diagnosticQuizPayloadJson(),
          courseId: 'course-1',
        ),
      ),
    );
    final dio = Dio()..httpClientAdapter = adapter;
    final api = HttpRevisionSessionsApi(
      dio: dio,
      getIdToken: () async => 'firebase-id-token',
    );

    final response = await api.getRevisionSession(
      sessionId: 'revision-session-1',
    );

    expect(response.session.courseId, 'course-1');
  });

  test('starts and parses a rich closed launcher payload', () async {
    final adapter = CapturingHttpClientAdapter(
      jsonResponse(revisionSessionJson(payload: richClosedPayloadJson())),
    );
    final dio = Dio()..httpClientAdapter = adapter;
    final api = HttpRevisionSessionsApi(
      dio: dio,
      getIdToken: () async => 'firebase-id-token',
    );

    final response = await api.startRevisionSession(
      subjectId: 'subject-1',
      documentId: 'document-1',
      knowledgeUnitId: 'unit-1',
      preferredAction: RevisionSessionPreferredAction.richClosedExercise,
    );

    expect(adapter.lastOptions?.data, {
      'subjectId': 'subject-1',
      'documentId': 'document-1',
      'knowledgeUnitId': 'unit-1',
      'preferredAction': 'rich_closed_exercise',
    });
    expect(
      response.currentAction?.kind,
      RevisionSessionActionKind.richClosedExercise,
    );
    expect(response.currentAction?.activitySessionId, isNull);
    final payload = response.currentAction?.payload;
    expect(payload, isA<RevisionSessionRichClosedExercisePayload>());
    final launcher = payload as RevisionSessionRichClosedExercisePayload;
    expect(launcher.subjectId, 'subject-1');
    expect(launcher.documentId, 'document-1');
    expect(launcher.knowledgeUnitId, 'unit-1');
    expect(launcher.knowledgeUnitTitle, 'Institutions politiques');
    expect(launcher.estimatedMinutes, 8);
  });

  test('omits null fields from start request', () async {
    final adapter = CapturingHttpClientAdapter(
      jsonResponse(revisionSessionJson(payload: diagnosticQuizPayloadJson())),
    );
    final dio = Dio()..httpClientAdapter = adapter;
    final api = HttpRevisionSessionsApi(
      dio: dio,
      getIdToken: () async => 'firebase-id-token',
    );

    await api.startRevisionSession(subjectId: 'subject-1');

    expect(adapter.lastOptions?.data, {'subjectId': 'subject-1'});
  });

  test('gets a revision session with minimal payload', () async {
    final adapter = CapturingHttpClientAdapter(
      jsonResponse(revisionSessionJson(payload: minimalPayloadJson())),
    );
    final dio = Dio()..httpClientAdapter = adapter;
    final api = HttpRevisionSessionsApi(
      dio: dio,
      getIdToken: () async => 'firebase-id-token',
    );

    final response = await api.getRevisionSession(
      sessionId: 'revision-session-1',
    );

    expect(adapter.lastOptions?.path, '/revision-sessions/revision-session-1');
    final payload = response.currentAction?.payload;
    expect(payload, isA<RevisionSessionMinimalPayload>());
    expect((payload as RevisionSessionMinimalPayload).type, 'open_question');
    expect(payload.sessionId, 'open-session-1');
  });

  test(
    'parses an open question full payload without correction leaks',
    () async {
      final adapter = CapturingHttpClientAdapter(
        jsonResponse(revisionSessionJson(payload: openQuestionPayloadJson())),
      );
      final dio = Dio()..httpClientAdapter = adapter;
      final api = HttpRevisionSessionsApi(
        dio: dio,
        getIdToken: () async => 'firebase-id-token',
      );

      final response = await api.startRevisionSession(
        subjectId: 'subject-1',
        knowledgeUnitId: 'unit-1',
      );

      final payload = response.currentAction?.payload;
      expect(payload, isA<RevisionSessionOpenQuestionPayload>());
      final activity = (payload as RevisionSessionOpenQuestionPayload).activity;
      expect(activity.question.prompt, 'Explique la séparation des pouvoirs.');
      expect(activity.question.sources.single.chunkId, 'chunk-1');
    },
  );

  test('parses currentAction null and history', () async {
    final json = revisionSessionJson(payload: null)..['currentAction'] = null;
    final adapter = CapturingHttpClientAdapter(jsonResponse(json));
    final dio = Dio()..httpClientAdapter = adapter;
    final api = HttpRevisionSessionsApi(
      dio: dio,
      getIdToken: () async => 'firebase-id-token',
    );

    final response = await api.getRevisionSession(
      sessionId: 'revision-session-1',
    );

    expect(response.currentAction, isNull);
    expect(response.history, hasLength(1));
    expect(
      response.history.single.kind,
      RevisionSessionActionKind.openQuestion,
    );
  });

  test('rejects rich closed payloads that contain exercise content', () async {
    final payload = richClosedPayloadJson()
      ..['questions'] = [
        {'id': 'question-1'},
      ]
      ..['correction'] = {'correctChoiceId': 'choice-1'};
    final adapter = CapturingHttpClientAdapter(
      jsonResponse(revisionSessionJson(payload: payload)),
    );
    final dio = Dio()..httpClientAdapter = adapter;
    final api = HttpRevisionSessionsApi(
      dio: dio,
      getIdToken: () async => 'firebase-id-token',
    );

    final response = await api.getRevisionSession(
      sessionId: 'revision-session-1',
    );

    expect(
      response.currentAction?.payload,
      isA<RevisionSessionUnknownPayload>(),
    );
  });

  test('refuses an empty token before network call', () async {
    final adapter = CapturingHttpClientAdapter(
      jsonResponse(revisionSessionJson(payload: minimalPayloadJson())),
    );
    final dio = Dio()..httpClientAdapter = adapter;
    final api = HttpRevisionSessionsApi(dio: dio, getIdToken: () async => ' ');

    await expectLater(
      api.getRevisionSession(sessionId: 'revision-session-1'),
      throwsStateError,
    );
    expect(adapter.fetchCallCount, 0);
  });

  test('completes a revision session with an empty body', () async {
    final adapter = CapturingHttpClientAdapter(
      jsonResponse(revisionSessionResultJson()),
    );
    final dio = Dio()..httpClientAdapter = adapter;
    final api = HttpRevisionSessionsApi(
      dio: dio,
      getIdToken: () async => 'firebase-id-token',
    );

    final result = await api.completeRevisionSession(
      sessionId: 'revision-session-1',
    );

    expect(
      adapter.lastOptions?.path,
      '/revision-sessions/revision-session-1/complete',
    );
    expect(adapter.lastOptions?.data, const <String, Object?>{});
    expect(result.summary.correctAnswers, 4);
    expect(result.summary.totalQuestions, 6);
    expect(result.knowledgeUnits.single.state.name, 'toReview');
  });

  test('gets a revision session result', () async {
    final adapter = CapturingHttpClientAdapter(
      jsonResponse(revisionSessionResultJson()),
    );
    final dio = Dio()..httpClientAdapter = adapter;
    final api = HttpRevisionSessionsApi(
      dio: dio,
      getIdToken: () async => 'firebase-id-token',
    );

    final result = await api.getRevisionSessionResult(
      sessionId: 'revision-session-1',
    );

    expect(
      adapter.lastOptions?.path,
      '/revision-sessions/revision-session-1/result',
    );
    expect(result.session.courseId, 'course-1');
    expect(result.session.mode, RevisionSessionMode.quick);
    expect(result.summary.durationSeconds, 252);
  });

  test('maps result 404 and 409 responses', () async {
    final adapter = CapturingHttpClientAdapter(
      ResponseBody.fromString(
        jsonEncode({'message': 'Revision session not found'}),
        404,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      ),
    );
    final dio = Dio()..httpClientAdapter = adapter;
    final api = HttpRevisionSessionsApi(
      dio: dio,
      getIdToken: () async => 'firebase-id-token',
    );

    await expectLater(
      api.getRevisionSessionResult(sessionId: 'missing-session'),
      throwsA(isA<RevisionSessionNotFoundException>()),
    );

    adapter.response = ResponseBody.fromString(
      jsonEncode({'message': 'Revision session not completed'}),
      409,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );

    await expectLater(
      api.completeRevisionSession(sessionId: 'revision-session-1'),
      throwsA(isA<RevisionSessionResultNotReadyException>()),
    );
  });

  test('rejects invalid revision session responses', () async {
    final adapter = CapturingHttpClientAdapter(
      jsonResponse({'session': null, 'currentAction': null, 'history': []}),
    );
    final dio = Dio()..httpClientAdapter = adapter;
    final api = HttpRevisionSessionsApi(
      dio: dio,
      getIdToken: () async => 'firebase-id-token',
    );

    await expectLater(
      api.getRevisionSession(sessionId: 'revision-session-1'),
      throwsFormatException,
    );
  });
}

ResponseBody jsonResponse(Object? payload) {
  return ResponseBody.fromString(
    jsonEncode(payload),
    200,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );
}

Map<String, Object?> revisionSessionJson({
  required Object? payload,
  String? courseId,
}) {
  final actionKind = payload == null ? 'OPEN_QUESTION' : actionKindFor(payload);
  final isRichClosed = actionKind == 'RICH_CLOSED_EXERCISE';

  return {
    'session': {
      'id': 'revision-session-1',
      'status': 'STARTED',
      'mode': 'QUICK',
      'subjectId': 'subject-1',
      'courseId': courseId,
      'documentId': null,
      'knowledgeUnitId': 'unit-1',
      'createdAt': '2026-06-15T12:00:00.000Z',
      'completedAt': null,
    },
    'currentAction': {
      'id': 'action-1',
      'kind': actionKind,
      'status': 'READY',
      'displayOrder': 0,
      'activitySessionId': isRichClosed ? null : 'activity-session-1',
      'documentId': null,
      'knowledgeUnitId': 'unit-1',
      'payload': payload,
    },
    'history': [
      {
        'id': 'action-1',
        'kind': actionKind,
        'status': 'READY',
        'displayOrder': 0,
        'activitySessionId': isRichClosed ? null : 'activity-session-1',
        'documentId': null,
        'knowledgeUnitId': 'unit-1',
      },
    ],
  };
}

Map<String, Object?> revisionSessionResultJson({
  String? state = 'TO_REVIEW',
  String? courseId = 'course-1',
}) {
  return {
    'session': {
      'id': 'revision-session-1',
      'subjectId': 'subject-1',
      'courseId': courseId,
      'mode': 'QUICK',
      'status': 'COMPLETED',
      'createdAt': '2026-06-15T12:00:00.000Z',
      'completedAt': '2026-06-15T12:04:12.000Z',
    },
    'summary': {
      'correctAnswers': 4,
      'totalQuestions': 6,
      'score': 0.6666666667,
      'durationSeconds': 252,
    },
    'knowledgeUnits': [
      {
        'knowledgeUnitId': 'unit-1',
        'title': 'Séparation des pouvoirs',
        'correctAnswers': 4,
        'totalQuestions': 6,
        'score': 0.6666666667,
        'state': state,
      },
    ],
  };
}

String actionKindFor(Object payload) {
  if (payload is Map && payload['type'] == 'diagnostic_quiz') {
    return 'DIAGNOSTIC_QUIZ';
  }
  if (payload is Map && payload['type'] == 'rich_closed_exercise') {
    return 'RICH_CLOSED_EXERCISE';
  }
  return 'OPEN_QUESTION';
}

Map<String, Object?> minimalPayloadJson() {
  return {'type': 'open_question', 'sessionId': 'open-session-1'};
}

Map<String, Object?> diagnosticQuizPayloadJson() {
  return {
    'sessionId': 'quiz-session-1',
    'type': 'diagnostic_quiz',
    'version': 3,
    'title': 'QCM de session',
    'documentId': null,
    'subjectId': 'subject-1',
    'questions': [
      {
        'id': 'question-1',
        'knowledgeUnitId': 'unit-1',
        'prompt': 'Question test',
        'difficulty': 'MEDIUM',
        'correctChoiceId': 'choice-1',
        'explanation': 'Ne doit pas être mappé.',
        'sources': [
          {
            'chunkId': 'chunk-1',
            'pageNumber': null,
            'index': 0,
            'text': 'Texte source complet interdit.',
          },
        ],
        'choices': [
          {'id': 'choice-1', 'label': 'Réponse A', 'feedback': 'Interdit'},
          {'id': 'choice-2', 'label': 'Réponse B'},
        ],
      },
    ],
  };
}

Map<String, Object?> openQuestionPayloadJson() {
  return {
    'sessionId': 'open-session-1',
    'type': 'open_question',
    'version': 1,
    'subjectId': 'subject-1',
    'documentId': null,
    'knowledgeUnitId': 'unit-1',
    'score': 20,
    'feedback': 'Interdit avant submit.',
    'modelAnswer': 'Interdit avant submit.',
    'question': {
      'id': 'open-question-1',
      'prompt': 'Explique la séparation des pouvoirs.',
      'instructions': 'Réponds en quelques phrases.',
      'maxAnswerLength': 4000,
      'sources': [
        {
          'chunkId': 'chunk-1',
          'pageNumber': null,
          'index': 0,
          'text': 'Texte source complet interdit.',
        },
      ],
    },
  };
}

Map<String, Object?> richClosedPayloadJson() {
  return {
    'type': 'rich_closed_exercise',
    'subjectId': 'subject-1',
    'documentId': 'document-1',
    'knowledgeUnitId': 'unit-1',
    'knowledgeUnitTitle': 'Institutions politiques',
    'reason': 'Questions riches recommandées.',
    'estimatedMinutes': 8,
    'preferredAction': 'rich_closed_exercise',
  };
}
