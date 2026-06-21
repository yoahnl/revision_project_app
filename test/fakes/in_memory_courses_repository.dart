import 'dart:typed_data';

import 'package:Neralune/features/courses/domain/course_models.dart';
import 'package:Neralune/features/courses/domain/courses_repository.dart';
import 'package:Neralune/features/documents/domain/revision_document.dart';
import 'package:Neralune/features/revision_sessions/domain/revision_session.dart';

class InMemoryCoursesRepository implements CoursesRepository {
  final Map<String, List<CourseListItem>> coursesBySubject = {};
  final Map<String, CourseDetail> detailsByCourse = {};
  final Map<String, CourseProgress> progressByCourse = {};
  final Map<String, SubjectProgress> progressBySubject = {};
  final Map<String, RevisionSheet?> revisionSheetsByCourse = {};
  final Map<String, RevisionSheet> generatedRevisionSheetsByCourse = {};
  final Map<String, Object> revisionSheetErrorsByCourse = {};
  int createCount = 0;
  int listCoursesCount = 0;
  int getCourseCount = 0;
  int getCourseProgressCount = 0;
  int getSubjectProgressCount = 0;
  int getRevisionSheetCount = 0;
  int generateRevisionSheetCount = 0;
  int uploadCount = 0;
  int deleteDocumentCount = 0;
  int startQuickRevisionCount = 0;
  String? lastUploadedCourseId;
  String? lastUploadedFileName;
  Uint8List? lastUploadedBytes;
  String? lastDeletedCourseId;
  String? lastDeletedDocumentId;
  String? lastQuickRevisionCourseId;
  int? lastQuickRevisionQuestionCount;
  Object? uploadError;
  Object? deleteDocumentError;
  Object? quickRevisionError;
  RevisionSessionResponse? quickRevisionResponse;
  Duration uploadDelay = Duration.zero;
  Duration quickRevisionDelay = Duration.zero;

  @override
  Future<List<CourseListItem>> listCourses({required String subjectId}) async {
    listCoursesCount += 1;
    return List.unmodifiable(coursesBySubject[subjectId] ?? const []);
  }

  @override
  Future<CourseDetail> getCourse({required String courseId}) async {
    getCourseCount += 1;
    final detail = detailsByCourse[courseId];

    if (detail == null) {
      throw const CourseNotFoundException('Course not found');
    }

    return detail;
  }

  @override
  Future<CourseListItem> createCourse({
    required String subjectId,
    required CreateCourseInput input,
  }) async {
    createCount += 1;
    final course = CourseListItem(
      id: 'course-$createCount',
      subjectId: subjectId,
      title: input.title,
      description: input.description,
      chapterLabel: input.chapterLabel,
      estimatedMinutes: input.estimatedMinutes,
      sourceCount: 0,
      readySourceCount: 0,
      processingSourceCount: 0,
      failedSourceCount: 0,
    );
    coursesBySubject.putIfAbsent(subjectId, () => []).add(course);
    detailsByCourse[course.id] = CourseDetail(
      course: course,
      subject: CourseSubjectSummary(id: subjectId, name: 'Matière réelle'),
      sources: const [],
    );

    return course;
  }

  @override
  Future<CourseDocument> uploadCoursePdf({
    required String courseId,
    required String fileName,
    required Uint8List bytes,
  }) async {
    if (uploadDelay > Duration.zero) {
      await Future<void>.delayed(uploadDelay);
    }

    final error = uploadError;
    if (error != null) {
      throw error;
    }

    final detail = detailsByCourse[courseId];
    if (detail == null) {
      throw const CourseNotFoundException('Course not found');
    }

    uploadCount += 1;
    lastUploadedCourseId = courseId;
    lastUploadedFileName = fileName;
    lastUploadedBytes = bytes;

    final document = CourseDocument(
      id: 'document-$uploadCount',
      courseId: courseId,
      documentId: 'document-$uploadCount',
      fileName: fileName,
      status: CourseDocumentStatus.uploaded,
      createdAt: DateTime.utc(2026, 6, 18, 12),
      updatedAt: DateTime.utc(2026, 6, 18, 12),
    );
    detailsByCourse[courseId] = CourseDetail(
      course: detail.course,
      subject: detail.subject,
      sources: [...detail.sources, document],
      progress: detail.progress,
    );

    return document;
  }

