import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:Neralune/features/courses/data/http_courses_repository.dart';
import 'package:Neralune/features/courses/domain/course_models.dart';
import 'package:Neralune/features/courses/domain/courses_repository.dart';
import 'package:Neralune/features/documents/domain/source_lifecycle.dart';
import 'package:Neralune/features/revision_sessions/domain/revision_session.dart';

import '../activities/fixtures/rich_closed_exercise_fixtures.dart';

class CapturingHttpClientAdapter implements HttpClientAdapter {
  CapturingHttpClientAdapter(this.response);

  ResponseBody response;
  int fetchCallCount = 0;
  RequestOptions? lastOptions;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    fetchCallCount += 1;
    lastOptions = options;
    return response;
  }
}

void main() {
  test('lists real courses with source counts and bearer token', () async {
    final adapter = CapturingHttpClientAdapter(jsonResponse([courseJson()]));
    final repository = HttpCoursesRepository(
      dio: Dio()..httpClientAdapter = adapter,
      getIdToken: () async => 'firebase-id-token',
    );

    final courses = await repository.listCourses(subjectId: 'subject-1');

    expect(courses.single.title, 'Droit constitutionnel');
    expect(courses.single.estimatedMinutes, 30);
    expect(courses.single.sourceCount, 2);
    expect(courses.single.readySourceCount, 1);
    expect(adapter.lastOptions?.path, '/subjects/subject-1/courses');
    expect(
      adapter.lastOptions?.headers['Authorization'],
      'Bearer firebase-id-token',
    );
  });

  test('creates a real course with the CORE-02 payload', () async {
    final adapter = CapturingHttpClientAdapter(jsonResponse(courseJson()));
    final repository = HttpCoursesRepository(
      dio: Dio()..httpClientAdapter = adapter,
      getIdToken: () async => 'firebase-id-token',
    );

    final course = await repository.createCourse(
      subjectId: 'subject-1',
      input: const CreateCourseInput(
        title: 'Droit constitutionnel',
        description: 'Institutions',
        chapterLabel: 'Chapitre 1',
        estimatedMinutes: 30,
      ),
    );

    expect(course.id, 'course-1');
    expect(adapter.lastOptions?.method, 'POST');
    expect(adapter.lastOptions?.path, '/subjects/subject-1/courses');
    expect(adapter.lastOptions?.data, {
      'title': 'Droit constitutionnel',
      'description': 'Institutions',
      'chapterLabel': 'Chapitre 1',
      'estimatedMinutes': 30,
    });
  });

  test('updates a course through the PATCH endpoint', () async {
    final adapter = CapturingHttpClientAdapter(
      jsonResponse(
        courseJson(
          title: 'Droit public',
          sourceCount: 4,
          readySourceCount: 2,
          processingSourceCount: 1,
          failedSourceCount: 1,
        ),
      ),
    );
    final repository = HttpCoursesRepository(
      dio: Dio()..httpClientAdapter = adapter,
      getIdToken: () async => 'firebase-id-token',
    );

    final course = await repository.updateCourse(
      courseId: 'course id/1',
      input: const UpdateCourseInput(title: 'Droit public'),
    );

    expect(course.title, 'Droit public');
    expect(course.sourceCount, 4);
    expect(course.readySourceCount, 2);
    expect(course.processingSourceCount, 1);
    expect(course.failedSourceCount, 1);
    expect(adapter.lastOptions?.method, 'PATCH');
    expect(adapter.lastOptions?.path, '/courses/course%20id%2F1');
    expect(adapter.lastOptions?.data, {'title': 'Droit public'});
  });

  test('loads a course lifecycle decision', () async {
    final adapter = CapturingHttpClientAdapter(
      jsonResponse(courseLifecycleJson(recommendedAction: 'ARCHIVE')),
    );
    final repository = HttpCoursesRepository(
      dio: Dio()..httpClientAdapter = adapter,
      getIdToken: () async => 'firebase-id-token',
    );

    final decision = await repository.getCourseLifecycle(courseId: 'course-1');

    expect(decision.recommendedAction, LifecycleRecommendedAction.archive);
    expect(adapter.lastOptions?.path, '/courses/course-1/lifecycle');
  });

  test('archives a course through the archive endpoint', () async {
    final adapter = CapturingHttpClientAdapter(
      jsonResponse(courseLifecycleJson(status: 'ARCHIVED')),
    );
    final repository = HttpCoursesRepository(
      dio: Dio()..httpClientAdapter = adapter,
      getIdToken: () async => 'firebase-id-token',
    );

    final decision = await repository.archiveCourse(courseId: 'course-1');

    expect(decision.status, LifecycleStatus.archived);
    expect(adapter.lastOptions?.method, 'POST');
    expect(adapter.lastOptions?.path, '/courses/course-1/archive');
  });

  test(
    'maps blocked course deletion without exposing the technical code',
    () async {
      final adapter = CapturingHttpClientAdapter(
        jsonResponse({
          'code': 'COURSE_DELETE_BLOCKED',
          'message':
              'Ce cours contient déjà des sources ou des révisions. Archive-le plutôt que le supprimer.',
        }, statusCode: 409),
      );
      final repository = HttpCoursesRepository(
        dio: Dio()..httpClientAdapter = adapter,
        getIdToken: () async => 'firebase-id-token',
      );

      await expectLater(
        repository.deleteCourse(courseId: 'course-1'),
        throwsA(
          isA<CourseLifecycleBlockedException>().having(
            (error) => error.message,
            'message',
            isNot(contains('COURSE_DELETE_BLOCKED')),
          ),
        ),
      );
    },
  );

  test('loads course detail with subject and sources', () async {
    final adapter = CapturingHttpClientAdapter(
      jsonResponse({
        'course': courseJson(sourceCount: 1, readySourceCount: 1),
        'subject': {'id': 'subject-1', 'name': 'Droit'},
        'sources': [sourceJson()],
      }),
    );
    final repository = HttpCoursesRepository(
      dio: Dio()..httpClientAdapter = adapter,
      getIdToken: () async => 'firebase-id-token',
    );

    final detail = await repository.getCourse(courseId: 'course-1');

    expect(detail.subject.name, 'Droit');
    expect(detail.sources.single.status, CourseDocumentStatus.ready);
    expect(detail.sources.single.errorCode, isNull);
    expect(adapter.lastOptions?.path, '/courses/course-1');
  });

  test('maps backend 404 to CourseNotFoundException', () async {
    final adapter = CapturingHttpClientAdapter(
      jsonResponse({'message': 'Course not found'}, statusCode: 404),
    );
    final repository = HttpCoursesRepository(
      dio: Dio()..httpClientAdapter = adapter,
      getIdToken: () async => 'firebase-id-token',
    );

    await expectLater(
      repository.getCourse(courseId: 'unknown'),
      throwsA(isA<CourseNotFoundException>()),
    );
  });

  test('uploads a course PDF as multipart without subjectId', () async {
    final adapter = CapturingHttpClientAdapter(
      jsonResponse(sourceJsonWith(status: 'UPLOADED')),
    );
    final repository = HttpCoursesRepository(
      dio: Dio()..httpClientAdapter = adapter,
      getIdToken: () async => 'firebase-id-token',
    );

    final source = await repository.uploadCoursePdf(
      courseId: 'course-1',
      fileName: 'cours.pdf',
      bytes: Uint8List.fromList('%PDF-1.7'.codeUnits),
    );

    expect(source.status, CourseDocumentStatus.uploaded);
    expect(adapter.lastOptions?.method, 'POST');
    expect(adapter.lastOptions?.path, '/courses/course-1/source/course-pdf');
    expect(
      adapter.lastOptions?.headers['Authorization'],
      'Bearer firebase-id-token',
    );

    final formData = adapter.lastOptions?.data as FormData;
    expect(
      formData.fields.map((field) => field.key),
      isNot(contains('subjectId')),
    );
    expect(
      formData.fields.map((field) => field.key),
      isNot(contains('studentId')),
    );
    expect(formData.files.single.key, 'file');
    expect(formData.files.single.value.filename, 'cours.pdf');
  });

  test('maps upload 400 and 404 to typed course exceptions', () async {
    final badRequest = HttpCoursesRepository(
      dio: Dio()
        ..httpClientAdapter = CapturingHttpClientAdapter(
          jsonResponse({'message': 'Invalid file'}, statusCode: 400),
        ),
      getIdToken: () async => 'firebase-id-token',
    );

    await expectLater(
      badRequest.uploadCoursePdf(
        courseId: 'course-1',
        fileName: 'cours.txt',
        bytes: Uint8List.fromList([1, 2, 3]),
      ),
      throwsA(isA<CourseUploadException>()),
    );

    final notFound = HttpCoursesRepository(
      dio: Dio()
        ..httpClientAdapter = CapturingHttpClientAdapter(
          jsonResponse({'message': 'Course not found'}, statusCode: 404),
        ),
      getIdToken: () async => 'firebase-id-token',
    );

    await expectLater(
      notFound.uploadCoursePdf(
        courseId: 'missing',
        fileName: 'cours.pdf',
        bytes: Uint8List.fromList([1, 2, 3]),
      ),
      throwsA(isA<CourseNotFoundException>()),
    );
  });

  test(
    'deletes a course source through the encoded course-scoped endpoint',
    () async {
      final adapter = CapturingHttpClientAdapter(
        jsonResponse(null, statusCode: 204),
      );
      final repository = HttpCoursesRepository(
        dio: Dio()..httpClientAdapter = adapter,
        getIdToken: () async => 'firebase-id-token',
      );

      await repository.deleteCourseDocument(
        courseId: 'course id/1',
        documentId: 'document id/1',
      );

      expect(adapter.lastOptions?.method, 'DELETE');
      expect(
        adapter.lastOptions?.path,
        '/courses/course%20id%2F1/sources/document%20id%2F1',
      );
      expect(adapter.lastOptions?.data, isNull);
      expect(
        adapter.lastOptions?.headers['Authorization'],
        'Bearer firebase-id-token',
      );
    },
  );

  test('maps course source delete 404 to CourseNotFoundException', () async {
    final adapter = CapturingHttpClientAdapter(
      jsonResponse({'message': 'Course source not found'}, statusCode: 404),
    );
    final repository = HttpCoursesRepository(
      dio: Dio()..httpClientAdapter = adapter,
      getIdToken: () async => 'firebase-id-token',
    );

    await expectLater(
      repository.deleteCourseDocument(
        courseId: 'course-1',
        documentId: 'missing-document',
      ),
      throwsA(isA<CourseNotFoundException>()),
    );
  });

  test(
    'maps course source delete 409 to a readable request exception',
    () async {
      final adapter = CapturingHttpClientAdapter(
        jsonResponse({
          'message': 'Cette source peut être archivée.',
        }, statusCode: 409),
      );
      final repository = HttpCoursesRepository(
        dio: Dio()..httpClientAdapter = adapter,
        getIdToken: () async => 'firebase-id-token',
      );

      await expectLater(
        repository.deleteCourseDocument(
          courseId: 'course-1',
          documentId: 'document-1',
        ),
        throwsA(
          isA<CourseRequestException>().having(
            (error) => error.message,
            'message',
            'Cette source peut être archivée.',
          ),
        ),
      );
    },
  );

  test('loads course source lifecycle from the encoded endpoint', () async {
    final adapter = CapturingHttpClientAdapter(
      jsonResponse(sourceLifecycleJson()),
    );
    final repository = HttpCoursesRepository(
      dio: Dio()..httpClientAdapter = adapter,
      getIdToken: () async => 'firebase-id-token',
    );

    final decision = await repository.getCourseDocumentLifecycle(
      courseId: 'course id/1',
      documentId: 'document id/1',
    );

    expect(decision.recommendedAction, SourceLifecycleAction.archive);
    expect(decision.canArchive, true);
    expect(adapter.lastOptions?.method, 'GET');
    expect(
      adapter.lastOptions?.path,
      '/courses/course%20id%2F1/sources/document%20id%2F1/lifecycle',
    );
  });

  test('archives a course source through the encoded endpoint', () async {
    final adapter = CapturingHttpClientAdapter(
      jsonResponse(sourceLifecycleJson(status: 'ARCHIVED', action: 'BLOCK')),
    );
    final repository = HttpCoursesRepository(
      dio: Dio()..httpClientAdapter = adapter,
      getIdToken: () async => 'firebase-id-token',
    );

    final decision = await repository.archiveCourseDocument(
      courseId: 'course id/1',
      documentId: 'document id/1',
    );

    expect(decision.status, SourceLifecycleStatus.archived);
    expect(adapter.lastOptions?.method, 'POST');
    expect(
      adapter.lastOptions?.path,
      '/courses/course%20id%2F1/sources/document%20id%2F1/archive',
    );
  });

  test(
    'loads a course-level revision sheet from the course endpoint',
    () async {
      final adapter = CapturingHttpClientAdapter(
        jsonResponse(revisionSheetJson()),
      );
      final repository = HttpCoursesRepository(
        dio: Dio()..httpClientAdapter = adapter,
        getIdToken: () async => 'firebase-id-token',
      );

      final sheet = await repository.getCourseRevisionSheet(
        courseId: 'course-1',
      );

      expect(sheet?.title, 'Fiche de cours');
      expect(sheet?.sections.single.title, 'Institutions');
      expect(adapter.lastOptions?.method, 'GET');
      expect(adapter.lastOptions?.path, '/courses/course-1/revision-sheet');
    },
  );

  test(
    'generates a course-level revision sheet without documentId payload',
    () async {
      final adapter = CapturingHttpClientAdapter(
        jsonResponse(revisionSheetJson()),
      );
      final repository = HttpCoursesRepository(
        dio: Dio()..httpClientAdapter = adapter,
        getIdToken: () async => 'firebase-id-token',
      );

      final sheet = await repository.generateCourseRevisionSheet(
        courseId: 'course-1',
      );

      expect(sheet.title, 'Fiche de cours');
      expect(adapter.lastOptions?.method, 'POST');
      expect(adapter.lastOptions?.path, '/courses/course-1/revision-sheet');
      expect(adapter.lastOptions?.data, isNull);
    },
  );

  test(
    'maps course-level revision sheet 404 and 409 to typed outcomes',
    () async {
      final notFoundRepository = HttpCoursesRepository(
        dio: Dio()
          ..httpClientAdapter = CapturingHttpClientAdapter(
            jsonResponse({
              'message': 'Revision sheet not found',
            }, statusCode: 404),
          ),
        getIdToken: () async => 'firebase-id-token',
      );

      await expectLater(
        notFoundRepository.getCourseRevisionSheet(courseId: 'course-1'),
        completion(isNull),
      );

      final missingCourseRepository = HttpCoursesRepository(
        dio: Dio()
          ..httpClientAdapter = CapturingHttpClientAdapter(
            jsonResponse({'message': 'Course not found'}, statusCode: 404),
          ),
        getIdToken: () async => 'firebase-id-token',
      );

      await expectLater(
        missingCourseRepository.getCourseRevisionSheet(courseId: 'course-1'),
        throwsA(isA<CourseNotFoundException>()),
      );

      final notReadyRepository = HttpCoursesRepository(
        dio: Dio()
          ..httpClientAdapter = CapturingHttpClientAdapter(
            jsonResponse({
              'message': 'Course has no ready source',
            }, statusCode: 409),
          ),
        getIdToken: () async => 'firebase-id-token',
      );

      await expectLater(
        notReadyRepository.generateCourseRevisionSheet(courseId: 'course-1'),
        throwsA(isA<CourseRevisionSheetNotReadyException>()),
      );
    },
  );

  test(
    'starts a course quick revision with the selected question count',
    () async {
      final adapter = CapturingHttpClientAdapter(
        jsonResponse(revisionSessionJson(courseId: 'course-1')),
      );
      final repository = HttpCoursesRepository(
        dio: Dio()..httpClientAdapter = adapter,
        getIdToken: () async => 'firebase-id-token',
      );

      final response = await repository.startCourseQuickRevision(
        courseId: 'course-1',
        questionCount: 20,
      );

      expect(response.session.id, 'revision-session-1');
      expect(response.session.courseId, 'course-1');
      expect(response.currentAction?.kind.name, 'diagnosticQuiz');
      expect(adapter.lastOptions?.method, 'POST');
      expect(
        adapter.lastOptions?.path,
        '/courses/course-1/revision-sessions/quick',
      );
      expect(adapter.lastOptions?.data, {'questionCount': 20});
      expect(
        adapter.lastOptions?.headers['Authorization'],
        'Bearer firebase-id-token',
      );
    },
  );

  test('loads a resumable course quick revision session', () async {
    final adapter = CapturingHttpClientAdapter(
      jsonResponse(resumableRevisionSessionJson(courseId: 'course-1')),
    );
    final repository = HttpCoursesRepository(
      dio: Dio()..httpClientAdapter = adapter,
      getIdToken: () async => 'firebase-id-token',
    );

    final resumable = await repository.getResumableCourseRevisionSession(
      courseId: 'course-1',
    );

    expect(resumable?.session.id, 'revision-session-1');
    expect(resumable?.session.courseId, 'course-1');
    expect(resumable?.progress.answeredQuestionCount, 2);
    expect(resumable?.progress.totalQuestionCount, 5);
    expect(adapter.lastOptions?.method, 'GET');
    expect(
      adapter.lastOptions?.path,
      '/courses/course-1/revision-sessions/resumable',
    );
  });

  test('loads completed course revision session history', () async {
    final adapter = CapturingHttpClientAdapter(
      jsonResponse({
        'items': [
          revisionSessionHistoryItemJson(
            sessionId: 'revision-session-2',
            correctAnswers: 8,
            totalQuestions: 10,
            score: 0.8,
          ),
        ],
      }),
    );
    final repository = HttpCoursesRepository(
      dio: Dio()..httpClientAdapter = adapter,
      getIdToken: () async => 'firebase-id-token',
    );

    final history = await repository.getCourseRevisionSessionHistory(
      courseId: 'course-1',
      limit: 5,
    );

    expect(history.items, hasLength(1));
    expect(history.items.single.session.id, 'revision-session-2');
    expect(
      history.items.single.session.status,
      RevisionSessionStatus.completed,
    );
    expect(history.items.single.summary.correctAnswers, 8);
    expect(history.items.single.summary.totalQuestions, 10);
    expect(history.items.single.summary.score, 0.8);
    expect(history.items.single.course.title, 'Droit constitutionnel');
    expect(adapter.lastOptions?.method, 'GET');
    expect(
      adapter.lastOptions?.path,
      '/courses/course-1/revision-sessions/history',
    );
    expect(adapter.lastOptions?.queryParameters, {'limit': 5});
  });

  test('loads an empty completed course revision session history', () async {
    final adapter = CapturingHttpClientAdapter(jsonResponse({'items': []}));
    final repository = HttpCoursesRepository(
      dio: Dio()..httpClientAdapter = adapter,
      getIdToken: () async => 'firebase-id-token',
    );

    final history = await repository.getCourseRevisionSessionHistory(
      courseId: 'course-1',
    );

    expect(history.items, isEmpty);
  });

  test('loads completed course rich closed history', () async {
    final adapter = CapturingHttpClientAdapter(
      jsonResponse({
        'items': [
          richClosedHistoryItemJson(
            sessionId: 'rich-session-2',
            correctAnswers: 5,
            totalQuestions: 6,
            score: 0.833,
          ),
        ],
      }),
    );
    final repository = HttpCoursesRepository(
      dio: Dio()..httpClientAdapter = adapter,
      getIdToken: () async => 'firebase-id-token',
    );

    final history = await repository.getCourseRichClosedHistory(
      courseId: 'course-1',
      limit: 5,
    );

    expect(history.items, hasLength(1));
    expect(history.items.single.sessionId, 'rich-session-2');
    expect(history.items.single.type, 'rich_closed_exercise');
    expect(history.items.single.correctAnswers, 5);
    expect(history.items.single.totalQuestions, 6);
    expect(history.items.single.score, 0.833);
    expect(history.items.single.course.title, 'Droit constitutionnel');
    expect(history.items.single.knowledgeUnit.title, 'Séparation des pouvoirs');
    expect(
      history.items.single.resultPath,
      '/activities/rich-closed/rich-session-2/result',
    );
    expect(adapter.lastOptions?.method, 'GET');
    expect(adapter.lastOptions?.path, '/courses/course-1/rich-closed/history');
    expect(adapter.lastOptions?.queryParameters, {'limit': 5});
  });

  test('loads course QCM complet options without answer data', () async {
    final response = richRevisionOptionsJson();
    final adapter = CapturingHttpClientAdapter(jsonResponse(response));
    final repository = HttpCoursesRepository(
      dio: Dio()..httpClientAdapter = adapter,
      getIdToken: () async => 'firebase-id-token',
    );

    final options = await repository.getRichRevisionOptions(
      courseId: 'course-1',
    );

    expect(options.course.title, 'Droit constitutionnel');
    expect(options.readiness.state, CourseRichRevisionReadinessState.ready);
    expect(options.readiness.canStart, isTrue);
    expect(options.scopeOptions, hasLength(1));
    expect(
      options.scopeOptions.single.kind,
      CourseRichRevisionScopeKind.knowledgeUnit,
    );
    expect(options.scopeOptions.single.id, 'ku-1');
    expect(options.scopeOptions.single.documentId, 'document-1');
    expect(options.questionCountOptions, [6, 10, 13]);
    expect(options.questionCountOptions, isNot(contains(14)));
    expect(options.defaultQuestionCount, 6);
    expect(options.defaultConfig?.complexityProfile, 'standard');
    expect(options.complexityProfiles, ['standard', 'advanced']);
    expect(jsonEncode(response), isNot(contains('correctAnswer')));
    expect(adapter.lastOptions?.method, 'GET');
    expect(
      adapter.lastOptions?.path,
      '/courses/course-1/rich-revision/options',
    );
  });

  test('starts a course QCM complet session', () async {
    final adapter = CapturingHttpClientAdapter(
      jsonResponse(richClosedExerciseJson()),
    );
    final repository = HttpCoursesRepository(
      dio: Dio()..httpClientAdapter = adapter,
      getIdToken: () async => 'firebase-id-token',
    );

    final exercise = await repository.startCourseRichRevision(
      courseId: 'course-1',
      config: const CourseRichRevisionConfig(
        scopeKind: CourseRichRevisionScopeKind.knowledgeUnit,
        scopeId: 'ku-1',
        questionCount: 13,
        complexityProfile: 'advanced',
      ),
    );

    expect(exercise.sessionId, 'rich-session-1');
    expect(adapter.lastOptions?.method, 'POST');
    expect(
      adapter.lastOptions?.path,
      '/courses/course-1/rich-revision/sessions',
    );
    expect(adapter.lastOptions?.data, {
      'scopeKind': 'knowledge_unit',
      'scopeId': 'ku-1',
      'questionCount': 13,
      'complexityProfile': 'advanced',
    });
  });

  test('loads course exam preparation options without answer data', () async {
    final response = examPreparationOptionsJson();
    final adapter = CapturingHttpClientAdapter(jsonResponse(response));
    final repository = HttpCoursesRepository(
      dio: Dio()..httpClientAdapter = adapter,
      getIdToken: () async => 'firebase-id-token',
    );

    final options = await repository.getExamPreparationOptions(
      courseId: 'course-1',
    );

    expect(options.course.title, 'Droit constitutionnel');
    expect(options.readiness.state, CourseExamPreparationReadinessState.ready);
    expect(options.readiness.canPrepare, isTrue);
    expect(options.scopeOptions, hasLength(2));
    expect(
      options.scopeOptions.first.kind,
      CourseExamPreparationScopeKind.course,
    );
    expect(options.scopeOptions.first.canSelect, isTrue);
    expect(options.questionCountOptions, [10, 20]);
    expect(options.defaultQuestionCount, 20);
    expect(options.defaultConfig?.complexityProfile, 'exam');
    expect(options.supportedQuestionKinds, [
      'single_choice',
      'multiple_choice',
    ]);
    expect(jsonEncode(response), isNot(contains('correctAnswer')));
    expect(adapter.lastOptions?.method, 'GET');
    expect(
      adapter.lastOptions?.path,
      '/courses/course-1/exam-preparation/options',
    );
  });

  test('starts a course exam preparation session', () async {
    final adapter = CapturingHttpClientAdapter(
      jsonResponse(
        revisionSessionJson(
          courseId: 'course-1',
          sessionId: 'exam-session-1',
          mode: 'EXAM',
        ),
      ),
    );
    final repository = HttpCoursesRepository(
      dio: Dio()..httpClientAdapter = adapter,
      getIdToken: () async => 'firebase-id-token',
    );

    final response = await repository.startCourseExamPreparation(
      courseId: 'course-1',
      config: const CourseExamPreparationConfig(
        scopeKind: CourseExamPreparationScopeKind.source,
        scopeId: 'document-1',
        questionCount: 10,
        complexityProfile: 'exam',
      ),
    );

    expect(response.session.id, 'exam-session-1');
    expect(response.session.mode, RevisionSessionMode.exam);
    expect(adapter.lastOptions?.method, 'POST');
    expect(
      adapter.lastOptions?.path,
      '/courses/course-1/exam-preparation/sessions',
    );
    expect(adapter.lastOptions?.data, {
      'scopeKind': 'source',
      'scopeId': 'document-1',
      'questionCount': 10,
      'complexityProfile': 'exam',
    });
  });

  test('loads course deep revision options without correction data', () async {
    final response = deepRevisionOptionsJson();
    final adapter = CapturingHttpClientAdapter(jsonResponse(response));
    final repository = HttpCoursesRepository(
      dio: Dio()..httpClientAdapter = adapter,
      getIdToken: () async => 'firebase-id-token',
    );

    final options = await repository.getDeepRevisionOptions(
      courseId: 'course-1',
    );

    expect(options.course.title, 'Droit constitutionnel');
    expect(options.readiness.state, CourseDeepRevisionReadinessState.ready);
    expect(options.readiness.canStart, isTrue);
    expect(options.scopeOptions, hasLength(1));
    expect(
      options.scopeOptions.single.kind,
      CourseDeepRevisionScopeKind.knowledgeUnit,
    );
    expect(options.scopeOptions.single.id, 'ku-1');
    expect(options.scopeOptions.single.documentId, 'document-1');
    expect(options.answerGuidelines.minLength, 12);
    expect(options.answerGuidelines.maxLength, 4000);
    expect(options.defaultConfig?.scopeId, 'ku-1');
    expect(jsonEncode(response), isNot(contains('modelAnswer')));
    expect(jsonEncode(response), isNot(contains('evaluation')));
    expect(adapter.lastOptions?.method, 'GET');
    expect(
      adapter.lastOptions?.path,
      '/courses/course-1/deep-revision/options',
    );
  });

  test('starts a course deep revision question', () async {
    final adapter = CapturingHttpClientAdapter(
      jsonResponse(deepRevisionSessionJson()),
    );
    final repository = HttpCoursesRepository(
      dio: Dio()..httpClientAdapter = adapter,
      getIdToken: () async => 'firebase-id-token',
    );

    final response = await repository.startCourseDeepRevision(
      courseId: 'course-1',
      config: const CourseDeepRevisionConfig(
        scopeKind: CourseDeepRevisionScopeKind.knowledgeUnit,
        scopeId: 'ku-1',
      ),
    );

    expect(response.session.id, 'deep-session-1');
    expect(response.session.status, 'STARTED');
    expect(response.scope.label, 'Responsabilité politique');
    expect(response.question.prompt, contains('responsabilité politique'));
    expect(response.question.sources, hasLength(1));
    expect(adapter.lastOptions?.method, 'POST');
    expect(
      adapter.lastOptions?.path,
      '/courses/course-1/deep-revision/sessions',
    );
    expect(adapter.lastOptions?.data, {
      'scopeKind': 'knowledge_unit',
      'scopeId': 'ku-1',
    });
  });

  test('submits a course deep revision answer', () async {
    final adapter = CapturingHttpClientAdapter(
      jsonResponse(deepRevisionSubmitJson()),
    );
    final repository = HttpCoursesRepository(
      dio: Dio()..httpClientAdapter = adapter,
      getIdToken: () async => 'firebase-id-token',
    );

    final response = await repository.submitCourseDeepRevisionAnswer(
      courseId: 'course-1',
      sessionId: 'deep-session-1',
      answer:
          'La responsabilité politique permet au Parlement de contrôler le Gouvernement.',
    );

    expect(response.session.id, 'deep-session-1');
    expect(response.evaluation.score, 0.72);
    expect(response.evaluation.feedback, contains('Bonne structure'));
    expect(
      response.evaluation.presentPoints,
      contains('Contrôle parlementaire'),
    );
    expect(response.evaluation.modelAnswer, contains('réponse modèle'));
    expect(response.evaluation.sources, hasLength(1));
    expect(adapter.lastOptions?.method, 'POST');
    expect(
      adapter.lastOptions?.path,
      '/courses/course-1/deep-revision/sessions/deep-session-1/submit',
    );
    expect(adapter.lastOptions?.data, {
      'answer':
          'La responsabilité politique permet au Parlement de contrôler le Gouvernement.',
    });
  });

  test(
    'loads a course deep revision result from the dedicated endpoint',
    () async {
      final adapter = CapturingHttpClientAdapter(
        jsonResponse(deepRevisionResultJson()),
      );
      final repository = HttpCoursesRepository(
        dio: Dio()..httpClientAdapter = adapter,
        getIdToken: () async => 'firebase-id-token',
      );

      final result = await repository.getCourseDeepRevisionResult(
        courseId: 'course-1',
        sessionId: 'deep-session-1',
      );

      expect(result.session.id, 'deep-session-1');
      expect(result.session.status, 'COMPLETED');
      expect(result.scope.label, 'Responsabilité politique');
      expect(result.question.prompt, contains('responsabilité politique'));
      expect(result.answer.text, contains('contrôler le Gouvernement'));
      expect(result.evaluation.score, 0.72);
      expect(result.evaluation.modelAnswer, contains('réponse modèle'));
      expect(result.evaluation.sources, hasLength(1));
      expect(adapter.lastOptions?.method, 'GET');
      expect(
        adapter.lastOptions?.path,
        '/courses/course-1/deep-revision/sessions/deep-session-1/result',
      );
    },
  );

  test(
    'maps a missing course deep revision result to a readable request error',
    () async {
      final adapter = CapturingHttpClientAdapter(
        jsonResponse({
          'message': 'Deep revision result not found',
        }, statusCode: 404),
      );
      final repository = HttpCoursesRepository(
        dio: Dio()..httpClientAdapter = adapter,
        getIdToken: () async => 'firebase-id-token',
      );

      await expectLater(
        repository.getCourseDeepRevisionResult(
          courseId: 'course-1',
          sessionId: 'deep-session-1',
        ),
        throwsA(
          isA<CourseRequestException>().having(
            (error) => error.message,
            'message',
            'Résultat indisponible',
          ),
        ),
      );
    },
  );

  test('loads course deep revision history', () async {
    final adapter = CapturingHttpClientAdapter(
      jsonResponse(deepRevisionHistoryJson()),
    );
    final repository = HttpCoursesRepository(
      dio: Dio()..httpClientAdapter = adapter,
      getIdToken: () async => 'firebase-id-token',
    );

    final history = await repository.getCourseDeepRevisionHistory(
      courseId: 'course-1',
      limit: 7,
    );

    expect(history.items, hasLength(1));
    expect(history.items.single.sessionId, 'deep-session-1');
    expect(history.items.single.title, 'Révision approfondie');
    expect(
      history.items.single.knowledgeUnit.title,
      'Responsabilité politique',
    );
    expect(history.items.single.score, 0.72);
    expect(
      history.items.single.resultPath,
      '/courses/course-1/deep-revision/sessions/deep-session-1/result',
    );
    expect(adapter.lastOptions?.method, 'GET');
    expect(
      adapter.lastOptions?.path,
      '/courses/course-1/deep-revision/history',
    );
    expect(adapter.lastOptions?.queryParameters, {'limit': 7});
  });

  test('loads completed course exam preparation history', () async {
    final adapter = CapturingHttpClientAdapter(
      jsonResponse({
        'items': [
          revisionSessionHistoryItemJson(
            sessionId: 'exam-session-2',
            correctAnswers: 9,
            totalQuestions: 10,
            score: 0.9,
            mode: 'EXAM',
          ),
        ],
      }),
    );
    final repository = HttpCoursesRepository(
      dio: Dio()..httpClientAdapter = adapter,
      getIdToken: () async => 'firebase-id-token',
    );

    final history = await repository.getCourseExamPreparationHistory(
      courseId: 'course-1',
      limit: 3,
    );

    expect(history.items, hasLength(1));
    expect(history.items.single.session.id, 'exam-session-2');
    expect(history.items.single.session.mode, RevisionSessionMode.exam);
    expect(history.items.single.summary.correctAnswers, 9);
    expect(history.items.single.summary.totalQuestions, 10);
    expect(history.items.single.summary.score, 0.9);
    expect(adapter.lastOptions?.method, 'GET');
    expect(
      adapter.lastOptions?.path,
      '/courses/course-1/exam-preparation/history',
    );
    expect(adapter.lastOptions?.queryParameters, {'limit': 3});
  });

  test('maps course history 404 to CourseNotFoundException', () async {
    final adapter = CapturingHttpClientAdapter(
      jsonResponse({'message': 'Course not found'}, statusCode: 404),
    );
    final repository = HttpCoursesRepository(
      dio: Dio()..httpClientAdapter = adapter,
      getIdToken: () async => 'firebase-id-token',
    );

    await expectLater(
      repository.getCourseRevisionSessionHistory(courseId: 'missing-course'),
      throwsA(isA<CourseNotFoundException>()),
    );
  });

  test('loads and prepares course question bank readiness', () async {
    final readinessRepository = HttpCoursesRepository(
      dio: Dio()
        ..httpClientAdapter = CapturingHttpClientAdapter(
          jsonResponse(questionBankReadinessJson(status: 'READY')),
        ),
      getIdToken: () async => 'firebase-id-token',
    );

    final readiness = await readinessRepository.getQuestionBankReadiness(
      courseId: 'course-1',
      questionCount: 5,
    );

    expect(readiness.status, CourseQuestionBankReadinessStatus.ready);
    expect(readiness.readyQuestionCount, 10);
    expect(readiness.canStartQuickRevision, isTrue);

    final prepareAdapter = CapturingHttpClientAdapter(
      jsonResponse(questionBankReadinessJson(status: 'PREPARING')),
    );
    final prepareRepository = HttpCoursesRepository(
      dio: Dio()..httpClientAdapter = prepareAdapter,
      getIdToken: () async => 'firebase-id-token',
    );

    final preparing = await prepareRepository.prepareQuestionBank(
      courseId: 'course-1',
      questionCount: 5,
    );

    expect(preparing.status, CourseQuestionBankReadinessStatus.preparing);
    expect(prepareAdapter.lastOptions?.method, 'POST');
    expect(
      prepareAdapter.lastOptions?.path,
      '/courses/course-1/question-bank/prepare',
    );
    expect(prepareAdapter.lastOptions?.data, {'questionCount': 5});
  });

  test('loads course learning path from the learning path endpoint', () async {
    final adapter = CapturingHttpClientAdapter(
      jsonResponse(courseLearningPathJson()),
    );
    final repository = HttpCoursesRepository(
      dio: Dio()..httpClientAdapter = adapter,
      getIdToken: () async => 'firebase-id-token',
    );

    final path = await repository.getCourseLearningPath(courseId: 'course-1');

    expect(path.course.title, 'Droit constitutionnel');
    expect(path.summary.estimatedGlobalMastery, 0.62);
    expect(path.activeNodeId, 'unit-2');
    expect(
      path.primaryAction.kind,
      CourseLearningPathPrimaryActionKind.reviewActiveNode,
    );
    expect(path.primaryAction.label, 'Continuer');
    expect(path.primaryAction.targetKnowledgeUnitId, 'unit-2');
    expect(path.nodes, hasLength(3));
    expect(path.nodes[0].state, CourseLearningPathNodeState.solid);
    expect(path.nodes[1].display.statusLabel, 'À renforcer');
    expect(path.nodes[1].source?.fileName, 'CM.pdf');
    expect(path.nodes[1].lastPracticedAt, DateTime.utc(2026, 6, 18, 12));
    expect(path.emptyState, isNull);
    expect(adapter.lastOptions?.method, 'GET');
    expect(adapter.lastOptions?.path, '/courses/course-1/learning-path');
  });

  test('maps unknown learning path enums safely', () async {
    final adapter = CapturingHttpClientAdapter(
      jsonResponse(
        courseLearningPathJson(
          primaryActionKind: 'FUTURE_ACTION',
          nodes: [courseLearningPathNodeJson(state: 'FUTURE_STATE')],
          emptyState: {
            'title': 'Parcours à venir',
            'message': 'Le parcours sera bientôt disponible.',
            'actionLabel': 'Revenir plus tard',
            'actionKind': 'FUTURE_EMPTY_ACTION',
          },
        ),
      ),
    );
    final repository = HttpCoursesRepository(
      dio: Dio()..httpClientAdapter = adapter,
      getIdToken: () async => 'firebase-id-token',
    );

    final path = await repository.getCourseLearningPath(courseId: 'course-1');

    expect(
      path.primaryAction.kind,
      CourseLearningPathPrimaryActionKind.unknown,
    );
    expect(path.nodes.single.state, CourseLearningPathNodeState.unknown);
    expect(
      path.emptyState?.actionKind,
      CourseLearningPathEmptyActionKind.unknown,
    );
  });

  test('loads course progress from the course progress endpoint', () async {
    final adapter = CapturingHttpClientAdapter(
      jsonResponse(courseProgressJson()),
    );
    final repository = HttpCoursesRepository(
      dio: Dio()..httpClientAdapter = adapter,
      getIdToken: () async => 'firebase-id-token',
    );

    final progress = await repository.getCourseProgress(courseId: 'course-1');

    expect(progress.knowledgeUnitCount, 12);
    expect(progress.practicedKnowledgeUnitCount, 3);
    expect(progress.coverage, 0.25);
    expect(progress.mastery, 0.72);
    expect(progress.estimatedGlobalMastery, 0.18);
    expect(progress.state, CourseProgressState.practiced);
    expect(adapter.lastOptions?.method, 'GET');
    expect(adapter.lastOptions?.path, '/courses/course-1/progress');
    expect(
      adapter.lastOptions?.headers['Authorization'],
      'Bearer firebase-id-token',
    );
  });

  test('loads subject progress and maps unknown course state safely', () async {
    final adapter = CapturingHttpClientAdapter(
      jsonResponse(
        subjectProgressJson(
          courses: [subjectCourseProgressJson(state: 'FUTURE_STATE')],
        ),
      ),
    );
    final repository = HttpCoursesRepository(
      dio: Dio()..httpClientAdapter = adapter,
      getIdToken: () async => 'firebase-id-token',
    );

    final progress = await repository.getSubjectProgress(
      subjectId: 'subject-1',
    );

    expect(progress.courseCount, 1);
    expect(progress.readyCourseCount, 1);
    expect(progress.courses.single.state, CourseProgressState.unknown);
    expect(adapter.lastOptions?.method, 'GET');
    expect(adapter.lastOptions?.path, '/subjects/subject-1/progress');
  });

  test('parses nullable mastery and progress 404 errors', () async {
    final noMasteryRepository = HttpCoursesRepository(
      dio: Dio()
        ..httpClientAdapter = CapturingHttpClientAdapter(
          jsonResponse(courseProgressJson(mastery: null)),
        ),
      getIdToken: () async => 'firebase-id-token',
    );

    final progress = await noMasteryRepository.getCourseProgress(
      courseId: 'course-1',
    );

    expect(progress.mastery, isNull);

    final missingCourseRepository = HttpCoursesRepository(
      dio: Dio()
        ..httpClientAdapter = CapturingHttpClientAdapter(
          jsonResponse({'message': 'Course not found'}, statusCode: 404),
        ),
      getIdToken: () async => 'firebase-id-token',
    );

    await expectLater(
      missingCourseRepository.getCourseProgress(courseId: 'missing'),
      throwsA(isA<CourseNotFoundException>()),
    );
  });

  test('maps course quick revision 404 and 409 to typed exceptions', () async {
    final missingCourseRepository = HttpCoursesRepository(
      dio: Dio()
        ..httpClientAdapter = CapturingHttpClientAdapter(
          jsonResponse({'message': 'Course not found'}, statusCode: 404),
        ),
      getIdToken: () async => 'firebase-id-token',
    );

    await expectLater(
      missingCourseRepository.startCourseQuickRevision(courseId: 'missing'),
      throwsA(isA<CourseNotFoundException>()),
    );

    final notReadyRepository = HttpCoursesRepository(
      dio: Dio()
        ..httpClientAdapter = CapturingHttpClientAdapter(
          jsonResponse({
            'message': 'Course has no ready knowledge unit',
          }, statusCode: 409),
        ),
      getIdToken: () async => 'firebase-id-token',
    );

    await expectLater(
      notReadyRepository.startCourseQuickRevision(courseId: 'course-1'),
      throwsA(
        isA<CourseQuickRevisionUnavailableException>().having(
          (error) => error.message,
          'message',
          "Aucune notion exploitable n'a encore été trouvée pour ce cours.",
        ),
      ),
    );

    final preparingRepository = HttpCoursesRepository(
      dio: Dio()
        ..httpClientAdapter = CapturingHttpClientAdapter(
          jsonResponse({
            'code': 'COURSE_QUICK_REVISION_QUESTIONS_PREPARING',
            'message':
                'Les questions sont en préparation. Réessaie dans un instant.',
            'readiness': questionBankReadinessJson(status: 'PREPARING'),
          }, statusCode: 409),
        ),
      getIdToken: () async => 'firebase-id-token',
    );

    await expectLater(
      preparingRepository.startCourseQuickRevision(courseId: 'course-1'),
      throwsA(
        isA<CourseQuickRevisionUnavailableException>()
            .having(
              (error) => error.message,
              'message',
              'Les questions sont en préparation. Réessaie dans un instant.',
            )
            .having(
              (error) => error.readiness?.status,
              'readiness status',
              CourseQuestionBankReadinessStatus.preparing,
            ),
      ),
    );
  });

  test('rejects unknown source status and invalid shapes', () async {
    final invalidStatus = sourceJson()..['status'] = 'ARCHIVED';
    final repository = HttpCoursesRepository(
      dio: Dio()
        ..httpClientAdapter = CapturingHttpClientAdapter(
          jsonResponse({
            'course': courseJson(),
            'subject': {'id': 'subject-1', 'name': 'Droit'},
            'sources': [invalidStatus],
          }),
        ),
      getIdToken: () async => 'firebase-id-token',
    );

    await expectLater(
      repository.getCourse(courseId: 'course-1'),
      throwsFormatException,
    );
  });
}

