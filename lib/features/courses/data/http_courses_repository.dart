import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../domain/course_models.dart';
import '../domain/courses_repository.dart';
import '../../documents/data/revision_sheet_json.dart';
import '../../documents/domain/revision_document.dart';
import '../../documents/domain/source_lifecycle.dart';
import '../../revision_sessions/data/http_revision_sessions_api.dart';
import '../../revision_sessions/domain/revision_session.dart';

class HttpCoursesRepository implements CoursesRepository {
  HttpCoursesRepository({
    required Dio dio,
    required Future<String> Function() getIdToken,
  }) : this._(dio, getIdToken);

  const HttpCoursesRepository._(this._dio, this._getIdToken);

  final Dio _dio;
  final Future<String> Function() _getIdToken;

  @override
  Future<List<CourseListItem>> listCourses({required String subjectId}) async {
    final response = await _dio.get<Object?>(
      '/subjects/${Uri.encodeComponent(subjectId)}/courses',
      options: await _authorizedOptions(),
    );
    final rawCourses = response.data;

    if (rawCourses is! List) {
      throw const FormatException('Invalid courses response');
    }

    return rawCourses
        .map((course) => _CourseJson(course).toListItem())
        .toList(growable: false);
  }

  @override
  Future<CourseDetail> getCourse({required String courseId}) async {
    try {
      final response = await _dio.get<Object?>(
        '/courses/${Uri.encodeComponent(courseId)}',
        options: await _authorizedOptions(),
      );

      return _CourseDetailJson(response.data).toDetail();
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        throw const CourseNotFoundException('Course not found');
      }
      rethrow;
    }
  }

  @override
  Future<CourseListItem> createCourse({
    required String subjectId,
    required CreateCourseInput input,
  }) async {
    try {
      final response = await _dio.post<Object?>(
        '/subjects/${Uri.encodeComponent(subjectId)}/courses',
        data: {
          'title': input.title,
          'description': input.description,
          'chapterLabel': input.chapterLabel,
          'estimatedMinutes': input.estimatedMinutes,
        },
        options: await _authorizedOptions(),
      );

      return _CourseJson(response.data).toListItem();
    } on DioException catch (error) {
      if (error.response?.statusCode == 400) {
        throw const CourseRequestException('Invalid course request');
      }
      if (error.response?.statusCode == 404) {
        throw const CourseNotFoundException('Course subject not found');
      }
      rethrow;
    }
  }

  @override
  Future<CourseDocument> uploadCoursePdf({
    required String courseId,
    required String fileName,
    required Uint8List bytes,
  }) async {
    try {
      final response = await _dio.post<Object?>(
        '/courses/${Uri.encodeComponent(courseId)}/source/course-pdf',
        data: FormData.fromMap({
          'file': MultipartFile.fromBytes(
            bytes,
            filename: fileName,
            contentType: DioMediaType('application', 'pdf'),
          ),
        }),
        options: await _authorizedOptions(),
      );

      return _CourseDocumentJson(response.data).toDocument();
    } on DioException catch (error) {
      if (error.response?.statusCode == 400) {
        throw const CourseUploadException('Invalid course PDF upload');
      }
      if (error.response?.statusCode == 404) {
        throw const CourseNotFoundException('Course not found');
      }
      rethrow;
    }
  }

  @override
  Future<void> deleteCourseDocument({
    required String courseId,
    required String documentId,
  }) async {
    try {
      await _dio.delete<Object?>(
        '/courses/${Uri.encodeComponent(courseId)}/sources/${Uri.encodeComponent(documentId)}',
        options: await _authorizedOptions(),
      );
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        throw const CourseNotFoundException('Course source not found');
      }
      if (error.response?.statusCode == 409) {
        throw CourseRequestException(
          _responseMessage(error) ?? 'Cette source ne peut pas être supprimée.',
        );
      }
      rethrow;
    }
  }

  @override
  Future<SourceLifecycleDecision> getCourseDocumentLifecycle({
    required String courseId,
    required String documentId,
  }) async {
    try {
      final response = await _dio.get<Object?>(
        '/courses/${Uri.encodeComponent(courseId)}/sources/${Uri.encodeComponent(documentId)}/lifecycle',
        options: await _authorizedOptions(),
      );

      return SourceLifecycleDecisionJson(response.data).toDecision();
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        throw const CourseNotFoundException('Course source not found');
      }
      rethrow;
    }
  }

  @override
  Future<SourceLifecycleDecision> archiveCourseDocument({
    required String courseId,
    required String documentId,
  }) async {
    try {
      final response = await _dio.post<Object?>(
        '/courses/${Uri.encodeComponent(courseId)}/sources/${Uri.encodeComponent(documentId)}/archive',
        options: await _authorizedOptions(),
      );

      return SourceLifecycleDecisionJson(response.data).toDecision();
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        throw const CourseNotFoundException('Course source not found');
      }
      if (error.response?.statusCode == 409) {
        throw CourseRequestException(
          _responseMessage(error) ?? 'Cette source ne peut pas être archivée.',
        );
      }
      rethrow;
    }
  }

  @override
  Future<RevisionSheet?> getCourseRevisionSheet({
    required String courseId,
  }) async {
    try {
      final response = await _dio.get<Object?>(
        '/courses/${Uri.encodeComponent(courseId)}/revision-sheet',
        options: await _authorizedOptions(),
      );

      return RevisionSheetJson(response.data).toRevisionSheet();
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        final message = _responseMessage(error);
        if (message == 'Revision sheet not found') {
          return null;
        }

        // CORE-04-bis: an ambiguous 404 is safer as a missing course than as
        // a missing sheet, otherwise a deleted/unknown course looks generatable.
        throw const CourseNotFoundException('Course not found');
      }
      if (error.response?.statusCode == 409) {
        throw const CourseRevisionSheetNotReadyException(
          'Course has no ready source',
        );
      }
      rethrow;
    }
  }

  @override
  Future<RevisionSheet> generateCourseRevisionSheet({
    required String courseId,
  }) async {
    try {
      final response = await _dio.post<Object?>(
        '/courses/${Uri.encodeComponent(courseId)}/revision-sheet',
        options: await _authorizedOptions(),
      );

      return RevisionSheetJson(response.data).toRevisionSheet();
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        throw const CourseNotFoundException('Course not found');
      }
      if (error.response?.statusCode == 409) {
        throw const CourseRevisionSheetNotReadyException(
          'Course has no ready source',
        );
      }
      rethrow;
    }
  }

  @override
  Future<RevisionSessionResponse> startCourseQuickRevision({
    required String courseId,
    int questionCount = 10,
  }) async {
    try {
      final response = await _dio.post<Object?>(
        '/courses/${Uri.encodeComponent(courseId)}/revision-sessions/quick',
        data: {'questionCount': questionCount},
        options: await _authorizedOptions(),
      );

      return RevisionSessionResponseJson(response.data).toResponse();
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        throw const CourseNotFoundException('Course not found');
      }
      if (error.response?.statusCode == 409) {
        final message = _responseMessage(error);
        throw CourseQuickRevisionUnavailableException(
          message ?? 'Course quick revision is not available',
        );
      }
      rethrow;
    }
  }

  @override
  Future<CourseProgress> getCourseProgress({required String courseId}) async {
    try {
      final response = await _dio.get<Object?>(
        '/courses/${Uri.encodeComponent(courseId)}/progress',
        options: await _authorizedOptions(),
      );

      return _CourseProgressJson(response.data).toProgress();
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        throw const CourseNotFoundException('Course not found');
      }
      rethrow;
    }
  }

  @override
  Future<SubjectProgress> getSubjectProgress({
    required String subjectId,
  }) async {
    try {
      final response = await _dio.get<Object?>(
        '/subjects/${Uri.encodeComponent(subjectId)}/progress',
        options: await _authorizedOptions(),
      );

      return _SubjectProgressJson(response.data).toProgress();
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        throw const CourseNotFoundException('Course subject not found');
      }
      rethrow;
    }
  }

  Future<Options> _authorizedOptions() async {
    final token = (await _getIdToken()).trim();

    if (token.isEmpty) {
      throw StateError('A Firebase ID token is required to load courses');
    }

    return Options(headers: {'Authorization': 'Bearer $token'});
  }

  String? _responseMessage(DioException error) {
    final data = error.response?.data;
    if (data is Map<String, Object?>) {
      final message = data['message'];
      if (message is String) {
        return message;
      }
    }

    return null;
  }
}

