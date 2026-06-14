import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:revision_app/features/documents/application/documents_controller.dart';
import 'package:revision_app/features/documents/domain/revision_document.dart';
import 'package:revision_app/presentation/pages/documents/document_detail_page.dart';

class DetailDocumentsApi implements DocumentsApi {
  DetailDocumentsApi({
    required this.document,
    this.knowledgeUnits = const [],
    this.summary,
    this.revisionSheet,
    this.generatedSummary,
    this.generatedRevisionSheet,
    this.error,
    this.summaryError,
    this.revisionSheetError,
  });

  final RevisionDocument document;
  final List<DocumentKnowledgeUnit> knowledgeUnits;
  DocumentSummary? summary;
  RevisionSheet? revisionSheet;
  final DocumentSummary? generatedSummary;
  final RevisionSheet? generatedRevisionSheet;
  final Object? error;
  final Object? summaryError;
  final Object? revisionSheetError;

  @override
  Future<RevisionDocument> getDocument({required String documentId}) async {
    final error = this.error;
    if (error != null) {
      throw error;
    }

    return document;
  }

  @override
  Future<void> deleteDocument({required String documentId}) async {}

  @override
  Future<DocumentKnowledgeUnitsResponse> listDocumentKnowledgeUnits({
    required String documentId,
  }) async {
    return DocumentKnowledgeUnitsResponse(
      documentId: documentId,
      items: knowledgeUnits,
    );
  }

  @override
  Future<DocumentSummary?> getDocumentSummary({
    required String documentId,
  }) async {
    final error = summaryError;
    if (error != null) {
      throw error;
    }

    return summary;
  }

  @override
  Future<DocumentSummary> generateDocumentSummary({
    required String documentId,
  }) async {
    final generated = generatedSummary ?? summary;
    if (generated == null) {
      throw StateError('summary generation failed');
    }
    summary = generated;
    return generated;
  }

  @override
  Future<RevisionSheet?> getRevisionSheet({required String documentId}) async {
    final error = revisionSheetError;
    if (error != null) {
      throw error;
    }

    return revisionSheet;
  }

  @override
  Future<RevisionSheet> generateRevisionSheet({
    required String documentId,
  }) async {
    final generated = generatedRevisionSheet ?? revisionSheet;
    if (generated == null) {
      throw StateError('revision sheet generation failed');
    }
    revisionSheet = generated;
    return generated;
  }

  @override
  Future<List<RevisionDocument>> listSubjectDocuments({
    required String subjectId,
  }) async {
    return [document];
  }

  @override
  Future<RevisionDocument> uploadCoursePdf({
    required String subjectId,
    required String fileName,
    required Uint8List bytes,
  }) {
    throw UnimplementedError();
  }
}

