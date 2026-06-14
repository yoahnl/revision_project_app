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
              score: 1,
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

  testWidgets('does not reveal correction fields before submit', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: DiagnosticQuizPage(
          activity: enrichedActivity(),
          onSubmit: (_) async => enrichedResult(),
        ),
      ),
    );

    expect(find.text('Réponse attendue: Myocarde'), findsNothing);
    expect(find.text('Explication post-submit sensible.'), findsNothing);
    expect(find.text('Feedback post-submit sensible.'), findsNothing);
    expect(find.text('Texte source post-submit sensible.'), findsNothing);
    expect(find.text('Sources disponibles après correction'), findsOneWidget);
  });

  testWidgets('shows enriched correction feedback and sources after submit', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: DiagnosticQuizPage(
          activity: enrichedActivity(),
          onSubmit: (_) async => enrichedResult(),
        ),
      ),
    );

    await tester.tap(find.text('Péricarde'));
    await tester.pump();
    await tester.tap(find.text('Valider'));
    await tester.pumpAndSettle();

    expect(find.text('Score 0 / 1'), findsOneWidget);
    expect(find.text('Réponse sélectionnée: Péricarde'), findsOneWidget);
    expect(find.text('Réponse attendue: Myocarde'), findsOneWidget);
    expect(find.text('Explication post-submit sensible.'), findsOneWidget);
    expect(
      find.textContaining('Feedback post-submit sensible.'),
      findsOneWidget,
    );
    expect(find.text('Texte source post-submit sensible.'), findsOneWidget);
  });

  testWidgets(
    'keeps the submit button disabled until all questions are answered',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: DiagnosticQuizPage(
            activity: longActivity(questionCount: 1),
            onSubmit: (_) async => const DiagnosticQuizResult(
              correctAnswers: 1,
              totalQuestions: 1,
            ),
          ),
        ),
      );

      await tester.ensureVisible(find.text('Valider'));
      await tester.pumpAndSettle();
      final submitButton = find.byType(RevisionButton);
      expect(tester.widget<RevisionButton>(submitButton).onPressed, isNull);

      await tester.ensureVisible(find.text('Choix A question 1'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Choix A question 1'));
      await tester.pump();

      await tester.ensureVisible(find.text('Valider'));
      await tester.pumpAndSettle();
      expect(tester.widget<RevisionButton>(submitButton).onPressed, isNotNull);
    },
  );

  testWidgets('renders a long quiz without layout exceptions', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: SizedBox(
          height: 680,
          child: DiagnosticQuizPage(
            activity: longActivity(questionCount: 15),
            onSubmit: (_) async => const DiagnosticQuizResult(
              correctAnswers: 15,
              totalQuestions: 15,
            ),
          ),
        ),
      ),
    );

    expect(find.text('15 questions'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Question 15 prompt'),
      600,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Question 15 prompt'), findsOneWidget);
    expect(tester.takeException(), isNull);
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

DiagnosticQuizActivity enrichedActivity() {
  return const DiagnosticQuizActivity(
    sessionId: 'session-1',
    title: 'Diagnostic enrichi',
    version: 2,
    documentId: 'document-1',
    subjectId: 'subject-1',
    questions: [
      DiagnosticQuizQuestion(
        id: 'question-1',
        knowledgeUnitId: 'unit-1',
        prompt: 'Quelle structure contractile propulse le sang ?',
        difficulty: 'MEDIUM',
        choices: [
          DiagnosticQuizChoice(id: 'a', label: 'Myocarde'),
          DiagnosticQuizChoice(id: 'b', label: 'Péricarde'),
        ],
        sources: [
          DiagnosticQuizSourceRef(
            chunkId: 'chunk-1',
            pageNumber: null,
            index: 0,
          ),
        ],
      ),
    ],
  );
}

DiagnosticQuizResult enrichedResult() {
  return const DiagnosticQuizResult(
    correctAnswers: 0,
    totalQuestions: 1,
    score: 0,
    items: [
      DiagnosticQuizCorrectionItem(
        questionId: 'question-1',
        knowledgeUnitId: 'unit-1',
        prompt: 'Quelle structure contractile propulse le sang ?',
        selectedChoiceId: 'b',
        correctChoiceId: 'a',
        isCorrect: false,
        explanation: 'Explication post-submit sensible.',
        choiceFeedback: [
          DiagnosticQuizChoiceFeedback(
            choiceId: 'b',
            feedback: 'Feedback post-submit sensible.',
          ),
        ],
        sources: [
          DiagnosticQuizCorrectionSource(
            chunkId: 'chunk-1',
            text: 'Texte source post-submit sensible.',
            pageNumber: null,
            index: 0,
          ),
        ],
      ),
    ],
  );
}

DiagnosticQuizActivity longActivity({required int questionCount}) {
  return DiagnosticQuizActivity(
    sessionId: 'session-long',
    title: 'Diagnostic long',
    questions: [
      for (var index = 1; index <= questionCount; index += 1)
        DiagnosticQuizQuestion(
          id: 'question-$index',
          prompt: 'Question $index prompt',
          choices: [
            DiagnosticQuizChoice(id: 'a', label: 'Choix A question $index'),
            DiagnosticQuizChoice(id: 'b', label: 'Choix B question $index'),
          ],
        ),
    ],
  );
}