class _CourseJson {
  const _CourseJson(this.value);

  final Object? value;

  CourseListItem toListItem() {
    final json = value;

    if (json is! Map<String, Object?>) {
      throw const FormatException('Invalid course response');
    }

    final id = json['id'];
    final subjectId = json['subjectId'];
    final title = json['title'];
    final description = json['description'];
    final chapterLabel = json['chapterLabel'];
    final estimatedMinutes = json['estimatedMinutes'];
    final displayOrder = json['displayOrder'];
    final sourceCount = json['sourceCount'];
    final readySourceCount = json['readySourceCount'];
    final processingSourceCount = json['processingSourceCount'];
    final failedSourceCount = json['failedSourceCount'];

    if (id is! String ||
        subjectId is! String ||
        title is! String ||
        displayOrder is! int ||
        sourceCount is! int ||
        readySourceCount is! int ||
        processingSourceCount is! int ||
        failedSourceCount is! int) {
      throw const FormatException('Invalid course response');
    }

    return CourseListItem(
      id: id,
      subjectId: subjectId,
      title: title,
      description: description is String ? description : null,
      chapterLabel: chapterLabel is String ? chapterLabel : null,
      estimatedMinutes: estimatedMinutes is int ? estimatedMinutes : null,
      displayOrder: displayOrder,
      createdAt: _parseOptionalDate(json['createdAt']),
      updatedAt: _parseOptionalDate(json['updatedAt']),
      sourceCount: sourceCount,
      readySourceCount: readySourceCount,
      processingSourceCount: processingSourceCount,
      failedSourceCount: failedSourceCount,
    );
  }
}

