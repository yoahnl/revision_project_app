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
  Future<void> deleteDocument({required String documentId}) async {
    await _dio.delete<Object?>(
      '/documents/$documentId',
      options: await _authorizedOptions(
        'A Firebase ID token is required to delete documents',
      ),
    );
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

  @override
  Future<DocumentSummary?> getDocumentSummary({
    required String documentId,
  }) async {
    try {
      final response = await _dio.get<Object?>(
        '/documents/$documentId/summary',
        options: await _authorizedOptions(
          'A Firebase ID token is required to load document summaries',
        ),
      );

      return _DocumentSummaryJson(response.data).toSummary();
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        return null;
      }
      _throwArtifactRequestException(error);
    }
  }

  @override
  Future<DocumentSummary> generateDocumentSummary({
    required String documentId,
  }) async {
    try {
      final response = await _dio.post<Object?>(
        '/documents/$documentId/summary',
        options: await _authorizedOptions(
          'A Firebase ID token is required to generate document summaries',
        ),
      );

      return _DocumentSummaryJson(response.data).toSummary();
    } on DioException catch (error) {
      _throwArtifactRequestException(error);
    }
  }

  @override
  Future<RevisionSheet?> getRevisionSheet({required String documentId}) async {
    try {
      final response = await _dio.get<Object?>(
        '/documents/$documentId/revision-sheet',
        options: await _authorizedOptions(
          'A Firebase ID token is required to load revision sheets',
        ),
      );

      return _RevisionSheetJson(response.data).toRevisionSheet();
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        return null;
      }
      _throwArtifactRequestException(error);
    }
  }

  @override
  Future<RevisionSheet> generateRevisionSheet({
    required String documentId,
  }) async {
    try {
      final response = await _dio.post<Object?>(
        '/documents/$documentId/revision-sheet',
        options: await _authorizedOptions(
          'A Firebase ID token is required to generate revision sheets',
        ),
      );

      return _RevisionSheetJson(response.data).toRevisionSheet();
    } on DioException catch (error) {
      _throwArtifactRequestException(error);
    }
  }

  Future<Options> _authorizedOptions(String missingTokenMessage) async {
    final token = (await _getIdToken())?.trim();

    if (token == null || token.isEmpty) {
      throw StateError(missingTokenMessage);
    }

    return Options(headers: {'Authorization': 'Bearer $token'});
  }

  Never _throwArtifactRequestException(DioException error) {
    final statusCode = error.response?.statusCode;

    if (statusCode == 409) {
      throw const DocumentNotReadyException();
    }

    if (statusCode != null) {
      throw DocumentArtifactRequestException(statusCode: statusCode);
    }

    throw error;
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

class _DocumentSummaryJson {
  const _DocumentSummaryJson(this.value);

  final Object? value;

  DocumentSummary toSummary() {
    final json = value;

    if (json is! Map<String, Object?>) {
      throw const FormatException('Invalid document summary response');
    }

    final id = json['id'];
    final documentId = json['documentId'];
    final subjectId = json['subjectId'];
    final status = json['status'];
    final title = json['title'];
    final content = json['content'];
    final keyPoints = json['keyPoints'];
    final limits = json['limits'];
    final errorCode = json['errorCode'];
    final sources = json['sources'];

    if (id is! String ||
        documentId is! String ||
        subjectId is! String ||
        status is! String ||
        title is! String ||
        content is! String ||
        keyPoints is! List ||
        (limits != null && limits is! String) ||
        (errorCode != null && errorCode is! String) ||
        sources is! List) {
      throw const FormatException('Invalid document summary response');
    }

    return DocumentSummary(
      id: id,
      documentId: documentId,
      subjectId: subjectId,
      status: status,
      title: title,
      content: content,
      keyPoints: _stringList(keyPoints, 'Invalid document summary response'),
      limits: limits as String?,
      errorCode: errorCode as String?,
      sources: sources
          .map((source) => _DocumentArtifactSourceJson(source).toSource())
          .toList(growable: false),
    );
  }
}

class _RevisionSheetJson {
  const _RevisionSheetJson(this.value);

  final Object? value;

  RevisionSheet toRevisionSheet() {
    final json = value;

    if (json is! Map<String, Object?>) {
      throw const FormatException('Invalid revision sheet response');
    }

    final id = json['id'];
    final documentId = json['documentId'];
    final subjectId = json['subjectId'];
    final status = json['status'];
    final title = json['title'];
    final introduction = json['introduction'];
    final sections = json['sections'];
    final keyPoints = json['keyPoints'];
    final commonMistakes = json['commonMistakes'];
    final mustKnow = json['mustKnow'];
    final practiceSuggestions = json['practiceSuggestions'];
    final errorCode = json['errorCode'];

    if (id is! String ||
        documentId is! String ||
        subjectId is! String ||
        status is! String ||
        title is! String ||
        (introduction != null && introduction is! String) ||
        sections is! List ||
        keyPoints is! List ||
        commonMistakes is! List ||
        mustKnow is! List ||
        practiceSuggestions is! List ||
        (errorCode != null && errorCode is! String)) {
      throw const FormatException('Invalid revision sheet response');
    }

    return RevisionSheet(
      id: id,
      documentId: documentId,
      subjectId: subjectId,
      status: status,
      title: title,
      introduction: introduction as String?,
      sections: sections
          .map((section) => _RevisionSheetSectionJson(section).toSection())
          .toList(growable: false),
      keyPoints: _stringList(keyPoints, 'Invalid revision sheet response'),
      commonMistakes: _stringList(
        commonMistakes,
        'Invalid revision sheet response',
      ),
      mustKnow: _stringList(mustKnow, 'Invalid revision sheet response'),
      practiceSuggestions: _stringList(
        practiceSuggestions,
        'Invalid revision sheet response',
      ),
      errorCode: errorCode as String?,
    );
  }
}

class _RevisionSheetSectionJson {
  const _RevisionSheetSectionJson(this.value);

  final Object? value;

  RevisionSheetSection toSection() {
    final json = value;

    if (json is! Map<String, Object?>) {
      throw const FormatException('Invalid revision sheet section response');
    }

    final id = json['id'];
    final displayOrder = json['displayOrder'];
    final title = json['title'];
    final content = json['content'];
    final sources = json['sources'];

    if (id is! String ||
        displayOrder is! int ||
        title is! String ||
        content is! String ||
        sources is! List) {
      throw const FormatException('Invalid revision sheet section response');
    }

    return RevisionSheetSection(
      id: id,
      displayOrder: displayOrder,
      title: title,
      content: content,
      sources: sources
          .map((source) => _DocumentArtifactSourceJson(source).toSource())
          .toList(growable: false),
    );
  }
}

class _DocumentArtifactSourceJson {
  const _DocumentArtifactSourceJson(this.value);

  final Object? value;

  DocumentArtifactSource toSource() {
    final json = value;

    if (json is! Map<String, Object?>) {
      throw const FormatException('Invalid artifact source response');
    }

    final chunkId = json['chunkId'];
    final text = json['text'];
    final pageNumber = json['pageNumber'];
    final index = json['index'];

    if (chunkId is! String ||
        text is! String ||
        (pageNumber != null && pageNumber is! int) ||
        index is! int) {
      throw const FormatException('Invalid artifact source response');
    }

    return DocumentArtifactSource(
      chunkId: chunkId,
      text: text,
      pageNumber: pageNumber as int?,
      index: index,
    );
  }
}

List<String> _stringList(List value, String message) {
  if (value.any((item) => item is! String)) {
    throw FormatException(message);
  }

  return value.cast<String>().toList(growable: false);
}
