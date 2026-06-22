import 'package:Neralune/features/subjects/application/subjects_controller.dart';
import 'package:Neralune/features/subjects/domain/subject.dart';

class InMemorySubjectsRepository implements SubjectsRepository {
  final List<Subject> subjects = [];
  int updateCount = 0;
  int archiveCount = 0;
  int lifecycleCount = 0;
  String? lastArchivedSubjectId;
  String? lastUpdatedSubjectId;

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

    updateCount += 1;
    lastUpdatedSubjectId = id;
    final updated = Subject(
      id: id,
      name: name,
      priority: priority,
      weeklyMinutes: subjects[index].weeklyMinutes,
    );
    subjects[index] = updated;
    return updated;
  }

  @override
  Future<SubjectLifecycleDecision> getSubjectLifecycle(String id) async {
    lifecycleCount += 1;
    if (!subjects.any((subject) => subject.id == id)) {
      throw StateError('Subject not found');
    }

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
    archiveCount += 1;
    lastArchivedSubjectId = id;
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
