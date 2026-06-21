import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:Neralune/app/di/providers.dart';
import 'package:Neralune/features/documents/application/documents_controller.dart';
import 'package:Neralune/features/documents/domain/revision_document.dart';
import 'package:Neralune/features/subjects/application/subjects_controller.dart';
import 'package:Neralune/features/subjects/domain/subject.dart';
import 'package:Neralune/features/subjects/presentation/subject_detail_page.dart';

class SingleSubjectRepository implements SubjectsRepository {
  @override
  Future<Subject> createSubject({
    required String name,
    required int priority,
    int weeklyMinutes = 0,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<void> deleteSubject(String id) {
    throw UnimplementedError();
  }

  @override
  Future<Subject> getSubject(String id) async {
    return const Subject(id: 'subject-1', name: 'Biologie', priority: 4);
  }

  @override
  Future<List<Subject>> listSubjects() {
    throw UnimplementedError();
  }
}

class StaticDocumentsApi implements DocumentsApi {
  final documents = <RevisionDocument>[
    const RevisionDocument(
      id: 'document-1',
      subjectId: 'subject-1',
      kind: 'COURSE_PDF',
      fileName: 'cours.pdf',
      status: 'FAILED',
      mimeType: 'application/pdf',
      errorCode: 'KNOWLEDGE_EXTRACTION_FAILED',
    ),
  ];

  @override
  Future<RevisionDocument> getDocument({required String documentId}) {
    throw UnimplementedError();
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
    documents.removeWhere((document) => document.id == documentId);
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
    return null;
  }

  @override
  Future<DocumentSummary> generateDocumentSummary({
    required String documentId,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<RevisionSheet?> getRevisionSheet({required String documentId}) async {
    return null;
  }

  @override
  Future<RevisionSheet> generateRevisionSheet({required String documentId}) {
    throw UnimplementedError();
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
  testWidgets('shows a readable reason for failed AI processing', (
    tester,
  ) async {
    final documentsApi = StaticDocumentsApi();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [documentsApiProvider.overrideWithValue(documentsApi)],
        child: MaterialApp(
          home: Scaffold(
            body: SubjectDetailPage(
              subjectId: 'subject-1',
              controller: SubjectsController(SingleSubjectRepository()),
              documentsController: DocumentsController(documentsApi),
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('cours.pdf'), findsOneWidget);
    expect(find.text('Erreur IA'), findsOneWidget);
  });

  testWidgets('opens document detail when tapping a document', (tester) async {
    final documentsApi = StaticDocumentsApi();
    final router = GoRouter(
      initialLocation: '/subjects/subject-1',
      routes: [
        GoRoute(
          path: '/subjects/:subjectId',
          builder: (context, state) => SubjectDetailPage(
            subjectId: state.pathParameters['subjectId'] ?? '',
            controller: SubjectsController(SingleSubjectRepository()),
            documentsController: DocumentsController(documentsApi),
          ),
          routes: [
            GoRoute(
              path: 'documents/:documentId',
              builder: (context, state) =>
                  Text('Document ${state.pathParameters['documentId']}'),
            ),
          ],
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [documentsApiProvider.overrideWithValue(documentsApi)],
        child: MaterialApp.router(routerConfig: router),
      ),
    );

    await tester.pumpAndSettle();
    await tester.tap(find.text('cours.pdf'));
    await tester.pumpAndSettle();

    expect(find.text('Document document-1'), findsOneWidget);
  });

  testWidgets('deletes a document after confirmation', (tester) async {
    final documentsApi = StaticDocumentsApi();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [documentsApiProvider.overrideWithValue(documentsApi)],
        child: MaterialApp(
          home: Scaffold(
            body: SubjectDetailPage(
              subjectId: 'subject-1',
              controller: SubjectsController(SingleSubjectRepository()),
              documentsController: DocumentsController(documentsApi),
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text('cours.pdf'), findsOneWidget);

    await tester.tap(find.byTooltip('Supprimer le cours'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Supprimer'));
    await tester.pumpAndSettle();

    expect(documentsApi.documents, isEmpty);
    expect(find.text('cours.pdf'), findsNothing);
  });
}