void main() {
  testWidgets('shows a waiting state for processing documents', (tester) async {
    await tester.pumpWidget(
      documentDetailApp(
        document: const RevisionDocument(
          id: 'document-1',
          subjectId: 'subject-1',
          kind: 'COURSE_PDF',
          fileName: 'cours.pdf',
          status: 'PROCESSING',
          mimeType: 'application/pdf',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('cours.pdf'), findsOneWidget);
    expect(find.text('Analyse en cours'), findsWidgets);
    expect(
      find.text('Les notions apparaitront apres le traitement.'),
      findsOneWidget,
    );
  });

  testWidgets('shows failed document errors', (tester) async {
    await tester.pumpWidget(
      documentDetailApp(
        document: const RevisionDocument(
          id: 'document-1',
          subjectId: 'subject-1',
          kind: 'COURSE_PDF',
          fileName: 'cours.pdf',
          status: 'FAILED',
          mimeType: 'application/pdf',
          errorCode: 'KNOWLEDGE_EXTRACTION_FAILED',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Analyse echouee'), findsWidgets);
    expect(find.text('Erreur IA'), findsWidgets);
  });

  testWidgets('shows ready knowledge units and source excerpts', (
    tester,
  ) async {
    await tester.pumpWidget(
      documentDetailApp(
        document: const RevisionDocument(
          id: 'document-1',
          subjectId: 'subject-1',
          kind: 'COURSE_PDF',
          fileName: 'cours.pdf',
          status: 'READY',
          mimeType: 'application/pdf',
        ),
        knowledgeUnits: const [
          DocumentKnowledgeUnit(
            id: 'unit-1',
            title: 'Séparation des pouvoirs',
            summary: 'Résumé court.',
            difficulty: 'MEDIUM',
            displayOrder: 1,
            confidence: 0.84,
            sources: [
              DocumentKnowledgeUnitSource(
                chunkId: 'chunk-1',
                text: 'Extrait source issu du chunk.',
                pageNumber: null,
                index: 0,
              ),
            ],
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Séparation des pouvoirs'), findsOneWidget);
    expect(find.text('Résumé court.'), findsOneWidget);
    expect(find.text('Difficulte moyenne'), findsOneWidget);
    expect(find.text('Confiance 84%'), findsOneWidget);
    expect(find.text('Extrait source issu du chunk.'), findsOneWidget);
    expect(find.text('Supports IA'), findsOneWidget);
    expect(find.text('Generer le resume'), findsOneWidget);
    expect(find.text('Generer la fiche'), findsOneWidget);
  });

  testWidgets('generates and displays a document summary', (tester) async {
    await tester.pumpWidget(
      documentDetailApp(document: readyDocument(), generatedSummary: summary()),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Generer le resume'));
    await tester.pumpAndSettle();

    expect(find.text('Résumé du cours'), findsOneWidget);
    expect(find.text('Texte synthétique.'), findsOneWidget);
    expect(find.text('Point clé'), findsOneWidget);
    expect(find.text('Extrait summary.'), findsOneWidget);
  });

  testWidgets('generates and displays a revision sheet', (tester) async {
    await tester.pumpWidget(
      documentDetailApp(
        document: readyDocument(),
        generatedRevisionSheet: revisionSheet(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Generer la fiche'));
    await tester.pumpAndSettle();

    expect(find.text('Fiche de révision'), findsOneWidget);
    expect(find.text('Principe clé'), findsOneWidget);
    expect(find.text('Explication structurée.'), findsOneWidget);
    expect(find.text('Extrait fiche.'), findsOneWidget);
  });

  testWidgets('does not show artifact generation CTAs before ready', (
    tester,
  ) async {
    await tester.pumpWidget(
      documentDetailApp(
        document: const RevisionDocument(
          id: 'document-1',
          subjectId: 'subject-1',
          kind: 'COURSE_PDF',
          fileName: 'cours.pdf',
          status: 'PROCESSING',
          mimeType: 'application/pdf',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Generer le resume'), findsNothing);
    expect(find.text('Generer la fiche'), findsNothing);
  });

  testWidgets('shows artifact loading errors without hiding notions', (
    tester,
  ) async {
    await tester.pumpWidget(
      documentDetailApp(
        document: readyDocument(),
        knowledgeUnits: const [
          DocumentKnowledgeUnit(
            id: 'unit-1',
            title: 'Constitution',
            summary: 'Norme fondamentale.',
            sources: [],
          ),
        ],
        summaryError: StateError('summary failed'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Constitution'), findsOneWidget);
    expect(find.text('Impossible de charger les supports IA'), findsOneWidget);
  });

  testWidgets('shows API errors with retry action', (tester) async {
    await tester.pumpWidget(
      documentDetailApp(
        document: const RevisionDocument(
          id: 'document-1',
          subjectId: 'subject-1',
          kind: 'COURSE_PDF',
          fileName: 'cours.pdf',
          status: 'READY',
          mimeType: 'application/pdf',
        ),
        error: StateError('network failed'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Impossible de charger le document'), findsOneWidget);
    expect(find.text('Reessayer'), findsOneWidget);
  });
}

Widget documentDetailApp({
  required RevisionDocument document,
  List<DocumentKnowledgeUnit> knowledgeUnits = const [],
  DocumentSummary? summary,
  RevisionSheet? revisionSheet,
  DocumentSummary? generatedSummary,
  RevisionSheet? generatedRevisionSheet,
  Object? error,
  Object? summaryError,
  Object? revisionSheetError,
}) {
  return MaterialApp(
    home: Scaffold(
      body: DocumentDetailPage(
        documentId: document.id,
        controller: DocumentsController(
          DetailDocumentsApi(
            document: document,
            knowledgeUnits: knowledgeUnits,
            summary: summary,
            revisionSheet: revisionSheet,
            generatedSummary: generatedSummary,
            generatedRevisionSheet: generatedRevisionSheet,
            error: error,
            summaryError: summaryError,
            revisionSheetError: revisionSheetError,
          ),
        ),
      ),
    ),
  );
}

RevisionDocument readyDocument() {
  return const RevisionDocument(
    id: 'document-1',
    subjectId: 'subject-1',
    kind: 'COURSE_PDF',
    fileName: 'cours.pdf',
    status: 'READY',
    mimeType: 'application/pdf',
  );
}

DocumentSummary summary() {
  return const DocumentSummary(
    id: 'summary-1',
    documentId: 'document-1',
    subjectId: 'subject-1',
    status: 'READY',
    title: 'Résumé du cours',
    content: 'Texte synthétique.',
    keyPoints: ['Point clé'],
    limits: 'Limite.',
    errorCode: null,
    sources: [
      DocumentArtifactSource(
        chunkId: 'chunk-1',
        text: 'Extrait summary.',
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
    title: 'Fiche de révision',
    introduction: "Vue d'ensemble.",
    sections: [
      RevisionSheetSection(
        id: 'section-1',
        displayOrder: 0,
        title: 'Principe clé',
        content: 'Explication structurée.',
        sources: [
          DocumentArtifactSource(
            chunkId: 'chunk-1',
            text: 'Extrait fiche.',
            pageNumber: null,
            index: 0,
          ),
        ],
      ),
    ],
    keyPoints: ['À retenir'],
    commonMistakes: [],
    mustKnow: ['Indispensable'],
    practiceSuggestions: ['Relire la section.'],
    errorCode: null,
  );
}
