class CourseListItem {
  const CourseListItem({
    required this.id,
    required this.subjectId,
    required this.title,
    this.description,
    this.chapterLabel,
    this.estimatedMinutes,
    this.displayOrder = 0,
    this.createdAt,
    this.updatedAt,
    this.sourceCount = 0,
    this.readySourceCount = 0,
    this.processingSourceCount = 0,
    this.failedSourceCount = 0,
    this.difficulty,
    this.progress,
  });

  final String id;
  final String subjectId;
  final String title;
  final String? description;
  final String? chapterLabel;
  final int? estimatedMinutes;
  final int displayOrder;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int sourceCount;
  final int readySourceCount;
  final int processingSourceCount;
  final int failedSourceCount;
  final CourseDifficulty? difficulty;
  final CourseProgress? progress;
}

class CourseSubjectSummary {
  const CourseSubjectSummary({required this.id, required this.name});

  final String id;
  final String name;
}

class CourseDetail {
  const CourseDetail({
    required this.course,
    required this.subject,
    required this.sources,
    this.progress,
  });

  final CourseListItem course;
  final CourseSubjectSummary subject;
  final List<CourseDocument> sources;
  final CourseProgress? progress;
}

class CourseDocument {
  const CourseDocument({
    required this.id,
    required this.courseId,
    required this.documentId,
    required this.fileName,
    required this.status,
    this.kind = 'COURSE_PDF',
    this.errorCode,
    this.createdAt,
    this.updatedAt,
    this.isPrimary = false,
  });

  final String id;
  final String courseId;
  final String documentId;
  final String fileName;
  final String kind;
  final CourseDocumentStatus status;
  final String? errorCode;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool isPrimary;
}

class CourseProgress {
  const CourseProgress({
    required this.coverage,
    required this.estimatedGlobalMastery,
    required this.knowledgeUnitCount,
    required this.practicedKnowledgeUnitCount,
    this.mastery,
  });

  final double coverage;
  final double? mastery;
  final double estimatedGlobalMastery;
  final int knowledgeUnitCount;
  final int practicedKnowledgeUnitCount;
}

enum CourseDifficulty { beginner, intermediate, advanced }

enum CourseDocumentStatus { uploaded, processing, ready, failed, unknown }
