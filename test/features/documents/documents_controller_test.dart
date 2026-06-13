import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:revision_app/features/documents/application/documents_controller.dart';
import 'package:revision_app/features/documents/domain/revision_document.dart';

class FakeDocumentUploader implements DocumentUploader {
  FakeDocumentUploader({
    this.uploaded = const UploadedDocumentFile(
      fileName: '1710000000000-cours.pdf',
      storagePath:
          'students/firebase-1/subjects/subject-1/1710000000000-cours.pdf',
      mimeType: 'application/pdf',
    ),
    this.error,
  });

  final UploadedDocumentFile uploaded;
  final Object? error;

  String? uploadedSubjectId;
  String? uploadedFileName;
  Uint8List? uploadedBytes;

  @override
  Future<UploadedDocumentFile> uploadCoursePdf({
    required String subjectId,
    required String fileName,
    required Uint8List bytes,
  }) async {
    uploadedSubjectId = subjectId;
    uploadedFileName = fileName;
    uploadedBytes = bytes;

    final error = this.error;
    if (error != null) {
      throw error;
    }

    return uploaded;
  }
}

class FakeDocumentsApi implements DocumentsApi {
  int registerCallCount = 0;
  String? registeredSubjectId;
  String? registeredKind;
  String? registeredFileName;
  String? registeredStoragePath;
  String? registeredMimeType;
  final List<RevisionDocument> documents = [];

  @override
  Future<RevisionDocument> registerDocument({
    required String subjectId,
    required String kind,
    required String fileName,
    required String storagePath,
    required String mimeType,
  }) async {
    registerCallCount += 1;
    registeredSubjectId = subjectId;
    registeredKind = kind;
    registeredFileName = fileName;
    registeredStoragePath = storagePath;
    registeredMimeType = mimeType;

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

void main() {
  test('uploads and registers a course PDF', () async {
    final api = FakeDocumentsApi();
    final uploader = FakeDocumentUploader();
    final controller = DocumentsController(uploader, api);
    final bytes = Uint8List.fromList([1, 2, 3]);

    final document = await controller.uploadCoursePdf(
      subjectId: 'subject-1',
      fileName: 'cours.pdf',
      bytes: bytes,
    );

    expect(uploader.uploadedSubjectId, 'subject-1');
    expect(uploader.uploadedFileName, 'cours.pdf');
    expect(uploader.uploadedBytes, bytes);
    expect(api.registerCallCount, 1);
    expect(api.registeredSubjectId, 'subject-1');
    expect(api.registeredKind, 'COURSE_PDF');
    expect(api.registeredFileName, '1710000000000-cours.pdf');
    expect(
      api.registeredStoragePath,
      'students/firebase-1/subjects/subject-1/1710000000000-cours.pdf',
    );
    expect(api.registeredMimeType, 'application/pdf');
    expect(document.status, 'UPLOADED');
  });

  test('does not register the document when upload fails', () async {
    final api = FakeDocumentsApi();
    final controller = DocumentsController(
      FakeDocumentUploader(error: StateError('upload failed')),
      api,
    );

    await expectLater(
      controller.uploadCoursePdf(
        subjectId: 'subject-1',
        fileName: 'cours.pdf',
        bytes: Uint8List.fromList([1, 2, 3]),
      ),
      throwsStateError,
    );

    expect(api.registerCallCount, 0);
  });

  test('lists documents for a subject', () async {
    final api = FakeDocumentsApi();
    final controller = DocumentsController(FakeDocumentUploader(), api);

    await controller.uploadCoursePdf(
      subjectId: 'subject-1',
      fileName: 'cours.pdf',
      bytes: Uint8List.fromList([1, 2, 3]),
    );

    final documents = await controller.listSubjectDocuments('subject-1');

    expect(documents.single.fileName, '1710000000000-cours.pdf');
  });
}
