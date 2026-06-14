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
    this.error,
  });

  final RevisionDocument document;
  final List<DocumentKnowledgeUnit> knowledgeUnits;
  final Object? error;

  @override
  Future<RevisionDocument> getDocument({required String documentId}) async {
    final error = this.error;
    if (error != null) {
      throw error;
    }

    return document;
  }

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

  testWidgets('shows ready knowledge units and source excerpts', (tester) async {
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
  Object? error,
}) {
  return MaterialApp(
    home: Scaffold(
      body: DocumentDetailPage(
        documentId: document.id,
        controller: DocumentsController(
          DetailDocumentsApi(
            document: document,
            knowledgeUnits: knowledgeUnits,
            error: error,
          ),
        ),
      ),
    ),
  );
}
