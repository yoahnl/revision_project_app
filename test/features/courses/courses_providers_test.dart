import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:Neralune/features/courses/application/course_pdf_picker.dart';
import 'package:Neralune/features/courses/application/courses_providers.dart';
import 'package:Neralune/features/courses/domain/course_models.dart';
import 'package:Neralune/features/courses/domain/courses_repository.dart';
import 'package:Neralune/features/documents/domain/revision_document.dart';
import 'package:Neralune/features/documents/domain/source_lifecycle.dart';

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
      final repository = InMemoryCoursesRepository()
        ..progressByCourse['course-1'] = courseProgress()
        ..progressBySubject['subject-1'] = subjectProgress();
      final picker = FakeCoursePdfPicker(null);
      final container = ProviderContainer(
        overrides: [
          coursesRepositoryProvider.overrideWithValue(repository),
          coursePdfPickerProvider.overrideWithValue(picker),
        ],
      );
      addTearDown(container.dispose);

      await container.read(courseProgressProvider('course-1').future);
      await container.read(subjectProgressProvider('subject-1').future);
      final initialCourseProgressReads = repository.getCourseProgressCount;
      final initialSubjectProgressReads = repository.getSubjectProgressCount;

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
      await container.read(courseProgressProvider('course-1').future);
      await container.read(subjectProgressProvider('subject-1').future);
      expect(repository.getCourseProgressCount, initialCourseProgressReads);
      expect(repository.getSubjectProgressCount, initialSubjectProgressReads);
    },
  );

  test(
    'uploadCourseDocumentController uploads and invalidates detail lists and progress',
    () async {
      final repository = InMemoryCoursesRepository()
        ..coursesBySubject['subject-1'] = const [
          CourseListItem(
            id: 'course-1',
            subjectId: 'subject-1',
            title: 'Droit constitutionnel',
          ),
        ]
        ..detailsByCourse['course-1'] = courseDetail()
        ..progressByCourse['course-1'] = courseProgress()
        ..progressBySubject['subject-1'] = subjectProgress();
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
      await container.read(coursesProvider('subject-1').future);
      await container.read(courseProgressProvider('course-1').future);
      await container.read(subjectProgressProvider('subject-1').future);

      final initialDetailReads = repository.getCourseCount;
      final initialListReads = repository.listCoursesCount;
      final initialCourseProgressReads = repository.getCourseProgressCount;
      final initialSubjectProgressReads = repository.getSubjectProgressCount;

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
      await container.read(coursesProvider('subject-1').future);
      await container.read(courseProgressProvider('course-1').future);
      await container.read(subjectProgressProvider('subject-1').future);

      expect(repository.getCourseCount, greaterThan(initialDetailReads));
      expect(repository.listCoursesCount, greaterThan(initialListReads));
      expect(
        repository.getCourseProgressCount,
        greaterThan(initialCourseProgressReads),
      );
      expect(
        repository.getSubjectProgressCount,
        greaterThan(initialSubjectProgressReads),
      );
    },
  );

  test('uploadCourseDocumentController exposes upload errors', () async {
    final repository = InMemoryCoursesRepository()
      ..progressByCourse['course-1'] = courseProgress()
      ..progressBySubject['subject-1'] = subjectProgress()
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

    await container.read(courseProgressProvider('course-1').future);
    await container.read(subjectProgressProvider('subject-1').future);
    final initialCourseProgressReads = repository.getCourseProgressCount;
    final initialSubjectProgressReads = repository.getSubjectProgressCount;

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
    await container.read(courseProgressProvider('course-1').future);
    await container.read(subjectProgressProvider('subject-1').future);
    expect(repository.getCourseProgressCount, initialCourseProgressReads);
    expect(repository.getSubjectProgressCount, initialSubjectProgressReads);
  });

  test(
    'deleteCourseDocumentController removes a source and refreshes course surfaces',
    () async {
      final repository = InMemoryCoursesRepository()
        ..coursesBySubject['subject-1'] = const [
          CourseListItem(
            id: 'course-1',
            subjectId: 'subject-1',
            title: 'Droit constitutionnel',
          ),
        ]
        ..detailsByCourse['course-1'] = courseDetail(
          sources: const [
            CourseDocument(
              id: 'document-1',
              courseId: 'course-1',
              documentId: 'document-1',
              fileName: 'cours.pdf',
              status: CourseDocumentStatus.ready,
            ),
          ],
        )
        ..progressByCourse['course-1'] = courseProgress()
        ..progressBySubject['subject-1'] = subjectProgress();
      final container = ProviderContainer(
        overrides: [coursesRepositoryProvider.overrideWithValue(repository)],
      );
      addTearDown(container.dispose);

      expect(
        (await container.read(courseDetailProvider('course-1').future)).sources,
        hasLength(1),
      );
      await container.read(coursesProvider('subject-1').future);
      await container.read(courseProgressProvider('course-1').future);
      await container.read(subjectProgressProvider('subject-1').future);

      final initialDetailReads = repository.getCourseCount;
      final initialListReads = repository.listCoursesCount;
      final initialCourseProgressReads = repository.getCourseProgressCount;
      final initialSubjectProgressReads = repository.getSubjectProgressCount;

      await container
          .read(deleteCourseDocumentControllerProvider.notifier)
          .delete(
            detail: repository.detailsByCourse['course-1']!,
            documentId: 'document-1',
          );

      expect(repository.deleteDocumentCount, 1);
      expect(repository.lastDeletedCourseId, 'course-1');
      expect(repository.lastDeletedDocumentId, 'document-1');
      expect(
        (await container.read(courseDetailProvider('course-1').future)).sources,
        isEmpty,
      );
      await container.read(coursesProvider('subject-1').future);
      await container.read(courseProgressProvider('course-1').future);
      await container.read(subjectProgressProvider('subject-1').future);

      expect(repository.getCourseCount, greaterThan(initialDetailReads));
      expect(repository.listCoursesCount, greaterThan(initialListReads));
      expect(
        repository.getCourseProgressCount,
        greaterThan(initialCourseProgressReads),
      );
      expect(
        repository.getSubjectProgressCount,
        greaterThan(initialSubjectProgressReads),
      );
    },
  );

  test(
    'deleteCourseDocumentController exposes errors without refreshing',
    () async {
      final repository = InMemoryCoursesRepository()
        ..coursesBySubject['subject-1'] = const [
          CourseListItem(
            id: 'course-1',
            subjectId: 'subject-1',
            title: 'Droit constitutionnel',
          ),
        ]
        ..detailsByCourse['course-1'] = courseDetail(
          sources: const [
            CourseDocument(
              id: 'document-1',
              courseId: 'course-1',
              documentId: 'document-1',
              fileName: 'cours.pdf',
              status: CourseDocumentStatus.ready,
            ),
          ],
        )
        ..progressByCourse['course-1'] = courseProgress()
        ..progressBySubject['subject-1'] = subjectProgress()
        ..deleteDocumentError = const CourseNotFoundException(
          'Course source not found',
        );
      final container = ProviderContainer(
        overrides: [coursesRepositoryProvider.overrideWithValue(repository)],
      );
      addTearDown(container.dispose);

      await container.read(courseDetailProvider('course-1').future);
      await container.read(coursesProvider('subject-1').future);
      await container.read(courseProgressProvider('course-1').future);
      await container.read(subjectProgressProvider('subject-1').future);

      final initialDetailReads = repository.getCourseCount;
      final initialListReads = repository.listCoursesCount;
      final initialCourseProgressReads = repository.getCourseProgressCount;
      final initialSubjectProgressReads = repository.getSubjectProgressCount;

      await expectLater(
        container
            .read(deleteCourseDocumentControllerProvider.notifier)
            .delete(
              detail: repository.detailsByCourse['course-1']!,
              documentId: 'document-1',
            ),
        throwsA(isA<CourseNotFoundException>()),
      );

      expect(
        container.read(deleteCourseDocumentControllerProvider).hasError,
        true,
      );
      await container.read(courseDetailProvider('course-1').future);
      await container.read(coursesProvider('subject-1').future);
      await container.read(courseProgressProvider('course-1').future);
      await container.read(subjectProgressProvider('subject-1').future);
      expect(repository.getCourseCount, initialDetailReads);
      expect(repository.listCoursesCount, initialListReads);
      expect(repository.getCourseProgressCount, initialCourseProgressReads);
      expect(repository.getSubjectProgressCount, initialSubjectProgressReads);
    },
  );

  test(
    'archiveCourseDocumentController archives a source and refreshes course surfaces',
    () async {
      final repository = InMemoryCoursesRepository()
        ..coursesBySubject['subject-1'] = const [
          CourseListItem(
            id: 'course-1',
            subjectId: 'subject-1',
            title: 'Droit constitutionnel',
          ),
        ]
        ..detailsByCourse['course-1'] = courseDetail(
          sources: const [
            CourseDocument(
              id: 'document-1',
              courseId: 'course-1',
              documentId: 'document-1',
              fileName: 'cours.pdf',
              status: CourseDocumentStatus.ready,
            ),
          ],
        )
        ..progressByCourse['course-1'] = courseProgress()
        ..progressBySubject['subject-1'] = subjectProgress()
        ..lifecycleByDocumentId['document-1'] = const SourceLifecycleDecision(
          documentId: 'document-1',
          courseId: 'course-1',
          status: SourceLifecycleStatus.active,
          recommendedAction: SourceLifecycleAction.archive,
          canDelete: false,
          canArchive: true,
          blockingReasons: ['HAS_KNOWLEDGE_UNITS'],
          userMessage: 'Cette source peut être archivée.',
        );
      final container = ProviderContainer(
        overrides: [coursesRepositoryProvider.overrideWithValue(repository)],
      );
      addTearDown(container.dispose);

      await container.read(courseDetailProvider('course-1').future);
      await container.read(coursesProvider('subject-1').future);
      await container.read(courseProgressProvider('course-1').future);
      await container.read(subjectProgressProvider('subject-1').future);

      final initialDetailReads = repository.getCourseCount;
      final initialListReads = repository.listCoursesCount;
      final initialCourseProgressReads = repository.getCourseProgressCount;
      final initialSubjectProgressReads = repository.getSubjectProgressCount;

      await container
          .read(archiveCourseDocumentControllerProvider.notifier)
          .archive(
            detail: repository.detailsByCourse['course-1']!,
            documentId: 'document-1',
          );

      expect(repository.archiveDocumentCount, 1);
      expect(repository.lastArchivedCourseId, 'course-1');
      expect(repository.lastArchivedDocumentId, 'document-1');
      expect(
        (await container.read(courseDetailProvider('course-1').future)).sources,
        isEmpty,
      );
      await container.read(coursesProvider('subject-1').future);
      await container.read(courseProgressProvider('course-1').future);
      await container.read(subjectProgressProvider('subject-1').future);

      expect(repository.getCourseCount, greaterThan(initialDetailReads));
      expect(repository.listCoursesCount, greaterThan(initialListReads));
      expect(
        repository.getCourseProgressCount,
        greaterThan(initialCourseProgressReads),
      );
      expect(
        repository.getSubjectProgressCount,
        greaterThan(initialSubjectProgressReads),
      );
    },
  );

  test(
    'courseRevisionSheetProvider loads an existing course-level sheet',
    () async {
      final repository = InMemoryCoursesRepository()
        ..revisionSheetsByCourse['course-1'] = revisionSheet();
      final container = ProviderContainer(
        overrides: [coursesRepositoryProvider.overrideWithValue(repository)],
      );
      addTearDown(container.dispose);

      final sheet = await container.read(
        courseRevisionSheetProvider('course-1').future,
      );

      expect(sheet?.title, 'Fiche de cours');
      expect(repository.getRevisionSheetCount, 1);
    },
  );

  test('courseProgressProvider loads real course progress', () async {
    final repository = InMemoryCoursesRepository()
      ..progressByCourse['course-1'] = courseProgress();
    final container = ProviderContainer(
      overrides: [coursesRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);

    final progress = await container.read(
      courseProgressProvider('course-1').future,
    );

    expect(progress.state, CourseProgressState.practiced);
    expect(progress.estimatedGlobalMastery, 0.18);
    expect(repository.getCourseProgressCount, 1);
  });

  test('subjectProgressProvider loads real subject progress', () async {
    final repository = InMemoryCoursesRepository()
      ..progressBySubject['subject-1'] = subjectProgress();
    final container = ProviderContainer(
      overrides: [coursesRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);

    final progress = await container.read(
      subjectProgressProvider('subject-1').future,
    );

    expect(progress.courses.single.title, 'Droit constitutionnel');
    expect(progress.readyCourseCount, 1);
    expect(repository.getSubjectProgressCount, 1);
  });

  test(
    'generateCourseRevisionSheetController generates and invalidates',
    () async {
      final repository = InMemoryCoursesRepository()
        ..revisionSheetsByCourse['course-1'] = revisionSheet();
      final container = ProviderContainer(
        overrides: [coursesRepositoryProvider.overrideWithValue(repository)],
      );
      addTearDown(container.dispose);

      await container.read(courseRevisionSheetProvider('course-1').future);

      final sheet = await container
          .read(generateCourseRevisionSheetControllerProvider.notifier)
          .generate(courseId: 'course-1');

      expect(sheet.title, 'Fiche de cours');
      expect(repository.generateRevisionSheetCount, 1);
      expect(
        await container.read(courseRevisionSheetProvider('course-1').future),
        isNotNull,
      );
    },
  );

  test(
    'generateCourseRevisionSheetController exposes not-ready errors',
    () async {
      final repository = InMemoryCoursesRepository()
        ..revisionSheetErrorsByCourse['course-1'] =
            const CourseRevisionSheetNotReadyException(
              'Course has no ready source',
            );
      final container = ProviderContainer(
        overrides: [coursesRepositoryProvider.overrideWithValue(repository)],
      );
      addTearDown(container.dispose);

      await expectLater(
        container
            .read(generateCourseRevisionSheetControllerProvider.notifier)
            .generate(courseId: 'course-1'),
        throwsA(isA<CourseRevisionSheetNotReadyException>()),
      );

      expect(
        container.read(generateCourseRevisionSheetControllerProvider).hasError,
        true,
      );
    },
  );

  test(
    'startCourseQuickRevisionController starts a real course session',
    () async {
      final repository = InMemoryCoursesRepository()
        ..detailsByCourse['course-1'] = courseDetail();
      final container = ProviderContainer(
        overrides: [coursesRepositoryProvider.overrideWithValue(repository)],
      );
      addTearDown(container.dispose);

      final response = await container
          .read(startCourseQuickRevisionControllerProvider.notifier)
          .start(detail: courseDetail());

      expect(response.session.id, 'revision-session-1');
      expect(response.session.courseId, 'course-1');
      expect(repository.startQuickRevisionCount, 1);
      expect(repository.lastQuickRevisionCourseId, 'course-1');
      expect(
        container.read(startCourseQuickRevisionControllerProvider).hasError,
        false,
      );
    },
  );

  test(
    'prepareQuestionBankController prepares and refreshes readiness',
    () async {
      final repository = InMemoryCoursesRepository()
        ..detailsByCourse['course-1'] = courseDetail();
      final container = ProviderContainer(
        overrides: [coursesRepositoryProvider.overrideWithValue(repository)],
      );
      addTearDown(container.dispose);

      final readiness = await container
          .read(prepareQuestionBankControllerProvider.notifier)
          .prepare(courseId: 'course-1', questionCount: 5);

      expect(readiness.status, CourseQuestionBankReadinessStatus.preparing);
      expect(readiness.targetQuestionCount, 5);
      expect(repository.prepareQuestionBankCount, 1);
      expect(
        container.read(prepareQuestionBankControllerProvider).hasError,
        false,
      );
    },
  );

  test('startCourseQuickRevisionController exposes readiness errors', () async {
    final repository = InMemoryCoursesRepository()
      ..detailsByCourse['course-1'] = courseDetail()
      ..quickRevisionError = const CourseQuickRevisionUnavailableException(
        'Course has no ready knowledge unit',
      );
    final container = ProviderContainer(
      overrides: [coursesRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);

    await expectLater(
      container
          .read(startCourseQuickRevisionControllerProvider.notifier)
          .start(detail: courseDetail()),
      throwsA(isA<CourseQuickRevisionUnavailableException>()),
    );

    expect(
      container.read(startCourseQuickRevisionControllerProvider).hasError,
      true,
    );
  });
}

CourseDetail courseDetail({List<CourseDocument> sources = const []}) {
  const course = CourseListItem(
    id: 'course-1',
    subjectId: 'subject-1',
    title: 'Droit constitutionnel',
  );
  return CourseDetail(
    course: course,
    subject: const CourseSubjectSummary(id: 'subject-1', name: 'Droit'),
    sources: sources,
  );
}

RevisionSheet revisionSheet() {
  return const RevisionSheet(
    id: 'sheet-1',
    documentId: 'document-1',
    subjectId: 'subject-1',
    status: 'READY',
    title: 'Fiche de cours',
    introduction: 'Introduction',
    sections: [
      RevisionSheetSection(
        id: 'section-1',
        displayOrder: 0,
        title: 'Institutions',
        content: 'Le Parlement contrôle le Gouvernement.',
        sources: [],
      ),
    ],
    keyPoints: ['Point clé'],
    commonMistakes: ['Erreur fréquente'],
    mustKnow: ['À savoir'],
    practiceSuggestions: ['S’entraîner'],
    errorCode: null,
  );
}

CourseProgress courseProgress() {
  return CourseProgress(
    courseId: 'course-1',
    subjectId: 'subject-1',
    knowledgeUnitCount: 12,
    practicedKnowledgeUnitCount: 3,
    coverage: 0.25,
    mastery: 0.72,
    estimatedGlobalMastery: 0.18,
    readySourceCount: 1,
    processingSourceCount: 0,
    failedSourceCount: 0,
    lastPracticedAt: DateTime.utc(2026, 6, 18, 12),
    state: CourseProgressState.practiced,
  );
}

SubjectProgress subjectProgress() {
  return SubjectProgress(
    subjectId: 'subject-1',
    knowledgeUnitCount: 12,
    practicedKnowledgeUnitCount: 3,
    coverage: 0.25,
    mastery: 0.72,
    estimatedGlobalMastery: 0.18,
    courseCount: 1,
    readyCourseCount: 1,
    lastPracticedAt: DateTime.utc(2026, 6, 18, 12),
    courses: const [
      SubjectCourseProgressItem(
        courseId: 'course-1',
        title: 'Droit constitutionnel',
        knowledgeUnitCount: 12,
        practicedKnowledgeUnitCount: 3,
        coverage: 0.25,
        mastery: 0.72,
        estimatedGlobalMastery: 0.18,
        state: CourseProgressState.practiced,
      ),
    ],
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
