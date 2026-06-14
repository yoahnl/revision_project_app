import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:revision_app/features/documents/application/documents_controller.dart';
import 'package:revision_app/features/documents/domain/revision_document.dart';

class FakeDocumentsApi implements DocumentsApi {
  int uploadCallCount = 0;
  String? uploadedSubjectId;
  String? uploadedFileName;
  Uint8List? uploadedBytes;
  Object? uploadError;
  final Map<String, List<DocumentKnowledgeUnit>> unitsByDocumentId = {};
  final List<RevisionDocument> documents = [];

  @override
  Future<RevisionDocument> uploadCoursePdf({
    required String subjectId,
    required String fileName,
    required Uint8List bytes,
  }) async {
    uploadCallCount += 1;
    uploadedSubjectId = subjectId;
    uploadedFileName = fileName;
    uploadedBytes = bytes;

    final error = uploadError;
    if (error != null) {
      throw error;
    }

    final document = RevisionDocument(
      id: 'document-${documents.length + 1}',
      subjectId: subjectId,
      kind: 'COURSE_PDF',
      fileName: '1710000000000-$fileName',
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
      items: unitsByDocumentId[documentId] ?? const [],
    );
  }
}

void main() {
  test('uploads a course PDF through the documents API', () async {
    final api = FakeDocumentsApi();
    final controller = DocumentsController(api);
    final bytes = Uint8List.fromList([1, 2, 3]);

    final document = await controller.uploadCoursePdf(
      subjectId: 'subject-1',
      fileName: 'cours.pdf',
      bytes: bytes,
    );

    expect(api.uploadCallCount, 1);
    expect(api.uploadedSubjectId, 'subject-1');
    expect(api.uploadedFileName, 'cours.pdf');
    expect(api.uploadedBytes, bytes);
    expect(document.status, 'UPLOADED');
  });

  test('surfaces upload failures', () async {
    final api = FakeDocumentsApi()..uploadError = StateError('upload failed');
    final controller = DocumentsController(api);

    await expectLater(
      controller.uploadCoursePdf(
        subjectId: 'subject-1',
        fileName: 'cours.pdf',
        bytes: Uint8List.fromList([1, 2, 3]),
      ),
      throwsStateError,
    );
  });

  test('lists documents for a subject', () async {
    final api = FakeDocumentsApi();
    final controller = DocumentsController(api);

    await controller.uploadCoursePdf(
      subjectId: 'subject-1',
      fileName: 'cours.pdf',
      bytes: Uint8List.fromList([1, 2, 3]),
    );

    final documents = await controller.listSubjectDocuments('subject-1');

    expect(documents.single.fileName, '1710000000000-cours.pdf');
  });

  test('loads ready document detail with knowledge units', () async {
    final api = FakeDocumentsApi()
      ..documents.add(
        const RevisionDocument(
          id: 'document-1',
          subjectId: 'subject-1',
          kind: 'COURSE_PDF',
          fileName: 'cours.pdf',
          status: 'READY',
          mimeType: 'application/pdf',
        ),
      )
      ..unitsByDocumentId['document-1'] = const [
        DocumentKnowledgeUnit(
          id: 'unit-1',
          title: 'Constitution',
          summary: 'Norme fondamentale.',
          difficulty: 'MEDIUM',
          displayOrder: 1,
          confidence: 0.8,
          sources: [
            DocumentKnowledgeUnitSource(
              chunkId: 'chunk-1',
              text: 'Extrait source.',
              pageNumber: null,
              index: 0,
            ),
          ],
        ),
      ];
    final controller = DocumentsController(api);

    final detail = await controller.loadDocumentDetail('document-1');

    expect(detail.document.status, 'READY');
    expect(detail.knowledgeUnits.single.title, 'Constitution');
    expect(detail.state, DocumentDetailLoadState.ready);
  });

  test('does not load knowledge units for processing documents', () async {
    final api = FakeDocumentsApi()
      ..documents.add(
        const RevisionDocument(
          id: 'document-1',
          subjectId: 'subject-1',
          kind: 'COURSE_PDF',
          fileName: 'cours.pdf',
          status: 'PROCESSING',
          mimeType: 'application/pdf',
        ),
      );
    final controller = DocumentsController(api);

    final detail = await controller.loadDocumentDetail('document-1');

    expect(detail.state, DocumentDetailLoadState.notReady);
    expect(detail.knowledgeUnits, isEmpty);
  });

  test('exposes failed document detail error state', () async {
    final api = FakeDocumentsApi()
      ..documents.add(
        const RevisionDocument(
          id: 'document-1',
          subjectId: 'subject-1',
          kind: 'COURSE_PDF',
          fileName: 'cours.pdf',
          status: 'FAILED',
          mimeType: 'application/pdf',
          errorCode: 'KNOWLEDGE_EXTRACTION_FAILED',
        ),
      );
    final controller = DocumentsController(api);

    final detail = await controller.loadDocumentDetail('document-1');

    expect(detail.state, DocumentDetailLoadState.failed);
    expect(detail.document.errorCode, 'KNOWLEDGE_EXTRACTION_FAILED');
  });
}