class _CourseDetailJson {
  const _CourseDetailJson(this.value);

  final Object? value;

  CourseDetail toDetail() {
    final json = value;

    if (json is! Map<String, Object?>) {
      throw const FormatException('Invalid course detail response');
    }

    final subject = json['subject'];
    final sources = json['sources'];

    if (subject is! Map<String, Object?> || sources is! List) {
      throw const FormatException('Invalid course detail response');
    }

    final subjectId = subject['id'];
    final subjectName = subject['name'];

    if (subjectId is! String || subjectName is! String) {
      throw const FormatException('Invalid course detail response');
    }

    return CourseDetail(
      course: _CourseJson(json['course']).toListItem(),
      subject: CourseSubjectSummary(id: subjectId, name: subjectName),
      sources: sources
          .map((source) => _CourseDocumentJson(source).toDocument())
          .toList(growable: false),
    );
  }
}

class _CourseDocumentJson {
  const _CourseDocumentJson(this.value);

  final Object? value;

  CourseDocument toDocument() {
    final json = value;

    if (json is! Map<String, Object?>) {
      throw const FormatException('Invalid course source response');
    }

    final id = json['id'];
    final courseId = json['courseId'];
    final documentId = json['documentId'];
    final fileName = json['fileName'];
    final kind = json['kind'];
    final status = json['status'];
    final errorCode = json['errorCode'];

    if (id is! String ||
        courseId is! String ||
        documentId is! String ||
        fileName is! String ||
        kind is! String ||
        status is! String) {
      throw const FormatException('Invalid course source response');
    }

    return CourseDocument(
      id: id,
      courseId: courseId,
      documentId: documentId,
      fileName: fileName,
      kind: kind,
      status: _parseDocumentStatus(status),
      errorCode: errorCode is String ? errorCode : null,
      createdAt: _parseOptionalDate(json['createdAt']),
      updatedAt: _parseOptionalDate(json['updatedAt']),
    );
  }
}

class _CourseProgressJson {
  const _CourseProgressJson(this.value);

  final Object? value;

  CourseProgress toProgress() {
    final json = value;

    if (json is! Map<String, Object?>) {
      throw const FormatException('Invalid course progress response');
    }

    final courseId = json['courseId'];
    final subjectId = json['subjectId'];
    final knowledgeUnitCount = json['knowledgeUnitCount'];
    final practicedKnowledgeUnitCount = json['practicedKnowledgeUnitCount'];
    final coverage = json['coverage'];
    final mastery = json['mastery'];
    final estimatedGlobalMastery = json['estimatedGlobalMastery'];
    final readySourceCount = json['readySourceCount'];
    final processingSourceCount = json['processingSourceCount'];
    final failedSourceCount = json['failedSourceCount'];
    final state = json['state'];

    if (courseId is! String ||
        subjectId is! String ||
        knowledgeUnitCount is! int ||
        practicedKnowledgeUnitCount is! int ||
        coverage is! num ||
        (mastery != null && mastery is! num) ||
        estimatedGlobalMastery is! num ||
        readySourceCount is! int ||
        processingSourceCount is! int ||
        failedSourceCount is! int ||
        state is! String) {
      throw const FormatException('Invalid course progress response');
    }

    return CourseProgress(
      courseId: courseId,
      subjectId: subjectId,
      knowledgeUnitCount: knowledgeUnitCount,
      practicedKnowledgeUnitCount: practicedKnowledgeUnitCount,
      coverage: coverage.toDouble(),
      mastery: mastery is num ? mastery.toDouble() : null,
      estimatedGlobalMastery: estimatedGlobalMastery.toDouble(),
      readySourceCount: readySourceCount,
      processingSourceCount: processingSourceCount,
      failedSourceCount: failedSourceCount,
      lastPracticedAt: _parseOptionalDate(json['lastPracticedAt']),
      state: _parseProgressState(state),
    );
  }
}

