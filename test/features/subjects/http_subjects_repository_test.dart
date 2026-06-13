import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:revision_app/features/subjects/data/http_subjects_repository.dart';

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
  test('lists subjects with a Firebase bearer token', () async {
    final adapter = CapturingHttpClientAdapter(
      jsonResponse([
        {'id': 'subject-1', 'name': 'Anatomie', 'priority': 4},
      ]),
    );
    final dio = Dio()..httpClientAdapter = adapter;
    final repository = HttpSubjectsRepository(
      dio: dio,
      getIdToken: () async => 'firebase-id-token',
    );

    final subjects = await repository.listSubjects();

    expect(subjects.single.name, 'Anatomie');
    expect(adapter.lastOptions?.path, '/subjects');
    expect(
      adapter.lastOptions?.headers['Authorization'],
      'Bearer firebase-id-token',
    );
  });

  test(
    'creates subjects without leaking weekly minutes into the API payload',
    () async {
      final adapter = CapturingHttpClientAdapter(
        jsonResponse({'id': 'subject-1', 'name': 'Anatomie', 'priority': 4}),
      );
      final dio = Dio()..httpClientAdapter = adapter;
      final repository = HttpSubjectsRepository(
        dio: dio,
        getIdToken: () async => 'firebase-id-token',
      );

      final subject = await repository.createSubject(
        name: 'Anatomie',
        priority: 4,
        weeklyMinutes: 180,
      );

      expect(subject.weeklyMinutes, 180);
      expect(adapter.lastOptions?.path, '/subjects');
      expect(adapter.lastOptions?.data, {'name': 'Anatomie', 'priority': 4});
    },
  );

  test('rejects blank Firebase ID tokens before calling the API', () async {
    final adapter = CapturingHttpClientAdapter(jsonResponse([]));
    final dio = Dio()..httpClientAdapter = adapter;
    final repository = HttpSubjectsRepository(
      dio: dio,
      getIdToken: () async => '  ',
    );

    await expectLater(repository.listSubjects(), throwsStateError);

    expect(adapter.fetchCallCount, 0);
  });
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
