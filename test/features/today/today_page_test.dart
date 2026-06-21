import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:Neralune/app/di/providers.dart';
import 'package:Neralune/features/today/domain/today_plan.dart';
import 'package:Neralune/presentation/pages/today/today_page.dart';

import '../../fakes/in_memory_today_repository.dart';

void main() {
  testWidgets('affiche un état de chargement', (tester) async {
    final repository = _PendingTodayRepository();

    await tester.pumpWidget(_buildApp(repository: repository));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('affiche un état vide propre', (tester) async {
    final repository = InMemoryTodayRepository();

    await tester.pumpWidget(_buildApp(repository: repository));
    await tester.pump();

    expect(
      find.text('Aucune action prioritaire pour aujourd’hui.'),
      findsOneWidget,
    );
    expect(find.text('Voir mes matières'), findsOneWidget);
  });

  testWidgets('affiche une erreur et permet de réessayer', (tester) async {
    final repository = InMemoryTodayRepository()
      ..error = StateError('network')
      ..plan = todayPlan();

    await tester.pumpWidget(_buildApp(repository: repository));
    await tester.pump();

    expect(find.text('Impossible de charger le plan'), findsOneWidget);

    repository.error = null;
    await tester.tap(find.text('Réessayer'));
    await tester.pump();
    await tester.pump();

    expect(repository.getTodayPlanCalls, 2);
    expect(find.text('QCM ciblé'), findsOneWidget);
  });

  testWidgets('affiche plusieurs actions Today v2', (tester) async {
    final repository = InMemoryTodayRepository()..plan = todayPlan();

    await tester.pumpWidget(_buildApp(repository: repository));
    await tester.pump();

    expect(find.text('4 actions'), findsOneWidget);
    expect(find.text('63 min'), findsOneWidget);
    expect(find.text('QCM ciblé'), findsOneWidget);
    expect(find.text('Question ouverte'), findsOneWidget);
    expect(find.text('Questions riches'), findsOneWidget);
    expect(find.text('Session de révision IA'), findsOneWidget);
    expect(find.text('À revoir en priorité.'), findsOneWidget);
    expect(find.text('Change de format.'), findsOneWidget);
    expect(find.text('Questions riches recommandées.'), findsOneWidget);
    expect(find.text('Lance une session guidée.'), findsOneWidget);
    expect(find.text('8 min'), findsOneWidget);
    expect(find.text('12 min'), findsOneWidget);
    expect(find.text('Priorité 610'), findsOneWidget);
    expect(find.text('Maîtrise 20 %'), findsOneWidget);
    expect(find.text('Maîtrise non mesurée'), findsOneWidget);
    expect(find.text('Démarrer le QCM'), findsOneWidget);
    expect(find.text('Répondre à la question'), findsOneWidget);
    expect(find.text('Commencer'), findsOneWidget);
    expect(find.text('Lancer la session'), findsOneWidget);
  });

  testWidgets(
    'ne montre pas de barre de progression pour maîtrise non mesurée',
    (tester) async {
      final repository = InMemoryTodayRepository()
        ..plan = TodayPlan(
          generatedAt: DateTime.parse('2026-06-15T10:00:00.000Z'),
          items: [openQuestionItem()],
        );

      await tester.pumpWidget(_buildApp(repository: repository));
      await tester.pump();

      expect(find.text('Maîtrise non mesurée'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsNothing);
    },
  );

  testWidgets('navigue vers Activities pour QCM sans forcer question ouverte', (
    tester,
  ) async {
    final repository = InMemoryTodayRepository()..plan = todayPlan();
    final router = _router(repository);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [todayRepositoryProvider.overrideWithValue(repository)],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    addTearDown(router.dispose);
    await tester.pump();

    await tester.tap(find.text('Démarrer le QCM'));
    await tester.pumpAndSettle();

    expect(
      router.routeInformationProvider.value.uri.toString(),
      '/activities?subjectId=subject-1',
    );
  });

  testWidgets('navigue vers Activities avec notion pour question ouverte', (
    tester,
  ) async {
    final repository = InMemoryTodayRepository()..plan = todayPlan();
    final router = _router(repository);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [todayRepositoryProvider.overrideWithValue(repository)],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    addTearDown(router.dispose);
    await tester.pump();

    await tester.ensureVisible(find.text('Répondre à la question'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Répondre à la question'));
    await tester.pumpAndSettle();

    expect(
      router.routeInformationProvider.value.uri.toString(),
      '/activities?subjectId=subject-1&knowledgeUnitId=unit-2',
    );
  });

  testWidgets('navigue vers Questions riches avec notion et document', (
    tester,
  ) async {
    final repository = InMemoryTodayRepository()..plan = todayPlan();
    final router = _router(repository);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [todayRepositoryProvider.overrideWithValue(repository)],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    addTearDown(router.dispose);
    await tester.pump();

    await tester.ensureVisible(find.text('Commencer'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Commencer'));
    await tester.pumpAndSettle();

    expect(
      router.routeInformationProvider.value.uri.toString(),
      '/activities/rich-closed?subjectId=subject-1&documentId=document-1&knowledgeUnitId=unit-2',
    );
  });

  testWidgets('navigue vers la session de révision IA', (tester) async {
    final repository = InMemoryTodayRepository()..plan = todayPlan();
    final router = _router(repository);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [todayRepositoryProvider.overrideWithValue(repository)],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    addTearDown(router.dispose);
    await tester.pump();

    await tester.ensureVisible(find.text('Lancer la session'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Lancer la session'));
    await tester.pumpAndSettle();

    expect(
      router.routeInformationProvider.value.uri.toString(),
      '/activities/session?subjectId=subject-2',
    );
  });

  testWidgets('désactive une question ouverte sans notion', (tester) async {
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

    expect(find.text('Action indisponible'), findsOneWidget);
    expect(find.text('Répondre à la question'), findsNothing);
  });
}

Widget _buildApp({required InMemoryTodayRepository repository}) {
  return ProviderScope(
    overrides: [todayRepositoryProvider.overrideWithValue(repository)],
    child: MaterialApp.router(routerConfig: _router(repository)),
  );
}

GoRouter _router(InMemoryTodayRepository repository) {
  return GoRouter(
    initialLocation: '/today',
    routes: [
      GoRoute(path: '/today', builder: (context, state) => const TodayPage()),
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
        builder: (context, state) =>
            const Scaffold(body: Text('Questions riches')),
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

TodayPlan todayPlan() {
  return TodayPlan(
    generatedAt: DateTime.parse('2026-06-15T10:00:00.000Z'),
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
      ),
      openQuestionItem(),
      richClosedItem(),
      const TodayPlanItem(
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
      ),
    ],
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
  );
}
