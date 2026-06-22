import '../domain/subject.dart';

abstract interface class SubjectsRepository {
  Future<List<Subject>> listSubjects();

  Future<Subject> getSubject(String id);

  Future<Subject> createSubject({
    required String name,
    required int priority,
    int weeklyMinutes = 0,
  });

  Future<Subject> updateSubject({
    required String id,
    required String name,
    required int priority,
  });

  Future<SubjectLifecycleDecision> getSubjectLifecycle(String id);

  Future<SubjectLifecycleDecision> archiveSubject(String id);

  Future<void> deleteSubject(String id);
}

class SubjectsController {
  const SubjectsController(this._repository);

  final SubjectsRepository _repository;

  Future<List<Subject>> listSubjects() => _repository.listSubjects();

  Future<Subject> getSubject(String id) {
    final trimmed = id.trim();

    if (trimmed.isEmpty) {
      throw ArgumentError('Subject id is required');
    }

    return _repository.getSubject(trimmed);
  }

  Future<Subject> createSubject({
    required String name,
    required int priority,
    int weeklyMinutes = 0,
  }) {
    final trimmed = name.trim();

    if (trimmed.length < 2) {
      throw ArgumentError('Subject name must contain at least 2 characters');
    }

    if (weeklyMinutes < 0) {
      throw ArgumentError('Weekly minutes cannot be negative');
    }

    return _repository.createSubject(
      name: trimmed,
      priority: priority,
      weeklyMinutes: weeklyMinutes,
    );
  }

  Future<void> deleteSubject(String id) {
    final trimmed = id.trim();

    if (trimmed.isEmpty) {
      throw ArgumentError('Subject id is required');
    }

    return _repository.deleteSubject(trimmed);
  }

  Future<Subject> updateSubject({
    required String id,
    required String name,
    required int priority,
  }) {
    final trimmedId = id.trim();
    final trimmedName = name.trim();

    if (trimmedId.isEmpty) {
      throw ArgumentError('Subject id is required');
    }
    if (trimmedName.length < 2) {
      throw ArgumentError('Subject name must contain at least 2 characters');
    }

    return _repository.updateSubject(
      id: trimmedId,
      name: trimmedName,
      priority: priority,
    );
  }

  Future<SubjectLifecycleDecision> getSubjectLifecycle(String id) {
    final trimmed = id.trim();

    if (trimmed.isEmpty) {
      throw ArgumentError('Subject id is required');
    }

    return _repository.getSubjectLifecycle(trimmed);
  }

  Future<SubjectLifecycleDecision> archiveSubject(String id) {
    final trimmed = id.trim();

    if (trimmed.isEmpty) {
      throw ArgumentError('Subject id is required');
    }

    return _repository.archiveSubject(trimmed);
  }
}
