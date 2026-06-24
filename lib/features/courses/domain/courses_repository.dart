import 'dart:typed_data';

import '../../documents/domain/revision_document.dart';
import '../../documents/domain/source_lifecycle.dart';
import '../../revision_sessions/domain/revision_session.dart';
import 'course_models.dart';

abstract interface class CoursesRepository {
  Future<List<CourseListItem>> listCourses({required String subjectId});

  Future<CourseDetail> getCourse({required String courseId});

  Future<CourseListItem> createCourse({
    required String subjectId,
    required CreateCourseInput input,
  });

  Future<CourseListItem> updateCourse({
    required String courseId,
    required UpdateCourseInput input,
  });

  Future<CourseLifecycleDecision> getCourseLifecycle({
    required String courseId,
  });

  Future<CourseLifecycleDecision> archiveCourse({required String courseId});

  Future<void> deleteCourse({required String courseId});

  Future<CourseDocument> uploadCoursePdf({
    required String courseId,
    required String fileName,
    required Uint8List bytes,
  });

  Future<void> deleteCourseDocument({
    required String courseId,
    required String documentId,
  });

  Future<SourceLifecycleDecision> getCourseDocumentLifecycle({
    required String courseId,
    required String documentId,
  });

  Future<SourceLifecycleDecision> archiveCourseDocument({
    required String courseId,
    required String documentId,
  });

  Future<RevisionSheet?> getCourseRevisionSheet({required String courseId});

  Future<RevisionSheet> generateCourseRevisionSheet({required String courseId});

  Future<CourseQuestionBankReadiness> getQuestionBankReadiness({
    required String courseId,
    int questionCount = 10,
  });

  Future<CourseQuestionBankReadiness> prepareQuestionBank({
    required String courseId,
    int questionCount = 10,
  });

  Future<RevisionSessionResponse> startCourseQuickRevision({
    required String courseId,
    int questionCount = 10,
  });

  Future<ResumableCourseRevisionSession?> getResumableCourseRevisionSession({
    required String courseId,
  });

  Future<RevisionSessionHistoryResponse> getCourseRevisionSessionHistory({
    required String courseId,
    int limit = 5,
  });

  Future<CourseRichClosedHistoryResponse> getCourseRichClosedHistory({
    required String courseId,
    int limit = 5,
  });

  Future<CourseProgress> getCourseProgress({required String courseId});

  Future<SubjectProgress> getSubjectProgress({required String subjectId});
}

class CreateCourseInput {
  const CreateCourseInput({
    required this.title,
    this.description,
    this.chapterLabel,
    this.estimatedMinutes,
  });

  final String title;
  final String? description;
  final String? chapterLabel;
  final int? estimatedMinutes;
}

class UpdateCourseInput {
  const UpdateCourseInput({
    this.title,
    this.description,
    this.chapterLabel,
    this.estimatedMinutes,
  });

  final String? title;
  final String? description;
  final String? chapterLabel;
  final int? estimatedMinutes;
}

class CourseNotFoundException implements Exception {
  const CourseNotFoundException(this.message);

  final String message;

  @override
  String toString() => message;
}

class CourseRequestException implements Exception {
  const CourseRequestException(this.message);

  final String message;

  @override
  String toString() => message;
}

class CourseLifecycleBlockedException implements Exception {
  const CourseLifecycleBlockedException(this.message);

  final String message;

  @override
  String toString() => message;
}

class CourseUploadException implements Exception {
  const CourseUploadException(this.message);

  final String message;

  @override
  String toString() => message;
}

class CourseRevisionSheetNotReadyException implements Exception {
  const CourseRevisionSheetNotReadyException(this.message);

  final String message;

  @override
  String toString() => message;
}

class CourseQuickRevisionUnavailableException implements Exception {
  const CourseQuickRevisionUnavailableException(this.message, {this.readiness});

  final String message;
  final CourseQuestionBankReadiness? readiness;

  @override
  String toString() => message;
}
