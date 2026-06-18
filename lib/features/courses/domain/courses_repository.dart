import 'dart:typed_data';

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

  Future<CourseProgress> getCourseProgress({required String courseId});
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
