import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/di/providers.dart';
import '../../activities/domain/rich_closed_exercise.dart';
import '../../documents/domain/revision_document.dart';
import '../../revision_sessions/domain/revision_session.dart';
import '../data/http_courses_repository.dart';
import '../domain/course_models.dart';
import '../domain/courses_repository.dart';
import 'course_pdf_picker.dart';

final coursesRepositoryProvider = Provider<CoursesRepository>((ref) {
  final dio = ref.read(dioProvider);
  final auth = ref.read(authControllerProvider);
  return HttpCoursesRepository(dio: dio, getIdToken: auth.requireIdToken);
});

final coursesProvider = FutureProvider.family<List<CourseListItem>, String>((
  ref,
  subjectId,
) {
  return ref.read(coursesRepositoryProvider).listCourses(subjectId: subjectId);
});

final courseDetailProvider = FutureProvider.family<CourseDetail, String>((
  ref,
  courseId,
) {
  return ref.read(coursesRepositoryProvider).getCourse(courseId: courseId);
});

final courseLifecycleProvider =
    FutureProvider.family<CourseLifecycleDecision, String>((ref, courseId) {
      return ref
          .read(coursesRepositoryProvider)
          .getCourseLifecycle(courseId: courseId);
    });

final courseProgressProvider = FutureProvider.family<CourseProgress, String>((
  ref,
  courseId,
) {
  return ref
      .read(coursesRepositoryProvider)
      .getCourseProgress(courseId: courseId);
});

final resumableCourseRevisionSessionProvider =
    FutureProvider.family<ResumableCourseRevisionSession?, String>((
      ref,
      courseId,
    ) {
      return ref
          .read(coursesRepositoryProvider)
          .getResumableCourseRevisionSession(courseId: courseId);
    });

final courseRevisionSessionHistoryProvider =
    FutureProvider.family<RevisionSessionHistoryResponse, String>((
      ref,
      courseId,
    ) {
      return ref
          .read(coursesRepositoryProvider)
          .getCourseRevisionSessionHistory(courseId: courseId);
    });

final courseRichClosedHistoryProvider =
    FutureProvider.family<CourseRichClosedHistoryResponse, String>((
      ref,
      courseId,
    ) {
      return ref
          .read(coursesRepositoryProvider)
          .getCourseRichClosedHistory(courseId: courseId);
    });

final courseRichRevisionOptionsProvider =
    FutureProvider.family<CourseRichRevisionOptions, String>((ref, courseId) {
      return ref
          .read(coursesRepositoryProvider)
          .getRichRevisionOptions(courseId: courseId);
    });

final courseExamPreparationOptionsProvider =
    FutureProvider.family<CourseExamPreparationOptions, String>((
      ref,
      courseId,
    ) {
      return ref
          .read(coursesRepositoryProvider)
          .getExamPreparationOptions(courseId: courseId);
    });

final courseExamPreparationHistoryProvider =
    FutureProvider.family<RevisionSessionHistoryResponse, String>((
      ref,
      courseId,
    ) {
      return ref
          .read(coursesRepositoryProvider)
          .getCourseExamPreparationHistory(courseId: courseId);
    });

typedef CourseQuestionBankReadinessKey = ({String courseId, int questionCount});

final courseQuestionBankReadinessProvider =
    FutureProvider.family<
      CourseQuestionBankReadiness,
      CourseQuestionBankReadinessKey
    >((ref, key) {
      return ref
          .read(coursesRepositoryProvider)
          .getQuestionBankReadiness(
            courseId: key.courseId,
            questionCount: key.questionCount,
          );
    });

final subjectProgressProvider = FutureProvider.family<SubjectProgress, String>((
  ref,
  subjectId,
) {
  return ref
      .read(coursesRepositoryProvider)
      .getSubjectProgress(subjectId: subjectId);
});

final courseRevisionSheetProvider =
    FutureProvider.family<RevisionSheet?, String>((ref, courseId) {
      return ref
          .read(coursesRepositoryProvider)
          .getCourseRevisionSheet(courseId: courseId);
    });

