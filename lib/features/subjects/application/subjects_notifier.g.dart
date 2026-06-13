// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subjects_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SubjectsNotifier)
final subjectsProvider = SubjectsNotifierProvider._();

final class SubjectsNotifierProvider
    extends $AsyncNotifierProvider<SubjectsNotifier, List<Subject>> {
  SubjectsNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'subjectsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$subjectsNotifierHash();

  @$internal
  @override
  SubjectsNotifier create() => SubjectsNotifier();
}

String _$subjectsNotifierHash() => r'd95c323dd7c7a0876ab0df32b96c67ebccd03685';

abstract class _$SubjectsNotifier extends $AsyncNotifier<List<Subject>> {
  FutureOr<List<Subject>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<Subject>>, List<Subject>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Subject>>, List<Subject>>,
              AsyncValue<List<Subject>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
