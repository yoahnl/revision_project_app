# CORE-04 — Course-level revision sheet V0 depuis une source READY

## 1. Résumé du lot

CORE-04 côté Flutter est réalisé. Depuis le détail d’un cours réel, le bouton `Fiche de cours` est désormais actif uniquement si le cours contient au moins une source en statut `READY`. La route `/courses/:courseId/sheet` affiche une vraie fiche course-level récupérée depuis l’API, ou propose une génération via `POST` si aucune fiche n’existe encore.

Aucune fixture métier n’a été ajoutée au parcours Course. Les modèles de fiche document-level existants sont réutilisés.

## 2. Audit initial

Sources inspectées côté app :

- `lib/features/courses/domain/course_models.dart`
- `lib/features/courses/domain/courses_repository.dart`
- `lib/features/courses/data/http_courses_repository.dart`
- `lib/features/courses/application/courses_providers.dart`
- `lib/features/courses/presentation/course_detail_page.dart`
- `lib/features/courses/presentation/course_pending_page.dart`
- `lib/app/router/app_router.dart`
- `lib/app/router/app_routes.dart`
- `lib/features/documents/data/documents_api.dart`
- `lib/features/documents/domain/revision_document.dart`
- `test/features/courses/**`
- `test/app/router/app_router_test.dart`

Constats :

- `RevisionSheet` existait déjà dans la feature documents.
- Le parser JSON de fiche était privé dans `documents_api.dart`; il a été extrait en parser partagé.
- `CourseDetailPage` affichait un bouton placeholder `Fiche bientôt disponible`.
- `AppRoutes.courseSheetPath` pointait vers `CoursePendingPage`.
- CORE-03 avait déjà ajouté le polling des sources `UPLOADED` / `PROCESSING`.

## 3. Choix d’architecture

- Réutilisation du modèle `RevisionSheet` existant.
- Parser partagé `RevisionSheetJson` dans `features/documents/data`.
- Ajout de deux méthodes au port `CoursesRepository` : `getCourseRevisionSheet` et `generateCourseRevisionSheet`.
- Providers Riverpod dédiés : `courseRevisionSheetProvider` et `generateCourseRevisionSheetControllerProvider`.
- Page `CourseRevisionSheetPage` dédiée, branchée sur la route existante `AppRoutes.courseSheetPath`.
- CTA du détail de cours conditionné strictement par la présence d’au moins une source `READY`.

## 4. Détail backend

Voir le rapport API. Côté app, les endpoints consommés sont :

- `GET /courses/:courseId/revision-sheet`
- `POST /courses/:courseId/revision-sheet`

Le front n’envoie jamais de `documentId` pour cette fiche course-level.

## 5. Détail frontend

- `HttpCoursesRepository.getCourseRevisionSheet` : appelle `GET`, mappe `404` en `null`, mappe `409` en `CourseRevisionSheetNotReadyException`.
- `HttpCoursesRepository.generateCourseRevisionSheet` : appelle `POST`, sans body, mappe `404`/`409` en exceptions typées.
- `CourseDetailPage` :
  - `Fiche de cours` actif si source `READY` ;
  - `Fiche disponible après traitement` si source pending ;
  - `Ajoute une source pour créer une fiche` sans source ;
  - `Aucune source prête` si sources failed uniquement ;
  - `Révision rapide bientôt disponible` reste désactivé.
- `CourseRevisionSheetPage` : loading, erreur, fiche existante, génération manuelle si GET retourne `null`.
- Nettoyage wording : anciennes mentions `CourseSource` retirées du namespace MVP legacy.

## 6. Endpoints ajoutés ou réutilisés

Endpoints consommés :

- `GET /courses/:courseId/revision-sheet`
- `POST /courses/:courseId/revision-sheet`

Routes Flutter :

- `/courses/:courseId/sheet` remplacée par `CourseRevisionSheetPage`.

## 7. Fichiers créés/modifiés/supprimés

Créés :

- `lib/features/courses/presentation/course_revision_sheet_page.dart`
- `lib/features/documents/data/revision_sheet_json.dart`
- `test/features/courses/course_revision_sheet_page_test.dart`

Modifiés :

- `lib/app/router/app_router.dart`
- `lib/features/courses/application/courses_providers.dart`
- `lib/features/courses/data/http_courses_repository.dart`
- `lib/features/courses/domain/courses_repository.dart`
- `lib/features/courses/presentation/course_detail_page.dart`
- `lib/features/documents/data/documents_api.dart`
- `lib/features/mvp/application/mvp_study_controller.dart`
- `lib/features/mvp/presentation/mvp_sources_page.dart`
- `test/app/router/app_router_test.dart`
- `test/fakes/in_memory_courses_repository.dart`
- `test/features/courses/course_detail_page_test.dart`
- `test/features/courses/courses_providers_test.dart`
- `test/features/courses/http_courses_repository_test.dart`

Supprimés : aucun.

## 8. Tests exécutés

- `dart format <liste explicite>` : OK.
- `dart analyze lib test` : OK, no issues found.
- `flutter test test/features/courses --reporter compact` : OK.
- `flutter test test/features/documents --reporter compact` : OK après relance séquentielle.
- `flutter test test/app/router/app_router_test.dart --reporter compact` : OK.
- `flutter test test/app/revision_app_test.dart --reporter compact` : OK.
- `flutter test test/app --reporter compact` : OK.
- `flutter test --reporter compact` : OK, 395 tests passés.

## 9. Résultats exacts des commandes

```text
dart analyze lib test
Analyzing lib, test...
No issues found!
```

```text
flutter test test/features/courses --reporter compact
All tests passed!
```

```text
flutter test test/features/documents --reporter compact
All tests passed!
```

```text
flutter test test/app/router/app_router_test.dart --reporter compact
All tests passed!
```

```text
flutter test test/app/revision_app_test.dart --reporter compact
All tests passed!
```

```text
flutter test test/app --reporter compact
All tests passed!
```

```text
flutter test --reporter compact
All tests passed! 395 tests.
```

Note : un premier lancement parallèle de deux commandes Flutter a échoué sur un lock `ios/Flutter/ephemeral/Packages/.packages`. Les commandes ont été relancées ensuite séquentiellement avec succès.

Greps :

- `rg "CourseSource" lib test || true` : aucune occurrence après nettoyage.
- `rg "Loi normale|78%|870|7 jours" lib test || true` : occurrences restantes uniquement dans anciens fichiers MVP legacy non routés en production, dans `RevisionTopCounters` legacy, et dans les tests anti-fixtures `findsNothing`.

## 10. Limites connues

- La page fiche ne fait pas encore de composition multi-source.
- Pas de génération automatique au chargement : si `GET` retourne `null`, l’utilisateur clique sur `Générer la fiche`.
- Pas d’activation de la révision rapide.
- Le namespace MVP legacy existe toujours hors route principale ; il contient encore des fixtures anciennes non utilisées par le parcours Course réel.

## 11. Risques restants

- Si la génération POST est longue côté backend, l’UI affiche un état de traitement local mais pas de polling de génération de fiche. C’est acceptable pour V0.
- L’affichage de sections est minimal et pourra être polishé plus tard.
- `RevisionTopCounters` contient encore un label legacy `870`, mais il n’est pas utilisé dans le parcours Course réel.

## 12. Auto-review séparée

- Périmètre : pas de CORE-05, pas de quick revision réelle.
- Absence de fixtures : aucune donnée fake dans la fiche course-level.
- Contrat API : le front appelle `/courses/:courseId/revision-sheet`, sans `documentId`.
- CTA : fiche active uniquement si source `READY`.
- Erreurs : `409` affiché comme “Aucune source prête”.
- UI : page lisible, design system existant, pas de refonte globale.
- Tests : repository, providers, widgets, routeur, app, full test verts.
- Nettoyage : anciennes mentions `CourseSource` retirées.

## 13. Auto-critique

Solide : réutilisation des modèles document-level, tests de route, anti-fixtures, CTA strictement conditionné.

Fragile : affichage de la fiche simple, sans table des matières ni ancrage par section.

Fait au plus simple : génération déclenchée par bouton si GET retourne `null`.

À reprendre plus tard : meilleure UX de génération longue, état “fiche en cours de génération” côté serveur si l’API devient async.

Pourquoi pas multi-source : le backend CORE-04 sélectionne une seule source READY ; le front reflète ce contrat.

Pourquoi pas quick revision : la session quick réelle relève du lot suivant.

## 14. Points discutables du prompt

- Le prompt demande une fiche “générée/récupérée” mais laisse ouvert le choix auto-POST vs bouton. J’ai choisi bouton POST quand GET retourne `null`, car c’est le plus proche du document-level existant.
- Le grep anti-fixtures global retrouve encore les vieux fichiers MVP legacy. Je les ai laissés hors refonte, car CORE-04 ne demande pas de supprimer le namespace MVP ; j’ai seulement supprimé les mentions `CourseSource` obsolètes.
- `CoursePendingPage` reste dans le code bien qu’il ne serve plus à la fiche ; je ne l’ai pas supprimé pour éviter un nettoyage hors lot.

## 15. Contenu complet des fichiers créés/modifiés/supprimés

Le présent rapport n’est pas inclus dans sa propre section de contenu pour éviter une récursion infinie.

### `lib/features/courses/presentation/course_revision_sheet_page.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_routes.dart';
import '../../../presentation/design_system/components/revision_mvp_components.dart';
import '../../../presentation/design_system/components/revision_states.dart';
import '../../../presentation/design_system/tokens/revision_colors.dart';
import '../../../presentation/design_system/tokens/revision_spacing.dart';
import '../../../presentation/design_system/tokens/revision_typography.dart';
import '../../documents/domain/revision_document.dart';
import '../application/courses_providers.dart';
import '../domain/courses_repository.dart';

class CourseRevisionSheetPage extends ConsumerWidget {
  const CourseRevisionSheetPage({required this.courseId, super.key});

  final String courseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sheet = ref.watch(courseRevisionSheetProvider(courseId));

    return RevisionPageScaffold(
      children: [
        Row(
          children: [
            IconButton(
              tooltip: 'Retour au cours',
              onPressed: () => context.go(AppRoutes.course(courseId)),
              icon: const Icon(Icons.arrow_back_rounded),
            ),
            const Spacer(),
          ],
        ),
        sheet.when(
          loading: () =>
              const RevisionLoadingState(label: 'Chargement de la fiche'),
          error: (error, stackTrace) =>
              _SheetErrorState(error: error, courseId: courseId),
          data: (sheet) {
            if (sheet == null) {
              return _GenerateSheetCard(courseId: courseId);
            }

            return _RevisionSheetContent(sheet: sheet);
          },
        ),
      ],
    );
  }
}

class _GenerateSheetCard extends ConsumerWidget {
  const _GenerateSheetCard({required this.courseId});

  final String courseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(generateCourseRevisionSheetControllerProvider);

    if (state.isLoading) {
      return const RevisionProcessingState(
        title: 'Génération de la fiche',
        message: 'La fiche est créée depuis la première source PDF prête.',
      );
    }

    if (state.hasError) {
      return _SheetErrorState(error: state.error!, courseId: courseId);
    }

    return RevisionEmptyState(
      title: 'Fiche non générée',
      message:
          'Une source est prête, mais aucune fiche n’a encore été créée pour ce cours.',
      icon: Icons.article_outlined,
      actionLabel: 'Générer la fiche',
      onAction: () async {
        try {
          await ref
              .read(generateCourseRevisionSheetControllerProvider.notifier)
              .generate(courseId: courseId);
        } catch (_) {
          // The controller stores the error state; the provider refresh below
          // will render a domain-specific message if the backend rejected it.
        }
      },
    );
  }
}

class _SheetErrorState extends StatelessWidget {
  const _SheetErrorState({required this.error, required this.courseId});

  final Object error;
  final String courseId;

  @override
  Widget build(BuildContext context) {
    if (error is CourseRevisionSheetNotReadyException) {
      return RevisionErrorState(
        title: 'Aucune source prête',
        message:
            'Ajoute ou attends une source PDF traitée avec succès avant de créer une fiche.',
        actionLabel: 'Retour au cours',
        onAction: () => context.go(AppRoutes.course(courseId)),
      );
    }

    if (error is CourseNotFoundException) {
      return RevisionNotFoundState(
        title: 'Cours introuvable',
        message: 'Ce cours n’existe pas dans les données réelles.',
        actionLabel: 'Retour à l’accueil',
        onAction: () => context.go(AppRoutes.home),
      );
    }

    return RevisionErrorState(
      title: 'Fiche indisponible',
      message:
          'Impossible de charger cette fiche pour le moment. Aucune donnée fictive ne sera affichée.',
      actionLabel: 'Réessayer',
      onAction: () => context.go(AppRoutes.courseSheet(courseId)),
    );
  }
}

class _RevisionSheetContent extends StatelessWidget {
  const _RevisionSheetContent({required this.sheet});

  final RevisionSheet sheet;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RevisionGlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Fiche de cours', style: RevisionTypography.caption),
              const SizedBox(height: RevisionSpacing.xs),
              Text(sheet.title, style: RevisionTypography.pageTitle),
              if (sheet.introduction != null) ...[
                const SizedBox(height: RevisionSpacing.m),
                Text(sheet.introduction!, style: RevisionTypography.body),
              ],
            ],
          ),
        ),
        const SizedBox(height: RevisionSpacing.l),
        if (sheet.keyPoints.isNotEmpty)
          _TextListCard(
            title: 'Points clés',
            icon: Icons.check_circle_rounded,
            items: sheet.keyPoints,
          ),
        if (sheet.mustKnow.isNotEmpty)
          _TextListCard(
            title: 'À connaître',
            icon: Icons.school_rounded,
            items: sheet.mustKnow,
          ),
        if (sheet.commonMistakes.isNotEmpty)
          _TextListCard(
            title: 'Pièges fréquents',
            icon: Icons.warning_amber_rounded,
            items: sheet.commonMistakes,
          ),
        for (final section in sheet.sections) _SectionCard(section: section),
        if (sheet.practiceSuggestions.isNotEmpty)
          _TextListCard(
            title: 'S’entraîner',
            icon: Icons.fitness_center_rounded,
            items: sheet.practiceSuggestions,
          ),
      ],
    );
  }
}

class _TextListCard extends StatelessWidget {
  const _TextListCard({
    required this.title,
    required this.icon,
    required this.items,
  });

