class CourseListItem {
  const CourseListItem({
    required this.id,
    required this.subjectId,
    required this.title,
    this.description,
    this.chapterLabel,
    this.estimatedMinutes,
    this.difficulty,
    this.progress,
  });

  final String id;
  final String subjectId;
  final String title;
  final String? description;
  final String? chapterLabel;
  final int? estimatedMinutes;
  final CourseDifficulty? difficulty;
  final CourseProgress? progress;
}

class CourseDetail {
  const CourseDetail({
    required this.course,
    required this.sources,
    this.progress,
  });

  final CourseListItem course;
  final List<CourseSource> sources;
  final CourseProgress? progress;
}

class CourseSource {
  const CourseSource({
    required this.id,
    required this.courseId,
    required this.documentId,
    required this.fileName,
    required this.status,
    this.isPrimary = false,
  });

  final String id;
  final String courseId;
  final String documentId;
  final String fileName;
  final CourseSourceStatus status;
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

enum CourseSourceStatus { uploaded, processing, ready, failed, unknown }
