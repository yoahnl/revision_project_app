import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../app/di/providers.dart';
import '../domain/today_plan.dart';

part 'today_notifier.g.dart';

@riverpod
class TodayNotifier extends _$TodayNotifier {
  @override
  Future<TodayPlan> build() {
    return ref.read(todayRepositoryProvider).getTodayPlan();
  }

  Future<void> reload() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(todayRepositoryProvider).getTodayPlan(),
    );
  }
}

final todayNotifierProvider = todayProvider;
