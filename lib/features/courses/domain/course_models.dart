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
    required this.courseId,
    required this.subjectId,
    required this.coverage,
    required this.estimatedGlobalMastery,
    required this.knowledgeUnitCount,
    required this.practicedKnowledgeUnitCount,
    required this.readySourceCount,
    required this.processingSourceCount,
    required this.failedSourceCount,
    required this.state,
    this.mastery,
    this.lastPracticedAt,
  });

  final String courseId;
  final String subjectId;
  final double coverage;
  final double? mastery;
  final double estimatedGlobalMastery;
  final int knowledgeUnitCount;
  final int practicedKnowledgeUnitCount;
  final int readySourceCount;
  final int processingSourceCount;
  final int failedSourceCount;
  final DateTime? lastPracticedAt;
  final CourseProgressState state;
}

class SubjectProgress {
  const SubjectProgress({
    required this.subjectId,
    required this.knowledgeUnitCount,
    required this.practicedKnowledgeUnitCount,
    required this.coverage,
    required this.estimatedGlobalMastery,
    required this.courseCount,
    required this.readyCourseCount,
    required this.courses,
    this.mastery,
    this.lastPracticedAt,
  });

  final String subjectId;
  final int knowledgeUnitCount;
  final int practicedKnowledgeUnitCount;
  final double coverage;
  final double? mastery;
  final double estimatedGlobalMastery;
  final int courseCount;
  final int readyCourseCount;
  final DateTime? lastPracticedAt;
  final List<SubjectCourseProgressItem> courses;
}

class SubjectCourseProgressItem {
  const SubjectCourseProgressItem({
    required this.courseId,
    required this.title,
    required this.knowledgeUnitCount,
    required this.practicedKnowledgeUnitCount,
    required this.coverage,
    required this.estimatedGlobalMastery,
    required this.state,
    this.mastery,
  });

  final String courseId;
  final String title;
  final int knowledgeUnitCount;
  final int practicedKnowledgeUnitCount;
  final double coverage;
  final double? mastery;
  final double estimatedGlobalMastery;
  final CourseProgressState state;
}

enum CourseDifficulty { beginner, intermediate, advanced }

enum CourseDocumentStatus { uploaded, processing, ready, failed, unknown }

enum LifecycleStatus { active, archived }

enum LifecycleRecommendedAction { delete, archive, block }

class CourseLifecycleDecision {
  const CourseLifecycleDecision({
    required this.courseId,
    required this.status,
    required this.recommendedAction,
    required this.canDelete,
    required this.canArchive,
    required this.canUpdate,
    required this.blockingReasons,
    required this.userMessage,
  });

  final String courseId;
  final LifecycleStatus status;
  final LifecycleRecommendedAction recommendedAction;
  final bool canDelete;
  final bool canArchive;
  final bool canUpdate;
  final List<String> blockingReasons;
  final String userMessage;
}

enum CourseProgressState {
  noSource,
  processing,
  failedOnly,
  noKnowledgeUnits,
  readyNotPracticed,
  practiced,
  unknown,
}

enum CourseQuestionBankReadinessStatus {
  noReadySource,
  noKnowledgeUnits,
  notPrepared,
  preparing,
  ready,
  failed,
  unknown,
}

class CourseQuestionBankReadiness {
  const CourseQuestionBankReadiness({
    required this.courseId,
    required this.status,
    required this.readyQuestionCount,
    required this.targetQuestionCount,
    required this.canStartQuickRevision,
    required this.canPrepare,
    required this.userMessage,
  });

  final String courseId;
  final CourseQuestionBankReadinessStatus status;
  final int readyQuestionCount;
  final int targetQuestionCount;
  final bool canStartQuickRevision;
  final bool canPrepare;
  final String userMessage;
}
