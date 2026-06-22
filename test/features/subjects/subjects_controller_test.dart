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

  @override
  Future<Subject> updateSubject({
    required String id,
    required String name,
    required int priority,
  }) async {
    final index = subjects.indexWhere((subject) => subject.id == id);
    if (index < 0) {
      throw StateError('Subject not found');
    }

    final updated = Subject(id: id, name: name, priority: priority);
    subjects[index] = updated;
    return updated;
  }

  @override
  Future<SubjectLifecycleDecision> getSubjectLifecycle(String id) async {
    return SubjectLifecycleDecision(
      subjectId: id,
      status: SubjectLifecycleStatus.active,
      recommendedAction: SubjectLifecycleRecommendedAction.delete,
      canDelete: true,
      canArchive: false,
      canUpdate: true,
      blockingReasons: const [],
      userMessage: 'Cette matière peut être supprimée.',
    );
  }

  @override
  Future<SubjectLifecycleDecision> archiveSubject(String id) async {
    subjects.removeWhere((subject) => subject.id == id);
    return SubjectLifecycleDecision(
      subjectId: id,
      status: SubjectLifecycleStatus.archived,
      recommendedAction: SubjectLifecycleRecommendedAction.block,
      canDelete: false,
      canArchive: false,
      canUpdate: false,
      blockingReasons: const ['ALREADY_ARCHIVED'],
      userMessage: 'Cette matière est archivée.',
    );
  }
}

class CapturingSubjectsRepository implements SubjectsRepository {
  int createSubjectCallCount = 0;
  int deleteSubjectCallCount = 0;
  int updateSubjectCallCount = 0;
  int archiveSubjectCallCount = 0;
  int lifecycleSubjectCallCount = 0;
  String? createdName;
  int? createdPriority;
  int? createdWeeklyMinutes;
  String? deletedSubjectId;
  String? updatedSubjectId;
  String? updatedName;
  int? updatedPriority;
  String? archivedSubjectId;

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

  @override
  Future<Subject> updateSubject({
    required String id,
    required String name,
    required int priority,
  }) async {
    updateSubjectCallCount += 1;
    updatedSubjectId = id;
    updatedName = name;
    updatedPriority = priority;
    return Subject(id: id, name: name, priority: priority);
  }

  @override
  Future<SubjectLifecycleDecision> getSubjectLifecycle(String id) async {
    lifecycleSubjectCallCount += 1;
    return SubjectLifecycleDecision(
      subjectId: id,
      status: SubjectLifecycleStatus.active,
      recommendedAction: SubjectLifecycleRecommendedAction.delete,
      canDelete: true,
      canArchive: false,
      canUpdate: true,
      blockingReasons: const [],
      userMessage: 'Cette matière peut être supprimée.',
    );
  }

  @override
  Future<SubjectLifecycleDecision> archiveSubject(String id) async {
    archiveSubjectCallCount += 1;
    archivedSubjectId = id;
    return SubjectLifecycleDecision(
      subjectId: id,
      status: SubjectLifecycleStatus.archived,
      recommendedAction: SubjectLifecycleRecommendedAction.block,
      canDelete: false,
      canArchive: false,
      canUpdate: false,
      blockingReasons: const ['ALREADY_ARCHIVED'],
      userMessage: 'Cette matière est archivée.',
    );
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

  test('trims subject fields before updating a subject', () async {
    final repository = CapturingSubjectsRepository();
    final controller = SubjectsController(repository);

    await controller.updateSubject(
      id: ' subject-1 ',
      name: '  Japonais  ',
      priority: 4,
    );

    expect(repository.updateSubjectCallCount, 1);
    expect(repository.updatedSubjectId, 'subject-1');
    expect(repository.updatedName, 'Japonais');
    expect(repository.updatedPriority, 4);
  });

  test('trims subject id before loading lifecycle', () async {
    final repository = CapturingSubjectsRepository();
    final controller = SubjectsController(repository);

    final decision = await controller.getSubjectLifecycle(' subject-1 ');

    expect(repository.lifecycleSubjectCallCount, 1);
    expect(decision.subjectId, 'subject-1');
  });

  test('trims subject id before archiving a subject', () async {
    final repository = CapturingSubjectsRepository();
    final controller = SubjectsController(repository);

    await controller.archiveSubject(' subject-1 ');

    expect(repository.archiveSubjectCallCount, 1);
    expect(repository.archivedSubjectId, 'subject-1');
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
