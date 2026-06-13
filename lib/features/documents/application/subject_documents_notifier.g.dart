// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subject_documents_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SubjectDocumentsNotifier)
final subjectDocumentsProvider = SubjectDocumentsNotifierFamily._();

final class SubjectDocumentsNotifierProvider
    extends
        $AsyncNotifierProvider<
          SubjectDocumentsNotifier,
          List<RevisionDocument>
        > {
  SubjectDocumentsNotifierProvider._({
    required SubjectDocumentsNotifierFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'subjectDocumentsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$subjectDocumentsNotifierHash();

  @override
  String toString() {
    return r'subjectDocumentsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  SubjectDocumentsNotifier create() => SubjectDocumentsNotifier();

  @override
  bool operator ==(Object other) {
    return other is SubjectDocumentsNotifierProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$subjectDocumentsNotifierHash() =>
    r'8f6c753279dad00a57fe698a1b3ce676d958da0e';

final class SubjectDocumentsNotifierFamily extends $Family
    with
        $ClassFamilyOverride<
          SubjectDocumentsNotifier,
          AsyncValue<List<RevisionDocument>>,
          List<RevisionDocument>,
          FutureOr<List<RevisionDocument>>,
          String
        > {
  SubjectDocumentsNotifierFamily._()
    : super(
        retry: null,
        name: r'subjectDocumentsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  SubjectDocumentsNotifierProvider call(String subjectId) =>
      SubjectDocumentsNotifierProvider._(argument: subjectId, from: this);

  @override
  String toString() => r'subjectDocumentsProvider';
}

abstract class _$SubjectDocumentsNotifier
    extends $AsyncNotifier<List<RevisionDocument>> {
  late final _$args = ref.$arg as String;
  String get subjectId => _$args;

  FutureOr<List<RevisionDocument>> build(String subjectId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<AsyncValue<List<RevisionDocument>>, List<RevisionDocument>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<RevisionDocument>>,
                List<RevisionDocument>
              >,
              AsyncValue<List<RevisionDocument>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
