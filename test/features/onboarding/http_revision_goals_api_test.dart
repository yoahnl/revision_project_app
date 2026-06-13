import 'dart:async';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:revision_app/features/onboarding/data/http_revision_goals_api.dart';
import 'package:revision_app/features/onboarding/domain/revision_goal.dart';

class CapturingHttpClientAdapter implements HttpClientAdapter {
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
    return ResponseBody.fromString('', 201);
  }
}

void main() {
  test('saves revision goals with a Firebase bearer token', () async {
    final adapter = CapturingHttpClientAdapter();
    final dio = Dio()..httpClientAdapter = adapter;
    final api = HttpRevisionGoalsApi(
      dio: dio,
      getIdToken: () async => 'firebase-id-token',
    );

    await api.saveRevisionGoal(
      RevisionGoal(targetDate: DateTime.utc(2026, 7, 13), weeklyMinutes: 180),
    );

    expect(adapter.lastOptions?.path, '/revision-goals');
    expect(
      adapter.lastOptions?.headers['Authorization'],
      'Bearer firebase-id-token',
    );
    expect(adapter.lastOptions?.data, {
      'targetDate': '2026-07-13T00:00:00.000Z',
      'weeklyMinutes': 180,
    });
  });

  test('rejects blank Firebase ID tokens before calling the API', () async {
    final adapter = CapturingHttpClientAdapter();
    final dio = Dio()..httpClientAdapter = adapter;
    final api = HttpRevisionGoalsApi(dio: dio, getIdToken: () async => '  ');

    await expectLater(
      api.saveRevisionGoal(
        RevisionGoal(targetDate: DateTime.utc(2026, 7, 13), weeklyMinutes: 180),
      ),
      throwsStateError,
    );

    expect(adapter.fetchCallCount, 0);
  });
}
