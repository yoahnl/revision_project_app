# STAB-01B — Home, Revision Hub & Course action hierarchy

## Résumé

STAB-01B rend les trois entrées principales du MVP plus actionnables sans modifier le backend : l’accueil choisit une action honnête selon la matière et les cours, le hub Réviser peut lancer directement une révision rapide quand un cours est prêt, et le détail cours affiche une action recommandée claire selon l’état des sources.

## Audit initial

- `CoursesHomePage` utilisait la première entrée de liste comme hero et affichait encore un wording de reprise alors que l’app ne possède pas de reprise de session fiable dans ce lot.

- `RevisionsPendingPage` était visuellement agréable mais restait trop indirect : le chemin utile passait encore par le détail du cours au lieu de proposer une action quick directe.

- `CourseDetailPage` exposait plusieurs boutons de même poids et ne disait pas assez clairement quoi faire selon l’état réel des sources.

- `StartCourseQuickRevisionController` était couplé à `CourseDetail`, ce qui compliquait le lancement quick direct depuis le hub Réviser.

- Les textes utilisateur contenaient encore des traces trop techniques ou internes : `MVP+`, mentions de backend, et formulations autour du caractère “réel” qui sonnaient debug.

- Les tests couvraient l’accueil et le détail cours, mais pas encore le hub Réviser comme entrée actionnable autonome.

## Sub-agents / passes utilisées

- Home UX Agent : passe d’audit avec Averroes sur matière active, choix du cours mis en avant, états vides et fausses reprises.

- Course Action Agent : passe d’audit avec Lovelace sur la disponibilité quick/fiche/sources et les états READY/PROCESSING/FAILED/no source.

- Revision Hub Agent : passe locale sur `RevisionsPendingPage` pour rendre l’onglet Réviser directement utile.

- Wording Agent : remplacement des formulations techniques par des libellés utilisateur.

- QA Agent : tests ciblés Home/Hub/CourseDetail, suites app/router/courses/revision_sessions, full Flutter test et anti-fixtures.

- Reviewer Agent : vérification finale du périmètre App-only, des trackers et de l’absence de nouveau contrat API.

## Home : état avant/après

Avant, l’accueil utilisait un hero “Reprendre le cours” même sans donnée fiable de reprise. Après, l’accueil reste centré sur la matière active, choisit un cours prêt en priorité, propose `Réviser` seulement si une source READY existe, et bascule vers `Ouvrir` ou les CTA de création lorsque les données ne permettent pas de réviser.

États couverts : aucune matière, matière sans cours, cours sans source prête, cours avec source prête.

## Hub Réviser : état avant/après

Avant, le hub expliquait les modes mais laissait encore l’utilisateur repasser par un cours. Après, il affiche une action principale : `Commencer 5 questions` si un cours prêt existe, sinon une carte de préparation qui renvoie vers l’accueil ou le cours le plus pertinent. Deep et Examen restent visibles mais verrouillés avec `Bientôt disponible`, sans wording interne.

## Détail cours : état avant/après

Avant, les actions avaient un poids proche et l’utilisateur devait interpréter l’état des sources. Après, une carte `Action recommandée` arrive juste après le header : ajouter une source, voir les sources pendant l’analyse, corriger une source échouée, ou commencer une session rapide si le cours est prêt. Fiche et Sources restent des actions secondaires.

## Wording corrigé

- `Reprendre le cours` a été retiré du hero Home tant qu’aucune reprise réelle n’existe.

- `MVP+` a été remplacé par `Bientôt disponible`.

- Les mentions utilisateur de backend, fixture, payload et lots historiques ont été retirées des écrans modifiés.

- `Progression réelle` devient `Progression` côté détail cours ; le détail pédagogique reste porté par les valeurs et messages.

## Navigation quick

Un helper partagé `startCourseQuickRevisionFlow` centralise le loader bloquant, le démarrage quick, la navigation vers la session immersive et les messages d’erreur lisibles. Le hub Réviser démarre une session de 5 questions directement. Le détail cours conserve la bottom sheet de quantité pour laisser choisir 5/10/20/30.

## Tests ajoutés ou modifiés

- Ajout de `test/features/courses/revisions_pending_page_test.dart` pour couvrir le hub Réviser actionnable et le démarrage quick direct avec 5 questions.

- Adaptation de `test/app/revision_app_test.dart` pour les nouveaux libellés Home/Réviser et l’absence de fausse reprise.

- Adaptation de `test/app/router/app_router_test.dart` pour l’état vide Home.

- Adaptation de `test/features/courses/course_detail_page_test.dart` pour la carte d’action recommandée, les états sources et le wording.

## Commandes exécutées

```bash
flutter --version
flutter pub get
dart analyze lib test
flutter test test/app/router/app_router_test.dart --reporter compact
flutter test test/app/revision_app_test.dart --reporter compact
flutter test test/features/courses --reporter compact
flutter test test/features/revision_sessions --reporter compact
flutter test --reporter compact
git diff --check
rg -n "MVP\+|backend|payload|fixture|Reprendre le cours|Aucun cours réel|Aucune matière réelle|CORE-05 branchera|CORE-03 branchera" lib/features/courses/presentation/courses_home_page.dart lib/features/courses/presentation/revisions_pending_page.dart lib/features/courses/presentation/course_detail_page.dart test/app test/features/courses || true
rg -n "MvpStudyController\.instance|mvpSubjects|mvpSessionQuestions|courseOrFallback|Loi normale|78%|4/5 bonnes|870|7 jours|MVP\+" lib/app lib/features/courses lib/presentation/shell test/app test/features/courses || true
rg -n "CourseSource" lib/features/courses test/features/courses test/fakes test/app || true
```

## Résultats exacts

- `flutter --version` : exit 0, Flutter 3.44.0 stable, Dart 3.12.0.

- `flutter pub get` : exit 0, dépendances résolues ; 23 packages indiquent des versions plus récentes incompatibles, sans échec.

- `dart analyze lib test` : première passe exit 1 sur un import inutilisé dans le nouveau test, corrigé ; seconde passe exit 0, `No issues found!`.

- `flutter test test/app/router/app_router_test.dart --reporter compact` : exit 0, 20 tests passés.

- `flutter test test/app/revision_app_test.dart --reporter compact` : exit 0, 10 tests passés.

- `flutter test test/features/courses --reporter compact` : exit 0, 55 tests passés.

- `flutter test test/features/revision_sessions --reporter compact` : exit 0, 38 tests passés.

- `flutter test --reporter compact` : exit 0, 446 tests passés. Une trace `Document import failed` apparaît dans un test d’erreur attendu, mais la suite termine en vert.

- `git diff --check` : exit 0, aucune erreur de whitespace.

- Recherche anti-wording ciblée : uniquement des assertions négatives de tests et une dette Progrès hors scope STAB-01C (`Aucune matière réelle`). Aucun runtime Home/Hub/Détail modifié ne contient les termes interdits.

- Recherche anti-fixtures : uniquement des assertions négatives de tests.

- Recherche `CourseSource` : exit 0, aucune occurrence.

Note : des essais de tests Flutter lancés en parallèle pendant la phase rouge ont provoqué des erreurs natives macOS/iOS temporaires (`ephemeral` / `native_assets`). Les validations finales ont été relancées séquentiellement et passent.

## Limitations

- Le hub Réviser lance 5 questions par défaut. Le choix détaillé du nombre reste dans le détail cours, pour éviter d’alourdir ce lot.

- La page Progrès garde certains libellés hérités et sera traitée en STAB-01C.

- Il n’y a toujours pas de vraie reprise de session ; le wording évite donc de promettre une reprise.

## Dette restante pour STAB-01C

- Revoir le wording de Progrès, notamment `Aucune matière réelle`.

- Clarifier fiche/progrès/subject discoverability.

- Réduire les derniers termes “réel” côté UI utilisateur lorsque le contexte n’en a plus besoin.

## Fichiers créés/modifiés/supprimés

### Créés

- `docs/ui/STAB_01B_HOME_REVISION_HUB_COURSE_ACTIONS_REPORT.md`

- `lib/features/courses/presentation/course_quick_revision_launcher.dart`

- `test/features/courses/revisions_pending_page_test.dart`

### Modifiés

- `docs/roadmap/v2/EXECUTION_LOT_TRACKER_V2.md`

- `docs/roadmap/v2/LOT_TRACKER_V2.md`

- `lib/features/courses/application/courses_providers.dart`

- `lib/features/courses/presentation/course_detail_page.dart`

- `lib/features/courses/presentation/courses_home_page.dart`

- `lib/features/courses/presentation/revisions_pending_page.dart`

- `lib/presentation/design_system/components/revision_mvp_components.dart`

- `test/app/revision_app_test.dart`

- `test/app/router/app_router_test.dart`

- `test/features/courses/course_detail_page_test.dart`

### Supprimés

- Aucun.

## Auto-review

- Roadmap V2 et rapport STAB-01A relus.

- Home audité et rendu actionnable selon les états réels.

- Hub Réviser audité et rendu actionnable avec quick direct.

- Détail cours audité et doté d’une action principale claire.

- Quick reste disponible ; Deep/Exam restent verrouillés.

- Aucune donnée fictive ajoutée.

- Aucun backend modifié.

- Trackers mis à jour.

- Tests ciblés et full Flutter test passés.

- Aucun commit effectué.

## Confirmation backend

Aucun fichier backend et aucun contrat API n’ont été modifiés.

## Confirmation Git

Aucun commit, amend, merge, rebase, push ou tag n’a été effectué.

## Contenu complet des fichiers créés/modifiés

### `docs/roadmap/v2/EXECUTION_LOT_TRACKER_V2.md`

````````md

# Execution Lot Tracker V2

Ce tracker suit les lots réellement exécutables. Les macro-lots restent suivis dans `LOT_TRACKER_V2.md`.

Statuts autorisés : `TODO`, `IN_PROGRESS`, `DONE`, `BLOCKED`, `DEFERRED`, `REPLACED`.

Horizons autorisés : `FOUNDATION`, `MVP_STABLE`, `MVP_PLUS`, `POST_MVP`, `RELEASE`.

| Lot | Parent macro-lot | Horizon | Repo(s) | Statut | Dépend de | Travaux parallélisables | Objectif | Validation | Rapport |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| STAB-00B | STAB-00 | FOUNDATION | App + API | DONE | STAB-00 | Aucun | Durcir la roadmap V2 et créer les lots exécutables. | Docs, trackers et protocole synchronisés. | `docs/roadmap/v2/STAB_00B_ROADMAP_V2_HARDENING_REPORT.md` |
| QUALITY-00 | QUALITY-00 | FOUNDATION | App + API | DONE | STAB-00B | STAB-01A | Installer une baseline CI reproductible. | Flutter analyze/tests côté app ; Prisma/build/lint/tests/e2e côté API. | `docs/roadmap/v2/QUALITY_00_CI_BASELINE_REPORT.md` |
| STAB-01A | STAB-01 | MVP_STABLE | App | DONE | STAB-00B | QUALITY-00 | Corriger shell, navigation, scaffold et scrolls globaux. | Bottom nav 4 onglets, routes session immersives, routes legacy conservées, scaffolds top-aligned. | `docs/ui/STAB_01A_SHELL_NAVIGATION_SCAFFOLD_REPORT.md` |
| STAB-01B | STAB-01 | MVP_STABLE | App | DONE | STAB-01A | CORE-09A | Clarifier Home, Hub Révisions et hiérarchie des actions cours. | Home, hub Réviser et détail cours ont une action principale honnête, sans impasse ni wording technique. | `docs/ui/STAB_01B_HOME_REVISION_HUB_COURSE_ACTIONS_REPORT.md` |
| STAB-01C | STAB-01 | MVP_STABLE | App + API si besoin | TODO | STAB-01B | Aucun | Corriger fiche, progrès, wording et découvrabilité des matières. | Capacités non disponibles masquées ou reliées à un lot API. | À créer |
| STAB-02A | STAB-02 | MVP_STABLE | App | TODO | STAB-01C | CORE-10A si CORE-09A fait | Migrer Auth, Onboarding, Profil et Matières vers le design premium. | Une seule direction visuelle, sans faux état produit. | À créer |
| STAB-02B | STAB-02 | MVP_STABLE | App | TODO | STAB-02A | Aucun | Extraire les widgets feature, isoler ou déprécier le legacy. | `features/*/presentation` vidé progressivement selon la règle d'architecture. | À créer |
| CORE-09A | CORE-09 | MVP_STABLE | App + API | TODO | STAB-01A | STAB-01B | Définir archive/delete des sources. | Une source utilisée n'est plus supprimée naïvement. | À créer |
| CORE-09B | CORE-09 | MVP_STABLE | API | TODO | CORE-09A | CORE-09C | Durcir cleanup blob et abstraction storage. | Politique local/cloud documentée et testée. | À créer |
| CORE-09C | CORE-09 | MVP_STABLE | App + API | TODO | CORE-09A | CORE-09B | Ajouter les APIs de lifecycle sujet/cours nécessaires à l'UX. | Renommer/archiver devient disponible seulement si API réelle. | À créer |
| CORE-10A | CORE-10 | MVP_STABLE | App + API | TODO | CORE-09A | STAB-02A | Préparer la question bank en asynchrone. | Plus de génération longue bloquante au démarrage quick. | À créer |
| CORE-10B | CORE-10 | MVP_STABLE | API | TODO | CORE-10A | CORE-11A | Sélection multi-KU et verrouillage concurrence. | Répartition robuste, pas de double réservation évidente. | À créer |
| CORE-10C | CORE-10 | MVP_STABLE | API | TODO | CORE-10B | ADAPT-01 | Découpler QuestionBankService et ajouter métriques qualité/coût. | Service testable, métriques exploitables. | À créer |
| CORE-11A | CORE-11 | MVP_STABLE | App + API | TODO | CORE-10A | CORE-10B, PLUS-01A | Sauvegarder brouillons de session et reprise. | Une session en cours peut être reprise après fermeture. | À créer |
| CORE-11B | CORE-11 | MVP_STABLE | App + API | TODO | CORE-11A | Aucun | Historique de sessions et détail des sessions terminées. | Historique utilisable sans rouvrir un quiz terminé. | À créer |
| PLUS-01A | PLUS-01 | MVP_PLUS | App + API | TODO | STAB-02A, CORE-10A, quick lifecycle stable | CORE-11A | Deep Revision course-level avec question ouverte V1. | Action open-question réelle, correction IA, pas de résultat deep complet si hors lot. | À créer |
| PLUS-01B | PLUS-01 | MVP_PLUS | App + API | TODO | PLUS-01A, CORE-11A | Aucun | Lifecycle, completion et résultat Deep. | Deep dispose d'un résultat cohérent et testable. | À créer |
| PLUS-02 | PLUS-02 | MVP_PLUS | App + API | TODO | STAB-02B, CORE-09A | PLUS-01A | Fiches complète et pré-examen réelles. | Les faux onglets ne mentent plus. | À créer |
| ADAPT-01 | ADAPT-01 | MVP_PLUS | App + API | TODO | CORE-10B | CORE-10C | Page Today et coach adaptatif. | Recommandation honnête basée sur données réelles. | À créer |
| PLUS-03 | PLUS-03 | POST_MVP | App + API | TODO | PLUS-01B, PLUS-02, CORE-11B | Aucun | Préparation examen V1. | Mode examen distinct, résultat distinct, sources adaptées. | À créer |
| GENUI-01 | GENUI-01 | POST_MVP | App + API | TODO | STAB-02B, ADAPT-01, PLUS-01A | Aucun | Surface GenUI contrôlée par catalogue. | Payloads validés, fallback sûr, aucun UI arbitraire. | À créer |
| RELEASE-01 | RELEASE-01 | RELEASE | App + API | TODO | QUALITY-00, lots MVP_STABLE requis | Aucun | Préparation production complète. | CI, stockage, secrets, monitoring, accessibilité et conformité prêts. | À créer |

````````

### `docs/roadmap/v2/LOT_TRACKER_V2.md`

````````md

# Lot Tracker V2

Ce tracker suit les macro-lots stratégiques. Le détail exécutable vit dans `EXECUTION_LOT_TRACKER_V2.md`.

Statuts autorisés : `TODO`, `IN_PROGRESS`, `DONE`, `BLOCKED`, `DEFERRED`, `REPLACED`.

Horizons autorisés : `FOUNDATION`, `MVP_STABLE`, `MVP_PLUS`, `POST_MVP`, `RELEASE`.

