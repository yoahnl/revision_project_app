import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:revision_app/app/di/providers.dart';
import 'package:revision_app/features/documents/application/subject_documents_notifier.dart';
import 'package:revision_app/features/documents/domain/revision_document.dart';

import '../../fakes/in_memory_documents_api.dart';

void main() {
  test(
    'subject documents notifier loads documents through API provider',
    () async {
      final api = InMemoryDocumentsApi()
        ..documents.add(
          const RevisionDocument(
            id: 'document-1',
            subjectId: 'subject-1',
            kind: 'COURSE_PDF',
            fileName: 'cours.pdf',
            status: 'READY',
            mimeType: 'application/pdf',
          ),
        );
      final container = ProviderContainer(
        overrides: [documentsApiProvider.overrideWithValue(api)],
      );
      addTearDown(container.dispose);

      final documents = await container.read(
        subjectDocumentsNotifierProvider('subject-1').future,
      );

      expect(documents.single.fileName, 'cours.pdf');
    },
  );

  test('subject documents notifier deletes a document and reloads the list', () async {
    final api = InMemoryDocumentsApi()
      ..documents.add(
        const RevisionDocument(
          id: 'document-1',
          subjectId: 'subject-1',
          kind: 'COURSE_PDF',
          fileName: 'cours.pdf',
          status: 'READY',
          mimeType: 'application/pdf',
        ),
      );
    final container = ProviderContainer(
      overrides: [documentsApiProvider.overrideWithValue(api)],
    );
    addTearDown(container.dispose);

    await container.read(subjectDocumentsNotifierProvider('subject-1').future);
    await container
        .read(subjectDocumentsNotifierProvider('subject-1').notifier)
        .deleteDocument('document-1');
    final documents = await container.read(
      subjectDocumentsNotifierProvider('subject-1').future,
    );

    expect(documents, isEmpty);
  });
}