class _SubjectProgressJson {
  const _SubjectProgressJson(this.value);

  final Object? value;

  SubjectProgress toProgress() {
    final json = value;

    if (json is! Map<String, Object?>) {
      throw const FormatException('Invalid subject progress response');
    }

    final subjectId = json['subjectId'];
    final knowledgeUnitCount = json['knowledgeUnitCount'];
    final practicedKnowledgeUnitCount = json['practicedKnowledgeUnitCount'];
    final coverage = json['coverage'];
    final mastery = json['mastery'];
    final estimatedGlobalMastery = json['estimatedGlobalMastery'];
    final courseCount = json['courseCount'];
    final readyCourseCount = json['readyCourseCount'];
    final courses = json['courses'];

    if (subjectId is! String ||
        knowledgeUnitCount is! int ||
        practicedKnowledgeUnitCount is! int ||
        coverage is! num ||
        (mastery != null && mastery is! num) ||
        estimatedGlobalMastery is! num ||
        courseCount is! int ||
        readyCourseCount is! int ||
        courses is! List) {
      throw const FormatException('Invalid subject progress response');
    }

    return SubjectProgress(
      subjectId: subjectId,
      knowledgeUnitCount: knowledgeUnitCount,
      practicedKnowledgeUnitCount: practicedKnowledgeUnitCount,
      coverage: coverage.toDouble(),
      mastery: mastery is num ? mastery.toDouble() : null,
      estimatedGlobalMastery: estimatedGlobalMastery.toDouble(),
      courseCount: courseCount,
      readyCourseCount: readyCourseCount,
      lastPracticedAt: _parseOptionalDate(json['lastPracticedAt']),
      courses: courses
          .map((course) => _SubjectCourseProgressJson(course).toItem())
          .toList(growable: false),
    );
  }
}

class _SubjectCourseProgressJson {
  const _SubjectCourseProgressJson(this.value);

  final Object? value;

  SubjectCourseProgressItem toItem() {
    final json = value;

    if (json is! Map<String, Object?>) {
      throw const FormatException('Invalid subject course progress response');
    }

    final courseId = json['courseId'];
    final title = json['title'];
    final knowledgeUnitCount = json['knowledgeUnitCount'];
    final practicedKnowledgeUnitCount = json['practicedKnowledgeUnitCount'];
    final coverage = json['coverage'];
    final mastery = json['mastery'];
    final estimatedGlobalMastery = json['estimatedGlobalMastery'];
    final state = json['state'];

    if (courseId is! String ||
        title is! String ||
        knowledgeUnitCount is! int ||
        practicedKnowledgeUnitCount is! int ||
        coverage is! num ||
        (mastery != null && mastery is! num) ||
        estimatedGlobalMastery is! num ||
        state is! String) {
      throw const FormatException('Invalid subject course progress response');
    }

    return SubjectCourseProgressItem(
      courseId: courseId,
      title: title,
      knowledgeUnitCount: knowledgeUnitCount,
      practicedKnowledgeUnitCount: practicedKnowledgeUnitCount,
      coverage: coverage.toDouble(),
      mastery: mastery is num ? mastery.toDouble() : null,
      estimatedGlobalMastery: estimatedGlobalMastery.toDouble(),
      state: _parseProgressState(state),
    );
  }
}

CourseDocumentStatus _parseDocumentStatus(String value) {
  return switch (value) {
    'UPLOADED' => CourseDocumentStatus.uploaded,
    'PROCESSING' => CourseDocumentStatus.processing,
    'READY' => CourseDocumentStatus.ready,
    'FAILED' => CourseDocumentStatus.failed,
    _ => throw const FormatException('Unknown course source status'),
  };
}

CourseProgressState _parseProgressState(String value) {
  return switch (value) {
    'NO_SOURCE' => CourseProgressState.noSource,
    'PROCESSING' => CourseProgressState.processing,
    'FAILED_ONLY' => CourseProgressState.failedOnly,
    'NO_KNOWLEDGE_UNITS' => CourseProgressState.noKnowledgeUnits,
    'READY_NOT_PRACTICED' => CourseProgressState.readyNotPracticed,
    'PRACTICED' => CourseProgressState.practiced,
    _ => CourseProgressState.unknown,
  };
}

DateTime? _parseOptionalDate(Object? value) {
  if (value == null) {
    return null;
  }

  if (value is! String) {
    throw const FormatException('Invalid date response');
  }

  return DateTime.parse(value);
}
