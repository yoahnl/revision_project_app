import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:revision_app/features/today/data/http_today_repository.dart';
import 'package:revision_app/features/today/domain/today_plan.dart';

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
  test('loads today plan with a Firebase bearer token', () async {
    final adapter = CapturingHttpClientAdapter(jsonResponse(todayJson()));
    final dio = Dio()..httpClientAdapter = adapter;
    final repository = HttpTodayRepository(
      dio: dio,
      getIdToken: () async => 'firebase-id-token',
    );

    final plan = await repository.getTodayPlan();

    expect(plan.items, hasLength(3));
    expect(plan.items.first.id, 'subject-1:unit-1:diagnostic_quiz');
    expect(plan.items.first.subjectName, 'Anatomie');
    expect(plan.items.first.knowledgeUnitId, 'unit-1');
    expect(plan.items.first.knowledgeUnitTitle, 'Cycle cardiaque');
    expect(plan.items.first.masteryScore, 0.2);
    expect(plan.items.first.action, TodayPlanActionType.diagnosticQuiz);
    expect(plan.items.first.reasonCode, TodayPlanReasonCode.lowMastery);
    expect(plan.items.first.reason, 'À revoir en priorité.');
    expect(plan.items.first.priority, 610);
    expect(plan.items.first.startPayload.subjectId, 'subject-1');
    expect(plan.items.first.startPayload.knowledgeUnitId, 'unit-1');
    expect(
      plan.items.first.startPayload.preferredAction,
      TodayPlanPreferredAction.diagnosticQuiz,
    );
    expect(plan.items[1].masteryScore, isNull);
    expect(plan.items[1].action, TodayPlanActionType.openQuestion);
    expect(plan.items[1].startPayload.preferredAction, isNull);
    expect(plan.items[2].knowledgeUnitId, isNull);
    expect(plan.items[2].knowledgeUnitTitle, isNull);
    expect(plan.items[2].action, TodayPlanActionType.revisionSession);
    expect(adapter.lastOptions?.path, '/today');
    expect(
      adapter.lastOptions?.headers['Authorization'],
      'Bearer firebase-id-token',
    );
  });

  test('rejects unknown today action values', () async {
    final body = todayJson();
    final items = body['items']! as List<Object?>;
    final firstItem = Map<String, Object?>.from(
      items.first! as Map<String, Object?>,
    );
    firstItem['action'] = 'flashcards';
    items[0] = firstItem;
    final adapter = CapturingHttpClientAdapter(jsonResponse(body));
    final dio = Dio()..httpClientAdapter = adapter;
    final repository = HttpTodayRepository(
      dio: dio,
      getIdToken: () async => 'firebase-id-token',
    );

    await expectLater(repository.getTodayPlan(), throwsFormatException);
  });

  test('rejects unknown today reason code values', () async {
    final body = todayJson();
    final items = body['items']! as List<Object?>;
    final firstItem = Map<String, Object?>.from(
      items.first! as Map<String, Object?>,
    );
    firstItem['reasonCode'] = 'RANDOM';
    items[0] = firstItem;
    final adapter = CapturingHttpClientAdapter(jsonResponse(body));
    final dio = Dio()..httpClientAdapter = adapter;
    final repository = HttpTodayRepository(
      dio: dio,
      getIdToken: () async => 'firebase-id-token',
    );

    await expectLater(repository.getTodayPlan(), throwsFormatException);
  });

  test('rejects today items without start payload subject id', () async {
    final body = todayJson();
    final items = body['items']! as List<Object?>;
    final firstItem = Map<String, Object?>.from(
      items.first! as Map<String, Object?>,
    );
    firstItem['startPayload'] = {'knowledgeUnitId': 'unit-1'};
    items[0] = firstItem;
    final adapter = CapturingHttpClientAdapter(jsonResponse(body));
    final dio = Dio()..httpClientAdapter = adapter;
    final repository = HttpTodayRepository(
      dio: dio,
      getIdToken: () async => 'firebase-id-token',
    );

    await expectLater(repository.getTodayPlan(), throwsFormatException);
  });

  test('rejects invalid generatedAt and items shape', () async {
    final invalidGeneratedAt = CapturingHttpClientAdapter(
      jsonResponse({'generatedAt': 'not-a-date', 'items': []}),
    );
    final invalidItems = CapturingHttpClientAdapter(
      jsonResponse({'generatedAt': '2026-06-13T10:00:00.000Z', 'items': {}}),
    );

    await expectLater(
      HttpTodayRepository(
        dio: Dio()..httpClientAdapter = invalidGeneratedAt,
        getIdToken: () async => 'firebase-id-token',
      ).getTodayPlan(),
      throwsFormatException,
    );
    await expectLater(
      HttpTodayRepository(
        dio: Dio()..httpClientAdapter = invalidItems,
        getIdToken: () async => 'firebase-id-token',
      ).getTodayPlan(),
      throwsFormatException,
    );
  });

  test('rejects blank Firebase ID tokens before calling the API', () async {
    final adapter = CapturingHttpClientAdapter(jsonResponse(todayJson()));
    final dio = Dio()..httpClientAdapter = adapter;
    final repository = HttpTodayRepository(
      dio: dio,
      getIdToken: () async => '  ',
    );

    await expectLater(repository.getTodayPlan(), throwsStateError);

    expect(adapter.fetchCallCount, 0);
  });
}

Map<String, Object?> todayJson() {
  return {
    'generatedAt': '2026-06-13T10:00:00.000Z',
    'items': [
      {
        'subjectId': 'subject-1',
        'subjectName': 'Anatomie',
        'knowledgeUnitId': 'unit-1',
        'knowledgeUnitTitle': 'Cycle cardiaque',
        'masteryScore': 0.2,
        'action': 'diagnostic_quiz',
        'estimatedMinutes': 12,
        'id': 'subject-1:unit-1:diagnostic_quiz',
        'priority': 610,
        'reasonCode': 'LOW_MASTERY',
        'reason': 'À revoir en priorité.',
        'startPayload': {
          'subjectId': 'subject-1',
          'knowledgeUnitId': 'unit-1',
          'preferredAction': 'diagnostic_quiz',
        },
      },
      {
        'id': 'subject-1:unit-2:open_question',
        'subjectId': 'subject-1',
        'subjectName': 'Anatomie',
        'knowledgeUnitId': 'unit-2',
        'knowledgeUnitTitle': 'Valves',
        'masteryScore': null,
        'action': 'open_question',
        'estimatedMinutes': 18,
        'priority': 590,
        'reasonCode': 'MIX_ACTIVITY_TYPE',
        'reason': 'Change de format.',
        'startPayload': {'subjectId': 'subject-1', 'knowledgeUnitId': 'unit-2'},
      },
      {
        'id': 'subject-2:null:revision_session',
        'subjectId': 'subject-2',
        'subjectName': 'Droit',
        'knowledgeUnitId': null,
        'knowledgeUnitTitle': null,
        'masteryScore': 0.7,
        'action': 'revision_session',
        'estimatedMinutes': 25,
        'priority': 500,
        'reasonCode': 'START_REVISION_SESSION',
        'reason': 'Lance une session guidée.',
        'startPayload': {'subjectId': 'subject-2'},
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