| Lot | Titre | Horizon | Repo(s) | Statut | Dépend de | Lots exécutables | Objectif | Validation | Rapport |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| STAB-00 | Roadmap V2 canonicalisation | FOUNDATION | App + API | DONE | Aucun | STAB-00B | Créer la source de vérité V2 et le protocole de mise à jour. | Documents V2 créés dans les deux repos. | `docs/roadmap/v2/` |
| STAB-00B | Roadmap V2 hardening, execution slicing & governance | FOUNDATION | App + API | DONE | STAB-00 | STAB-00B | Durcir la roadmap, ajouter horizons, lots exécutables et gouvernance. | Trackers, plans, décisions et protocoles synchronisés. | `docs/roadmap/v2/STAB_00B_ROADMAP_V2_HARDENING_REPORT.md` |
| QUALITY-00 | CI baseline | FOUNDATION | App + API | DONE | STAB-00B | QUALITY-00 | Ajouter une baseline CI avant les gros refactors. | Analyse, tests ciblés et full Flutter test côté app ; Prisma, build, lint, unit et e2e côté API. | `docs/roadmap/v2/QUALITY_00_CI_BASELINE_REPORT.md` |
| STAB-01 | Product navigation & UX coherence | MVP_STABLE | App | IN_PROGRESS | STAB-00B | STAB-01A, STAB-01B, STAB-01C | Corriger navigation, faux affordances et parcours confus. | Tests router/widget + smoke visuel. | `docs/ui/STAB_01A_SHELL_NAVIGATION_SCAFFOLD_REPORT.md`, `docs/ui/STAB_01B_HOME_REVISION_HUB_COURSE_ACTIONS_REPORT.md` |
| STAB-02 | Frontend design system unification | MVP_STABLE | App | TODO | STAB-01C | STAB-02A, STAB-02B | Unifier les écrans legacy et premium. | Tests UI ciblés + anti-régression. | À créer |
| CORE-09 | Source lifecycle & storage policy | MVP_STABLE | API + App | TODO | STAB-01A | CORE-09A, CORE-09B, CORE-09C | Sécuriser archive/suppression de sources et stockage. | Tests Prisma + API + UI. | À créer |
| CORE-10 | Question bank production hardening | MVP_STABLE | API + App | TODO | CORE-09A | CORE-10A, CORE-10B, CORE-10C | Rendre la banque de questions robuste et moins synchrone. | Tests génération, sélection, concurrence. | À créer |
| CORE-11 | Session resume & history | MVP_STABLE | API + App | TODO | CORE-10A | CORE-11A, CORE-11B | Reprise de session et historique utilisateur. | Tests lifecycle + navigation. | À créer |
| PLUS-01 | Deep Revision course-level | MVP_PLUS | API + App | TODO | STAB-02A, CORE-10A | PLUS-01A, PLUS-01B | Activer la révision approfondie réelle. | Tests open question + correction IA. | À créer |
| PLUS-02 | Revision sheet complete / exam modes | MVP_PLUS | API + App | TODO | STAB-02B, CORE-09A | PLUS-02 | Remplacer les faux onglets fiche par de vrais contenus. | Tests fiche complète/examen. | À créer |
| ADAPT-01 | Today / adaptive coach | MVP_PLUS | API + App | TODO | CORE-10B | ADAPT-01 | Guider l'utilisateur vers la prochaine action utile. | Tests recommandation + UI Today. | À créer |
| PLUS-03 | Exam preparation V1 | POST_MVP | API + App | TODO | PLUS-01B, PLUS-02, CORE-11B | PLUS-03 | Créer un vrai mode préparation examen. | Tests session exam + résultat. | À créer |
| GENUI-01 | Controlled GenUI surface | POST_MVP | API + App | TODO | STAB-02B, ADAPT-01, PLUS-01A | GENUI-01 | Réintroduire GenUI avec widgets strictement contrôlés. | Validation payload + fallback. | À créer |
| RELEASE-01 | Production readiness | RELEASE | API + App + Infra | TODO | QUALITY-00, lots MVP_STABLE requis | RELEASE-01 | Préparer CI complète, monitoring, stockage et exploitation. | Checklist release complète. | À créer |

````````

### `lib/features/courses/application/courses_providers.dart`

````````dart

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/di/providers.dart';
import '../../documents/domain/revision_document.dart';
import '../../revision_sessions/domain/revision_session.dart';
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

final courseProgressProvider = FutureProvider.family<CourseProgress, String>((
  ref,
  courseId,
) {
  return ref
      .read(coursesRepositoryProvider)
      .getCourseProgress(courseId: courseId);
});

final subjectProgressProvider = FutureProvider.family<SubjectProgress, String>((
  ref,
  subjectId,
) {
  return ref
      .read(coursesRepositoryProvider)
      .getSubjectProgress(subjectId: subjectId);
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

final deleteCourseDocumentControllerProvider =
    NotifierProvider<DeleteCourseDocumentController, AsyncValue<void>>(
      DeleteCourseDocumentController.new,
    );

final generateCourseRevisionSheetControllerProvider =
    NotifierProvider<
      GenerateCourseRevisionSheetController,
      AsyncValue<RevisionSheet?>
    >(GenerateCourseRevisionSheetController.new);

final startCourseQuickRevisionControllerProvider =
    NotifierProvider<
      StartCourseQuickRevisionController,
      AsyncValue<RevisionSessionResponse?>
    >(StartCourseQuickRevisionController.new);

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
    ref.invalidate(courseProgressProvider(detail.course.id));
    ref.invalidate(coursesProvider(detail.course.subjectId));
    ref.invalidate(subjectProgressProvider(detail.course.subjectId));

    return uploaded;
  }
}

class DeleteCourseDocumentController extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<void> delete({
    required CourseDetail detail,
    required String documentId,
  }) async {
    state = const AsyncLoading();
    final repository = ref.read(coursesRepositoryProvider);
    final result = await AsyncValue.guard(
      () => repository.deleteCourseDocument(
        courseId: detail.course.id,
        documentId: documentId,
      ),
    );

    state = result;

    if (result.hasError) {
      Error.throwWithStackTrace(result.error!, result.stackTrace!);
    }

    ref.invalidate(courseDetailProvider(detail.course.id));
    ref.invalidate(courseProgressProvider(detail.course.id));
    ref.invalidate(coursesProvider(detail.course.subjectId));
    ref.invalidate(subjectProgressProvider(detail.course.subjectId));
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

class StartCourseQuickRevisionController
    extends Notifier<AsyncValue<RevisionSessionResponse?>> {
  @override
  AsyncValue<RevisionSessionResponse?> build() => const AsyncData(null);

  Future<RevisionSessionResponse> start({
    CourseDetail? detail,
    String? courseId,
    int questionCount = 10,
  }) async {
    final resolvedCourseId = courseId ?? detail?.course.id;
    if (resolvedCourseId == null) {
      throw ArgumentError('A course id is required to start quick revision');
    }

    state = const AsyncLoading();
    final repository = ref.read(coursesRepositoryProvider);
    final result = await AsyncValue.guard(
      () => repository.startCourseQuickRevision(
        courseId: resolvedCourseId,
        questionCount: questionCount,
      ),
    );

    state = result.whenData<RevisionSessionResponse?>((response) => response);

    if (result.hasError) {
      Error.throwWithStackTrace(result.error!, result.stackTrace!);
    }

    return result.requireValue;
  }
}

````````

### `lib/features/courses/presentation/course_detail_page.dart`

````````dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_routes.dart';
import '../../../presentation/design_system/components/revision_mvp_components.dart';
import '../../../presentation/design_system/components/revision_states.dart';
import '../../../presentation/design_system/tokens/revision_colors.dart';
import '../../../presentation/design_system/tokens/revision_radius.dart';
import '../../../presentation/design_system/tokens/revision_spacing.dart';
import '../../../presentation/design_system/tokens/revision_subject_visuals.dart';
import '../../../presentation/design_system/tokens/revision_typography.dart';
import '../application/courses_providers.dart';
import '../domain/course_models.dart';
import '../domain/courses_repository.dart';
import 'course_not_found_page.dart';
import 'course_quick_revision_launcher.dart';

class CourseDetailPage extends ConsumerWidget {
  const CourseDetailPage({required this.courseId, super.key});

  final String courseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(courseDetailProvider(courseId));

    return detail.when(
      loading: () => const RevisionPageScaffold(
        children: [RevisionLoadingState(label: 'Chargement du cours')],
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
                  'Réessaie ou retourne à l’accueil pour choisir un autre cours.',
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
    final visual = revisionSubjectVisualThemeFor(
      '${detail.subject.name} ${course.title}',
    );
    final progress = ref.watch(courseProgressProvider(course.id));
    final hasReadySource = detail.sources.any(
      (source) => source.status == CourseDocumentStatus.ready,
    );

    return RevisionPageScaffold(
      headerChildren: [
        _CourseTopBar(
          detail: detail,
          visual: visual,
          hasReadySource: hasReadySource,
        ),
        _CourseHero(detail: detail, visual: visual),
      ],
      children: [
        _CoursePrimaryAction(detail: detail, visual: visual),
        _StatsStrip(course: course, progress: progress, visual: visual),
        _CourseProgressSection(
          progress: progress,
          onRetry: () => ref.invalidate(courseProgressProvider(course.id)),
        ),
        _CourseModes(detail: detail, visual: visual),
        if (_pollTimedOut)
          RevisionGlassCard(
            child: Text(
              'Le traitement continue en arrière-plan. Tu peux revenir plus tard.',
              style: RevisionTypography.body,
            ),
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
      ref.invalidate(courseProgressProvider(widget.detail.course.id));
      ref.invalidate(subjectProgressProvider(widget.detail.course.subjectId));
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

class _CourseTopBar extends ConsumerWidget {
  const _CourseTopBar({
    required this.detail,
    required this.visual,
    required this.hasReadySource,
  });

  final CourseDetail detail;
  final RevisionSubjectVisualTheme visual;
  final bool hasReadySource;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        IconButton(
          tooltip: 'Retour',
          onPressed: () => _popOrGo(context, AppRoutes.home),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        const Spacer(),
        RevisionHeaderActionPill(
          label: 'Fiche',
          icon: Icons.article_outlined,
          accent: visual.accent,
          selected: hasReadySource,
          onTap: hasReadySource
              ? () => context.push(AppRoutes.courseSheet(detail.course.id))
              : null,
        ),
        const SizedBox(width: RevisionSpacing.s),
        RevisionHeaderActionPill(
          label: 'Sources',
          icon: Icons.description_outlined,
          accent: visual.accent,
          onTap: () => _showSourcesSheet(context, ref, detail),
        ),
      ],
    );
  }
}

class _CourseHero extends StatelessWidget {
  const _CourseHero({required this.detail, required this.visual});

  final CourseDetail detail;
  final RevisionSubjectVisualTheme visual;

  @override
  Widget build(BuildContext context) {
    final course = detail.course;

    return RevisionGlassCard(
      padding: const EdgeInsets.all(RevisionSpacing.l),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          visual.accent.withValues(alpha: 0.30),
          RevisionColors.glassStrong,
        ],
      ),
      borderColor: visual.accent.withValues(alpha: 0.36),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RevisionIconTile(icon: visual.icon, accent: visual.accent, size: 64),
          const SizedBox(width: RevisionSpacing.l),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  detail.subject.name,
                  style: RevisionTypography.caption.copyWith(
                    color: visual.accent,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: RevisionSpacing.xs),
                Text(course.title, style: RevisionTypography.pageTitle),
                const SizedBox(height: RevisionSpacing.xs),
                Text(_courseMeta(course), style: RevisionTypography.body),
                if (course.description != null) ...[
                  const SizedBox(height: RevisionSpacing.m),
                  Text(course.description!, style: RevisionTypography.body),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CoursePrimaryAction extends ConsumerWidget {
  const _CoursePrimaryAction({required this.detail, required this.visual});

  final CourseDetail detail;
  final RevisionSubjectVisualTheme visual;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final action = _primaryActionFor(detail.sources);

    return RevisionGlassCard(
      borderColor: action.accent.withValues(alpha: 0.34),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          action.accent.withValues(alpha: 0.20),
          RevisionColors.glassStrong,
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RevisionIconTile(icon: action.icon, accent: action.accent, size: 48),
          const SizedBox(width: RevisionSpacing.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Action recommandée',
                  style: RevisionTypography.caption.copyWith(
                    color: visual.accent,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: RevisionSpacing.xs),
                Text(action.title, style: RevisionTypography.sectionTitle),
                const SizedBox(height: RevisionSpacing.xs),
                Text(action.message, style: RevisionTypography.body),
                const SizedBox(height: RevisionSpacing.m),
                RevisionGradientButton(
                  label: action.buttonLabel,
                  icon: action.buttonIcon,
                  onPressed: () => action.run(context, ref, detail),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PrimaryCourseAction {
  const _PrimaryCourseAction({
    required this.title,
    required this.message,
    required this.buttonLabel,
    required this.icon,
    required this.buttonIcon,
    required this.accent,
    required this.run,
  });

  final String title;
  final String message;
  final String buttonLabel;
  final IconData icon;
  final IconData buttonIcon;
  final Color accent;
  final void Function(BuildContext context, WidgetRef ref, CourseDetail detail)
  run;
}

_PrimaryCourseAction _primaryActionFor(List<CourseDocument> sources) {
  if (sources.any((source) => source.status == CourseDocumentStatus.ready)) {
    return _PrimaryCourseAction(
      title: 'Réviser maintenant',
      message: 'Une source est prête pour lancer des questions rapides.',
      buttonLabel: 'Commencer une session rapide',
      icon: Icons.flash_on_rounded,
      buttonIcon: Icons.play_arrow_rounded,
      accent: RevisionColors.blue,
      run: (context, ref, detail) =>
          _showQuickRevisionSheet(context, ref, detail),
    );
  }

  if (sources.any(_isPendingSource)) {
    return _PrimaryCourseAction(
      title: 'Source en analyse',
      message: 'La révision sera disponible quand le PDF sera prêt.',
      buttonLabel: 'Voir les sources',
      icon: Icons.hourglass_top_rounded,
      buttonIcon: Icons.description_outlined,
      accent: RevisionColors.amber,
      run: (context, ref, detail) => _showSourcesSheet(context, ref, detail),
    );
  }

  if (sources.isNotEmpty &&
      sources.every((source) => source.status == CourseDocumentStatus.failed)) {
    return _PrimaryCourseAction(
      title: 'Source à corriger',
      message:
          'Ouvre les sources pour remplacer ou supprimer le PDF en erreur.',
      buttonLabel: 'Voir les sources',
      icon: Icons.error_outline_rounded,
      buttonIcon: Icons.description_outlined,
      accent: RevisionColors.red,
      run: (context, ref, detail) => _showSourcesSheet(context, ref, detail),
    );
  }

  return _PrimaryCourseAction(
    title: 'Ajoute une source',
    message: 'Ajoute un PDF pour préparer la fiche et les révisions.',
    buttonLabel: 'Ajouter une source',
    icon: Icons.upload_file_rounded,
    buttonIcon: Icons.add_rounded,
    accent: RevisionColors.blue,
    run: (context, ref, detail) => _showSourcesSheet(context, ref, detail),
  );
}

class _StatsStrip extends StatelessWidget {
  const _StatsStrip({
    required this.course,
    required this.progress,
    required this.visual,
  });

  final CourseListItem course;
  final AsyncValue<CourseProgress> progress;
  final RevisionSubjectVisualTheme visual;

  @override
  Widget build(BuildContext context) {
    final progressValue = progress.maybeWhen(
      data: (progress) => _percent(progress.estimatedGlobalMastery),
      orElse: () => 'En attente',
    );

    return RevisionStatTriplet(
      items: [
        RevisionStatItem(
          icon: Icons.track_changes_rounded,
          label: 'Progression',
          value: progressValue,
          color: visual.accent,
        ),
        RevisionStatItem(
          icon: Icons.schedule_rounded,
          label: 'Temps estimé',
          value: course.estimatedMinutes == null
              ? 'À préciser'
              : '${course.estimatedMinutes} min',
          color: RevisionColors.textMuted,
        ),
        RevisionStatItem(
          icon: Icons.star_border_rounded,
          label: 'Difficulté',
          value: _difficultyLabel(course.difficulty),
          color: RevisionColors.amber,
        ),
      ],
    );
  }
}

class _CourseProgressSection extends StatelessWidget {
  const _CourseProgressSection({required this.progress, required this.onRetry});

  final AsyncValue<CourseProgress> progress;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return progress.when(
      loading: () =>
          const RevisionLoadingState(label: 'Chargement de la progression'),
      error: (error, stackTrace) => RevisionErrorState(
        title: 'Progression indisponible',
        message: 'Les métriques ne sont pas disponibles pour ce cours.',
        actionLabel: 'Réessayer',
        onAction: onRetry,
      ),
      data: (progress) => RevisionGlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Progression', style: RevisionTypography.sectionTitle),
            const SizedBox(height: RevisionSpacing.m),
            Row(
              children: [
                RevisionMasteryRing(
                  value: progress.estimatedGlobalMastery,
                  label: _percent(progress.estimatedGlobalMastery),
                  caption: 'global',
                  color: _progressColor(progress.state),
                  size: 92,
                ),
                const SizedBox(width: RevisionSpacing.l),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${progress.practicedKnowledgeUnitCount}/${progress.knowledgeUnitCount} notions travaillées',
                        style: RevisionTypography.sectionTitle.copyWith(
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: RevisionSpacing.s),
                      RevisionProgressLine(
                        value: progress.coverage,
                        color: _progressColor(progress.state),
                        height: 8,
                      ),
                      const SizedBox(height: RevisionSpacing.s),
                      Text(
                        _masteryLabel(progress),
                        style: RevisionTypography.caption,
                      ),
                      const SizedBox(height: RevisionSpacing.xs),
                      Text(
                        'Estimation globale : ${_percent(progress.estimatedGlobalMastery)}',
                        style: RevisionTypography.caption,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: RevisionSpacing.m),
            Text(
              _progressStateLabel(progress.state),
              style: RevisionTypography.body,
            ),
          ],
        ),
      ),
    );
  }
}

class _CourseModes extends ConsumerWidget {
  const _CourseModes({required this.detail, required this.visual});

  final CourseDetail detail;
  final RevisionSubjectVisualTheme visual;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quickRevisionState = ref.watch(
      startCourseQuickRevisionControllerProvider,
    );
    final isStartingQuickRevision = quickRevisionState.isLoading;
    final hasReadySource = detail.sources.any(
      (source) => source.status == CourseDocumentStatus.ready,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Modes de révision', style: RevisionTypography.sectionTitle),
        const SizedBox(height: RevisionSpacing.m),
        RevisionModeCard(
          title: isStartingQuickRevision ? 'Démarrage...' : 'Révision rapide',
          description: _quickRevisionActionLabel(detail.sources),
          icon: Icons.flash_on_rounded,
          accent: RevisionColors.blue,
          trailingLabel: hasReadySource
              ? null
              : _quickRevisionBlockedLabel(detail.sources),
          enabled: hasReadySource && !isStartingQuickRevision,
          onTap: () => _showQuickRevisionSheet(context, ref, detail),
        ),
        const SizedBox(height: RevisionSpacing.m),
        RevisionModeCard(
          title: 'Révision approfondie',
          description: 'Cours complet et exemples détaillés.',
          icon: Icons.menu_book_rounded,
          accent: RevisionColors.violet,
          trailingLabel: 'Bientôt disponible',
          enabled: false,
        ),
        const SizedBox(height: RevisionSpacing.m),
        RevisionModeCard(
          title: 'Préparation examen',
          description: 'Entraînements et sujets corrigés.',
          icon: Icons.gps_fixed_rounded,
          accent: RevisionColors.pink,
          trailingLabel: 'Bientôt disponible',
          enabled: false,
        ),
        if (quickRevisionState.hasError) ...[
          const SizedBox(height: RevisionSpacing.s),
          Text(
            'Les questions sont en préparation. Réessaie dans un instant.',
            style: RevisionTypography.caption.copyWith(
              color: RevisionColors.red,
            ),
          ),
        ],
      ],
    );
  }
}

Future<void> _showQuickRevisionSheet(
  BuildContext context,
  WidgetRef ref,
  CourseDetail detail,
) async {
  final questionCount = await showModalBottomSheet<int>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (context) => const _QuickRevisionQuestionCountSheet(),
  );

  if (!context.mounted || questionCount == null) {
    return;
  }

  await startCourseQuickRevisionFlow(
    context: context,
    ref: ref,
    courseId: detail.course.id,
    questionCount: questionCount,
  );
}

void _showSourcesSheet(
  BuildContext context,
  WidgetRef ref,
  CourseDetail detail,
) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _SourcesBottomSheet(detail: detail),
  );
}

class _QuickRevisionQuestionCountSheet extends StatefulWidget {
  const _QuickRevisionQuestionCountSheet();

  @override
  State<_QuickRevisionQuestionCountSheet> createState() =>
      _QuickRevisionQuestionCountSheetState();
}

class _QuickRevisionQuestionCountSheetState
    extends State<_QuickRevisionQuestionCountSheet> {
  static const _choices = [5, 10, 20, 30];

  int _selectedQuestionCount = 10;

  @override
  Widget build(BuildContext context) {
    return RevisionBottomSheetFrame(
      title: 'Révision rapide',
      subtitle: 'Choisis le nombre de questions pour cette session.',
      children: [
        Wrap(
          spacing: RevisionSpacing.s,
          runSpacing: RevisionSpacing.s,
          children: [
            for (final choice in _choices)
              _QuestionCountChip(
                count: choice,
                selected: choice == _selectedQuestionCount,
                onTap: () => setState(() {
                  _selectedQuestionCount = choice;
                }),
              ),
          ],
        ),
        const SizedBox(height: RevisionSpacing.l),
        RevisionGradientButton(
          label: 'Démarrer',
          icon: Icons.play_arrow_rounded,
          expanded: true,
          onPressed: () => Navigator.of(context).pop(_selectedQuestionCount),
        ),
        const SizedBox(height: RevisionSpacing.s),
        Text(
          'Les questions viennent de la banque du cours. Si elle en manque, le service en prépare par petits lots.',
          style: RevisionTypography.caption,
        ),
      ],
    );
  }
}

class _QuestionCountChip extends StatelessWidget {
  const _QuestionCountChip({
    required this.count,
    required this.selected,
    required this.onTap,
  });

  final int count;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: RevisionRadius.pill,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(
          horizontal: RevisionSpacing.l,
          vertical: RevisionSpacing.s,
        ),
        decoration: BoxDecoration(
          gradient: selected
              ? const LinearGradient(
                  colors: [RevisionColors.blue, RevisionColors.blueDeep],
                )
              : null,
          color: selected ? null : RevisionColors.glassSoft,
          borderRadius: RevisionRadius.pill,
          border: Border.all(
            color: selected ? RevisionColors.blue : RevisionColors.border,
          ),
        ),
        child: Text(
          '$count questions',
          style: RevisionTypography.body.copyWith(
            color: selected ? RevisionColors.text : RevisionColors.textMuted,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _SourcesBottomSheet extends ConsumerWidget {
  const _SourcesBottomSheet({required this.detail});

  final CourseDetail detail;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uploadState = ref.watch(uploadCourseDocumentControllerProvider);
    final deleteState = ref.watch(deleteCourseDocumentControllerProvider);
    final isUploading = uploadState.isLoading;
    final isDeleting = deleteState.isLoading;
    final sources = detail.sources;

    return RevisionBottomSheetFrame(
      title: 'Sources',
      subtitle: detail.course.title,
      floatingAction: RevisionFloatingAddButton(
        onTap: isUploading ? () {} : () => _uploadSource(context, ref),
      ),
      children: [
        if (sources.isEmpty)
          RevisionEmptyState(
            title: 'Aucune source attachée',
            message:
                'Ajoute un PDF pour lancer le traitement documentaire de ce cours.',
            icon: Icons.source_outlined,
          )
        else
          for (final source in sources)
            RevisionSourceFileCard(
              fileName: source.fileName,
              statusLabel:
                  source.status == CourseDocumentStatus.failed &&
                      source.errorCode != null
                  ? '${_statusLabel(source.status)} · Code erreur : ${source.errorCode}'
                  : _statusLabel(source.status),
              statusColor: _statusColor(source.status),
              trailing: IconButton(
                tooltip: 'Supprimer la source ${source.fileName}',
                onPressed: isDeleting
                    ? null
                    : () => _deleteSource(context, ref, source),
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  color: RevisionColors.textMuted,
                ),
              ),
            ),
        if (isUploading)
          const RevisionProcessingState(
            title: 'Upload en cours...',
            message: 'La source est envoyée pour analyse.',
          ),
        if (uploadState.hasError)
          Text(
            'Upload impossible pour le moment.',
            style: RevisionTypography.caption.copyWith(
              color: RevisionColors.red,
            ),
          ),
        if (deleteState.hasError)
          Text(
            'Impossible de supprimer cette source.',
            style: RevisionTypography.caption.copyWith(
              color: RevisionColors.red,
            ),
          ),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: () {
              ref.invalidate(courseDetailProvider(detail.course.id));
              ref.invalidate(courseProgressProvider(detail.course.id));
              ref.invalidate(subjectProgressProvider(detail.course.subjectId));
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Rafraîchir'),
          ),
        ),
      ],
    );
  }

  Future<void> _uploadSource(BuildContext context, WidgetRef ref) async {
    try {
      final uploaded = await ref
          .read(uploadCourseDocumentControllerProvider.notifier)
          .upload(detail: detail);

      if (!context.mounted || uploaded == null) {
        return;
      }

      Navigator.of(context).pop();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Source ajoutée')));
    } catch (_) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Impossible d’ajouter cette source PDF.')),
      );
    }
  }

  Future<void> _deleteSource(
    BuildContext context,
    WidgetRef ref,
    CourseDocument source,
  ) async {
    final confirmed = await _confirmDeleteSource(context, source.fileName);
    if (!confirmed || !context.mounted) {
      return;
    }

    try {
      await ref
          .read(deleteCourseDocumentControllerProvider.notifier)
          .delete(detail: detail, documentId: source.documentId);

      if (!context.mounted) {
        return;
      }

      Navigator.of(context).pop();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Source supprimée')));
    } catch (_) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Impossible de supprimer cette source.')),
      );
    }
  }
}

