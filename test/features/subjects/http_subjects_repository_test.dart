import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:Neralune/features/subjects/data/http_subjects_repository.dart';
import 'package:Neralune/features/subjects/domain/subject.dart';

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

  test('deletes a subject with a Firebase bearer token', () async {
    final adapter = CapturingHttpClientAdapter(jsonResponse(null));
    final dio = Dio()..httpClientAdapter = adapter;
    final repository = HttpSubjectsRepository(
      dio: dio,
      getIdToken: () async => 'firebase-id-token',
    );

    await repository.deleteSubject('subject-1');

    expect(adapter.lastOptions?.method, 'DELETE');
    expect(adapter.lastOptions?.path, '/subjects/subject-1');
    expect(
      adapter.lastOptions?.headers['Authorization'],
      'Bearer firebase-id-token',
    );
  });

  test('updates a subject through the PATCH endpoint', () async {
    final adapter = CapturingHttpClientAdapter(
      jsonResponse({'id': 'subject-1', 'name': 'Droit', 'priority': 2}),
    );
    final repository = HttpSubjectsRepository(
      dio: Dio()..httpClientAdapter = adapter,
      getIdToken: () async => 'firebase-id-token',
    );

    final subject = await repository.updateSubject(
      id: 'subject id/1',
      name: 'Droit',
      priority: 2,
    );

    expect(subject.name, 'Droit');
    expect(adapter.lastOptions?.method, 'PATCH');
    expect(adapter.lastOptions?.path, '/subjects/subject%20id%2F1');
    expect(adapter.lastOptions?.data, {'name': 'Droit', 'priority': 2});
  });

  test('loads a subject lifecycle decision', () async {
    final adapter = CapturingHttpClientAdapter(
      jsonResponse(subjectLifecycleJson(recommendedAction: 'ARCHIVE')),
    );
    final repository = HttpSubjectsRepository(
      dio: Dio()..httpClientAdapter = adapter,
      getIdToken: () async => 'firebase-id-token',
    );

    final decision = await repository.getSubjectLifecycle('subject-1');

    expect(
      decision.recommendedAction,
      SubjectLifecycleRecommendedAction.archive,
    );
    expect(adapter.lastOptions?.path, '/subjects/subject-1/lifecycle');
  });

  test('archives a subject through the archive endpoint', () async {
    final adapter = CapturingHttpClientAdapter(
      jsonResponse(subjectLifecycleJson(status: 'ARCHIVED')),
    );
    final repository = HttpSubjectsRepository(
      dio: Dio()..httpClientAdapter = adapter,
      getIdToken: () async => 'firebase-id-token',
    );

    final decision = await repository.archiveSubject('subject-1');

    expect(decision.status, SubjectLifecycleStatus.archived);
    expect(adapter.lastOptions?.method, 'POST');
    expect(adapter.lastOptions?.path, '/subjects/subject-1/archive');
  });

  test(
    'maps blocked subject deletion without exposing the technical code',
    () async {
      final adapter = CapturingHttpClientAdapter(
        jsonResponse({
          'code': 'SUBJECT_DELETE_BLOCKED',
          'message':
              'Cette matière contient déjà des cours ou des révisions. Archive-la plutôt que la supprimer.',
        }, statusCode: 409),
      );
      final repository = HttpSubjectsRepository(
        dio: Dio()..httpClientAdapter = adapter,
        getIdToken: () async => 'firebase-id-token',
      );

      await expectLater(
        repository.deleteSubject('subject-1'),
        throwsA(
          isA<SubjectLifecycleBlockedException>().having(
            (error) => error.message,
            'message',
            isNot(contains('SUBJECT_DELETE_BLOCKED')),
          ),
        ),
      );
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

ResponseBody jsonResponse(Object? body, {int statusCode = 200}) {
  return ResponseBody.fromString(
    jsonEncode(body),
    statusCode,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );
}

Map<String, Object?> subjectLifecycleJson({
  String status = 'ACTIVE',
  String recommendedAction = 'DELETE',
}) {
  return {
    'subjectId': 'subject-1',
    'status': status,
    'recommendedAction': recommendedAction,
    'canDelete': recommendedAction == 'DELETE',
    'canArchive': recommendedAction == 'ARCHIVE',
    'canUpdate': status == 'ACTIVE',
    'blockingReasons': const <String>[],
    'userMessage': 'Décision lifecycle matière',
  };
}