Map<String, Object?> richClosedHistoryItemJson({
  String sessionId = 'rich-session-1',
  int correctAnswers = 4,
  int totalQuestions = 6,
  double score = 0.667,
}) {
  return {
    'id': sessionId,
    'sessionId': sessionId,
    'type': 'rich_closed_exercise',
    'status': 'completed',
    'title': 'Questions riches - Constitution',
    'subjectId': 'subject-1',
    'documentId': 'document-1',
    'knowledgeUnit': {'id': 'unit-1', 'title': 'Séparation des pouvoirs'},
    'course': {'id': 'course-1', 'title': 'Droit constitutionnel'},
    'correctAnswers': correctAnswers,
    'totalQuestions': totalQuestions,
    'score': score,
    'completedAt': '2026-06-18T10:07:00.000Z',
    'resultPath': '/activities/rich-closed/$sessionId/result',
  };
}

Map<String, Object?> richRevisionOptionsJson({
  String state = 'READY',
  bool canStart = true,
}) {
  return {
    'course': {
      'id': 'course-1',
      'title': 'Droit constitutionnel',
      'subjectId': 'subject-1',
    },
    'readiness': {
      'canStart': canStart,
      'state': state,
      'userMessage': 'Ton cours est prêt pour un QCM complet.',
      'blockers': <String>[],
      'readySourceCount': 1,
      'readyKnowledgeUnitCount': 1,
    },
    'scopeOptions': [
      {
        'kind': 'knowledge_unit',
        'id': 'ku-1',
        'documentId': 'document-1',
        'label': 'Responsabilité politique',
        'sourceLabel': 'CM.pdf',
        'canSelect': true,
      },
    ],
    'questionCountOptions': [6, 10, 13],
    'defaultQuestionCount': 6,
    'supportedQuestionKinds': ['single_choice', 'multiple_choice', 'matching'],
    'complexityProfiles': ['standard', 'advanced'],
    'defaultConfig': {
      'scopeKind': 'knowledge_unit',
      'scopeId': 'ku-1',
      'questionCount': 6,
      'complexityProfile': 'standard',
    },
    'nextStep': {
      'kind': 'configuration_ready',
      'userMessage': 'Choisis une notion et démarre le QCM complet.',
    },
  };
}