Future<bool> _confirmDeleteSource(BuildContext context, String fileName) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Supprimer cette source ?'),
      content: Text(
        'Le PDF "$fileName" sera retiré de ce cours. Tu pourras le rajouter plus tard si besoin.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Annuler'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Supprimer'),
        ),
      ],
    ),
  );

  return confirmed ?? false;
}

String _quickRevisionActionLabel(List<CourseDocument> sources) {
  if (sources.any((source) => source.status == CourseDocumentStatus.ready)) {
    return 'Questions rapides depuis une source prête.';
  }

  if (sources.any(_isPendingSource)) {
    return 'Révision disponible après traitement';
  }

  if (sources.isNotEmpty &&
      sources.every((source) => source.status == CourseDocumentStatus.failed)) {
    return 'Aucune source prête';
  }

  return 'Ajoute une source pour réviser';
}

String _quickRevisionBlockedLabel(List<CourseDocument> sources) {
  if (sources.any(_isPendingSource)) {
    return 'Analyse en cours';
  }

  if (sources.isNotEmpty &&
      sources.every((source) => source.status == CourseDocumentStatus.failed)) {
    return 'Source à corriger';
  }

  return 'Source requise';
}

String _masteryLabel(CourseProgress progress) {
  if (progress.mastery == null) {
    return 'Maîtrise sur notions travaillées : en attente';
  }

  return 'Maîtrise sur notions travaillées : ${_percent(progress.mastery!)}';
}

String _progressStateLabel(CourseProgressState state) {
  return switch (state) {
    CourseProgressState.noSource => 'Ajoute une source pour commencer.',
    CourseProgressState.processing => 'Analyse du PDF en cours.',
    CourseProgressState.failedOnly =>
      'Les sources ont échoué. Ajoute ou corrige une source.',
    CourseProgressState.noKnowledgeUnits =>
      'Source prête, mais aucune notion exploitable.',
    CourseProgressState.readyNotPracticed =>
      'Notions prêtes, pas encore travaillées.',
    CourseProgressState.practiced => 'Progression basée sur tes réponses.',
    CourseProgressState.unknown => 'Progression disponible.',
  };
}

Color _progressColor(CourseProgressState state) {
  return switch (state) {
    CourseProgressState.practiced => RevisionColors.green,
    CourseProgressState.readyNotPracticed => RevisionColors.blue,
    CourseProgressState.processing => RevisionColors.amber,
    CourseProgressState.failedOnly => RevisionColors.red,
    CourseProgressState.noKnowledgeUnits => RevisionColors.violet,
    CourseProgressState.noSource => RevisionColors.blue,
    CourseProgressState.unknown => RevisionColors.mint,
  };
}

String _courseMeta(CourseListItem course) {
  final parts = <String>[
    if (course.chapterLabel != null) course.chapterLabel!,
    if (course.estimatedMinutes != null) '${course.estimatedMinutes} min',
  ];

  return parts.isEmpty ? 'Cours sans durée estimée' : parts.join(' · ');
}

String _difficultyLabel(CourseDifficulty? difficulty) {
  return switch (difficulty) {
    CourseDifficulty.beginner => 'Débutant',
    CourseDifficulty.intermediate => 'Intermédiaire',
    CourseDifficulty.advanced => 'Avancé',
    null => 'À préciser',
  };
}

String _percent(double value) {
  return '${(value.clamp(0, 1) * 100).round()}%';
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

bool _isPendingSource(CourseDocument source) {
  return source.status == CourseDocumentStatus.uploaded ||
      source.status == CourseDocumentStatus.processing;
}

void _popOrGo(BuildContext context, String fallbackLocation) {
  // Detail pages are opened with push so system/back buttons must pop the stack.
  // The fallback keeps direct deep links usable when no parent route exists.
  if (context.canPop()) {
    context.pop();
    return;
  }

  context.go(fallbackLocation);
}

````````

### `lib/features/courses/presentation/course_quick_revision_launcher.dart`

````````dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_routes.dart';
import '../../../presentation/design_system/components/revision_mvp_components.dart';
import '../../../presentation/design_system/tokens/revision_colors.dart';
import '../../../presentation/design_system/tokens/revision_spacing.dart';
import '../../../presentation/design_system/tokens/revision_typography.dart';
import '../application/courses_providers.dart';
import '../domain/courses_repository.dart';

Future<void> startCourseQuickRevisionFlow({
  required BuildContext context,
  required WidgetRef ref,
  required String courseId,
  required int questionCount,
}) async {
  var loadingDialogShown = false;
  try {
    loadingDialogShown = true;
    unawaited(showQuickRevisionLoadingDialog(context, questionCount));
    final response = await ref
        .read(startCourseQuickRevisionControllerProvider.notifier)
        .start(courseId: courseId, questionCount: questionCount);

    if (!context.mounted) {
      return;
    }

    if (loadingDialogShown) {
      Navigator.of(context, rootNavigator: true).pop();
      loadingDialogShown = false;
    }
    context.go(
      AppRoutes.revisionSessionV2(
        sessionId: response.session.id,
        courseId: courseId,
        mode: 'quick',
      ),
    );
  } catch (error) {
    if (!context.mounted) {
      return;
    }

    if (loadingDialogShown) {
      Navigator.of(context, rootNavigator: true).pop();
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(quickRevisionErrorLabel(error))));
  }
}

