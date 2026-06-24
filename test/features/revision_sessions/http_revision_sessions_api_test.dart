import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:Neralune/features/activities/domain/diagnostic_quiz_activity.dart';
import 'package:Neralune/features/revision_sessions/data/http_revision_sessions_api.dart';
import 'package:Neralune/features/revision_sessions/data/revision_sessions_api.dart';
import 'package:Neralune/features/revision_sessions/domain/revision_session.dart';

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
    expect(
      result.corrections.single.prompt,
      'Quelle institution vote la loi ?',
    );
    expect(result.corrections.single.selectedAnswers, ['Le préfet']);
    expect(result.corrections.single.correctAnswers, ['Le Parlement']);
  });

  test(
    'gets an exam preparation session with diagnostic quiz payload',
    () async {
      final adapter = CapturingHttpClientAdapter(
        jsonResponse(
          revisionSessionJson(
            payload: diagnosticQuizPayloadJson(),
            courseId: 'course-1',
            mode: 'EXAM',
            sessionId: 'exam-session-1',
          ),
        ),
      );
      final dio = Dio()..httpClientAdapter = adapter;
      final api = HttpRevisionSessionsApi(
        dio: dio,
        getIdToken: () async => 'firebase-id-token',
      );

      final response = await api.getExamPreparationSession(
        sessionId: 'exam-session-1',
      );

      expect(
        adapter.lastOptions?.path,
        '/exam-preparation/sessions/exam-session-1',
      );
      expect(response.session.id, 'exam-session-1');
      expect(response.session.mode, RevisionSessionMode.exam);
      expect(
        response.currentAction?.payload,
        isA<RevisionSessionDiagnosticQuizPayload>(),
      );
    },
  );

  test('submits exam preparation answers', () async {
    final adapter = CapturingHttpClientAdapter(
      jsonResponse(
        revisionSessionResultJson(mode: 'EXAM', sessionId: 'exam-session-1'),
      ),
    );
    final dio = Dio()..httpClientAdapter = adapter;
    final api = HttpRevisionSessionsApi(
      dio: dio,
      getIdToken: () async => 'firebase-id-token',
    );

    final result = await api.submitExamPreparationSession(
      sessionId: 'exam-session-1',
      answers: const [
        DiagnosticQuizAnswer(questionId: 'question-1', choiceId: 'choice-1'),
        DiagnosticQuizAnswer(
          questionId: 'question-2',
          choiceIds: ['choice-2', 'choice-3'],
        ),
      ],
    );

    expect(
      adapter.lastOptions?.path,
      '/exam-preparation/sessions/exam-session-1/submit',
    );
    expect(adapter.lastOptions?.data, {
      'answers': [
        {'questionId': 'question-1', 'choiceId': 'choice-1'},
        {
          'questionId': 'question-2',
          'choiceIds': ['choice-2', 'choice-3'],
        },
      ],
    });
    expect(result.session.mode, RevisionSessionMode.exam);
  });

  test('gets an exam preparation result', () async {
    final adapter = CapturingHttpClientAdapter(
      jsonResponse(
        revisionSessionResultJson(mode: 'EXAM', sessionId: 'exam-session-1'),
      ),
    );
    final dio = Dio()..httpClientAdapter = adapter;
    final api = HttpRevisionSessionsApi(
      dio: dio,
      getIdToken: () async => 'firebase-id-token',
    );

    final result = await api.getExamPreparationSessionResult(
      sessionId: 'exam-session-1',
    );

    expect(
      adapter.lastOptions?.path,
      '/exam-preparation/sessions/exam-session-1/result',
    );
    expect(result.session.id, 'exam-session-1');
    expect(result.session.mode, RevisionSessionMode.exam);
  });

  test('rejects diagnostic quiz correction leaks before submit', () async {
    final adapter = CapturingHttpClientAdapter(
      jsonResponse(
        revisionSessionJson(
          payload: diagnosticQuizPayloadJson(includeCorrectionLeak: true),
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

    expect(
      response.currentAction?.payload,
      isA<RevisionSessionUnknownPayload>(),
    );
  });

  test('flags a revision session question', () async {
    final adapter = CapturingHttpClientAdapter(
      jsonResponse({'status': 'flagged'}),
    );
    final dio = Dio()..httpClientAdapter = adapter;
    final api = HttpRevisionSessionsApi(
      dio: dio,
      getIdToken: () async => 'firebase-id-token',
    );

    await api.flagRevisionSessionQuestion(
      sessionId: 'revision-session-1',
      questionId: 'question-1',
      reason: 'ambiguë',
    );

    expect(
      adapter.lastOptions?.path,
      '/revision-sessions/revision-session-1/questions/question-1/flag',
    );
    expect(adapter.lastOptions?.data, {'reason': 'ambiguë'});
    expect(
      adapter.lastOptions?.headers['Authorization'],
      'Bearer firebase-id-token',
    );
  });

  test('saves a draft answer for a revision session question', () async {
    final adapter = CapturingHttpClientAdapter(
      jsonResponse(
        revisionSessionJson(
          payload: diagnosticQuizPayloadJson(),
          draftAnswers: [
            {
              'questionId': 'question-1',
              'selectedChoiceIds': ['choice-1'],
              'updatedAt': '2026-06-15T12:01:00.000Z',
            },
          ],
        ),
      ),
    );
    final dio = Dio()..httpClientAdapter = adapter;
    final api = HttpRevisionSessionsApi(
      dio: dio,
      getIdToken: () async => 'firebase-id-token',
    );

    final response = await api.saveDraftAnswer(
      sessionId: 'revision-session-1',
      questionId: 'question-1',
      selectedChoiceIds: ['choice-1'],
    );

    expect(adapter.lastOptions?.method, 'PUT');
    expect(
      adapter.lastOptions?.path,
      '/revision-sessions/revision-session-1/questions/question-1/draft-answer',
    );
    expect(adapter.lastOptions?.data, {
      'selectedChoiceIds': ['choice-1'],
    });
    expect(response.draftAnswers.single.questionId, 'question-1');
    expect(response.draftAnswers.single.selectedChoiceIds, ['choice-1']);
  });

  test('deletes a draft answer for a revision session question', () async {
    final adapter = CapturingHttpClientAdapter(
      jsonResponse(revisionSessionJson(payload: diagnosticQuizPayloadJson())),
    );
    final dio = Dio()..httpClientAdapter = adapter;
    final api = HttpRevisionSessionsApi(
      dio: dio,
      getIdToken: () async => 'firebase-id-token',
    );

    await api.deleteDraftAnswer(
      sessionId: 'revision-session-1',
      questionId: 'question-1',
    );

    expect(adapter.lastOptions?.method, 'DELETE');
    expect(
      adapter.lastOptions?.path,
      '/revision-sessions/revision-session-1/questions/question-1/draft-answer',
    );
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
  String mode = 'QUICK',
  String sessionId = 'revision-session-1',
  List<Map<String, Object?>> draftAnswers = const [],
}) {
  final actionKind = payload == null ? 'OPEN_QUESTION' : actionKindFor(payload);
  final isRichClosed = actionKind == 'RICH_CLOSED_EXERCISE';

  return {
    'session': {
      'id': sessionId,
      'status': 'STARTED',
      'mode': mode,
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
    'draftAnswers': draftAnswers,
  };
}

Map<String, Object?> revisionSessionResultJson({
  String? state = 'TO_REVIEW',
  String? courseId = 'course-1',
  String mode = 'QUICK',
  String sessionId = 'revision-session-1',
}) {
  return {
    'session': {
      'id': sessionId,
      'subjectId': 'subject-1',
      'courseId': courseId,
      'mode': mode,
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
    'corrections': [
      {
        'prompt': 'Quelle institution vote la loi ?',
        'isCorrect': false,
        'selectedAnswers': ['Le préfet'],
        'correctAnswers': ['Le Parlement'],
        'explanation': 'Le Parlement vote la loi.',
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

Map<String, Object?> diagnosticQuizPayloadJson({
  bool includeCorrectionLeak = false,
}) {
  final question = <String, Object?>{
    'id': 'question-1',
    'knowledgeUnitId': 'unit-1',
    'prompt': 'Question test',
    'difficulty': 'MEDIUM',
    'sources': [
      {
        'chunkId': 'chunk-1',
        'pageNumber': null,
        'index': 0,
        'text': 'Texte source complet interdit.',
      },
    ],
    'choices': [
      {'id': 'choice-1', 'label': 'Réponse A'},
      {'id': 'choice-2', 'label': 'Réponse B'},
    ],
  };
  if (includeCorrectionLeak) {
    question
      ..['correctChoiceId'] = 'choice-1'
      ..['explanation'] = 'Ne doit pas être mappé.'
      ..['choices'] = [
        {'id': 'choice-1', 'label': 'Réponse A', 'feedback': 'Interdit'},
        {'id': 'choice-2', 'label': 'Réponse B'},
      ];
  }

  return {
    'sessionId': 'quiz-session-1',
    'type': 'diagnostic_quiz',
    'version': 3,
    'title': 'QCM de session',
    'documentId': null,
    'subjectId': 'subject-1',
    'questions': [question],
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