Map<String, Object?> examPreparationOptionsJson({
  String state = 'READY',
  bool canPrepare = true,
  int availableQuestionCount = 24,
}) {
  return {
    'course': {
      'id': 'course-1',
      'title': 'Droit constitutionnel',
      'subjectId': 'subject-1',
    },
    'readiness': {
      'canPrepare': canPrepare,
      'state': state,
      'userMessage': 'Ton cours est prêt pour une préparation examen.',
      'blockers': <String>[],
      'readySourceCount': 1,
      'readyKnowledgeUnitCount': 2,
      'availableQuestionCount': availableQuestionCount,
    },
    'scopeOptions': [
      {
        'kind': 'course',
        'id': 'course-1',
        'label': 'Tout le cours',
        'readyQuestionCount': availableQuestionCount,
        'readyKnowledgeUnitCount': 2,
        'canSelect': true,
      },
      {
        'kind': 'source',
        'id': 'document-1',
        'label': 'CM.pdf',
        'readyQuestionCount': 16,
        'readyKnowledgeUnitCount': 1,
        'canSelect': true,
      },
    ],
    'questionCountOptions': [10, 20],
    'defaultQuestionCount': 20,
    'supportedQuestionKinds': ['single_choice', 'multiple_choice'],
    'defaultConfig': {
      'scopeKind': 'course',
      'scopeId': 'course-1',
      'questionCount': 20,
      'complexityProfile': 'exam',
    },
    'nextStep': {
      'kind': 'configuration_ready',
      'userMessage':
          'Configuration prête. Tu peux démarrer un entraînement examen.',
    },
  };
}

