import 'dart:typed_data';

import 'package:revision_app/features/documents/application/documents_controller.dart';
import 'package:revision_app/features/documents/domain/revision_document.dart';

class InMemoryDocumentsApi implements DocumentsApi {
  final List<RevisionDocument> documents = [];
  final Map<String, DocumentSummary> summariesByDocumentId = {};
  final Map<String, RevisionSheet> revisionSheetsByDocumentId = {};

  @override
  Future<RevisionDocument> uploadCoursePdf({
    required String subjectId,
    required String fileName,
    required Uint8List bytes,
  }) async {
    final document = RevisionDocument(
      id: 'document-${documents.length + 1}',
      subjectId: subjectId,
      kind: 'COURSE_PDF',
      fileName: fileName,
      status: 'UPLOADED',
      mimeType: 'application/pdf',
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

  @override
  Future<DocumentKnowledgeUnitsResponse> listDocumentKnowledgeUnits({
    required String documentId,
  }) async {
    return DocumentKnowledgeUnitsResponse(
      documentId: documentId,
      items: const [],
    );
  }

  @override
  Future<DocumentSummary?> getDocumentSummary({
    required String documentId,
  }) async {
    return summariesByDocumentId[documentId];
  }

  @override
  Future<DocumentSummary> generateDocumentSummary({
    required String documentId,
  }) async {
    return summariesByDocumentId[documentId]!;
  }

  @override
  Future<RevisionSheet?> getRevisionSheet({required String documentId}) async {
    return revisionSheetsByDocumentId[documentId];
  }

  @override
  Future<RevisionSheet> generateRevisionSheet({
    required String documentId,
  }) async {
    return revisionSheetsByDocumentId[documentId]!;
  }
}
