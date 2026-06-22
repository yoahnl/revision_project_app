import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:Neralune/features/documents/application/documents_controller.dart';
import 'package:Neralune/features/documents/domain/revision_document.dart';
import 'package:Neralune/features/documents/domain/source_lifecycle.dart';

class FakeDocumentsApi implements DocumentsApi {
  int uploadCallCount = 0;
  String? uploadedSubjectId;
  String? uploadedFileName;
  Uint8List? uploadedBytes;
  Object? uploadError;
  final Map<String, List<DocumentKnowledgeUnit>> unitsByDocumentId = {};
  final Map<String, DocumentSummary> summariesByDocumentId = {};
  final Map<String, RevisionSheet> revisionSheetsByDocumentId = {};
  final Map<String, SourceLifecycleDecision> lifecycleByDocumentId = {};
  final List<RevisionDocument> documents = [];
  int generateSummaryCallCount = 0;
  int generateRevisionSheetCallCount = 0;
  int deleteDocumentCallCount = 0;
  String? deletedDocumentId;

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
  Future<void> deleteDocument({required String documentId}) async {
    deleteDocumentCallCount += 1;
    deletedDocumentId = documentId;
    documents.removeWhere((document) => document.id == documentId);
  }

  @override
  Future<SourceLifecycleDecision> getDocumentLifecycle({
    required String documentId,
  }) async {
    final document = documents.firstWhere(
      (document) => document.id == documentId,
      orElse: () => RevisionDocument(
        id: documentId,
        subjectId: 'subject-1',
        kind: 'COURSE_PDF',
        fileName: 'cours.pdf',
        status: 'FAILED',
        mimeType: 'application/pdf',
      ),
    );

    return lifecycleByDocumentId[documentId] ??
        SourceLifecycleDecision(
          documentId: document.id,
          courseId: null,
          status: SourceLifecycleStatus.active,
          recommendedAction: SourceLifecycleAction.delete,
          canDelete: true,
          canArchive: true,
          blockingReasons: const [],
          userMessage: 'Cette source peut être supprimée.',
        );
  }

  @override
  Future<SourceLifecycleDecision> archiveDocument({
    required String documentId,
  }) async {
    documents.removeWhere((document) => document.id == documentId);
    return SourceLifecycleDecision(
      documentId: documentId,
      courseId: null,
      status: SourceLifecycleStatus.archived,
      recommendedAction: SourceLifecycleAction.block,
      canDelete: false,
      canArchive: false,
      blockingReasons: const ['ALREADY_ARCHIVED'],
      userMessage: 'Cette source est archivée.',
    );
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
    generateSummaryCallCount += 1;
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
    generateRevisionSheetCallCount += 1;
    return revisionSheetsByDocumentId[documentId]!;
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

  test('trims document id before deleting a document', () async {
    final api = FakeDocumentsApi();
    final controller = DocumentsController(api);

    await controller.deleteDocument(' document-1 ');

    expect(api.deleteDocumentCallCount, 1);
    expect(api.deletedDocumentId, 'document-1');
  });

  test('rejects empty document ids before deleting a document', () async {
    final api = FakeDocumentsApi();
    final controller = DocumentsController(api);

    expect(() => controller.deleteDocument('  '), throwsArgumentError);
    expect(api.deleteDocumentCallCount, 0);
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

  test('loads existing document artifacts', () async {
    final api = FakeDocumentsApi()
      ..summariesByDocumentId['document-1'] = summary()
      ..revisionSheetsByDocumentId['document-1'] = revisionSheet();
    final controller = DocumentsController(api);

    final artifacts = await controller.loadDocumentArtifacts('document-1');

    expect(artifacts.summary?.title, 'Résumé');
    expect(artifacts.revisionSheet?.title, 'Fiche');
  });

  test('generates document artifacts through the API', () async {
    final api = FakeDocumentsApi()
      ..summariesByDocumentId['document-1'] = summary()
      ..revisionSheetsByDocumentId['document-1'] = revisionSheet();
    final controller = DocumentsController(api);

    await controller.generateDocumentSummary('document-1');
    await controller.generateRevisionSheet('document-1');

    expect(api.generateSummaryCallCount, 1);
    expect(api.generateRevisionSheetCallCount, 1);
  });
}

DocumentSummary summary() {
  return const DocumentSummary(
    id: 'summary-1',
    documentId: 'document-1',
    subjectId: 'subject-1',
    status: 'READY',
    title: 'Résumé',
    content: 'Contenu',
    keyPoints: ['Point'],
    limits: null,
    errorCode: null,
    sources: [
      DocumentArtifactSource(
        chunkId: 'chunk-1',
        text: 'Source',
        pageNumber: null,
        index: 0,
      ),
    ],
  );
}

RevisionSheet revisionSheet() {
  return const RevisionSheet(
    id: 'sheet-1',
    documentId: 'document-1',
    subjectId: 'subject-1',
    status: 'READY',
    title: 'Fiche',
    introduction: 'Intro',
    sections: [
      RevisionSheetSection(
        id: 'section-1',
        displayOrder: 0,
        title: 'Section',
        content: 'Contenu',
        sources: [
          DocumentArtifactSource(
            chunkId: 'chunk-1',
            text: 'Source',
            pageNumber: null,
            index: 0,
          ),
        ],
      ),
    ],
    keyPoints: ['Point'],
    commonMistakes: [],
    mustKnow: [],
    practiceSuggestions: [],
    errorCode: null,
  );
}
