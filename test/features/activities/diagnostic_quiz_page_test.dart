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

  testWidgets('renders v3 visuals and multiple selection without leaks', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: DiagnosticQuizPage(
          activity: v3MediaActivity(),
          onSubmit: (_) async => v3MediaResult(),
        ),
      ),
    );

    expect(find.text('Plusieurs réponses possibles'), findsOneWidget);
    expect(find.text('Contrôles'), findsOneWidget);
    expect(find.text('Répartition des éléments'), findsOneWidget);
    expect(find.text('Contrôle'), findsNWidgets(2));
    expect(find.text('Relations'), findsOneWidget);
    expect(find.text('Pouvoir'), findsOneWidget);
    expect(find.text('Visuel IMAGE indisponible'), findsOneWidget);
    expect(
      find.text('Réponses attendues: Contrôle juridictionnel'),
      findsNothing,
    );
    expect(find.text('Explication multi post-submit.'), findsNothing);
    expect(find.text('Feedback multi post-submit.'), findsNothing);
    expect(find.text('Source multi post-submit.'), findsNothing);
  });

  testWidgets('submits multiple answers and shows v3 correction', (
    tester,
  ) async {
    final submittedAnswers = <DiagnosticQuizAnswer>[];

    await tester.pumpWidget(
      MaterialApp(
        home: DiagnosticQuizPage(
          activity: v3MediaActivity(),
          onSubmit: (answers) async {
            submittedAnswers.addAll(answers);

            return v3MediaResult();
          },
        ),
      ),
    );

    await tester.scrollUntilVisible(
      find.text('Valider'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    final submitButton = find.byType(RevisionButton);
    expect(tester.widget<RevisionButton>(submitButton).onPressed, isNull);

    await tester.scrollUntilVisible(
      find.text('Contrôle juridictionnel'),
      -300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Contrôle juridictionnel'));
    await tester.pump();
    await tester.tap(find.text('Séparation des pouvoirs'));
    await tester.pump();
    await tester.scrollUntilVisible(
      find.text('Valider'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(tester.widget<RevisionButton>(submitButton).onPressed, isNotNull);

    await tester.tap(find.text('Valider'));
    await tester.pumpAndSettle();

    expect(submittedAnswers.single.choiceId, isNull);
    expect(submittedAnswers.single.choiceIds, ['a', 'c']);
    expect(
      find.text(
        'Réponses sélectionnées: Contrôle juridictionnel, Séparation des pouvoirs',
      ),
      findsOneWidget,
    );
    expect(
      find.text('Réponses attendues: Contrôle juridictionnel, État de droit'),
      findsOneWidget,
    );
    expect(find.text('Score partiel 50 %'), findsOneWidget);
    expect(find.text('Explication multi post-submit.'), findsOneWidget);
    expect(find.textContaining('Feedback multi post-submit.'), findsOneWidget);
    expect(find.text('Source multi post-submit.'), findsOneWidget);
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
            activity: longActivity(questionCount: 20),
            onSubmit: (_) async => const DiagnosticQuizResult(
              correctAnswers: 20,
              totalQuestions: 20,
            ),
          ),
        ),
      ),
    );

    expect(find.text('20 questions'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Question 20 prompt'),
      600,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Question 20 prompt'), findsOneWidget);
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

DiagnosticQuizActivity v3MediaActivity() {
  return const DiagnosticQuizActivity(
    sessionId: 'session-v3',
    title: 'Diagnostic v3',
    version: 3,
    documentId: 'document-1',
    subjectId: 'subject-1',
    questions: [
      DiagnosticQuizQuestion(
        id: 'question-multiple',
        knowledgeUnitId: 'unit-1',
        prompt: 'Quels éléments contrôlent le pouvoir ?',
        difficulty: 'MEDIUM',
        selectionMode: DiagnosticQuizSelectionMode.multiple,
        minSelections: 2,
        maxSelections: 2,
        choices: [
          DiagnosticQuizChoice(id: 'a', label: 'Contrôle juridictionnel'),
          DiagnosticQuizChoice(id: 'b', label: 'Pouvoir absolu'),
          DiagnosticQuizChoice(id: 'c', label: 'Séparation des pouvoirs'),
          DiagnosticQuizChoice(id: 'd', label: 'État de droit'),
        ],
        sources: [
          DiagnosticQuizSourceRef(
            chunkId: 'chunk-1',
            pageNumber: null,
            index: 0,
          ),
        ],
        visuals: [
          DiagnosticQuizChartVisual(
            id: 'visual-chart',
            displayOrder: 0,
            chartType: DiagnosticQuizChartType.bar,
            title: 'Contrôles',
            description: 'Répartition des éléments',
            data: [
              {'category': 'Contrôle', 'value': 2},
            ],
            xKey: 'category',
            yKeys: ['value'],
            sources: [
              DiagnosticQuizSourceRef(
                chunkId: 'chunk-1',
                pageNumber: null,
                index: 0,
              ),
            ],
          ),
          DiagnosticQuizDiagramVisual(
            id: 'visual-diagram',
            displayOrder: 1,
            title: 'Relations',
            nodes: [
              DiagnosticQuizDiagramNode(id: 'n1', label: 'Pouvoir'),
              DiagnosticQuizDiagramNode(id: 'n2', label: 'Contrôle'),
            ],
            edges: [
              DiagnosticQuizDiagramEdge(from: 'n1', to: 'n2', label: 'limite'),
            ],
            sources: [
              DiagnosticQuizSourceRef(
                chunkId: 'chunk-1',
                pageNumber: null,
                index: 0,
              ),
            ],
          ),
          DiagnosticQuizUnsupportedVisual(
            id: 'visual-image',
            displayOrder: 2,
            type: 'IMAGE',
          ),
        ],
      ),
    ],
  );
}

DiagnosticQuizResult v3MediaResult() {
  return const DiagnosticQuizResult(
    correctAnswers: 0,
    totalQuestions: 1,
    score: 0,
    items: [
      DiagnosticQuizCorrectionItem(
        questionId: 'question-multiple',
        knowledgeUnitId: 'unit-1',
        prompt: 'Quels éléments contrôlent le pouvoir ?',
        selectedChoiceIds: ['a', 'c'],
        correctChoiceIds: ['a', 'd'],
        isCorrect: false,
        partialScore: 0.5,
        explanation: 'Explication multi post-submit.',
        choiceFeedback: [
          DiagnosticQuizChoiceFeedback(
            choiceId: 'c',
            feedback: 'Feedback multi post-submit.',
          ),
        ],
        sources: [
          DiagnosticQuizCorrectionSource(
            chunkId: 'chunk-1',
            text: 'Source multi post-submit.',
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
