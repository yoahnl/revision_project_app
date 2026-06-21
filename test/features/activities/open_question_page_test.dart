import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:Neralune/features/activities/domain/open_question_activity.dart';
import 'package:Neralune/presentation/pages/activities/open_question_page.dart';
import 'package:Neralune/presentation/widgets/revision_button.dart';

void main() {
  testWidgets('renders the open question before submit without correction', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: OpenQuestionPage(
          activity: openQuestionActivity(),
          onSubmit: (_) async => openAnswerReadyResult(),
        ),
      ),
    );

    expect(find.text('Question ouverte'), findsOneWidget);
    expect(find.text('Explique la séparation des pouvoirs.'), findsOneWidget);
    expect(find.text('Réponds en quelques phrases.'), findsOneWidget);
    expect(find.text('0 / 4000'), findsOneWidget);
    expect(find.text('Source 1'), findsOneWidget);
    expect(find.text('Source post-submit sensible.'), findsNothing);
    expect(find.text('Réponse solide.'), findsNothing);
    expect(find.text('Réponse modèle sensible.'), findsNothing);
  });

  testWidgets('keeps submit disabled until the answer is valid', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: OpenQuestionPage(
          activity: openQuestionActivity(),
          onSubmit: (_) async => openAnswerReadyResult(),
        ),
      ),
    );

    final submitButton = find.byType(RevisionButton).last;
    expect(tester.widget<RevisionButton>(submitButton).onPressed, isNull);

    await tester.enterText(find.byType(TextField), 'Trop court');
    await tester.pump();

    expect(find.text('10 / 4000'), findsOneWidget);
    expect(find.text('Réponse trop courte'), findsOneWidget);
    expect(tester.widget<RevisionButton>(submitButton).onPressed, isNull);

    await tester.enterText(find.byType(TextField), 'Réponse assez longue.');
    await tester.pump();

    expect(tester.widget<RevisionButton>(submitButton).onPressed, isNotNull);
  });

  testWidgets('shows loading then READY correction', (tester) async {
    final completer = Completer<OpenAnswerSubmissionResult>();
    await tester.pumpWidget(
      MaterialApp(
        home: OpenQuestionPage(
          activity: openQuestionActivity(),
          onSubmit: (_) => completer.future,
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), 'Réponse assez longue.');
    await tester.ensureVisible(find.text('Valider ma réponse'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Valider ma réponse'));
    await tester.pump();

    expect(find.text('Correction en cours...'), findsNWidgets(2));

    completer.complete(openAnswerReadyResult());
    await tester.pumpAndSettle();

    expect(find.text('Score 16 / 20'), findsOneWidget);
    expect(find.text('Réponse solide.'), findsOneWidget);
    expect(find.textContaining('Définition correcte'), findsOneWidget);
    expect(find.textContaining('Exemple attendu'), findsOneWidget);
    expect(find.textContaining('Confusion à corriger'), findsOneWidget);
    expect(find.text('Réponse modèle sensible.'), findsOneWidget);
    expect(find.text('Ajoute un exemple.'), findsOneWidget);
    expect(find.text('Source post-submit sensible.'), findsOneWidget);
  });

  testWidgets('shows FAILED correction without null score fields', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: OpenQuestionPage(
          activity: openQuestionActivity(),
          onSubmit: (_) async => openAnswerFailedResult(),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), 'Réponse assez longue.');
    await tester.ensureVisible(find.text('Valider ma réponse'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Valider ma réponse'));
    await tester.pumpAndSettle();

    expect(find.text("La correction n'a pas pu être générée."), findsOneWidget);
    expect(find.text('OPEN_ANSWER_EVALUATION_FAILED'), findsOneWidget);
    expect(find.textContaining('Score'), findsNothing);
    expect(find.text('null'), findsNothing);
  });

  testWidgets('shows a clean submit error and keeps the answer', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: OpenQuestionPage(
          activity: openQuestionActivity(),
          onSubmit: (_) async => throw StateError('network failed'),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), 'Réponse assez longue.');
    await tester.ensureVisible(find.text('Valider ma réponse'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Valider ma réponse'));
    await tester.pumpAndSettle();

    expect(
      find.textContaining('La correction a peut-être été enregistrée'),
      findsOneWidget,
    );
    expect(find.text('Réponse assez longue.'), findsOneWidget);
  });

  testWidgets('renders long open question content without layout exceptions', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: SizedBox(
          height: 680,
          child: OpenQuestionPage(activity: longOpenQuestionActivity()),
        ),
      ),
    );

    expect(find.textContaining('Explique longuement'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.byType(TextField),
      220,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.enterText(find.byType(TextField), 'Réponse assez longue.');
    await tester.pump();

    expect(tester.takeException(), isNull);
  });
}

OpenQuestionActivity openQuestionActivity({int maxAnswerLength = 4000}) {
  return OpenQuestionActivity(
    sessionId: 'open-session-1',
    type: 'open_question',
    version: 1,
    subjectId: 'subject-1',
    documentId: 'document-1',
    knowledgeUnitId: 'unit-1',
    question: OpenQuestion(
      id: 'open-question-1',
      prompt: 'Explique la séparation des pouvoirs.',
      instructions: 'Réponds en quelques phrases.',
      maxAnswerLength: maxAnswerLength,
      sources: const [
        OpenQuestionSource(chunkId: 'chunk-1', pageNumber: null, index: 0),
      ],
    ),
  );
}

OpenQuestionActivity longOpenQuestionActivity() {
  return OpenQuestionActivity(
    sessionId: 'open-session-long',
    type: 'open_question',
    version: 1,
    subjectId: 'subject-1',
    documentId: null,
    knowledgeUnitId: 'unit-1',
    question: OpenQuestion(
      id: 'open-question-long',
      prompt: 'Explique longuement ${List.filled(12, 'un principe').join(' ')}.',
      instructions:
          'Structure ta réponse en plusieurs phrases et appuie-toi sur le cours.',
      maxAnswerLength: 4000,
      sources: const [
        OpenQuestionSource(chunkId: 'chunk-1', pageNumber: 2, index: 0),
        OpenQuestionSource(chunkId: 'chunk-2', pageNumber: 3, index: 1),
      ],
    ),
  );
}

OpenAnswerSubmissionResult openAnswerReadyResult() {
  return const OpenAnswerSubmissionResult(
    sessionId: 'open-session-1',
    type: 'open_question',
    status: 'submitted',
    evaluation: OpenAnswerEvaluation(
      id: 'evaluation-1',
      status: OpenAnswerEvaluationStatus.ready,
      score: 16,
      maxScore: 20,
      feedback: 'Réponse solide.',
      presentPoints: ['Définition correcte'],
      missingPoints: ['Exemple attendu'],
      errors: ['Confusion à corriger'],
      modelAnswer: 'Réponse modèle sensible.',
      advice: 'Ajoute un exemple.',
      sources: [
        OpenAnswerCorrectionSource(
          chunkId: 'chunk-1',
          text: 'Source post-submit sensible.',
          pageNumber: null,
          index: 0,
        ),
      ],
    ),
  );
}

OpenAnswerSubmissionResult openAnswerFailedResult() {
  return const OpenAnswerSubmissionResult(
    sessionId: 'open-session-1',
    type: 'open_question',
    status: 'submitted',
    evaluation: OpenAnswerEvaluation(
      id: 'evaluation-1',
      status: OpenAnswerEvaluationStatus.failed,
      score: null,
      maxScore: null,
      feedback: null,
      presentPoints: [],
      missingPoints: [],
      errors: ['OPEN_ANSWER_EVALUATION_FAILED'],
      modelAnswer: null,
      advice: null,
      sources: [],
    ),
  );
}
