import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:revision_app/features/activities/domain/diagnostic_quiz_activity.dart';
import 'package:revision_app/presentation/pages/activities/diagnostic_quiz_page.dart';
import 'package:revision_app/presentation/widgets/revision_button.dart';

void main() {
  testWidgets('renders the diagnostic quiz fallback activity', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: DiagnosticQuizPage(
          activity: DiagnosticQuizActivity(
            sessionId: 'session-1',
            title: 'Diagnostic rapide',
            questions: [
              DiagnosticQuizQuestion(
                id: 'question-1',
                prompt: 'Quelle structure contractile propulse le sang ?',
                choices: [
                  DiagnosticQuizChoice(id: 'a', label: 'Myocarde'),
                  DiagnosticQuizChoice(id: 'b', label: 'Pericarde'),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Diagnostic rapide'), findsOneWidget);
    expect(
      find.text('Quelle structure contractile propulse le sang ?'),
      findsOneWidget,
    );
    expect(find.text('Myocarde'), findsOneWidget);
    expect(find.text('Pericarde'), findsOneWidget);
  });

  testWidgets('selects answers and submits the diagnostic quiz', (
    tester,
  ) async {
    final submittedAnswers = <DiagnosticQuizAnswer>[];

    await tester.pumpWidget(
      MaterialApp(
        home: DiagnosticQuizPage(
          activity: const DiagnosticQuizActivity(
            sessionId: 'session-1',
            title: 'Diagnostic rapide',
            questions: [
              DiagnosticQuizQuestion(
                id: 'question-1',
                prompt: 'Quelle structure contractile propulse le sang ?',
                choices: [
                  DiagnosticQuizChoice(id: 'a', label: 'Myocarde'),
                  DiagnosticQuizChoice(id: 'b', label: 'Pericarde'),
                ],
              ),
            ],
          ),
          onSubmit: (answers) async {
            submittedAnswers.addAll(answers);

            return const DiagnosticQuizResult(
              correctAnswers: 1,
              totalQuestions: 1,
            );
          },
        ),
      ),
    );

    final submitButton = find.byType(RevisionButton);
    expect(tester.widget<RevisionButton>(submitButton).onPressed, isNull);

    await tester.tap(find.text('Myocarde'));
    await tester.pump();
    await tester.tap(find.text('Valider'));
    await tester.pumpAndSettle();

    expect(submittedAnswers.single.choiceId, 'a');
    expect(find.text('Score 1 / 1'), findsOneWidget);
  });

  testWidgets('shows a deterministic empty state without questions', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: DiagnosticQuizPage(
          activity: DiagnosticQuizActivity(
            sessionId: 'session-1',
            title: 'Diagnostic rapide',
            questions: [],
          ),
        ),
      ),
    );

    expect(find.text('Aucune question disponible'), findsOneWidget);
  });
}
