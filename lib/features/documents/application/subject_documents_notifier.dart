import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../app/di/providers.dart';
import '../domain/revision_document.dart';

part 'subject_documents_notifier.g.dart';

@riverpod
class SubjectDocumentsNotifier extends _$SubjectDocumentsNotifier {
  @override
  Future<List<RevisionDocument>> build(String subjectId) {
    return ref
        .read(documentsApiProvider)
        .listSubjectDocuments(subjectId: subjectId);
  }

  Future<void> reload() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref
          .read(documentsApiProvider)
          .listSubjectDocuments(subjectId: subjectId),
    );
  }

  Future<void> deleteDocument(String documentId) async {
    await ref.read(documentsApiProvider).deleteDocument(documentId: documentId);
    await reload();
  }
}

final subjectDocumentsNotifierProvider = subjectDocumentsProvider;
