import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../application/documents_controller.dart';
import '../domain/revision_document.dart';

class HttpDocumentsApi implements DocumentsApi {
  HttpDocumentsApi({
    required Dio dio,
    required Future<String?> Function() getIdToken,
  }) : this._(dio, getIdToken);

  const HttpDocumentsApi._(this._dio, this._getIdToken);

  final Dio _dio;
  final Future<String?> Function() _getIdToken;

  @override
  Future<RevisionDocument> uploadCoursePdf({
    required String subjectId,
    required String fileName,
    required Uint8List bytes,
  }) async {
    final response = await _dio.post<Object?>(
      '/documents/course-pdf',
      data: FormData.fromMap({
        'subjectId': subjectId,
        'file': MultipartFile.fromBytes(
          bytes,
          filename: fileName,
          contentType: DioMediaType('application', 'pdf'),
        ),
      }),
      options: await _authorizedOptions(
        'A Firebase ID token is required to upload documents',
      ),
    );

    return _DocumentJson(response.data).toDocument();
  }

  @override
  Future<List<RevisionDocument>> listSubjectDocuments({
    required String subjectId,
  }) async {
    final response = await _dio.get<Object?>(
      '/subjects/$subjectId/documents',
      options: await _authorizedOptions(
        'A Firebase ID token is required to load documents',
      ),
    );
    final rawDocuments = response.data;

    if (rawDocuments is! List) {
      throw const FormatException('Invalid documents response');
    }

    return rawDocuments
        .map((document) => _DocumentJson(document).toDocument())
        .toList(growable: false);
  }

  @override
  Future<RevisionDocument> getDocument({required String documentId}) async {
    final response = await _dio.get<Object?>(
      '/documents/$documentId',
      options: await _authorizedOptions(
        'A Firebase ID token is required to load documents',
      ),
    );

    return _DocumentJson(response.data).toDocument();
  }

  @override
  Future<DocumentKnowledgeUnitsResponse> listDocumentKnowledgeUnits({
    required String documentId,
  }) async {
    try {
      final response = await _dio.get<Object?>(
        '/documents/$documentId/knowledge-units',
        options: await _authorizedOptions(
          'A Firebase ID token is required to load document knowledge units',
        ),
      );

      return _KnowledgeUnitsJson(response.data).toResponse();
    } on DioException catch (error) {
      if (error.response?.statusCode == 409) {
        throw const DocumentNotReadyException();
      }

      rethrow;
    }
  }

  Future<Options> _authorizedOptions(String missingTokenMessage) async {
    final token = (await _getIdToken())?.trim();

    if (token == null || token.isEmpty) {
      throw StateError(missingTokenMessage);
    }

    return Options(headers: {'Authorization': 'Bearer $token'});
  }
}

class _DocumentJson {
  const _DocumentJson(this.value);

  final Object? value;

  RevisionDocument toDocument() {
    final json = value;

    if (json is! Map<String, Object?>) {
      throw const FormatException('Invalid document response');
    }

    final id = json['id'];
    final subjectId = json['subjectId'];
    final kind = json['kind'];
    final fileName = json['fileName'];
    final status = json['status'];
    final mimeType = json['mimeType'];
    final errorCode = json['errorCode'];

    if (id is! String ||
        subjectId is! String ||
        kind is! String ||
        fileName is! String ||
        status is! String ||
        mimeType is! String ||
        (errorCode != null && errorCode is! String)) {
      throw const FormatException('Invalid document response');
    }

    return RevisionDocument(
      id: id,
      subjectId: subjectId,
      kind: kind,
      fileName: fileName,
      status: status,
      mimeType: mimeType,
      errorCode: errorCode as String?,
    );
  }
}

class _KnowledgeUnitsJson {
  const _KnowledgeUnitsJson(this.value);

  final Object? value;

  DocumentKnowledgeUnitsResponse toResponse() {
    final json = value;

    if (json is! Map<String, Object?>) {
      throw const FormatException('Invalid knowledge units response');
    }

    final documentId = json['documentId'];
    final items = json['items'];

    if (documentId is! String || items is! List) {
      throw const FormatException('Invalid knowledge units response');
    }

    return DocumentKnowledgeUnitsResponse(
      documentId: documentId,
      items: items
          .map((item) => _KnowledgeUnitJson(item).toKnowledgeUnit())
          .toList(growable: false),
    );
  }
}

class _KnowledgeUnitJson {
  const _KnowledgeUnitJson(this.value);

  final Object? value;

  DocumentKnowledgeUnit toKnowledgeUnit() {
    final json = value;

    if (json is! Map<String, Object?>) {
      throw const FormatException('Invalid knowledge unit response');
    }

    final id = json['id'];
    final title = json['title'];
    final summary = json['summary'];
    final difficulty = json['difficulty'];
    final displayOrder = json['displayOrder'];
    final confidence = json['confidence'];
    final sources = json['sources'];

    if (id is! String ||
        title is! String ||
        summary is! String ||
        (difficulty != null && difficulty is! String) ||
        (displayOrder != null && displayOrder is! int) ||
        (confidence != null && confidence is! num) ||
        sources is! List) {
      throw const FormatException('Invalid knowledge unit response');
    }

    return DocumentKnowledgeUnit(
      id: id,
      title: title,
      summary: summary,
      difficulty: difficulty as String?,
      displayOrder: displayOrder as int?,
      confidence: (confidence as num?)?.toDouble(),
      sources: sources
          .map((source) => _KnowledgeUnitSourceJson(source).toSource())
          .toList(growable: false),
    );
  }
}

class _KnowledgeUnitSourceJson {
  const _KnowledgeUnitSourceJson(this.value);

  final Object? value;

  DocumentKnowledgeUnitSource toSource() {
    final json = value;

    if (json is! Map<String, Object?>) {
      throw const FormatException('Invalid knowledge unit source response');
    }

    final chunkId = json['chunkId'];
    final text = json['text'];
    final pageNumber = json['pageNumber'];
    final index = json['index'];

    if (chunkId is! String ||
        text is! String ||
        (pageNumber != null && pageNumber is! int) ||
        index is! int) {
      throw const FormatException('Invalid knowledge unit source response');
    }

    return DocumentKnowledgeUnitSource(
      chunkId: chunkId,
      text: text,
      pageNumber: pageNumber as int?,
      index: index,
    );
  }
}
