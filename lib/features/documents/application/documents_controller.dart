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
}
