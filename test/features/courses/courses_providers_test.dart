import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:revision_app/features/courses/application/course_pdf_picker.dart';
import 'package:revision_app/features/courses/application/courses_providers.dart';
import 'package:revision_app/features/courses/domain/course_models.dart';
import 'package:revision_app/features/courses/domain/courses_repository.dart';

import '../../fakes/in_memory_courses_repository.dart';

void main() {
  test('coursesProvider loads real courses for a subject', () async {
    final repository = InMemoryCoursesRepository()
      ..coursesBySubject['subject-1'] = const [
        CourseListItem(
          id: 'course-1',
          subjectId: 'subject-1',
          title: 'Droit constitutionnel',
          sourceCount: 0,
          readySourceCount: 0,
          processingSourceCount: 0,
          failedSourceCount: 0,
        ),
      ];
    final container = ProviderContainer(
      overrides: [coursesRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);

    final courses = await container.read(coursesProvider('subject-1').future);

    expect(courses.single.title, 'Droit constitutionnel');
  });

  test('createCourseController invalidates the subject course list', () async {
    final repository = InMemoryCoursesRepository();
    final container = ProviderContainer(
      overrides: [coursesRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);

    expect(await container.read(coursesProvider('subject-1').future), isEmpty);

    final created = await container
        .read(createCourseControllerProvider.notifier)
        .create(
          subjectId: 'subject-1',
          input: const CreateCourseInput(title: 'Droit constitutionnel'),
        );

    expect(created.title, 'Droit constitutionnel');
    expect(
      await container.read(coursesProvider('subject-1').future),
      hasLength(1),
    );
  });

  test('course detail repository exposes typed not-found errors', () async {
    final repository = InMemoryCoursesRepository();

    await expectLater(
      repository.getCourse(courseId: 'unknown'),
      throwsA(isA<CourseNotFoundException>()),
    );
  });

  test(
    'uploadCourseDocumentController does nothing when picking is cancelled',
    () async {
      final repository = InMemoryCoursesRepository();
      final picker = FakeCoursePdfPicker(null);
      final container = ProviderContainer(
        overrides: [
          coursesRepositoryProvider.overrideWithValue(repository),
          coursePdfPickerProvider.overrideWithValue(picker),
        ],
      );
      addTearDown(container.dispose);

      final result = await container
          .read(uploadCourseDocumentControllerProvider.notifier)
          .upload(detail: courseDetail());

      expect(result, isNull);
      expect(picker.pickCount, 1);
      expect(repository.uploadCount, 0);
      expect(
        container.read(uploadCourseDocumentControllerProvider).hasError,
        false,
      );
    },
  );

  test(
    'uploadCourseDocumentController uploads and invalidates course detail',
    () async {
      final repository = InMemoryCoursesRepository()
        ..detailsByCourse['course-1'] = courseDetail();
      final picker = FakeCoursePdfPicker(
        PickedCoursePdf(
          fileName: 'cours.pdf',
          bytes: Uint8List.fromList('%PDF-1.7'.codeUnits),
        ),
      );
      final container = ProviderContainer(
        overrides: [
          coursesRepositoryProvider.overrideWithValue(repository),
          coursePdfPickerProvider.overrideWithValue(picker),
        ],
      );
      addTearDown(container.dispose);

      expect(
        (await container.read(courseDetailProvider('course-1').future)).sources,
        isEmpty,
      );

      final uploaded = await container
          .read(uploadCourseDocumentControllerProvider.notifier)
          .upload(detail: courseDetail());

      expect(uploaded?.fileName, 'cours.pdf');
      expect(repository.uploadCount, 1);
      expect(repository.lastUploadedCourseId, 'course-1');
      expect(
        (await container.read(courseDetailProvider('course-1').future)).sources,
        hasLength(1),
      );
    },
  );

  test('uploadCourseDocumentController exposes upload errors', () async {
    final repository = InMemoryCoursesRepository()
      ..uploadError = const CourseUploadException('Invalid PDF');
    final picker = FakeCoursePdfPicker(
      PickedCoursePdf(fileName: 'cours.pdf', bytes: Uint8List.fromList([1])),
    );
    final container = ProviderContainer(
      overrides: [
        coursesRepositoryProvider.overrideWithValue(repository),
        coursePdfPickerProvider.overrideWithValue(picker),
      ],
    );
    addTearDown(container.dispose);

    await expectLater(
      container
          .read(uploadCourseDocumentControllerProvider.notifier)
          .upload(detail: courseDetail()),
      throwsA(isA<CourseUploadException>()),
    );

    expect(
      container.read(uploadCourseDocumentControllerProvider).hasError,
      true,
    );
  });
}

CourseDetail courseDetail() {
  const course = CourseListItem(
    id: 'course-1',
    subjectId: 'subject-1',
    title: 'Droit constitutionnel',
  );
  return const CourseDetail(
    course: course,
    subject: CourseSubjectSummary(id: 'subject-1', name: 'Droit'),
    sources: [],
  );
}

class FakeCoursePdfPicker implements CoursePdfPicker {
  FakeCoursePdfPicker(this.result);

  final PickedCoursePdf? result;
  int pickCount = 0;

  @override
  Future<PickedCoursePdf?> pickPdf() async {
    pickCount += 1;
    return result;
  }
}