Map<String, Object?> deepRevisionOptionsJson({
  String state = 'READY',
  bool canStart = true,
}) {
  return {
    'course': {
      'id': 'course-1',
      'title': 'Droit constitutionnel',
      'subjectId': 'subject-1',
    },
    'readiness': {
      'canStart': canStart,
      'state': state,
      'userMessage': 'Ton cours est prêt pour une révision approfondie.',
      'blockers': <String>[],
      'readySourceCount': 1,
      'readyKnowledgeUnitCount': 1,
    },
    'scopeOptions': [
      {
        'kind': 'knowledge_unit',
        'id': 'ku-1',
        'documentId': 'document-1',
        'label': 'Responsabilité politique',
        'sourceLabel': 'CM.pdf',
        'canSelect': true,
      },
    ],
    'answerGuidelines': {
      'minLength': 12,
      'maxLength': 4000,
      'userMessage': 'Rédige une réponse structurée avec tes propres mots.',
    },
    'defaultConfig': {'scopeKind': 'knowledge_unit', 'scopeId': 'ku-1'},
    'nextStep': {
      'kind': 'configuration_ready',
      'userMessage': 'Choisis une notion et démarre la question ouverte.',
    },
  };
}

Map<String, Object?> deepRevisionSessionJson() {
  return {
    'session': {
      'id': 'deep-session-1',
      'mode': 'DEEP',
      'status': 'STARTED',
      'courseId': 'course-1',
    },
    'question': openQuestionJson(),
    'scope': {
      'kind': 'knowledge_unit',
      'id': 'ku-1',
      'label': 'Responsabilité politique',
      'sourceLabel': 'CM.pdf',
    },
    'answerGuidelines': {'minLength': 12, 'maxLength': 4000},
  };
}

