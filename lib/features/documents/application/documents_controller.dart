import 'dart:typed_data';

import '../domain/revision_document.dart';

abstract interface class DocumentsApi {
  Future<RevisionDocument> uploadCoursePdf({
    required String subjectId,
    required String fileName,
    required Uint8List bytes,
  });

  Future<List<RevisionDocument>> listSubjectDocuments({
    required String subjectId,
  });

  Future<RevisionDocument> getDocument({required String documentId});

  Future<void> deleteDocument({required String documentId});

  Future<DocumentKnowledgeUnitsResponse> listDocumentKnowledgeUnits({
    required String documentId,
  });

  Future<DocumentSummary?> getDocumentSummary({required String documentId});

  Future<DocumentSummary> generateDocumentSummary({required String documentId});

  Future<RevisionSheet?> getRevisionSheet({required String documentId});

  Future<RevisionSheet> generateRevisionSheet({required String documentId});
}

enum DocumentDetailLoadState { notReady, ready, failed }

class DocumentDetail {
  const DocumentDetail({
    required this.document,
    required this.knowledgeUnits,
    required this.state,
  });

  final RevisionDocument document;
  final List<DocumentKnowledgeUnit> knowledgeUnits;
  final DocumentDetailLoadState state;
}

class DocumentArtifacts {
  const DocumentArtifacts({required this.summary, required this.revisionSheet});

  final DocumentSummary? summary;
  final RevisionSheet? revisionSheet;

  DocumentArtifacts copyWith({
    DocumentSummary? summary,
    RevisionSheet? revisionSheet,
  }) {
    return DocumentArtifacts(
      summary: summary ?? this.summary,
      revisionSheet: revisionSheet ?? this.revisionSheet,
    );
  }
}

class DocumentsController {
  const DocumentsController(this._api);

  final DocumentsApi _api;

  Future<RevisionDocument> uploadCoursePdf({
    required String subjectId,
    required String fileName,
    required Uint8List bytes,
  }) async {
    return _api.uploadCoursePdf(
      subjectId: subjectId,
      fileName: fileName,
      bytes: bytes,
    );
  }

  Future<List<RevisionDocument>> listSubjectDocuments(String subjectId) {
    return _api.listSubjectDocuments(subjectId: subjectId);
  }

  Future<RevisionDocument> getDocument(String documentId) {
    return _api.getDocument(documentId: documentId);
  }

  Future<void> deleteDocument(String documentId) {
    final trimmed = documentId.trim();

    if (trimmed.isEmpty) {
      throw ArgumentError('Document id is required');
    }

    return _api.deleteDocument(documentId: trimmed);
  }

  Future<DocumentKnowledgeUnitsResponse> listDocumentKnowledgeUnits(
    String documentId,
  ) {
    return _api.listDocumentKnowledgeUnits(documentId: documentId);
  }

  Future<DocumentArtifacts> loadDocumentArtifacts(String documentId) async {
    final summary = await _api.getDocumentSummary(documentId: documentId);
    final revisionSheet = await _api.getRevisionSheet(documentId: documentId);

    return DocumentArtifacts(summary: summary, revisionSheet: revisionSheet);
  }

  Future<DocumentSummary> generateDocumentSummary(String documentId) {
    return _api.generateDocumentSummary(documentId: documentId);
  }

  Future<RevisionSheet> generateRevisionSheet(String documentId) {
    return _api.generateRevisionSheet(documentId: documentId);
  }

  Future<DocumentDetail> loadDocumentDetail(String documentId) async {
    final document = await getDocument(documentId);

    if (document.status == 'FAILED') {
      return DocumentDetail(
        document: document,
        knowledgeUnits: const [],
        state: DocumentDetailLoadState.failed,
      );
    }

    if (document.status != 'READY') {
      return DocumentDetail(
        document: document,
        knowledgeUnits: const [],
        state: DocumentDetailLoadState.notReady,
      );
    }

    try {
      final response = await listDocumentKnowledgeUnits(documentId);

      return DocumentDetail(
        document: document,
        knowledgeUnits: response.items,
        state: DocumentDetailLoadState.ready,
      );
    } on DocumentNotReadyException {
      return DocumentDetail(
        document: document,
        knowledgeUnits: const [],
        state: DocumentDetailLoadState.notReady,
      );
    }
  }
}

class DocumentNotReadyException implements Exception {
  const DocumentNotReadyException();
}

class DocumentArtifactRequestException implements Exception {
  const DocumentArtifactRequestException({required this.statusCode});

  final int statusCode;
}
