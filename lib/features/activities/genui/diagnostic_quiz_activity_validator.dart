import '../domain/diagnostic_quiz_activity.dart';

const int maxDiagnosticQuizQuestions = 20;
const int maxDiagnosticQuizChoicesPerQuestion = 6;

bool isDiagnosticQuizActivityCatalogSafe(DiagnosticQuizActivity activity) {
  if (activity.sessionId.trim().isEmpty || activity.title.trim().isEmpty) {
    return false;
  }

  if (activity.questions.isEmpty ||
      activity.questions.length > maxDiagnosticQuizQuestions) {
    return false;
  }

  final questionIds = <String>{};

  for (final question in activity.questions) {
    if (question.id.trim().isEmpty ||
        question.prompt.trim().isEmpty ||
        !questionIds.add(question.id)) {
      return false;
    }

    if (question.choices.length < 2 ||
        question.choices.length > maxDiagnosticQuizChoicesPerQuestion) {
      return false;
    }

    final choiceIds = <String>{};
    for (final choice in question.choices) {
      if (choice.id.trim().isEmpty ||
          choice.label.trim().isEmpty ||
          !choiceIds.add(choice.id)) {
        return false;
      }
    }
  }

  return true;
}