Map<String, Object?> deepRevisionSubmitJson() {
  return {
    'session': {
      'id': 'deep-session-1',
      'mode': 'DEEP',
      'status': 'COMPLETED',
      'courseId': 'course-1',
      'completedAt': '2026-06-25T12:00:00.000Z',
    },
    'resultPath':
        '/courses/course-1/deep-revision/sessions/deep-session-1/result',
    'evaluation': openAnswerEvaluationJson(),
  };
}

Map<String, Object?> deepRevisionResultJson() {
  return {
    'session': {
      'id': 'deep-session-1',
      'mode': 'DEEP',
      'status': 'COMPLETED',
      'courseId': 'course-1',
      'completedAt': '2026-06-25T12:00:00.000Z',
    },
    'scope': {
      'kind': 'knowledge_unit',
      'id': 'ku-1',
      'label': 'Responsabilité politique',
      'sourceLabel': 'CM.pdf',
    },
    'question': openQuestionJson(),
    'answer': {
      'text':
          'La responsabilité politique permet au Parlement de contrôler le Gouvernement.',
      'submittedAt': '2026-06-25T12:00:00.000Z',
    },
    'evaluation': openAnswerEvaluationJson(),
  };
}

Map<String, Object?> deepRevisionHistoryJson() {
  return {
    'items': [
      {
        'sessionId': 'deep-session-1',
        'type': 'deep_revision',
        'status': 'completed',
        'title': 'Révision approfondie',
        'course': {'id': 'course-1', 'title': 'Droit constitutionnel'},
        'knowledgeUnit': {'id': 'ku-1', 'title': 'Responsabilité politique'},
        'score': 0.72,
        'submittedAt': '2026-06-25T12:00:00.000Z',
        'resultPath':
            '/courses/course-1/deep-revision/sessions/deep-session-1/result',
      },
    ],
  };
}

