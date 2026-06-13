import 'package:revision_app/features/onboarding/application/revision_goals_controller.dart';
import 'package:revision_app/features/onboarding/domain/revision_goal.dart';

class InMemoryRevisionGoalsRepository implements RevisionGoalsRepository {
  final List<RevisionGoal> goals = [];

  @override
  Future<void> saveRevisionGoal(RevisionGoal goal) async {
    goals.add(goal);
  }
}
