import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:Neralune/app/router/app_routes.dart';
import 'package:Neralune/features/courses/application/course_pdf_picker.dart';
import 'package:Neralune/features/courses/application/courses_providers.dart';
import 'package:Neralune/features/courses/domain/course_models.dart';
import 'package:Neralune/features/courses/domain/courses_repository.dart';
import 'package:Neralune/features/courses/presentation/course_detail_page.dart';
import 'package:Neralune/features/documents/domain/source_lifecycle.dart';
import 'package:Neralune/features/revision_sessions/domain/revision_session.dart';
import 'package:Neralune/presentation/design_system/components/revision_mvp_components.dart';

import '../../fakes/in_memory_courses_repository.dart';

void main() {
  testWidgets('course detail uploads a PDF source without fixture content', (
    tester,
  ) async {
    final repository = InMemoryCoursesRepository()
      ..detailsByCourse['course-1'] = courseDetail()
      ..uploadDelay = const Duration(milliseconds: 50);
    final picker = FakeCoursePdfPicker(
      PickedCoursePdf(
        fileName: 'cours.pdf',
        bytes: Uint8List.fromList('%PDF-1.7'.codeUnits),
      ),
    );

    await tester.pumpWidget(testApp(repository: repository, picker: picker));
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pumpAndSettle();

    expect(find.text('Droit constitutionnel'), findsOneWidget);
    expect(find.text('Sources'), findsOneWidget);
    expect(find.text('Loi normale'), findsNothing);
    expect(find.text('78%'), findsNothing);
    expect(find.text('870'), findsNothing);
    expect(find.text('7 jours'), findsNothing);

    await openSourcesSheet(tester);
    await tester.tap(find.bySemanticsLabel('Ajouter une source'));
    await tester.pump();

    expect(find.text('Upload en cours...'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 60));
    await tester.pump();

    expect(repository.uploadCount, 1);
    expect(repository.lastUploadedCourseId, 'course-1');
    expect(repository.lastUploadedFileName, 'cours.pdf');
    expect(find.text('Source ajoutée'), findsOneWidget);
  });

  testWidgets('course detail displays failed source errors', (tester) async {
    final repository = InMemoryCoursesRepository()
      ..detailsByCourse['course-1'] = courseDetail(
        sources: const [
          CourseDocument(
            id: 'document-1',
            courseId: 'course-1',
            documentId: 'document-1',
            fileName: 'broken.pdf',
            status: CourseDocumentStatus.failed,
            errorCode: 'KNOWLEDGE_EXTRACTION_FAILED',
          ),
        ],
      );

    await tester.pumpWidget(
      testApp(repository: repository, picker: FakeCoursePdfPicker(null)),
    );
    await tester.pumpAndSettle();

    await openSourcesSheet(tester);
    expect(find.text('broken.pdf'), findsOneWidget);
    expect(find.textContaining('Analyse du PDF impossible'), findsOneWidget);
    expect(find.textContaining('KNOWLEDGE_EXTRACTION_FAILED'), findsNothing);
    expect(find.textContaining('Code erreur'), findsNothing);
  });

  testWidgets('course detail exposes lifecycle management actions', (
    tester,
  ) async {
    final repository = InMemoryCoursesRepository()
      ..detailsByCourse['course-1'] = courseDetail();

    await tester.pumpWidget(
      testApp(repository: repository, picker: FakeCoursePdfPicker(null)),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(RevisionHeaderActionPill, 'Gérer'));
    await tester.pumpAndSettle();

    expect(repository.getCourseLifecycleCount, 1);
    expect(find.text('Gérer le cours'), findsOneWidget);
    expect(find.text('Renommer'), findsOneWidget);
    expect(find.text('Supprimer'), findsOneWidget);
    expect(find.textContaining('COURSE_DELETE_BLOCKED'), findsNothing);
  });

  testWidgets('source upload button is disabled while upload is in progress', (
    tester,
  ) async {
    final repository = InMemoryCoursesRepository()
      ..detailsByCourse['course-1'] = courseDetail()
      ..uploadDelay = const Duration(milliseconds: 80);
    final picker = FakeCoursePdfPicker(
      PickedCoursePdf(
        fileName: 'cours.pdf',
        bytes: Uint8List.fromList('%PDF-1.7'.codeUnits),
      ),
    );

    await tester.pumpWidget(testApp(repository: repository, picker: picker));
    await tester.pumpAndSettle();

    await openSourcesSheet(tester);
    await tester.tap(find.bySemanticsLabel('Ajouter une source'));
    await tester.pump();

    final addButton = tester.widget<RevisionFloatingAddButton>(
      find.byType(RevisionFloatingAddButton),
    );
    expect(addButton.onTap, isNull);

    await tester.tap(find.bySemanticsLabel('Ajouter une source'));
    await tester.pump(const Duration(milliseconds: 90));
    await tester.pump();

    expect(repository.uploadCount, 1);
  });

  testWidgets('course detail deletes a source after confirmation', (
    tester,
  ) async {
    final repository = InMemoryCoursesRepository()
      ..detailsByCourse['course-1'] = courseDetail(
        sources: const [
          CourseDocument(
            id: 'document-1',
            courseId: 'course-1',
            documentId: 'document-1',
            fileName: 'cours.pdf',
            status: CourseDocumentStatus.ready,
          ),
        ],
      );

    await tester.pumpWidget(
      testApp(repository: repository, picker: FakeCoursePdfPicker(null)),
    );
    await tester.pumpAndSettle();

    await openSourcesSheet(tester);
    expect(find.text('cours.pdf'), findsOneWidget);

    await tester.tap(find.byTooltip('Gérer la source cours.pdf'));
    await tester.pumpAndSettle();

    expect(find.text('Supprimer cette source ?'), findsOneWidget);

    await tester.tap(find.widgetWithText(TextButton, 'Supprimer'));
    await tester.pumpAndSettle();

    expect(repository.deleteDocumentCount, 1);
    expect(repository.lastDeletedDocumentId, 'document-1');
    expect(find.text('Source supprimée'), findsOneWidget);
  });

  testWidgets('course detail archives a used source after confirmation', (
    tester,
  ) async {
    final repository = InMemoryCoursesRepository()
      ..detailsByCourse['course-1'] = courseDetail(
        sources: const [
          CourseDocument(
            id: 'document-1',
            courseId: 'course-1',
            documentId: 'document-1',
            fileName: 'cours.pdf',
            status: CourseDocumentStatus.ready,
          ),
        ],
      )
      ..lifecycleByDocumentId['document-1'] = const SourceLifecycleDecision(
        documentId: 'document-1',
        courseId: 'course-1',
        status: SourceLifecycleStatus.active,
        recommendedAction: SourceLifecycleAction.archive,
        canDelete: false,
        canArchive: true,
        blockingReasons: ['HAS_KNOWLEDGE_UNITS'],
        userMessage: 'Cette source peut être archivée.',
      );

    await tester.pumpWidget(
      testApp(repository: repository, picker: FakeCoursePdfPicker(null)),
    );
    await tester.pumpAndSettle();

    await openSourcesSheet(tester);
    await tester.tap(find.byTooltip('Gérer la source cours.pdf'));
    await tester.pumpAndSettle();

    expect(find.text('Archiver cette source ?'), findsOneWidget);
    expect(find.textContaining('historique déjà créé'), findsOneWidget);

    await tester.tap(find.widgetWithText(TextButton, 'Archiver'));
    await tester.pumpAndSettle();

    expect(repository.archiveDocumentCount, 1);
    expect(repository.lastArchivedDocumentId, 'document-1');
    expect(find.text('Source archivée'), findsOneWidget);
  });

  testWidgets('course detail shows an error when source deletion fails', (
    tester,
  ) async {
    final repository = InMemoryCoursesRepository()
      ..detailsByCourse['course-1'] = courseDetail(
        sources: const [
          CourseDocument(
            id: 'document-1',
            courseId: 'course-1',
            documentId: 'document-1',
            fileName: 'cours.pdf',
            status: CourseDocumentStatus.ready,
          ),
        ],
      )
      ..deleteDocumentError = const CourseNotFoundException(
        'Course source not found',
      );

    await tester.pumpWidget(
      testApp(repository: repository, picker: FakeCoursePdfPicker(null)),
    );
    await tester.pumpAndSettle();

    await openSourcesSheet(tester);
    await tester.tap(find.byTooltip('Gérer la source cours.pdf'));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(TextButton, 'Supprimer'));
    await tester.pumpAndSettle();

    expect(repository.deleteDocumentCount, 0);
    expect(find.text('Impossible de supprimer cette source.'), findsWidgets);
    expect(find.text('cours.pdf'), findsOneWidget);
  });

  testWidgets('course detail displays no-source progress state', (
    tester,
  ) async {
    final repository = InMemoryCoursesRepository()
      ..detailsByCourse['course-1'] = courseDetail()
      ..progressByCourse['course-1'] = courseProgress(
        state: CourseProgressState.noSource,
        knowledgeUnitCount: 0,
        practicedKnowledgeUnitCount: 0,
        coverage: 0,
        mastery: null,
        estimatedGlobalMastery: 0,
        readySourceCount: 0,
      );

    await tester.pumpWidget(
      testApp(repository: repository, picker: FakeCoursePdfPicker(null)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Progression'), findsWidgets);
    expect(find.text('0/0 notions travaillées'), findsOneWidget);
    expect(find.text('Ajoute une source pour commencer.'), findsOneWidget);
    expect(find.text('78%'), findsNothing);
  });

  testWidgets('course detail displays practiced real progress', (tester) async {
    final repository = InMemoryCoursesRepository()
      ..detailsByCourse['course-1'] = courseDetail(
        sources: const [
          CourseDocument(
            id: 'document-1',
            courseId: 'course-1',
            documentId: 'document-1',
            fileName: 'ready.pdf',
            status: CourseDocumentStatus.ready,
          ),
        ],
      )
      ..progressByCourse['course-1'] = courseProgress();

    await tester.pumpWidget(
      testApp(repository: repository, picker: FakeCoursePdfPicker(null)),
    );
    await tester.pumpAndSettle();

    expect(find.text('3/12 notions travaillées'), findsOneWidget);
    expect(find.text('Maîtrise sur notions travaillées : 72%'), findsOneWidget);
    expect(find.text('Estimation globale : 18%'), findsOneWidget);
    expect(find.text('Progression basée sur tes réponses.'), findsOneWidget);
  });

  testWidgets('processing sources trigger bounded detail refresh polling', (
    tester,
  ) async {
    final repository = InMemoryCoursesRepository()
      ..detailsByCourse['course-1'] = courseDetail(
        sources: const [
          CourseDocument(
            id: 'document-1',
            courseId: 'course-1',
            documentId: 'document-1',
            fileName: 'processing.pdf',
            status: CourseDocumentStatus.processing,
          ),
        ],
      );

    await tester.pumpWidget(
      testApp(repository: repository, picker: FakeCoursePdfPicker(null)),
    );
    await tester.pump();
    await tester.pump();

    expect(repository.getCourseCount, 1);
    expect(repository.getCourseProgressCount, 1);
    await openSourcesSheet(tester);
    expect(find.text('Traitement en cours'), findsOneWidget);

    await tester.pump(const Duration(seconds: 2));
    await tester.pump();

    expect(repository.getCourseCount, greaterThanOrEqualTo(2));
    expect(repository.getCourseProgressCount, greaterThanOrEqualTo(2));
  });

  testWidgets('ready failed and empty sources do not trigger polling', (
    tester,
  ) async {
    for (final sources in [
      const <CourseDocument>[],
      const [
        CourseDocument(
          id: 'document-ready',
          courseId: 'course-1',
          documentId: 'document-ready',
          fileName: 'ready.pdf',
          status: CourseDocumentStatus.ready,
        ),
      ],
      const [
        CourseDocument(
          id: 'document-failed',
          courseId: 'course-1',
          documentId: 'document-failed',
          fileName: 'failed.pdf',
          status: CourseDocumentStatus.failed,
          errorCode: 'KNOWLEDGE_EXTRACTION_FAILED',
        ),
      ],
    ]) {
      final repository = InMemoryCoursesRepository()
        ..detailsByCourse['course-1'] = courseDetail(sources: sources);

      await tester.pumpWidget(
        testApp(repository: repository, picker: FakeCoursePdfPicker(null)),
      );
      await tester.pump();
      await tester.pump();

      final detailReads = repository.getCourseCount;
      final progressReads = repository.getCourseProgressCount;

      await tester.pump(const Duration(seconds: 2));
      await tester.pump();

      expect(repository.getCourseCount, detailReads);
      expect(repository.getCourseProgressCount, progressReads);
    }
  });

  testWidgets('course sheet CTA asks for a source when none exists', (
    tester,
  ) async {
    final repository = InMemoryCoursesRepository()
      ..detailsByCourse['course-1'] = courseDetail();

    await tester.pumpWidget(
      testApp(repository: repository, picker: FakeCoursePdfPicker(null)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Action recommandée'), findsOneWidget);
    expect(find.text('Ajouter une source'), findsWidgets);
    expect(find.textContaining('MVP+'), findsNothing);
    expect(find.textContaining('backend'), findsNothing);

    final emptySheetPill = tester.widget<RevisionHeaderActionPill>(
      find.widgetWithText(RevisionHeaderActionPill, 'Fiche'),
    );
    expect(emptySheetPill.onTap, isNull);

    await scrollToQuickRevision(tester);
    final emptyQuickCard = tester.widget<RevisionModeCard>(
      find.widgetWithText(RevisionModeCard, 'Révision rapide'),
    );
    expect(emptyQuickCard.enabled, isFalse);
    expect(find.text('Ajoute une source pour réviser'), findsOneWidget);
  });

  testWidgets('course sheet CTA waits while a source is processing', (
    tester,
  ) async {
    final repository = InMemoryCoursesRepository()
      ..detailsByCourse['course-1'] = courseDetail(
        sources: const [
          CourseDocument(
            id: 'document-1',
            courseId: 'course-1',
            documentId: 'document-1',
            fileName: 'processing.pdf',
            status: CourseDocumentStatus.processing,
          ),
        ],
      );

    await tester.pumpWidget(
      testApp(repository: repository, picker: FakeCoursePdfPicker(null)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Action recommandée'), findsOneWidget);
    expect(find.text('Voir les sources'), findsWidgets);
    expect(find.text('Source en analyse'), findsOneWidget);

    final processingSheetPill = tester.widget<RevisionHeaderActionPill>(
      find.widgetWithText(RevisionHeaderActionPill, 'Fiche'),
    );
    expect(processingSheetPill.onTap, isNull);

    await scrollToQuickRevision(tester);
    final processingQuickCard = tester.widget<RevisionModeCard>(
      find.widgetWithText(RevisionModeCard, 'Révision rapide'),
    );
    expect(processingQuickCard.enabled, isFalse);
    expect(find.text('Révision disponible après traitement'), findsOneWidget);
  });

  testWidgets('course sheet CTA is enabled when a READY source exists', (
    tester,
  ) async {
    final repository = InMemoryCoursesRepository()
      ..detailsByCourse['course-1'] = courseDetail(
        sources: const [
          CourseDocument(
            id: 'document-1',
            courseId: 'course-1',
            documentId: 'document-1',
            fileName: 'ready.pdf',
            status: CourseDocumentStatus.ready,
          ),
        ],
      );

    await tester.pumpWidget(
      testApp(repository: repository, picker: FakeCoursePdfPicker(null)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Action recommandée'), findsOneWidget);
    expect(find.text('Réviser maintenant'), findsWidgets);

    final sheetPill = tester.widget<RevisionHeaderActionPill>(
      find.widgetWithText(RevisionHeaderActionPill, 'Fiche'),
    );
    expect(sheetPill.onTap, isNotNull);

    await scrollToQuickRevision(tester);
    final quickCard = tester.widget<RevisionModeCard>(
      find.widgetWithText(RevisionModeCard, 'Révision rapide'),
    );
    expect(quickCard.enabled, isTrue);
  });

  testWidgets(
    'course detail does not offer question preparation when no knowledge unit exists',
    (tester) async {
      final repository = InMemoryCoursesRepository()
        ..detailsByCourse['course-1'] = courseDetail(
          sources: const [
            CourseDocument(
              id: 'document-1',
              courseId: 'course-1',
              documentId: 'document-1',
              fileName: 'ready.pdf',
              status: CourseDocumentStatus.ready,
            ),
          ],
        )
        ..questionBankReadinessByTarget[(
          courseId: 'course-1',
          questionCount: 10,
        )] = const CourseQuestionBankReadiness(
          courseId: 'course-1',
          status: CourseQuestionBankReadinessStatus.noKnowledgeUnits,
          readyQuestionCount: 0,
          targetQuestionCount: 10,
          canStartQuickRevision: false,
          canPrepare: false,
          userMessage:
              "Aucune notion exploitable n'a encore été trouvée pour ce cours.",
        );

      await tester.pumpWidget(
        testApp(repository: repository, picker: FakeCoursePdfPicker(null)),
      );
      await tester.pumpAndSettle();

      expect(find.text('Préparer les questions'), findsNothing);
      expect(
        find.textContaining("Aucune notion exploitable n'a encore été trouvée"),
        findsWidgets,
      );
    },
  );

  testWidgets(
    'quick revision shows partial readiness without contradictory CTA',
    (tester) async {
      final repository = InMemoryCoursesRepository()
        ..detailsByCourse['course-1'] = courseDetail(
          sources: const [
            CourseDocument(
              id: 'document-1',
              courseId: 'course-1',
              documentId: 'document-1',
              fileName: 'ready.pdf',
              status: CourseDocumentStatus.ready,
            ),
          ],
        )
        ..questionBankReadinessByTarget[(
          courseId: 'course-1',
          questionCount: 5,
        )] = const CourseQuestionBankReadiness(
          courseId: 'course-1',
          status: CourseQuestionBankReadinessStatus.ready,
          readyQuestionCount: 9,
          targetQuestionCount: 5,
          canStartQuickRevision: true,
          canPrepare: false,
          userMessage: 'Les questions sont prêtes.',
        )
        ..questionBankReadinessByTarget[(
          courseId: 'course-1',
          questionCount: 10,
        )] = const CourseQuestionBankReadiness(
          courseId: 'course-1',
          status: CourseQuestionBankReadinessStatus.preparing,
          readyQuestionCount: 9,
          targetQuestionCount: 10,
          canStartQuickRevision: false,
          canPrepare: false,
          userMessage:
              'Les questions sont en préparation. Réessaie dans un instant.',
        )
        ..questionBankReadinessByTarget[(
          courseId: 'course-1',
          questionCount: 20,
        )] = const CourseQuestionBankReadiness(
          courseId: 'course-1',
          status: CourseQuestionBankReadinessStatus.notPrepared,
          readyQuestionCount: 9,
          targetQuestionCount: 20,
          canStartQuickRevision: false,
          canPrepare: true,
          userMessage:
              'Les questions doivent être préparées avant de commencer.',
        )
        ..questionBankReadinessByTarget[(
          courseId: 'course-1',
          questionCount: 30,
        )] = const CourseQuestionBankReadiness(
          courseId: 'course-1',
          status: CourseQuestionBankReadinessStatus.notPrepared,
          readyQuestionCount: 9,
          targetQuestionCount: 30,
          canStartQuickRevision: false,
          canPrepare: true,
          userMessage:
              'Les questions doivent être préparées avant de commencer.',
        );

      await tester.pumpWidget(
        testApp(repository: repository, picker: FakeCoursePdfPicker(null)),
      );
      await tester.pumpAndSettle();

      expect(find.text('Réviser maintenant'), findsWidgets);
      expect(
        find.text(
          "Une session rapide peut démarrer maintenant. D'autres questions sont en préparation.",
        ),
        findsWidgets,
      );
      expect(find.text('9 questions prêtes.'), findsNothing);
      expect(find.text('Commencer une session rapide'), findsNothing);

      await scrollToQuickRevision(tester);
      final quickCard = tester.widget<RevisionModeCard>(
        find.widgetWithText(RevisionModeCard, 'Révision rapide'),
      );
      expect(quickCard.enabled, isTrue);

      await tester.tap(
        find.widgetWithText(RevisionModeCard, 'Révision rapide'),
      );
      await tester.pumpAndSettle();

      expect(find.text('5 questions'), findsOneWidget);
      expect(find.text('10 questions'), findsOneWidget);
      expect(find.text('20 questions'), findsOneWidget);
      expect(find.text('30 questions'), findsOneWidget);
      expect(find.text('Prêt'), findsWidgets);
      expect(find.text('9 prêtes'), findsNothing);
      expect(find.text('En préparation'), findsOneWidget);
      expect(find.text('À préparer'), findsNWidgets(2));

      await tester.tap(find.text('Démarrer'));
      await tester.pump();

      expect(repository.startQuickRevisionCount, 1);
      expect(repository.lastQuickRevisionQuestionCount, 5);
    },
  );

  testWidgets('ready quick revision starts the real revision session route', (
    tester,
  ) async {
    final repository = InMemoryCoursesRepository()
      ..detailsByCourse['course-1'] = courseDetail(
        sources: const [
          CourseDocument(
            id: 'document-1',
            courseId: 'course-1',
            documentId: 'document-1',
            fileName: 'ready.pdf',
            status: CourseDocumentStatus.ready,
          ),
        ],
      )
      ..quickRevisionDelay = const Duration(milliseconds: 50);

    await tester.pumpWidget(
      routerTestApp(repository: repository, picker: FakeCoursePdfPicker(null)),
    );
    await tester.pumpAndSettle();
    await scrollToQuickRevision(tester);

    final quickButton = find.widgetWithText(
      RevisionModeCard,
      'Révision rapide',
    );
    await tester.tap(quickButton);
    await tester.pumpAndSettle();

    expect(
      find.text('Choisis une quantité disponible ou prépare la suite.'),
      findsOneWidget,
    );
    await tester.tap(find.text('20 questions'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Démarrer'));
    await tester.pump();

    expect(find.text('Préparation des questions'), findsOneWidget);
    expect(
      find.text('20 questions sont préparées pour ta session.'),
      findsOneWidget,
    );
    expect(find.text('Préparation...'), findsOneWidget);

    await tester.pumpAndSettle();

    expect(repository.startQuickRevisionCount, 1);
    expect(repository.lastQuickRevisionCourseId, 'course-1');
    expect(repository.lastQuickRevisionQuestionCount, 20);
    expect(find.text('Session réelle'), findsOneWidget);
  });

  testWidgets('course detail shows an empty completed history state', (
    tester,
  ) async {
    final repository = InMemoryCoursesRepository()
      ..detailsByCourse['course-1'] = courseDetail();

    await tester.pumpWidget(
      testApp(repository: repository, picker: FakeCoursePdfPicker(null)),
    );
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(find.text('Historique'), 400);
    await tester.pumpAndSettle();

    expect(find.text('Historique'), findsOneWidget);
    expect(find.text('Aucune session terminée pour ce cours.'), findsOneWidget);
    expect(repository.getCourseRevisionSessionHistoryCount, 1);
    expect(repository.getCourseRichClosedHistoryCount, 1);
    expect(repository.getCourseExamPreparationHistoryCount, 1);
  });

  testWidgets('course detail opens a completed session result from history', (
    tester,
  ) async {
    final repository = InMemoryCoursesRepository()
      ..detailsByCourse['course-1'] = courseDetail()
      ..revisionSessionHistoryByCourse['course-1'] = [
        revisionSessionHistoryItem(),
      ];

    await tester.pumpWidget(
      routerTestApp(repository: repository, picker: FakeCoursePdfPicker(null)),
    );
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(find.text('Voir le résultat'), 400);
    await tester.pumpAndSettle();

    expect(find.text('Historique'), findsOneWidget);
    expect(find.text('4/5'), findsOneWidget);
    expect(find.textContaining('80 %'), findsOneWidget);

    await tester.tap(find.text('Voir le résultat'));
    await tester.pumpAndSettle();

    expect(find.text('Résultat de session'), findsOneWidget);
  });

  testWidgets('course detail opens a rich closed result from history', (
    tester,
  ) async {
    final repository = InMemoryCoursesRepository()
      ..detailsByCourse['course-1'] = courseDetail()
      ..richClosedHistoryByCourse['course-1'] = [richClosedHistoryItem()];

    await tester.pumpWidget(
      routerTestApp(repository: repository, picker: FakeCoursePdfPicker(null)),
    );
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(find.text('5/6'), 400);
    await tester.pumpAndSettle();

    expect(find.text('Historique'), findsOneWidget);
    expect(find.text('5/6'), findsOneWidget);
    expect(find.textContaining('83 %'), findsOneWidget);

    await tester.tap(find.text('Voir le résultat'));
    await tester.pumpAndSettle();

    expect(find.text('Résultat questions riches'), findsOneWidget);
  });

  testWidgets('course detail opens an exam result from history', (
    tester,
  ) async {
    final repository = InMemoryCoursesRepository()
      ..detailsByCourse['course-1'] = courseDetail()
      ..examPreparationHistoryByCourse['course-1'] = [
        revisionSessionHistoryItem(
          sessionId: 'exam-session-1',
          correctAnswers: 9,
          totalQuestions: 10,
          score: 0.9,
          mode: RevisionSessionMode.exam,
        ),
      ];

    await tester.pumpWidget(
      routerTestApp(repository: repository, picker: FakeCoursePdfPicker(null)),
    );
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(find.text('9/10'), 400);
    await tester.pumpAndSettle();

    expect(find.text('Historique'), findsOneWidget);
    expect(find.text('9/10'), findsOneWidget);
    expect(find.textContaining('Entraînement examen'), findsOneWidget);
    expect(find.textContaining('90 %'), findsOneWidget);

    await tester.tap(find.text('Voir le résultat'));
    await tester.pumpAndSettle();

    expect(find.text('Résultat examen'), findsOneWidget);
  });

  testWidgets(
    'course detail opens the exam preparation page from a real card',
    (tester) async {
      final repository = InMemoryCoursesRepository()
        ..detailsByCourse['course-1'] = courseDetail(
          sources: const [
            CourseDocument(
              id: 'document-1',
              courseId: 'course-1',
              documentId: 'document-1',
              fileName: 'CM.pdf',
              status: CourseDocumentStatus.ready,
            ),
          ],
        )
        ..examPreparationOptionsByCourse['course-1'] =
            examPreparationOptionsFixture();

      await tester.pumpWidget(
        routerTestApp(
          repository: repository,
          picker: FakeCoursePdfPicker(null),
        ),
      );
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(find.text('Préparation examen'), 400);
      await tester.pumpAndSettle();

      await tester.tap(
        find.widgetWithText(RevisionModeCard, 'Préparation examen'),
      );
      await tester.pumpAndSettle();

      expect(find.text('Préparation examen dédiée'), findsOneWidget);
    },
  );

  testWidgets('course detail prioritizes a resumable quick session', (
    tester,
  ) async {
    final response = quickRevisionSessionResponse('course-1');
    final repository = InMemoryCoursesRepository()
      ..detailsByCourse['course-1'] = courseDetail(
        sources: const [
          CourseDocument(
            id: 'document-1',
            courseId: 'course-1',
            documentId: 'document-1',
            fileName: 'ready.pdf',
            status: CourseDocumentStatus.ready,
          ),
        ],
      )
      ..resumableRevisionSessionByCourse['course-1'] =
          ResumableCourseRevisionSession(
            session: response.session,
            currentAction: response.currentAction,
            progress: const ResumableCourseRevisionProgress(
              answeredQuestionCount: 2,
              totalQuestionCount: 5,
            ),
            userMessage: 'Tu as une session en cours.',
          );

    await tester.pumpWidget(
      routerTestApp(repository: repository, picker: FakeCoursePdfPicker(null)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Reprendre la session'), findsOneWidget);
    expect(find.text('2/5 réponses sauvegardées.'), findsOneWidget);

    await tester.tap(find.widgetWithText(RevisionGradientButton, 'Reprendre'));
    await tester.pumpAndSettle();

    expect(repository.startQuickRevisionCount, 0);
    expect(find.text('Session réelle'), findsOneWidget);
  });
}

Future<void> openSourcesSheet(WidgetTester tester) async {
  await tester.tap(find.widgetWithText(RevisionHeaderActionPill, 'Sources'));
  await tester.pumpAndSettle();
}

Future<void> scrollToQuickRevision(WidgetTester tester) async {
  await tester.scrollUntilVisible(find.text('Révision rapide'), 400);
  await tester.pumpAndSettle();
}

Widget testApp({
  required InMemoryCoursesRepository repository,
  required CoursePdfPicker picker,
}) {
  _ensureDefaultProgress(repository);

  return ProviderScope(
    overrides: [
      coursesRepositoryProvider.overrideWithValue(repository),
      coursePdfPickerProvider.overrideWithValue(picker),
    ],
    child: const MaterialApp(
      home: Scaffold(body: CourseDetailPage(courseId: 'course-1')),
    ),
  );
}

Widget routerTestApp({
  required InMemoryCoursesRepository repository,
  required CoursePdfPicker picker,
}) {
  _ensureDefaultProgress(repository);

  final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) =>
            const Scaffold(body: CourseDetailPage(courseId: 'course-1')),
      ),
      GoRoute(
        path: AppRoutes.revisionSessionV2Path,
        builder: (context, state) => Scaffold(
          body: Text(
            state.pathParameters['sessionId'] == 'revision-session-1'
                ? 'Session réelle'
                : 'Session inconnue',
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.revisionSessionResultV2Path,
        builder: (context, state) => Scaffold(
          body: Text(
            state.pathParameters['sessionId'] == 'exam-session-1' &&
                    state.uri.queryParameters['mode'] == 'exam'
                ? 'Résultat examen'
                : state.pathParameters['sessionId'] == 'revision-session-1'
                ? 'Résultat de session'
                : 'Résultat introuvable',
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.richClosedExerciseResultPath,
        builder: (context, state) => Scaffold(
          body: Text(
            state.pathParameters['sessionId'] == 'rich-session-1' &&
                    state.uri.queryParameters['courseId'] == 'course-1'
                ? 'Résultat questions riches'
                : 'Résultat introuvable',
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.courseExamPreparationPath,
        builder: (context, state) =>
            const Scaffold(body: Text('Préparation examen dédiée')),
      ),
    ],
  );

  return ProviderScope(
    overrides: [
      coursesRepositoryProvider.overrideWithValue(repository),
      coursePdfPickerProvider.overrideWithValue(picker),
    ],
    child: MaterialApp.router(routerConfig: router),
  );
}

void _ensureDefaultProgress(InMemoryCoursesRepository repository) {
  repository.progressByCourse.putIfAbsent(
    'course-1',
    () => courseProgress(
      state: CourseProgressState.noSource,
      knowledgeUnitCount: 0,
      practicedKnowledgeUnitCount: 0,
      coverage: 0,
      mastery: null,
      estimatedGlobalMastery: 0,
      readySourceCount: 0,
    ),
  );
}

CourseDetail courseDetail({List<CourseDocument> sources = const []}) {
  const course = CourseListItem(
    id: 'course-1',
    subjectId: 'subject-1',
    title: 'Droit constitutionnel',
    sourceCount: 0,
    readySourceCount: 0,
    processingSourceCount: 0,
    failedSourceCount: 0,
  );
  return CourseDetail(
    course: course,
    subject: const CourseSubjectSummary(id: 'subject-1', name: 'Droit'),
    sources: sources,
  );
}

CourseProgress courseProgress({
  CourseProgressState state = CourseProgressState.practiced,
  int knowledgeUnitCount = 12,
  int practicedKnowledgeUnitCount = 3,
  double coverage = 0.25,
  double? mastery = 0.72,
  double estimatedGlobalMastery = 0.18,
  int readySourceCount = 1,
}) {
  return CourseProgress(
    courseId: 'course-1',
    subjectId: 'subject-1',
    knowledgeUnitCount: knowledgeUnitCount,
    practicedKnowledgeUnitCount: practicedKnowledgeUnitCount,
    coverage: coverage,
    mastery: mastery,
    estimatedGlobalMastery: estimatedGlobalMastery,
    readySourceCount: readySourceCount,
    processingSourceCount: 0,
    failedSourceCount: 0,
    lastPracticedAt: DateTime.utc(2026, 6, 18, 12),
    state: state,
  );
}

RevisionSessionHistoryItem revisionSessionHistoryItem({
  String sessionId = 'revision-session-1',
  int correctAnswers = 4,
  int totalQuestions = 5,
  double score = 0.8,
  RevisionSessionMode mode = RevisionSessionMode.quick,
}) {
  return RevisionSessionHistoryItem(
    session: RevisionSessionResultSession(
      id: sessionId,
      subjectId: 'subject-1',
      courseId: 'course-1',
      mode: mode,
      status: RevisionSessionStatus.completed,
      createdAt: DateTime.utc(2026, 6, 18, 10),
      completedAt: DateTime.utc(2026, 6, 18, 10, 7),
    ),
    summary: RevisionSessionResultSummary(
      correctAnswers: correctAnswers,
      totalQuestions: totalQuestions,
      score: score,
      durationSeconds: 420,
    ),
    course: const RevisionSessionHistoryCourse(
      id: 'course-1',
      title: 'Droit constitutionnel',
    ),
  );
}

CourseRichClosedHistoryItem richClosedHistoryItem({
  String sessionId = 'rich-session-1',
  int correctAnswers = 5,
  int totalQuestions = 6,
  double score = 0.833,
}) {
  return CourseRichClosedHistoryItem(
    id: sessionId,
    sessionId: sessionId,
    type: 'rich_closed_exercise',
    status: 'completed',
    title: 'Questions riches - Constitution',
    subjectId: 'subject-1',
    documentId: 'document-1',
    knowledgeUnit: const CourseRichClosedHistoryKnowledgeUnit(
      id: 'unit-1',
      title: 'Séparation des pouvoirs',
    ),
    course: const CourseRichClosedHistoryCourse(
      id: 'course-1',
      title: 'Droit constitutionnel',
    ),
    correctAnswers: correctAnswers,
    totalQuestions: totalQuestions,
    score: score,
    completedAt: DateTime.utc(2026, 6, 18, 10, 7),
    resultPath: '/activities/rich-closed/$sessionId/result',
  );
}

CourseExamPreparationOptions examPreparationOptionsFixture({
  CourseExamPreparationReadinessState state =
      CourseExamPreparationReadinessState.ready,
}) {
  return CourseExamPreparationOptions(
    course: const CourseExamPreparationCourse(
      id: 'course-1',
      title: 'Droit constitutionnel',
      subjectId: 'subject-1',
    ),
    readiness: CourseExamPreparationReadiness(
      canPrepare: state == CourseExamPreparationReadinessState.ready,
      state: state,
      userMessage: 'Ton cours est prêt pour une préparation examen.',
      blockers: const [],
      readySourceCount: 1,
      readyKnowledgeUnitCount: 2,
      availableQuestionCount: 20,
    ),
    scopeOptions: const [
      CourseExamPreparationScopeOption(
        kind: CourseExamPreparationScopeKind.course,
        id: 'course-1',
        label: 'Tout le cours',
        readyQuestionCount: 20,
        readyKnowledgeUnitCount: 2,
        canSelect: true,
      ),
    ],
    questionCountOptions: const [10, 20],
    defaultQuestionCount: 20,
    supportedQuestionKinds: const ['single_choice', 'multiple_choice'],
    defaultConfig: const CourseExamPreparationConfig(
      scopeKind: CourseExamPreparationScopeKind.course,
      scopeId: 'course-1',
      questionCount: 20,
      complexityProfile: 'exam',
    ),
    nextStep: const CourseExamPreparationNextStep(
      kind: 'configuration_ready',
      userMessage:
          'Configuration prête. Tu peux démarrer un entraînement examen.',
    ),
  );
}

class FakeCoursePdfPicker implements CoursePdfPicker {
  FakeCoursePdfPicker(this.result);

  final PickedCoursePdf? result;

  @override
  Future<PickedCoursePdf?> pickPdf() async => result;
}
