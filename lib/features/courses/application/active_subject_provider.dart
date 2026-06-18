import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../subjects/application/subjects_notifier.dart';
import '../../subjects/domain/subject.dart';

final activeSubjectIdProvider =
    NotifierProvider<ActiveSubjectIdNotifier, String?>(
      ActiveSubjectIdNotifier.new,
    );

class ActiveSubjectIdNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void select(String subjectId) {
    final trimmed = subjectId.trim();
    state = trimmed.isEmpty ? null : trimmed;
  }
}

final activeSubjectProvider = Provider<AsyncValue<Subject?>>((ref) {
  final activeSubjectId = ref.watch(activeSubjectIdProvider);
  final subjects = ref.watch(subjectsNotifierProvider);

  return subjects.whenData((subjects) {
    if (subjects.isEmpty) {
      return null;
    }

    for (final subject in subjects) {
      if (subject.id == activeSubjectId) {
        return subject;
      }
    }

    return subjects.first;
  });
});