Map<String, Object?> openQuestionJson() {
  return {
    'id': 'open-question-1',
    'prompt': 'Explique la responsabilité politique du Gouvernement.',
    'instructions': 'Structure ta réponse en deux idées.',
    'maxAnswerLength': 4000,
    'sources': [
      {'chunkId': 'chunk-1', 'pageNumber': 4, 'index': 0},
    ],
  };
}

Map<String, Object?> openAnswerEvaluationJson() {
  return {
    'id': 'evaluation-1',
    'status': 'READY',
    'score': 0.72,
    'maxScore': 1,
    'feedback': 'Bonne structure, mais il manque une nuance.',
    'presentPoints': ['Contrôle parlementaire'],
    'missingPoints': ['Responsabilité collective'],
    'errors': ['Confusion légère avec la responsabilité pénale'],
    'modelAnswer': 'Une réponse modèle rappelle le contrôle politique.',
    'advice': 'Reprends les conditions de mise en jeu.',
    'sources': [
      {
        'chunkId': 'chunk-1',
        'text': 'Le Gouvernement est responsable devant le Parlement.',
        'pageNumber': 4,
        'index': 0,
      },
    ],
  };
}

Map<String, Object?> revisionSessionJson({
  required String courseId,
  String sessionId = 'revision-session-1',
  String mode = 'QUICK',
}) {
  return {
    'session': {
      'id': sessionId,
      'status': 'STARTED',
      'mode': mode,
      'subjectId': 'subject-1',
      'courseId': courseId,
      'documentId': 'document-1',
      'knowledgeUnitId': 'knowledge-unit-1',
      'createdAt': '2026-06-18T10:00:00.000Z',
      'completedAt': null,
    },
    'currentAction': {
      'id': 'action-1',
      'kind': 'DIAGNOSTIC_QUIZ',
      'status': 'READY',
      'displayOrder': 0,
      'activitySessionId': 'activity-session-1',
      'documentId': 'document-1',
      'knowledgeUnitId': 'knowledge-unit-1',
      'payload': null,
    },
    'history': [],
  };
}