final createCourseControllerProvider =
    NotifierProvider<CreateCourseController, AsyncValue<void>>(
      CreateCourseController.new,
    );

final updateCourseControllerProvider =
    NotifierProvider<UpdateCourseController, AsyncValue<void>>(
      UpdateCourseController.new,
    );

final archiveCourseControllerProvider =
    NotifierProvider<ArchiveCourseController, AsyncValue<void>>(
      ArchiveCourseController.new,
    );

final deleteCourseControllerProvider =
    NotifierProvider<DeleteCourseController, AsyncValue<void>>(
      DeleteCourseController.new,
    );

final uploadCourseDocumentControllerProvider =
    NotifierProvider<
      UploadCourseDocumentController,
      AsyncValue<CourseDocument?>
    >(UploadCourseDocumentController.new);

final deleteCourseDocumentControllerProvider =
    NotifierProvider<DeleteCourseDocumentController, AsyncValue<void>>(
      DeleteCourseDocumentController.new,
    );

final archiveCourseDocumentControllerProvider =
    NotifierProvider<ArchiveCourseDocumentController, AsyncValue<void>>(
      ArchiveCourseDocumentController.new,
    );

final generateCourseRevisionSheetControllerProvider =
    NotifierProvider<
      GenerateCourseRevisionSheetController,
      AsyncValue<RevisionSheet?>
    >(GenerateCourseRevisionSheetController.new);

final prepareQuestionBankControllerProvider =
    NotifierProvider<
      PrepareQuestionBankController,
      AsyncValue<CourseQuestionBankReadiness?>
    >(PrepareQuestionBankController.new);

final startCourseQuickRevisionControllerProvider =
    NotifierProvider<
      StartCourseQuickRevisionController,
      AsyncValue<RevisionSessionResponse?>
    >(StartCourseQuickRevisionController.new);

final startCourseRichRevisionControllerProvider =
    NotifierProvider<
      StartCourseRichRevisionController,
      AsyncValue<RichClosedExercise?>
    >(StartCourseRichRevisionController.new);

class CreateCourseController extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<CourseListItem> create({
    required String subjectId,
    required CreateCourseInput input,
  }) async {
    state = const AsyncLoading();
    final repository = ref.read(coursesRepositoryProvider);
    final result = await AsyncValue.guard(
      () => repository.createCourse(subjectId: subjectId, input: input),
    );
    state = result.whenData((_) {});

    if (result.hasError) {
      Error.throwWithStackTrace(result.error!, result.stackTrace!);
    }

    final course = result.requireValue;
    ref.invalidate(coursesProvider(subjectId));
    ref.invalidate(courseDetailProvider(course.id));

    return course;
  }
}

class UpdateCourseController extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<CourseListItem> update({
    required CourseDetail detail,
    required UpdateCourseInput input,
  }) async {
    state = const AsyncLoading();
    final repository = ref.read(coursesRepositoryProvider);
    final result = await AsyncValue.guard(
      () => repository.updateCourse(courseId: detail.course.id, input: input),
    );
    state = result.whenData((_) {});

    if (result.hasError) {
      Error.throwWithStackTrace(result.error!, result.stackTrace!);
    }

    final course = result.requireValue;
    _invalidateCourseSurfaces(
      ref,
      courseId: course.id,
      subjectId: course.subjectId,
    );
    return course;
  }
}

class ArchiveCourseController extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<CourseLifecycleDecision> archive({
    required CourseDetail detail,
  }) async {
    state = const AsyncLoading();
    final repository = ref.read(coursesRepositoryProvider);
    final result = await AsyncValue.guard(
      () => repository.archiveCourse(courseId: detail.course.id),
    );
    state = result.whenData((_) {});

    if (result.hasError) {
      Error.throwWithStackTrace(result.error!, result.stackTrace!);
    }

    final decision = result.requireValue;
    _invalidateCourseSurfaces(
      ref,
      courseId: detail.course.id,
      subjectId: detail.course.subjectId,
    );
    return decision;
  }
}

