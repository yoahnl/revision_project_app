import 'package:flutter_test/flutter_test.dart';
import 'package:revision_app/features/documents/data/firebase_document_uploader.dart';

void main() {
  group('buildCoursePdfUploadMetadata', () {
    test('creates a unique canonical filename and storage path', () {
      final uploaded = buildCoursePdfUploadMetadata(
        firebaseUid: 'firebase-1',
        subjectId: 'subject-1',
        fileName: 'Cours chapitre 1.pdf',
        now: () =>
            DateTime.fromMillisecondsSinceEpoch(1710000000000, isUtc: true),
      );

      expect(uploaded.fileName, '1710000000000-Cours_chapitre_1.pdf');
      expect(
        uploaded.storagePath,
        'students/firebase-1/subjects/subject-1/'
        '1710000000000-Cours_chapitre_1.pdf',
      );
      expect(uploaded.mimeType, 'application/pdf');
    });

    test('rejects invalid subject ids and filenames before upload', () {
      for (final subjectId in [
        '',
        ' ',
        '.',
        '..',
        'subject/1',
        r'subject\1',
        'subject%1',
      ]) {
        expect(
          () => buildCoursePdfUploadMetadata(
            firebaseUid: 'firebase-1',
            subjectId: subjectId,
            fileName: 'cours.pdf',
            now: () => DateTime.fromMillisecondsSinceEpoch(1710000000000),
          ),
          throwsArgumentError,
        );
      }

      for (final fileName in [
        '',
        ' ',
        '.',
        '..',
        'dir/cours.pdf',
        r'dir\cours.pdf',
        'cours%2epdf',
      ]) {
        expect(
          () => buildCoursePdfUploadMetadata(
            firebaseUid: 'firebase-1',
            subjectId: 'subject-1',
            fileName: fileName,
            now: () => DateTime.fromMillisecondsSinceEpoch(1710000000000),
          ),
          throwsArgumentError,
        );
      }
    });

    test(
      'keeps generated filenames and storage paths within backend limits',
      () {
        final uploaded = buildCoursePdfUploadMetadata(
          firebaseUid: 'firebase-1',
          subjectId: 'subject-1',
          fileName: '${List.filled(400, 'a').join()}.pdf',
          now: () => DateTime.fromMillisecondsSinceEpoch(1710000000000),
        );

        expect(uploaded.fileName.length, lessThanOrEqualTo(255));
        expect(uploaded.storagePath.length, lessThanOrEqualTo(512));
        expect(uploaded.storagePath.endsWith('/${uploaded.fileName}'), isTrue);
      },
    );

    test('rejects generated storage paths that exceed backend limits', () {
      expect(
        () => buildCoursePdfUploadMetadata(
          firebaseUid: 'firebase-${List.filled(480, 'a').join()}',
          subjectId: 'subject-1',
          fileName: 'cours.pdf',
          now: () => DateTime.fromMillisecondsSinceEpoch(1710000000000),
        ),
        throwsArgumentError,
      );
    });
  });
}