Future<void> showQuickRevisionLoadingDialog(
  BuildContext context,
  int questionCount,
) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (context) => PopScope(
      canPop: false,
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(RevisionSpacing.xl),
        child: RevisionGlassCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 42,
                height: 42,
                child: CircularProgressIndicator(
                  color: RevisionColors.blue,
                  strokeWidth: 4,
                ),
              ),
              const SizedBox(height: RevisionSpacing.l),
              Text(
                'Préparation des questions',
                textAlign: TextAlign.center,
                style: RevisionTypography.sectionTitle,
              ),
              const SizedBox(height: RevisionSpacing.s),
              Text(
                '$questionCount questions sont chargées depuis la banque du cours.',
                textAlign: TextAlign.center,
                style: RevisionTypography.body,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

String quickRevisionErrorLabel(Object error) {
  if (error is CourseQuickRevisionUnavailableException) {
    if (error.message == 'Course quick revision questions are being prepared') {
      return 'Les questions sont en préparation. Réessaie dans un instant.';
    }

    return error.message;
  }

  if (error is CourseNotFoundException) {
    return 'Cours introuvable.';
  }

  return 'Impossible de démarrer la révision rapide.';
}

````````

### `lib/features/courses/presentation/courses_home_page.dart`

````````dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_routes.dart';
import '../../../presentation/design_system/components/revision_mvp_components.dart';
import '../../../presentation/design_system/components/revision_states.dart';
import '../../../presentation/design_system/tokens/revision_colors.dart';
import '../../../presentation/design_system/tokens/revision_spacing.dart';
import '../../../presentation/design_system/tokens/revision_subject_visuals.dart';
import '../../../presentation/design_system/tokens/revision_typography.dart';
import '../../subjects/application/subjects_notifier.dart';
import '../../subjects/domain/subject.dart';
import '../application/active_subject_provider.dart';
import '../application/courses_providers.dart';
import '../domain/course_models.dart';
import '../domain/courses_repository.dart';
import 'course_quick_revision_launcher.dart';

class CoursesHomePage extends ConsumerWidget {
  const CoursesHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subjects = ref.watch(subjectsNotifierProvider);
    final notifier = ref.read(subjectsNotifierProvider.notifier);

    return _HomePageFrame(
      child: subjects.when(
        loading: () =>
            const RevisionLoadingState(label: 'Chargement des matières'),
        error: (error, stackTrace) => RevisionErrorState(
          title: 'Impossible de charger les matières',
          message:
              'Vérifie la connexion puis réessaie. Aucun cours de remplacement ne sera affiché.',
          actionLabel: 'Réessayer',
          onAction: notifier.reload,
        ),
        data: (subjects) => _CoursesHomeContent(subjects: subjects),
      ),
    );
  }
}

class _HomePageFrame extends StatelessWidget {
  const _HomePageFrame({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1280),
            child: SizedBox(
              height: constraints.maxHeight,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  RevisionSpacing.pageX,
                  RevisionSpacing.pageTop,
                  RevisionSpacing.pageX,
                  110,
                ),
                child: child,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _CoursesHomeContent extends ConsumerWidget {
  const _CoursesHomeContent({required this.subjects});

  final List<Subject> subjects;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (subjects.isEmpty) {
      return RevisionEmptyState(
        title: 'Commence par créer une matière.',
        message:
            'Ajoute ensuite un cours et une source pour générer tes premières révisions.',
        icon: Icons.school_outlined,
        actionLabel: 'Créer une matière',
        onAction: () => _showCreateSubjectSheet(context),
      );
    }

    final activeSubject = _activeSubject(
      subjects,
      ref.watch(activeSubjectIdProvider),
    );
    final visual = revisionSubjectVisualThemeFor(activeSubject.name);
    final courses = ref.watch(coursesProvider(activeSubject.id));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _HomeTopBar(subject: activeSubject, visual: visual, subjects: subjects),
        const SizedBox(height: RevisionSpacing.xl),
        Text(activeSubject.name, style: RevisionTypography.hero),
        const SizedBox(height: RevisionSpacing.xs),
        Text('Continue ton progrès', style: RevisionTypography.body),
        const SizedBox(height: RevisionSpacing.xl),
        Expanded(
          // The home header stays anchored like the mockups; only the course
          // cards below the hero/section title scroll when the list grows.
          child: courses.when(
            loading: () =>
                const RevisionLoadingState(label: 'Chargement des cours'),
            error: (error, stackTrace) => RevisionErrorState(
              title: 'Impossible de charger les cours',
              message:
                  'Vérifie la connexion puis réessaie. Aucun cours de remplacement ne sera affiché.',
              actionLabel: 'Réessayer',
              onAction: () => ref.invalidate(coursesProvider(activeSubject.id)),
            ),
            data: (courses) => _CourseList(
              subject: activeSubject,
              visual: visual,
              courses: courses,
            ),
          ),
        ),
      ],
    );
  }
}

class _HomeTopBar extends ConsumerWidget {
  const _HomeTopBar({
    required this.subject,
    required this.visual,
    required this.subjects,
  });

  final Subject subject;
  final RevisionSubjectVisualTheme visual;
  final List<Subject> subjects;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        RevisionSubjectSwitcher(
          label: subject.name,
          accent: visual.accent,
          icon: visual.icon,
          onTap: () => _showSubjectPicker(context, subjects, subject.id),
        ),
        const Spacer(),
        // No streak/gems are displayed here: the MVP Core has no real
        // gamification counters yet, so the mockup slots intentionally remain
        // empty instead of inventing production values.
        const RevisionTopCounters(),
      ],
    );
  }
}

class _CourseList extends ConsumerWidget {
  const _CourseList({
    required this.subject,
    required this.visual,
    required this.courses,
  });

  final Subject subject;
  final RevisionSubjectVisualTheme visual;
  final List<CourseListItem> courses;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (courses.isEmpty) {
      return ListView(
        padding: EdgeInsets.zero,
        children: [
          Text(
            'Tes cours de ${subject.name}',
            style: RevisionTypography.sectionTitle,
          ),
          const SizedBox(height: RevisionSpacing.m),
          RevisionEmptyState(
            title: 'Aucun cours pour le moment',
            message:
                'Crée ton premier cours pour ajouter une source et commencer à réviser.',
            icon: Icons.layers_outlined,
            actionLabel: 'Créer un cours',
            onAction: () => _showCreateCourseSheet(context, subject),
          ),
          const SizedBox(height: RevisionSpacing.l),
          _CourseCreationHint(subject: subject, visual: visual),
        ],
      );
    }

    final spotlightCourse = _spotlightCourse(courses);
    final spotlightReady = spotlightCourse.readySourceCount > 0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final fixedHeader = <Widget>[
          RevisionResumeCourseCard(
            title: spotlightCourse.title,
            subtitle: spotlightReady
                ? 'Cours prêt à réviser'
                : 'Préparer ce cours',
            progressLabel: _courseProgressLabel(spotlightCourse),
            progress: _courseProgressValue(spotlightCourse),
            accent: visual.accent,
            icon: visual.icon,
            actionLabel: spotlightReady ? 'Réviser' : 'Ouvrir',
            onContinue: () {
              if (!spotlightReady) {
                context.push(AppRoutes.course(spotlightCourse.id));
                return;
              }

              startCourseQuickRevisionFlow(
                context: context,
                ref: ref,
                courseId: spotlightCourse.id,
                questionCount: 5,
              );
            },
          ),
          const SizedBox(height: RevisionSpacing.xl),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Tes cours de ${subject.name}',
                  style: RevisionTypography.sectionTitle,
                ),
              ),
              TextButton.icon(
                onPressed: () => _showCreateCourseSheet(context, subject),
                icon: const Icon(Icons.add_rounded),
                label: const Text('Créer'),
              ),
            ],
          ),
          const SizedBox(height: RevisionSpacing.m),
        ];

        if (constraints.maxHeight < 340) {
          // On very short surfaces, preserving accessibility matters more than
          // strict pinning: the whole course area scrolls to avoid clipping.
          return ListView(
            padding: EdgeInsets.zero,
            children: [
              ...fixedHeader,
              ..._courseCards(context),
              const SizedBox(height: RevisionSpacing.l),
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...fixedHeader,
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.only(bottom: RevisionSpacing.l),
                itemCount: courses.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: RevisionSpacing.m),
                itemBuilder: (context, index) =>
                    _courseCard(context, courses[index]),
              ),
            ),
          ],
        );
      },
    );
  }

  List<Widget> _courseCards(BuildContext context) {
    return [
      for (final course in courses) ...[
        _courseCard(context, course),
        const SizedBox(height: RevisionSpacing.m),
      ],
    ];
  }

  Widget _courseCard(BuildContext context, CourseListItem course) {
    return RevisionCourseCard(
      title: course.title,
      progressLabel: _courseProgressLabel(course),
      durationLabel: _courseMeta(course),
      progress: _courseProgressValue(course),
      accent: visual.accent,
      icon: visual.icon,
      onTap: () => context.push(AppRoutes.course(course.id)),
    );
  }
}

class _CourseCreationHint extends StatelessWidget {
  const _CourseCreationHint({required this.subject, required this.visual});

  final Subject subject;
  final RevisionSubjectVisualTheme visual;

  @override
  Widget build(BuildContext context) {
    return RevisionGlassCard(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          visual.accent.withValues(alpha: 0.28),
          RevisionColors.glassStrong,
        ],
      ),
      borderColor: visual.accent.withValues(alpha: 0.34),
      child: Row(
        children: [
          RevisionIconTile(icon: visual.icon, accent: visual.accent),
          const SizedBox(width: RevisionSpacing.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Prêt à structurer ${subject.name} ?',
                  style: RevisionTypography.sectionTitle,
                ),
                const SizedBox(height: RevisionSpacing.xs),
                Text(
                  'Un cours devient utile dès qu’une source PDF est prête.',
                  style: RevisionTypography.body,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CreateCourseSheet extends ConsumerStatefulWidget {
  const _CreateCourseSheet({required this.subject});

  final Subject subject;

  @override
  ConsumerState<_CreateCourseSheet> createState() => _CreateCourseSheetState();
}

class _CreateCourseSheetState extends ConsumerState<_CreateCourseSheet> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _chapterController = TextEditingController();
  final _minutesController = TextEditingController();
  String? _localError;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _chapterController.dispose();
    _minutesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final createState = ref.watch(createCourseControllerProvider);

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: RevisionBottomSheetFrame(
        title: 'Créer un cours',
        subtitle: widget.subject.name,
        children: [
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(labelText: 'Titre'),
            textInputAction: TextInputAction.next,
          ),
          TextField(
            controller: _descriptionController,
            decoration: const InputDecoration(labelText: 'Description'),
            textInputAction: TextInputAction.next,
          ),
          TextField(
            controller: _chapterController,
            decoration: const InputDecoration(labelText: 'Chapitre'),
            textInputAction: TextInputAction.next,
          ),
          TextField(
            controller: _minutesController,
            decoration: const InputDecoration(labelText: 'Durée estimée'),
            keyboardType: TextInputType.number,
          ),
          if (_localError != null)
            Text(
              _localError!,
              style: const TextStyle(color: RevisionColors.red),
            ),
          if (createState.hasError)
            const Text(
              'Impossible de créer le cours.',
              style: TextStyle(color: RevisionColors.red),
            ),
          RevisionGradientButton(
            label: createState.isLoading ? 'Création...' : 'Créer le cours',
            icon: Icons.add_rounded,
            expanded: true,
            onPressed: createState.isLoading ? null : _submit,
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    final title = _titleController.text.trim();
    final minutesText = _minutesController.text.trim();
    final estimatedMinutes = minutesText.isEmpty
        ? null
        : int.tryParse(minutesText);

    if (title.length < 2) {
      setState(() {
        _localError = 'Le titre doit contenir au moins 2 caractères.';
      });
      return;
    }

    if (minutesText.isNotEmpty && estimatedMinutes == null) {
      setState(() {
        _localError = 'La durée doit être un nombre entier.';
      });
      return;
    }

    setState(() {
      _localError = null;
    });

    try {
      final course = await ref
          .read(createCourseControllerProvider.notifier)
          .create(
            subjectId: widget.subject.id,
            input: CreateCourseInput(
              title: title,
              description: _optionalText(_descriptionController.text),
              chapterLabel: _optionalText(_chapterController.text),
              estimatedMinutes: estimatedMinutes,
            ),
          );

      if (!mounted) {
        return;
      }

      final router = GoRouter.of(context);
      Navigator.of(context).pop();
      router.push(AppRoutes.course(course.id));
    } on CourseRequestException {
      setState(() {
        _localError = 'Les informations du cours sont invalides.';
      });
    }
  }
}

class _CreateSubjectSheet extends ConsumerStatefulWidget {
  const _CreateSubjectSheet();

  @override
  ConsumerState<_CreateSubjectSheet> createState() =>
      _CreateSubjectSheetState();
}

class _CreateSubjectSheetState extends ConsumerState<_CreateSubjectSheet> {
  final _nameController = TextEditingController();
  String? _localError;
  bool _submitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: RevisionBottomSheetFrame(
        title: 'Créer une matière',
        subtitle: 'Elle deviendra la matière active de l’accueil.',
        children: [
          TextField(
            controller: _nameController,
            autofocus: true,
            decoration: const InputDecoration(labelText: 'Nom de la matière'),
            textInputAction: TextInputAction.done,
            onSubmitted: (_) {
              if (!_submitting) {
                _submit();
              }
            },
          ),
          if (_localError != null)
            Text(
              _localError!,
              style: const TextStyle(color: RevisionColors.red),
            ),
          RevisionGradientButton(
            label: _submitting ? 'Création...' : 'Créer la matière',
            icon: Icons.add_rounded,
            expanded: true,
            onPressed: _submitting ? null : _submit,
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();

    if (name.length < 2) {
      setState(() {
        _localError = 'Le nom doit contenir au moins 2 caractères.';
      });
      return;
    }

    setState(() {
      _localError = null;
      _submitting = true;
    });

    try {
      final subject = await ref
          .read(subjectsNotifierProvider.notifier)
          .createSubject(name: name);

      ref.read(activeSubjectIdProvider.notifier).select(subject.id);

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop();
    } on ArgumentError {
      if (!mounted) {
        return;
      }

      setState(() {
        _localError = 'Le nom doit contenir au moins 2 caractères.';
        _submitting = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _localError = 'Impossible de créer la matière.';
        _submitting = false;
      });
    }
  }
}

Subject _activeSubject(List<Subject> subjects, String? activeSubjectId) {
  for (final subject in subjects) {
    if (subject.id == activeSubjectId) {
      return subject;
    }
  }

  return subjects.first;
}

CourseListItem _spotlightCourse(List<CourseListItem> courses) {
  for (final course in courses) {
    if (course.readySourceCount > 0) {
      return course;
    }
  }

  return courses.first;
}

void _showSubjectPicker(
  BuildContext context,
  List<Subject> subjects,
  String activeSubjectId,
) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => _SubjectPickerSheet(
      parentContext: context,
      subjects: subjects,
      activeSubjectId: activeSubjectId,
    ),
  );
}

class _SubjectPickerSheet extends ConsumerWidget {
  const _SubjectPickerSheet({
    required this.parentContext,
    required this.subjects,
    required this.activeSubjectId,
  });

  final BuildContext parentContext;
  final List<Subject> subjects;
  final String activeSubjectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RevisionBottomSheetFrame(
      title: 'Choisir une matière',
      subtitle: 'La page reste centrée sur une seule matière active.',
      children: [
        for (final subject in subjects)
          _SubjectChoiceCard(
            subject: subject,
            selected: subject.id == activeSubjectId,
            onTap: () {
              ref.read(activeSubjectIdProvider.notifier).select(subject.id);
              Navigator.of(context).pop();
            },
          ),
        RevisionGradientButton(
          label: 'Créer une matière',
          icon: Icons.add_rounded,
          expanded: true,
          onPressed: () {
            Navigator.of(context).pop();
            Future<void>.microtask(() {
              if (!parentContext.mounted) {
                return;
              }

              _showCreateSubjectSheet(parentContext);
            });
          },
        ),
      ],
    );
  }
}

void _showCreateCourseSheet(BuildContext context, Subject subject) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _CreateCourseSheet(subject: subject),
  );
}

void _showCreateSubjectSheet(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (context) => const _CreateSubjectSheet(),
  );
}

class _SubjectChoiceCard extends StatelessWidget {
  const _SubjectChoiceCard({
    required this.subject,
    required this.selected,
    required this.onTap,
  });

  final Subject subject;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final visual = revisionSubjectVisualThemeFor(subject.name);

    return RevisionGlassCard(
      selected: selected,
      onTap: onTap,
      child: Row(
        children: [
          RevisionIconTile(icon: visual.icon, accent: visual.accent),
          const SizedBox(width: RevisionSpacing.m),
          Expanded(
            child: Text(subject.name, style: RevisionTypography.sectionTitle),
          ),
          if (selected) Icon(Icons.check_circle_rounded, color: visual.accent),
        ],
      ),
    );
  }
}

double _courseProgressValue(CourseListItem course) {
  final progress = course.progress;
  if (progress != null) {
    return progress.estimatedGlobalMastery;
  }

  if (course.sourceCount <= 0) {
    return 0;
  }

  return course.readySourceCount / course.sourceCount;
}

