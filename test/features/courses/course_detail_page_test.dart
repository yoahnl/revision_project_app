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
import 'package:Neralune/features/courses/presentation/course_hero_tags.dart';
import 'package:Neralune/features/courses/presentation/course_detail_page.dart';
import 'package:Neralune/features/documents/domain/revision_document.dart';
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
    expect(find.byTooltip('Plus d’actions'), findsOneWidget);
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

  testWidgets('course detail shows the V4 path-first layout', (tester) async {
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
      ..learningPathByCourse['course-1'] = courseLearningPathFixture();

    await tester.pumpWidget(
      testApp(repository: repository, picker: FakeCoursePdfPicker(null)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Droit constitutionnel'), findsOneWidget);
    expect(find.byTooltip('Retour'), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Hero && widget.tag == CourseHeroTags.navigationControl(),
      ),
      findsOneWidget,
    );
    expect(find.byTooltip('Plus d’actions'), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Hero &&
            widget.tag == CourseHeroTags.subjectOverview('subject-1'),
      ),
      findsOneWidget,
    );
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Hero &&
            widget.tag == CourseHeroTags.learningPath('course-1'),
      ),
      findsOneWidget,
    );
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Hero && widget.tag == CourseHeroTags.card('course-1'),
      ),
      findsNothing,
    );
    expect(find.byKey(const ValueKey('course-detail-luna')), findsOneWidget);
    expect(repository.getCourseLearningPathCount, 1);
    expect(find.text('62%'), findsOneWidget);
    expect(find.text('Continuer'), findsWidgets);
    expect(find.text('Parcours'), findsOneWidget);
    expect(find.text('La séparation des pouvoirs'), findsOneWidget);
    expect(find.textContaining('À renforcer'), findsOneWidget);
    expect(find.text('Comprendre'), findsOneWidget);
    expect(find.text('Réviser ce cours'), findsOneWidget);
    expect(find.text('Modes de révision'), findsNothing);
    expect(find.text('Historique'), findsNothing);
    expect(find.text('Temps estimé : À préciser'), findsNothing);
    expect(find.text('Difficulté : À préciser'), findsNothing);
    expect(find.text('La Constitution'), findsNothing);
  });

  testWidgets('course detail primary CTA opens the duration sheet', (
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
      ..learningPathByCourse['course-1'] = courseLearningPathFixture();

    await tester.pumpWidget(
      testApp(repository: repository, picker: FakeCoursePdfPicker(null)),
    );
    await tester.pumpAndSettle();

    await tester.tap(
      find.widgetWithText(RevisionGradientButton, 'Continuer').first,
    );
    await tester.pumpAndSettle();

    expect(find.text('Combien de temps as-tu ?'), findsOneWidget);
    expect(find.text('5 min'), findsOneWidget);
    expect(find.text('15 min'), findsOneWidget);
    expect(find.text('30 min'), findsOneWidget);
    expect(find.text('Commencer'), findsOneWidget);
  });

  testWidgets('course detail displays backend learning path empty state', (
    tester,
  ) async {
    final repository = InMemoryCoursesRepository()
      ..detailsByCourse['course-1'] = courseDetail()
      ..learningPathByCourse['course-1'] = courseLearningPathFixture(
        nodes: const [],
        activeNodeId: null,
        emptyState: const CourseLearningPathEmptyState(
          title: 'Ajoute une source',
          message:
              'Ajoute un PDF pour que Neralune prépare le parcours de ce cours.',
          actionLabel: 'Ajouter une source',
          actionKind: CourseLearningPathEmptyActionKind.addSource,
        ),
      );

    await tester.pumpWidget(
      testApp(repository: repository, picker: FakeCoursePdfPicker(null)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Ajoute une source'), findsWidgets);
    expect(
      find.text(
        'Ajoute un PDF pour que Neralune prépare le parcours de ce cours.',
      ),
      findsOneWidget,
    );
    expect(find.text('La séparation des pouvoirs'), findsNothing);
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

    await openManagementSheet(tester);

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
      )
      ..richRevisionOptionsByCourse['course-1'] = richRevisionOptionsFixture()
      ..deepRevisionOptionsByCourse['course-1'] = deepRevisionOptionsFixture();

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
      ..learningPathByCourse['course-1'] = courseLearningPathFixture(
        nodes: const [],
        activeNodeId: null,
        primaryAction: const CourseLearningPathPrimaryAction(
          kind: CourseLearningPathPrimaryActionKind.addSource,
          label: 'Ajouter une source',
          description: 'Ajoute un PDF pour préparer le parcours de ce cours.',
          enabled: true,
        ),
        emptyState: const CourseLearningPathEmptyState(
          title: 'Parcours du cours',
          message:
              'Les notions détaillées seront affichées dès que le parcours sera disponible.',
          actionLabel: 'Ajouter une source',
          actionKind: CourseLearningPathEmptyActionKind.addSource,
        ),
      )
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

    expect(find.text('Parcours'), findsOneWidget);
    expect(find.text('Parcours du cours'), findsOneWidget);
    expect(
      find.text(
        'Les notions détaillées seront affichées dès que le parcours sera disponible.',
      ),
      findsOneWidget,
    );
    expect(find.text('0/0 notions travaillées'), findsNothing);
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

    expect(find.text('62%'), findsOneWidget);
    expect(find.text('maîtrisé'), findsOneWidget);
    expect(find.text('Parcours'), findsOneWidget);
    expect(find.text('3/12 notions travaillées'), findsNothing);
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
    expect(repository.getCourseLearningPathCount, 1);
    await openSourcesSheet(tester);
    expect(find.text('Traitement en cours'), findsOneWidget);

    await tester.pump(const Duration(seconds: 2));
    await tester.pump();

    expect(repository.getCourseCount, greaterThanOrEqualTo(2));
    expect(repository.getCourseLearningPathCount, greaterThanOrEqualTo(2));
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
      final learningPathReads = repository.getCourseLearningPathCount;

      await tester.pump(const Duration(seconds: 2));
      await tester.pump();

      expect(repository.getCourseCount, detailReads);
      expect(repository.getCourseLearningPathCount, learningPathReads);
    }
  });

  testWidgets('course sheet CTA asks for a source when none exists', (
    tester,
  ) async {
    final repository = InMemoryCoursesRepository()
      ..detailsByCourse['course-1'] = courseDetail()
      ..learningPathByCourse['course-1'] = courseLearningPathFixture(
        nodes: const [],
        activeNodeId: null,
        primaryAction: const CourseLearningPathPrimaryAction(
          kind: CourseLearningPathPrimaryActionKind.addSource,
          label: 'Ajouter une source',
          description: 'Ajoute un PDF pour préparer le parcours de ce cours.',
          enabled: true,
        ),
        emptyState: const CourseLearningPathEmptyState(
          title: 'Ajoute une source',
          message:
              'Ajoute un PDF pour que Neralune prépare le parcours de ce cours.',
          actionLabel: 'Ajouter une source',
          actionKind: CourseLearningPathEmptyActionKind.addSource,
        ),
      );

    await tester.pumpWidget(
      testApp(repository: repository, picker: FakeCoursePdfPicker(null)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Ajoute une source'), findsOneWidget);
    expect(find.text('Ajouter une source'), findsWidgets);
    expect(find.textContaining('MVP+'), findsNothing);
    expect(find.textContaining('backend'), findsNothing);
    expect(find.text('Modes de révision'), findsNothing);
    expect(find.text('Historique'), findsNothing);

    final understandButton = tester.widget<OutlinedButton>(
      find.widgetWithText(OutlinedButton, 'Comprendre'),
    );
    expect(understandButton.onPressed, isNull);

    await scrollToQuickRevision(tester);
    final emptyQuickCard = tester.widget<RevisionModeCard>(
      find.widgetWithText(RevisionModeCard, 'Révision rapide'),
    );
    expect(emptyQuickCard.enabled, isFalse);
    expect(find.text('Ajoute une source pour réviser'), findsOneWidget);
    final emptyRichCard = tester.widget<RevisionModeCard>(
      find.widgetWithText(RevisionModeCard, 'QCM complet'),
    );
    expect(emptyRichCard.enabled, isFalse);
    expect(find.text('Ajoute une source pour t’entraîner.'), findsOneWidget);
    final emptyDeepCard = tester.widget<RevisionModeCard>(
      find.widgetWithText(RevisionModeCard, 'Révision approfondie'),
    );
    expect(emptyDeepCard.enabled, isFalse);
    expect(
      find.text('Ajoute une source pour rédiger une réponse.'),
      findsOneWidget,
    );
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
      )
      ..richRevisionOptionsByCourse['course-1'] = richRevisionOptionsFixture()
      ..deepRevisionOptionsByCourse['course-1'] = deepRevisionOptionsFixture()
      ..learningPathByCourse['course-1'] = courseLearningPathFixture(
        nodes: const [],
        activeNodeId: null,
        primaryAction: const CourseLearningPathPrimaryAction(
          kind: CourseLearningPathPrimaryActionKind.waitForAnalysis,
          label: 'Analyse en cours',
          description:
              'Le parcours sera disponible quand la source sera prête.',
          enabled: false,
          unavailableReason: 'Analyse en cours',
        ),
        emptyState: const CourseLearningPathEmptyState(
          title: 'Analyse en cours',
          message: 'Neralune prépare les notions de ce cours.',
          actionLabel: 'Revenir plus tard',
          actionKind: CourseLearningPathEmptyActionKind.waitForAnalysis,
        ),
      );

    await tester.pumpWidget(
      testApp(repository: repository, picker: FakeCoursePdfPicker(null)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Analyse en cours'), findsWidgets);
    expect(find.text('Modes de révision'), findsNothing);

    final understandButton = tester.widget<OutlinedButton>(
      find.widgetWithText(OutlinedButton, 'Comprendre'),
    );
    expect(understandButton.onPressed, isNull);

    await scrollToQuickRevision(tester);
    final processingQuickCard = tester.widget<RevisionModeCard>(
      find.widgetWithText(RevisionModeCard, 'Révision rapide'),
    );
    expect(processingQuickCard.enabled, isFalse);
    expect(find.text('Révision disponible après traitement'), findsOneWidget);
    final processingDeepCard = tester.widget<RevisionModeCard>(
      find.widgetWithText(RevisionModeCard, 'Révision approfondie'),
    );
    expect(processingDeepCard.enabled, isFalse);
    expect(find.text('Disponible après traitement.'), findsWidgets);
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
      )
      ..richRevisionOptionsByCourse['course-1'] = richRevisionOptionsFixture()
      ..deepRevisionOptionsByCourse['course-1'] = deepRevisionOptionsFixture();

    await tester.pumpWidget(
      testApp(repository: repository, picker: FakeCoursePdfPicker(null)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Continuer'), findsWidgets);
    expect(find.text('Réviser ce cours'), findsOneWidget);

    final understandButton = tester.widget<OutlinedButton>(
      find.widgetWithText(OutlinedButton, 'Comprendre'),
    );
    expect(understandButton.onPressed, isNotNull);

    await scrollToQuickRevision(tester);
    final quickCard = tester.widget<RevisionModeCard>(
      find.widgetWithText(RevisionModeCard, 'Révision rapide'),
    );
    expect(quickCard.enabled, isTrue);
  });

  testWidgets('course detail exposes canonical revision modes honestly', (
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
      ..richRevisionOptionsByCourse['course-1'] = richRevisionOptionsFixture()
      ..deepRevisionOptionsByCourse['course-1'] = deepRevisionOptionsFixture();

    await tester.pumpWidget(
      testApp(repository: repository, picker: FakeCoursePdfPicker(null)),
    );
    await tester.pumpAndSettle();

    await scrollToQuickRevision(tester);

    expect(
      find.widgetWithText(RevisionModeCard, 'Révision rapide'),
      findsOneWidget,
    );
    expect(
      find.widgetWithText(RevisionModeCard, 'QCM complet'),
      findsOneWidget,
    );
    expect(
      find.widgetWithText(RevisionModeCard, 'Révision approfondie'),
      findsOneWidget,
    );
    expect(
      find.widgetWithText(RevisionModeCard, 'Préparation examen - QCM'),
      findsOneWidget,
    );
    expect(find.text('Bientôt'), findsNothing);

    final qcmCard = tester.widget<RevisionModeCard>(
      find.widgetWithText(RevisionModeCard, 'QCM complet'),
    );
    expect(qcmCard.enabled, isTrue);
    expect(qcmCard.onTap, isNotNull);

    final deepCard = tester.widget<RevisionModeCard>(
      find.widgetWithText(RevisionModeCard, 'Révision approfondie'),
    );
    expect(deepCard.enabled, isTrue);
    expect(deepCard.onTap, isNotNull);

    final examCard = tester.widget<RevisionModeCard>(
      find.widgetWithText(RevisionModeCard, 'Préparation examen - QCM'),
    );
    expect(examCard.enabled, isTrue);
    expect(examCard.onTap, isNotNull);

    expect(find.textContaining('Questions riches'), findsNothing);
    expect(find.textContaining('rich closed'), findsNothing);
    expect(find.textContaining('MVP+'), findsNothing);
    expect(find.textContaining('backend'), findsNothing);
  });

  testWidgets(
    'course detail disables QCM complet when no notion is available',
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
        ..richRevisionOptionsByCourse['course-1'] = richRevisionOptionsFixture(
          state: CourseRichRevisionReadinessState.notReady,
          blocker: 'NO_KNOWLEDGE_UNITS',
        );

      await tester.pumpWidget(
        testApp(repository: repository, picker: FakeCoursePdfPicker(null)),
      );
      await tester.pumpAndSettle();

      await scrollToQuickRevision(tester);
      final qcmCard = tester.widget<RevisionModeCard>(
        find.widgetWithText(RevisionModeCard, 'QCM complet'),
      );

      expect(qcmCard.enabled, isFalse);
      expect(find.text('Aucune notion exploitable.'), findsOneWidget);
    },
  );

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
        )
        ..learningPathByCourse['course-1'] = courseLearningPathFixture(
          nodes: const [],
          activeNodeId: null,
          primaryAction: const CourseLearningPathPrimaryAction(
            kind: CourseLearningPathPrimaryActionKind.unavailable,
            label: 'Parcours indisponible',
            description:
                "Aucune notion exploitable n'a encore été trouvée pour ce cours.",
            enabled: false,
            unavailableReason: 'Aucune notion exploitable',
          ),
          emptyState: const CourseLearningPathEmptyState(
            title: 'Aucune notion trouvée',
            message:
                "Aucune notion exploitable n'a encore été trouvée pour ce cours.",
            actionLabel: 'Voir les sources',
            actionKind: CourseLearningPathEmptyActionKind.none,
          ),
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
    'course detail prioritizes reading the sheet when questions are preparing',
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
          status: CourseQuestionBankReadinessStatus.preparing,
          readyQuestionCount: 0,
          targetQuestionCount: 10,
          canStartQuickRevision: false,
          canPrepare: false,
          userMessage:
              'Les questions sont en préparation. Réessaie dans un instant.',
        );

      await tester.pumpWidget(
        testApp(repository: repository, picker: FakeCoursePdfPicker(null)),
      );
      await tester.pumpAndSettle();

      expect(
        find.widgetWithText(RevisionGradientButton, 'Réviser ce cours'),
        findsNothing,
      );
      expect(
        find.widgetWithText(RevisionGradientButton, 'Lire la fiche'),
        findsOneWidget,
      );
      expect(find.text('Questions en préparation'), findsOneWidget);
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

      expect(find.text('Continuer'), findsWidgets);
      expect(
        find.text('Reprendre le parcours à la notion recommandée.'),
        findsWidgets,
      );
      expect(find.text('9 questions prêtes.'), findsNothing);
      expect(find.text('Commencer une session rapide'), findsNothing);

      await tester.ensureVisible(find.text('Réviser ce cours'));
      await tester.tap(find.text('Réviser ce cours'));
      await tester.pumpAndSettle();

      expect(find.text('Combien de temps as-tu ?'), findsOneWidget);
      expect(find.text('5 min'), findsOneWidget);
      expect(find.text('15 min'), findsOneWidget);
      expect(find.text('30 min'), findsOneWidget);
      expect(find.text('Métro'), findsOneWidget);
      expect(find.text('Standard'), findsOneWidget);
      expect(find.text('Approfondi'), findsOneWidget);
      expect(find.text('Commencer'), findsOneWidget);
      expect(find.text('questionCount'), findsNothing);
      expect(find.textContaining('questions'), findsNothing);
      expect(find.text('QCM complet'), findsNothing);
      expect(
        find.byKey(const ValueKey('course-revision-duration-5-selected')),
        findsOneWidget,
      );

      await tester.tap(
        find.byKey(const ValueKey('course-revision-duration-15')),
      );
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('course-revision-duration-15-selected')),
        findsOneWidget,
      );

      await tester.tap(
        find.byKey(const ValueKey('course-revision-duration-5')),
      );
      await tester.pumpAndSettle();

      await tester.tap(
        find.widgetWithText(RevisionGradientButton, 'Commencer'),
      );
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
    await tester.ensureVisible(find.text('Réviser ce cours'));
    await tester.tap(find.text('Réviser ce cours'));
    await tester.pumpAndSettle();

    expect(find.text('Combien de temps as-tu ?'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('course-revision-duration-30')));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(RevisionGradientButton, 'Commencer'));
    await tester.pump();

    expect(find.text('Préparation de la session'), findsOneWidget);
    expect(find.text('Ta session courte se prépare.'), findsOneWidget);
    expect(find.textContaining('questions'), findsNothing);

    await tester.pumpAndSettle();

    expect(repository.startQuickRevisionCount, 1);
    expect(repository.lastQuickRevisionCourseId, 'course-1');
    expect(repository.lastQuickRevisionQuestionCount, 30);
    expect(find.text('Session réelle'), findsOneWidget);
  });

  testWidgets(
    'quick revision preparing error shows stable fallbacks without technical jargon',
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
        ..revisionSheetsByCourse['course-1'] = revisionSheet()
        ..quickRevisionError = const CourseQuickRevisionUnavailableException(
          'COURSE_QUICK_REVISION_QUESTIONS_PREPARING',
          readiness: CourseQuestionBankReadiness(
            courseId: 'course-1',
            status: CourseQuestionBankReadinessStatus.preparing,
            readyQuestionCount: 0,
            targetQuestionCount: 5,
            canStartQuickRevision: false,
            canPrepare: false,
            userMessage:
                'Les questions sont en préparation. Réessaie dans un instant.',
          ),
        );

      await tester.pumpWidget(
        routerTestApp(
          repository: repository,
          picker: FakeCoursePdfPicker(null),
        ),
      );
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Réviser ce cours'));
      await tester.tap(find.text('Réviser ce cours'));
      await tester.pumpAndSettle();

      await tester.tap(
        find.widgetWithText(RevisionGradientButton, 'Commencer'),
      );
      await tester.pumpAndSettle();

      expect(find.text('Questions en préparation'), findsOneWidget);
      expect(
        find.text(
          'Neralune prépare encore les questions de ce cours. Tu peux lire la fiche en attendant.',
        ),
        findsOneWidget,
      );
      expect(find.text('Lire la fiche'), findsOneWidget);
      expect(find.text('Voir le parcours'), findsOneWidget);
      expect(find.textContaining('COURSE_QUICK_REVISION'), findsNothing);
      expect(find.textContaining('409'), findsNothing);
      expect(find.textContaining('backend'), findsNothing);
      expect(find.textContaining('payload'), findsNothing);
      expect(find.textContaining('questionCount'), findsNothing);

      await tester.tap(
        find.widgetWithText(RevisionGradientButton, 'Lire la fiche'),
      );
      await tester.pumpAndSettle();

      expect(find.text('Fiche prête'), findsOneWidget);
    },
  );

  testWidgets('course detail shows an empty completed history state', (
    tester,
  ) async {
    final repository = InMemoryCoursesRepository()
      ..detailsByCourse['course-1'] = courseDetail();

    await tester.pumpWidget(
      testApp(repository: repository, picker: FakeCoursePdfPicker(null)),
    );
    await tester.pumpAndSettle();

    await openHistorySheet(tester);

    expect(find.text('Historique'), findsWidgets);
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

    await openHistorySheet(tester);

    expect(find.text('Historique'), findsWidgets);
    expect(find.text('4/5'), findsOneWidget);
    expect(find.textContaining('80 %'), findsOneWidget);

    await tester.tap(find.text('Voir le résultat').first);
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

    await openHistorySheet(tester);

    expect(find.text('Historique'), findsWidgets);
    expect(find.text('5/6'), findsOneWidget);
    expect(find.textContaining('83 %'), findsOneWidget);

    await tester.tap(find.text('Voir le résultat').first);
    await tester.pumpAndSettle();

    expect(find.text('Résultat QCM complet'), findsOneWidget);
  });

  testWidgets('course detail opens a deep revision result from history', (
    tester,
  ) async {
    final repository = InMemoryCoursesRepository()
      ..detailsByCourse['course-1'] = courseDetail()
      ..deepRevisionHistoryByCourse['course-1'] = [deepRevisionHistoryItem()];

    await tester.pumpWidget(
      routerTestApp(repository: repository, picker: FakeCoursePdfPicker(null)),
    );
    await tester.pumpAndSettle();

    await openHistorySheet(tester);

    expect(find.text('Historique'), findsWidgets);
    expect(repository.getCourseDeepRevisionHistoryCount, 1);
    expect(find.text('Révision approfondie'), findsWidgets);
    expect(find.textContaining('Responsabilité politique'), findsOneWidget);
    expect(find.textContaining('72 %'), findsOneWidget);

    await tester.tap(find.text('Voir le résultat').last);
    await tester.pumpAndSettle();

    expect(find.text('Résultat révision approfondie'), findsOneWidget);
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

    await openHistorySheet(tester);

    expect(find.text('Historique'), findsWidgets);
    expect(find.text('9/10'), findsOneWidget);
    expect(find.textContaining('Préparation examen - QCM'), findsWidgets);
    expect(find.textContaining('90 %'), findsOneWidget);

    await tester.tap(find.text('Voir le résultat').first);
    await tester.pumpAndSettle();

    expect(find.text('Résultat Préparation examen - QCM'), findsOneWidget);
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

      await openAdvancedActionsSheet(tester);
      await dragCurrentBottomSheetUp(tester);

      await tester.tap(
        find.widgetWithText(RevisionModeCard, 'Préparation examen - QCM'),
      );
      await tester.pumpAndSettle();

      expect(find.text('Préparation examen - QCM dédiée'), findsOneWidget);
    },
  );

  testWidgets('course detail opens the QCM complet page from a real card', (
    tester,
  ) async {
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
      ..richRevisionOptionsByCourse['course-1'] = richRevisionOptionsFixture();

    await tester.pumpWidget(
      routerTestApp(repository: repository, picker: FakeCoursePdfPicker(null)),
    );
    await tester.pumpAndSettle();

    await openAdvancedActionsSheet(tester);

    await tester.tap(find.widgetWithText(RevisionModeCard, 'QCM complet'));
    await tester.pumpAndSettle();

    expect(find.text('QCM complet dédiée'), findsOneWidget);
  });

  testWidgets(
    'course detail opens the Révision approfondie page from a real card',
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
        ..richRevisionOptionsByCourse['course-1'] = richRevisionOptionsFixture()
        ..deepRevisionOptionsByCourse['course-1'] =
            deepRevisionOptionsFixture();

      await tester.pumpWidget(
        routerTestApp(
          repository: repository,
          picker: FakeCoursePdfPicker(null),
        ),
      );
      await tester.pumpAndSettle();

      await openAdvancedActionsSheet(tester);
      await dragCurrentBottomSheetUp(tester);

      await tester.tap(
        find.widgetWithText(RevisionModeCard, 'Révision approfondie'),
      );
      await tester.pumpAndSettle();

      expect(find.text('Révision approfondie dédiée'), findsOneWidget);
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

    expect(find.text('Continuer'), findsWidgets);
    expect(
      find.text('Reprendre le parcours à la notion recommandée.'),
      findsOneWidget,
    );

    await tester.tap(find.widgetWithText(RevisionGradientButton, 'Continuer'));
    await tester.pumpAndSettle();

    expect(repository.startQuickRevisionCount, 0);
    expect(find.text('Session réelle'), findsOneWidget);
  });
}

