import '../../activities/domain/open_question_activity.dart';

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

enum CourseExamPreparationReadinessState {
  ready,
  partiallyReady,
  notReady,
  blocked,
  unknown,
}

enum CourseExamPreparationScopeKind { course, source, unknown }

class CourseExamPreparationOptions {
  const CourseExamPreparationOptions({
    required this.course,
    required this.readiness,
    required this.scopeOptions,
    required this.questionCountOptions,
    required this.defaultQuestionCount,
    required this.supportedQuestionKinds,
    required this.defaultConfig,
    required this.nextStep,
  });

  final CourseExamPreparationCourse course;
  final CourseExamPreparationReadiness readiness;
  final List<CourseExamPreparationScopeOption> scopeOptions;
  final List<int> questionCountOptions;
  final int? defaultQuestionCount;
  final List<String> supportedQuestionKinds;
  final CourseExamPreparationConfig? defaultConfig;
  final CourseExamPreparationNextStep nextStep;
}

class CourseExamPreparationCourse {
  const CourseExamPreparationCourse({
    required this.id,
    required this.title,
    required this.subjectId,
  });

  final String id;
  final String title;
  final String subjectId;
}

class CourseExamPreparationReadiness {
  const CourseExamPreparationReadiness({
    required this.canPrepare,
    required this.state,
    required this.userMessage,
    required this.blockers,
    required this.readySourceCount,
    required this.readyKnowledgeUnitCount,
    required this.availableQuestionCount,
  });

  final bool canPrepare;
  final CourseExamPreparationReadinessState state;
  final String userMessage;
  final List<String> blockers;
  final int readySourceCount;
  final int readyKnowledgeUnitCount;
  final int availableQuestionCount;
}

class CourseExamPreparationScopeOption {
  const CourseExamPreparationScopeOption({
    required this.kind,
    required this.id,
    required this.label,
    required this.readyQuestionCount,
    required this.readyKnowledgeUnitCount,
    required this.canSelect,
  });

  final CourseExamPreparationScopeKind kind;
  final String id;
  final String label;
  final int readyQuestionCount;
  final int readyKnowledgeUnitCount;
  final bool canSelect;
}

class CourseExamPreparationConfig {
  const CourseExamPreparationConfig({
    required this.scopeKind,
    required this.scopeId,
    required this.questionCount,
    required this.complexityProfile,
  });

  final CourseExamPreparationScopeKind scopeKind;
  final String scopeId;
  final int questionCount;
  final String complexityProfile;
}

class CourseExamPreparationNextStep {
  const CourseExamPreparationNextStep({
    required this.kind,
    required this.userMessage,
  });

  final String kind;
  final String userMessage;
}

enum CourseRichRevisionReadinessState {
  ready,
  partiallyReady,
  notReady,
  blocked,
  unknown,
}

enum CourseRichRevisionScopeKind { knowledgeUnit, unknown }

class CourseRichRevisionOptions {
  const CourseRichRevisionOptions({
    required this.course,
    required this.readiness,
    required this.scopeOptions,
    required this.questionCountOptions,
    required this.defaultQuestionCount,
    required this.supportedQuestionKinds,
    required this.complexityProfiles,
    required this.defaultConfig,
    required this.nextStep,
  });

  final CourseRichRevisionCourse course;
  final CourseRichRevisionReadiness readiness;
  final List<CourseRichRevisionScopeOption> scopeOptions;
  final List<int> questionCountOptions;
  final int? defaultQuestionCount;
  final List<String> supportedQuestionKinds;
  final List<String> complexityProfiles;
  final CourseRichRevisionConfig? defaultConfig;
  final CourseRichRevisionNextStep nextStep;
}

class CourseRichRevisionCourse {
  const CourseRichRevisionCourse({
    required this.id,
    required this.title,
    required this.subjectId,
  });

  final String id;
  final String title;
  final String subjectId;
}

class CourseRichRevisionReadiness {
  const CourseRichRevisionReadiness({
    required this.canStart,
    required this.state,
    required this.userMessage,
    required this.blockers,
    required this.readySourceCount,
    required this.readyKnowledgeUnitCount,
  });

  final bool canStart;
  final CourseRichRevisionReadinessState state;
  final String userMessage;
  final List<String> blockers;
  final int readySourceCount;
  final int readyKnowledgeUnitCount;
}

