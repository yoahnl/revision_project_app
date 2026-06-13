import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:revision_app/features/today/data/http_today_repository.dart';

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

    expect(plan.items.single.subjectName, 'Anatomie');
    expect(plan.items.single.masteryScore, 0.2);
    expect(adapter.lastOptions?.path, '/today');
    expect(
      adapter.lastOptions?.headers['Authorization'],
      'Bearer firebase-id-token',
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
        'estimatedMinutes': 15,
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