  @override
  Future<void> deleteCourseDocument({
    required String courseId,
    required String documentId,
  }) async {
    final error = deleteDocumentError;
    if (error != null) {
      throw error;
    }

    final detail = detailsByCourse[courseId];
    if (detail == null) {
      throw const CourseNotFoundException('Course not found');
    }

    final remainingSources = detail.sources
        .where((source) => source.documentId != documentId)
        .toList(growable: false);
    if (remainingSources.length == detail.sources.length) {
      throw const CourseNotFoundException('Course source not found');
    }

    deleteDocumentCount += 1;
    lastDeletedCourseId = courseId;
    lastDeletedDocumentId = documentId;
    detailsByCourse[courseId] = CourseDetail(
      course: detail.course,
      subject: detail.subject,
      sources: remainingSources,
      progress: detail.progress,
    );
  }

  @override
  Future<RevisionSheet?> getCourseRevisionSheet({
    required String courseId,
  }) async {
    getRevisionSheetCount += 1;
    final error = revisionSheetErrorsByCourse[courseId];
    if (error != null) {
      throw error;
    }

    return revisionSheetsByCourse[courseId];
  }

  @override
  Future<RevisionSheet> generateCourseRevisionSheet({
    required String courseId,
  }) async {
    generateRevisionSheetCount += 1;
    final error = revisionSheetErrorsByCourse[courseId];
    if (error != null) {
      throw error;
    }

    final existing = revisionSheetsByCourse[courseId];
    if (existing != null) {
      return existing;
    }

    final generated = generatedRevisionSheetsByCourse[courseId];
    if (generated != null) {
      revisionSheetsByCourse[courseId] = generated;
      return generated;
    }

    throw const CourseRevisionSheetNotReadyException(
      'Course has no ready source',
    );
  }

  @override
  Future<RevisionSessionResponse> startCourseQuickRevision({
    required String courseId,
    int questionCount = 10,
  }) async {
    if (quickRevisionDelay > Duration.zero) {
      await Future<void>.delayed(quickRevisionDelay);
    }

    final error = quickRevisionError;
    if (error != null) {
      throw error;
    }

    if (!detailsByCourse.containsKey(courseId)) {
      throw const CourseNotFoundException('Course not found');
    }

    startQuickRevisionCount += 1;
    lastQuickRevisionCourseId = courseId;
    lastQuickRevisionQuestionCount = questionCount;

    return quickRevisionResponse ?? quickRevisionSessionResponse(courseId);
  }

  @override
  Future<CourseProgress> getCourseProgress({required String courseId}) {
    getCourseProgressCount += 1;
    final progress = progressByCourse[courseId];

    if (progress == null) {
      throw const CourseNotFoundException('Course not found');
    }

    return Future.value(progress);
  }

  @override
  Future<SubjectProgress> getSubjectProgress({required String subjectId}) {
    getSubjectProgressCount += 1;
    final progress = progressBySubject[subjectId];

    if (progress == null) {
      throw const CourseNotFoundException('Course subject not found');
    }

    return Future.value(progress);
  }
}

RevisionSessionResponse quickRevisionSessionResponse(String courseId) {
  return RevisionSessionResponse(
    session: RevisionSession(
      id: 'revision-session-1',
      status: RevisionSessionStatus.started,
      mode: RevisionSessionMode.quick,
      subjectId: 'subject-1',
      courseId: courseId,
      documentId: 'document-1',
      knowledgeUnitId: 'knowledge-unit-1',
      createdAt: DateTime.utc(2026, 6, 18, 12),
      completedAt: null,
    ),
    currentAction: const RevisionSessionAction(
      id: 'action-1',
      kind: RevisionSessionActionKind.diagnosticQuiz,
      status: RevisionSessionActionStatus.ready,
      displayOrder: 0,
      activitySessionId: 'activity-session-1',
      documentId: 'document-1',
      knowledgeUnitId: 'knowledge-unit-1',
      payload: null,
    ),
    history: const [],
  );
}
