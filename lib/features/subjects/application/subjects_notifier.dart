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
}

final subjectsNotifierProvider = subjectsProvider;