  final String title;
  final IconData icon;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return RevisionGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: RevisionColors.blue, size: 20),
              const SizedBox(width: RevisionSpacing.s),
              Expanded(
                child: Text(title, style: RevisionTypography.sectionTitle),
              ),
            ],
          ),
          const SizedBox(height: RevisionSpacing.m),
          for (final item in items) ...[
            Text('• $item', style: RevisionTypography.body),
            if (item != items.last) const SizedBox(height: RevisionSpacing.s),
          ],
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.section});

  final RevisionSheetSection section;

  @override
  Widget build(BuildContext context) {
    return RevisionGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(section.title, style: RevisionTypography.sectionTitle),
          const SizedBox(height: RevisionSpacing.s),
          Text(section.content, style: RevisionTypography.body),
          if (section.sources.isNotEmpty) ...[
            const SizedBox(height: RevisionSpacing.m),
            Text('Sources', style: RevisionTypography.caption),
            const SizedBox(height: RevisionSpacing.xs),
            for (final source in section.sources)
              Text(
                'p. ${source.pageNumber ?? '-'} · ${source.text}',
                style: RevisionTypography.caption,
              ),
          ],
        ],
      ),
    );
  }
}

```

### `lib/features/documents/data/revision_sheet_json.dart`

```dart
import '../domain/revision_document.dart';

class RevisionSheetJson {
  const RevisionSheetJson(this.value);

  final Object? value;

  RevisionSheet toRevisionSheet() {
    final json = value;

    if (json is! Map<String, Object?>) {
      throw const FormatException('Invalid revision sheet response');
    }

    final id = json['id'];
    final documentId = json['documentId'];
    final subjectId = json['subjectId'];
    final status = json['status'];
    final title = json['title'];
    final introduction = json['introduction'];
    final sections = json['sections'];
    final keyPoints = json['keyPoints'];
    final commonMistakes = json['commonMistakes'];
    final mustKnow = json['mustKnow'];
    final practiceSuggestions = json['practiceSuggestions'];
    final errorCode = json['errorCode'];

    if (id is! String ||
        documentId is! String ||
        subjectId is! String ||
        status is! String ||
        title is! String ||
        (introduction != null && introduction is! String) ||
        sections is! List ||
        keyPoints is! List ||
        commonMistakes is! List ||
        mustKnow is! List ||
        practiceSuggestions is! List ||
        (errorCode != null && errorCode is! String)) {
      throw const FormatException('Invalid revision sheet response');
    }

    return RevisionSheet(
      id: id,
      documentId: documentId,
      subjectId: subjectId,
      status: status,
      title: title,
      introduction: introduction as String?,
      sections: sections
          .map((section) => _RevisionSheetSectionJson(section).toSection())
          .toList(growable: false),
      keyPoints: _stringList(keyPoints, 'Invalid revision sheet response'),
      commonMistakes: _stringList(
        commonMistakes,
        'Invalid revision sheet response',
      ),
      mustKnow: _stringList(mustKnow, 'Invalid revision sheet response'),
      practiceSuggestions: _stringList(
        practiceSuggestions,
        'Invalid revision sheet response',
      ),
      errorCode: errorCode as String?,
    );
  }
}

class _RevisionSheetSectionJson {
  const _RevisionSheetSectionJson(this.value);

  final Object? value;

  RevisionSheetSection toSection() {
    final json = value;

    if (json is! Map<String, Object?>) {
      throw const FormatException('Invalid revision sheet section response');
    }

    final id = json['id'];
    final displayOrder = json['displayOrder'];
    final title = json['title'];
    final content = json['content'];
    final sources = json['sources'];

    if (id is! String ||
        displayOrder is! int ||
        title is! String ||
        content is! String ||
        sources is! List) {
      throw const FormatException('Invalid revision sheet section response');
    }

    return RevisionSheetSection(
      id: id,
      displayOrder: displayOrder,
      title: title,
      content: content,
      sources: sources
          .map((source) => _DocumentArtifactSourceJson(source).toSource())
          .toList(growable: false),
    );
  }
}

class _DocumentArtifactSourceJson {
  const _DocumentArtifactSourceJson(this.value);

  final Object? value;

  DocumentArtifactSource toSource() {
    final json = value;

    if (json is! Map<String, Object?>) {
      throw const FormatException('Invalid artifact source response');
    }

    final chunkId = json['chunkId'];
    final text = json['text'];
    final pageNumber = json['pageNumber'];
    final index = json['index'];

    if (chunkId is! String ||
        text is! String ||
        (pageNumber != null && pageNumber is! int) ||
        index is! int) {
      throw const FormatException('Invalid artifact source response');
    }

    return DocumentArtifactSource(
      chunkId: chunkId,
      text: text,
      pageNumber: pageNumber as int?,
      index: index,
    );
  }
}

List<String> _stringList(List value, String message) {
  if (value.any((item) => item is! String)) {
    throw FormatException(message);
  }

  return value.cast<String>().toList(growable: false);
}

```

### `test/features/courses/course_revision_sheet_page_test.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:revision_app/features/courses/application/courses_providers.dart';
import 'package:revision_app/features/courses/domain/courses_repository.dart';
import 'package:revision_app/features/courses/presentation/course_revision_sheet_page.dart';
import 'package:revision_app/features/documents/domain/revision_document.dart';

import '../../fakes/in_memory_courses_repository.dart';

void main() {
  testWidgets('course revision sheet page displays an existing sheet', (
    tester,
  ) async {
    final repository = InMemoryCoursesRepository()
      ..revisionSheetsByCourse['course-1'] = revisionSheet();

    await tester.pumpWidget(testApp(repository));
    await tester.pumpAndSettle();

    expect(find.text('Fiche de cours'), findsWidgets);
    expect(find.text('Introduction'), findsOneWidget);
    expect(find.text('Institutions'), findsOneWidget);
    expect(find.text('Le Parlement contrôle le Gouvernement.'), findsOneWidget);
    expect(find.text('Loi normale'), findsNothing);
    expect(find.text('78%'), findsNothing);
    expect(find.text('870'), findsNothing);
    expect(find.text('7 jours'), findsNothing);
  });

  testWidgets('course revision sheet page can generate a missing sheet', (
    tester,
  ) async {
    final repository = InMemoryCoursesRepository()
      ..generatedRevisionSheetsByCourse['course-1'] = revisionSheet();

    await tester.pumpWidget(testApp(repository));
    await tester.pumpAndSettle();

    expect(find.text('Fiche non générée'), findsOneWidget);

    await tester.tap(find.text('Générer la fiche'));
    await tester.pumpAndSettle();

    expect(repository.generateRevisionSheetCount, 1);
    expect(find.text('Institutions'), findsOneWidget);
  });

  testWidgets('course revision sheet page shows no-ready-source errors', (
    tester,
  ) async {
    final repository = InMemoryCoursesRepository()
      ..revisionSheetErrorsByCourse['course-1'] =
          const CourseRevisionSheetNotReadyException(
            'Course has no ready source',
          );

    await tester.pumpWidget(testApp(repository));
    await tester.pumpAndSettle();

    expect(find.text('Aucune source prête'), findsOneWidget);
    expect(find.textContaining('traitée avec succès'), findsOneWidget);
  });
}

Widget testApp(InMemoryCoursesRepository repository) {
  return ProviderScope(
    overrides: [coursesRepositoryProvider.overrideWithValue(repository)],
    child: const MaterialApp(
      home: Scaffold(body: CourseRevisionSheetPage(courseId: 'course-1')),
    ),
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

```

### `lib/app/router/app_router.dart`

```dart
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/activities/application/activity_controller.dart';
import '../../features/auth/application/auth_controller.dart';
import '../../features/courses/presentation/course_detail_page.dart';
import '../../features/courses/presentation/course_revision_sheet_page.dart';
import '../../features/courses/presentation/courses_home_page.dart';
import '../../features/courses/presentation/progress_pending_page.dart';
import '../../features/courses/presentation/revision_session_pending_page.dart';
import '../../features/courses/presentation/revision_session_result_pending_page.dart';
import '../../features/courses/presentation/revisions_pending_page.dart';
import '../../features/courses/presentation/sources_pending_page.dart';
import '../../features/documents/application/documents_controller.dart';
import '../../features/onboarding/application/revision_goals_controller.dart';
import '../../features/revision_sessions/application/revision_session_controller.dart';
import '../../features/revision_sessions/data/revision_sessions_api.dart';
import '../../features/subjects/application/subjects_controller.dart';
import '../../features/subjects/application/subjects_notifier.dart';
import '../../features/today/application/today_controller.dart';
import '../../presentation/pages/activities/activities_page.dart';
import '../../presentation/pages/auth/sign_in_page.dart';
import '../../presentation/pages/activities/rich_closed_exercise_page.dart';
import '../../presentation/pages/onboarding/onboarding_page.dart';
import '../../presentation/pages/profile/profile_page.dart';
import '../../presentation/pages/documents/document_detail_page.dart';
import '../../presentation/pages/revision_sessions/revision_session_page.dart';
import '../../presentation/pages/subjects/subject_detail_page.dart';
import '../../presentation/pages/subjects/subjects_home_page.dart';
import '../../presentation/pages/today/today_page.dart';
import '../../presentation/shell/revision_home_shell.dart';
import '../di/providers.dart';
import 'app_routes.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final router = createAppRouter(
    authController: ref.read(authControllerProvider),
    subjectsController: ref.read(subjectsControllerProvider),
    revisionGoalsController: ref.read(revisionGoalsControllerProvider),
    documentsController: ref.read(documentsControllerProvider),
    activityController: ref.read(activityControllerProvider),
    revisionSessionController: ref.read(revisionSessionControllerProvider),
    todayController: ref.read(todayControllerProvider),
    onSubjectCreated: () => ref.invalidate(subjectsNotifierProvider),
  );
  ref.onDispose(router.dispose);
  return router;
});