Map<String, Object?> resumableRevisionSessionJson({required String courseId}) {
  return {
    'session': revisionSessionJson(courseId: courseId)['session'],
    'currentAction': revisionSessionJson(courseId: courseId)['currentAction'],
    'progress': {'answeredQuestionCount': 2, 'totalQuestionCount': 5},
    'userMessage': 'Tu as une session en cours.',
  };
}

Map<String, Object?> revisionSessionHistoryItemJson({
  String sessionId = 'revision-session-1',
  int correctAnswers = 4,
  int totalQuestions = 5,
  double score = 0.8,
  String mode = 'QUICK',
}) {
  return {
    'session': {
      'id': sessionId,
      'status': 'COMPLETED',
      'mode': mode,
      'subjectId': 'subject-1',
      'courseId': 'course-1',
      'createdAt': '2026-06-18T10:00:00.000Z',
      'completedAt': '2026-06-18T10:07:00.000Z',
    },
    'summary': {
      'correctAnswers': correctAnswers,
      'totalQuestions': totalQuestions,
      'score': score,
      'durationSeconds': 420,
    },
    'course': {'id': 'course-1', 'title': 'Droit constitutionnel'},
  };
}

Map<String, Object?> courseJson({
  int sourceCount = 2,
  int readySourceCount = 1,
  int processingSourceCount = 1,
  int failedSourceCount = 0,
  String title = 'Droit constitutionnel',
}) {
  return {
    'id': 'course-1',
    'subjectId': 'subject-1',
    'title': title,
    'description': 'Institutions',
    'chapterLabel': 'Chapitre 1',
    'estimatedMinutes': 30,
    'displayOrder': 0,
    'createdAt': '2026-06-18T10:00:00.000Z',
    'updatedAt': '2026-06-18T10:00:00.000Z',
    'sourceCount': sourceCount,
    'readySourceCount': readySourceCount,
    'processingSourceCount': processingSourceCount,
    'failedSourceCount': failedSourceCount,
  };
}