class DeleteCourseController extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<void> delete({required CourseDetail detail}) async {
    state = const AsyncLoading();
    final repository = ref.read(coursesRepositoryProvider);
    final result = await AsyncValue.guard(
      () => repository.deleteCourse(courseId: detail.course.id),
    );
    state = result;

    if (result.hasError) {
      Error.throwWithStackTrace(result.error!, result.stackTrace!);
    }

    _invalidateCourseSurfaces(
      ref,
      courseId: detail.course.id,
      subjectId: detail.course.subjectId,
    );
  }
}

class UploadCourseDocumentController
    extends Notifier<AsyncValue<CourseDocument?>> {
  @override
  AsyncValue<CourseDocument?> build() => const AsyncData(null);

  Future<CourseDocument?> upload({required CourseDetail detail}) async {
    final picked = await ref.read(coursePdfPickerProvider).pickPdf();

    if (picked == null) {
      state = const AsyncData(null);
      return null;
    }

    state = const AsyncLoading();
    final repository = ref.read(coursesRepositoryProvider);
    final result = await AsyncValue.guard(
      () => repository.uploadCoursePdf(
        courseId: detail.course.id,
        fileName: picked.fileName,
        bytes: picked.bytes,
      ),
    );

    state = result.whenData<CourseDocument?>((document) => document);

    if (result.hasError) {
      Error.throwWithStackTrace(result.error!, result.stackTrace!);
    }

    final uploaded = result.requireValue;
    ref.invalidate(courseDetailProvider(detail.course.id));
    ref.invalidate(courseProgressProvider(detail.course.id));
    ref.invalidate(courseRichRevisionOptionsProvider(detail.course.id));
    ref.invalidate(coursesProvider(detail.course.subjectId));
    ref.invalidate(subjectProgressProvider(detail.course.subjectId));

    return uploaded;
  }
}

void _invalidateCourseSurfaces(
  Ref ref, {
  required String courseId,
  required String subjectId,
}) {
  ref.invalidate(courseDetailProvider(courseId));
  ref.invalidate(courseLifecycleProvider(courseId));
  ref.invalidate(courseProgressProvider(courseId));
  ref.invalidate(courseRevisionSessionHistoryProvider(courseId));
  ref.invalidate(courseRichRevisionOptionsProvider(courseId));
  ref.invalidate(courseRichClosedHistoryProvider(courseId));
  ref.invalidate(coursesProvider(subjectId));
  ref.invalidate(subjectProgressProvider(subjectId));
}

class DeleteCourseDocumentController extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<void> delete({
    required CourseDetail detail,
    required String documentId,
  }) async {
    state = const AsyncLoading();
    final repository = ref.read(coursesRepositoryProvider);
    final result = await AsyncValue.guard(
      () => repository.deleteCourseDocument(
        courseId: detail.course.id,
        documentId: documentId,
      ),
    );

    state = result;

    if (result.hasError) {
      Error.throwWithStackTrace(result.error!, result.stackTrace!);
    }

    ref.invalidate(courseDetailProvider(detail.course.id));
    ref.invalidate(courseProgressProvider(detail.course.id));
    ref.invalidate(coursesProvider(detail.course.subjectId));
    ref.invalidate(subjectProgressProvider(detail.course.subjectId));
  }
}

class ArchiveCourseDocumentController extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<void> archive({
    required CourseDetail detail,
    required String documentId,
  }) async {
    state = const AsyncLoading();
    final repository = ref.read(coursesRepositoryProvider);
    final result = await AsyncValue.guard(
      () => repository.archiveCourseDocument(
        courseId: detail.course.id,
        documentId: documentId,
      ),
    );

    state = result.whenData((_) {});

    if (result.hasError) {
      Error.throwWithStackTrace(result.error!, result.stackTrace!);
    }

    ref.invalidate(courseDetailProvider(detail.course.id));
    ref.invalidate(courseProgressProvider(detail.course.id));
    ref.invalidate(coursesProvider(detail.course.subjectId));
    ref.invalidate(subjectProgressProvider(detail.course.subjectId));
  }
}

