import 'dart:typed_data';

import 'package:revision_app/features/documents/application/documents_controller.dart';
import 'package:revision_app/features/documents/domain/revision_document.dart';

class NoopDocumentUploader implements DocumentUploader {
  @override
  Future<UploadedDocumentFile> uploadCoursePdf({
    required String subjectId,
    required String fileName,
    required Uint8List bytes,
  }) async {
    return UploadedDocumentFile(
      fileName: fileName,
      storagePath: 'students/firebase-1/subjects/$subjectId/$fileName',
      mimeType: 'application/pdf',
    );
  }
}

class InMemoryDocumentsApi implements DocumentsApi {
  final List<RevisionDocument> documents = [];

  @override
  Future<RevisionDocument> registerDocument({
    required String subjectId,
    required String kind,
    required String fileName,
    required String storagePath,
    required String mimeType,
  }) async {
    final document = RevisionDocument(
      id: 'document-${documents.length + 1}',
      subjectId: subjectId,
      kind: kind,
      fileName: fileName,
      status: 'UPLOADED',
      mimeType: mimeType,
    );
    documents.add(document);

    return document;
  }

  @override
  Future<List<RevisionDocument>> listSubjectDocuments({
    required String subjectId,
  }) async {
    return documents
        .where((document) => document.subjectId == subjectId)
        .toList(growable: false);
  }

  @override
  Future<RevisionDocument> getDocument({required String documentId}) async {
    return documents.singleWhere((document) => document.id == documentId);
  }
}
