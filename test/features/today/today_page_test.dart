import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:Neralune/app/di/providers.dart';
import 'package:Neralune/features/courses/application/active_subject_provider.dart';
import 'package:Neralune/features/courses/application/courses_providers.dart';
import 'package:Neralune/features/courses/domain/course_models.dart';
import 'package:Neralune/features/subjects/domain/subject.dart';
import 'package:Neralune/features/today/domain/today_plan.dart';
import 'package:Neralune/presentation/pages/today/today_page.dart';

import '../../fakes/in_memory_today_repository.dart';

void main() {
  testWidgets('affiche un état de chargement premium', (tester) async {
    final repository = _PendingTodayRepository();

    await tester.pumpWidget(_buildApp(repository: repository));

    expect(find.text('Préparation de ta session du jour...'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
  });

  testWidgets('affiche un état coach sans cours sans fausse session', (
    tester,
  ) async {
    final repository = InMemoryTodayRepository();
    final router = _router(repository);

    await tester.pumpWidget(
      _buildScopedApp(repository: repository, router: router),
    );
    addTearDown(router.dispose);
    await tester.pump();

    expect(find.text('Aujourd’hui'), findsNothing);
    expect(_findGreeting(), findsOneWidget);
    expect(find.byKey(const ValueKey('today-luna-static')), findsOneWidget);
    expect(find.text('Rien de prêt pour aujourd’hui'), findsNothing);
    expect(find.text('Prépare ta première matière'), findsOneWidget);
    expect(
      find.text(
        'Ajoute un cours ou une source pour que Neralune crée ta fiche et tes questions.',
      ),
      findsOneWidget,
    );
    expect(find.text('Ouvrir les cours'), findsOneWidget);
    expect(find.text('Ta mission du jour'), findsOneWidget);
    expect(find.text('Réviser maintenant'), findsNothing);
    expect(find.text('Commencer'), findsNothing);

    await tester.tap(find.text('Ouvrir les cours'));
    await tester.pumpAndSettle();

    expect(router.routeInformationProvider.value.uri.path, '/home');
  });

  testWidgets(
    'affiche Lire la fiche quand un cours a une source prête mais aucune session Today',
    (tester) async {
      final repository = InMemoryTodayRepository();
      final router = _router(repository);

      await tester.pumpWidget(
        _buildScopedApp(
          repository: repository,
          router: router,
          activeSubject: _subject(),
          courses: [_course(readySourceCount: 1, processingSourceCount: 2)],
        ),
      );
      addTearDown(router.dispose);
      await tester.pump();
      await tester.pump();

      expect(find.text('Rien de prêt pour aujourd’hui'), findsNothing);
      expect(find.text('Ta mission du jour'), findsOneWidget);
      expect(find.text('Ta fiche est prête'), findsOneWidget);
      expect(find.text('Questions en préparation'), findsOneWidget);
      expect(
        find.text('Ta fiche est prête. Les questions arrivent bientôt.'),
        findsOneWidget,
      );
      expect(find.text('Lire la fiche'), findsOneWidget);
      expect(find.text('Voir le parcours'), findsOneWidget);
      expect(find.text('Commencer'), findsNothing);
      expect(find.textContaining('.pdf'), findsNothing);
      expect(find.textContaining('COURSE_QUICK_REVISION'), findsNothing);

      await tester.tap(find.text('Lire la fiche'));
      await tester.pumpAndSettle();

      final sheetUri = router.routeInformationProvider.value.uri;
      expect(sheetUri.path, '/courses/course-1/sheet');
      expect(sheetUri.queryParameters['from'], 'today');
    },
  );

  testWidgets(
    'affiche Voir le cours quand un cours existe mais la fiche/session ne sont pas prêtes',
    (tester) async {
      final repository = InMemoryTodayRepository();
      final router = _router(repository);

      await tester.pumpWidget(
        _buildScopedApp(
          repository: repository,
          router: router,
          activeSubject: _subject(),
          courses: [_course(processingSourceCount: 1)],
        ),
      );
      addTearDown(router.dispose);
      await tester.pump();
      await tester.pump();

      expect(find.text('Rien de prêt pour aujourd’hui'), findsNothing);
      expect(find.text('Continue ton cours'), findsOneWidget);
      expect(
        find.text('Reprends le parcours et choisis la prochaine notion.'),
        findsOneWidget,
      );
      expect(find.text('Voir le cours'), findsOneWidget);
      expect(find.text('Ouvrir les cours'), findsOneWidget);
      expect(find.text('Commencer'), findsNothing);

      await tester.tap(find.text('Voir le cours'));
      await tester.pumpAndSettle();

      expect(
        router.routeInformationProvider.value.uri.path,
        '/courses/course-1',
      );
    },
  );

  testWidgets('affiche un fallback utile si les cours ne chargent pas', (
    tester,
  ) async {
    final repository = InMemoryTodayRepository();
    final router = _router(repository);

    await tester.pumpWidget(
      _buildScopedApp(
        repository: repository,
        router: router,
        activeSubject: _subject(),
        coursesError: StateError('network'),
      ),
    );
    addTearDown(router.dispose);
    await tester.pump();
    await tester.pump();

    expect(find.text('Impossible de charger Aujourd’hui'), findsOneWidget);
    expect(find.text('Réessayer'), findsOneWidget);
    expect(find.text('Ouvrir les cours'), findsOneWidget);
    expect(find.textContaining('StateError'), findsNothing);

    await tester.tap(find.text('Ouvrir les cours'));
    await tester.pumpAndSettle();

    expect(router.routeInformationProvider.value.uri.path, '/home');
  });

  testWidgets('affiche une erreur et permet de réessayer', (tester) async {
    final repository = InMemoryTodayRepository()
      ..error = StateError('network')
      ..plan = todayPlan();

    await tester.pumpWidget(_buildApp(repository: repository));
    await tester.pump();

    expect(
      find.text('Impossible de charger ta session du jour.'),
      findsOneWidget,
    );

    repository.error = null;
    await tester.tap(find.text('Réessayer'));
    await tester.pump();
    await tester.pump();

    expect(repository.getTodayPlanCalls, 2);
    expect(find.text('Ta session du jour'), findsOneWidget);
    expect(find.text('Réviser maintenant'), findsOneWidget);
  });

  testWidgets('affiche une carte principale Today V4', (tester) async {
    final repository = InMemoryTodayRepository()..plan = todayPlan();

    await tester.pumpWidget(_buildApp(repository: repository));
    await tester.pump();

    expect(find.text('Aujourd’hui'), findsNothing);
    expect(_findGreeting(), findsOneWidget);
    expect(find.byKey(const ValueKey('today-luna-static')), findsOneWidget);
    expect(find.text('Ta session du jour'), findsOneWidget);
    expect(find.text('ANATOMIE'), findsOneWidget);
    expect(find.text('Cycle cardiaque'), findsOneWidget);
    expect(find.text('12 min · session guidée'), findsOneWidget);
    expect(
      find.text(
        'Cette notion semble fragile : la revoir maintenant aidera à consolider tes bases.',
      ),
      findsOneWidget,
    );
    expect(find.text('Réviser maintenant'), findsOneWidget);
    expect(find.text('Changer de cours'), findsOneWidget);
    expect(find.text('Objectif de la semaine'), findsOneWidget);
    expect(find.text('Objectif : 4 h cette semaine'), findsOneWidget);
    expect(find.text('3 / 4'), findsNothing);
    expect(find.text('Continuer'), findsOneWidget);
    expect(find.text('Valves'), findsOneWidget);
  });

  testWidgets('masque le jargon technique Today', (tester) async {
    final repository = InMemoryTodayRepository()..plan = todayPlan();

    await tester.pumpWidget(_buildApp(repository: repository));
    await tester.pump();

    for (final forbidden in _forbiddenTodayLabels) {
      expect(find.text(forbidden), findsNothing, reason: forbidden);
      expect(find.textContaining(forbidden), findsNothing, reason: forbidden);
    }
    expect(find.text('Priorité 610'), findsNothing);
    expect(find.text('priority'), findsNothing);
    expect(find.text('reasonCode'), findsNothing);
    expect(find.text('payload'), findsNothing);
  });

  testWidgets('navigue vers Activities pour la session du jour QCM', (
    tester,
  ) async {
    final repository = InMemoryTodayRepository()..plan = todayPlan();
    final router = _router(repository);

    await tester.pumpWidget(
      _buildScopedApp(repository: repository, router: router),
    );
    addTearDown(router.dispose);
    await tester.pump();

    await tester.tap(find.text('Réviser maintenant'));
    await tester.pumpAndSettle();

    expect(
      router.routeInformationProvider.value.uri.toString(),
      '/activities?subjectId=subject-1',
    );
  });

  testWidgets('navigue vers Activities avec notion pour question ouverte', (
    tester,
  ) async {
    final repository = InMemoryTodayRepository()
      ..plan = TodayPlan(
        generatedAt: DateTime.parse('2026-06-15T10:00:00.000Z'),
        items: [openQuestionItem()],
      );
    final router = _router(repository);

    await tester.pumpWidget(
      _buildScopedApp(repository: repository, router: router),
    );
    addTearDown(router.dispose);
    await tester.pump();

    await tester.tap(find.text('Réviser maintenant'));
    await tester.pumpAndSettle();

    expect(
      router.routeInformationProvider.value.uri.toString(),
      '/activities?subjectId=subject-1&knowledgeUnitId=unit-2',
    );
  });

  testWidgets('navigue vers rich closed avec notion et document', (
    tester,
  ) async {
    final repository = InMemoryTodayRepository()
      ..plan = TodayPlan(
        generatedAt: DateTime.parse('2026-06-15T10:00:00.000Z'),
        items: [richClosedItem()],
      );
    final router = _router(repository);

    await tester.pumpWidget(
      _buildScopedApp(repository: repository, router: router),
    );
    addTearDown(router.dispose);
    await tester.pump();

    await tester.tap(find.text('Réviser maintenant'));
    await tester.pumpAndSettle();

    expect(
      router.routeInformationProvider.value.uri.toString(),
      '/activities/rich-closed?subjectId=subject-1&documentId=document-1&knowledgeUnitId=unit-2',
    );
  });

  testWidgets('navigue vers la session existante', (tester) async {
    final repository = InMemoryTodayRepository()
      ..plan = TodayPlan(
        generatedAt: DateTime.parse('2026-06-15T10:00:00.000Z'),
        items: [revisionSessionItem()],
      );
    final router = _router(repository);

    await tester.pumpWidget(
      _buildScopedApp(repository: repository, router: router),
    );
    addTearDown(router.dispose);
    await tester.pump();

    await tester.tap(find.text('Réviser maintenant'));
    await tester.pumpAndSettle();

    expect(
      router.routeInformationProvider.value.uri.toString(),
      '/activities/session?subjectId=subject-2',
    );
  });

  testWidgets('désactive une action sans notion requise', (tester) async {
    final repository = InMemoryTodayRepository()
      ..plan = TodayPlan(
        generatedAt: DateTime.parse('2026-06-15T10:00:00.000Z'),
        items: [
          openQuestionItem(
            knowledgeUnitId: null,
            knowledgeUnitTitle: null,
            startPayload: const TodayPlanStartPayload(subjectId: 'subject-1'),
          ),
        ],
      );

    await tester.pumpWidget(_buildApp(repository: repository));
    await tester.pump();

    expect(find.text('Session indisponible'), findsOneWidget);
    expect(find.text('Réviser maintenant'), findsNothing);
  });
}

Finder _findGreeting() {
  return find.byWidgetPredicate(
    (widget) =>
        widget is Text &&
        widget.data != null &&
        (widget.data!.startsWith('Bonjour') ||
            widget.data!.startsWith('Bonsoir')),
    description: 'Bonjour/Bonsoir greeting',
  );
}

Widget _buildApp({required InMemoryTodayRepository repository}) {
  final router = _router(repository);
  return _buildScopedApp(repository: repository, router: router);
}

Widget _buildScopedApp({
  required InMemoryTodayRepository repository,
  required GoRouter router,
  Subject? activeSubject,
  List<CourseListItem>? courses,
  Object? coursesError,
}) {
  final overrides = [
    todayRepositoryProvider.overrideWithValue(repository),
    activeSubjectProvider.overrideWithValue(AsyncData(activeSubject)),
    if (activeSubject != null) ...[
      coursesProvider(activeSubject.id).overrideWith((ref) async {
        final error = coursesError;
        if (error != null) {
          throw error;
        }

        return courses ?? const <CourseListItem>[];
      }),
    ],
  ];

  return ProviderScope(
    overrides: overrides,
    child: MaterialApp.router(routerConfig: router),
  );
}

GoRouter _router(InMemoryTodayRepository repository) {
  return GoRouter(
    initialLocation: '/today',
    routes: [
      GoRoute(path: '/today', builder: (context, state) => const TodayPage()),
      GoRoute(
        path: '/home',
        builder: (context, state) => const Scaffold(body: Text('Cours')),
      ),
      GoRoute(
        path: '/subjects',
        builder: (context, state) => const Scaffold(body: Text('Matières')),
      ),
      GoRoute(
        path: '/activities',
        builder: (context, state) => const Scaffold(body: Text('Activités')),
      ),
      GoRoute(
        path: '/activities/session',
        builder: (context, state) => const Scaffold(body: Text('Session')),
      ),
      GoRoute(
        path: '/activities/rich-closed',
        builder: (context, state) => const Scaffold(body: Text('Session')),
      ),
      GoRoute(
        path: '/courses/:courseId',
        builder: (context, state) => const Scaffold(body: Text('Cours détail')),
      ),
      GoRoute(
        path: '/courses/:courseId/sheet',
        builder: (context, state) => const Scaffold(body: Text('Fiche')),
      ),
    ],
  );
}

class _PendingTodayRepository extends InMemoryTodayRepository {
  @override
  Future<TodayPlan> getTodayPlan() {
    getTodayPlanCalls += 1;
    return Completer<TodayPlan>().future;
  }
}

const _forbiddenTodayLabels = [
  'QCM ciblé',
  'Questions riches',
  'Question ouverte',
  'Session de révision IA',
  'diagnostic_quiz',
  'open_question',
  'rich_closed_exercise',
  'QCM simple',
  'QCM complet',
  'Révision rapide',
  'MVP',
  'legacy',
  'backend',
  'GenUI',
];

Subject _subject() {
  return const Subject(
    id: 'subject-1',
    name: 'Droit',
    priority: 1,
    weeklyMinutes: 120,
  );
}

CourseListItem _course({
  int sourceCount = 1,
  int readySourceCount = 0,
  int processingSourceCount = 0,
}) {
  return CourseListItem(
    id: 'course-1',
    subjectId: 'subject-1',
    title: 'Droit constitutionnel',
    description: 'Contrôle de constitutionnalité',
    estimatedMinutes: 12,
    sourceCount: sourceCount,
    readySourceCount: readySourceCount,
    processingSourceCount: processingSourceCount,
  );
}

TodayPlan todayPlan() {
  return TodayPlan(
    generatedAt: DateTime.parse('2026-06-15T10:00:00.000Z'),
    primaryItemId: 'subject-1:unit-1:diagnostic_quiz',
    continuationItemIds: const [
      'subject-1:unit-2:open_question',
      'subject-1:unit-2:rich_closed_exercise',
    ],
    weeklyObjective: const TodayWeeklyObjective(
      targetMinutes: 240,
      completedMinutes: null,
      progressRatio: null,
      label: 'Objectif : 4 h cette semaine',
      status: TodayWeeklyObjectiveStatus.targetOnly,
    ),
    emptyState: const TodayEmptyState(
      title: 'Rien de prêt pour aujourd’hui',
      message:
          'Ajoute un cours ou une source pour que Neralune prépare ta prochaine session.',
      actionLabel: 'Voir mes cours',
      actionKind: TodayEmptyActionKind.openCourses,
    ),
    items: [
      const TodayPlanItem(
        id: 'subject-1:unit-1:diagnostic_quiz',
        subjectId: 'subject-1',
        subjectName: 'Anatomie',
        knowledgeUnitId: 'unit-1',
        knowledgeUnitTitle: 'Cycle cardiaque',
        masteryScore: 0.2,
        action: TodayPlanActionType.diagnosticQuiz,
        estimatedMinutes: 12,
        priority: 610,
        reasonCode: TodayPlanReasonCode.lowMastery,
        reason: 'À revoir en priorité.',
        startPayload: TodayPlanStartPayload(
          subjectId: 'subject-1',
          knowledgeUnitId: 'unit-1',
          preferredAction: TodayPlanPreferredAction.diagnosticQuiz,
        ),
        role: TodayPlanItemRole.primary,
        display: TodayPlanItemDisplay(
          title: 'Cycle cardiaque',
          subjectLabel: 'Anatomie',
          badgeLabel: 'ANATOMIE',
          durationLabel: '12 min',
          metaLabel: '12 min · session guidée',
          recommendation:
              'Cette notion semble fragile : la revoir maintenant aidera à consolider tes bases.',
          actionLabel: 'Réviser maintenant',
          unavailableReason: null,
        ),
      ),
      openQuestionItem(),
      richClosedItem(),
      revisionSessionItem(),
    ],
  );
}

TodayPlanItem revisionSessionItem() {
  return const TodayPlanItem(
    id: 'subject-2:session:revision_session',
    subjectId: 'subject-2',
    subjectName: 'Droit',
    knowledgeUnitId: null,
    knowledgeUnitTitle: null,
    masteryScore: 0.7,
    action: TodayPlanActionType.revisionSession,
    estimatedMinutes: 25,
    priority: 500,
    reasonCode: TodayPlanReasonCode.startRevisionSession,
    reason: 'Lance une session guidée.',
    startPayload: TodayPlanStartPayload(subjectId: 'subject-2'),
    role: TodayPlanItemRole.continuation,
    display: TodayPlanItemDisplay(
      title: 'Droit',
      subjectLabel: 'Droit',
      badgeLabel: 'DROIT',
      durationLabel: '25 min',
      metaLabel: '25 min · session guidée',
      recommendation:
          'Neralune a assez de contexte pour te guider sans te disperser.',
      actionLabel: 'Continuer',
      unavailableReason: null,
    ),
  );
}

TodayPlanItem richClosedItem() {
  return const TodayPlanItem(
    id: 'subject-1:unit-2:rich_closed_exercise',
    subjectId: 'subject-1',
    subjectName: 'Anatomie',
    documentId: 'document-1',
    knowledgeUnitId: 'unit-2',
    knowledgeUnitTitle: 'Valves',
    masteryScore: 0.35,
    action: TodayPlanActionType.richClosedExercise,
    estimatedMinutes: 8,
    priority: 585,
    reasonCode: TodayPlanReasonCode.richClosedPractice,
    reason: 'Questions riches recommandées.',
    startPayload: TodayPlanStartPayload(
      subjectId: 'subject-1',
      documentId: 'document-1',
      knowledgeUnitId: 'unit-2',
    ),
    role: TodayPlanItemRole.continuation,
    display: TodayPlanItemDisplay(
      title: 'Valves',
      subjectLabel: 'Anatomie',
      badgeLabel: 'ANATOMIE',
      durationLabel: '8 min',
      metaLabel: '8 min · session guidée',
      recommendation: 'Cette notion mérite une session cadrée avec feedback.',
      actionLabel: 'Continuer',
      unavailableReason: null,
    ),
  );
}

TodayPlanItem openQuestionItem({
  String? knowledgeUnitId = 'unit-2',
  String? knowledgeUnitTitle = 'Valves',
  TodayPlanStartPayload startPayload = const TodayPlanStartPayload(
    subjectId: 'subject-1',
    knowledgeUnitId: 'unit-2',
  ),
}) {
  return TodayPlanItem(
    id: 'subject-1:unit-2:open_question',
    subjectId: 'subject-1',
    subjectName: 'Anatomie',
    knowledgeUnitId: knowledgeUnitId,
    knowledgeUnitTitle: knowledgeUnitTitle,
    masteryScore: null,
    action: TodayPlanActionType.openQuestion,
    estimatedMinutes: 18,
    priority: 590,
    reasonCode: TodayPlanReasonCode.mixActivityType,
    reason: 'Change de format.',
    startPayload: startPayload,
    role: TodayPlanItemRole.continuation,
    display: const TodayPlanItemDisplay(
      title: 'Valves',
      subjectLabel: 'Anatomie',
      badgeLabel: 'ANATOMIE',
      durationLabel: '18 min',
      metaLabel: '18 min · session guidée',
      recommendation: 'Changer d’angle peut t’aider à mieux ancrer la notion.',
      actionLabel: 'Continuer',
      unavailableReason: null,
    ),
  );
}
