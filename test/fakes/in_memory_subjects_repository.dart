import 'package:revision_app/features/subjects/application/subjects_controller.dart';
import 'package:revision_app/features/subjects/domain/subject.dart';

class InMemorySubjectsRepository implements SubjectsRepository {
  final List<Subject> subjects = [];

  @override
  Future<List<Subject>> listSubjects() async {
    return List.unmodifiable(subjects);
  }

  @override
  Future<Subject> getSubject(String id) async {
    return subjects.singleWhere((subject) => subject.id == id);
  }

  @override
  Future<Subject> createSubject({
    required String name,
    required int priority,
    int weeklyMinutes = 0,
  }) async {
    final subject = Subject(
      id: 'subject-${subjects.length + 1}',
      name: name,
      priority: priority,
      weeklyMinutes: weeklyMinutes,
    );
    subjects.add(subject);

    return subject;
  }

  @override
  Future<void> deleteSubject(String id) async {
    subjects.removeWhere((subject) => subject.id == id);
  }
}