class GenerateCourseRevisionSheetController
    extends Notifier<AsyncValue<RevisionSheet?>> {
  @override
  AsyncValue<RevisionSheet?> build() => const AsyncData(null);

  Future<RevisionSheet> generate({required String courseId}) async {
    state = const AsyncLoading();
    final repository = ref.read(coursesRepositoryProvider);
    final result = await AsyncValue.guard(
      () => repository.generateCourseRevisionSheet(courseId: courseId),
    );

    state = result.whenData<RevisionSheet?>((sheet) => sheet);

    if (result.hasError) {
      Error.throwWithStackTrace(result.error!, result.stackTrace!);
    }

    final sheet = result.requireValue;
    ref.invalidate(courseRevisionSheetProvider(courseId));

    return sheet;
  }
}

class PrepareQuestionBankController
    extends Notifier<AsyncValue<CourseQuestionBankReadiness?>> {
  @override
  AsyncValue<CourseQuestionBankReadiness?> build() => const AsyncData(null);

  Future<CourseQuestionBankReadiness> prepare({
    required String courseId,
    int questionCount = 10,
  }) async {
    state = const AsyncLoading();
    final repository = ref.read(coursesRepositoryProvider);
    final result = await AsyncValue.guard(
      () => repository.prepareQuestionBank(
        courseId: courseId,
        questionCount: questionCount,
      ),
    );

    state = result.whenData<CourseQuestionBankReadiness?>(
      (readiness) => readiness,
    );

    ref.invalidate(
      courseQuestionBankReadinessProvider((
        courseId: courseId,
        questionCount: questionCount,
      )),
    );

    if (result.hasError) {
      Error.throwWithStackTrace(result.error!, result.stackTrace!);
    }

    return result.requireValue;
  }
}

class StartCourseQuickRevisionController
    extends Notifier<AsyncValue<RevisionSessionResponse?>> {
  @override
  AsyncValue<RevisionSessionResponse?> build() => const AsyncData(null);

  Future<RevisionSessionResponse> start({
    CourseDetail? detail,
    String? courseId,
    int questionCount = 10,
  }) async {
    final resolvedCourseId = courseId ?? detail?.course.id;
    if (resolvedCourseId == null) {
      throw ArgumentError('A course id is required to start quick revision');
    }

    state = const AsyncLoading();
    final repository = ref.read(coursesRepositoryProvider);
    final result = await AsyncValue.guard(
      () => repository.startCourseQuickRevision(
        courseId: resolvedCourseId,
        questionCount: questionCount,
      ),
    );

    state = result.whenData<RevisionSessionResponse?>((response) => response);
    ref.invalidate(resumableCourseRevisionSessionProvider(resolvedCourseId));
    ref.invalidate(
      courseQuestionBankReadinessProvider((
        courseId: resolvedCourseId,
        questionCount: questionCount,
      )),
    );

    if (result.hasError) {
      Error.throwWithStackTrace(result.error!, result.stackTrace!);
    }

    return result.requireValue;
  }
}

class StartCourseRichRevisionController
    extends Notifier<AsyncValue<RichClosedExercise?>> {
  @override
  AsyncValue<RichClosedExercise?> build() => const AsyncData(null);

  Future<RichClosedExercise> start({
    required String courseId,
    required CourseRichRevisionConfig config,
  }) async {
    if (state.isLoading) {
      throw StateError('QCM complet en cours de préparation');
    }

    state = const AsyncLoading();
    final repository = ref.read(coursesRepositoryProvider);
    final result = await AsyncValue.guard(
      () => repository.startCourseRichRevision(
        courseId: courseId,
        config: config,
      ),
    );
    state = result.whenData<RichClosedExercise?>((exercise) => exercise);

    if (result.hasError) {
      Error.throwWithStackTrace(result.error!, result.stackTrace!);
    }

    final exercise = result.requireValue;
    ref.invalidate(courseRichRevisionOptionsProvider(courseId));
    ref.invalidate(courseRichClosedHistoryProvider(courseId));

    return exercise;
  }
}
