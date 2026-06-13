import 'dart:typed_data';

import '../domain/revision_document.dart';

class UploadedDocumentFile {
  const UploadedDocumentFile({
    required this.fileName,
    required this.storagePath,
    required this.mimeType,
  });

  final String fileName;
  final String storagePath;
  final String mimeType;
}

abstract interface class DocumentUploader {
  Future<UploadedDocumentFile> uploadCoursePdf({
    required String subjectId,
    required String fileName,
    required Uint8List bytes,
  });
}

abstract interface class DocumentsApi {
  Future<RevisionDocument> registerDocument({
    required String subjectId,
    required String kind,
    required String fileName,
    required String storagePath,
    required String mimeType,
  });

  Future<List<RevisionDocument>> listSubjectDocuments({
    required String subjectId,
  });

  Future<RevisionDocument> getDocument({required String documentId});
}

class DocumentsController {
  const DocumentsController(this._uploader, this._api);

  final DocumentUploader _uploader;
  final DocumentsApi _api;

  Future<RevisionDocument> uploadCoursePdf({
    required String subjectId,
    required String fileName,
    required Uint8List bytes,
  }) async {
    final uploaded = await _uploader.uploadCoursePdf(
      subjectId: subjectId,
      fileName: fileName,
      bytes: bytes,
    );
    return _api.registerDocument(
      subjectId: subjectId,
      kind: 'COURSE_PDF',
      fileName: uploaded.fileName,
      storagePath: uploaded.storagePath,
      mimeType: uploaded.mimeType,
    );
  }

  Future<List<RevisionDocument>> listSubjectDocuments(String subjectId) {
    return _api.listSubjectDocuments(subjectId: subjectId);
  }

  Future<RevisionDocument> getDocument(String documentId) {
    return _api.getDocument(documentId: documentId);
  }
}
