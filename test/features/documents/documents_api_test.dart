import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:revision_app/features/documents/data/documents_api.dart';

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
  test('registers document metadata with a Firebase bearer token', () async {
    final adapter = CapturingHttpClientAdapter(jsonResponse(documentJson()));
    final dio = Dio()..httpClientAdapter = adapter;
    final api = HttpDocumentsApi(
      dio: dio,
      getIdToken: () async => 'firebase-id-token',
    );

    final document = await api.registerDocument(
      subjectId: 'subject-1',
      kind: 'COURSE_PDF',
      fileName: 'cours.pdf',
      storagePath: 'students/firebase-1/subjects/subject-1/cours.pdf',
      mimeType: 'application/pdf',
    );

    expect(document.status, 'UPLOADED');
    expect(adapter.lastOptions?.path, '/documents');
    expect(
      adapter.lastOptions?.headers['Authorization'],
      'Bearer firebase-id-token',
    );
    expect(adapter.lastOptions?.data, {
      'subjectId': 'subject-1',
      'kind': 'COURSE_PDF',
      'fileName': 'cours.pdf',
      'storagePath': 'students/firebase-1/subjects/subject-1/cours.pdf',
      'mimeType': 'application/pdf',
    });
  });

  test('lists subject documents from the API', () async {
    final adapter = CapturingHttpClientAdapter(
      jsonResponse([documentJson(status: 'READY')]),
    );
    final dio = Dio()..httpClientAdapter = adapter;
    final api = HttpDocumentsApi(
      dio: dio,
      getIdToken: () async => 'firebase-id-token',
    );

    final documents = await api.listSubjectDocuments(subjectId: 'subject-1');

    expect(documents.single.status, 'READY');
    expect(adapter.lastOptions?.path, '/subjects/subject-1/documents');
  });

  test('rejects blank Firebase ID tokens before posting metadata', () async {
    final adapter = CapturingHttpClientAdapter(jsonResponse(documentJson()));
    final dio = Dio()..httpClientAdapter = adapter;
    final api = HttpDocumentsApi(dio: dio, getIdToken: () async => '  ');

    await expectLater(
      api.registerDocument(
        subjectId: 'subject-1',
        kind: 'COURSE_PDF',
        fileName: 'cours.pdf',
        storagePath: 'students/firebase-1/subjects/subject-1/cours.pdf',
        mimeType: 'application/pdf',
      ),
      throwsStateError,
    );

    expect(adapter.fetchCallCount, 0);
  });
}

Map<String, Object?> documentJson({String status = 'UPLOADED'}) {
  return {
    'id': 'document-1',
    'subjectId': 'subject-1',
    'kind': 'COURSE_PDF',
    'fileName': 'cours.pdf',
    'mimeType': 'application/pdf',
    'status': status,
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