Map<String, Object?> courseLifecycleJson({
  String status = 'ACTIVE',
  String recommendedAction = 'DELETE',
}) {
  return {
    'courseId': 'course-1',
    'status': status,
    'recommendedAction': recommendedAction,
    'canDelete': recommendedAction == 'DELETE',
    'canArchive': recommendedAction == 'ARCHIVE',
    'canUpdate': status == 'ACTIVE',
    'blockingReasons': const <String>[],
    'userMessage': 'Décision lifecycle cours',
  };
}

Map<String, Object?> questionBankReadinessJson({String status = 'READY'}) {
  return {
    'courseId': 'course-1',
    'status': status,
    'readyQuestionCount': status == 'READY' ? 10 : 0,
    'targetQuestionCount': 10,
    'canStartQuickRevision': status == 'READY',
    'canPrepare': status == 'NOT_PREPARED' || status == 'FAILED',
    'userMessage': status == 'PREPARING'
        ? 'Les questions sont en préparation. Réessaie dans un instant.'
        : 'Les questions sont prêtes.',
  };
}

Map<String, Object?> sourceJson() {
  return sourceJsonWith(status: 'READY');
}

Map<String, Object?> sourceJsonWith({required String status}) {
  return {
    'id': 'document-1',
    'courseId': 'course-1',
    'documentId': 'document-1',
    'fileName': 'cours.pdf',
    'kind': 'COURSE_PDF',
    'status': status,
    'errorCode': null,
    'createdAt': '2026-06-18T10:00:00.000Z',
    'updatedAt': '2026-06-18T10:00:00.000Z',
  };
}

Map<String, Object?> sourceLifecycleJson({
  String status = 'ACTIVE',
  String action = 'ARCHIVE',
}) {
  return {
    'documentId': 'document-1',
    'courseId': 'course-1',
    'status': status,
    'recommendedAction': action,
    'canDelete': action == 'DELETE',
    'canArchive': action == 'ARCHIVE',
    'blockingReasons': action == 'ARCHIVE' ? ['HAS_KNOWLEDGE_UNITS'] : [],
    'userMessage': 'Cette source peut être archivée.',
  };
}

Map<String, Object?> courseProgressJson({Object? mastery = 0.72}) {
  return {
    'courseId': 'course-1',
    'subjectId': 'subject-1',
    'knowledgeUnitCount': 12,
    'practicedKnowledgeUnitCount': 3,
    'coverage': 0.25,
    'mastery': mastery,
    'estimatedGlobalMastery': 0.18,
    'readySourceCount': 1,
    'processingSourceCount': 0,
    'failedSourceCount': 0,
    'lastPracticedAt': '2026-06-18T12:00:00.000Z',
    'state': 'PRACTICED',
  };
}

Map<String, Object?> courseLearningPathJson({
  String primaryActionKind = 'REVIEW_ACTIVE_NODE',
  List<Map<String, Object?>>? nodes,
  Map<String, Object?>? emptyState,
}) {
  return {
    'generatedAt': '2026-06-18T12:30:00.000Z',
    'course': {
      'id': 'course-1',
      'subjectId': 'subject-1',
      'subjectName': 'Droit',
      'title': 'Droit constitutionnel',
    },
    'summary': {
      'knowledgeUnitCount': 3,
      'solidCount': 1,
      'inProgressCount': 1,
      'toStrengthenCount': 1,
      'undiscoveredCount': 0,
      'estimatedGlobalMastery': 0.62,
      'mastery': 0.74,
      'coverage': 0.83,
      'readySourceCount': 1,
    },
    'activeNodeId': 'unit-2',
    'primaryAction': {
      'kind': primaryActionKind,
      'label': 'Continuer',
      'description': 'Reprendre le parcours à la notion recommandée.',
      'estimatedMinutes': 8,
      'targetKnowledgeUnitId': 'unit-2',
      'targetNodeId': 'unit-2',
      'enabled': true,
      'unavailableReason': null,
    },
    'nodes':
        nodes ??
        [
          courseLearningPathNodeJson(
            id: 'unit-1',
            title: 'La Constitution',
            state: 'SOLID',
            statusLabel: 'Solide',
            masteryScore: 0.9,
            lastPracticedAt: null,
          ),
          courseLearningPathNodeJson(
            id: 'unit-2',
            title: 'Le contrôle de constitutionnalité',
            state: 'TO_STRENGTHEN',
            statusLabel: 'À renforcer',
            masteryScore: 0.36,
          ),
          courseLearningPathNodeJson(
            id: 'unit-3',
            title: 'Le Conseil constitutionnel',
            state: 'IN_PROGRESS',
            statusLabel: 'En cours',
            masteryScore: 0.66,
          ),
        ],
    'emptyState': emptyState,
  };
}

Map<String, Object?> courseLearningPathNodeJson({
  String id = 'unit-2',
  String title = 'Le contrôle de constitutionnalité',
  String state = 'TO_STRENGTHEN',
  String statusLabel = 'À renforcer',
  Object? masteryScore = 0.36,
  Object? lastPracticedAt = '2026-06-18T12:00:00.000Z',
}) {
  return {
    'id': id,
    'knowledgeUnitId': id,
    'courseId': 'course-1',
    'subjectId': 'subject-1',
    'documentId': 'document-1',
    'title': title,
    'order': id == 'unit-1'
        ? 0
        : id == 'unit-2'
        ? 1
        : 2,
    'state': state,
    'masteryScore': masteryScore,
    'lastPracticedAt': lastPracticedAt,
    'source': {'documentId': 'document-1', 'fileName': 'CM.pdf'},
    'display': {
      'title': title,
      'statusLabel': statusLabel,
      'metaLabel': 'CM.pdf',
      'actionLabel': 'Continuer',
      'unavailableReason': null,
    },
  };
}

Map<String, Object?> subjectProgressJson({
  List<Map<String, Object?>>? courses,
}) {
  return {
    'subjectId': 'subject-1',
    'knowledgeUnitCount': 12,
    'practicedKnowledgeUnitCount': 3,
    'coverage': 0.25,
    'mastery': 0.72,
    'estimatedGlobalMastery': 0.18,
    'courseCount': 1,
    'readyCourseCount': 1,
    'lastPracticedAt': '2026-06-18T12:00:00.000Z',
    'courses': courses ?? [subjectCourseProgressJson()],
  };
}

Map<String, Object?> subjectCourseProgressJson({String state = 'PRACTICED'}) {
  return {
    'courseId': 'course-1',
    'title': 'Droit constitutionnel',
    'knowledgeUnitCount': 12,
    'practicedKnowledgeUnitCount': 3,
    'coverage': 0.25,
    'mastery': 0.72,
    'estimatedGlobalMastery': 0.18,
    'state': state,
  };
}

Map<String, Object?> revisionSheetJson() {
  return {
    'id': 'sheet-1',
    'documentId': 'document-1',
    'subjectId': 'subject-1',
    'status': 'READY',
    'title': 'Fiche de cours',
    'introduction': 'Introduction',
    'keyPoints': ['Point clé'],
    'commonMistakes': ['Erreur fréquente'],
    'mustKnow': ['À savoir'],
    'practiceSuggestions': ['S’entraîner'],
    'errorCode': null,
    'sections': [
      {
        'id': 'section-1',
        'displayOrder': 0,
        'title': 'Institutions',
        'content': 'Le Parlement contrôle le Gouvernement.',
        'sources': [
          {
            'chunkId': 'chunk-1',
            'text': 'Extrait source',
            'pageNumber': 1,
            'index': 0,
          },
        ],
      },
    ],
  };
}

ResponseBody jsonResponse(Object? body, {int statusCode = 200}) {
  return ResponseBody.fromString(
    jsonEncode(body),
    statusCode,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );
}
