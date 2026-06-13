import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:revision_app/app/di/providers.dart';
import 'package:revision_app/features/today/application/today_notifier.dart';

import '../../fakes/in_memory_today_repository.dart';

void main() {
  test('today notifier loads plan through repository provider', () async {
    final repository = InMemoryTodayRepository();
    final container = ProviderContainer(
      overrides: [todayRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);

    final plan = await container.read(todayNotifierProvider.future);

    expect(plan.items, isEmpty);
    expect(repository.getTodayPlanCalls, 1);
  });
}