String _courseProgressLabel(CourseListItem course) {
  final progress = course.progress;
  if (progress != null) {
    return 'Global ${_percent(progress.estimatedGlobalMastery)}';
  }

  return _sourceMeta(course);
}

String _courseMeta(CourseListItem course) {
  final parts = <String>[
    if (course.chapterLabel != null) course.chapterLabel!,
    if (course.estimatedMinutes != null) '${course.estimatedMinutes} min',
  ];

  return parts.isEmpty ? 'Durée à préciser' : parts.join(' · ');
}

String _sourceMeta(CourseListItem course) {
  final sourceLabel = course.sourceCount <= 1 ? 'source' : 'sources';
  final readyLabel = course.readySourceCount <= 1 ? 'prête' : 'prêtes';

  return '${course.sourceCount} $sourceLabel · ${course.readySourceCount} $readyLabel';
}

String _percent(double value) {
  return '${(value.clamp(0, 1) * 100).round()}%';
}

String? _optionalText(String value) {
  final trimmed = value.trim();

  return trimmed.isEmpty ? null : trimmed;
}

````````

### `lib/features/courses/presentation/revisions_pending_page.dart`

````````dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_routes.dart';
import '../../../presentation/design_system/components/revision_mvp_components.dart';
import '../../../presentation/design_system/components/revision_states.dart';
import '../../../presentation/design_system/tokens/revision_colors.dart';
import '../../../presentation/design_system/tokens/revision_spacing.dart';
import '../../../presentation/design_system/tokens/revision_subject_visuals.dart';
import '../../../presentation/design_system/tokens/revision_typography.dart';
import '../application/active_subject_provider.dart';
import '../application/courses_providers.dart';
import '../domain/course_models.dart';
import 'course_quick_revision_launcher.dart';

class RevisionsPendingPage extends ConsumerWidget {
  const RevisionsPendingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeSubject = ref.watch(activeSubjectProvider);

    return RevisionPageScaffold(
      headerChildren: [
        Text('Réviser', style: RevisionTypography.hero),
        Text(
          'Choisis une session courte et utile.',
          style: RevisionTypography.body,
        ),
      ],
      children: [
        activeSubject.when(
          loading: () =>
              const RevisionLoadingState(label: 'Chargement des matières'),
          error: (error, stackTrace) => RevisionErrorState(
            title: 'Révisions indisponibles',
            message: 'Impossible de déterminer la matière active.',
            actionLabel: 'Retour à l’accueil',
            onAction: () => context.go(AppRoutes.home),
          ),
          data: (subject) {
            if (subject == null) {
              return RevisionEmptyState(
                title: 'Aucune matière disponible',
                message:
                    'Crée une matière, puis ajoute un cours et une source pour lancer une révision rapide.',
                icon: Icons.track_changes_rounded,
                actionLabel: 'Ouvrir les matières',
                onAction: () => context.go(AppRoutes.subjects),
              );
            }

            return _RevisionHubContent(
              subjectId: subject.id,
              subjectName: subject.name,
            );
          },
        ),
      ],
    );
  }
}

class _RevisionHubContent extends ConsumerWidget {
  const _RevisionHubContent({
    required this.subjectId,
    required this.subjectName,
  });

  final String subjectId;
  final String subjectName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final courses = ref.watch(coursesProvider(subjectId));
    final visual = revisionSubjectVisualThemeFor(subjectName);

    return courses.when(
      loading: () => const RevisionLoadingState(label: 'Chargement des cours'),
      error: (error, stackTrace) => RevisionErrorState(
        title: 'Cours indisponibles',
        message: 'Impossible de charger les cours de cette matière.',
        actionLabel: 'Réessayer',
        onAction: () => ref.invalidate(coursesProvider(subjectId)),
      ),
      data: (courses) {
        final readyCourse = _firstReadyCourse(courses);
        final firstCourse = courses.isEmpty ? null : courses.first;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _RevisionHubPrimaryAction(
              subjectName: subjectName,
              visual: visual,
              readyCourse: readyCourse,
              fallbackCourse: firstCourse,
            ),
            const SizedBox(height: RevisionSpacing.l),
            RevisionModeCard(
              title: 'Révision rapide',
              description: readyCourse == null
                  ? 'Ajoute une source prête dans un cours pour réviser.'
                  : 'Session courte depuis ${readyCourse.title}.',
              icon: Icons.flash_on_rounded,
              accent: RevisionColors.blue,
              enabled: readyCourse != null,
              trailingLabel: readyCourse == null ? 'Source requise' : null,
              onTap: readyCourse == null
                  ? null
                  : () => startCourseQuickRevisionFlow(
                      context: context,
                      ref: ref,
                      courseId: readyCourse.id,
                      questionCount: 5,
                    ),
            ),
            const SizedBox(height: RevisionSpacing.m),
            RevisionModeCard(
              title: 'Révision approfondie',
              description: 'Cours complet et exemples détaillés.',
              icon: Icons.menu_book_rounded,
              accent: visual.accent,
              trailingLabel: 'Bientôt disponible',
              enabled: false,
            ),
            const SizedBox(height: RevisionSpacing.m),
            RevisionModeCard(
              title: 'Préparation examen',
              description: 'Entraînements et sujets corrigés.',
              icon: Icons.gps_fixed_rounded,
              accent: RevisionColors.pink,
              trailingLabel: 'Bientôt disponible',
              enabled: false,
            ),
          ],
        );
      },
    );
  }
}

class _RevisionHubPrimaryAction extends ConsumerWidget {
  const _RevisionHubPrimaryAction({
    required this.subjectName,
    required this.visual,
    required this.readyCourse,
    required this.fallbackCourse,
  });

  final String subjectName;
  final RevisionSubjectVisualTheme visual;
  final CourseListItem? readyCourse;
  final CourseListItem? fallbackCourse;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final readyCourse = this.readyCourse;

    if (readyCourse != null) {
      return RevisionGlassCard(
        borderColor: RevisionColors.blue.withValues(alpha: 0.36),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            RevisionColors.blue.withValues(alpha: 0.26),
            RevisionColors.glassStrong,
          ],
        ),
        child: Row(
          children: [
            RevisionIconTile(
              icon: Icons.flash_on_rounded,
              accent: RevisionColors.blue,
              size: 52,
            ),
            const SizedBox(width: RevisionSpacing.m),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subjectName,
                    style: RevisionTypography.caption.copyWith(
                      color: visual.accent,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: RevisionSpacing.xs),
                  Text(
                    readyCourse.title,
                    style: RevisionTypography.sectionTitle,
                  ),
                  const SizedBox(height: RevisionSpacing.xs),
                  Text(
                    'Un cours est prêt pour une session rapide.',
                    style: RevisionTypography.body,
                  ),
                  const SizedBox(height: RevisionSpacing.m),
                  RevisionGradientButton(
                    label: 'Commencer 5 questions',
                    icon: Icons.play_arrow_rounded,
                    onPressed: () => startCourseQuickRevisionFlow(
                      context: context,
                      ref: ref,
                      courseId: readyCourse.id,
                      questionCount: 5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    final fallbackCourse = this.fallbackCourse;
    return RevisionGlassCard(
      child: Row(
        children: [
          RevisionIconTile(icon: visual.icon, accent: visual.accent, size: 42),
          const SizedBox(width: RevisionSpacing.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Préparer un cours',
                  style: RevisionTypography.sectionTitle,
                ),
                const SizedBox(height: RevisionSpacing.xs),
                Text(
                  fallbackCourse == null
                      ? 'Crée un cours et ajoute une source pour lancer une révision rapide.'
                      : 'Ajoute une source prête dans un cours pour lancer une révision rapide.',
                  style: RevisionTypography.body,
                ),
              ],
            ),
          ),
          const SizedBox(width: RevisionSpacing.s),
          TextButton(
            onPressed: () {
              final course = fallbackCourse;
              if (course == null) {
                context.go(AppRoutes.home);
                return;
              }

              context.push(AppRoutes.course(course.id));
            },
            child: Text(fallbackCourse == null ? 'Accueil' : 'Ouvrir'),
          ),
        ],
      ),
    );
  }
}

CourseListItem? _firstReadyCourse(List<CourseListItem> courses) {
  for (final course in courses) {
    if (course.readySourceCount > 0) {
      return course;
    }
  }

  return null;
}

````````

### `lib/presentation/design_system/components/revision_mvp_components.dart`

````````dart

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../tokens/revision_colors.dart';
import '../tokens/revision_radius.dart';
import '../tokens/revision_shadows.dart';
import '../tokens/revision_spacing.dart';
import '../tokens/revision_typography.dart';

class RevisionPageScaffold extends StatelessWidget {
  const RevisionPageScaffold({
    required this.children,
    this.headerChildren = const [],
    this.padding = const EdgeInsets.fromLTRB(
      RevisionSpacing.pageX,
      RevisionSpacing.pageTop,
      RevisionSpacing.pageX,
      110,
    ),
    this.maxWidth = 1280,
    super.key,
  });

  final List<Widget> children;
  final List<Widget> headerChildren;
  final EdgeInsetsGeometry padding;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final resolvedPadding = padding.resolve(Directionality.of(context));
        final hasFixedHeader = headerChildren.isNotEmpty;
        final supportsFixedHeader =
            hasFixedHeader && constraints.hasBoundedHeight;

        final scrollableContent = _SpacedColumn(children: children);

        if (!supportsFixedHeader) {
          return Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              // Keep the premium screens visually fixed when their content
              // fits, but still allow overflow content to move on shorter
              // panes. This avoids the "web page" feeling on normal screens
              // without risking clipped cards when a course has more state.
              child: SingleChildScrollView(
                child: Padding(padding: padding, child: scrollableContent),
              ),
            ),
          );
        }

        return Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    resolvedPadding.left,
                    resolvedPadding.top,
                    resolvedPadding.right,
                    0,
                  ),
                  child: _SpacedColumn(children: headerChildren),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        resolvedPadding.left,
                        RevisionSpacing.l,
                        resolvedPadding.right,
                        resolvedPadding.bottom,
                      ),
                      child: scrollableContent,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SpacedColumn extends StatelessWidget {
  const _SpacedColumn({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final child in children) ...[
          child,
          if (child != children.last) const SizedBox(height: RevisionSpacing.l),
        ],
      ],
    );
  }
}

class RevisionGlassCard extends StatelessWidget {
  const RevisionGlassCard({
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(RevisionSpacing.l),
    this.radius = RevisionRadius.radiusL,
    this.borderColor,
    this.backgroundColor,
    this.gradient,
    this.selected = false,
    super.key,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final BorderRadius radius;
  final Color? borderColor;
  final Color? backgroundColor;
  final Gradient? gradient;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final content = AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: padding,
      decoration: BoxDecoration(
        color: gradient == null
            ? backgroundColor ?? RevisionColors.glassSoft
            : null,
        gradient: gradient,
        borderRadius: radius,
        border: Border.all(
          color:
              borderColor ??
              (selected ? RevisionColors.blue : RevisionColors.border),
          width: selected ? 1.4 : 1,
        ),
        boxShadow: selected
            ? RevisionShadows.soft(RevisionColors.blue)
            : RevisionShadows.glass,
      ),
      child: child,
    );

    if (onTap == null) {
      return content;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(borderRadius: radius, onTap: onTap, child: content),
    );
  }
}

class RevisionGradientButton extends StatelessWidget {
  const RevisionGradientButton({
    required this.label,
    this.icon,
    this.onPressed,
    this.expanded = false,
    this.gradient,
    this.foreground = RevisionColors.text,
    super.key,
  });

  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool expanded;
  final Gradient? gradient;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    final button = Opacity(
      opacity: enabled ? 1 : 0.55,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient:
              gradient ??
              const LinearGradient(
                colors: [RevisionColors.blue, RevisionColors.blueDeep],
              ),
          borderRadius: RevisionRadius.pill,
          boxShadow: RevisionShadows.soft(RevisionColors.blue),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: RevisionSpacing.xl,
            vertical: RevisionSpacing.m,
          ),
          child: Row(
            mainAxisSize: expanded ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, color: foreground, size: 19),
                const SizedBox(width: RevisionSpacing.s),
              ],
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: RevisionColors.text,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onPressed,
        child: expanded
            ? SizedBox(width: double.infinity, child: button)
            : button,
      ),
    );
  }
}

class RevisionIconTile extends StatelessWidget {
  const RevisionIconTile({
    required this.icon,
    required this.accent,
    this.size = 52,
    this.iconSize = 28,
    super.key,
  });

  final IconData icon;
  final Color accent;
  final double size;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accent.withValues(alpha: 0.95),
            accent.withValues(alpha: 0.35),
          ],
        ),
        borderRadius: RevisionRadius.radiusM,
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
        boxShadow: RevisionShadows.soft(accent),
      ),
      child: Icon(icon, color: RevisionColors.text, size: iconSize),
    );
  }
}

