import 'package:flutter_test/flutter_test.dart';
import 'package:Neralune/features/subjects/application/subjects_controller.dart';
import 'package:Neralune/features/subjects/domain/subject.dart';

class InMemorySubjectsRepository implements SubjectsRepository {
  final subjects = <Subject>[];

  @override
  Future<List<Subject>> listSubjects() async => subjects;

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

class CapturingSubjectsRepository implements SubjectsRepository {
  int createSubjectCallCount = 0;
  int deleteSubjectCallCount = 0;
  String? createdName;
  int? createdPriority;
  int? createdWeeklyMinutes;
  String? deletedSubjectId;

  @override
  Future<List<Subject>> listSubjects() async => const [];

  @override
  Future<Subject> getSubject(String id) async {
    return Subject(id: id, name: 'Anatomie', priority: 5);
  }

  @override
  Future<Subject> createSubject({
    required String name,
    required int priority,
    int weeklyMinutes = 0,
  }) async {
    createSubjectCallCount += 1;
    createdName = name;
    createdPriority = priority;
    createdWeeklyMinutes = weeklyMinutes;

    return Subject(
      id: 'subject-1',
      name: name,
      priority: priority,
      weeklyMinutes: weeklyMinutes,
    );
  }

  @override
  Future<void> deleteSubject(String id) async {
    deleteSubjectCallCount += 1;
    deletedSubjectId = id;
  }
}

void main() {
  test('creates and lists subjects', () async {
    final repository = InMemorySubjectsRepository();
    final controller = SubjectsController(repository);

    await controller.createSubject(name: 'Anatomie', priority: 5);
    final subjects = await controller.listSubjects();

    expect(subjects, hasLength(1));
    expect(subjects.single.name, 'Anatomie');
  });

  test('trims subject name and delegates priority to repository', () async {
    final repository = CapturingSubjectsRepository();
    final controller = SubjectsController(repository);

    await controller.createSubject(name: '  Anatomie  ', priority: 5);

    expect(repository.createSubjectCallCount, 1);
    expect(repository.createdName, 'Anatomie');
    expect(repository.createdPriority, 5);
    expect(repository.createdWeeklyMinutes, 0);
  });

  test('delegates weekly minutes when provided', () async {
    final repository = CapturingSubjectsRepository();
    final controller = SubjectsController(repository);

    await controller.createSubject(
      name: 'Anatomie',
      priority: 4,
      weeklyMinutes: 180,
    );

    expect(repository.createdWeeklyMinutes, 180);
  });

  test('trims subject id before loading a subject', () async {
    final repository = CapturingSubjectsRepository();
    final controller = SubjectsController(repository);

    final subject = await controller.getSubject(' subject-1 ');

    expect(subject.id, 'subject-1');
  });

  test('trims subject id before deleting a subject', () async {
    final repository = CapturingSubjectsRepository();
    final controller = SubjectsController(repository);

    await controller.deleteSubject(' subject-1 ');

    expect(repository.deleteSubjectCallCount, 1);
    expect(repository.deletedSubjectId, 'subject-1');
  });

  test('rejects short subject names', () async {
    final repository = CapturingSubjectsRepository();
    final controller = SubjectsController(repository);

    expect(
      () => controller.createSubject(name: 'A', priority: 3),
      throwsArgumentError,
    );
    expect(repository.createSubjectCallCount, 0);
  });

  test('rejects empty subject ids before deleting a subject', () async {
    final repository = CapturingSubjectsRepository();
    final controller = SubjectsController(repository);

    expect(() => controller.deleteSubject('  '), throwsArgumentError);
    expect(repository.deleteSubjectCallCount, 0);
  });
}