class CourseRichRevisionScopeOption {
  const CourseRichRevisionScopeOption({
    required this.kind,
    required this.id,
    required this.documentId,
    required this.label,
    required this.sourceLabel,
    required this.canSelect,
  });

  final CourseRichRevisionScopeKind kind;
  final String id;
  final String documentId;
  final String label;
  final String sourceLabel;
  final bool canSelect;
}

class CourseRichRevisionConfig {
  const CourseRichRevisionConfig({
    required this.scopeKind,
    required this.scopeId,
    required this.questionCount,
    required this.complexityProfile,
  });

  final CourseRichRevisionScopeKind scopeKind;
  final String scopeId;
  final int questionCount;
  final String complexityProfile;
}

class CourseRichRevisionNextStep {
  const CourseRichRevisionNextStep({
    required this.kind,
    required this.userMessage,
  });

  final String kind;
  final String userMessage;
}

enum CourseDeepRevisionReadinessState { ready, notReady, blocked, unknown }

enum CourseDeepRevisionScopeKind { knowledgeUnit, unknown }

class CourseDeepRevisionOptions {
  const CourseDeepRevisionOptions({
    required this.course,
    required this.readiness,
    required this.scopeOptions,
    required this.answerGuidelines,
    required this.defaultConfig,
    required this.nextStep,
  });

  final CourseDeepRevisionCourse course;
  final CourseDeepRevisionReadiness readiness;
  final List<CourseDeepRevisionScopeOption> scopeOptions;
  final CourseDeepRevisionAnswerGuidelines answerGuidelines;
  final CourseDeepRevisionConfig? defaultConfig;
  final CourseDeepRevisionNextStep nextStep;
}

class CourseDeepRevisionCourse {
  const CourseDeepRevisionCourse({
    required this.id,
    required this.title,
    required this.subjectId,
  });

  final String id;
  final String title;
  final String subjectId;
}

class CourseDeepRevisionReadiness {
  const CourseDeepRevisionReadiness({
    required this.canStart,
    required this.state,
    required this.userMessage,
    required this.blockers,
    required this.readySourceCount,
    required this.readyKnowledgeUnitCount,
  });

  final bool canStart;
  final CourseDeepRevisionReadinessState state;
  final String userMessage;
  final List<String> blockers;
  final int readySourceCount;
  final int readyKnowledgeUnitCount;
}

class CourseDeepRevisionScopeOption {
  const CourseDeepRevisionScopeOption({
    required this.kind,
    required this.id,
    required this.documentId,
    required this.label,
    required this.sourceLabel,
    required this.canSelect,
  });

  final CourseDeepRevisionScopeKind kind;
  final String id;
  final String documentId;
  final String label;
  final String sourceLabel;
  final bool canSelect;
}

class CourseDeepRevisionAnswerGuidelines {
  const CourseDeepRevisionAnswerGuidelines({
    required this.minLength,
    required this.maxLength,
    required this.userMessage,
  });

  final int minLength;
  final int maxLength;
  final String userMessage;
}

class CourseDeepRevisionConfig {
  const CourseDeepRevisionConfig({
    required this.scopeKind,
    required this.scopeId,
  });

  final CourseDeepRevisionScopeKind scopeKind;
  final String scopeId;
}

class CourseDeepRevisionNextStep {
  const CourseDeepRevisionNextStep({
    required this.kind,
    required this.userMessage,
  });

  final String kind;
  final String userMessage;
}

class CourseDeepRevisionSessionSummary {
  const CourseDeepRevisionSessionSummary({
    required this.id,
    required this.mode,
    required this.status,
    required this.courseId,
    this.completedAt,
  });

  final String id;
  final String mode;
  final String status;
  final String courseId;
  final DateTime? completedAt;
}

class CourseDeepRevisionScope {
  const CourseDeepRevisionScope({
    required this.kind,
    required this.id,
    required this.label,
    required this.sourceLabel,
  });

  final CourseDeepRevisionScopeKind kind;
  final String id;
  final String label;
  final String sourceLabel;
}

class CourseDeepRevisionSession {
  const CourseDeepRevisionSession({
    required this.session,
    required this.question,
    required this.scope,
    required this.answerGuidelines,
  });

