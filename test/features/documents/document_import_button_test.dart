import 'dart:async';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:Neralune/features/documents/application/documents_controller.dart';
import 'package:Neralune/features/documents/domain/revision_document.dart';
import 'package:Neralune/features/documents/domain/source_lifecycle.dart';
import 'package:Neralune/presentation/design_system/components/revision_mvp_components.dart';
import 'package:Neralune/presentation/widgets/documents/document_import_button.dart';

class CompletingDocumentsApi implements DocumentsApi {
  final completer = Completer<void>();
  int uploadCallCount = 0;

  @override
  Future<RevisionDocument> uploadCoursePdf({
    required String subjectId,
    required String fileName,
    required Uint8List bytes,
  }) async {
    uploadCallCount += 1;
    await completer.future;

    return RevisionDocument(
      id: 'document-1',
      subjectId: subjectId,
      kind: 'COURSE_PDF',
      fileName: '1710000000000-cours.pdf',
      status: 'UPLOADED',
      mimeType: 'application/pdf',
    );
  }

  @override
  Future<List<RevisionDocument>> listSubjectDocuments({
    required String subjectId,
  }) async {
    return const [];
  }

  @override
  Future<RevisionDocument> getDocument({required String documentId}) async {
    throw StateError('No documents available');
  }

  @override
  Future<void> deleteDocument({required String documentId}) async {}

  @override
  Future<SourceLifecycleDecision> getDocumentLifecycle({
    required String documentId,
  }) async {
    return SourceLifecycleDecision(
      documentId: documentId,
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
}

class FailingDocumentsApi extends CompletingDocumentsApi {
  @override
  Future<RevisionDocument> uploadCoursePdf({
    required String subjectId,
    required String fileName,
    required Uint8List bytes,
  }) async {
    throw StateError('upload failed');
  }
}

void main() {
  testWidgets('disables the button while upload is in progress', (
    tester,
  ) async {
    final documentsApi = CompletingDocumentsApi();
    final controller = DocumentsController(documentsApi);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DocumentImportButton(
            subjectId: 'subject-1',
            controller: controller,
            pickFiles: () async => FilePickerResult([
              PlatformFile(
                name: 'cours.pdf',
                size: 3,
                bytes: Uint8List.fromList([1, 2, 3]),
              ),
            ]),
          ),
        ),
      ),
    );

    await tester.tap(find.byType(RevisionGradientButton));
    await tester.pump();

    expect(
      tester
          .widget<RevisionGradientButton>(find.byType(RevisionGradientButton))
          .onPressed,
      isNull,
    );

    await tester.tap(find.byType(RevisionGradientButton));
    await tester.pump();

    expect(documentsApi.uploadCallCount, 1);

    documentsApi.completer.complete();
    await tester.pumpAndSettle();

    expect(
      tester
          .widget<RevisionGradientButton>(find.byType(RevisionGradientButton))
          .onPressed,
      isNotNull,
    );
  });

  testWidgets('shows a snackbar when upload fails', (tester) async {
    final controller = DocumentsController(FailingDocumentsApi());

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DocumentImportButton(
            subjectId: 'subject-1',
            controller: controller,
            pickFiles: () async => FilePickerResult([
              PlatformFile(
                name: 'cours.pdf',
                size: 3,
                bytes: Uint8List.fromList([1, 2, 3]),
              ),
            ]),
          ),
        ),
      ),
    );

    await tester.tap(find.byType(RevisionGradientButton));
    await tester.pump();

    expect(find.text("Impossible d'importer le document"), findsOneWidget);
  });

  testWidgets('notifies parent widgets after a successful import', (
    tester,
  ) async {
    var importedCount = 0;
    final documentsApi = CompletingDocumentsApi();
    final controller = DocumentsController(documentsApi);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DocumentImportButton(
            subjectId: 'subject-1',
            controller: controller,
            onImported: () => importedCount += 1,
            pickFiles: () async => FilePickerResult([
              PlatformFile(
                name: 'cours.pdf',
                size: 3,
                bytes: Uint8List.fromList([1, 2, 3]),
              ),
            ]),
          ),
        ),
      ),
    );

    await tester.tap(find.byType(RevisionGradientButton));
    await tester.pump();

    documentsApi.completer.complete();
    await tester.pumpAndSettle();

    expect(importedCount, 1);
  });
}
