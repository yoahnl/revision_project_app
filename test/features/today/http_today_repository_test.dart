import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:Neralune/features/today/data/http_today_repository.dart';
import 'package:Neralune/features/today/domain/today_plan.dart';

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

    expect(plan.primaryItemId, 'subject-1:unit-1:diagnostic_quiz');
    expect(plan.continuationItemIds, [
      'subject-1:unit-2:open_question',
      'subject-1:unit-2:rich_closed_exercise',
    ]);
    expect(plan.weeklyObjective?.targetMinutes, 240);
    expect(plan.weeklyObjective?.completedMinutes, isNull);
    expect(plan.weeklyObjective?.progressRatio, isNull);
    expect(plan.weeklyObjective?.label, 'Objectif : 4 h cette semaine');
    expect(plan.weeklyObjective?.status, TodayWeeklyObjectiveStatus.targetOnly);
    expect(plan.emptyState?.title, 'Rien de prêt pour aujourd’hui');
    expect(plan.emptyState?.actionLabel, 'Voir mes cours');
    expect(plan.emptyState?.actionKind, TodayEmptyActionKind.openCourses);
    expect(plan.items, hasLength(4));
    expect(plan.items.first.id, 'subject-1:unit-1:diagnostic_quiz');
    expect(plan.items.first.subjectName, 'Anatomie');
    expect(plan.items.first.knowledgeUnitId, 'unit-1');
    expect(plan.items.first.knowledgeUnitTitle, 'Cycle cardiaque');
    expect(plan.items.first.masteryScore, 0.2);
    expect(plan.items.first.action, TodayPlanActionType.diagnosticQuiz);
    expect(plan.items.first.reasonCode, TodayPlanReasonCode.lowMastery);
    expect(plan.items.first.reason, 'À revoir en priorité.');
    expect(plan.items.first.priority, 610);
    expect(plan.items.first.role, TodayPlanItemRole.primary);
    expect(plan.items.first.display?.title, 'Cycle cardiaque');
    expect(plan.items.first.display?.badgeLabel, 'ANATOMIE');
    expect(plan.items.first.display?.metaLabel, '12 min · session guidée');
    expect(plan.items.first.display?.actionLabel, 'Réviser maintenant');
    expect(plan.items.first.startPayload.subjectId, 'subject-1');
    expect(plan.items.first.startPayload.knowledgeUnitId, 'unit-1');
    expect(
      plan.items.first.startPayload.preferredAction,
      TodayPlanPreferredAction.diagnosticQuiz,
    );
    expect(plan.items[1].masteryScore, isNull);
    expect(plan.items[1].action, TodayPlanActionType.openQuestion);
    expect(plan.items[1].startPayload.preferredAction, isNull);
    expect(plan.items[2].documentId, 'document-1');
    expect(plan.items[2].action, TodayPlanActionType.richClosedExercise);
    expect(plan.items[2].reasonCode, TodayPlanReasonCode.richClosedPractice);
    expect(plan.items[2].startPayload.documentId, 'document-1');
    expect(plan.items[2].startPayload.knowledgeUnitId, 'unit-2');
    expect(plan.items[3].knowledgeUnitId, isNull);
    expect(plan.items[3].knowledgeUnitTitle, isNull);
    expect(plan.items[3].action, TodayPlanActionType.revisionSession);
    expect(adapter.lastOptions?.path, '/today');
    expect(
      adapter.lastOptions?.headers['Authorization'],
      'Bearer firebase-id-token',
    );
  });

  test(
    'keeps reading the legacy today contract without enriched fields',
    () async {
      final body = todayJson()
        ..remove('primaryItemId')
        ..remove('continuationItemIds')
        ..remove('weeklyObjective')
        ..remove('emptyState');
      final items = body['items']! as List<Object?>;
      for (var index = 0; index < items.length; index += 1) {
        final item =
            Map<String, Object?>.from(items[index]! as Map<String, Object?>)
              ..remove('role')
              ..remove('display');
        items[index] = item;
      }
      final adapter = CapturingHttpClientAdapter(jsonResponse(body));
      final dio = Dio()..httpClientAdapter = adapter;
      final repository = HttpTodayRepository(
        dio: dio,
        getIdToken: () async => 'firebase-id-token',
      );

      final plan = await repository.getTodayPlan();

      expect(plan.primaryItemId, isNull);
      expect(plan.continuationItemIds, isEmpty);
      expect(plan.weeklyObjective, isNull);
      expect(plan.emptyState, isNull);
      expect(plan.items.first.role, isNull);
      expect(plan.items.first.display, isNull);
      expect(plan.items.first.action, TodayPlanActionType.diagnosticQuiz);
    },
  );

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

  test('rejects rich closed actions without a knowledge unit id', () async {
    final body = todayJson();
    final items = body['items']! as List<Object?>;
    final richClosedItem = Map<String, Object?>.from(
      items[2]! as Map<String, Object?>,
    );
    richClosedItem['knowledgeUnitId'] = null;
    richClosedItem['startPayload'] = {'subjectId': 'subject-1'};
    items[2] = richClosedItem;
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
    'primaryItemId': 'subject-1:unit-1:diagnostic_quiz',
    'continuationItemIds': [
      'subject-1:unit-2:open_question',
      'subject-1:unit-2:rich_closed_exercise',
    ],
    'weeklyObjective': {
      'targetMinutes': 240,
      'completedMinutes': null,
      'progressRatio': null,
      'label': 'Objectif : 4 h cette semaine',
      'status': 'TARGET_ONLY',
    },
    'emptyState': {
      'title': 'Rien de prêt pour aujourd’hui',
      'message':
          'Ajoute un cours ou une source pour que Neralune prépare ta prochaine session.',
      'actionLabel': 'Voir mes cours',
      'actionKind': 'OPEN_COURSES',
    },
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
        'role': 'PRIMARY',
        'display': {
          'title': 'Cycle cardiaque',
          'subjectLabel': 'Anatomie',
          'badgeLabel': 'ANATOMIE',
          'durationLabel': '12 min',
          'metaLabel': '12 min · session guidée',
          'recommendation':
              'Cette notion semble fragile : la revoir maintenant aidera à consolider tes bases.',
          'actionLabel': 'Réviser maintenant',
          'unavailableReason': null,
        },
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
        'role': 'CONTINUATION',
        'display': {
          'title': 'Valves',
          'subjectLabel': 'Anatomie',
          'badgeLabel': 'ANATOMIE',
          'durationLabel': '18 min',
          'metaLabel': '18 min · session guidée',
          'recommendation':
              'Changer d’angle peut t’aider à mieux ancrer la notion.',
          'actionLabel': 'Continuer',
          'unavailableReason': null,
        },
        'startPayload': {'subjectId': 'subject-1', 'knowledgeUnitId': 'unit-2'},
      },
      {
        'id': 'subject-1:unit-2:rich_closed_exercise',
        'subjectId': 'subject-1',
        'subjectName': 'Anatomie',
        'documentId': 'document-1',
        'knowledgeUnitId': 'unit-2',
        'knowledgeUnitTitle': 'Valves',
        'masteryScore': null,
        'action': 'rich_closed_exercise',
        'estimatedMinutes': 8,
        'priority': 585,
        'reasonCode': 'RICH_CLOSED_PRACTICE',
        'reason': 'Questions riches recommandées.',
        'role': 'CONTINUATION',
        'display': {
          'title': 'Valves',
          'subjectLabel': 'Anatomie',
          'badgeLabel': 'ANATOMIE',
          'durationLabel': '8 min',
          'metaLabel': '8 min · session guidée',
          'recommendation':
              'Cette notion mérite une session cadrée avec feedback.',
          'actionLabel': 'Continuer',
          'unavailableReason': null,
        },
        'startPayload': {
          'subjectId': 'subject-1',
          'documentId': 'document-1',
          'knowledgeUnitId': 'unit-2',
        },
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
        'role': 'CONTINUATION',
        'display': {
          'title': 'Droit',
          'subjectLabel': 'Droit',
          'badgeLabel': 'DROIT',
          'durationLabel': '25 min',
          'metaLabel': '25 min · session guidée',
          'recommendation':
              'Neralune a assez de contexte pour te guider sans te disperser.',
          'actionLabel': 'Continuer',
          'unavailableReason': null,
        },
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