class RevisionHeaderActionPill extends StatelessWidget {
  const RevisionHeaderActionPill({
    required this.label,
    required this.icon,
    this.onTap,
    this.accent = RevisionColors.blue,
    this.selected = false,
    super.key,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onTap;
  final Color accent;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;

    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 160),
          opacity: enabled ? 1 : 0.58,
          child: Container(
            constraints: const BoxConstraints(minHeight: 38),
            padding: const EdgeInsets.symmetric(
              horizontal: RevisionSpacing.m,
              vertical: RevisionSpacing.s,
            ),
            decoration: BoxDecoration(
              color: selected
                  ? accent.withValues(alpha: 0.18)
                  : RevisionColors.glassSoft,
              borderRadius: RevisionRadius.pill,
              border: Border.all(
                color: selected
                    ? accent.withValues(alpha: 0.68)
                    : RevisionColors.border,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color: selected ? accent : RevisionColors.textMuted,
                  size: 17,
                ),
                const SizedBox(width: RevisionSpacing.xs),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: selected
                        ? RevisionColors.text
                        : RevisionColors.textMuted,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                    letterSpacing: 0,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class RevisionMetricPill extends StatelessWidget {
  const RevisionMetricPill({
    required this.label,
    required this.icon,
    this.accent = RevisionColors.blue,
    super.key,
  });

  final String label;
  final IconData icon;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: RevisionSpacing.m,
        vertical: RevisionSpacing.s,
      ),
      decoration: BoxDecoration(
        color: RevisionColors.glassSoft,
        borderRadius: RevisionRadius.pill,
        border: Border.all(color: accent.withValues(alpha: 0.32)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: accent, size: 16),
          const SizedBox(width: RevisionSpacing.xs),
          Text(
            label,
            style: RevisionTypography.caption.copyWith(
              color: RevisionColors.text,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class RevisionSubjectSwitcher extends StatelessWidget {
  const RevisionSubjectSwitcher({
    required this.label,
    required this.accent,
    required this.icon,
    required this.onTap,
    super.key,
  });

  final String label;
  final Color accent;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Changer de matiere',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 40, maxWidth: 190),
          padding: const EdgeInsets.symmetric(
            horizontal: RevisionSpacing.m,
            vertical: RevisionSpacing.s,
          ),
          decoration: BoxDecoration(
            color: RevisionColors.glassSoft,
            borderRadius: RevisionRadius.pill,
            border: Border.all(color: accent, width: 1.4),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              RevisionIconTile(
                icon: icon,
                accent: accent,
                size: 24,
                iconSize: 15,
              ),
              const SizedBox(width: RevisionSpacing.s),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: RevisionColors.text,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    letterSpacing: 0,
                  ),
                ),
              ),
              const SizedBox(width: RevisionSpacing.xs),
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: RevisionColors.textMuted,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RevisionTopCounters extends StatelessWidget {
  const RevisionTopCounters({this.streakLabel, this.gemsLabel, super.key});

  final String? streakLabel;
  final String? gemsLabel;

  @override
  Widget build(BuildContext context) {
    final counters = <Widget>[
      if (streakLabel != null)
        _CounterPill(
          icon: Icons.local_fire_department_rounded,
          label: streakLabel!,
        ),
      if (gemsLabel != null)
        _CounterPill(
          icon: Icons.diamond_rounded,
          label: gemsLabel!,
          accent: RevisionColors.cyan,
        ),
    ];

    if (counters.isEmpty) {
      return const SizedBox.shrink();
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final (index, counter) in counters.indexed) ...[
          if (index > 0) const SizedBox(width: RevisionSpacing.s),
          counter,
        ],
      ],
    );
  }
}

class _CounterPill extends StatelessWidget {
  const _CounterPill({
    required this.icon,
    required this.label,
    this.accent = RevisionColors.amber,
  });

  final IconData icon;
  final String label;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: RevisionSpacing.s,
        vertical: RevisionSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: RevisionColors.glassSoft,
        borderRadius: RevisionRadius.pill,
      ),
      child: Row(
        children: [
          Icon(icon, color: accent, size: 18),
          const SizedBox(width: RevisionSpacing.xs),
          Text(
            label,
            style: TextStyle(
              color: accent,
              fontWeight: FontWeight.w900,
              fontSize: 14,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}

class RevisionProgressLine extends StatelessWidget {
  const RevisionProgressLine({
    required this.value,
    this.color = RevisionColors.blue,
    this.height = 5,
    super.key,
  });

  final double value;
  final Color color;
  final double height;

  @override
  Widget build(BuildContext context) {
    final clamped = value.clamp(0, 1).toDouble();

    return ClipRRect(
      borderRadius: RevisionRadius.pill,
      child: LinearProgressIndicator(
        value: clamped,
        minHeight: height,
        color: color,
        backgroundColor: RevisionColors.border.withValues(alpha: 0.72),
      ),
    );
  }
}

class RevisionMasteryRing extends StatelessWidget {
  const RevisionMasteryRing({
    required this.value,
    required this.label,
    this.size = 82,
    this.color = RevisionColors.green,
    this.caption,
    super.key,
  });

  final double value;
  final String label;
  final String? caption;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox.square(
            dimension: size,
            child: CircularProgressIndicator(
              value: value.clamp(0, 1).toDouble(),
              strokeWidth: 7,
              strokeCap: StrokeCap.round,
              color: color,
              backgroundColor: RevisionColors.border,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: RevisionColors.text,
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                  letterSpacing: 0,
                ),
              ),
              if (caption != null)
                Text(
                  caption!,
                  textAlign: TextAlign.center,
                  style: RevisionTypography.caption.copyWith(
                    color: RevisionColors.textMuted,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class RevisionResumeCourseCard extends StatelessWidget {
  const RevisionResumeCourseCard({
    required this.title,
    required this.subtitle,
    required this.progressLabel,
    required this.progress,
    required this.accent,
    required this.icon,
    required this.onContinue,
    this.actionLabel = 'Continuer',
    super.key,
  });

  final String title;
  final String subtitle;
  final String progressLabel;
  final double progress;
  final Color accent;
  final IconData icon;
  final VoidCallback onContinue;
  final String actionLabel;

  @override
  Widget build(BuildContext context) {
    return RevisionGlassCard(
      padding: const EdgeInsets.all(RevisionSpacing.m),
      gradient: LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [accent.withValues(alpha: 0.92), RevisionColors.blueDeep],
      ),
      borderColor: Colors.white.withValues(alpha: 0.14),
      child: Row(
        children: [
          RevisionIconTile(
            icon: Icons.play_arrow_rounded,
            accent: RevisionColors.cyan,
          ),
          const SizedBox(width: RevisionSpacing.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subtitle,
                  style: RevisionTypography.caption.copyWith(
                    color: RevisionColors.text.withValues(alpha: 0.72),
                  ),
                ),
                const SizedBox(height: RevisionSpacing.xs),
                Text(title, style: RevisionTypography.sectionTitle),
                const SizedBox(height: RevisionSpacing.m),
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: RevisionProgressLine(
                        value: progress,
                        color: RevisionColors.cyan,
                      ),
                    ),
                    const SizedBox(width: RevisionSpacing.s),
                    Flexible(
                      flex: 2,
                      child: Text(
                        progressLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: RevisionTypography.caption.copyWith(
                          color: RevisionColors.text,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: RevisionSpacing.s),
          TextButton(
            onPressed: onContinue,
            style: TextButton.styleFrom(
              backgroundColor: RevisionColors.text,
              foregroundColor: RevisionColors.blueDeep,
              shape: const StadiumBorder(),
              padding: const EdgeInsets.symmetric(
                horizontal: RevisionSpacing.m,
                vertical: RevisionSpacing.s,
              ),
            ),
            child: Text(
              actionLabel,
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }
}

class RevisionCourseCard extends StatelessWidget {
  const RevisionCourseCard({
    required this.title,
    required this.progressLabel,
    required this.durationLabel,
    required this.progress,
    required this.accent,
    required this.icon,
    required this.onTap,
    super.key,
  });

  final String title;
  final String progressLabel;
  final String durationLabel;
  final double progress;
  final Color accent;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return RevisionGlassCard(
      onTap: onTap,
      padding: const EdgeInsets.all(RevisionSpacing.m),
      child: Row(
        children: [
          RevisionIconTile(icon: icon, accent: accent, size: 48, iconSize: 27),
          const SizedBox(width: RevisionSpacing.m),
          Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: RevisionTypography.sectionTitle,
                ),
                const SizedBox(height: RevisionSpacing.s),
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        progressLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: RevisionTypography.caption.copyWith(
                          color: accent,
                        ),
                      ),
                    ),
                    const SizedBox(width: RevisionSpacing.m),
                    Expanded(
                      child: RevisionProgressLine(
                        value: progress,
                        color: accent,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: RevisionSpacing.m),
          Flexible(
            flex: 3,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.schedule_rounded,
                  color: RevisionColors.textMuted,
                  size: 15,
                ),
                const SizedBox(width: RevisionSpacing.xs),
                Flexible(
                  child: Text(
                    durationLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: RevisionTypography.caption,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: RevisionSpacing.s),
          const Icon(
            Icons.chevron_right_rounded,
            color: RevisionColors.textMuted,
          ),
        ],
      ),
    );
  }
}

class RevisionModeCard extends StatelessWidget {
  const RevisionModeCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.accent,
    this.onTap,
    this.enabled = true,
    this.trailingLabel,
    super.key,
  });

  final String title;
  final String description;
  final IconData icon;
  final Color accent;
  final VoidCallback? onTap;
  final bool enabled;
  final String? trailingLabel;

  @override
  Widget build(BuildContext context) {
    return RevisionGlassCard(
      onTap: enabled ? onTap : null,
      padding: const EdgeInsets.all(RevisionSpacing.m),
      gradient: LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          accent.withValues(alpha: enabled ? 0.78 : 0.28),
          RevisionColors.glassStrong,
        ],
      ),
      borderColor: accent.withValues(alpha: 0.30),
      child: Row(
        children: [
          RevisionIconTile(icon: icon, accent: accent, size: 48),
          const SizedBox(width: RevisionSpacing.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: RevisionTypography.sectionTitle),
                const SizedBox(height: RevisionSpacing.xs),
                Text(description, style: RevisionTypography.body),
              ],
            ),
          ),
          if (trailingLabel != null)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: RevisionSpacing.s,
                vertical: RevisionSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: RevisionColors.ink.withValues(alpha: 0.28),
                borderRadius: RevisionRadius.pill,
              ),
              child: Text(
                trailingLabel!,
                style: RevisionTypography.caption.copyWith(
                  color: enabled
                      ? RevisionColors.text
                      : RevisionColors.textMuted,
                  fontWeight: FontWeight.w800,
                ),
              ),
            )
          else
            Icon(
              Icons.chevron_right_rounded,
              color: enabled ? RevisionColors.text : RevisionColors.textFaint,
            ),
        ],
      ),
    );
  }
}

class RevisionSourceFileCard extends StatelessWidget {
  const RevisionSourceFileCard({
    required this.fileName,
    required this.statusLabel,
    this.sizeLabel,
    this.statusColor = RevisionColors.red,
    this.trailing,
    this.onTap,
    super.key,
  });

  final String fileName;
  final String? sizeLabel;
  final String statusLabel;
  final Color statusColor;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return RevisionGlassCard(
      onTap: onTap,
      padding: const EdgeInsets.all(RevisionSpacing.m),
      child: Row(
        children: [
          RevisionIconTile(
            icon: Icons.picture_as_pdf_rounded,
            accent: statusColor,
            size: 42,
            iconSize: 23,
          ),
          const SizedBox(width: RevisionSpacing.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fileName,
                  style: RevisionTypography.sectionTitle.copyWith(fontSize: 14),
                ),
                const SizedBox(height: RevisionSpacing.xs),
                Text(
                  sizeLabel == null ? statusLabel : '$sizeLabel · $statusLabel',
                  style: RevisionTypography.caption,
                ),
              ],
            ),
          ),
          trailing ??
              const Icon(
                Icons.more_vert_rounded,
                color: RevisionColors.textMuted,
              ),
        ],
      ),
    );
  }
}

class RevisionBottomSheetFrame extends StatelessWidget {
  const RevisionBottomSheetFrame({
    required this.title,
    required this.children,
    this.subtitle,
    this.floatingAction,
    super.key,
  });

  final String title;
  final String? subtitle;
  final List<Widget> children;
  final Widget? floatingAction;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: RevisionColors.ink2,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: SafeArea(
        top: false,
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                RevisionSpacing.xl,
                RevisionSpacing.m,
                RevisionSpacing.xl,
                floatingAction == null ? RevisionSpacing.xl : 112,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: Container(
                      width: 52,
                      height: 5,
                      decoration: BoxDecoration(
                        color: RevisionColors.borderBright,
                        borderRadius: RevisionRadius.pill,
                      ),
                    ),
                  ),
                  const SizedBox(height: RevisionSpacing.xl),
                  Text(title, style: RevisionTypography.pageTitle),
                  if (subtitle != null) ...[
                    const SizedBox(height: RevisionSpacing.s),
                    Text(subtitle!, style: RevisionTypography.body),
                  ],
                  const SizedBox(height: RevisionSpacing.l),
                  for (final child in children) ...[
                    child,
                    if (child != children.last)
                      const SizedBox(height: RevisionSpacing.m),
                  ],
                ],
              ),
            ),
            if (floatingAction != null)
              Positioned(
                left: 0,
                right: 0,
                bottom: RevisionSpacing.l,
                child: Center(child: floatingAction),
              ),
          ],
        ),
      ),
    );
  }
}

class RevisionSheetSectionCard extends StatelessWidget {
  const RevisionSheetSectionCard({
    required this.title,
    required this.icon,
    required this.children,
    this.accent = RevisionColors.blue,
    super.key,
  });

  final String title;
  final IconData icon;
  final Color accent;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return RevisionGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              RevisionIconTile(
                icon: icon,
                accent: accent,
                size: 28,
                iconSize: 16,
              ),
              const SizedBox(width: RevisionSpacing.s),
              Expanded(
                child: Text(title, style: RevisionTypography.sectionTitle),
              ),
            ],
          ),
          const SizedBox(height: RevisionSpacing.m),
          for (final child in children) ...[
            child,
            if (child != children.last)
              const SizedBox(height: RevisionSpacing.s),
          ],
        ],
      ),
    );
  }
}

class RevisionSegmentedControl<T> extends StatelessWidget {
  const RevisionSegmentedControl({
    required this.values,
    required this.selected,
    required this.labelOf,
    required this.onChanged,
    super.key,
  });

  final List<T> values;
  final T selected;
  final String Function(T value) labelOf;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return RevisionGlassCard(
      padding: const EdgeInsets.all(RevisionSpacing.xxs),
      radius: RevisionRadius.radiusM,
      child: Row(
        children: [
          for (final value in values)
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onChanged(value),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(
                    vertical: RevisionSpacing.s,
                  ),
                  decoration: BoxDecoration(
                    gradient: value == selected
                        ? const LinearGradient(
                            colors: [
                              RevisionColors.blue,
                              RevisionColors.blueDeep,
                            ],
                          )
                        : null,
                    borderRadius: RevisionRadius.radiusS,
                  ),
                  child: Text(
                    labelOf(value),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: value == selected
                          ? RevisionColors.text
                          : RevisionColors.textMuted,
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                      letterSpacing: 0,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class RevisionStatTriplet extends StatelessWidget {
  const RevisionStatTriplet({required this.items, super.key});

  final List<RevisionStatItem> items;

  @override
  Widget build(BuildContext context) {
    return RevisionGlassCard(
      child: Row(
        children: [
          for (var index = 0; index < items.length; index++) ...[
            Expanded(child: _StatItemView(item: items[index])),
            if (index != items.length - 1)
              Container(width: 1, height: 44, color: RevisionColors.border),
          ],
        ],
      ),
    );
  }
}

class RevisionStatItem {
  const RevisionStatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;
}

class _StatItemView extends StatelessWidget {
  const _StatItemView({required this.item});

  final RevisionStatItem item;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(item.icon, color: item.color, size: 20),
        const SizedBox(height: RevisionSpacing.xs),
        Text(item.label, style: RevisionTypography.caption),
        const SizedBox(height: RevisionSpacing.xs),
        Text(
          item.value,
          textAlign: TextAlign.center,
          style: RevisionTypography.sectionTitle.copyWith(
            color: item.color,
            fontSize: 15,
          ),
        ),
      ],
    );
  }
}

class RevisionSectionHeader extends StatelessWidget {
  const RevisionSectionHeader({required this.title, this.subtitle, super.key});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: RevisionTypography.sectionTitle),
        if (subtitle != null) ...[
          const SizedBox(height: RevisionSpacing.xs),
          Text(subtitle!, style: RevisionTypography.body),
        ],
      ],
    );
  }
}

class RevisionFloatingAddButton extends StatelessWidget {
  const RevisionFloatingAddButton({required this.onTap, super.key});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Ajouter une source',
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 78,
          height: 78,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [RevisionColors.pink, RevisionColors.pinkDeep],
            ),
            border: Border.all(
              color: RevisionColors.pink.withValues(alpha: 0.55),
              width: 6,
            ),
            boxShadow: RevisionShadows.soft(RevisionColors.pink),
          ),
          child: const Icon(
            Icons.add_rounded,
            color: RevisionColors.text,
            size: 38,
          ),
        ),
      ),
    );
  }
}

class RevisionConfettiOverlay extends StatefulWidget {
  const RevisionConfettiOverlay({this.particleCount = 180, super.key});

  final int particleCount;

  @override
  State<RevisionConfettiOverlay> createState() =>
      _RevisionConfettiOverlayState();
}

class _RevisionConfettiOverlayState extends State<RevisionConfettiOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late List<_RevisionConfettiParticle> _particles;

  @override
  void initState() {
    super.initState();
    _particles = _buildRevisionConfettiParticles(widget.particleCount);
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 7600),
    )..forward();
  }

  @override
  void didUpdateWidget(covariant RevisionConfettiOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.particleCount != widget.particleCount) {
      _particles = _buildRevisionConfettiParticles(widget.particleCount);
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final animationsDisabled = MediaQuery.disableAnimationsOf(context);

    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          if (!animationsDisabled && _controller.isCompleted) {
            return child!;
          }

          return CustomPaint(
            painter: _RevisionConfettiOverlayPainter(
              progress: animationsDisabled ? 0.72 : _controller.value,
              particles: _particles,
            ),
            child: child,
          );
        },
        child: const SizedBox.expand(),
      ),
    );
  }
}

List<_RevisionConfettiParticle> _buildRevisionConfettiParticles(int count) {
  final random = math.Random(20260617);
  return List<_RevisionConfettiParticle>.generate(count, (index) {
    return _RevisionConfettiParticle(
      x: random.nextDouble(),
      start: random.nextDouble() * 0.42,
      yOffset: random.nextDouble() * 0.22,
      drift: (random.nextDouble() - 0.5) * 0.28,
      size: 3 + random.nextDouble() * 8,
      spin: random.nextDouble() * math.pi * 2,
      speed: 0.28 + random.nextDouble() * 0.42,
      colorIndex: random.nextInt(8),
      shapeIndex: random.nextInt(4),
    );
  });
}

class _RevisionConfettiParticle {
  const _RevisionConfettiParticle({
    required this.x,
    required this.start,
    required this.yOffset,
    required this.drift,
    required this.size,
    required this.spin,
    required this.speed,
    required this.colorIndex,
    required this.shapeIndex,
  });

  final double x;
  final double start;
  final double yOffset;
  final double drift;
  final double size;
  final double spin;
  final double speed;
  final int colorIndex;
  final int shapeIndex;
}

class _RevisionConfettiOverlayPainter extends CustomPainter {
  _RevisionConfettiOverlayPainter({
    required this.progress,
    required this.particles,
  });

