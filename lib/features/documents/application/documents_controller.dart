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

  Future<DocumentKnowledgeUnitsResponse> listDocumentKnowledgeUnits({
    required String documentId,
  });
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

  Future<DocumentKnowledgeUnitsResponse> listDocumentKnowledgeUnits(
    String documentId,
  ) {
    return _api.listDocumentKnowledgeUnits(documentId: documentId);
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
