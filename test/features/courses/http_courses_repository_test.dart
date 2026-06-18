import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:revision_app/features/courses/data/http_courses_repository.dart';
import 'package:revision_app/features/courses/domain/course_models.dart';
import 'package:revision_app/features/courses/domain/courses_repository.dart';

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

Map<String, Object?> courseJson({
  int sourceCount = 2,
  int readySourceCount = 1,
}) {
  return {
    'id': 'course-1',
    'subjectId': 'subject-1',
    'title': 'Droit constitutionnel',
    'description': 'Institutions',
    'chapterLabel': 'Chapitre 1',
    'estimatedMinutes': 30,
    'displayOrder': 0,
    'createdAt': '2026-06-18T10:00:00.000Z',
    'updatedAt': '2026-06-18T10:00:00.000Z',
    'sourceCount': sourceCount,
    'readySourceCount': readySourceCount,
    'processingSourceCount': 1,
    'failedSourceCount': 0,
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