  static const _strokeWidth = 3.0;
  static const _colors = [
    RevisionColors.blue,
    RevisionColors.cyan,
    RevisionColors.green,
    RevisionColors.amber,
    RevisionColors.pink,
    RevisionColors.violet,
    RevisionColors.mint,
    RevisionColors.coral,
  ];

  final double progress;
  final List<_RevisionConfettiParticle> particles;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty || particles.isEmpty) return;

    final paint = Paint()..strokeCap = StrokeCap.round;

    for (final particle in particles) {
      final phase = (progress * (0.55 + particle.speed) - particle.start).clamp(
        0.0,
        1.0,
      );
      final eased = Curves.easeInOutSine.transform(phase);
      final sway = math.sin((phase * math.pi * 3) + particle.spin);
      final x =
          (particle.x + particle.drift * eased + sway * 0.018) * size.width;
      final y =
          -size.height * (0.18 + particle.yOffset) +
          (size.height * (1.2 + particle.yOffset)) * eased;
      final rotation = particle.spin + phase * math.pi * 3.5;
      final introOpacity = (phase / 0.18).clamp(0.0, 1.0);
      final exitOpacity = (1 - ((phase - 0.88) / 0.12).clamp(0.0, 1.0));
      final opacity = introOpacity * exitOpacity * (0.62 + (1 - phase) * 0.24);

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(rotation);
      paint
        ..color = _colors[particle.colorIndex % _colors.length].withValues(
          alpha: opacity,
        )
        ..strokeWidth = _strokeWidth;
      _paintShape(canvas, paint, particle);
      canvas.restore();
    }
  }

  void _paintShape(
    Canvas canvas,
    Paint paint,
    _RevisionConfettiParticle particle,
  ) {
    final size = particle.size;

    switch (particle.shapeIndex) {
      case 0:
        paint.style = PaintingStyle.fill;
        canvas.drawCircle(Offset.zero, size * 0.45, paint);
        break;
      case 1:
        paint.style = PaintingStyle.fill;
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: Offset.zero,
              width: size * 0.72,
              height: size * 1.85,
            ),
            const Radius.circular(RevisionSpacing.xs),
          ),
          paint,
        );
        break;
      case 2:
        paint.style = PaintingStyle.stroke;
        canvas.drawLine(Offset(-size, 0), Offset(size, 0), paint);
        break;
      default:
        paint.style = PaintingStyle.fill;
        final path = Path()
          ..moveTo(0, -size)
          ..lineTo(size * 0.88, size * 0.72)
          ..lineTo(-size * 0.88, size * 0.72)
          ..close();
        canvas.drawPath(path, paint);
        break;
    }
  }

  @override
  bool shouldRepaint(covariant _RevisionConfettiOverlayPainter oldDelegate) {
    return progress != oldDelegate.progress ||
        particles != oldDelegate.particles;
  }
}

class RevisionConfettiStrip extends StatelessWidget {
  const RevisionConfettiStrip({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 120,
      child: RevisionConfettiOverlay(particleCount: 90),
    );
  }
}

````````

### `test/app/revision_app_test.dart`

````````dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:revision_app/app/app_root.dart';
import 'package:revision_app/app/di/providers.dart';
import 'package:revision_app/core/storage/kv_storage_port.dart';
import 'package:revision_app/features/activities/application/activity_controller.dart';
import 'package:revision_app/features/auth/application/auth_controller.dart';
import 'package:revision_app/features/auth/domain/auth_session.dart';
import 'package:revision_app/features/auth/domain/authenticated_user.dart';
import 'package:revision_app/features/courses/application/courses_providers.dart';
import 'package:revision_app/features/courses/domain/course_models.dart';
import 'package:revision_app/features/documents/application/documents_controller.dart';
import 'package:revision_app/features/onboarding/application/revision_goals_controller.dart';
import 'package:revision_app/features/subjects/application/subjects_controller.dart';
import 'package:revision_app/features/subjects/domain/subject.dart';
import 'package:revision_app/features/today/application/today_controller.dart';
import 'package:revision_app/presentation/widgets/revision_navigation.dart';

import '../fakes/in_memory_activity_api.dart';
import '../fakes/in_memory_courses_repository.dart';
import '../fakes/in_memory_documents_api.dart';
import '../fakes/in_memory_revision_goals_repository.dart';
import '../fakes/in_memory_subjects_repository.dart';
import '../fakes/in_memory_today_repository.dart';

