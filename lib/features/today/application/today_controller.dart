import '../domain/today_plan.dart';

abstract interface class TodayRepository {
  Future<TodayPlan> getTodayPlan();
}

class TodayController {
  const TodayController(this._repository);

  final TodayRepository _repository;

  Future<TodayPlan> getTodayPlan() => _repository.getTodayPlan();
}
