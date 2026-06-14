import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:revision_app/features/documents/application/documents_controller.dart';
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

  test('loads a public document without storage path', () async {
    final adapter = CapturingHttpClientAdapter(
      jsonResponse({
        ...documentJson(status: 'READY'),
        'storagePath': 'should-not-be-used',
      }),
    );
    final dio = Dio()..httpClientAdapter = adapter;
    final api = HttpDocumentsApi(
      dio: dio,
      getIdToken: () async => 'firebase-id-token',
    );

    final document = await api.getDocument(documentId: 'document-1');

    expect(document.status, 'READY');
    expect(adapter.lastOptions?.path, '/documents/document-1');
  });

  test('loads sourced document knowledge units from the API', () async {
    final adapter = CapturingHttpClientAdapter(
      jsonResponse({
        'documentId': 'document-1',
        'items': [
          {
            'id': 'unit-1',
            'title': 'Séparation des pouvoirs',
            'summary': 'Résumé court.',
            'difficulty': 'MEDIUM',
            'displayOrder': 1,
            'confidence': 0.84,
            'sources': [
              {
                'chunkId': 'chunk-1',
                'text': 'Extrait source.',
                'pageNumber': null,
                'index': 0,
              },
            ],
          },
        ],
      }),
    );
    final dio = Dio()..httpClientAdapter = adapter;
    final api = HttpDocumentsApi(
      dio: dio,
      getIdToken: () async => 'firebase-id-token',
    );

    final response = await api.listDocumentKnowledgeUnits(
      documentId: 'document-1',
    );

    expect(response.documentId, 'document-1');
    expect(response.items.single.title, 'Séparation des pouvoirs');
    expect(response.items.single.sources.single.pageNumber, isNull);
    expect(response.items.single.sources.single.text, 'Extrait source.');
    expect(
      adapter.lastOptions?.path,
      '/documents/document-1/knowledge-units',
    );
  });

  test('throws a document not ready error on knowledge units 409', () async {
    final adapter = CapturingHttpClientAdapter(
      jsonResponse({'message': 'Document is not ready'}, statusCode: 409),
    );
    final dio = Dio()..httpClientAdapter = adapter;
    final api = HttpDocumentsApi(
      dio: dio,
      getIdToken: () async => 'firebase-id-token',
    );

    await expectLater(
      api.listDocumentKnowledgeUnits(documentId: 'document-1'),
      throwsA(isA<DocumentNotReadyException>()),
    );
  });

  test('rejects invalid knowledge units JSON', () async {
    final adapter = CapturingHttpClientAdapter(
      jsonResponse({
        'documentId': 'document-1',
        'items': [
          {'id': 'unit-1', 'title': 'Incomplete'},
        ],
      }),
    );
    final dio = Dio()..httpClientAdapter = adapter;
    final api = HttpDocumentsApi(
      dio: dio,
      getIdToken: () async => 'firebase-id-token',
    );

    await expectLater(
      api.listDocumentKnowledgeUnits(documentId: 'document-1'),
      throwsFormatException,
    );
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

ResponseBody jsonResponse(Object body, {int statusCode = 200}) {
  return ResponseBody.fromString(
    jsonEncode(body),
    statusCode,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );
}