class SignedInAuthRepository implements AuthRepository {
  @override
  Stream<AuthSession> watchSession() async* {
    yield const AuthSession.signedIn(
      AuthenticatedUser(
        uid: 'firebase-123',
        email: 'student@example.com',
        displayName: 'Karim',
      ),
    );
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

class SignedOutAuthRepository implements AuthRepository {
  @override
  Stream<AuthSession> watchSession() async* {
    yield const AuthSession.signedOut();
  }

  @override
  Future<String> requireIdToken() async {
    throw StateError('A signed-in user is required');
  }

  @override
  Future<void> signInWithApple() async {}

  @override
  Future<void> signInWithGoogle() async {}

  @override
  Future<void> signOut() async {}
}

class FakeKvStorage implements KvStoragePort {
  @override
  Future<String?> readString(String key) async => null;

  @override
  Future<void> writeString(String key, String value) async {}
}

void main() {
  testWidgets('shows a real-ready home without fixture courses', (
    tester,
  ) async {
    final testApp = _createTestApp();

    await tester.pumpWidget(testApp.widget);
    await tester.pumpAndSettle();

    expect(find.text('Accueil'), findsWidgets);
    expect(find.text('Commence par créer une matière.'), findsOneWidget);
    expect(find.text('Créer une matière'), findsOneWidget);
    expect(find.text('Math'), findsNothing);
    expect(find.text('Loi normale'), findsNothing);
    expect(find.text('78%'), findsNothing);
    expect(find.text('12'), findsNothing);
    expect(find.text('870'), findsNothing);
    expect(find.text('7 jours'), findsNothing);
    expect(find.text('Progrès'), findsOneWidget);
    expect(find.text('Réviser'), findsOneWidget);
    expect(find.text('Sources'), findsNothing);
    expect(find.byType(RevisionBottomNavigation), findsOneWidget);
    expect(testApp.authController.isSignedIn, isTrue);
  });

  testWidgets('bottom navigation opens honest real-ready pages', (
    tester,
  ) async {
    await tester.pumpWidget(_createTestApp().widget);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Progrès'));
    await tester.pumpAndSettle();

    expect(find.text('Aucune matière réelle'), findsOneWidget);
    expect(find.text('Progression réelle en attente'), findsNothing);
    expect(find.text('78%'), findsNothing);
    expect(find.textContaining('CORE-06 branchera'), findsNothing);

    await tester.tap(find.text('Réviser'));
    await tester.pumpAndSettle();

    expect(find.text('Réviser'), findsWidgets);
    expect(find.text('Choisis une session courte et utile.'), findsOneWidget);
    expect(find.text('Aucune matière disponible'), findsOneWidget);
    expect(find.textContaining('CORE-05 branchera'), findsNothing);
    expect(find.textContaining('à brancher en CORE-05'), findsNothing);
    expect(find.text('Sources'), findsNothing);
    expect(find.textContaining('CORE-03 branchera'), findsNothing);
    expect(find.text('Loi normale'), findsNothing);
  });

  testWidgets('home can list real subjects without inventing courses', (
    tester,
  ) async {
    await tester.pumpWidget(
      _createTestApp(
        seedSubjects: const [
          Subject(
            id: 'subject-real-1',
            name: 'Droit constitutionnel',
            priority: 4,
          ),
        ],
      ).widget,
    );
    await tester.pumpAndSettle();

    expect(find.text('Droit constitutionnel'), findsWidgets);
    expect(find.text('Aucun cours pour le moment'), findsOneWidget);
    expect(find.text('Loi normale'), findsNothing);
  });

  testWidgets('home can create and select a subject from the subject picker', (
    tester,
  ) async {
    final view = tester.view;
    view.devicePixelRatio = 1;
    view.physicalSize = const Size(430, 932);
    addTearDown(view.resetDevicePixelRatio);
    addTearDown(view.resetPhysicalSize);

    await tester.pumpWidget(
      _createTestApp(
        seedSubjects: const [
          Subject(id: 'subject-real-1', name: 'Droits', priority: 4),
        ],
      ).widget,
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Droits').first);
    await tester.pumpAndSettle();

    expect(find.text('Choisir une matière'), findsOneWidget);
    expect(find.text('Créer une matière'), findsOneWidget);

    await tester.tap(find.text('Créer une matière'));
    await tester.pumpAndSettle();

    expect(find.text('Créer une matière'), findsOneWidget);
    expect(find.text('Nom de la matière'), findsOneWidget);

    await tester.enterText(find.byType(TextField).last, 'Histoire');
    await tester.tap(find.text('Créer la matière'));
    await tester.pumpAndSettle();

    expect(find.text('Histoire'), findsWidgets);
    expect(find.text('Tes cours de Histoire'), findsOneWidget);
    expect(find.text('Aucun cours pour le moment'), findsOneWidget);
    expect(find.text('Loi normale'), findsNothing);
    expect(find.text('78%'), findsNothing);
  });

  testWidgets('home can list real courses for the active subject', (
    tester,
  ) async {
    final view = tester.view;
    view.devicePixelRatio = 1;
    view.physicalSize = const Size(430, 932);
    addTearDown(view.resetDevicePixelRatio);
    addTearDown(view.resetPhysicalSize);

    await tester.pumpWidget(
      _createTestApp(
        seedSubjects: const [
          Subject(
            id: 'subject-real-1',
            name: 'Droit constitutionnel',
            priority: 4,
          ),
        ],
        seedCourses: const [
          CourseListItem(
            id: 'course-real-1',
            subjectId: 'subject-real-1',
            title: 'Institutions de la Ve République',
            chapterLabel: 'Chapitre 2',
            estimatedMinutes: 35,
            sourceCount: 1,
            readySourceCount: 1,
            processingSourceCount: 0,
            failedSourceCount: 0,
          ),
        ],
      ).widget,
    );
    await tester.pumpAndSettle();

    expect(find.text('Institutions de la Ve République'), findsWidgets);
    expect(find.text('Chapitre 2 · 35 min'), findsOneWidget);
    expect(find.text('1 source · 1 prête'), findsWidgets);
    expect(find.text('Loi normale'), findsNothing);
  });

  testWidgets('home keeps its premium header fixed while course cards scroll', (
    tester,
  ) async {
    final view = tester.view;
    view.devicePixelRatio = 1;
    view.physicalSize = const Size(430, 932);
    addTearDown(view.resetDevicePixelRatio);
    addTearDown(view.resetPhysicalSize);

    final courses = List<CourseListItem>.generate(
      12,
      (index) => CourseListItem(
        id: 'course-real-${index + 1}',
        subjectId: 'subject-real-1',
        title: 'Cours ${index + 1}',
        chapterLabel: 'Chapitre ${index + 1}',
        estimatedMinutes: 20 + index,
        sourceCount: 1,
        readySourceCount: 1,
        processingSourceCount: 0,
        failedSourceCount: 0,
      ),
    );

    await tester.pumpWidget(
      _createTestApp(
        seedSubjects: const [
          Subject(id: 'subject-real-1', name: 'Droits', priority: 4),
        ],
        seedCourses: courses,
      ).widget,
    );
    await tester.pumpAndSettle();

    expect(find.text('Droits'), findsWidgets);
    expect(find.text('Continue ton progrès'), findsOneWidget);
    expect(find.text('Cours prêt à réviser'), findsOneWidget);
    expect(find.text('Reprendre le cours'), findsNothing);
    expect(find.text('Cours 12'), findsNothing);

    await tester.scrollUntilVisible(
      find.text('Cours 12'),
      600,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.pumpAndSettle();

    expect(find.text('Droits'), findsWidgets);
    expect(find.text('Continue ton progrès'), findsOneWidget);
    expect(find.text('Cours prêt à réviser'), findsOneWidget);
    expect(find.text('Reprendre le cours'), findsNothing);
    expect(find.text('Cours 12'), findsOneWidget);
  });

  testWidgets('home can create a real course and open its detail', (
    tester,
  ) async {
    final view = tester.view;
    view.devicePixelRatio = 1;
    view.physicalSize = const Size(430, 932);
    addTearDown(view.resetDevicePixelRatio);
    addTearDown(view.resetPhysicalSize);

    await tester.pumpWidget(
      _createTestApp(
        seedSubjects: const [
          Subject(
            id: 'subject-real-1',
            name: 'Droit constitutionnel',
            priority: 4,
          ),
        ],
      ).widget,
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(
      find.widgetWithText(FilledButton, 'Créer un cours'),
    );
    await tester.tap(
      find.widgetWithText(FilledButton, 'Créer un cours').hitTestable(),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, 'Droit administratif');
    await tester.tap(find.text('Créer le cours'));
    await tester.pumpAndSettle();

    expect(find.text('Droit administratif'), findsOneWidget);
    expect(find.text('Cours introuvable'), findsNothing);
    expect(find.text('Loi normale'), findsNothing);
  });

  testWidgets('course and result routes do not fallback to fixture data', (
    tester,
  ) async {
    await tester.pumpWidget(_createTestApp().widget);
    await tester.pumpAndSettle();

    final context = tester.element(find.byType(RevisionBottomNavigation));
    GoRouter.of(context).go('/courses/unknown');
    await tester.pumpAndSettle();

    expect(find.text('Cours introuvable'), findsOneWidget);
    expect(find.text('Loi normale'), findsNothing);

    GoRouter.of(context).go('/revision-sessions/fake/result');
    await tester.pumpAndSettle();

    expect(find.text('Impossible de charger le résultat'), findsOneWidget);
    expect(find.text('78%'), findsNothing);
    expect(find.text('4/5 bonnes'), findsNothing);
  });

  testWidgets('uses route-driven navigation rail on wide layouts', (
    tester,
  ) async {
    final view = tester.view;
    view.devicePixelRatio = 1;
    view.physicalSize = const Size(1200, 900);
    addTearDown(view.resetDevicePixelRatio);
    addTearDown(view.resetPhysicalSize);

    await tester.pumpWidget(_createTestApp().widget);
    await tester.pumpAndSettle();

    expect(find.byType(RevisionNavigationRail), findsOneWidget);
    expect(find.byType(RevisionBottomNavigation), findsNothing);

    await tester.tap(find.text('Réviser'));
    await tester.pumpAndSettle();

    expect(find.text('Réviser'), findsWidgets);
    expect(find.text('Choisis une session courte et utile.'), findsOneWidget);
    expect(find.text('Aucune matière disponible'), findsOneWidget);
    expect(find.textContaining('CORE-05 branchera'), findsNothing);
  });

  testWidgets('redirects signed-out users to the sign-in page', (tester) async {
    await tester.pumpWidget(
      _createTestApp(
        authController: AuthController(SignedOutAuthRepository()),
      ).widget,
    );
    await tester.pumpAndSettle();

    expect(find.text('Connexion'), findsOneWidget);
    expect(find.text('Continuer avec Google'), findsOneWidget);
    expect(find.text('Continuer avec Apple'), findsOneWidget);
  });
}

AuthController signedInAuthController() {
  return AuthController(SignedInAuthRepository());
}

_RevisionTestApp _createTestApp({
  AuthController? authController,
  List<Subject> seedSubjects = const [],
  List<CourseListItem> seedCourses = const [],
}) {
  final resolvedAuthController = authController ?? signedInAuthController();
  final subjectsRepository = InMemorySubjectsRepository();
  subjectsRepository.subjects.addAll(seedSubjects);
  final coursesRepository = InMemoryCoursesRepository();
  for (final course in seedCourses) {
    coursesRepository.coursesBySubject
        .putIfAbsent(course.subjectId, () => [])
        .add(course);
    coursesRepository.detailsByCourse[course.id] = CourseDetail(
      course: course,
      subject: CourseSubjectSummary(
        id: course.subjectId,
        name: _subjectNameFor(seedSubjects, course.subjectId),
      ),
      sources: const [],
    );
  }
  final revisionGoalsRepository = InMemoryRevisionGoalsRepository();
  final documentsApi = InMemoryDocumentsApi();
  final activityApi = InMemoryActivityApi();
  final todayRepository = InMemoryTodayRepository();

  resolvedAuthController.start();
  addTearDown(resolvedAuthController.dispose);

  final widget = ProviderScope(
    overrides: [
      kvStorageProvider.overrideWithValue(FakeKvStorage()),
      authControllerProvider.overrideWithValue(resolvedAuthController),
      subjectsRepositoryProvider.overrideWithValue(subjectsRepository),
      subjectsControllerProvider.overrideWithValue(
        SubjectsController(subjectsRepository),
      ),
      coursesRepositoryProvider.overrideWithValue(coursesRepository),
      revisionGoalsControllerProvider.overrideWithValue(
        RevisionGoalsController(revisionGoalsRepository),
      ),
      documentsControllerProvider.overrideWithValue(
        DocumentsController(documentsApi),
      ),
      documentsApiProvider.overrideWithValue(documentsApi),
      activityControllerProvider.overrideWithValue(
        ActivityController(activityApi),
      ),
      todayRepositoryProvider.overrideWithValue(todayRepository),
      todayControllerProvider.overrideWithValue(
        TodayController(todayRepository),
      ),
    ],
    child: const AppRoot(),
  );

  return _RevisionTestApp(
    widget: widget,
    authController: resolvedAuthController,
    revisionGoalsRepository: revisionGoalsRepository,
    activityApi: activityApi,
    todayRepository: todayRepository,
  );
}

String _subjectNameFor(List<Subject> subjects, String subjectId) {
  for (final subject in subjects) {
    if (subject.id == subjectId) {
      return subject.name;
    }
  }

  return 'Matière réelle';
}

class _RevisionTestApp {
  const _RevisionTestApp({
    required this.widget,
    required this.authController,
    required this.revisionGoalsRepository,
    required this.activityApi,
    required this.todayRepository,
  });

  final Widget widget;
  final AuthController authController;
  final InMemoryRevisionGoalsRepository revisionGoalsRepository;
  final InMemoryActivityApi activityApi;
  final InMemoryTodayRepository todayRepository;
}

````````

### `test/app/router/app_router_test.dart`

````````dart

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
import 'package:revision_app/presentation/design_system/components/revision_mvp_components.dart';
import 'package:revision_app/presentation/widgets/revision_button.dart';
import 'package:revision_app/presentation/widgets/revision_navigation.dart';

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

  test('shell keeps only primary destinations and sessions outside shell', () {
    final harness = _RouterHarness();
    addTearDown(harness.dispose);

    final shellRoute = harness.router.configuration.routes
        .whereType<StatefulShellRoute>()
        .single;
    final branchRoots = shellRoute.branches
        .map((branch) => branch.routes.whereType<GoRoute>().first.path)
        .toList(growable: false);
    final shellPaths = shellRoute.branches
        .expand((branch) => branch.routes.whereType<GoRoute>())
        .map((route) => route.path)
        .toSet();
    final topLevelPaths = harness.router.configuration.routes
        .whereType<GoRoute>()
        .map((route) => route.path)
        .toSet();

    expect(branchRoots, [
      AppRoutes.home,
      AppRoutes.progress,
      AppRoutes.revisions,
      AppRoutes.profile,
    ]);
    expect(shellPaths, isNot(contains(AppRoutes.sources)));
    expect(shellPaths, isNot(contains(AppRoutes.revisionSessionV2Path)));
    expect(shellPaths, isNot(contains(AppRoutes.revisionSessionResultV2Path)));
    expect(shellPaths, isNot(contains(AppRoutes.revisionSessionPath)));
    expect(shellPaths, isNot(contains(AppRoutes.richClosedExercisePath)));
    expect(topLevelPaths, contains(AppRoutes.sources));
    expect(topLevelPaths, contains(AppRoutes.revisionSessionV2Path));
    expect(topLevelPaths, contains(AppRoutes.revisionSessionResultV2Path));
    expect(topLevelPaths, contains(AppRoutes.revisionSessionPath));
    expect(topLevelPaths, contains(AppRoutes.richClosedExercisePath));
  });

  testWidgets('home route does not render MVP fixture course data', (
    tester,
  ) async {
    final harness = _RouterHarness();
    addTearDown(harness.dispose);

    await tester.pumpWidget(harness.buildApp());
    await tester.pumpAndSettle();

    expect(find.text('Accueil'), findsWidgets);
    expect(find.text('Commence par créer une matière.'), findsOneWidget);
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
    await tester.tap(find.widgetWithText(RevisionHeaderActionPill, 'Sources'));
    await tester.pumpAndSettle();
    expect(find.text('cours.pdf'), findsOneWidget);
    expect(find.text('Loi normale'), findsNothing);
  });

  testWidgets('course detail back pops to home without forward history', (
    tester,
  ) async {
    final harness = _RouterHarness();
    _seedReadyCourse(harness);
    addTearDown(harness.dispose);

    await tester.pumpWidget(harness.buildApp());
    await tester.pumpAndSettle();

    expect(
      harness.router.routeInformationProvider.value.uri.path,
      AppRoutes.home,
    );
    expect(harness.router.canPop(), isFalse);

    harness.router.push(AppRoutes.course('course-1'));
    await tester.pumpAndSettle();

    expect(
      find.widgetWithText(RevisionHeaderActionPill, 'Fiche'),
      findsOneWidget,
    );
    expect(harness.router.canPop(), isTrue);

    await tester.tap(find.byTooltip('Retour'));
    await tester.pumpAndSettle();

    expect(
      harness.router.routeInformationProvider.value.uri.path,
      AppRoutes.home,
    );
    expect(harness.router.canPop(), isFalse);
    expect(
      find.widgetWithText(RevisionHeaderActionPill, 'Fiche'),
      findsNothing,
    );
  });

  testWidgets('course sheet back pops to detail without duplicating home', (
    tester,
  ) async {
    final harness = _RouterHarness();
    _seedReadyCourse(harness);
    harness.coursesRepository.revisionSheetsByCourse['course-1'] =
        _revisionSheet();
    addTearDown(harness.dispose);

    await tester.pumpWidget(harness.buildApp());
    await tester.pumpAndSettle();

    harness.router.push(AppRoutes.course('course-1'));
    await tester.pumpAndSettle();
    harness.router.push(AppRoutes.courseSheet('course-1'));
    await tester.pumpAndSettle();

    expect(find.text('Fiche de cours'), findsWidgets);
    expect(harness.router.canPop(), isTrue);

    await tester.tap(find.byTooltip('Retour au cours'));
    await tester.pumpAndSettle();

    expect(
      find.widgetWithText(RevisionHeaderActionPill, 'Fiche'),
      findsOneWidget,
    );
    expect(harness.router.canPop(), isTrue);

    await tester.tap(find.byTooltip('Retour'));
    await tester.pumpAndSettle();

    expect(
      harness.router.routeInformationProvider.value.uri.path,
      AppRoutes.home,
    );
    expect(harness.router.canPop(), isFalse);
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

  testWidgets('revision session result route displays real backend result', (
    tester,
  ) async {
    final harness = _RouterHarness();
    addTearDown(harness.dispose);

    await tester.pumpWidget(harness.buildApp());
    harness.router.go(AppRoutes.revisionSessionResultV2(sessionId: 'fake'));
    await tester.pumpAndSettle();

    expect(find.text('Session terminée'), findsOneWidget);
    expect(find.text('4/6 bonnes réponses'), findsOneWidget);
    expect(find.byType(RevisionBottomNavigation), findsNothing);
    expect(find.byType(RevisionNavigationRail), findsNothing);
    expect(find.text('78%'), findsNothing);
    expect(find.text('4/5 bonnes'), findsNothing);
  });

  testWidgets(
    'revision session routes are immersive without shell navigation',
    (tester) async {
      final harness = _RouterHarness();
      addTearDown(harness.dispose);

      await tester.pumpWidget(harness.buildApp());
      harness.router.go(
        AppRoutes.revisionSession(sessionId: 'revision-session-1'),
      );
      await tester.pumpAndSettle();

      expect(find.text('Révision IA'), findsOneWidget);
      expect(find.byType(RevisionBottomNavigation), findsNothing);
      expect(find.byType(RevisionNavigationRail), findsNothing);

      harness.router.go(
        AppRoutes.richClosedExercise(
          subjectId: 'subject-1',
          knowledgeUnitId: 'unit-1',
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Questions riches'), findsOneWidget);
      expect(find.byType(RevisionBottomNavigation), findsNothing);
      expect(find.byType(RevisionNavigationRail), findsNothing);
    },
  );

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

    harness.router.go(AppRoutes.sources);
    await tester.pumpAndSettle();
    expect(find.text('Sources depuis les cours'), findsOneWidget);
    expect(find.byType(RevisionBottomNavigation), findsNothing);
    expect(find.byType(RevisionNavigationRail), findsNothing);
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

CourseListItem _seedReadyCourse(_RouterHarness harness) {
  harness.subjectsRepository.subjects.add(
    const Subject(id: 'subject-1', name: 'Droit constitutionnel', priority: 4),
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
  harness.coursesRepository.progressByCourse['course-1'] = const CourseProgress(
    courseId: 'course-1',
    subjectId: 'subject-1',
    coverage: 0,
    mastery: null,
    estimatedGlobalMastery: 0,
    knowledgeUnitCount: 3,
    practicedKnowledgeUnitCount: 0,
    readySourceCount: 1,
    processingSourceCount: 0,
    failedSourceCount: 0,
    state: CourseProgressState.readyNotPracticed,
  );
  harness.coursesRepository.progressBySubject['subject-1'] =
      const SubjectProgress(
        subjectId: 'subject-1',
        knowledgeUnitCount: 3,
        practicedKnowledgeUnitCount: 0,
        coverage: 0,
        mastery: null,
        estimatedGlobalMastery: 0,
        courseCount: 1,
        readyCourseCount: 1,
        courses: [
          SubjectCourseProgressItem(
            courseId: 'course-1',
            title: 'Institutions de la Ve République',
            knowledgeUnitCount: 3,
            practicedKnowledgeUnitCount: 0,
            coverage: 0,
            mastery: null,
            estimatedGlobalMastery: 0,
            state: CourseProgressState.readyNotPracticed,
          ),
        ],
      );

  return course;
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

````````

### `test/features/courses/course_detail_page_test.dart`

````````dart

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:revision_app/app/router/app_routes.dart';
import 'package:revision_app/features/courses/application/course_pdf_picker.dart';
import 'package:revision_app/features/courses/application/courses_providers.dart';
import 'package:revision_app/features/courses/domain/course_models.dart';
import 'package:revision_app/features/courses/domain/courses_repository.dart';
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
            errorCode: 'PDF_PARSE_FAILED',
          ),
        ],
      );

    await tester.pumpWidget(
      testApp(repository: repository, picker: FakeCoursePdfPicker(null)),
    );
    await tester.pumpAndSettle();

    await openSourcesSheet(tester);
    expect(find.text('broken.pdf'), findsOneWidget);
    expect(find.textContaining('Erreur'), findsOneWidget);
    expect(find.textContaining('PDF_PARSE_FAILED'), findsOneWidget);
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

    await tester.tap(find.byTooltip('Supprimer la source cours.pdf'));
    await tester.pumpAndSettle();

    expect(find.text('Supprimer cette source ?'), findsOneWidget);

    await tester.tap(find.widgetWithText(TextButton, 'Supprimer'));
    await tester.pumpAndSettle();

    expect(repository.deleteDocumentCount, 1);
    expect(repository.lastDeletedDocumentId, 'document-1');
    expect(find.text('Source supprimée'), findsOneWidget);
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
    await tester.tap(find.byTooltip('Supprimer la source cours.pdf'));
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
    expect(find.text('Commencer une session rapide'), findsOneWidget);

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
      find.text('Choisis le nombre de questions pour cette session.'),
      findsOneWidget,
    );
    await tester.tap(find.text('20 questions'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Démarrer'));
    await tester.pump();

    expect(find.text('Préparation des questions'), findsOneWidget);
    expect(
      find.text('20 questions sont chargées depuis la banque du cours.'),
      findsOneWidget,
    );
    expect(find.text('Démarrage...'), findsOneWidget);

    await tester.pumpAndSettle();

    expect(repository.startQuickRevisionCount, 1);
    expect(repository.lastQuickRevisionCourseId, 'course-1');
    expect(repository.lastQuickRevisionQuestionCount, 20);
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

class FakeCoursePdfPicker implements CoursePdfPicker {
  FakeCoursePdfPicker(this.result);

  final PickedCoursePdf? result;

  @override
  Future<PickedCoursePdf?> pickPdf() async => result;
}

````````

### `test/features/courses/revisions_pending_page_test.dart`

````````dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:revision_app/app/di/providers.dart';
import 'package:revision_app/app/router/app_routes.dart';
import 'package:revision_app/features/courses/application/courses_providers.dart';
import 'package:revision_app/features/courses/domain/course_models.dart';
import 'package:revision_app/features/courses/presentation/revisions_pending_page.dart';
import 'package:revision_app/features/subjects/domain/subject.dart';

import '../../fakes/in_memory_courses_repository.dart';
import '../../fakes/in_memory_subjects_repository.dart';

void main() {
  testWidgets('revision hub stays actionable when no course is ready', (
    tester,
  ) async {
    final coursesRepository = InMemoryCoursesRepository()
      ..coursesBySubject['subject-1'] = const [
        CourseListItem(
          id: 'course-1',
          subjectId: 'subject-1',
          title: 'Cours sans source prête',
          sourceCount: 1,
          processingSourceCount: 1,
        ),
      ];

    await tester.pumpWidget(
      revisionHubTestApp(coursesRepository: coursesRepository),
    );
    await tester.pumpAndSettle();

    expect(find.text('Réviser'), findsWidgets);
    expect(find.text('Choisis une session courte et utile.'), findsOneWidget);
    expect(find.text('Préparer un cours'), findsOneWidget);
    expect(find.text('Commencer 5 questions'), findsNothing);
    expect(find.textContaining('MVP+'), findsNothing);
    expect(find.textContaining('backend'), findsNothing);
    expect(find.textContaining('payload'), findsNothing);
  });

  testWidgets('revision hub starts quick revision directly with 5 questions', (
    tester,
  ) async {
    final coursesRepository = InMemoryCoursesRepository()
      ..coursesBySubject['subject-1'] = const [
        CourseListItem(
          id: 'course-1',
          subjectId: 'subject-1',
          title: 'Institutions',
          sourceCount: 1,
          readySourceCount: 1,
        ),
      ]
      ..detailsByCourse['course-1'] = const CourseDetail(
        course: CourseListItem(
          id: 'course-1',
          subjectId: 'subject-1',
          title: 'Institutions',
          sourceCount: 1,
          readySourceCount: 1,
        ),
        subject: CourseSubjectSummary(id: 'subject-1', name: 'Droits'),
        sources: [
          CourseDocument(
            id: 'source-1',
            courseId: 'course-1',
            documentId: 'document-1',
            fileName: 'cours.pdf',
            status: CourseDocumentStatus.ready,
          ),
        ],
      );

    await tester.pumpWidget(
      revisionHubTestApp(coursesRepository: coursesRepository),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Commencer 5 questions').first);
    await tester.pumpAndSettle();

    expect(coursesRepository.startQuickRevisionCount, 1);
    expect(coursesRepository.lastQuickRevisionCourseId, 'course-1');
    expect(coursesRepository.lastQuickRevisionQuestionCount, 5);
    expect(find.text('Session démarrée'), findsOneWidget);
  });
}

Widget revisionHubTestApp({
  required InMemoryCoursesRepository coursesRepository,
}) {
  final subjectsRepository = InMemorySubjectsRepository()
    ..subjects.add(const Subject(id: 'subject-1', name: 'Droits', priority: 3));

  final router = GoRouter(
    initialLocation: AppRoutes.revisions,
    routes: [
      GoRoute(
        path: AppRoutes.revisions,
        builder: (context, state) => const RevisionsPendingPage(),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const Text('Accueil'),
      ),
      GoRoute(
        path: AppRoutes.coursePath,
        builder: (context, state) =>
            Text('Cours ${state.pathParameters['courseId']}'),
      ),
      GoRoute(
        path: AppRoutes.revisionSessionV2Path,
        builder: (context, state) => const Text('Session démarrée'),
      ),
    ],
  );

  return ProviderScope(
    overrides: [
      subjectsRepositoryProvider.overrideWithValue(subjectsRepository),
      coursesRepositoryProvider.overrideWithValue(coursesRepository),
    ],
    child: MaterialApp.router(routerConfig: router),
  );
}

````````