GoRouter createAppRouter({
  required AuthController authController,
  required SubjectsController subjectsController,
  required RevisionGoalsController revisionGoalsController,
  required DocumentsController documentsController,
  required ActivityController activityController,
  required RevisionSessionController revisionSessionController,
  required TodayController todayController,
  VoidCallback? onSubjectCreated,
}) {
  return GoRouter(
    initialLocation: AppRoutes.home,
    refreshListenable: authController,
    redirect: (context, state) {
      return executeRevisionRedirect(authController, state);
    },
    routes: [
      GoRoute(
        path: AppRoutes.root,
        redirect: (context, state) => AppRoutes.home,
      ),
      GoRoute(
        path: AppRoutes.signIn,
        builder: (context, state) => SignInPage(authController: authController),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => OnboardingPage(
          subjectsController: subjectsController,
          revisionGoalsController: revisionGoalsController,
          onSubjectCreated: onSubjectCreated,
        ),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return RevisionHomeShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home,
                builder: (context, state) => const CoursesHomePage(),
              ),
              GoRoute(
                path: AppRoutes.coursePath,
                builder: (context, state) => CourseDetailPage(
                  courseId: state.pathParameters['courseId'] ?? '',
                ),
              ),
              GoRoute(
                path: AppRoutes.courseSheetPath,
                builder: (context, state) => CourseRevisionSheetPage(
                  courseId: state.pathParameters['courseId'] ?? '',
                ),
              ),
              GoRoute(
                path: AppRoutes.subjects,
                builder: (context, state) => const SubjectsHomePage(),
                routes: [
                  GoRoute(
                    path: ':subjectId',
                    builder: (context, state) => SubjectDetailPage(
                      subjectId: state.pathParameters['subjectId'] ?? '',
                      controller: subjectsController,
                      documentsController: documentsController,
                    ),
                    routes: [
                      GoRoute(
                        path: 'documents/:documentId',
                        builder: (context, state) => DocumentDetailPage(
                          documentId: state.pathParameters['documentId'] ?? '',
                          controller: documentsController,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.progress,
                builder: (context, state) => const ProgressPendingPage(),
              ),
              GoRoute(
                path: AppRoutes.today,
                builder: (context, state) => const TodayPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.revisions,
                builder: (context, state) => const RevisionsPendingPage(),
              ),
              GoRoute(
                path: AppRoutes.revisionSessionV2Path,
                builder: (context, state) => RevisionSessionPendingPage(
                  sessionId: state.pathParameters['sessionId'] ?? '',
                ),
              ),
              GoRoute(
                path: AppRoutes.revisionSessionResultV2Path,
                builder: (context, state) => RevisionSessionResultPendingPage(
                  sessionId: state.pathParameters['sessionId'] ?? '',
                ),
              ),
              GoRoute(
                path: AppRoutes.activities,
                builder: (context, state) => ActivitiesPage(
                  controller: activityController,
                  subjectId: state.uri.queryParameters['subjectId'],
                  knowledgeUnitId: state.uri.queryParameters['knowledgeUnitId'],
                ),
              ),
              GoRoute(
                path: AppRoutes.revisionSessionPath,
                builder: (context, state) => RevisionSessionPage(
                  revisionSessionController: revisionSessionController,
                  activityController: activityController,
                  sessionId: state.uri.queryParameters['sessionId'],
                  subjectId: state.uri.queryParameters['subjectId'],
                  documentId: state.uri.queryParameters['documentId'],
                  knowledgeUnitId: state.uri.queryParameters['knowledgeUnitId'],
                  preferredAction: _preferredActionFromQuery(
                    state.uri.queryParameters['preferredAction'],
                  ),
                ),
              ),
              GoRoute(
                path: AppRoutes.richClosedExercisePath,
                builder: (context, state) => RichClosedExercisePage(
                  controller: activityController,
                  sessionId: state.uri.queryParameters['sessionId'],
                  subjectId: state.uri.queryParameters['subjectId'],
                  documentId: state.uri.queryParameters['documentId'],
                  knowledgeUnitId: state.uri.queryParameters['knowledgeUnitId'],
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.sources,
                builder: (context, state) => const SourcesPendingPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.profile,
                builder: (context, state) =>
                    ProfilePage(authController: authController),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

RevisionSessionPreferredAction? _preferredActionFromQuery(String? value) {
  return switch (value) {
    'diagnostic_quiz' => RevisionSessionPreferredAction.diagnosticQuiz,
    'open_question' => RevisionSessionPreferredAction.openQuestion,
    'rich_closed_exercise' => RevisionSessionPreferredAction.richClosedExercise,
    _ => null,
  };
}

@visibleForTesting
String? executeRevisionRedirect(
  AuthController authController,
  GoRouterState state,
) {
  final isSigningIn = state.uri.path == AppRoutes.signIn;

  if (authController.isLoading) {
    return null;
  }

  if (!authController.isSignedIn) {
    return isSigningIn ? null : AppRoutes.signIn;
  }

  if (isSigningIn) {
    return AppRoutes.home;
  }

  return null;
}

```

### `lib/features/courses/application/courses_providers.dart`

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/di/providers.dart';
import '../../documents/domain/revision_document.dart';
import '../data/http_courses_repository.dart';
import '../domain/course_models.dart';
import '../domain/courses_repository.dart';
import 'course_pdf_picker.dart';

final coursesRepositoryProvider = Provider<CoursesRepository>((ref) {
  final dio = ref.read(dioProvider);
  final auth = ref.read(authControllerProvider);
  return HttpCoursesRepository(dio: dio, getIdToken: auth.requireIdToken);
});

final coursesProvider = FutureProvider.family<List<CourseListItem>, String>((
  ref,
  subjectId,
) {
  return ref.read(coursesRepositoryProvider).listCourses(subjectId: subjectId);
});

final courseDetailProvider = FutureProvider.family<CourseDetail, String>((
  ref,
  courseId,
) {
  return ref.read(coursesRepositoryProvider).getCourse(courseId: courseId);
});

final courseRevisionSheetProvider =
    FutureProvider.family<RevisionSheet?, String>((ref, courseId) {
      return ref
          .read(coursesRepositoryProvider)
          .getCourseRevisionSheet(courseId: courseId);
    });

final createCourseControllerProvider =
    NotifierProvider<CreateCourseController, AsyncValue<void>>(
      CreateCourseController.new,
    );

final uploadCourseDocumentControllerProvider =
    NotifierProvider<
      UploadCourseDocumentController,
      AsyncValue<CourseDocument?>
    >(UploadCourseDocumentController.new);

final generateCourseRevisionSheetControllerProvider =
    NotifierProvider<
      GenerateCourseRevisionSheetController,
      AsyncValue<RevisionSheet?>
    >(GenerateCourseRevisionSheetController.new);

class CreateCourseController extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<CourseListItem> create({
    required String subjectId,
    required CreateCourseInput input,
  }) async {
    state = const AsyncLoading();
    final repository = ref.read(coursesRepositoryProvider);
    final result = await AsyncValue.guard(
      () => repository.createCourse(subjectId: subjectId, input: input),
    );
    state = result.whenData((_) {});

    if (result.hasError) {
      Error.throwWithStackTrace(result.error!, result.stackTrace!);
    }

    final course = result.requireValue;
    ref.invalidate(coursesProvider(subjectId));
    ref.invalidate(courseDetailProvider(course.id));

    return course;
  }
}

class UploadCourseDocumentController
    extends Notifier<AsyncValue<CourseDocument?>> {
  @override
  AsyncValue<CourseDocument?> build() => const AsyncData(null);

  Future<CourseDocument?> upload({required CourseDetail detail}) async {
    final picked = await ref.read(coursePdfPickerProvider).pickPdf();

    if (picked == null) {
      state = const AsyncData(null);
      return null;
    }

    state = const AsyncLoading();
    final repository = ref.read(coursesRepositoryProvider);
    final result = await AsyncValue.guard(
      () => repository.uploadCoursePdf(
        courseId: detail.course.id,
        fileName: picked.fileName,
        bytes: picked.bytes,
      ),
    );

    state = result.whenData<CourseDocument?>((document) => document);

    if (result.hasError) {
      Error.throwWithStackTrace(result.error!, result.stackTrace!);
    }

    final uploaded = result.requireValue;
    ref.invalidate(courseDetailProvider(detail.course.id));
    ref.invalidate(coursesProvider(detail.course.subjectId));

    return uploaded;
  }
}

class GenerateCourseRevisionSheetController
    extends Notifier<AsyncValue<RevisionSheet?>> {
  @override
  AsyncValue<RevisionSheet?> build() => const AsyncData(null);

  Future<RevisionSheet> generate({required String courseId}) async {
    state = const AsyncLoading();
    final repository = ref.read(coursesRepositoryProvider);
    final result = await AsyncValue.guard(
      () => repository.generateCourseRevisionSheet(courseId: courseId),
    );

    state = result.whenData<RevisionSheet?>((sheet) => sheet);

    if (result.hasError) {
      Error.throwWithStackTrace(result.error!, result.stackTrace!);
    }

    final sheet = result.requireValue;
    ref.invalidate(courseRevisionSheetProvider(courseId));

    return sheet;
  }
}

```

### `lib/features/courses/data/http_courses_repository.dart`

```dart
import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../domain/course_models.dart';
import '../domain/courses_repository.dart';
import '../../documents/data/revision_sheet_json.dart';
import '../../documents/domain/revision_document.dart';

class HttpCoursesRepository implements CoursesRepository {
  HttpCoursesRepository({
    required Dio dio,
    required Future<String> Function() getIdToken,
  }) : this._(dio, getIdToken);

  const HttpCoursesRepository._(this._dio, this._getIdToken);

  final Dio _dio;
  final Future<String> Function() _getIdToken;

  @override
  Future<List<CourseListItem>> listCourses({required String subjectId}) async {
    final response = await _dio.get<Object?>(
      '/subjects/${Uri.encodeComponent(subjectId)}/courses',
      options: await _authorizedOptions(),
    );
    final rawCourses = response.data;

    if (rawCourses is! List) {
      throw const FormatException('Invalid courses response');
    }

    return rawCourses
        .map((course) => _CourseJson(course).toListItem())
        .toList(growable: false);
  }

  @override
  Future<CourseDetail> getCourse({required String courseId}) async {
    try {
      final response = await _dio.get<Object?>(
        '/courses/${Uri.encodeComponent(courseId)}',
        options: await _authorizedOptions(),
      );

      return _CourseDetailJson(response.data).toDetail();
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        throw const CourseNotFoundException('Course not found');
      }
      rethrow;
    }
  }

  @override
  Future<CourseListItem> createCourse({
    required String subjectId,
    required CreateCourseInput input,
  }) async {
    try {
      final response = await _dio.post<Object?>(
        '/subjects/${Uri.encodeComponent(subjectId)}/courses',
        data: {
          'title': input.title,
          'description': input.description,
          'chapterLabel': input.chapterLabel,
          'estimatedMinutes': input.estimatedMinutes,
        },
        options: await _authorizedOptions(),
      );

      return _CourseJson(response.data).toListItem();
    } on DioException catch (error) {
      if (error.response?.statusCode == 400) {
        throw const CourseRequestException('Invalid course request');
      }
      if (error.response?.statusCode == 404) {
        throw const CourseNotFoundException('Course subject not found');
      }
      rethrow;
    }
  }

  @override
  Future<CourseDocument> uploadCoursePdf({
    required String courseId,
    required String fileName,
    required Uint8List bytes,
  }) async {
    try {
      final response = await _dio.post<Object?>(
        '/courses/${Uri.encodeComponent(courseId)}/source/course-pdf',
        data: FormData.fromMap({
          'file': MultipartFile.fromBytes(
            bytes,
            filename: fileName,
            contentType: DioMediaType('application', 'pdf'),
          ),
        }),
        options: await _authorizedOptions(),
      );

      return _CourseDocumentJson(response.data).toDocument();
    } on DioException catch (error) {
      if (error.response?.statusCode == 400) {
        throw const CourseUploadException('Invalid course PDF upload');
      }
      if (error.response?.statusCode == 404) {
        throw const CourseNotFoundException('Course not found');
      }
      rethrow;
    }
  }

  @override
  Future<RevisionSheet?> getCourseRevisionSheet({
    required String courseId,
  }) async {
    try {
      final response = await _dio.get<Object?>(
        '/courses/${Uri.encodeComponent(courseId)}/revision-sheet',
        options: await _authorizedOptions(),
      );

      return RevisionSheetJson(response.data).toRevisionSheet();
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        return null;
      }
      if (error.response?.statusCode == 409) {
        throw const CourseRevisionSheetNotReadyException(
          'Course has no ready source',
        );
      }
      rethrow;
    }
  }

  @override
  Future<RevisionSheet> generateCourseRevisionSheet({
    required String courseId,
  }) async {
    try {
      final response = await _dio.post<Object?>(
        '/courses/${Uri.encodeComponent(courseId)}/revision-sheet',
        options: await _authorizedOptions(),
      );

      return RevisionSheetJson(response.data).toRevisionSheet();
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        throw const CourseNotFoundException('Course not found');
      }
      if (error.response?.statusCode == 409) {
        throw const CourseRevisionSheetNotReadyException(
          'Course has no ready source',
        );
      }
      rethrow;
    }
  }

  @override
  Future<CourseProgress> getCourseProgress({required String courseId}) {
    throw UnimplementedError('Progression course réelle hors CORE-02');
  }

  Future<Options> _authorizedOptions() async {
    final token = (await _getIdToken()).trim();

    if (token.isEmpty) {
      throw StateError('A Firebase ID token is required to load courses');
    }

    return Options(headers: {'Authorization': 'Bearer $token'});
  }
}

class _CourseJson {
  const _CourseJson(this.value);

  final Object? value;

  CourseListItem toListItem() {
    final json = value;

    if (json is! Map<String, Object?>) {
      throw const FormatException('Invalid course response');
    }

    final id = json['id'];
    final subjectId = json['subjectId'];
    final title = json['title'];
    final description = json['description'];
    final chapterLabel = json['chapterLabel'];
    final estimatedMinutes = json['estimatedMinutes'];
    final displayOrder = json['displayOrder'];
    final sourceCount = json['sourceCount'];
    final readySourceCount = json['readySourceCount'];
    final processingSourceCount = json['processingSourceCount'];
    final failedSourceCount = json['failedSourceCount'];

    if (id is! String ||
        subjectId is! String ||
        title is! String ||
        displayOrder is! int ||
        sourceCount is! int ||
        readySourceCount is! int ||
        processingSourceCount is! int ||
        failedSourceCount is! int) {
      throw const FormatException('Invalid course response');
    }

    return CourseListItem(
      id: id,
      subjectId: subjectId,
      title: title,
      description: description is String ? description : null,
      chapterLabel: chapterLabel is String ? chapterLabel : null,
      estimatedMinutes: estimatedMinutes is int ? estimatedMinutes : null,
      displayOrder: displayOrder,
      createdAt: _parseOptionalDate(json['createdAt']),
      updatedAt: _parseOptionalDate(json['updatedAt']),
      sourceCount: sourceCount,
      readySourceCount: readySourceCount,
      processingSourceCount: processingSourceCount,
      failedSourceCount: failedSourceCount,
    );
  }
}

class _CourseDetailJson {
  const _CourseDetailJson(this.value);

  final Object? value;

  CourseDetail toDetail() {
    final json = value;

    if (json is! Map<String, Object?>) {
      throw const FormatException('Invalid course detail response');
    }

    final subject = json['subject'];
    final sources = json['sources'];

    if (subject is! Map<String, Object?> || sources is! List) {
      throw const FormatException('Invalid course detail response');
    }

    final subjectId = subject['id'];
    final subjectName = subject['name'];

    if (subjectId is! String || subjectName is! String) {
      throw const FormatException('Invalid course detail response');
    }

    return CourseDetail(
      course: _CourseJson(json['course']).toListItem(),
      subject: CourseSubjectSummary(id: subjectId, name: subjectName),
      sources: sources
          .map((source) => _CourseDocumentJson(source).toDocument())
          .toList(growable: false),
    );
  }
}

class _CourseDocumentJson {
  const _CourseDocumentJson(this.value);

  final Object? value;

  CourseDocument toDocument() {
    final json = value;

    if (json is! Map<String, Object?>) {
      throw const FormatException('Invalid course source response');
    }

    final id = json['id'];
    final courseId = json['courseId'];
    final documentId = json['documentId'];
    final fileName = json['fileName'];
    final kind = json['kind'];
    final status = json['status'];
    final errorCode = json['errorCode'];

    if (id is! String ||
        courseId is! String ||
        documentId is! String ||
        fileName is! String ||
        kind is! String ||
        status is! String) {
      throw const FormatException('Invalid course source response');
    }

    return CourseDocument(
      id: id,
      courseId: courseId,
      documentId: documentId,
      fileName: fileName,
      kind: kind,
      status: _parseDocumentStatus(status),
      errorCode: errorCode is String ? errorCode : null,
      createdAt: _parseOptionalDate(json['createdAt']),
      updatedAt: _parseOptionalDate(json['updatedAt']),
    );
  }
}

CourseDocumentStatus _parseDocumentStatus(String value) {
  return switch (value) {
    'UPLOADED' => CourseDocumentStatus.uploaded,
    'PROCESSING' => CourseDocumentStatus.processing,
    'READY' => CourseDocumentStatus.ready,
    'FAILED' => CourseDocumentStatus.failed,
    _ => throw const FormatException('Unknown course source status'),
  };
}

DateTime? _parseOptionalDate(Object? value) {
  if (value == null) {
    return null;
  }

  if (value is! String) {
    throw const FormatException('Invalid date response');
  }

  return DateTime.parse(value);
}

```

### `lib/features/courses/domain/courses_repository.dart`

```dart
import 'dart:typed_data';

import '../../documents/domain/revision_document.dart';
import 'course_models.dart';

abstract interface class CoursesRepository {
  Future<List<CourseListItem>> listCourses({required String subjectId});

  Future<CourseDetail> getCourse({required String courseId});

  Future<CourseListItem> createCourse({
    required String subjectId,
    required CreateCourseInput input,
  });

  Future<CourseDocument> uploadCoursePdf({
    required String courseId,
    required String fileName,
    required Uint8List bytes,
  });

  Future<RevisionSheet?> getCourseRevisionSheet({required String courseId});

  Future<RevisionSheet> generateCourseRevisionSheet({required String courseId});

  Future<CourseProgress> getCourseProgress({required String courseId});
}

class CreateCourseInput {
  const CreateCourseInput({
    required this.title,
    this.description,
    this.chapterLabel,
    this.estimatedMinutes,
  });

  final String title;
  final String? description;
  final String? chapterLabel;
  final int? estimatedMinutes;
}

class CourseNotFoundException implements Exception {
  const CourseNotFoundException(this.message);

  final String message;

  @override
  String toString() => message;
}

class CourseRequestException implements Exception {
  const CourseRequestException(this.message);

  final String message;

  @override
  String toString() => message;
}

class CourseUploadException implements Exception {
  const CourseUploadException(this.message);

  final String message;

  @override
  String toString() => message;
}

class CourseRevisionSheetNotReadyException implements Exception {
  const CourseRevisionSheetNotReadyException(this.message);

  final String message;

  @override
  String toString() => message;
}

```

### `lib/features/courses/presentation/course_detail_page.dart`

```dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_routes.dart';
import '../../../presentation/design_system/components/revision_mvp_components.dart';
import '../../../presentation/design_system/components/revision_states.dart';
import '../../../presentation/design_system/tokens/revision_colors.dart';
import '../../../presentation/design_system/tokens/revision_spacing.dart';
import '../../../presentation/design_system/tokens/revision_typography.dart';
import '../application/courses_providers.dart';
import '../domain/course_models.dart';
import '../domain/courses_repository.dart';
import 'course_not_found_page.dart';

class CourseDetailPage extends ConsumerWidget {
  const CourseDetailPage({required this.courseId, super.key});

  final String courseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(courseDetailProvider(courseId));

    return detail.when(
      loading: () => const RevisionPageScaffold(
        children: [RevisionLoadingState(label: 'Chargement du cours réel')],
      ),
      error: (error, stackTrace) {
        if (error is CourseNotFoundException) {
          return CourseNotFoundPage(courseId: courseId);
        }

        return RevisionPageScaffold(
          children: [
            Text('Cours indisponible', style: RevisionTypography.pageTitle),
            RevisionErrorState(
              title: 'Impossible de charger ce cours',
              message:
                  'Aucune fixture ne remplacera ce cours. Réessaie ou retourne à l’accueil.',
              actionLabel: 'Retour à l’accueil',
              onAction: () => context.go(AppRoutes.home),
            ),
          ],
        );
      },
      data: (detail) => _CourseDetailContent(detail: detail),
    );
  }
}

class _CourseDetailContent extends ConsumerStatefulWidget {
  const _CourseDetailContent({required this.detail});

  final CourseDetail detail;

  @override
  ConsumerState<_CourseDetailContent> createState() =>
      _CourseDetailContentState();
}

class _CourseDetailContentState extends ConsumerState<_CourseDetailContent> {
  static const _pollInterval = Duration(seconds: 2);
  static const _pollTimeout = Duration(minutes: 2);

  Timer? _pollTimer;
  DateTime? _pollStartedAt;
  bool _pollTimedOut = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncPolling());
  }

  @override
  void didUpdateWidget(covariant _CourseDetailContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncPolling();
  }

  @override
  void dispose() {
    _stopPolling(resetTimeout: false);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final detail = widget.detail;
    final course = detail.course;

    return RevisionPageScaffold(
      children: [
        Row(
          children: [
            IconButton(
              tooltip: 'Retour',
              onPressed: () => context.go(AppRoutes.home),
              icon: const Icon(Icons.arrow_back_rounded),
            ),
            const Spacer(),
          ],
        ),
        RevisionGlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(detail.subject.name, style: RevisionTypography.caption),
              const SizedBox(height: RevisionSpacing.xs),
              Text(course.title, style: RevisionTypography.pageTitle),
              if (course.description != null) ...[
                const SizedBox(height: RevisionSpacing.s),
                Text(course.description!, style: RevisionTypography.body),
              ],
              const SizedBox(height: RevisionSpacing.l),
              Wrap(
                spacing: RevisionSpacing.s,
                runSpacing: RevisionSpacing.s,
                children: [
                  _InfoPill(label: _courseMeta(course)),
                  _InfoPill(label: _sourceMeta(course)),
                ],
              ),
            ],
          ),
        ),
        _CourseActions(detail: detail),
        if (_pollTimedOut)
          RevisionGlassCard(
            child: Text(
              'Le traitement continue en arrière-plan. Tu peux revenir plus tard.',
              style: RevisionTypography.body,
            ),
          ),
        _SourcesSection(
          sources: detail.sources,
          onRefresh: () => ref.invalidate(courseDetailProvider(course.id)),
        ),
      ],
    );
  }

  void _syncPolling() {
    if (!mounted) {
      return;
    }

    final hasPendingSource = widget.detail.sources.any(_isPendingSource);

    if (!hasPendingSource) {
      _stopPolling(resetTimeout: true);
      return;
    }

    _pollStartedAt ??= DateTime.now();
    _pollTimer ??= Timer.periodic(_pollInterval, (_) {
      final startedAt = _pollStartedAt;
      if (startedAt != null &&
          DateTime.now().difference(startedAt) >= _pollTimeout) {
        if (mounted) {
          setState(() => _pollTimedOut = true);
        }
        _stopPolling(resetTimeout: false);
        return;
      }

      ref.invalidate(courseDetailProvider(widget.detail.course.id));
    });
  }

  void _stopPolling({required bool resetTimeout}) {
    _pollTimer?.cancel();
    _pollTimer = null;
    _pollStartedAt = null;
    if (resetTimeout && _pollTimedOut && mounted) {
      setState(() => _pollTimedOut = false);
    }
  }
}

class _CourseActions extends ConsumerWidget {
  const _CourseActions({required this.detail});

  final CourseDetail detail;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uploadState = ref.watch(uploadCourseDocumentControllerProvider);
    final isUploading = uploadState.isLoading;
    final hasReadySource = detail.sources.any(
      (source) => source.status == CourseDocumentStatus.ready,
    );

    return RevisionGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Actions', style: RevisionTypography.sectionTitle),
          const SizedBox(height: RevisionSpacing.m),
          RevisionGradientButton(
            label: isUploading ? 'Upload en cours...' : 'Ajouter une source',
            icon: Icons.upload_file_rounded,
            expanded: true,
            onPressed: isUploading
                ? null
                : () async {
                    try {
                      final uploaded = await ref
                          .read(uploadCourseDocumentControllerProvider.notifier)
                          .upload(detail: detail);

                      if (!context.mounted || uploaded == null) {
                        return;
                      }

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Source ajoutée')),
                      );
                    } catch (_) {
                      if (!context.mounted) {
                        return;
                      }

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Impossible d’ajouter cette source PDF.',
                          ),
                        ),
                      );
                    }
                  },
          ),
          if (uploadState.hasError) ...[
            const SizedBox(height: RevisionSpacing.s),
            Text(
              'Upload impossible pour le moment.',
              style: RevisionTypography.caption.copyWith(
                color: RevisionColors.red,
              ),
            ),
          ],
          const SizedBox(height: RevisionSpacing.m),
          RevisionGradientButton(
            label: _sheetActionLabel(detail.sources),
            icon: Icons.article_outlined,
            expanded: true,
            onPressed: hasReadySource
                ? () => context.go(AppRoutes.courseSheet(detail.course.id))
                : null,
          ),
          const SizedBox(height: RevisionSpacing.m),
          RevisionGradientButton(
            label: 'Révision rapide bientôt disponible',
            icon: Icons.flash_on_rounded,
            expanded: true,
            onPressed: null,
          ),
          const SizedBox(height: RevisionSpacing.s),
          Text(
            'Révision approfondie et préparation examen restent MVP+.',
            style: RevisionTypography.caption,
          ),
        ],
      ),
    );
  }
}

String _sheetActionLabel(List<CourseDocument> sources) {
  if (sources.any((source) => source.status == CourseDocumentStatus.ready)) {
    return 'Fiche de cours';
  }

  if (sources.any(_isPendingSource)) {
    return 'Fiche disponible après traitement';
  }

  if (sources.isNotEmpty &&
      sources.every((source) => source.status == CourseDocumentStatus.failed)) {
    return 'Aucune source prête';
  }

  return 'Ajoute une source pour créer une fiche';
}

class _SourcesSection extends StatelessWidget {
  const _SourcesSection({required this.sources, required this.onRefresh});

  final List<CourseDocument> sources;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    if (sources.isEmpty) {
      return const RevisionEmptyState(
        title: 'Aucune source attachée',
        message:
            'Ajoute un PDF réel pour lancer le traitement documentaire de ce cours.',
        icon: Icons.source_outlined,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Sources', style: RevisionTypography.sectionTitle),
        const SizedBox(height: RevisionSpacing.m),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: onRefresh,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Rafraîchir'),
          ),
        ),
        const SizedBox(height: RevisionSpacing.s),
        for (final source in sources) ...[
          RevisionGlassCard(
            child: Row(
              children: [
                RevisionIconTile(
                  icon: Icons.picture_as_pdf_rounded,
                  accent: _statusColor(source.status),
                ),
                const SizedBox(width: RevisionSpacing.m),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(source.fileName, style: RevisionTypography.body),
                      const SizedBox(height: RevisionSpacing.xs),
                      Text(
                        _statusLabel(source.status),
                        style: RevisionTypography.caption,
                      ),
                      if (source.status == CourseDocumentStatus.failed &&
                          source.errorCode != null) ...[
                        const SizedBox(height: RevisionSpacing.xs),
                        Text(
                          'Code erreur : ${source.errorCode}',
                          style: RevisionTypography.caption.copyWith(
                            color: RevisionColors.red,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: RevisionSpacing.m),
        ],
      ],
    );
  }
}

bool _isPendingSource(CourseDocument source) {
  return source.status == CourseDocumentStatus.uploaded ||
      source.status == CourseDocumentStatus.processing;
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: RevisionColors.glassSoft,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: RevisionColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: RevisionSpacing.m,
          vertical: RevisionSpacing.s,
        ),
        child: Text(label, style: RevisionTypography.caption),
      ),
    );
  }
}

String _courseMeta(CourseListItem course) {
  final parts = <String>[
    if (course.chapterLabel != null) course.chapterLabel!,
    if (course.estimatedMinutes != null) '${course.estimatedMinutes} min',
  ];

  return parts.isEmpty ? 'Cours réel' : parts.join(' · ');
}

String _sourceMeta(CourseListItem course) {
  final sourceLabel = course.sourceCount <= 1 ? 'source' : 'sources';
  final readyLabel = course.readySourceCount <= 1 ? 'prête' : 'prêtes';

  return '${course.sourceCount} $sourceLabel · ${course.readySourceCount} $readyLabel';
}

String _statusLabel(CourseDocumentStatus status) {
  return switch (status) {
    CourseDocumentStatus.uploaded => 'Téléversée',
    CourseDocumentStatus.processing => 'Traitement en cours',
    CourseDocumentStatus.ready => 'Prête',
    CourseDocumentStatus.failed => 'Erreur',
    CourseDocumentStatus.unknown => 'Statut inconnu',
  };
}

Color _statusColor(CourseDocumentStatus status) {
  return switch (status) {
    CourseDocumentStatus.ready => RevisionColors.mint,
    CourseDocumentStatus.processing => RevisionColors.blue,
    CourseDocumentStatus.failed => RevisionColors.red,
    CourseDocumentStatus.uploaded => RevisionColors.amber,
    CourseDocumentStatus.unknown => RevisionColors.violet,
  };
}

```

### `lib/features/documents/data/documents_api.dart`

```dart
import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../application/documents_controller.dart';
import '../domain/revision_document.dart';
import 'revision_sheet_json.dart';

class HttpDocumentsApi implements DocumentsApi {
  HttpDocumentsApi({
    required Dio dio,
    required Future<String?> Function() getIdToken,
  }) : this._(dio, getIdToken);

  const HttpDocumentsApi._(this._dio, this._getIdToken);

  final Dio _dio;
  final Future<String?> Function() _getIdToken;

  @override
  Future<RevisionDocument> uploadCoursePdf({
    required String subjectId,
    required String fileName,
    required Uint8List bytes,
  }) async {
    final response = await _dio.post<Object?>(
      '/documents/course-pdf',
      data: FormData.fromMap({
        'subjectId': subjectId,
        'file': MultipartFile.fromBytes(
          bytes,
          filename: fileName,
          contentType: DioMediaType('application', 'pdf'),
        ),
      }),
      options: await _authorizedOptions(
        'A Firebase ID token is required to upload documents',
      ),
    );

    return _DocumentJson(response.data).toDocument();
  }

  @override
  Future<List<RevisionDocument>> listSubjectDocuments({
    required String subjectId,
  }) async {
    final response = await _dio.get<Object?>(
      '/subjects/$subjectId/documents',
      options: await _authorizedOptions(
        'A Firebase ID token is required to load documents',
      ),
    );
    final rawDocuments = response.data;

    if (rawDocuments is! List) {
      throw const FormatException('Invalid documents response');
    }

    return rawDocuments
        .map((document) => _DocumentJson(document).toDocument())
        .toList(growable: false);
  }

  @override
  Future<RevisionDocument> getDocument({required String documentId}) async {
    final response = await _dio.get<Object?>(
      '/documents/$documentId',
      options: await _authorizedOptions(
        'A Firebase ID token is required to load documents',
      ),
    );

    return _DocumentJson(response.data).toDocument();
  }

  @override
  Future<void> deleteDocument({required String documentId}) async {
    await _dio.delete<Object?>(
      '/documents/$documentId',
      options: await _authorizedOptions(
        'A Firebase ID token is required to delete documents',
      ),
    );
  }

  @override
  Future<DocumentKnowledgeUnitsResponse> listDocumentKnowledgeUnits({
    required String documentId,
  }) async {
    try {
      final response = await _dio.get<Object?>(
        '/documents/$documentId/knowledge-units',
        options: await _authorizedOptions(
          'A Firebase ID token is required to load document knowledge units',
        ),
      );

      return _KnowledgeUnitsJson(response.data).toResponse();
    } on DioException catch (error) {
      if (error.response?.statusCode == 409) {
        throw const DocumentNotReadyException();
      }

      rethrow;
    }
  }

  @override
  Future<DocumentSummary?> getDocumentSummary({
    required String documentId,
  }) async {
    try {
      final response = await _dio.get<Object?>(
        '/documents/$documentId/summary',
        options: await _authorizedOptions(
          'A Firebase ID token is required to load document summaries',
        ),
      );

      return _DocumentSummaryJson(response.data).toSummary();
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        return null;
      }
      _throwArtifactRequestException(error);
    }
  }

  @override
  Future<DocumentSummary> generateDocumentSummary({
    required String documentId,
  }) async {
    try {
      final response = await _dio.post<Object?>(
        '/documents/$documentId/summary',
        options: await _authorizedOptions(
          'A Firebase ID token is required to generate document summaries',
        ),
      );

      return _DocumentSummaryJson(response.data).toSummary();
    } on DioException catch (error) {
      _throwArtifactRequestException(error);
    }
  }

  @override
  Future<RevisionSheet?> getRevisionSheet({required String documentId}) async {
    try {
      final response = await _dio.get<Object?>(
        '/documents/$documentId/revision-sheet',
        options: await _authorizedOptions(
          'A Firebase ID token is required to load revision sheets',
        ),
      );

      return RevisionSheetJson(response.data).toRevisionSheet();
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        return null;
      }
      _throwArtifactRequestException(error);
    }
  }

  @override
  Future<RevisionSheet> generateRevisionSheet({
    required String documentId,
  }) async {
    try {
      final response = await _dio.post<Object?>(
        '/documents/$documentId/revision-sheet',
        options: await _authorizedOptions(
          'A Firebase ID token is required to generate revision sheets',
        ),
      );

      return RevisionSheetJson(response.data).toRevisionSheet();
    } on DioException catch (error) {
      _throwArtifactRequestException(error);
    }
  }

  Future<Options> _authorizedOptions(String missingTokenMessage) async {
    final token = (await _getIdToken())?.trim();

    if (token == null || token.isEmpty) {
      throw StateError(missingTokenMessage);
    }

    return Options(headers: {'Authorization': 'Bearer $token'});
  }

  Never _throwArtifactRequestException(DioException error) {
    final statusCode = error.response?.statusCode;

    if (statusCode == 409) {
      throw const DocumentNotReadyException();
    }

    if (statusCode != null) {
      throw DocumentArtifactRequestException(statusCode: statusCode);
    }

    throw error;
  }
}

class _DocumentJson {
  const _DocumentJson(this.value);

  final Object? value;

  RevisionDocument toDocument() {
    final json = value;

    if (json is! Map<String, Object?>) {
      throw const FormatException('Invalid document response');
    }

    final id = json['id'];
    final subjectId = json['subjectId'];
    final kind = json['kind'];
    final fileName = json['fileName'];
    final status = json['status'];
    final mimeType = json['mimeType'];
    final errorCode = json['errorCode'];

    if (id is! String ||
        subjectId is! String ||
        kind is! String ||
        fileName is! String ||
        status is! String ||
        mimeType is! String ||
        (errorCode != null && errorCode is! String)) {
      throw const FormatException('Invalid document response');
    }

    return RevisionDocument(
      id: id,
      subjectId: subjectId,
      kind: kind,
      fileName: fileName,
      status: status,
      mimeType: mimeType,
      errorCode: errorCode as String?,
    );
  }
}

class _KnowledgeUnitsJson {
  const _KnowledgeUnitsJson(this.value);

  final Object? value;

  DocumentKnowledgeUnitsResponse toResponse() {
    final json = value;

    if (json is! Map<String, Object?>) {
      throw const FormatException('Invalid knowledge units response');
    }

    final documentId = json['documentId'];
    final items = json['items'];

    if (documentId is! String || items is! List) {
      throw const FormatException('Invalid knowledge units response');
    }

    return DocumentKnowledgeUnitsResponse(
      documentId: documentId,
      items: items
          .map((item) => _KnowledgeUnitJson(item).toKnowledgeUnit())
          .toList(growable: false),
    );
  }
}

class _KnowledgeUnitJson {
  const _KnowledgeUnitJson(this.value);

  final Object? value;

  DocumentKnowledgeUnit toKnowledgeUnit() {
    final json = value;

    if (json is! Map<String, Object?>) {
      throw const FormatException('Invalid knowledge unit response');
    }

    final id = json['id'];
    final title = json['title'];
    final summary = json['summary'];
    final difficulty = json['difficulty'];
    final displayOrder = json['displayOrder'];
    final confidence = json['confidence'];
    final sources = json['sources'];

    if (id is! String ||
        title is! String ||
        summary is! String ||
        (difficulty != null && difficulty is! String) ||
        (displayOrder != null && displayOrder is! int) ||
        (confidence != null && confidence is! num) ||
        sources is! List) {
      throw const FormatException('Invalid knowledge unit response');
    }

    return DocumentKnowledgeUnit(
      id: id,
      title: title,
      summary: summary,
      difficulty: difficulty as String?,
      displayOrder: displayOrder as int?,
      confidence: (confidence as num?)?.toDouble(),
      sources: sources
          .map((source) => _KnowledgeUnitSourceJson(source).toSource())
          .toList(growable: false),
    );
  }
}

class _KnowledgeUnitSourceJson {
  const _KnowledgeUnitSourceJson(this.value);

  final Object? value;

  DocumentKnowledgeUnitSource toSource() {
    final json = value;

    if (json is! Map<String, Object?>) {
      throw const FormatException('Invalid knowledge unit source response');
    }

    final chunkId = json['chunkId'];
    final text = json['text'];
    final pageNumber = json['pageNumber'];
    final index = json['index'];

    if (chunkId is! String ||
        text is! String ||
        (pageNumber != null && pageNumber is! int) ||
        index is! int) {
      throw const FormatException('Invalid knowledge unit source response');
    }

    return DocumentKnowledgeUnitSource(
      chunkId: chunkId,
      text: text,
      pageNumber: pageNumber as int?,
      index: index,
    );
  }
}

class _DocumentSummaryJson {
  const _DocumentSummaryJson(this.value);

  final Object? value;

  DocumentSummary toSummary() {
    final json = value;

    if (json is! Map<String, Object?>) {
      throw const FormatException('Invalid document summary response');
    }

    final id = json['id'];
    final documentId = json['documentId'];
    final subjectId = json['subjectId'];
    final status = json['status'];
    final title = json['title'];
    final content = json['content'];
    final keyPoints = json['keyPoints'];
    final limits = json['limits'];
    final errorCode = json['errorCode'];
    final sources = json['sources'];

    if (id is! String ||
        documentId is! String ||
        subjectId is! String ||
        status is! String ||
        title is! String ||
        content is! String ||
        keyPoints is! List ||
        (limits != null && limits is! String) ||
        (errorCode != null && errorCode is! String) ||
        sources is! List) {
      throw const FormatException('Invalid document summary response');
    }

    return DocumentSummary(
      id: id,
      documentId: documentId,
      subjectId: subjectId,
      status: status,
      title: title,
      content: content,
      keyPoints: _stringList(keyPoints, 'Invalid document summary response'),
      limits: limits as String?,
      errorCode: errorCode as String?,
      sources: sources
          .map((source) => _DocumentArtifactSourceJson(source).toSource())
          .toList(growable: false),
    );
  }
}

class _DocumentArtifactSourceJson {
  const _DocumentArtifactSourceJson(this.value);

  final Object? value;

  DocumentArtifactSource toSource() {
    final json = value;

    if (json is! Map<String, Object?>) {
      throw const FormatException('Invalid artifact source response');
    }

    final chunkId = json['chunkId'];
    final text = json['text'];
    final pageNumber = json['pageNumber'];
    final index = json['index'];

    if (chunkId is! String ||
        text is! String ||
        (pageNumber != null && pageNumber is! int) ||
        index is! int) {
      throw const FormatException('Invalid artifact source response');
    }

    return DocumentArtifactSource(
      chunkId: chunkId,
      text: text,
      pageNumber: pageNumber as int?,
      index: index,
    );
  }
}

List<String> _stringList(List value, String message) {
  if (value.any((item) => item is! String)) {
    throw FormatException(message);
  }

  return value.cast<String>().toList(growable: false);
}

```

### `lib/features/mvp/application/mvp_study_controller.dart`

```dart
import 'package:flutter/foundation.dart';

import '../domain/mvp_study_models.dart';

class MvpStudyController extends ChangeNotifier {
  MvpStudyController._();

  // Adapter temporaire front-only : il donne une experience Course visible
  // pendant que le modele backend Course + Document.courseId est implemente.
  static final MvpStudyController instance = MvpStudyController._();

  String _activeSubjectId = mvpSubjects.first.id;

  List<MvpSubject> get subjects => mvpSubjects;

  MvpSubject get activeSubject {
    return subjects.firstWhere((subject) => subject.id == _activeSubjectId);
  }

  MvpCourse get resumeCourse => activeSubject.courses.first;

  MvpCourse? courseById(String id) {
    for (final subject in subjects) {
      for (final course in subject.courses) {
        if (course.id == id) {
          return course;
        }
      }
    }

    return null;
  }

  MvpCourse courseOrFallback(String id) {
    return courseById(id) ?? resumeCourse;
  }

  Iterable<MvpSourceFile> get activeSources {
    return activeSubject.courses.expand((course) => course.sources);
  }

  double get activeMastery {
    final courses = activeSubject.courses;
    if (courses.isEmpty) {
      return 0;
    }

    final total = courses.fold<double>(
      0,
      (sum, course) => sum + course.mastery,
    );
    return total / courses.length;
  }

  void selectSubject(String id) {
    if (id == _activeSubjectId) {
      return;
    }

    if (!subjects.any((subject) => subject.id == id)) {
      return;
    }

    _activeSubjectId = id;
    notifyListeners();
  }

  void resetForTests() {
    _activeSubjectId = mvpSubjects.first.id;
    notifyListeners();
  }
}

```

### `lib/features/mvp/presentation/mvp_sources_page.dart`

```dart
import 'package:flutter/material.dart';

import '../../../presentation/design_system/components/revision_mvp_components.dart';
import '../../../presentation/design_system/tokens/revision_spacing.dart';
import '../application/mvp_study_controller.dart';
import 'mvp_page_helpers.dart';

class MvpSourcesPage extends StatelessWidget {
  const MvpSourcesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: MvpStudyController.instance,
      builder: (context, child) {
        final controller = MvpStudyController.instance;
        final sources = controller.activeSources.toList();

        return RevisionPageScaffold(
          children: [
            const MvpTopBar(),
            RevisionSectionHeader(
              title: 'Sources',
              subtitle:
                  'Fichiers attachés aux cours de ${controller.activeSubject.name}',
            ),
            if (sources.isEmpty)
              const RevisionGlassCard(
                child: Text('Aucune source pour le moment.'),
              )
            else
              Column(
                children: [
                  for (final source in sources) ...[
                    RevisionSourceFileCard(
                      fileName: source.fileName,
                      sizeLabel: source.sizeLabel,
                      statusLabel: source.statusLabel,
                    ),
                    if (source != sources.last)
                      const SizedBox(height: RevisionSpacing.m),
                  ],
                ],
              ),
            Center(
              child: RevisionFloatingAddButton(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Ajout de source prévu avec l’API Course.'),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

```

### `test/app/router/app_router_test.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:revision_app/app/di/providers.dart';
import 'package:revision_app/app/router/app_router.dart';
import 'package:revision_app/app/router/app_routes.dart';
import 'package:revision_app/features/activities/application/activity_controller.dart';
import 'package:revision_app/features/auth/application/auth_controller.dart';
import 'package:revision_app/features/auth/domain/auth_session.dart';
import 'package:revision_app/features/auth/domain/authenticated_user.dart';
import 'package:revision_app/features/courses/application/courses_providers.dart';
import 'package:revision_app/features/courses/domain/course_models.dart';
import 'package:revision_app/features/documents/domain/revision_document.dart';
import 'package:revision_app/features/documents/application/documents_controller.dart';
import 'package:revision_app/features/onboarding/application/revision_goals_controller.dart';
import 'package:revision_app/features/revision_sessions/application/revision_session_controller.dart';
import 'package:revision_app/features/revision_sessions/data/revision_sessions_api.dart';
import 'package:revision_app/features/subjects/application/subjects_controller.dart';
import 'package:revision_app/features/subjects/domain/subject.dart';
import 'package:revision_app/features/today/application/today_controller.dart';
import 'package:revision_app/features/today/domain/today_plan.dart';
import 'package:revision_app/presentation/widgets/revision_button.dart';

import '../../fakes/in_memory_activity_api.dart';
import '../../fakes/in_memory_courses_repository.dart';
import '../../fakes/in_memory_documents_api.dart';
import '../../fakes/in_memory_revision_goals_repository.dart';
import '../../fakes/in_memory_revision_sessions_api.dart';
import '../../fakes/in_memory_subjects_repository.dart';
import '../../fakes/in_memory_today_repository.dart';

class FakeAuthRepository implements AuthRepository {
  @override
  Stream<AuthSession> watchSession() async* {
    yield const AuthSession.signedOut();
  }

  @override
  Future<String> requireIdToken() async => 'firebase-id-token';

  @override
  Future<void> signInWithApple() async {}

  @override
  Future<void> signInWithGoogle() async {}

  @override
  Future<void> signOut() async {}
}

void main() {
  test(
    'appRouterProvider exposes a GoRouter with Revision initial location',
    () {
      final authController = AuthController(
        FakeAuthRepository(),
        initialSession: const AuthSession.signedIn(
          AuthenticatedUser(
            uid: 'firebase-123',
            email: 'student@example.com',
            displayName: 'Karim',
          ),
        ),
      );
      addTearDown(authController.dispose);

      final container = ProviderContainer(
        overrides: [
          authControllerProvider.overrideWithValue(authController),
          subjectsControllerProvider.overrideWithValue(
            SubjectsController(InMemorySubjectsRepository()),
          ),
          revisionGoalsControllerProvider.overrideWithValue(
            RevisionGoalsController(InMemoryRevisionGoalsRepository()),
          ),
          documentsControllerProvider.overrideWithValue(
            DocumentsController(InMemoryDocumentsApi()),
          ),
          activityControllerProvider.overrideWithValue(
            ActivityController(InMemoryActivityApi()),
          ),
          revisionSessionControllerProvider.overrideWithValue(
            RevisionSessionController(InMemoryRevisionSessionsApi()),
          ),
          todayControllerProvider.overrideWithValue(
            TodayController(InMemoryTodayRepository()),
          ),
        ],
      );
      addTearDown(container.dispose);

      final router = container.read(appRouterProvider);

      expect(router, isA<GoRouter>());
      expect(router.routeInformationProvider.value.uri.path, AppRoutes.home);
    },
  );

  test('AppRoutes builds revision session routes with query params', () {
    final route = AppRoutes.revisionSession(
      subjectId: 'subject-1',
      knowledgeUnitId: 'unit-1',
      preferredAction: 'open_question',
    );

    expect(
      route,
      '/activities/session?subjectId=subject-1&knowledgeUnitId=unit-1&preferredAction=open_question',
    );
  });

  test('AppRoutes builds rich closed routes with query params', () {
    final route = AppRoutes.richClosedExercise(
      subjectId: 'subject-1',
      knowledgeUnitId: 'unit-1',
      documentId: 'document-1',
    );

    expect(
      route,
      '/activities/rich-closed?subjectId=subject-1&documentId=document-1&knowledgeUnitId=unit-1',
    );
  });

  test('revision session route is a sibling of activities route', () {
    final harness = _RouterHarness();
    addTearDown(harness.dispose);

    final shellRoute = harness.router.configuration.routes
        .whereType<StatefulShellRoute>()
        .single;
    final activitiesBranch = shellRoute.branches.singleWhere((branch) {
      return branch.routes.whereType<GoRoute>().any(
        (route) => route.path == AppRoutes.activities,
      );
    });
    final activitiesRoutes = activitiesBranch.routes.whereType<GoRoute>();
    final activitiesRoute = activitiesRoutes.singleWhere(
      (route) => route.path == AppRoutes.activities,
    );

    expect(
      activitiesRoutes.map((route) => route.path),
      containsAll([
        AppRoutes.activities,
        AppRoutes.revisionSessionPath,
        AppRoutes.richClosedExercisePath,
      ]),
    );
    expect(activitiesRoute.routes, isEmpty);
  });

  testWidgets('home route does not render MVP fixture course data', (
    tester,
  ) async {
    final harness = _RouterHarness();
    addTearDown(harness.dispose);

    await tester.pumpWidget(harness.buildApp());
    await tester.pumpAndSettle();

    expect(find.text('Accueil'), findsWidgets);
    expect(find.text('Aucune matière réelle'), findsOneWidget);
    expect(find.text('Math'), findsNothing);
    expect(find.text('Loi normale'), findsNothing);
    expect(find.text('78%'), findsNothing);
    expect(find.text('870'), findsNothing);
    expect(find.text('7 jours'), findsNothing);
  });

  testWidgets('course route shows not found instead of fixture fallback', (
    tester,
  ) async {
    final harness = _RouterHarness();
    addTearDown(harness.dispose);

    await tester.pumpWidget(harness.buildApp());
    harness.router.go(AppRoutes.course('unknown'));
    await tester.pumpAndSettle();

    expect(find.text('Cours introuvable'), findsOneWidget);
    expect(find.text('Aucun fallback vers un cours fictif'), findsOneWidget);
    expect(find.text('Loi normale'), findsNothing);
  });

  testWidgets('course route shows real course detail when available', (
    tester,
  ) async {
    final harness = _RouterHarness();
    harness.subjectsRepository.subjects.add(
      const Subject(
        id: 'subject-1',
        name: 'Droit constitutionnel',
        priority: 4,
      ),
    );
    const course = CourseListItem(
      id: 'course-1',
      subjectId: 'subject-1',
      title: 'Institutions de la Ve République',
      chapterLabel: 'Chapitre 2',
      estimatedMinutes: 35,
      sourceCount: 1,
      readySourceCount: 1,
      processingSourceCount: 0,
      failedSourceCount: 0,
    );
    harness.coursesRepository.coursesBySubject['subject-1'] = [course];
    harness.coursesRepository.detailsByCourse['course-1'] = const CourseDetail(
      course: course,
      subject: CourseSubjectSummary(
        id: 'subject-1',
        name: 'Droit constitutionnel',
      ),
      sources: [
        CourseDocument(
          id: 'document-1',
          courseId: 'course-1',
          documentId: 'document-1',
          fileName: 'cours.pdf',
          status: CourseDocumentStatus.ready,
        ),
      ],
    );
    addTearDown(harness.dispose);

    await tester.pumpWidget(harness.buildApp());
    harness.router.go(AppRoutes.course('course-1'));
    await tester.pumpAndSettle();

    expect(find.text('Institutions de la Ve République'), findsOneWidget);
    expect(find.text('Droit constitutionnel'), findsOneWidget);
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -500));
    await tester.pumpAndSettle();
    expect(find.text('cours.pdf'), findsOneWidget);
    expect(find.text('Loi normale'), findsNothing);
  });

  testWidgets('course sheet route shows the real course-level revision sheet', (
    tester,
  ) async {
    final harness = _RouterHarness();
    harness.coursesRepository.revisionSheetsByCourse['course-1'] =
        _revisionSheet();
    addTearDown(harness.dispose);

    await tester.pumpWidget(harness.buildApp());
    harness.router.go(AppRoutes.courseSheet('course-1'));
    await tester.pumpAndSettle();

    expect(find.text('Fiche de cours'), findsWidgets);
    expect(find.text('Institutions'), findsOneWidget);
    expect(find.text('Le Parlement contrôle le Gouvernement.'), findsOneWidget);
    expect(find.text('Loi normale'), findsNothing);
    expect(find.text('78%'), findsNothing);
  });

  testWidgets('revision session result route hides static MVP score', (
    tester,
  ) async {
    final harness = _RouterHarness();
    addTearDown(harness.dispose);

    await tester.pumpWidget(harness.buildApp());
    harness.router.go(AppRoutes.revisionSessionResultV2(sessionId: 'fake'));
    await tester.pumpAndSettle();

    expect(find.text('Résultat réel indisponible'), findsOneWidget);
    expect(find.text('78%'), findsNothing);
    expect(find.text('4/5 bonnes'), findsNothing);
  });

  testWidgets('legacy real routes stay accessible', (tester) async {
    final harness = _RouterHarness();
    addTearDown(harness.dispose);

    await tester.pumpWidget(harness.buildApp());

    harness.router.go(AppRoutes.subjects);
    await tester.pumpAndSettle();
    expect(find.text('Tes matieres'), findsOneWidget);

    harness.router.go(AppRoutes.today);
    await tester.pumpAndSettle();
    expect(find.text('Plan du jour'), findsOneWidget);

    harness.router.go(AppRoutes.activities);
    await tester.pumpAndSettle();
    expect(find.text('Activites'), findsWidgets);
  });

  testWidgets(
    'revision session route starts a session without direct activity',
    (tester) async {
      final harness = _RouterHarness();
      addTearDown(harness.dispose);

      await tester.pumpWidget(harness.buildApp());
      harness.router.go(
        AppRoutes.revisionSession(
          subjectId: 'subject-1',
          knowledgeUnitId: 'unit-1',
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Révision IA'), findsOneWidget);
      expect(find.text('Question ouverte test'), findsOneWidget);
      expect(harness.revisionSessionsApi.startCount, 1);
      expect(harness.revisionSessionsApi.startedSubjectId, 'subject-1');
      expect(harness.revisionSessionsApi.startedKnowledgeUnitId, 'unit-1');
      expect(harness.activityApi.startedDiagnosticQuizCount, 0);
      expect(harness.activityApi.startedOpenQuestionCount, 0);
    },
  );

  testWidgets(
    'revision session rich closed action navigates to rich closed exercise',
    (tester) async {
      final harness = _RouterHarness();
      harness.revisionSessionsApi.startResponse =
          richClosedRevisionSessionResponse();
      addTearDown(harness.dispose);

      await tester.pumpWidget(harness.buildApp());
      harness.router.go(
        AppRoutes.revisionSession(
          subjectId: 'subject-1',
          knowledgeUnitId: 'unit-1',
          preferredAction: 'rich_closed_exercise',
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Révision IA'), findsOneWidget);
      expect(find.text('Notion: Institutions politiques'), findsOneWidget);
      expect(harness.revisionSessionsApi.startCount, 1);
      expect(
        harness.revisionSessionsApi.startedPreferredAction,
        RevisionSessionPreferredAction.richClosedExercise,
      );
      expect(harness.activityApi.startedRichClosedCount, 0);
      expect(harness.activityApi.startedDiagnosticQuizCount, 0);
      expect(harness.activityApi.startedOpenQuestionCount, 0);

      await tester.ensureVisible(
        find.widgetWithText(RevisionButton, 'Commencer'),
      );
      await tester.pumpAndSettle();
      await tester.drag(find.byType(Scrollable).last, const Offset(0, -160));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(RevisionButton, 'Commencer'));
      await tester.pumpAndSettle();

      expect(
        harness.router.routeInformationProvider.value.uri.toString(),
        '/activities/rich-closed?subjectId=subject-1&documentId=document-1&knowledgeUnitId=unit-1',
      );
      expect(find.text('Questions riches'), findsOneWidget);
      expect(harness.activityApi.startedRichClosedCount, 1);
      expect(harness.activityApi.startedRichClosedSubjectId, 'subject-1');
      expect(harness.activityApi.startedRichClosedDocumentId, 'document-1');
      expect(harness.activityApi.startedRichClosedKnowledgeUnitId, 'unit-1');
      expect(harness.activityApi.startedDiagnosticQuizCount, 0);
      expect(harness.activityApi.startedOpenQuestionCount, 0);
    },
  );

  testWidgets('activities route keeps diagnostic quiz behavior', (
    tester,
  ) async {
    final harness = _RouterHarness();
    addTearDown(harness.dispose);

    await tester.pumpWidget(harness.buildApp());
    harness.router.go(AppRoutes.activitiesForSubject('subject-1'));
    await tester.pumpAndSettle();

    expect(find.text('Activites'), findsWidgets);
    expect(find.text('Diagnostic rapide'), findsOneWidget);
    expect(harness.activityApi.startedDiagnosticQuizCount, 1);
    expect(harness.activityApi.startedOpenQuestionCount, 0);
    expect(harness.revisionSessionsApi.startCount, 0);
  });

  testWidgets(
    'rich closed route starts an exercise without diagnostic or open question',
    (tester) async {
      final harness = _RouterHarness();
      addTearDown(harness.dispose);

      await tester.pumpWidget(harness.buildApp());
      harness.router.go(
        AppRoutes.richClosedExercise(
          subjectId: 'subject-1',
          knowledgeUnitId: 'unit-1',
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Questions riches'), findsOneWidget);
      expect(find.text('Exercice institutions politiques'), findsOneWidget);
      expect(harness.activityApi.startedRichClosedCount, 1);
      expect(harness.activityApi.startedDiagnosticQuizCount, 0);
      expect(harness.activityApi.startedOpenQuestionCount, 0);
    },
  );

  testWidgets('activities page exposes the rich closed entry', (tester) async {
    final harness = _RouterHarness();
    addTearDown(harness.dispose);

    await tester.pumpWidget(harness.buildApp());
    harness.router.go(
      Uri(
        path: AppRoutes.activities,
        queryParameters: {
          'subjectId': 'subject-1',
          'knowledgeUnitId': 'unit-1',
        },
      ).toString(),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(RevisionButton, 'Questions riches'));
    await tester.pumpAndSettle();

    expect(find.text('Questions riches'), findsOneWidget);
    expect(harness.activityApi.startedRichClosedCount, 1);
    expect(harness.activityApi.startedRichClosedSubjectId, 'subject-1');
    expect(harness.activityApi.startedRichClosedKnowledgeUnitId, 'unit-1');
    expect(harness.revisionSessionsApi.startCount, 0);
  });

  testWidgets(
    'today rich closed action navigates to rich closed without other activity',
    (tester) async {
      final harness = _RouterHarness();
      harness.todayRepository.plan = _todayPlanWithRichClosedAction();
      addTearDown(harness.dispose);

      await tester.pumpWidget(harness.buildApp());
      harness.router.go(AppRoutes.today);
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Commencer'));
      await tester.tap(find.text('Commencer'));
      await tester.pumpAndSettle();

      expect(
        harness.router.routeInformationProvider.value.uri.toString(),
        '/activities/rich-closed?subjectId=subject-1&documentId=document-1&knowledgeUnitId=unit-1',
      );
      expect(find.text('Questions riches'), findsOneWidget);
      expect(harness.activityApi.startedRichClosedCount, 1);
      expect(harness.activityApi.startedRichClosedSubjectId, 'subject-1');
      expect(harness.activityApi.startedRichClosedKnowledgeUnitId, 'unit-1');
      expect(harness.activityApi.startedRichClosedDocumentId, 'document-1');
      expect(harness.activityApi.startedDiagnosticQuizCount, 0);
      expect(harness.activityApi.startedOpenQuestionCount, 0);
      expect(harness.revisionSessionsApi.startCount, 0);
    },
  );

  testWidgets(
    'revision session route by session id loads without direct activity',
    (tester) async {
      final harness = _RouterHarness();
      addTearDown(harness.dispose);

      await tester.pumpWidget(harness.buildApp());
      harness.router.go(
        AppRoutes.revisionSession(sessionId: 'revision-session-1'),
      );
      await tester.pumpAndSettle();

      expect(find.text('Révision IA'), findsOneWidget);
      expect(harness.revisionSessionsApi.loadCount, 1);
      expect(harness.revisionSessionsApi.loadedSessionId, 'revision-session-1');
      expect(harness.activityApi.startedDiagnosticQuizCount, 0);
      expect(harness.activityApi.startedOpenQuestionCount, 0);
    },
  );
}

class _RouterHarness {
  _RouterHarness()
    : authController = AuthController(
        _SignedInAuthRepository(),
        initialSession: _signedInSession,
      ),
      revisionGoalsController = RevisionGoalsController(
        InMemoryRevisionGoalsRepository(),
      ),
      documentsController = DocumentsController(InMemoryDocumentsApi()),
      activityApi = InMemoryActivityApi(),
      revisionSessionsApi = InMemoryRevisionSessionsApi() {
    subjectsRepository = InMemorySubjectsRepository();
    coursesRepository = InMemoryCoursesRepository();
    subjectsController = SubjectsController(subjectsRepository);
    todayRepository = InMemoryTodayRepository();
    todayController = TodayController(todayRepository);
    activityController = ActivityController(activityApi);
    revisionSessionController = RevisionSessionController(revisionSessionsApi);
    router = createAppRouter(
      authController: authController,
      subjectsController: subjectsController,
      revisionGoalsController: revisionGoalsController,
      documentsController: documentsController,
      activityController: activityController,
      revisionSessionController: revisionSessionController,
      todayController: todayController,
    );
  }

  final AuthController authController;
  late final InMemorySubjectsRepository subjectsRepository;
  late final InMemoryCoursesRepository coursesRepository;
  late final SubjectsController subjectsController;
  final RevisionGoalsController revisionGoalsController;
  final DocumentsController documentsController;
  final InMemoryActivityApi activityApi;
  final InMemoryRevisionSessionsApi revisionSessionsApi;
  late final InMemoryTodayRepository todayRepository;
  late final TodayController todayController;
  late final ActivityController activityController;
  late final RevisionSessionController revisionSessionController;
  late final GoRouter router;

  Widget buildApp() {
    return ProviderScope(
      overrides: [
        authControllerProvider.overrideWithValue(authController),
        subjectsRepositoryProvider.overrideWithValue(subjectsRepository),
        subjectsControllerProvider.overrideWithValue(subjectsController),
        coursesRepositoryProvider.overrideWithValue(coursesRepository),
        revisionGoalsControllerProvider.overrideWithValue(
          revisionGoalsController,
        ),
        documentsControllerProvider.overrideWithValue(documentsController),
        activityControllerProvider.overrideWithValue(activityController),
        revisionSessionControllerProvider.overrideWithValue(
          revisionSessionController,
        ),
        todayRepositoryProvider.overrideWithValue(todayRepository),
        todayControllerProvider.overrideWithValue(todayController),
      ],
      child: MaterialApp.router(routerConfig: router),
    );
  }

  void dispose() {
    router.dispose();
    authController.dispose();
  }
}

class _SignedInAuthRepository implements AuthRepository {
  @override
  Stream<AuthSession> watchSession() async* {
    yield _signedInSession;
  }

  @override
  Future<String> requireIdToken() async => 'firebase-id-token';

  @override
  Future<void> signInWithApple() async {}

  @override
  Future<void> signInWithGoogle() async {}

  @override
  Future<void> signOut() async {}
}

const _signedInSession = AuthSession.signedIn(
  AuthenticatedUser(
    uid: 'firebase-123',
    email: 'student@example.com',
    displayName: 'Karim',
  ),
);

RevisionSheet _revisionSheet() {
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

TodayPlan _todayPlanWithRichClosedAction() {
  return TodayPlan(
    generatedAt: DateTime.parse('2026-06-15T10:00:00.000Z'),
    items: const [
      TodayPlanItem(
        id: 'subject-1:unit-1:rich_closed_exercise',
        subjectId: 'subject-1',
        subjectName: 'Droit constitutionnel',
        documentId: 'document-1',
        knowledgeUnitId: 'unit-1',
        knowledgeUnitTitle: 'Institutions politiques',
        masteryScore: 0.2,
        action: TodayPlanActionType.richClosedExercise,
        estimatedMinutes: 8,
        priority: 605,
        reasonCode: TodayPlanReasonCode.richClosedPractice,
        reason: 'Questions riches recommandées.',
        startPayload: TodayPlanStartPayload(
          subjectId: 'subject-1',
          documentId: 'document-1',
          knowledgeUnitId: 'unit-1',
        ),
      ),
    ],
  );
}

```

### `test/fakes/in_memory_courses_repository.dart`

```dart
import 'dart:typed_data';

import 'package:revision_app/features/courses/domain/course_models.dart';
import 'package:revision_app/features/courses/domain/courses_repository.dart';
import 'package:revision_app/features/documents/domain/revision_document.dart';

class InMemoryCoursesRepository implements CoursesRepository {
  final Map<String, List<CourseListItem>> coursesBySubject = {};
  final Map<String, CourseDetail> detailsByCourse = {};
  final Map<String, RevisionSheet?> revisionSheetsByCourse = {};
  final Map<String, RevisionSheet> generatedRevisionSheetsByCourse = {};
  final Map<String, Object> revisionSheetErrorsByCourse = {};
  int createCount = 0;
  int getCourseCount = 0;
  int getRevisionSheetCount = 0;
  int generateRevisionSheetCount = 0;
  int uploadCount = 0;
  String? lastUploadedCourseId;
  String? lastUploadedFileName;
  Uint8List? lastUploadedBytes;
  Object? uploadError;
  Duration uploadDelay = Duration.zero;

  @override
  Future<List<CourseListItem>> listCourses({required String subjectId}) async {
    return List.unmodifiable(coursesBySubject[subjectId] ?? const []);
  }

  @override
  Future<CourseDetail> getCourse({required String courseId}) async {
    getCourseCount += 1;
    final detail = detailsByCourse[courseId];

    if (detail == null) {
      throw const CourseNotFoundException('Course not found');
    }

    return detail;
  }

  @override
  Future<CourseListItem> createCourse({
    required String subjectId,
    required CreateCourseInput input,
  }) async {
    createCount += 1;
    final course = CourseListItem(
      id: 'course-$createCount',
      subjectId: subjectId,
      title: input.title,
      description: input.description,
      chapterLabel: input.chapterLabel,
      estimatedMinutes: input.estimatedMinutes,
      sourceCount: 0,
      readySourceCount: 0,
      processingSourceCount: 0,
      failedSourceCount: 0,
    );
    coursesBySubject.putIfAbsent(subjectId, () => []).add(course);
    detailsByCourse[course.id] = CourseDetail(
      course: course,
      subject: CourseSubjectSummary(id: subjectId, name: 'Matière réelle'),
      sources: const [],
    );

    return course;
  }

  @override
  Future<CourseDocument> uploadCoursePdf({
    required String courseId,
    required String fileName,
    required Uint8List bytes,
  }) async {
    if (uploadDelay > Duration.zero) {
      await Future<void>.delayed(uploadDelay);
    }

    final error = uploadError;
    if (error != null) {
      throw error;
    }

    final detail = detailsByCourse[courseId];
    if (detail == null) {
      throw const CourseNotFoundException('Course not found');
    }

    uploadCount += 1;
    lastUploadedCourseId = courseId;
    lastUploadedFileName = fileName;
    lastUploadedBytes = bytes;

    final document = CourseDocument(
      id: 'document-$uploadCount',
      courseId: courseId,
      documentId: 'document-$uploadCount',
      fileName: fileName,
      status: CourseDocumentStatus.uploaded,
      createdAt: DateTime.utc(2026, 6, 18, 12),
      updatedAt: DateTime.utc(2026, 6, 18, 12),
    );
    detailsByCourse[courseId] = CourseDetail(
      course: detail.course,
      subject: detail.subject,
      sources: [...detail.sources, document],
      progress: detail.progress,
    );

    return document;
  }

  @override
  Future<RevisionSheet?> getCourseRevisionSheet({
    required String courseId,
  }) async {
    getRevisionSheetCount += 1;
    final error = revisionSheetErrorsByCourse[courseId];
    if (error != null) {
      throw error;
    }

    return revisionSheetsByCourse[courseId];
  }

  @override
  Future<RevisionSheet> generateCourseRevisionSheet({
    required String courseId,
  }) async {
    generateRevisionSheetCount += 1;
    final error = revisionSheetErrorsByCourse[courseId];
    if (error != null) {
      throw error;
    }

    final existing = revisionSheetsByCourse[courseId];
    if (existing != null) {
      return existing;
    }

    final generated = generatedRevisionSheetsByCourse[courseId];
    if (generated != null) {
      revisionSheetsByCourse[courseId] = generated;
      return generated;
    }

    throw const CourseRevisionSheetNotReadyException(
      'Course has no ready source',
    );
  }

  @override
  Future<CourseProgress> getCourseProgress({required String courseId}) {
    throw UnimplementedError('Progression course réelle hors CORE-02');
  }
}

```

### `test/features/courses/course_detail_page_test.dart`

```dart
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:revision_app/features/courses/application/course_pdf_picker.dart';
import 'package:revision_app/features/courses/application/courses_providers.dart';
import 'package:revision_app/features/courses/domain/course_models.dart';
import 'package:revision_app/features/courses/presentation/course_detail_page.dart';
import 'package:revision_app/presentation/design_system/components/revision_mvp_components.dart';

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
    expect(find.text('Ajouter une source'), findsOneWidget);
    expect(find.text('Loi normale'), findsNothing);
    expect(find.text('78%'), findsNothing);
    expect(find.text('870'), findsNothing);
    expect(find.text('7 jours'), findsNothing);

    await tester.tap(find.text('Ajouter une source'));
    await tester.pump();

    expect(find.text('Upload en cours...'), findsOneWidget);

    await tester.pumpAndSettle();

    expect(repository.uploadCount, 1);
    expect(repository.lastUploadedCourseId, 'course-1');
    expect(repository.lastUploadedFileName, 'cours.pdf');
    expect(find.text('Source ajoutée'), findsOneWidget);
    expect(find.text('cours.pdf'), findsOneWidget);
    expect(find.text('Téléversée'), findsOneWidget);
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
            errorCode: 'PDF_PARSE_FAILED',
          ),
        ],
      );

    await tester.pumpWidget(
      testApp(repository: repository, picker: FakeCoursePdfPicker(null)),
    );
    await tester.pumpAndSettle();

    expect(find.text('broken.pdf'), findsOneWidget);
    expect(find.text('Erreur'), findsOneWidget);
    expect(find.textContaining('PDF_PARSE_FAILED'), findsOneWidget);
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
    await tester.pumpAndSettle();

    expect(repository.getCourseCount, 1);
    expect(find.text('Traitement en cours'), findsOneWidget);

    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    expect(repository.getCourseCount, greaterThanOrEqualTo(2));
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

    final emptyButton = tester.widget<RevisionGradientButton>(
      find.widgetWithText(
        RevisionGradientButton,
        'Ajoute une source pour créer une fiche',
      ),
    );
    expect(emptyButton.onPressed, isNull);
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

    final processingButton = tester.widget<RevisionGradientButton>(
      find.widgetWithText(
        RevisionGradientButton,
        'Fiche disponible après traitement',
      ),
    );
    expect(processingButton.onPressed, isNull);
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

    final sheetButton = tester.widget<RevisionGradientButton>(
      find.widgetWithText(RevisionGradientButton, 'Fiche de cours'),
    );
    expect(sheetButton.onPressed, isNotNull);

    final quickButton = tester.widget<RevisionGradientButton>(
      find.widgetWithText(
        RevisionGradientButton,
        'Révision rapide bientôt disponible',
      ),
    );
    expect(quickButton.onPressed, isNull);
  });
}

Widget testApp({
  required InMemoryCoursesRepository repository,
  required CoursePdfPicker picker,
}) {
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

class FakeCoursePdfPicker implements CoursePdfPicker {
  FakeCoursePdfPicker(this.result);

  final PickedCoursePdf? result;

  @override
  Future<PickedCoursePdf?> pickPdf() async => result;
}

```

### `test/features/courses/courses_providers_test.dart`

```dart
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:revision_app/features/courses/application/course_pdf_picker.dart';
import 'package:revision_app/features/courses/application/courses_providers.dart';
import 'package:revision_app/features/courses/domain/course_models.dart';
import 'package:revision_app/features/courses/domain/courses_repository.dart';
import 'package:revision_app/features/documents/domain/revision_document.dart';

import '../../fakes/in_memory_courses_repository.dart';

void main() {
  test('coursesProvider loads real courses for a subject', () async {
    final repository = InMemoryCoursesRepository()
      ..coursesBySubject['subject-1'] = const [
        CourseListItem(
          id: 'course-1',
          subjectId: 'subject-1',
          title: 'Droit constitutionnel',
          sourceCount: 0,
          readySourceCount: 0,
          processingSourceCount: 0,
          failedSourceCount: 0,
        ),
      ];
    final container = ProviderContainer(
      overrides: [coursesRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);

    final courses = await container.read(coursesProvider('subject-1').future);

    expect(courses.single.title, 'Droit constitutionnel');
  });

  test('createCourseController invalidates the subject course list', () async {
    final repository = InMemoryCoursesRepository();
    final container = ProviderContainer(
      overrides: [coursesRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);

    expect(await container.read(coursesProvider('subject-1').future), isEmpty);

    final created = await container
        .read(createCourseControllerProvider.notifier)
        .create(
          subjectId: 'subject-1',
          input: const CreateCourseInput(title: 'Droit constitutionnel'),
        );

    expect(created.title, 'Droit constitutionnel');
    expect(
      await container.read(coursesProvider('subject-1').future),
      hasLength(1),
    );
  });

  test('course detail repository exposes typed not-found errors', () async {
    final repository = InMemoryCoursesRepository();

    await expectLater(
      repository.getCourse(courseId: 'unknown'),
      throwsA(isA<CourseNotFoundException>()),
    );
  });

  test(
    'uploadCourseDocumentController does nothing when picking is cancelled',
    () async {
      final repository = InMemoryCoursesRepository();
      final picker = FakeCoursePdfPicker(null);
      final container = ProviderContainer(
        overrides: [
          coursesRepositoryProvider.overrideWithValue(repository),
          coursePdfPickerProvider.overrideWithValue(picker),
        ],
      );
      addTearDown(container.dispose);

      final result = await container
          .read(uploadCourseDocumentControllerProvider.notifier)
          .upload(detail: courseDetail());

      expect(result, isNull);
      expect(picker.pickCount, 1);
      expect(repository.uploadCount, 0);
      expect(
        container.read(uploadCourseDocumentControllerProvider).hasError,
        false,
      );
    },
  );

  test(
    'uploadCourseDocumentController uploads and invalidates course detail',
    () async {
      final repository = InMemoryCoursesRepository()
        ..detailsByCourse['course-1'] = courseDetail();
      final picker = FakeCoursePdfPicker(
        PickedCoursePdf(
          fileName: 'cours.pdf',
          bytes: Uint8List.fromList('%PDF-1.7'.codeUnits),
        ),
      );
      final container = ProviderContainer(
        overrides: [
          coursesRepositoryProvider.overrideWithValue(repository),
          coursePdfPickerProvider.overrideWithValue(picker),
        ],
      );
      addTearDown(container.dispose);

      expect(
        (await container.read(courseDetailProvider('course-1').future)).sources,
        isEmpty,
      );

      final uploaded = await container
          .read(uploadCourseDocumentControllerProvider.notifier)
          .upload(detail: courseDetail());

      expect(uploaded?.fileName, 'cours.pdf');
      expect(repository.uploadCount, 1);
      expect(repository.lastUploadedCourseId, 'course-1');
      expect(
        (await container.read(courseDetailProvider('course-1').future)).sources,
        hasLength(1),
      );
    },
  );

  test('uploadCourseDocumentController exposes upload errors', () async {
    final repository = InMemoryCoursesRepository()
      ..uploadError = const CourseUploadException('Invalid PDF');
    final picker = FakeCoursePdfPicker(
      PickedCoursePdf(fileName: 'cours.pdf', bytes: Uint8List.fromList([1])),
    );
    final container = ProviderContainer(
      overrides: [
        coursesRepositoryProvider.overrideWithValue(repository),
        coursePdfPickerProvider.overrideWithValue(picker),
      ],
    );
    addTearDown(container.dispose);

    await expectLater(
      container
          .read(uploadCourseDocumentControllerProvider.notifier)
          .upload(detail: courseDetail()),
      throwsA(isA<CourseUploadException>()),
    );

    expect(
      container.read(uploadCourseDocumentControllerProvider).hasError,
      true,
    );
  });

  test(
    'courseRevisionSheetProvider loads an existing course-level sheet',
    () async {
      final repository = InMemoryCoursesRepository()
        ..revisionSheetsByCourse['course-1'] = revisionSheet();
      final container = ProviderContainer(
        overrides: [coursesRepositoryProvider.overrideWithValue(repository)],
      );
      addTearDown(container.dispose);

      final sheet = await container.read(
        courseRevisionSheetProvider('course-1').future,
      );

      expect(sheet?.title, 'Fiche de cours');
      expect(repository.getRevisionSheetCount, 1);
    },
  );

  test(
    'generateCourseRevisionSheetController generates and invalidates',
    () async {
      final repository = InMemoryCoursesRepository()
        ..revisionSheetsByCourse['course-1'] = revisionSheet();
      final container = ProviderContainer(
        overrides: [coursesRepositoryProvider.overrideWithValue(repository)],
      );
      addTearDown(container.dispose);

      await container.read(courseRevisionSheetProvider('course-1').future);

      final sheet = await container
          .read(generateCourseRevisionSheetControllerProvider.notifier)
          .generate(courseId: 'course-1');

      expect(sheet.title, 'Fiche de cours');
      expect(repository.generateRevisionSheetCount, 1);
      expect(
        await container.read(courseRevisionSheetProvider('course-1').future),
        isNotNull,
      );
    },
  );

  test(
    'generateCourseRevisionSheetController exposes not-ready errors',
    () async {
      final repository = InMemoryCoursesRepository()
        ..revisionSheetErrorsByCourse['course-1'] =
            const CourseRevisionSheetNotReadyException(
              'Course has no ready source',
            );
      final container = ProviderContainer(
        overrides: [coursesRepositoryProvider.overrideWithValue(repository)],
      );
      addTearDown(container.dispose);

      await expectLater(
        container
            .read(generateCourseRevisionSheetControllerProvider.notifier)
            .generate(courseId: 'course-1'),
        throwsA(isA<CourseRevisionSheetNotReadyException>()),
      );

      expect(
        container.read(generateCourseRevisionSheetControllerProvider).hasError,
        true,
      );
    },
  );
}

CourseDetail courseDetail() {
  const course = CourseListItem(
    id: 'course-1',
    subjectId: 'subject-1',
    title: 'Droit constitutionnel',
  );
  return const CourseDetail(
    course: course,
    subject: CourseSubjectSummary(id: 'subject-1', name: 'Droit'),
    sources: [],
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

class FakeCoursePdfPicker implements CoursePdfPicker {
  FakeCoursePdfPicker(this.result);

  final PickedCoursePdf? result;
  int pickCount = 0;

  @override
  Future<PickedCoursePdf?> pickPdf() async {
    pickCount += 1;
    return result;
  }
}

```

### `test/features/courses/http_courses_repository_test.dart`

```dart
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:revision_app/features/courses/data/http_courses_repository.dart';
import 'package:revision_app/features/courses/domain/course_models.dart';
import 'package:revision_app/features/courses/domain/courses_repository.dart';

class CapturingHttpClientAdapter implements HttpClientAdapter {
  CapturingHttpClientAdapter(this.response);

  ResponseBody response;
  int fetchCallCount = 0;
  RequestOptions? lastOptions;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    fetchCallCount += 1;
    lastOptions = options;
    return response;
  }
}

void main() {
  test('lists real courses with source counts and bearer token', () async {
    final adapter = CapturingHttpClientAdapter(jsonResponse([courseJson()]));
    final repository = HttpCoursesRepository(
      dio: Dio()..httpClientAdapter = adapter,
      getIdToken: () async => 'firebase-id-token',
    );

    final courses = await repository.listCourses(subjectId: 'subject-1');

    expect(courses.single.title, 'Droit constitutionnel');
    expect(courses.single.estimatedMinutes, 30);
    expect(courses.single.sourceCount, 2);
    expect(courses.single.readySourceCount, 1);
    expect(adapter.lastOptions?.path, '/subjects/subject-1/courses');
    expect(
      adapter.lastOptions?.headers['Authorization'],
      'Bearer firebase-id-token',
    );
  });

  test('creates a real course with the CORE-02 payload', () async {
    final adapter = CapturingHttpClientAdapter(jsonResponse(courseJson()));
    final repository = HttpCoursesRepository(
      dio: Dio()..httpClientAdapter = adapter,
      getIdToken: () async => 'firebase-id-token',
    );

    final course = await repository.createCourse(
      subjectId: 'subject-1',
      input: const CreateCourseInput(
        title: 'Droit constitutionnel',
        description: 'Institutions',
        chapterLabel: 'Chapitre 1',
        estimatedMinutes: 30,
      ),
    );

    expect(course.id, 'course-1');
    expect(adapter.lastOptions?.method, 'POST');
    expect(adapter.lastOptions?.path, '/subjects/subject-1/courses');
    expect(adapter.lastOptions?.data, {
      'title': 'Droit constitutionnel',
      'description': 'Institutions',
      'chapterLabel': 'Chapitre 1',
      'estimatedMinutes': 30,
    });
  });

  test('loads course detail with subject and sources', () async {
    final adapter = CapturingHttpClientAdapter(
      jsonResponse({
        'course': courseJson(sourceCount: 1, readySourceCount: 1),
        'subject': {'id': 'subject-1', 'name': 'Droit'},
        'sources': [sourceJson()],
      }),
    );
    final repository = HttpCoursesRepository(
      dio: Dio()..httpClientAdapter = adapter,
      getIdToken: () async => 'firebase-id-token',
    );

    final detail = await repository.getCourse(courseId: 'course-1');

    expect(detail.subject.name, 'Droit');
    expect(detail.sources.single.status, CourseDocumentStatus.ready);
    expect(detail.sources.single.errorCode, isNull);
    expect(adapter.lastOptions?.path, '/courses/course-1');
  });

  test('maps backend 404 to CourseNotFoundException', () async {
    final adapter = CapturingHttpClientAdapter(
      jsonResponse({'message': 'Course not found'}, statusCode: 404),
    );
    final repository = HttpCoursesRepository(
      dio: Dio()..httpClientAdapter = adapter,
      getIdToken: () async => 'firebase-id-token',
    );

    await expectLater(
      repository.getCourse(courseId: 'unknown'),
      throwsA(isA<CourseNotFoundException>()),
    );
  });

  test('uploads a course PDF as multipart without subjectId', () async {
    final adapter = CapturingHttpClientAdapter(
      jsonResponse(sourceJsonWith(status: 'UPLOADED')),
    );
    final repository = HttpCoursesRepository(
      dio: Dio()..httpClientAdapter = adapter,
      getIdToken: () async => 'firebase-id-token',
    );

    final source = await repository.uploadCoursePdf(
      courseId: 'course-1',
      fileName: 'cours.pdf',
      bytes: Uint8List.fromList('%PDF-1.7'.codeUnits),
    );

    expect(source.status, CourseDocumentStatus.uploaded);
    expect(adapter.lastOptions?.method, 'POST');
    expect(adapter.lastOptions?.path, '/courses/course-1/source/course-pdf');
    expect(
      adapter.lastOptions?.headers['Authorization'],
      'Bearer firebase-id-token',
    );

    final formData = adapter.lastOptions?.data as FormData;
    expect(
      formData.fields.map((field) => field.key),
      isNot(contains('subjectId')),
    );
    expect(
      formData.fields.map((field) => field.key),
      isNot(contains('studentId')),
    );
    expect(formData.files.single.key, 'file');
    expect(formData.files.single.value.filename, 'cours.pdf');
  });

  test('maps upload 400 and 404 to typed course exceptions', () async {
    final badRequest = HttpCoursesRepository(
      dio: Dio()
        ..httpClientAdapter = CapturingHttpClientAdapter(
          jsonResponse({'message': 'Invalid file'}, statusCode: 400),
        ),
      getIdToken: () async => 'firebase-id-token',
    );

    await expectLater(
      badRequest.uploadCoursePdf(
        courseId: 'course-1',
        fileName: 'cours.txt',
        bytes: Uint8List.fromList([1, 2, 3]),
      ),
      throwsA(isA<CourseUploadException>()),
    );

    final notFound = HttpCoursesRepository(
      dio: Dio()
        ..httpClientAdapter = CapturingHttpClientAdapter(
          jsonResponse({'message': 'Course not found'}, statusCode: 404),
        ),
      getIdToken: () async => 'firebase-id-token',
    );

    await expectLater(
      notFound.uploadCoursePdf(
        courseId: 'missing',
        fileName: 'cours.pdf',
        bytes: Uint8List.fromList([1, 2, 3]),
      ),
      throwsA(isA<CourseNotFoundException>()),
    );
  });

  test(
    'loads a course-level revision sheet from the course endpoint',
    () async {
      final adapter = CapturingHttpClientAdapter(
        jsonResponse(revisionSheetJson()),
      );
      final repository = HttpCoursesRepository(
        dio: Dio()..httpClientAdapter = adapter,
        getIdToken: () async => 'firebase-id-token',
      );

      final sheet = await repository.getCourseRevisionSheet(
        courseId: 'course-1',
      );

      expect(sheet?.title, 'Fiche de cours');
      expect(sheet?.sections.single.title, 'Institutions');
      expect(adapter.lastOptions?.method, 'GET');
      expect(adapter.lastOptions?.path, '/courses/course-1/revision-sheet');
    },
  );

  test(
    'generates a course-level revision sheet without documentId payload',
    () async {
      final adapter = CapturingHttpClientAdapter(
        jsonResponse(revisionSheetJson()),
      );
      final repository = HttpCoursesRepository(
        dio: Dio()..httpClientAdapter = adapter,
        getIdToken: () async => 'firebase-id-token',
      );

      final sheet = await repository.generateCourseRevisionSheet(
        courseId: 'course-1',
      );

      expect(sheet.title, 'Fiche de cours');
      expect(adapter.lastOptions?.method, 'POST');
      expect(adapter.lastOptions?.path, '/courses/course-1/revision-sheet');
      expect(adapter.lastOptions?.data, isNull);
    },
  );

  test(
    'maps course-level revision sheet 404 and 409 to typed outcomes',
    () async {
      final notFoundRepository = HttpCoursesRepository(
        dio: Dio()
          ..httpClientAdapter = CapturingHttpClientAdapter(
            jsonResponse({
              'message': 'Revision sheet not found',
            }, statusCode: 404),
          ),
        getIdToken: () async => 'firebase-id-token',
      );

      await expectLater(
        notFoundRepository.getCourseRevisionSheet(courseId: 'course-1'),
        completion(isNull),
      );

      final notReadyRepository = HttpCoursesRepository(
        dio: Dio()
          ..httpClientAdapter = CapturingHttpClientAdapter(
            jsonResponse({
              'message': 'Course has no ready source',
            }, statusCode: 409),
          ),
        getIdToken: () async => 'firebase-id-token',
      );

      await expectLater(
        notReadyRepository.generateCourseRevisionSheet(courseId: 'course-1'),
        throwsA(isA<CourseRevisionSheetNotReadyException>()),
      );
    },
  );

  test('rejects unknown source status and invalid shapes', () async {
    final invalidStatus = sourceJson()..['status'] = 'ARCHIVED';
    final repository = HttpCoursesRepository(
      dio: Dio()
        ..httpClientAdapter = CapturingHttpClientAdapter(
          jsonResponse({
            'course': courseJson(),
            'subject': {'id': 'subject-1', 'name': 'Droit'},
            'sources': [invalidStatus],
          }),
        ),
      getIdToken: () async => 'firebase-id-token',
    );

    await expectLater(
      repository.getCourse(courseId: 'course-1'),
      throwsFormatException,
    );
  });
}

Map<String, Object?> courseJson({
  int sourceCount = 2,
  int readySourceCount = 1,
}) {
  return {
    'id': 'course-1',
    'subjectId': 'subject-1',
    'title': 'Droit constitutionnel',
    'description': 'Institutions',
    'chapterLabel': 'Chapitre 1',
    'estimatedMinutes': 30,
    'displayOrder': 0,
    'createdAt': '2026-06-18T10:00:00.000Z',
    'updatedAt': '2026-06-18T10:00:00.000Z',
    'sourceCount': sourceCount,
    'readySourceCount': readySourceCount,
    'processingSourceCount': 1,
    'failedSourceCount': 0,
  };
}

Map<String, Object?> sourceJson() {
  return sourceJsonWith(status: 'READY');
}

Map<String, Object?> sourceJsonWith({required String status}) {
  return {
    'id': 'document-1',
    'courseId': 'course-1',
    'documentId': 'document-1',
    'fileName': 'cours.pdf',
    'kind': 'COURSE_PDF',
    'status': status,
    'errorCode': null,
    'createdAt': '2026-06-18T10:00:00.000Z',
    'updatedAt': '2026-06-18T10:00:00.000Z',
  };
}

Map<String, Object?> revisionSheetJson() {
  return {
    'id': 'sheet-1',
    'documentId': 'document-1',
    'subjectId': 'subject-1',
    'status': 'READY',
    'title': 'Fiche de cours',
    'introduction': 'Introduction',
    'keyPoints': ['Point clé'],
    'commonMistakes': ['Erreur fréquente'],
    'mustKnow': ['À savoir'],
    'practiceSuggestions': ['S’entraîner'],
    'errorCode': null,
    'sections': [
      {
        'id': 'section-1',
        'displayOrder': 0,
        'title': 'Institutions',
        'content': 'Le Parlement contrôle le Gouvernement.',
        'sources': [
          {
            'chunkId': 'chunk-1',
            'text': 'Extrait source',
            'pageNumber': 1,
            'index': 0,
          },
        ],
      },
    ],
  };
}

ResponseBody jsonResponse(Object? body, {int statusCode = 200}) {
  return ResponseBody.fromString(
    jsonEncode(body),
    statusCode,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );
}

```

