class Subject {
  const Subject({
    required this.id,
    required this.name,
    required this.priority,
    this.weeklyMinutes = 0,
  });

  final String id;
  final String name;
  final int priority;
  final int weeklyMinutes;
}

enum SubjectLifecycleStatus { active, archived }

enum SubjectLifecycleRecommendedAction { delete, archive, block }

class SubjectLifecycleDecision {
  const SubjectLifecycleDecision({
    required this.subjectId,
    required this.status,
    required this.recommendedAction,
    required this.canDelete,
    required this.canArchive,
    required this.canUpdate,
    required this.blockingReasons,
    required this.userMessage,
  });

  final String subjectId;
  final SubjectLifecycleStatus status;
  final SubjectLifecycleRecommendedAction recommendedAction;
  final bool canDelete;
  final bool canArchive;
  final bool canUpdate;
  final List<String> blockingReasons;
  final String userMessage;
}

class SubjectLifecycleBlockedException implements Exception {
  const SubjectLifecycleBlockedException(this.message);

  final String message;

  @override
  String toString() => message;
}
