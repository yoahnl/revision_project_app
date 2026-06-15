import 'package:revision_app/features/today/application/today_controller.dart';
import 'package:revision_app/features/today/domain/today_plan.dart';

class InMemoryTodayRepository implements TodayRepository {
  TodayPlan plan = TodayPlan(
    generatedAt: DateTime.utc(2026, 6, 13),
    items: const [],
  );
  Object? error;
  int getTodayPlanCalls = 0;

  @override
  Future<TodayPlan> getTodayPlan() async {
    getTodayPlanCalls += 1;
    final currentError = error;
    if (currentError != null) {
      throw currentError;
    }

    return plan;
  }
}
