class TodayPlan {
  const TodayPlan({required this.generatedAt, required this.items});

  final DateTime generatedAt;
  final List<TodayPlanItem> items;

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
}
