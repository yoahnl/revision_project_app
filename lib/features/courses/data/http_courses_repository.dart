import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../../activities/domain/open_question_activity.dart';
import '../../activities/domain/rich_closed_exercise.dart';
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
  Future<CourseListItem> updateCourse({
    required String courseId,
    required UpdateCourseInput input,
  }) async {
    try {
      final data = <String, Object?>{};
      if (input.title != null) {
        data['title'] = input.title;
      }
      if (input.description != null) {
        data['description'] = input.description;
      }
      if (input.chapterLabel != null) {
        data['chapterLabel'] = input.chapterLabel;
      }
      if (input.estimatedMinutes != null) {
        data['estimatedMinutes'] = input.estimatedMinutes;
      }

      final response = await _dio.patch<Object?>(
        '/courses/${Uri.encodeComponent(courseId)}',
        data: data,
        options: await _authorizedOptions(),
      );

      return _CourseJson(response.data).toListItem();
    } on DioException catch (error) {
      if (error.response?.statusCode == 400) {
        throw const CourseRequestException('Invalid course request');
      }
      if (error.response?.statusCode == 404) {
        throw const CourseNotFoundException('Course not found');
      }
      rethrow;
    }
  }

  @override
  Future<CourseLifecycleDecision> getCourseLifecycle({
    required String courseId,
  }) async {
    try {
      final response = await _dio.get<Object?>(
        '/courses/${Uri.encodeComponent(courseId)}/lifecycle',
        options: await _authorizedOptions(),
      );

      return _CourseLifecycleDecisionJson(response.data).toDecision();
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        throw const CourseNotFoundException('Course not found');
      }
      rethrow;
    }
  }

  @override
  Future<CourseLifecycleDecision> archiveCourse({
    required String courseId,
  }) async {
    try {
      final response = await _dio.post<Object?>(
        '/courses/${Uri.encodeComponent(courseId)}/archive',
        options: await _authorizedOptions(),
      );

      return _CourseLifecycleDecisionJson(response.data).toDecision();
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        throw const CourseNotFoundException('Course not found');
      }
      if (error.response?.statusCode == 409) {
        throw CourseLifecycleBlockedException(
          _responseMessage(error) ?? 'Ce cours ne peut pas être archivé.',
        );
      }
      rethrow;
    }
  }

  @override
  Future<void> deleteCourse({required String courseId}) async {
    try {
      await _dio.delete<Object?>(
        '/courses/${Uri.encodeComponent(courseId)}',
        options: await _authorizedOptions(),
      );
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        throw const CourseNotFoundException('Course not found');
      }
      if (error.response?.statusCode == 409) {
        throw CourseLifecycleBlockedException(
          _responseMessage(error) ?? 'Ce cours ne peut pas être supprimé.',
        );
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
  Future<CourseQuestionBankReadiness> getQuestionBankReadiness({
    required String courseId,
    int questionCount = 10,
  }) async {
    try {
      final response = await _dio.get<Object?>(
        '/courses/${Uri.encodeComponent(courseId)}/question-bank/readiness',
        queryParameters: {'questionCount': questionCount},
        options: await _authorizedOptions(),
      );

      return _CourseQuestionBankReadinessJson(response.data).toReadiness();
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        throw const CourseNotFoundException('Course not found');
      }
      rethrow;
    }
  }

  @override
  Future<CourseQuestionBankReadiness> prepareQuestionBank({
    required String courseId,
    int questionCount = 10,
  }) async {
    try {
      final response = await _dio.post<Object?>(
        '/courses/${Uri.encodeComponent(courseId)}/question-bank/prepare',
        data: {'questionCount': questionCount},
        options: await _authorizedOptions(),
      );

      return _CourseQuestionBankReadinessJson(response.data).toReadiness();
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        throw const CourseNotFoundException('Course not found');
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
        final readiness = _responseReadiness(error);
        final message = readiness?.userMessage ?? _responseMessage(error);
        throw CourseQuickRevisionUnavailableException(
          _friendlyQuickRevisionMessage(
            message ?? 'Course quick revision is not available',
          ),
          readiness: readiness,
        );
      }
      rethrow;
    }
  }

  @override
  Future<ResumableCourseRevisionSession?> getResumableCourseRevisionSession({
    required String courseId,
  }) async {
    try {
      final response = await _dio.get<Object?>(
        '/courses/${Uri.encodeComponent(courseId)}/revision-sessions/resumable',
        options: await _authorizedOptions(),
      );

      if (response.data == null) {
        return null;
      }

      return _ResumableCourseRevisionSessionJson(response.data).toResumable();
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        throw const CourseNotFoundException('Course not found');
      }
      rethrow;
    }
  }

  @override
  Future<RevisionSessionHistoryResponse> getCourseRevisionSessionHistory({
    required String courseId,
    int limit = 5,
  }) async {
    try {
      final response = await _dio.get<Object?>(
        '/courses/${Uri.encodeComponent(courseId)}/revision-sessions/history',
        queryParameters: {'limit': limit},
        options: await _authorizedOptions(),
      );

      return _RevisionSessionHistoryResponseJson(response.data).toHistory();
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        throw const CourseNotFoundException('Course not found');
      }
      rethrow;
    }
  }

  @override
  Future<CourseRichClosedHistoryResponse> getCourseRichClosedHistory({
    required String courseId,
    int limit = 5,
  }) async {
    try {
      final response = await _dio.get<Object?>(
        '/courses/${Uri.encodeComponent(courseId)}/rich-closed/history',
        queryParameters: {'limit': limit},
        options: await _authorizedOptions(),
      );

      return _CourseRichClosedHistoryResponseJson(response.data).toHistory();
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        throw const CourseNotFoundException('Course not found');
      }
      rethrow;
    }
  }

  @override
  Future<CourseRichRevisionOptions> getRichRevisionOptions({
    required String courseId,
  }) async {
    try {
      final response = await _dio.get<Object?>(
        '/courses/${Uri.encodeComponent(courseId)}/rich-revision/options',
        options: await _authorizedOptions(),
      );

      return _CourseRichRevisionOptionsJson(response.data).toOptions();
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        throw const CourseNotFoundException('Course not found');
      }
      rethrow;
    }
  }

  @override
  Future<RichClosedExercise> startCourseRichRevision({
    required String courseId,
    required CourseRichRevisionConfig config,
  }) async {
    try {
      final response = await _dio.post<Object?>(
        '/courses/${Uri.encodeComponent(courseId)}/rich-revision/sessions',
        data: {
          'scopeKind': _richRevisionScopeKindJson(config.scopeKind),
          'scopeId': config.scopeId,
          'questionCount': config.questionCount,
          'complexityProfile': config.complexityProfile,
        },
        options: await _authorizedOptions(),
      );

      return RichClosedExercise.fromJson(response.data);
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        throw const CourseNotFoundException('Course not found');
      }
      if (error.response?.statusCode == 409) {
        throw CourseRequestException(
          _responseMessage(error) ?? 'QCM complet indisponible',
        );
      }
      rethrow;
    }
  }

  @override
  Future<CourseDeepRevisionOptions> getDeepRevisionOptions({
    required String courseId,
  }) async {
    try {
      final response = await _dio.get<Object?>(
        '/courses/${Uri.encodeComponent(courseId)}/deep-revision/options',
        options: await _authorizedOptions(),
      );

      return _CourseDeepRevisionOptionsJson(response.data).toOptions();
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        throw const CourseNotFoundException('Course not found');
      }
      rethrow;
    }
  }

  @override
  Future<CourseDeepRevisionSession> startCourseDeepRevision({
    required String courseId,
    required CourseDeepRevisionConfig config,
  }) async {
    try {
      final response = await _dio.post<Object?>(
        '/courses/${Uri.encodeComponent(courseId)}/deep-revision/sessions',
        data: {
          'scopeKind': _deepRevisionScopeKindJson(config.scopeKind),
          'scopeId': config.scopeId,
        },
        options: await _authorizedOptions(),
      );

      return _CourseDeepRevisionSessionJson(response.data).toSession();
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        throw const CourseNotFoundException('Course not found');
      }
      if (error.response?.statusCode == 409) {
        throw CourseRequestException(
          _responseMessage(error) ?? 'Révision approfondie indisponible',
        );
      }
      rethrow;
    }
  }

  @override
  Future<CourseDeepRevisionSubmitResponse> submitCourseDeepRevisionAnswer({
    required String courseId,
    required String sessionId,
    required String answer,
  }) async {
    try {
      final response = await _dio.post<Object?>(
        '/courses/${Uri.encodeComponent(courseId)}/deep-revision/sessions/${Uri.encodeComponent(sessionId)}/submit',
        data: {'answer': answer},
        options: await _authorizedOptions(),
      );

      return _CourseDeepRevisionSubmitResponseJson(response.data).toResponse();
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        throw const CourseNotFoundException('Course not found');
      }
      if (error.response?.statusCode == 400 ||
          error.response?.statusCode == 409) {
        throw CourseRequestException(
          _responseMessage(error) ??
              'Impossible de corriger cette réponse pour le moment.',
        );
      }
      rethrow;
    }
  }

  @override
  Future<CourseExamPreparationOptions> getExamPreparationOptions({
    required String courseId,
  }) async {
    try {
      final response = await _dio.get<Object?>(
        '/courses/${Uri.encodeComponent(courseId)}/exam-preparation/options',
        options: await _authorizedOptions(),
      );

      return _CourseExamPreparationOptionsJson(response.data).toOptions();
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        throw const CourseNotFoundException('Course not found');
      }
      rethrow;
    }
  }

  @override
  Future<RevisionSessionResponse> startCourseExamPreparation({
    required String courseId,
    required CourseExamPreparationConfig config,
  }) async {
    try {
      final response = await _dio.post<Object?>(
        '/courses/${Uri.encodeComponent(courseId)}/exam-preparation/sessions',
        data: {
          'scopeKind': _examPreparationScopeKindJson(config.scopeKind),
          'scopeId': config.scopeId,
          'questionCount': config.questionCount,
          'complexityProfile': config.complexityProfile,
        },
        options: await _authorizedOptions(),
      );

      return RevisionSessionResponseJson(response.data).toResponse();
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        throw const CourseNotFoundException('Course not found');
      }
      if (error.response?.statusCode == 409) {
        throw CourseRequestException(
          _responseMessage(error) ?? 'Préparation examen - QCM indisponible',
        );
      }
      rethrow;
    }
  }

  @override
  Future<RevisionSessionHistoryResponse> getCourseExamPreparationHistory({
    required String courseId,
    int limit = 5,
  }) async {
    try {
      final response = await _dio.get<Object?>(
        '/courses/${Uri.encodeComponent(courseId)}/exam-preparation/history',
        queryParameters: {'limit': limit},
        options: await _authorizedOptions(),
      );

      return _RevisionSessionHistoryResponseJson(response.data).toHistory();
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        throw const CourseNotFoundException('Course not found');
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

  CourseQuestionBankReadiness? _responseReadiness(DioException error) {
    final data = error.response?.data;
    if (data is Map<String, Object?>) {
      final readiness = data['readiness'];
      if (readiness is Map<String, Object?>) {
        return _CourseQuestionBankReadinessJson(readiness).toReadiness();
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

class _CourseLifecycleDecisionJson {
  const _CourseLifecycleDecisionJson(this.value);

  final Object? value;

  CourseLifecycleDecision toDecision() {
    final json = value;

    if (json is! Map<String, Object?>) {
      throw const FormatException('Invalid course lifecycle response');
    }

    final courseId = json['courseId'];
    final status = json['status'];
    final action = json['recommendedAction'];
    final canDelete = json['canDelete'];
    final canArchive = json['canArchive'];
    final canUpdate = json['canUpdate'];
    final blockingReasons = json['blockingReasons'];
    final userMessage = json['userMessage'];

    if (courseId is! String ||
        status is! String ||
        action is! String ||
        canDelete is! bool ||
        canArchive is! bool ||
        canUpdate is! bool ||
        blockingReasons is! List ||
        userMessage is! String) {
      throw const FormatException('Invalid course lifecycle response');
    }

    return CourseLifecycleDecision(
      courseId: courseId,
      status: _parseLifecycleStatus(status),
      recommendedAction: _parseLifecycleAction(action),
      canDelete: canDelete,
      canArchive: canArchive,
      canUpdate: canUpdate,
      blockingReasons: blockingReasons.whereType<String>().toList(),
      userMessage: userMessage,
    );
  }
}

class _CourseQuestionBankReadinessJson {
  const _CourseQuestionBankReadinessJson(this.value);

  final Object? value;

  CourseQuestionBankReadiness toReadiness() {
    final json = value;

    if (json is! Map<String, Object?>) {
      throw const FormatException('Invalid question bank readiness response');
    }

    final courseId = json['courseId'];
    final status = json['status'];
    final readyQuestionCount = json['readyQuestionCount'];
    final targetQuestionCount = json['targetQuestionCount'];
    final canStartQuickRevision = json['canStartQuickRevision'];
    final canPrepare = json['canPrepare'];
    final userMessage = json['userMessage'];

    if (courseId is! String ||
        status is! String ||
        readyQuestionCount is! int ||
        targetQuestionCount is! int ||
        canStartQuickRevision is! bool ||
        canPrepare is! bool ||
        userMessage is! String) {
      throw const FormatException('Invalid question bank readiness response');
    }

    return CourseQuestionBankReadiness(
      courseId: courseId,
      status: _parseQuestionBankReadinessStatus(status),
      readyQuestionCount: readyQuestionCount,
      targetQuestionCount: targetQuestionCount,
      canStartQuickRevision: canStartQuickRevision,
      canPrepare: canPrepare,
      userMessage: userMessage,
    );
  }
}

class _ResumableCourseRevisionSessionJson {
  const _ResumableCourseRevisionSessionJson(this.value);

  final Object? value;

  ResumableCourseRevisionSession toResumable() {
    final json = value;

    if (json is! Map<String, Object?>) {
      throw const FormatException(
        'Invalid resumable revision session response',
      );
    }

    final progress = json['progress'];
    final userMessage = json['userMessage'];

    if (progress is! Map<String, Object?> || userMessage is! String) {
      throw const FormatException(
        'Invalid resumable revision session response',
      );
    }

    final parsed = RevisionSessionResponseJson({
      'session': json['session'],
      'currentAction': json['currentAction'],
      'history': const <Object?>[],
    }).toResponse();

    return ResumableCourseRevisionSession(
      session: parsed.session,
      currentAction: parsed.currentAction,
      progress: _ResumableCourseRevisionProgressJson(progress).toProgress(),
      userMessage: userMessage,
    );
  }
}

class _ResumableCourseRevisionProgressJson {
  const _ResumableCourseRevisionProgressJson(this.value);

  final Map<String, Object?> value;

  ResumableCourseRevisionProgress toProgress() {
    final answeredQuestionCount = value['answeredQuestionCount'];
    final totalQuestionCount = value['totalQuestionCount'];

    if (answeredQuestionCount is! int || totalQuestionCount is! int) {
      throw const FormatException(
        'Invalid resumable revision session response',
      );
    }

    return ResumableCourseRevisionProgress(
      answeredQuestionCount: answeredQuestionCount,
      totalQuestionCount: totalQuestionCount,
    );
  }
}

class _RevisionSessionHistoryResponseJson {
  const _RevisionSessionHistoryResponseJson(this.value);

  final Object? value;

  RevisionSessionHistoryResponse toHistory() {
    final json = value;

    if (json is! Map<String, Object?>) {
      throw const FormatException('Invalid revision session history response');
    }

    final items = json['items'];
    if (items is! List) {
      throw const FormatException('Invalid revision session history response');
    }

    return RevisionSessionHistoryResponse(
      items: items
          .map((item) => _RevisionSessionHistoryItemJson(item).toItem())
          .toList(growable: false),
    );
  }
}

class _RevisionSessionHistoryItemJson {
  const _RevisionSessionHistoryItemJson(this.value);

  final Object? value;

  RevisionSessionHistoryItem toItem() {
    final json = value;

    if (json is! Map<String, Object?>) {
      throw const FormatException('Invalid revision session history response');
    }

    final course = json['course'];
    if (course is! Map<String, Object?>) {
      throw const FormatException('Invalid revision session history response');
    }

    final parsed = RevisionSessionResultJson({
      'session': json['session'],
      'summary': json['summary'],
      'knowledgeUnits': const <Object?>[],
      'corrections': const <Object?>[],
    }).toResult();

    return RevisionSessionHistoryItem(
      session: parsed.session,
      summary: parsed.summary,
      course: _RevisionSessionHistoryCourseJson(course).toCourse(),
    );
  }
}

class _RevisionSessionHistoryCourseJson {
  const _RevisionSessionHistoryCourseJson(this.value);

  final Map<String, Object?> value;

  RevisionSessionHistoryCourse toCourse() {
    final id = value['id'];
    final title = value['title'];

    if (id is! String || title is! String) {
      throw const FormatException('Invalid revision session history response');
    }

    return RevisionSessionHistoryCourse(id: id, title: title);
  }
}

class _CourseRichClosedHistoryResponseJson {
  const _CourseRichClosedHistoryResponseJson(this.value);

  final Object? value;

  CourseRichClosedHistoryResponse toHistory() {
    final json = value;

    if (json is! Map<String, Object?>) {
      throw const FormatException('Invalid rich closed history response');
    }

    final items = json['items'];
    if (items is! List) {
      throw const FormatException('Invalid rich closed history response');
    }

    return CourseRichClosedHistoryResponse(
      items: items
          .map((item) => _CourseRichClosedHistoryItemJson(item).toItem())
          .toList(growable: false),
    );
  }
}

class _CourseRichClosedHistoryItemJson {
  const _CourseRichClosedHistoryItemJson(this.value);

  final Object? value;

  CourseRichClosedHistoryItem toItem() {
    final json = value;

    if (json is! Map<String, Object?>) {
      throw const FormatException('Invalid rich closed history response');
    }

    final score = json['score'];
    final knowledgeUnit = json['knowledgeUnit'];
    final course = json['course'];

    if (score is! num ||
        knowledgeUnit is! Map<String, Object?> ||
        course is! Map<String, Object?>) {
      throw const FormatException('Invalid rich closed history response');
    }

    return CourseRichClosedHistoryItem(
      id: _requiredString(json['id'], 'Invalid rich closed history response'),
      sessionId: _requiredString(
        json['sessionId'],
        'Invalid rich closed history response',
      ),
      type: _requiredString(
        json['type'],
        'Invalid rich closed history response',
      ),
      status: _requiredString(
        json['status'],
        'Invalid rich closed history response',
      ),
      title: _requiredString(
        json['title'],
        'Invalid rich closed history response',
      ),
      subjectId: _requiredString(
        json['subjectId'],
        'Invalid rich closed history response',
      ),
      documentId: _optionalString(json['documentId']),
      knowledgeUnit: CourseRichClosedHistoryKnowledgeUnit(
        id: _requiredString(
          knowledgeUnit['id'],
          'Invalid rich closed history response',
        ),
        title: _requiredString(
          knowledgeUnit['title'],
          'Invalid rich closed history response',
        ),
      ),
      course: CourseRichClosedHistoryCourse(
        id: _requiredString(
          course['id'],
          'Invalid rich closed history response',
        ),
        title: _requiredString(
          course['title'],
          'Invalid rich closed history response',
        ),
      ),
      correctAnswers: _requiredInt(
        json['correctAnswers'],
        'Invalid rich closed history response',
      ),
      totalQuestions: _requiredInt(
        json['totalQuestions'],
        'Invalid rich closed history response',
      ),
      score: score.toDouble(),
      completedAt: _requiredDate(
        json['completedAt'],
        'Invalid rich closed history response',
      ),
      resultPath: _requiredString(
        json['resultPath'],
        'Invalid rich closed history response',
      ),
    );
  }
}

class _CourseRichRevisionOptionsJson {
  const _CourseRichRevisionOptionsJson(this.value);

  final Object? value;

  CourseRichRevisionOptions toOptions() {
    final json = value;

    if (json is! Map<String, Object?>) {
      throw const FormatException('Invalid rich revision response');
    }

    final course = json['course'];
    final readiness = json['readiness'];
    final scopeOptions = json['scopeOptions'];
    final questionCountOptions = json['questionCountOptions'];
    final supportedQuestionKinds = json['supportedQuestionKinds'];
    final complexityProfiles = json['complexityProfiles'];
    final nextStep = json['nextStep'];

    if (course is! Map<String, Object?> ||
        readiness is! Map<String, Object?> ||
        scopeOptions is! List ||
        questionCountOptions is! List ||
        supportedQuestionKinds is! List ||
        complexityProfiles is! List ||
        nextStep is! Map<String, Object?>) {
      throw const FormatException('Invalid rich revision response');
    }

    return CourseRichRevisionOptions(
      course: CourseRichRevisionCourse(
        id: _requiredString(course['id'], 'Invalid rich revision response'),
        title: _requiredString(
          course['title'],
          'Invalid rich revision response',
        ),
        subjectId: _requiredString(
          course['subjectId'],
          'Invalid rich revision response',
        ),
      ),
      readiness: _CourseRichRevisionReadinessJson(readiness).toReadiness(),
      scopeOptions: scopeOptions
          .map((item) => _CourseRichRevisionScopeOptionJson(item).toOption())
          .toList(growable: false),
      questionCountOptions: questionCountOptions
          .map((item) => _requiredInt(item, 'Invalid rich revision response'))
          .toList(growable: false),
      defaultQuestionCount: _optionalInt(json['defaultQuestionCount']),
      supportedQuestionKinds: supportedQuestionKinds
          .map(
            (item) => _requiredString(item, 'Invalid rich revision response'),
          )
          .toList(growable: false),
      complexityProfiles: complexityProfiles
          .map(
            (item) => _requiredString(item, 'Invalid rich revision response'),
          )
          .toList(growable: false),
      defaultConfig: json['defaultConfig'] == null
          ? null
          : _CourseRichRevisionConfigJson(json['defaultConfig']).toConfig(),
      nextStep: CourseRichRevisionNextStep(
        kind: _requiredString(
          nextStep['kind'],
          'Invalid rich revision response',
        ),
        userMessage: _requiredString(
          nextStep['userMessage'],
          'Invalid rich revision response',
        ),
      ),
    );
  }
}

class _CourseRichRevisionReadinessJson {
  const _CourseRichRevisionReadinessJson(this.value);

  final Map<String, Object?> value;

  CourseRichRevisionReadiness toReadiness() {
    final blockers = value['blockers'];
    if (blockers is! List) {
      throw const FormatException('Invalid rich revision response');
    }

    return CourseRichRevisionReadiness(
      canStart: _requiredBool(
        value['canStart'],
        'Invalid rich revision response',
      ),
      state: _parseRichRevisionReadinessState(
        _requiredString(value['state'], 'Invalid rich revision response'),
      ),
      userMessage: _requiredString(
        value['userMessage'],
        'Invalid rich revision response',
      ),
      blockers: blockers
          .map(
            (item) => _requiredString(item, 'Invalid rich revision response'),
          )
          .toList(growable: false),
      readySourceCount: _requiredInt(
        value['readySourceCount'],
        'Invalid rich revision response',
      ),
      readyKnowledgeUnitCount: _requiredInt(
        value['readyKnowledgeUnitCount'],
        'Invalid rich revision response',
      ),
    );
  }
}

class _CourseRichRevisionScopeOptionJson {
  const _CourseRichRevisionScopeOptionJson(this.value);

  final Object? value;

  CourseRichRevisionScopeOption toOption() {
    final json = value;

    if (json is! Map<String, Object?>) {
      throw const FormatException('Invalid rich revision response');
    }

    return CourseRichRevisionScopeOption(
      kind: _parseRichRevisionScopeKind(
        _requiredString(json['kind'], 'Invalid rich revision response'),
      ),
      id: _requiredString(json['id'], 'Invalid rich revision response'),
      documentId: _requiredString(
        json['documentId'],
        'Invalid rich revision response',
      ),
      label: _requiredString(json['label'], 'Invalid rich revision response'),
      sourceLabel: _requiredString(
        json['sourceLabel'],
        'Invalid rich revision response',
      ),
      canSelect: _requiredBool(
        json['canSelect'],
        'Invalid rich revision response',
      ),
    );
  }
}

class _CourseRichRevisionConfigJson {
  const _CourseRichRevisionConfigJson(this.value);

  final Object? value;

  CourseRichRevisionConfig toConfig() {
    final json = value;

    if (json is! Map<String, Object?>) {
      throw const FormatException('Invalid rich revision response');
    }

    return CourseRichRevisionConfig(
      scopeKind: _parseRichRevisionScopeKind(
        _requiredString(json['scopeKind'], 'Invalid rich revision response'),
      ),
      scopeId: _requiredString(
        json['scopeId'],
        'Invalid rich revision response',
      ),
      questionCount: _requiredInt(
        json['questionCount'],
        'Invalid rich revision response',
      ),
      complexityProfile: _requiredString(
        json['complexityProfile'],
        'Invalid rich revision response',
      ),
    );
  }
}

class _CourseDeepRevisionOptionsJson {
  const _CourseDeepRevisionOptionsJson(this.value);

  final Object? value;

  CourseDeepRevisionOptions toOptions() {
    final json = value;

    if (json is! Map<String, Object?>) {
      throw const FormatException('Invalid deep revision response');
    }

    final course = json['course'];
    final readiness = json['readiness'];
    final scopeOptions = json['scopeOptions'];
    final answerGuidelines = json['answerGuidelines'];
    final nextStep = json['nextStep'];

    if (course is! Map<String, Object?> ||
        readiness is! Map<String, Object?> ||
        scopeOptions is! List ||
        answerGuidelines is! Map<String, Object?> ||
        nextStep is! Map<String, Object?>) {
      throw const FormatException('Invalid deep revision response');
    }

    return CourseDeepRevisionOptions(
      course: CourseDeepRevisionCourse(
        id: _requiredString(course['id'], 'Invalid deep revision response'),
        title: _requiredString(
          course['title'],
          'Invalid deep revision response',
        ),
        subjectId: _requiredString(
          course['subjectId'],
          'Invalid deep revision response',
        ),
      ),
      readiness: _CourseDeepRevisionReadinessJson(readiness).toReadiness(),
      scopeOptions: scopeOptions
          .map((item) => _CourseDeepRevisionScopeOptionJson(item).toOption())
          .toList(growable: false),
      answerGuidelines: _CourseDeepRevisionAnswerGuidelinesJson(
        answerGuidelines,
      ).toGuidelines(),
      defaultConfig: json['defaultConfig'] == null
          ? null
          : _CourseDeepRevisionConfigJson(json['defaultConfig']).toConfig(),
      nextStep: CourseDeepRevisionNextStep(
        kind: _requiredString(
          nextStep['kind'],
          'Invalid deep revision response',
        ),
        userMessage: _requiredString(
          nextStep['userMessage'],
          'Invalid deep revision response',
        ),
      ),
    );
  }
}

class _CourseDeepRevisionReadinessJson {
  const _CourseDeepRevisionReadinessJson(this.value);

  final Map<String, Object?> value;

  CourseDeepRevisionReadiness toReadiness() {
    final blockers = value['blockers'];
    if (blockers is! List) {
      throw const FormatException('Invalid deep revision response');
    }

    return CourseDeepRevisionReadiness(
      canStart: _requiredBool(
        value['canStart'],
        'Invalid deep revision response',
      ),
      state: _parseDeepRevisionReadinessState(
        _requiredString(value['state'], 'Invalid deep revision response'),
      ),
      userMessage: _requiredString(
        value['userMessage'],
        'Invalid deep revision response',
      ),
      blockers: blockers
          .map(
            (item) => _requiredString(item, 'Invalid deep revision response'),
          )
          .toList(growable: false),
      readySourceCount: _requiredInt(
        value['readySourceCount'],
        'Invalid deep revision response',
      ),
      readyKnowledgeUnitCount: _requiredInt(
        value['readyKnowledgeUnitCount'],
        'Invalid deep revision response',
      ),
    );
  }
}

class _CourseDeepRevisionScopeOptionJson {
  const _CourseDeepRevisionScopeOptionJson(this.value);

  final Object? value;

  CourseDeepRevisionScopeOption toOption() {
    final json = value;

    if (json is! Map<String, Object?>) {
      throw const FormatException('Invalid deep revision response');
    }

    return CourseDeepRevisionScopeOption(
      kind: _parseDeepRevisionScopeKind(
        _requiredString(json['kind'], 'Invalid deep revision response'),
      ),
      id: _requiredString(json['id'], 'Invalid deep revision response'),
      documentId: _requiredString(
        json['documentId'],
        'Invalid deep revision response',
      ),
      label: _requiredString(json['label'], 'Invalid deep revision response'),
      sourceLabel: _requiredString(
        json['sourceLabel'],
        'Invalid deep revision response',
      ),
      canSelect: _requiredBool(
        json['canSelect'],
        'Invalid deep revision response',
      ),
    );
  }
}

class _CourseDeepRevisionAnswerGuidelinesJson {
  const _CourseDeepRevisionAnswerGuidelinesJson(this.value);

  final Map<String, Object?> value;

  CourseDeepRevisionAnswerGuidelines toGuidelines() {
    return CourseDeepRevisionAnswerGuidelines(
      minLength: _requiredInt(
        value['minLength'],
        'Invalid deep revision response',
      ),
      maxLength: _requiredInt(
        value['maxLength'],
        'Invalid deep revision response',
      ),
      userMessage: _requiredString(
        value['userMessage'] ??
            'Rédige une réponse structurée avec tes propres mots.',
        'Invalid deep revision response',
      ),
    );
  }
}

class _CourseDeepRevisionConfigJson {
  const _CourseDeepRevisionConfigJson(this.value);

  final Object? value;

  CourseDeepRevisionConfig toConfig() {
    final json = value;

    if (json is! Map<String, Object?>) {
      throw const FormatException('Invalid deep revision response');
    }

    return CourseDeepRevisionConfig(
      scopeKind: _parseDeepRevisionScopeKind(
        _requiredString(json['scopeKind'], 'Invalid deep revision response'),
      ),
      scopeId: _requiredString(
        json['scopeId'],
        'Invalid deep revision response',
      ),
    );
  }
}

class _CourseDeepRevisionSessionJson {
  const _CourseDeepRevisionSessionJson(this.value);

  final Object? value;

  CourseDeepRevisionSession toSession() {
    final json = value;

    if (json is! Map<String, Object?>) {
      throw const FormatException('Invalid deep revision session response');
    }

    final session = json['session'];
    final question = json['question'];
    final scope = json['scope'];
    final answerGuidelines = json['answerGuidelines'];

    if (session is! Map<String, Object?> ||
        question is! Map<String, Object?> ||
        scope is! Map<String, Object?> ||
        answerGuidelines is! Map<String, Object?>) {
      throw const FormatException('Invalid deep revision session response');
    }

    return CourseDeepRevisionSession(
      session: _CourseDeepRevisionSessionSummaryJson(
        session,
      ).toSessionSummary(),
      question: _OpenQuestionJson(question).toQuestion(),
      scope: _CourseDeepRevisionScopeJson(scope).toScope(),
      answerGuidelines: _CourseDeepRevisionAnswerGuidelinesJson(
        answerGuidelines,
      ).toGuidelines(),
    );
  }
}

class _CourseDeepRevisionSubmitResponseJson {
  const _CourseDeepRevisionSubmitResponseJson(this.value);

  final Object? value;

  CourseDeepRevisionSubmitResponse toResponse() {
    final json = value;

    if (json is! Map<String, Object?>) {
      throw const FormatException('Invalid deep revision submit response');
    }

    final session = json['session'];
    final evaluation = json['evaluation'];

    if (session is! Map<String, Object?> ||
        evaluation is! Map<String, Object?>) {
      throw const FormatException('Invalid deep revision submit response');
    }

    return CourseDeepRevisionSubmitResponse(
      session: _CourseDeepRevisionSessionSummaryJson(
        session,
      ).toSessionSummary(),
      evaluation: _OpenAnswerEvaluationJson(evaluation).toEvaluation(),
    );
  }
}

class _CourseDeepRevisionSessionSummaryJson {
  const _CourseDeepRevisionSessionSummaryJson(this.value);

  final Map<String, Object?> value;

  CourseDeepRevisionSessionSummary toSessionSummary() {
    return CourseDeepRevisionSessionSummary(
      id: _requiredString(
        value['id'],
        'Invalid deep revision session response',
      ),
      mode: _requiredString(
        value['mode'],
        'Invalid deep revision session response',
      ),
      status: _requiredString(
        value['status'],
        'Invalid deep revision session response',
      ),
      courseId: _requiredString(
        value['courseId'],
        'Invalid deep revision session response',
      ),
    );
  }
}

class _CourseDeepRevisionScopeJson {
  const _CourseDeepRevisionScopeJson(this.value);

  final Map<String, Object?> value;

  CourseDeepRevisionScope toScope() {
    return CourseDeepRevisionScope(
      kind: _parseDeepRevisionScopeKind(
        _requiredString(
          value['kind'],
          'Invalid deep revision session response',
        ),
      ),
      id: _requiredString(
        value['id'],
        'Invalid deep revision session response',
      ),
      label: _requiredString(
        value['label'],
        'Invalid deep revision session response',
      ),
      sourceLabel: _requiredString(
        value['sourceLabel'],
        'Invalid deep revision session response',
      ),
    );
  }
}

class _OpenQuestionJson {
  const _OpenQuestionJson(this.value);

  final Map<String, Object?> value;

  OpenQuestion toQuestion() {
    final id = value['id'];
    final prompt = value['prompt'];
    final instructions = value['instructions'];
    final maxAnswerLength = value['maxAnswerLength'];
    final sources = value['sources'];

    if (id is! String || prompt is! String || maxAnswerLength is! int) {
      throw const FormatException('Invalid deep revision open question');
    }

    return OpenQuestion(
      id: id,
      prompt: prompt,
      instructions: instructions is String ? instructions : null,
      maxAnswerLength: maxAnswerLength,
      sources: sources is List
          ? sources
                .map((source) => _OpenQuestionSourceJson(source).toSource())
                .toList(growable: false)
          : const [],
    );
  }
}

class _OpenQuestionSourceJson {
  const _OpenQuestionSourceJson(this.value);

  final Object? value;

  OpenQuestionSource toSource() {
    final json = value;

    if (json is! Map<String, Object?>) {
      throw const FormatException('Invalid deep revision open question source');
    }

    final chunkId = json['chunkId'];
    final pageNumber = json['pageNumber'];
    final index = json['index'];

    if (chunkId is! String || index is! int) {
      throw const FormatException('Invalid deep revision open question source');
    }

    return OpenQuestionSource(
      chunkId: chunkId,
      pageNumber: pageNumber is int ? pageNumber : null,
      index: index,
    );
  }
}

class _OpenAnswerEvaluationJson {
  const _OpenAnswerEvaluationJson(this.value);

  final Map<String, Object?> value;

  OpenAnswerEvaluation toEvaluation() {
    final id = value['id'];
    final status = value['status'];
    final score = value['score'];
    final maxScore = value['maxScore'];
    final feedback = value['feedback'];
    final presentPoints = value['presentPoints'];
    final missingPoints = value['missingPoints'];
    final errors = value['errors'];
    final modelAnswer = value['modelAnswer'];
    final advice = value['advice'];
    final sources = value['sources'];

    if (id is! String || status is! String) {
      throw const FormatException('Invalid deep revision evaluation response');
    }

    return OpenAnswerEvaluation(
      id: id,
      status: _parseOpenAnswerEvaluationStatus(status),
      score: score is num ? score.toDouble() : null,
      maxScore: maxScore is num ? maxScore.toDouble() : null,
      feedback: feedback is String ? feedback : null,
      presentPoints: presentPoints is List
          ? _stringList(
              presentPoints,
              'Invalid deep revision evaluation response',
            )
          : const [],
      missingPoints: missingPoints is List
          ? _stringList(
              missingPoints,
              'Invalid deep revision evaluation response',
            )
          : const [],
      errors: errors is List
          ? _stringList(errors, 'Invalid deep revision evaluation response')
          : const [],
      modelAnswer: modelAnswer is String ? modelAnswer : null,
      advice: advice is String ? advice : null,
      sources: sources is List
          ? sources
                .map((source) => _OpenAnswerSourceJson(source).toSource())
                .toList(growable: false)
          : const [],
    );
  }
}

class _OpenAnswerSourceJson {
  const _OpenAnswerSourceJson(this.value);

  final Object? value;

  OpenAnswerCorrectionSource toSource() {
    final json = value;

    if (json is! Map<String, Object?>) {
      throw const FormatException('Invalid deep revision evaluation source');
    }

    final chunkId = json['chunkId'];
    final text = json['text'];
    final pageNumber = json['pageNumber'];
    final index = json['index'];

    if (chunkId is! String || text is! String || index is! int) {
      throw const FormatException('Invalid deep revision evaluation source');
    }

    return OpenAnswerCorrectionSource(
      chunkId: chunkId,
      text: text,
      pageNumber: pageNumber is int ? pageNumber : null,
      index: index,
    );
  }
}

class _CourseExamPreparationOptionsJson {
  const _CourseExamPreparationOptionsJson(this.value);

  final Object? value;

  CourseExamPreparationOptions toOptions() {
    final json = value;

    if (json is! Map<String, Object?>) {
      throw const FormatException('Invalid exam preparation response');
    }

    final course = json['course'];
    final readiness = json['readiness'];
    final scopeOptions = json['scopeOptions'];
    final questionCountOptions = json['questionCountOptions'];
    final supportedQuestionKinds = json['supportedQuestionKinds'];
    final nextStep = json['nextStep'];

    if (course is! Map<String, Object?> ||
        readiness is! Map<String, Object?> ||
        scopeOptions is! List ||
        questionCountOptions is! List ||
        supportedQuestionKinds is! List ||
        nextStep is! Map<String, Object?>) {
      throw const FormatException('Invalid exam preparation response');
    }

    return CourseExamPreparationOptions(
      course: CourseExamPreparationCourse(
        id: _requiredString(course['id'], 'Invalid exam preparation response'),
        title: _requiredString(
          course['title'],
          'Invalid exam preparation response',
        ),
        subjectId: _requiredString(
          course['subjectId'],
          'Invalid exam preparation response',
        ),
      ),
      readiness: _CourseExamPreparationReadinessJson(readiness).toReadiness(),
      scopeOptions: scopeOptions
          .map((item) => _CourseExamPreparationScopeOptionJson(item).toOption())
          .toList(growable: false),
      questionCountOptions: questionCountOptions
          .map(
            (item) => _requiredInt(item, 'Invalid exam preparation response'),
          )
          .toList(growable: false),
      defaultQuestionCount: _optionalInt(json['defaultQuestionCount']),
      supportedQuestionKinds: supportedQuestionKinds
          .map(
            (item) =>
                _requiredString(item, 'Invalid exam preparation response'),
          )
          .toList(growable: false),
      defaultConfig: json['defaultConfig'] == null
          ? null
          : _CourseExamPreparationConfigJson(json['defaultConfig']).toConfig(),
      nextStep: CourseExamPreparationNextStep(
        kind: _requiredString(
          nextStep['kind'],
          'Invalid exam preparation response',
        ),
        userMessage: _requiredString(
          nextStep['userMessage'],
          'Invalid exam preparation response',
        ),
      ),
    );
  }
}

class _CourseExamPreparationReadinessJson {
  const _CourseExamPreparationReadinessJson(this.value);

  final Map<String, Object?> value;

  CourseExamPreparationReadiness toReadiness() {
    final blockers = value['blockers'];
    if (blockers is! List) {
      throw const FormatException('Invalid exam preparation response');
    }

    return CourseExamPreparationReadiness(
      canPrepare: _requiredBool(
        value['canPrepare'],
        'Invalid exam preparation response',
      ),
      state: _parseExamPreparationReadinessState(
        _requiredString(value['state'], 'Invalid exam preparation response'),
      ),
      userMessage: _requiredString(
        value['userMessage'],
        'Invalid exam preparation response',
      ),
      blockers: blockers
          .map(
            (item) =>
                _requiredString(item, 'Invalid exam preparation response'),
          )
          .toList(growable: false),
      readySourceCount: _requiredInt(
        value['readySourceCount'],
        'Invalid exam preparation response',
      ),
      readyKnowledgeUnitCount: _requiredInt(
        value['readyKnowledgeUnitCount'],
        'Invalid exam preparation response',
      ),
      availableQuestionCount: _requiredInt(
        value['availableQuestionCount'],
        'Invalid exam preparation response',
      ),
    );
  }
}

class _CourseExamPreparationScopeOptionJson {
  const _CourseExamPreparationScopeOptionJson(this.value);

  final Object? value;

  CourseExamPreparationScopeOption toOption() {
    final json = value;

    if (json is! Map<String, Object?>) {
      throw const FormatException('Invalid exam preparation response');
    }

    return CourseExamPreparationScopeOption(
      kind: _parseExamPreparationScopeKind(
        _requiredString(json['kind'], 'Invalid exam preparation response'),
      ),
      id: _requiredString(json['id'], 'Invalid exam preparation response'),
      label: _requiredString(
        json['label'],
        'Invalid exam preparation response',
      ),
      readyQuestionCount: _requiredInt(
        json['readyQuestionCount'],
        'Invalid exam preparation response',
      ),
      readyKnowledgeUnitCount: _requiredInt(
        json['readyKnowledgeUnitCount'],
        'Invalid exam preparation response',
      ),
      canSelect: _requiredBool(
        json['canSelect'],
        'Invalid exam preparation response',
      ),
    );
  }
}

class _CourseExamPreparationConfigJson {
  const _CourseExamPreparationConfigJson(this.value);

  final Object? value;

  CourseExamPreparationConfig toConfig() {
    final json = value;

    if (json is! Map<String, Object?>) {
      throw const FormatException('Invalid exam preparation response');
    }

    return CourseExamPreparationConfig(
      scopeKind: _parseExamPreparationScopeKind(
        _requiredString(json['scopeKind'], 'Invalid exam preparation response'),
      ),
      scopeId: _requiredString(
        json['scopeId'],
        'Invalid exam preparation response',
      ),
      questionCount: _requiredInt(
        json['questionCount'],
        'Invalid exam preparation response',
      ),
      complexityProfile: _requiredString(
        json['complexityProfile'],
        'Invalid exam preparation response',
      ),
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

CourseQuestionBankReadinessStatus _parseQuestionBankReadinessStatus(
  String value,
) {
  return switch (value) {
    'NO_READY_SOURCE' => CourseQuestionBankReadinessStatus.noReadySource,
    'NO_KNOWLEDGE_UNITS' => CourseQuestionBankReadinessStatus.noKnowledgeUnits,
    'NOT_PREPARED' => CourseQuestionBankReadinessStatus.notPrepared,
    'PREPARING' => CourseQuestionBankReadinessStatus.preparing,
    'READY' => CourseQuestionBankReadinessStatus.ready,
    'FAILED' => CourseQuestionBankReadinessStatus.failed,
    _ => CourseQuestionBankReadinessStatus.unknown,
  };
}

String _friendlyQuickRevisionMessage(String message) {
  return switch (message) {
    'Course quick revision questions are being prepared' ||
    'COURSE_QUICK_REVISION_QUESTIONS_PREPARING' =>
      'Les questions sont en préparation. Réessaie dans un instant.',
    'Course has no ready knowledge unit' =>
      "Aucune notion exploitable n'a encore été trouvée pour ce cours.",
    'Course has no ready source' =>
      'Ajoute une source prête avant de lancer la révision rapide.',
    'Course quick revision generation failed' =>
      "Les questions n'ont pas pu être préparées pour le moment.",
    _ => message,
  };
}

LifecycleStatus _parseLifecycleStatus(String value) {
  return switch (value) {
    'ACTIVE' => LifecycleStatus.active,
    'ARCHIVED' => LifecycleStatus.archived,
    _ => throw const FormatException('Unknown lifecycle status'),
  };
}

LifecycleRecommendedAction _parseLifecycleAction(String value) {
  return switch (value) {
    'DELETE' => LifecycleRecommendedAction.delete,
    'ARCHIVE' => LifecycleRecommendedAction.archive,
    'BLOCK' => LifecycleRecommendedAction.block,
    _ => throw const FormatException('Unknown lifecycle action'),
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

String _requiredString(Object? value, String message) {
  if (value is String && value.trim().isNotEmpty) {
    return value.trim();
  }

  throw FormatException(message);
}

String? _optionalString(Object? value) {
  if (value == null) {
    return null;
  }

  return _requiredString(value, 'Invalid optional string response');
}

int _requiredInt(Object? value, String message) {
  if (value is int) {
    return value;
  }

  throw FormatException(message);
}

int? _optionalInt(Object? value) {
  if (value == null) {
    return null;
  }

  return _requiredInt(value, 'Invalid optional int response');
}

bool _requiredBool(Object? value, String message) {
  if (value is bool) {
    return value;
  }

  throw FormatException(message);
}

List<String> _stringList(List<Object?> values, String errorMessage) {
  return values
      .map((value) {
        if (value is String) {
          return value;
        }

        throw FormatException(errorMessage);
      })
      .toList(growable: false);
}

DateTime _requiredDate(Object? value, String message) {
  final parsed = _parseOptionalDate(value);
  if (parsed == null) {
    throw FormatException(message);
  }

  return parsed;
}

CourseExamPreparationReadinessState _parseExamPreparationReadinessState(
  String value,
) {
  return switch (value) {
    'READY' => CourseExamPreparationReadinessState.ready,
    'PARTIALLY_READY' => CourseExamPreparationReadinessState.partiallyReady,
    'NOT_READY' => CourseExamPreparationReadinessState.notReady,
    'BLOCKED' => CourseExamPreparationReadinessState.blocked,
    _ => CourseExamPreparationReadinessState.unknown,
  };
}

CourseRichRevisionReadinessState _parseRichRevisionReadinessState(
  String value,
) {
  return switch (value) {
    'READY' => CourseRichRevisionReadinessState.ready,
    'PARTIALLY_READY' => CourseRichRevisionReadinessState.partiallyReady,
    'NOT_READY' => CourseRichRevisionReadinessState.notReady,
    'BLOCKED' => CourseRichRevisionReadinessState.blocked,
    _ => CourseRichRevisionReadinessState.unknown,
  };
}

CourseDeepRevisionReadinessState _parseDeepRevisionReadinessState(
  String value,
) {
  return switch (value) {
    'READY' => CourseDeepRevisionReadinessState.ready,
    'NOT_READY' => CourseDeepRevisionReadinessState.notReady,
    'BLOCKED' => CourseDeepRevisionReadinessState.blocked,
    _ => CourseDeepRevisionReadinessState.unknown,
  };
}

CourseRichRevisionScopeKind _parseRichRevisionScopeKind(String value) {
  return switch (value) {
    'knowledge_unit' => CourseRichRevisionScopeKind.knowledgeUnit,
    _ => CourseRichRevisionScopeKind.unknown,
  };
}

CourseDeepRevisionScopeKind _parseDeepRevisionScopeKind(String value) {
  return switch (value) {
    'knowledge_unit' => CourseDeepRevisionScopeKind.knowledgeUnit,
    _ => CourseDeepRevisionScopeKind.unknown,
  };
}

String _richRevisionScopeKindJson(CourseRichRevisionScopeKind value) {
  return switch (value) {
    CourseRichRevisionScopeKind.knowledgeUnit => 'knowledge_unit',
    CourseRichRevisionScopeKind.unknown => 'unknown',
  };
}

String _deepRevisionScopeKindJson(CourseDeepRevisionScopeKind value) {
  return switch (value) {
    CourseDeepRevisionScopeKind.knowledgeUnit => 'knowledge_unit',
    CourseDeepRevisionScopeKind.unknown => 'unknown',
  };
}

CourseExamPreparationScopeKind _parseExamPreparationScopeKind(String value) {
  return switch (value) {
    'course' => CourseExamPreparationScopeKind.course,
    'source' => CourseExamPreparationScopeKind.source,
    _ => CourseExamPreparationScopeKind.unknown,
  };
}

String _examPreparationScopeKindJson(CourseExamPreparationScopeKind value) {
  return switch (value) {
    CourseExamPreparationScopeKind.course => 'course',
    CourseExamPreparationScopeKind.source => 'source',
    CourseExamPreparationScopeKind.unknown => 'unknown',
  };
}

OpenAnswerEvaluationStatus _parseOpenAnswerEvaluationStatus(String status) {
  return switch (status) {
    'PENDING' => OpenAnswerEvaluationStatus.pending,
    'READY' => OpenAnswerEvaluationStatus.ready,
    'FAILED' => OpenAnswerEvaluationStatus.failed,
    _ => throw const FormatException('Invalid deep revision evaluation status'),
  };
}
