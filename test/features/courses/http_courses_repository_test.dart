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

Map<String, Object?> revisionSessionJson({required String courseId}) {
  return {
    'session': {
      'id': 'revision-session-1',
      'status': 'STARTED',
      'mode': 'QUICK',
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
}) {
  return {
    'session': {
      'id': sessionId,
      'status': 'COMPLETED',
      'mode': 'QUICK',
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