  final CourseDeepRevisionSessionSummary session;
  final OpenQuestion question;
  final CourseDeepRevisionScope scope;
  final CourseDeepRevisionAnswerGuidelines answerGuidelines;

  OpenQuestionActivity toOpenQuestionActivity({
    required CourseDeepRevisionCourse course,
  }) {
    return OpenQuestionActivity(
      sessionId: session.id,
      type: 'open_question',
      version: null,
      subjectId: course.subjectId,
      documentId: null,
      knowledgeUnitId: scope.id,
      question: question,
    );
  }
}

class CourseDeepRevisionSubmitResponse {
  const CourseDeepRevisionSubmitResponse({
    required this.session,
    required this.evaluation,
    this.resultPath,
  });

  final CourseDeepRevisionSessionSummary session;
  final OpenAnswerEvaluation evaluation;
  final String? resultPath;

  OpenAnswerSubmissionResult toOpenAnswerSubmissionResult() {
    return OpenAnswerSubmissionResult(
      sessionId: session.id,
      type: 'open_question',
      status: session.status,
      evaluation: evaluation,
    );
  }
}

class CourseDeepRevisionHistoryResponse {
  const CourseDeepRevisionHistoryResponse({required this.items});

  final List<CourseDeepRevisionHistoryItem> items;
}

class CourseDeepRevisionHistoryItem {
  const CourseDeepRevisionHistoryItem({
    required this.sessionId,
    required this.title,
    required this.course,
    required this.knowledgeUnit,
    required this.score,
    required this.submittedAt,
    required this.resultPath,
  });

  final String sessionId;
  final String title;
  final CourseDeepRevisionHistoryCourse course;
  final CourseDeepRevisionHistoryKnowledgeUnit knowledgeUnit;
  final double? score;
  final DateTime submittedAt;
  final String resultPath;
}

class CourseDeepRevisionHistoryCourse {
  const CourseDeepRevisionHistoryCourse({
    required this.id,
    required this.title,
  });

  final String id;
  final String title;
}

class CourseDeepRevisionHistoryKnowledgeUnit {
  const CourseDeepRevisionHistoryKnowledgeUnit({
    required this.id,
    required this.title,
  });

  final String id;
  final String title;
}

class CourseDeepRevisionResult {
  const CourseDeepRevisionResult({
    required this.session,
    required this.scope,
    required this.question,
    required this.answer,
    required this.evaluation,
  });

  final CourseDeepRevisionResultSession session;
  final CourseDeepRevisionScope scope;
  final OpenQuestion question;
  final CourseDeepRevisionAnswer answer;
  final OpenAnswerEvaluation evaluation;
}

class CourseDeepRevisionResultSession {
  const CourseDeepRevisionResultSession({
    required this.id,
    required this.status,
    required this.courseId,
    required this.completedAt,
  });

  final String id;
  final String status;
  final String courseId;
  final DateTime? completedAt;
}

class CourseDeepRevisionAnswer {
  const CourseDeepRevisionAnswer({
    required this.text,
    required this.submittedAt,
  });

  final String text;
  final DateTime submittedAt;
}

class CourseRichClosedHistoryResponse {
  const CourseRichClosedHistoryResponse({required this.items});

  final List<CourseRichClosedHistoryItem> items;
}

class CourseRichClosedHistoryItem {
  const CourseRichClosedHistoryItem({
    required this.id,
    required this.sessionId,
    required this.type,
    required this.status,
    required this.title,
    required this.subjectId,
    required this.documentId,
    required this.knowledgeUnit,
    required this.course,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.score,
    required this.completedAt,
    required this.resultPath,
  });

  final String id;
  final String sessionId;
  final String type;
  final String status;
  final String title;
  final String subjectId;
  final String? documentId;
  final CourseRichClosedHistoryKnowledgeUnit knowledgeUnit;
  final CourseRichClosedHistoryCourse course;
  final int correctAnswers;
  final int totalQuestions;
  final double score;
  final DateTime completedAt;
  final String resultPath;
}

class CourseRichClosedHistoryKnowledgeUnit {
  const CourseRichClosedHistoryKnowledgeUnit({
    required this.id,
    required this.title,
  });

  final String id;
  final String title;
}

class CourseRichClosedHistoryCourse {
  const CourseRichClosedHistoryCourse({required this.id, required this.title});

  final String id;
  final String title;
}