Future<void> openSourcesSheet(WidgetTester tester) async {
  await openCourseMenuAction(tester, 'Sources');
}

Future<void> openManagementSheet(WidgetTester tester) async {
  await openCourseMenuAction(tester, 'Gérer le cours');
}

Future<void> openHistorySheet(WidgetTester tester) async {
  await openCourseMenuAction(tester, 'Historique');
}

Future<void> openAdvancedActionsSheet(WidgetTester tester) async {
  await openCourseMenuAction(tester, 'Actions avancées');
}

Future<void> openCourseMenuAction(WidgetTester tester, String label) async {
  await tester.tap(find.byTooltip('Plus d’actions'));
  await tester.pumpAndSettle();
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

Future<void> scrollToQuickRevision(WidgetTester tester) async {
  await openAdvancedActionsSheet(tester);
}

Future<void> dragCurrentBottomSheetUp(WidgetTester tester) async {
  await tester.drag(
    find.byType(SingleChildScrollView).last,
    const Offset(0, -500),
  );
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
                ? 'Résultat Préparation examen - QCM'
                : state.pathParameters['sessionId'] == 'revision-session-1'
                ? 'Résultat de session'
                : 'Résultat introuvable',
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.courseSheetPath,
        builder: (context, state) => const Scaffold(body: Text('Fiche prête')),
      ),
      GoRoute(
        path: AppRoutes.richClosedExerciseResultPath,
        builder: (context, state) => Scaffold(
          body: Text(
            state.pathParameters['sessionId'] == 'rich-session-1' &&
                    state.uri.queryParameters['courseId'] == 'course-1'
                ? 'Résultat QCM complet'
                : 'Résultat introuvable',
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.courseDeepRevisionResultPath,
        builder: (context, state) => Scaffold(
          body: Text(
            state.pathParameters['sessionId'] == 'deep-session-1' &&
                    state.pathParameters['courseId'] == 'course-1'
                ? 'Résultat révision approfondie'
                : 'Résultat introuvable',
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.courseRichRevisionPath,
        builder: (context, state) =>
            const Scaffold(body: Text('QCM complet dédiée')),
      ),
      GoRoute(
        path: AppRoutes.courseDeepRevisionPath,
        builder: (context, state) =>
            const Scaffold(body: Text('Révision approfondie dédiée')),
      ),
      GoRoute(
        path: AppRoutes.courseExamPreparationPath,
        builder: (context, state) =>
            const Scaffold(body: Text('Préparation examen - QCM dédiée')),
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
  repository.learningPathByCourse.putIfAbsent(
    'course-1',
    () => courseLearningPathFixture(),
  );
}

RevisionSheet revisionSheet() {
  return const RevisionSheet(
    id: 'sheet-1',
    documentId: 'document-1',
    subjectId: 'subject-1',
    status: 'READY',
    title: 'Fiche de cours',
    introduction: 'Introduction',
    sections: [
      RevisionSheetSection(
        id: 'section-1',
        displayOrder: 0,
        title: 'Institutions',
        content: 'Le Parlement contrôle le Gouvernement.',
        sources: [],
      ),
    ],
    keyPoints: ['Point clé'],
    commonMistakes: ['Erreur fréquente'],
    mustKnow: ['À savoir'],
    practiceSuggestions: ['S’entraîner'],
    errorCode: null,
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

CourseLearningPath courseLearningPathFixture({
  List<CourseLearningPathNode>? nodes,
  String? activeNodeId = 'unit-2',
  CourseLearningPathPrimaryAction? primaryAction,
  CourseLearningPathEmptyState? emptyState,
}) {
  final resolvedNodes =
      nodes ??
      const [
        CourseLearningPathNode(
          id: 'unit-1',
          knowledgeUnitId: 'unit-1',
          courseId: 'course-1',
          subjectId: 'subject-1',
          documentId: 'document-1',
          title: 'Population et conceptions de la Nation',
          order: 0,
          state: CourseLearningPathNodeState.solid,
          masteryScore: 0.86,
          source: CourseLearningPathNodeSource(
            documentId: 'document-1',
            fileName: 'CM.pdf',
          ),
          display: CourseLearningPathNodeDisplay(
            title: 'Population et conceptions de la Nation',
            statusLabel: 'Solide',
            metaLabel: 'CM.pdf',
            actionLabel: 'Revoir',
          ),
        ),
        CourseLearningPathNode(
          id: 'unit-2',
          knowledgeUnitId: 'unit-2',
          courseId: 'course-1',
          subjectId: 'subject-1',
          documentId: 'document-1',
          title: 'La séparation des pouvoirs',
          order: 1,
          state: CourseLearningPathNodeState.toStrengthen,
          masteryScore: 0.34,
          source: CourseLearningPathNodeSource(
            documentId: 'document-1',
            fileName: 'CM.pdf',
          ),
          display: CourseLearningPathNodeDisplay(
            title: 'La séparation des pouvoirs',
            statusLabel: 'À renforcer',
            metaLabel: 'CM.pdf',
            actionLabel: 'Renforcer',
          ),
        ),
        CourseLearningPathNode(
          id: 'unit-3',
          knowledgeUnitId: 'unit-3',
          courseId: 'course-1',
          subjectId: 'subject-1',
          documentId: 'document-1',
          title: "La souveraineté de l’État",
          order: 2,
          state: CourseLearningPathNodeState.undiscovered,
          source: CourseLearningPathNodeSource(
            documentId: 'document-1',
            fileName: 'CM.pdf',
          ),
          display: CourseLearningPathNodeDisplay(
            title: "La souveraineté de l’État",
            statusLabel: 'À découvrir',
            metaLabel: 'CM.pdf',
            actionLabel: 'Découvrir',
          ),
        ),
      ];

  return CourseLearningPath(
    generatedAt: DateTime.utc(2026, 6, 26, 12),
    course: const CourseLearningPathCourse(
      id: 'course-1',
      subjectId: 'subject-1',
      subjectName: 'Droit',
      title: 'Droit constitutionnel',
    ),
    summary: CourseLearningPathSummary(
      knowledgeUnitCount: resolvedNodes.length,
      solidCount: resolvedNodes
          .where((node) => node.state == CourseLearningPathNodeState.solid)
          .length,
      inProgressCount: resolvedNodes
          .where((node) => node.state == CourseLearningPathNodeState.inProgress)
          .length,
      toStrengthenCount: resolvedNodes
          .where(
            (node) => node.state == CourseLearningPathNodeState.toStrengthen,
          )
          .length,
      undiscoveredCount: resolvedNodes
          .where(
            (node) => node.state == CourseLearningPathNodeState.undiscovered,
          )
          .length,
      estimatedGlobalMastery: resolvedNodes.isEmpty ? 0 : 0.62,
      mastery: resolvedNodes.isEmpty ? null : 0.74,
      coverage: resolvedNodes.isEmpty ? 0 : 0.83,
      readySourceCount: 1,
    ),
    activeNodeId: activeNodeId,
    primaryAction:
        primaryAction ??
        const CourseLearningPathPrimaryAction(
          kind: CourseLearningPathPrimaryActionKind.reviewActiveNode,
          label: 'Continuer',
          description: 'Reprendre le parcours à la notion recommandée.',
          estimatedMinutes: 8,
          targetKnowledgeUnitId: 'unit-2',
          targetNodeId: 'unit-2',
          enabled: true,
        ),
    nodes: resolvedNodes,
    emptyState: emptyState,
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
    title: 'QCM complet - Constitution',
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
      userMessage: 'Ton cours est prêt pour une préparation examen - QCM.',
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
      userMessage: 'Configuration prête. Tu peux démarrer un entraînement QCM.',
    ),
  );
}

CourseRichRevisionOptions richRevisionOptionsFixture({
  CourseRichRevisionReadinessState state =
      CourseRichRevisionReadinessState.ready,
  String? blocker,
}) {
  final canStart = state == CourseRichRevisionReadinessState.ready;

  return CourseRichRevisionOptions(
    course: const CourseRichRevisionCourse(
      id: 'course-1',
      title: 'Droit constitutionnel',
      subjectId: 'subject-1',
    ),
    readiness: CourseRichRevisionReadiness(
      canStart: canStart,
      state: state,
      userMessage: canStart
          ? 'Ton cours est prêt pour un QCM complet.'
          : "Aucune notion exploitable n'est disponible pour ce cours.",
      blockers: blocker == null ? const [] : [blocker],
      readySourceCount: 1,
      readyKnowledgeUnitCount: canStart ? 1 : 0,
    ),
    scopeOptions: canStart
        ? const [
            CourseRichRevisionScopeOption(
              kind: CourseRichRevisionScopeKind.knowledgeUnit,
              id: 'ku-1',
              documentId: 'document-1',
              label: 'Responsabilité politique',
              sourceLabel: 'CM.pdf',
              canSelect: true,
            ),
          ]
        : const [],
    questionCountOptions: canStart ? const [6, 10, 13] : const [],
    defaultQuestionCount: canStart ? 6 : null,
    supportedQuestionKinds: const [
      'single_choice',
      'multiple_choice',
      'matching',
    ],
    complexityProfiles: const ['standard', 'advanced'],
    defaultConfig: canStart
        ? const CourseRichRevisionConfig(
            scopeKind: CourseRichRevisionScopeKind.knowledgeUnit,
            scopeId: 'ku-1',
            questionCount: 6,
            complexityProfile: 'standard',
          )
        : null,
    nextStep: CourseRichRevisionNextStep(
      kind: canStart ? 'configuration_ready' : 'blocked',
      userMessage: canStart
          ? 'Choisis une notion et démarre le QCM complet.'
          : "Aucune notion exploitable n'est disponible pour ce cours.",
    ),
  );
}

CourseDeepRevisionOptions deepRevisionOptionsFixture({
  CourseDeepRevisionReadinessState state =
      CourseDeepRevisionReadinessState.ready,
  String? blocker,
}) {
  final canStart = state == CourseDeepRevisionReadinessState.ready;

  return CourseDeepRevisionOptions(
    course: const CourseDeepRevisionCourse(
      id: 'course-1',
      title: 'Droit constitutionnel',
      subjectId: 'subject-1',
    ),
    readiness: CourseDeepRevisionReadiness(
      canStart: canStart,
      state: state,
      userMessage: canStart
          ? 'Ton cours est prêt pour une révision approfondie.'
          : "Aucune notion exploitable n'est disponible pour ce cours.",
      blockers: blocker == null ? const [] : [blocker],
      readySourceCount: 1,
      readyKnowledgeUnitCount: canStart ? 1 : 0,
    ),
    scopeOptions: canStart
        ? const [
            CourseDeepRevisionScopeOption(
              kind: CourseDeepRevisionScopeKind.knowledgeUnit,
              id: 'ku-1',
              documentId: 'document-1',
              label: 'Responsabilité politique',
              sourceLabel: 'CM.pdf',
              canSelect: true,
            ),
          ]
        : const [],
    answerGuidelines: const CourseDeepRevisionAnswerGuidelines(
      minLength: 12,
      maxLength: 4000,
      userMessage: 'Rédige une réponse structurée avec tes propres mots.',
    ),
    defaultConfig: canStart
        ? const CourseDeepRevisionConfig(
            scopeKind: CourseDeepRevisionScopeKind.knowledgeUnit,
            scopeId: 'ku-1',
          )
        : null,
    nextStep: CourseDeepRevisionNextStep(
      kind: canStart ? 'configuration_ready' : 'blocked',
      userMessage: canStart
          ? 'Choisis une notion et démarre la question ouverte.'
          : "Aucune notion exploitable n'est disponible pour ce cours.",
    ),
  );
}

CourseDeepRevisionHistoryItem deepRevisionHistoryItem() {
  return CourseDeepRevisionHistoryItem(
    sessionId: 'deep-session-1',
    title: 'Révision approfondie',
    course: const CourseDeepRevisionHistoryCourse(
      id: 'course-1',
      title: 'Droit constitutionnel',
    ),
    knowledgeUnit: const CourseDeepRevisionHistoryKnowledgeUnit(
      id: 'ku-1',
      title: 'Responsabilité politique',
    ),
    score: 0.72,
    submittedAt: DateTime.parse('2026-06-25T12:00:00.000Z'),
    resultPath:
        '/courses/course-1/deep-revision/sessions/deep-session-1/result',
  );
}

class FakeCoursePdfPicker implements CoursePdfPicker {
  FakeCoursePdfPicker(this.result);

  final PickedCoursePdf? result;

  @override
  Future<PickedCoursePdf?> pickPdf() async => result;
}
