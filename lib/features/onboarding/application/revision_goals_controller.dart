import '../domain/revision_goal.dart';

abstract interface class RevisionGoalsRepository {
  Future<void> saveRevisionGoal(RevisionGoal goal);
}

class RevisionGoalsController {
  const RevisionGoalsController(this._repository);

  final RevisionGoalsRepository _repository;

  Future<void> saveGoal({
    required DateTime targetDate,
    required int weeklyMinutes,
  }) {
    if (weeklyMinutes < 30) {
      throw ArgumentError('Weekly revision time must be at least 30 minutes');
    }

    return _repository.saveRevisionGoal(
      RevisionGoal(targetDate: targetDate, weeklyMinutes: weeklyMinutes),
    );
  }
}
