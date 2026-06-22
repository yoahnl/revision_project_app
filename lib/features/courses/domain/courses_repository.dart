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

  Future<RevisionSessionResponse> startCourseQuickRevision({
    required String courseId,
    int questionCount = 10,
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
  const CourseQuickRevisionUnavailableException(this.message);

  final String message;

  @override
  String toString() => message;
}
