// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'today_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(TodayNotifier)
final todayProvider = TodayNotifierProvider._();

final class TodayNotifierProvider
    extends $AsyncNotifierProvider<TodayNotifier, TodayPlan> {
  TodayNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'todayProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$todayNotifierHash();

  @$internal
  @override
  TodayNotifier create() => TodayNotifier();
}

String _$todayNotifierHash() => r'62d0e2ae9dcbf68f92592a2eef6eec2f0779a484';

abstract class _$TodayNotifier extends $AsyncNotifier<TodayPlan> {
  FutureOr<TodayPlan> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<TodayPlan>, TodayPlan>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<TodayPlan>, TodayPlan>,
              AsyncValue<TodayPlan>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
