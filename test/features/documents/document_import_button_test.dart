import 'dart:async';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:revision_app/features/documents/application/documents_controller.dart';
import 'package:revision_app/features/documents/domain/revision_document.dart';
import 'package:revision_app/features/documents/presentation/document_import_button.dart';

class CompletingUploader implements DocumentUploader {
  final completer = Completer<void>();
  int uploadCallCount = 0;

  @override
  Future<UploadedDocumentFile> uploadCoursePdf({
    required String subjectId,
    required String fileName,
    required Uint8List bytes,
  }) async {
    uploadCallCount += 1;
    await completer.future;

    return const UploadedDocumentFile(
      fileName: '1710000000000-cours.pdf',
      storagePath:
          'students/firebase-1/subjects/subject-1/1710000000000-cours.pdf',
      mimeType: 'application/pdf',
    );
  }
}

class FailingUploader implements DocumentUploader {
  @override
  Future<UploadedDocumentFile> uploadCoursePdf({
    required String subjectId,
    required String fileName,
    required Uint8List bytes,
  }) async {
    throw StateError('upload failed');
  }
}

class NoopApi implements DocumentsApi {
  @override
  Future<RevisionDocument> registerDocument({
    required String subjectId,
    required String kind,
    required String fileName,
    required String storagePath,
    required String mimeType,
  }) async {
    return RevisionDocument(
      id: 'document-1',
      subjectId: subjectId,
      kind: kind,
      fileName: fileName,
      status: 'UPLOADED',
      mimeType: mimeType,
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
}

void main() {
  testWidgets('disables the button while upload is in progress', (
    tester,
  ) async {
    final uploader = CompletingUploader();
    final controller = DocumentsController(uploader, NoopApi());

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

    await tester.tap(find.byType(FilledButton));
    await tester.pump();

    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNull,
    );

    await tester.tap(find.byType(FilledButton));
    await tester.pump();

    expect(uploader.uploadCallCount, 1);

    uploader.completer.complete();
    await tester.pumpAndSettle();

    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNotNull,
    );
  });

  testWidgets('shows a snackbar when upload fails', (tester) async {
    final controller = DocumentsController(FailingUploader(), NoopApi());

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

    await tester.tap(find.byType(FilledButton));
    await tester.pump();

    expect(find.text("Impossible d'importer le document"), findsOneWidget);
  });

  testWidgets('notifies parent widgets after a successful import', (
    tester,
  ) async {
    var importedCount = 0;
    final uploader = CompletingUploader();
    final controller = DocumentsController(uploader, NoopApi());

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

    await tester.tap(find.byType(FilledButton));
    await tester.pump();

    uploader.completer.complete();
    await tester.pumpAndSettle();

    expect(importedCount, 1);
  });
}
