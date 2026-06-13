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
