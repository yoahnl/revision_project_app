import 'package:flutter_test/flutter_test.dart';
import 'package:Neralune/features/onboarding/application/revision_goals_controller.dart';
import 'package:Neralune/features/onboarding/domain/revision_goal.dart';

class CapturingRevisionGoalsRepository implements RevisionGoalsRepository {
  RevisionGoal? savedGoal;

  @override
  Future<void> saveRevisionGoal(RevisionGoal goal) async {
    savedGoal = goal;
  }
}

void main() {
  test('saves valid revision goals', () async {
    final repository = CapturingRevisionGoalsRepository();
    final controller = RevisionGoalsController(repository);
    final targetDate = DateTime.utc(2026, 7, 13);

    await controller.saveGoal(targetDate: targetDate, weeklyMinutes: 180);

    expect(repository.savedGoal?.targetDate, targetDate);
    expect(repository.savedGoal?.weeklyMinutes, 180);
  });

  test('rejects weekly revision time under 30 minutes', () async {
    final repository = CapturingRevisionGoalsRepository();
    final controller = RevisionGoalsController(repository);

    expect(
      () => controller.saveGoal(
        targetDate: DateTime.utc(2026, 7, 13),
        weeklyMinutes: 29,
      ),
      throwsArgumentError,
    );
    expect(repository.savedGoal, isNull);
  });
}
