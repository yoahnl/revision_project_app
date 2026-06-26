class TodayPlan {
  const TodayPlan({
    required this.generatedAt,
    required this.items,
    this.primaryItemId,
    this.continuationItemIds = const [],
    this.weeklyObjective,
    this.emptyState,
  });

  final DateTime generatedAt;
  final List<TodayPlanItem> items;
  final String? primaryItemId;
  final List<String> continuationItemIds;
  final TodayWeeklyObjective? weeklyObjective;
  final TodayEmptyState? emptyState;

  int get totalEstimatedMinutes {
    return items.fold(0, (total, item) => total + item.estimatedMinutes);
  }
}

enum TodayPlanActionType {
  diagnosticQuiz,
  openQuestion,
  richClosedExercise,
  revisionSession,
}

enum TodayPlanReasonCode {
  lowMastery,
  stalePractice,
  highPrioritySubject,
  mixActivityType,
  richClosedPractice,
  startRevisionSession,
  continueProgress,
}

enum TodayPlanPreferredAction { diagnosticQuiz, openQuestion }

enum TodayPlanItemRole { primary, continuation }

enum TodayWeeklyObjectiveStatus { targetOnly, progressAvailable }

enum TodayEmptyActionKind { openCourses }

class TodayWeeklyObjective {
  const TodayWeeklyObjective({
    required this.targetMinutes,
    required this.completedMinutes,
    required this.progressRatio,
    required this.label,
    required this.status,
  });

  final int targetMinutes;
  final int? completedMinutes;
  final double? progressRatio;
  final String label;
  final TodayWeeklyObjectiveStatus status;
}

class TodayEmptyState {
  const TodayEmptyState({
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.actionKind,
  });

  final String title;
  final String message;
  final String actionLabel;
  final TodayEmptyActionKind actionKind;
}

class TodayPlanItemDisplay {
  const TodayPlanItemDisplay({
    required this.title,
    required this.subjectLabel,
    required this.badgeLabel,
    required this.durationLabel,
    required this.metaLabel,
    required this.recommendation,
    required this.actionLabel,
    required this.unavailableReason,
  });

  final String title;
  final String subjectLabel;
  final String badgeLabel;
  final String? durationLabel;
  final String metaLabel;
  final String recommendation;
  final String actionLabel;
  final String? unavailableReason;
}

class TodayPlanStartPayload {
  const TodayPlanStartPayload({
    required this.subjectId,
    this.documentId,
    this.knowledgeUnitId,
    this.preferredAction,
  });

  final String subjectId;
  final String? documentId;
  final String? knowledgeUnitId;
  final TodayPlanPreferredAction? preferredAction;
}

class TodayPlanItem {
  const TodayPlanItem({
    required this.id,
    required this.subjectId,
    required this.subjectName,
    this.documentId,
    required this.knowledgeUnitId,
    required this.knowledgeUnitTitle,
    required this.masteryScore,
    required this.action,
    required this.estimatedMinutes,
    required this.priority,
    required this.reasonCode,
    required this.reason,
    required this.startPayload,
    this.role,
    this.display,
  });

  final String id;
  final String subjectId;
  final String subjectName;
  final String? documentId;
  final String? knowledgeUnitId;
  final String? knowledgeUnitTitle;
  final double? masteryScore;
  final TodayPlanActionType action;
  final int estimatedMinutes;
  final int priority;
  final TodayPlanReasonCode reasonCode;
  final String reason;
  final TodayPlanStartPayload startPayload;
  final TodayPlanItemRole? role;
  final TodayPlanItemDisplay? display;
}
