import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:revision_app/app/di/providers.dart';
import 'package:revision_app/features/documents/application/documents_controller.dart';
import 'package:revision_app/features/documents/domain/revision_document.dart';
import 'package:revision_app/features/subjects/application/subjects_controller.dart';
import 'package:revision_app/features/subjects/domain/subject.dart';
import 'package:revision_app/features/subjects/presentation/subject_detail_page.dart';

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
  Future<Subject> getSubject(String id) async {
    return const Subject(id: 'subject-1', name: 'Biologie', priority: 4);
  }

  @override
  Future<List<Subject>> listSubjects() {
    throw UnimplementedError();
  }
}

class StaticDocumentsApi implements DocumentsApi {
  @override
  Future<RevisionDocument> getDocument({required String documentId}) {
    throw UnimplementedError();
  }

  @override
  Future<List<RevisionDocument>> listSubjectDocuments({
    required String subjectId,
  }) async {
    return const [
      RevisionDocument(
        id: 'document-1',
        subjectId: 'subject-1',
        kind: 'COURSE_PDF',
        fileName: 'cours.pdf',
        status: 'FAILED',
        mimeType: 'application/pdf',
        errorCode: 'KNOWLEDGE_EXTRACTION_FAILED',
      ),
    ];
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
}
