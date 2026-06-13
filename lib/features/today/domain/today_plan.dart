class TodayPlan {
  const TodayPlan({required this.generatedAt, required this.items});

  final DateTime generatedAt;
  final List<TodayPlanItem> items;
}

class TodayPlanItem {
  const TodayPlanItem({
    required this.subjectId,
    required this.subjectName,
    required this.knowledgeUnitId,
    required this.knowledgeUnitTitle,
    required this.masteryScore,
    required this.action,
    required this.estimatedMinutes,
  });

  final String subjectId;
  final String subjectName;
  final String knowledgeUnitId;
  final String knowledgeUnitTitle;
  final double masteryScore;
  final String action;
  final int estimatedMinutes;
}
