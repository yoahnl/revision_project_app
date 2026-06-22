import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../app/di/providers.dart';
import '../domain/subject.dart';

part 'subjects_notifier.g.dart';

@riverpod
class SubjectsNotifier extends _$SubjectsNotifier {
  @override
  Future<List<Subject>> build() {
    return ref.read(subjectsRepositoryProvider).listSubjects();
  }

  Future<void> reload() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(subjectsRepositoryProvider).listSubjects(),
    );
  }

  Future<Subject> createSubject({
    required String name,
    int priority = 3,
  }) async {
    final created = await ref
        .read(subjectsRepositoryProvider)
        .createSubject(name: name, priority: priority);
    await reload();
    return created;
  }

  Future<Subject> updateSubject({
    required String id,
    required String name,
    required int priority,
  }) async {
    final updated = await ref
        .read(subjectsRepositoryProvider)
        .updateSubject(id: id, name: name, priority: priority);
    await reload();
    return updated;
  }

  Future<SubjectLifecycleDecision> getSubjectLifecycle(String id) {
    return ref.read(subjectsRepositoryProvider).getSubjectLifecycle(id);
  }

  Future<SubjectLifecycleDecision> archiveSubject(String id) async {
    final decision = await ref
        .read(subjectsRepositoryProvider)
        .archiveSubject(id);
    await reload();
    return decision;
  }

  Future<void> deleteSubject(String id) async {
    await ref.read(subjectsRepositoryProvider).deleteSubject(id);
    await reload();
  }
}

final subjectsNotifierProvider = subjectsProvider;
