import 'package:flutter_test/flutter_test.dart';
import 'package:Neralune/features/activities/domain/diagnostic_quiz_activity.dart';
import 'package:Neralune/features/activities/genui/diagnostic_quiz_activity_validator.dart';

void main() {
  test('accepts a bounded diagnostic quiz activity', () {
    expect(isDiagnosticQuizActivityCatalogSafe(validActivity()), isTrue);
  });

  test('rejects empty identifiers and duplicate question ids', () {
    expect(
      isDiagnosticQuizActivityCatalogSafe(
        validActivity(
          questions: const [
            DiagnosticQuizQuestion(
              id: 'question-1',
              prompt: 'Question',
              choices: [
                DiagnosticQuizChoice(id: 'a', label: 'A'),
                DiagnosticQuizChoice(id: 'b', label: 'B'),
              ],
            ),
            DiagnosticQuizQuestion(
              id: 'question-1',
              prompt: 'Question bis',
              choices: [
                DiagnosticQuizChoice(id: 'a', label: 'A'),
                DiagnosticQuizChoice(id: 'b', label: 'B'),
              ],
            ),
          ],
        ),
      ),
      isFalse,
    );
    expect(
      isDiagnosticQuizActivityCatalogSafe(validActivity(sessionId: ' ')),
      isFalse,
    );
  });

  test('rejects invalid choice counts', () {
    expect(
      isDiagnosticQuizActivityCatalogSafe(
        validActivity(
          questions: const [
            DiagnosticQuizQuestion(
              id: 'question-1',
              prompt: 'Question',
              choices: [DiagnosticQuizChoice(id: 'a', label: 'A')],
            ),
          ],
        ),
      ),
      isFalse,
    );
  });
}

DiagnosticQuizActivity validActivity({
  String sessionId = 'session-1',
  List<DiagnosticQuizQuestion> questions = const [
    DiagnosticQuizQuestion(
      id: 'question-1',
      prompt: 'Question',
      choices: [
        DiagnosticQuizChoice(id: 'a', label: 'A'),
        DiagnosticQuizChoice(id: 'b', label: 'B'),
      ],
    ),
  ],
}) {
  return DiagnosticQuizActivity(
    sessionId: sessionId,
    title: 'Diagnostic rapide',
    questions: questions,
  );
}
