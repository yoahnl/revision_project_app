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
  test('uploads a course PDF with a Firebase bearer token', () async {
    final adapter = CapturingHttpClientAdapter(jsonResponse(documentJson()));
    final dio = Dio()..httpClientAdapter = adapter;
    final api = HttpDocumentsApi(
      dio: dio,
      getIdToken: () async => 'firebase-id-token',
    );

    final document = await api.uploadCoursePdf(
      subjectId: 'subject-1',
      fileName: 'cours.pdf',
      bytes: Uint8List.fromList([1, 2, 3]),
    );

    expect(document.status, 'UPLOADED');
    expect(adapter.lastOptions?.path, '/documents/course-pdf');
    expect(
      adapter.lastOptions?.headers['Authorization'],
      'Bearer firebase-id-token',
    );
    final formData = adapter.lastOptions?.data as FormData;
    expect(Map.fromEntries(formData.fields), {'subjectId': 'subject-1'});
    expect(formData.files.single.key, 'file');
    expect(formData.files.single.value.filename, 'cours.pdf');
    expect(
      formData.files.single.value.contentType.toString(),
      'application/pdf',
    );
  });

  test('lists subject documents from the API', () async {
    final adapter = CapturingHttpClientAdapter(
      jsonResponse([
        documentJson(
          status: 'FAILED',
          errorCode: 'KNOWLEDGE_EXTRACTION_FAILED',
        ),
      ]),
    );
    final dio = Dio()..httpClientAdapter = adapter;
    final api = HttpDocumentsApi(
      dio: dio,
      getIdToken: () async => 'firebase-id-token',
    );

    final documents = await api.listSubjectDocuments(subjectId: 'subject-1');

    expect(documents.single.status, 'FAILED');
    expect(documents.single.errorCode, 'KNOWLEDGE_EXTRACTION_FAILED');
    expect(adapter.lastOptions?.path, '/subjects/subject-1/documents');
  });

  test('rejects blank Firebase ID tokens before posting metadata', () async {
    final adapter = CapturingHttpClientAdapter(jsonResponse(documentJson()));
    final dio = Dio()..httpClientAdapter = adapter;
    final api = HttpDocumentsApi(dio: dio, getIdToken: () async => '  ');

    await expectLater(
      api.uploadCoursePdf(
        subjectId: 'subject-1',
        fileName: 'cours.pdf',
        bytes: Uint8List.fromList([1, 2, 3]),
      ),
      throwsStateError,
    );

    expect(adapter.fetchCallCount, 0);
  });
}

Map<String, Object?> documentJson({
  String status = 'UPLOADED',
  String? errorCode,
}) {
  return {
    'id': 'document-1',
    'subjectId': 'subject-1',
    'kind': 'COURSE_PDF',
    'fileName': 'cours.pdf',
    'mimeType': 'application/pdf',
    'status': status,
    'errorCode': errorCode,
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
