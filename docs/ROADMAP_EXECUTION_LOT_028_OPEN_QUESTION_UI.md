# LOT-028 — UI question ouverte corrigée

## 1. Résultat

LOT-028 ajoute le support Flutter natif de la question ouverte corrigée : modèles domaine, parsing HTTP, API de démarrage/soumission, fake/demo API, controller dédié, page native, entrée depuis une notion extraite, gestion READY/FAILED, anti-fuite pré-submit et tests. Aucun backend, Prisma, Genkit, GenUI, TodayPlan ou dépendance n’a été modifié.

## 2. Sources inspectées

- `docs/ROADMAP.md`
- `docs/ROADMAP_EXECUTION_PLAN.md`
- `docs/ROADMAP_EXECUTION_LOT_025E_QCM_MEDIA_MULTI_UI.md`
- `docs/ROADMAP_EXECUTION_LOT_026_OPEN_QUESTION_CONTRACT.md`
- `docs/ROADMAP_EXECUTION_LOT_027_OPEN_QUESTION_GENKIT_CORRECTION.md`
- `docs/ROADMAP_EXECUTION_HOTFIX_027B_OPEN_ANSWER_ERROR_PATH.md`
- `docs/ROADMAP_EXECUTION_LOT_030_GENUI_ACTIVITY_CORRECTION.md`
- `AGENTS.md`
- `codex_rule.md`
- `lib/features/activities/domain/diagnostic_quiz_activity.dart`
- `lib/features/activities/application/activity_controller.dart`
- `lib/features/activities/data/activities_api.dart`
- `lib/features/activities/data/http_activities_api.dart`
- `lib/features/activities/data/demo_activity_api.dart`
- `lib/presentation/pages/activities/activities_page.dart`
- `lib/presentation/pages/activities/diagnostic_quiz_page.dart`
- `lib/presentation/widgets/revision_choice_tile.dart`
- `lib/presentation/widgets/revision_panel.dart`
- `lib/presentation/widgets/documents/document_source_excerpt.dart`
- `lib/app/di/**`
- `lib/app/router/**`
- `test/features/activities/**`
- `test/fakes/in_memory_activity_api.dart`
- `api/src/modules/activities/interfaces/activities.controller.ts` en lecture seule
- `api/src/modules/activities/application/activities.repository.ts` en lecture seule
- `api/src/modules/activities/application/open-answer-evaluator.ts` en lecture seule
- `api/src/modules/activities/application/start-open-question-activity.use-case.ts` en lecture seule
- `api/src/modules/activities/application/submit-open-answer.use-case.ts` en lecture seule
- `api/src/modules/activities/infrastructure/prisma-activities.repository.ts` en lecture seule

## 3. Préflight Git

API initial : branche `main`, `## main...origin/main`, aucun fichier modifié/non suivi. Derniers commits : `0cf3f17`, `ba5daba`, `93dad71`, `02d3e57`, `1fc13d5`.

Frontend initial : branche `main`, `## main...origin/main`, aucun fichier modifié/non suivi au début du lot. Derniers commits : `513b4f0`, `5304d61`, `a208a72`, `ce4cc5b`, `769c73a`.

Les modifications existantes étaient compatibles : aucun fichier utilisateur hors scope n’était présent au début du lot.

## 4. Périmètre réalisé

- Ajout du modèle Flutter `OpenQuestionActivity` et de ses objets liés.
- Ajout des méthodes `startOpenQuestion` et `submitOpenAnswer` au contrat applicatif.
- Implémentation HTTP des endpoints `/activities/open-question` et `/activities/:sessionId/open-answer`.
- Ajout d’un `OpenQuestionSessionController` dédié.
- Ajout d’une page native `OpenQuestionPage`.
- Ajout d’une entrée depuis les notions extraites du détail document.
- Conservation du QCM natif et du catalogue GenUI existant.
- Mise à jour des fakes et tests.

## 5. Décisions d’architecture Flutter

Le support question ouverte est séparé du modèle QCM pour éviter de mélanger les contrats. Le controller dédié porte l’état de réponse longue, la validation UI, la soumission et le résultat. La page native reste un fallback produit stable et ne dépend pas de GenUI.

Le routeur existant lit désormais optionnellement `knowledgeUnitId` pour permettre une entrée produit depuis une notion sans créer de nouvelle route. Cette modification est minimale et nécessaire pour rendre l’activité lançable sans inventer un sélecteur de notion hors scope.

## 6. Modèles Flutter ajoutés/modifiés

`open_question_activity.dart` ajoute : `OpenQuestionActivity`, `OpenQuestion`, `OpenQuestionSource`, `OpenAnswerSubmissionResult`, `OpenAnswerEvaluationStatus`, `OpenAnswerEvaluation`, `OpenAnswerCorrectionSource`. Les listes nulles sont traitées côté data layer comme des listes vides. Les champs de correction sont uniquement dans le résultat de soumission.

## 7. Data layer HTTP

`HttpActivitiesApi` consomme :

- `POST /activities/open-question` avec `subjectId` et `knowledgeUnitId`;
- `POST /activities/:sessionId/open-answer` avec `answerText`.

Le parsing rejette un type inattendu, ignore le texte source s’il apparaît par erreur en pré-submit, parse `PENDING`, `READY`, `FAILED`, et ne calcule ni score ni correction.

## 8. Fake/demo API

`DemoActivityApi` et `InMemoryActivityApi` implémentent les méthodes open question pour les tests et la démo locale. Le fake permet de vérifier le démarrage, la soumission READY/FAILED, les erreurs réseau, la conservation de réponse et le double submit UI.

## 9. Controller/state

`OpenQuestionSessionController` expose : activité, réponse courante, résultat, erreur UI, état de soumission et `canSubmit`. Il bloque les réponses vides/trop courtes, les réponses trop longues, le double submit pendant `submitting`, et conserve la réponse saisie en cas d’erreur.

## 10. UI native question ouverte

`OpenQuestionPage` affiche avant submit le prompt, les instructions, les références sources sans texte complet, le champ de réponse long, le compteur caractères et le bouton de validation. Après submit READY, elle affiche score, feedback, points présents, points manquants, erreurs, réponse modèle, conseil et sources textuelles backend. Après submit FAILED, elle affiche un message propre sans champs null.

## 11. Gestion READY/FAILED

READY affiche uniquement les champs fournis par le backend. FAILED affiche `La correction n'a pas pu être générée.` et les codes techniques bornés si présents. Aucun score ou feedback n’est inventé côté frontend.

## 12. Gestion du cas HOTFIX-027B : correction possiblement créée mais endpoint en erreur

En cas d’erreur de soumission réseau/API après tentative, l’UI conserve la réponse saisie et affiche un message générique : `Impossible de récupérer la correction. La correction a peut-être été enregistrée. Réessaie dans un instant.` Aucune correction n’est inventée. Le rechargement d’une correction déjà créée reste limité par l’absence d’endpoint frontend dédié dans le contrat actuel.

## 13. Anti-fuite frontend

- Pas de correction affichée avant submit.
- Pas de score calculé côté Flutter.
- Pas de feedback, réponse modèle, conseil, points présents/manquants avant submit.
- Les sources pré-submit affichent seulement chunk/page/index, jamais `text`.
- Les sources post-submit affichent seulement le texte borné reçu du backend.
- Aucun payload GenUI créé ou stocké.

## 14. Tests créés ou modifiés

- `test/features/activities/http_activities_api_test.dart` : parsing start/READY/FAILED, listes nulles, type invalide, routes/payloads.
- `test/features/activities/activity_controller_test.dart` : start, validation, READY, FAILED, erreur réseau, double submit.
- `test/features/activities/open_question_page_test.dart` : pré-submit anti-fuite, compteur, disabled, loading, READY, FAILED, erreur, overflow.
- `test/features/documents/document_detail_page_test.dart` : entrée question ouverte depuis une notion.
- `test/fakes/in_memory_activity_api.dart` : fake open question.

## 15. Validations lancées avec résultats

- `dart analyze lib test` : OK, `No issues found!`
- `flutter test test/features/activities --reporter compact` : OK, `All tests passed!`
- `flutter test test/features/activities test/features/documents/document_detail_page_test.dart --reporter compact` : OK, `All tests passed!`
- `flutter test --reporter compact` : OK, `All tests passed!`
- `git diff --check` dans `revision_app` : OK après génération du rapport.
- `git diff --check` dans `api` : OK.

## 16. Validations non lancées avec justification

- Tests backend : non lancés, aucun fichier `api/**` modifié.
- Migrations/Prisma : non lancées, hors scope frontend et interdites.
- Provider IA réel : non lancé.
- Déploiement : non lancé.
- `flutter pub upgrade`, `dart fix --apply`, formatage global : non lancés conformément aux consignes.

## 17. Risques restants

- L’UI démarre la question ouverte depuis une notion extraite ; une UX plus riche de sélection de notion depuis la page Activités pourrait être ajoutée plus tard.
- Si le backend crée une correction puis échoue après coup, l’absence d’endpoint de reload de correction limite la récupération automatique.
- Les vrais contenus longs doivent rester à valider sur device physique, même si les tests widget couvrent l’absence d’overflow standard.
- Pas de GenUI question ouverte dans ce lot.

## 18. Recommandation prochain lot

Le prochain lot logique est soit `LOT-029B/UX` pour affiner l’entrée produit de sélection de notion si nécessaire, soit `LOT-031 — session coach` selon la roadmap. Les composants GenUI question ouverte peuvent venir après stabilité native et contrat de reload éventuel.

## 19. Passes de review

- Passe contrat backend : endpoints et DTOs consommés sans changer l’API.
- Passe data layer : parsing READY/FAILED et null-safety.
- Passe anti-fuite : aucune correction pré-submit et sources textuelles post-submit uniquement.
- Passe UI : états loading/submitting/error/READY/FAILED.
- Passe non-régression : QCM et GenUI existants verts.
- Passe critique : entrée produit minimale via notion, pas de sélection de notion globale.

## 20. Code complet créé/modifié/supprimé pour review

Aucun fichier supprimé. Le présent rapport est un fichier créé ; son contenu complet est ce document. Les autres fichiers créés/modifiés sont reproduits intégralement ci-dessous.

### Modifié — `lib/app/router/app_router.dart`

````dart
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/activities/application/activity_controller.dart';
import '../../features/auth/application/auth_controller.dart';
import '../../features/documents/application/documents_controller.dart';
import '../../features/onboarding/application/revision_goals_controller.dart';
import '../../features/subjects/application/subjects_controller.dart';
import '../../features/subjects/application/subjects_notifier.dart';
import '../../features/today/application/today_controller.dart';
import '../../presentation/pages/activities/activities_page.dart';
import '../../presentation/pages/auth/sign_in_page.dart';
import '../../presentation/pages/onboarding/onboarding_page.dart';
import '../../presentation/pages/profile/profile_page.dart';
import '../../presentation/pages/documents/document_detail_page.dart';
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
  required TodayController todayController,
  VoidCallback? onSubjectCreated,
}) {
  return GoRouter(
    initialLocation: AppRoutes.subjects,
    refreshListenable: authController,
    redirect: (context, state) {
      return executeRevisionRedirect(authController, state);
    },
    routes: [
      GoRoute(
        path: AppRoutes.root,
        redirect: (context, state) => AppRoutes.subjects,
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
                          documentId:
                              state.pathParameters['documentId'] ?? '',
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
                path: AppRoutes.today,
                builder: (context, state) => const TodayPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.activities,
                builder: (context, state) => ActivitiesPage(
                  controller: activityController,
                  subjectId: state.uri.queryParameters['subjectId'],
                  knowledgeUnitId: state.uri.queryParameters['knowledgeUnitId'],
                ),
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
    return AppRoutes.subjects;
  }

  return null;
}

````

### Créé — `lib/features/activities/domain/open_question_activity.dart`

````dart
class OpenQuestionActivity {
  const OpenQuestionActivity({
    required this.sessionId,
    required this.type,
    required this.version,
    required this.subjectId,
    required this.documentId,
    required this.knowledgeUnitId,
    required this.question,
  });

  final String sessionId;
  final String type;
  final int? version;
  final String subjectId;
  final String? documentId;
  final String knowledgeUnitId;
  final OpenQuestion question;
}

class OpenQuestion {
  const OpenQuestion({
    required this.id,
    required this.prompt,
    required this.instructions,
    required this.maxAnswerLength,
    this.sources = const [],
  });

  final String id;
  final String prompt;
  final String? instructions;
  final int maxAnswerLength;
  final List<OpenQuestionSource> sources;
}

class OpenQuestionSource {
  const OpenQuestionSource({
    required this.chunkId,
    required this.pageNumber,
    required this.index,
  });

  final String chunkId;
  final int? pageNumber;
  final int index;
}

class OpenAnswerSubmissionResult {
  const OpenAnswerSubmissionResult({
    required this.sessionId,
    required this.type,
    required this.status,
    required this.evaluation,
  });

  final String sessionId;
  final String type;
  final String status;
  final OpenAnswerEvaluation evaluation;
}

enum OpenAnswerEvaluationStatus { pending, ready, failed }

class OpenAnswerEvaluation {
  const OpenAnswerEvaluation({
    required this.id,
    required this.status,
    required this.score,
    required this.maxScore,
    required this.feedback,
    required this.modelAnswer,
    required this.advice,
    this.presentPoints = const [],
    this.missingPoints = const [],
    this.errors = const [],
    this.sources = const [],
  });

  final String id;
  final OpenAnswerEvaluationStatus status;
  final double? score;
  final double? maxScore;
  final String? feedback;
  final List<String> presentPoints;
  final List<String> missingPoints;
  final List<String> errors;
  final String? modelAnswer;
  final String? advice;
  final List<OpenAnswerCorrectionSource> sources;
}

class OpenAnswerCorrectionSource {
  const OpenAnswerCorrectionSource({
    required this.chunkId,
    required this.text,
    required this.pageNumber,
    required this.index,
  });

  final String chunkId;
  final String text;
  final int? pageNumber;
  final int index;
}

````

### Modifié — `lib/features/activities/application/activity_controller.dart`

````dart
import '../domain/diagnostic_quiz_activity.dart';
import '../domain/open_question_activity.dart';

typedef DiagnosticQuizSubmitter =
    Future<DiagnosticQuizResult> Function(List<DiagnosticQuizAnswer> answers);
typedef OpenAnswerSubmitter =
    Future<OpenAnswerSubmissionResult> Function(String answerText);

const openQuestionMinAnswerLength = 12;

abstract interface class ActivityApi {
  Future<DiagnosticQuizActivity> startNextActivity({
    required String subjectId,
    String? knowledgeUnitId,
  });

  Future<DiagnosticQuizResult> submitResult({
    required String sessionId,
    required List<DiagnosticQuizAnswer> answers,
  });

  Future<OpenQuestionActivity> startOpenQuestion({
    required String subjectId,
    required String knowledgeUnitId,
  });

  Future<OpenAnswerSubmissionResult> submitOpenAnswer({
    required String sessionId,
    required String answerText,
  });
}

class ActivityController {
  const ActivityController(this._api);

  final ActivityApi _api;

  Future<DiagnosticQuizActivity> startNextActivity({
    required String subjectId,
    String? knowledgeUnitId,
  }) {
    final trimmedSubjectId = subjectId.trim();

    if (trimmedSubjectId.isEmpty) {
      throw ArgumentError('Subject id is required');
    }

    return _api.startNextActivity(
      subjectId: trimmedSubjectId,
      knowledgeUnitId: knowledgeUnitId,
    );
  }

  Future<DiagnosticQuizResult> submitResult({
    required String sessionId,
    required List<DiagnosticQuizAnswer> answers,
  }) {
    if (answers.isEmpty) {
      throw ArgumentError('At least one answer is required');
    }

    return _api.submitResult(sessionId: sessionId, answers: answers);
  }

  Future<OpenQuestionActivity> startOpenQuestion({
    required String subjectId,
    required String knowledgeUnitId,
  }) {
    final trimmedSubjectId = subjectId.trim();
    final trimmedKnowledgeUnitId = knowledgeUnitId.trim();

    if (trimmedSubjectId.isEmpty) {
      throw ArgumentError('Subject id is required');
    }

    if (trimmedKnowledgeUnitId.isEmpty) {
      throw ArgumentError('Knowledge unit id is required');
    }

    return _api.startOpenQuestion(
      subjectId: trimmedSubjectId,
      knowledgeUnitId: trimmedKnowledgeUnitId,
    );
  }

  Future<OpenAnswerSubmissionResult> submitOpenAnswer({
    required String sessionId,
    required String answerText,
  }) {
    final trimmedSessionId = sessionId.trim();
    final trimmedAnswerText = answerText.trim();

    if (trimmedSessionId.isEmpty) {
      throw ArgumentError('Activity session id is required');
    }

    if (trimmedAnswerText.isEmpty) {
      throw ArgumentError('Open answer text is required');
    }

    return _api.submitOpenAnswer(
      sessionId: trimmedSessionId,
      answerText: trimmedAnswerText,
    );
  }
}

class OpenQuestionSessionController {
  OpenQuestionSessionController({required this.activity, this.submitter});

  final OpenQuestionActivity activity;
  final OpenAnswerSubmitter? submitter;

  String _answerText = '';
  OpenAnswerSubmissionResult? _result;
  Object? _submitError;
  bool _isSubmitting = false;
  Future<void>? _activeSubmit;

  String get answerText => _answerText;
  OpenAnswerSubmissionResult? get result => _result;
  Object? get submitError => _submitError;
  bool get isSubmitting => _isSubmitting;
  bool get hasCorrection => _result != null;

  bool get canSubmit {
    return submitter != null &&
        !_isSubmitting &&
        _result == null &&
        validationMessage == null;
  }

  String? get validationMessage {
    final trimmedAnswer = _answerText.trim();

    if (trimmedAnswer.length < openQuestionMinAnswerLength) {
      return 'Réponse trop courte';
    }

    if (trimmedAnswer.length > activity.question.maxAnswerLength) {
      return 'Réponse trop longue';
    }

    return null;
  }

  String? get submitErrorMessage {
    if (_submitError == null) {
      return null;
    }

    return 'Impossible de récupérer la correction. La correction a peut-être été enregistrée. Réessaie dans un instant.';
  }

  void updateAnswer(String answerText) {
    if (_result != null || _isSubmitting) {
      return;
    }

    _answerText = answerText;
    _submitError = null;
  }

  Future<void> submit() {
    final activeSubmit = _activeSubmit;
    if (activeSubmit != null) {
      return activeSubmit;
    }

    if (!canSubmit) {
      return Future.value();
    }

    _isSubmitting = true;
    _submitError = null;

    final future = _submitAnswer();
    _activeSubmit = future;

    return future;
  }

  Future<void> _submitAnswer() async {
    try {
      _result = await submitter!(_answerText.trim());
    } catch (error) {
      _submitError = error;
    } finally {
      _isSubmitting = false;
      _activeSubmit = null;
    }
  }
}

class DiagnosticQuizSessionController {
  DiagnosticQuizSessionController({required this.activity, this.submitter});

  final DiagnosticQuizActivity activity;
  final DiagnosticQuizSubmitter? submitter;
  final Map<String, Set<String>> _selectedChoiceIdsByQuestion = {};

  DiagnosticQuizResult? _result;
  Object? _submitError;
  bool _isSubmitting = false;
  Future<void>? _activeSubmit;

  DiagnosticQuizResult? get result => _result;
  Object? get submitError => _submitError;
  bool get isSubmitting => _isSubmitting;
  int get answeredCount => activity.questions
      .where((question) => _isQuestionComplete(question))
      .length;
  bool get hasCorrection => _result != null;

  bool get canSubmit {
    return submitter != null &&
        !_isSubmitting &&
        _result == null &&
        activity.questions.isNotEmpty &&
        activity.questions.every(_isQuestionComplete);
  }

  String? selectedChoiceIdFor(String questionId) {
    final selectedChoiceIds = selectedChoiceIdsFor(questionId);
    return selectedChoiceIds.isEmpty ? null : selectedChoiceIds.first;
  }

  List<String> selectedChoiceIdsFor(String questionId) {
    final selectedChoiceIds = _selectedChoiceIdsByQuestion[questionId];
    if (selectedChoiceIds == null || selectedChoiceIds.isEmpty) {
      return const [];
    }

    final question = _questionById(questionId);
    if (question == null) {
      return selectedChoiceIds.toList(growable: false);
    }

    return question.choices
        .where((choice) => selectedChoiceIds.contains(choice.id))
        .map((choice) => choice.id)
        .toList(growable: false);
  }

  void selectChoice({required String questionId, required String choiceId}) {
    if (_result != null || _isSubmitting) {
      return;
    }

    final question = _questionById(questionId);
    if (question == null) {
      return;
    }

    if (!question.choices.any((choice) => choice.id == choiceId)) {
      return;
    }

    if (question.selectionMode == DiagnosticQuizSelectionMode.multiple) {
      _toggleMultipleChoice(question: question, choiceId: choiceId);
    } else {
      _selectedChoiceIdsByQuestion[questionId] = {choiceId};
    }

    _submitError = null;
  }

  Future<void> submit() {
    final activeSubmit = _activeSubmit;
    if (activeSubmit != null) {
      return activeSubmit;
    }

    if (!canSubmit) {
      return Future.value();
    }

    _isSubmitting = true;
    _submitError = null;

    final future = _submitSelectedAnswers();
    _activeSubmit = future;

    return future;
  }

  Future<void> _submitSelectedAnswers() async {
    try {
      final result = await submitter!(
        activity.questions
            .map((question) => _answerForQuestion(question))
            .toList(growable: false),
      );
      _result = result;
    } catch (error) {
      _submitError = error;
    } finally {
      _isSubmitting = false;
      _activeSubmit = null;
    }
  }

  void _toggleMultipleChoice({
    required DiagnosticQuizQuestion question,
    required String choiceId,
  }) {
    final selectedChoiceIds = {...?_selectedChoiceIdsByQuestion[question.id]};

    if (selectedChoiceIds.contains(choiceId)) {
      selectedChoiceIds.remove(choiceId);
    } else if (selectedChoiceIds.length < question.maxSelections) {
      selectedChoiceIds.add(choiceId);
    }

    if (selectedChoiceIds.isEmpty) {
      _selectedChoiceIdsByQuestion.remove(question.id);
      return;
    }

    _selectedChoiceIdsByQuestion[question.id] = selectedChoiceIds;
  }

  bool _isQuestionComplete(DiagnosticQuizQuestion question) {
    final selectedChoiceIds = _selectedChoiceIdsByQuestion[question.id];
    if (selectedChoiceIds == null) {
      return false;
    }

    if (question.selectionMode == DiagnosticQuizSelectionMode.multiple) {
      return selectedChoiceIds.length >= question.minSelections &&
          selectedChoiceIds.length <= question.maxSelections;
    }

    return selectedChoiceIds.length == 1;
  }

  DiagnosticQuizAnswer _answerForQuestion(DiagnosticQuizQuestion question) {
    final selectedChoiceIds = selectedChoiceIdsFor(question.id);

    if (question.selectionMode == DiagnosticQuizSelectionMode.multiple) {
      return DiagnosticQuizAnswer(
        questionId: question.id,
        choiceIds: selectedChoiceIds,
      );
    }

    return DiagnosticQuizAnswer(
      questionId: question.id,
      choiceId: selectedChoiceIds.first,
    );
  }

  DiagnosticQuizQuestion? _questionById(String questionId) {
    for (final question in activity.questions) {
      if (question.id == questionId) {
        return question;
      }
    }

    return null;
  }
}

````

### Modifié — `lib/features/activities/data/http_activities_api.dart`

````dart
import 'package:dio/dio.dart';

import '../application/activity_controller.dart';
import '../domain/diagnostic_quiz_activity.dart';
import '../domain/open_question_activity.dart';

class HttpActivitiesApi implements ActivityApi {
  HttpActivitiesApi({
    required Dio dio,
    required Future<String> Function() getIdToken,
  }) : this._(dio, getIdToken);

  const HttpActivitiesApi._(this._dio, this._getIdToken);

  final Dio _dio;
  final Future<String> Function() _getIdToken;

  @override
  Future<DiagnosticQuizActivity> startNextActivity({
    required String subjectId,
    String? knowledgeUnitId,
  }) async {
    final data = <String, Object>{
      'subjectId': subjectId,
      'selectionModes': ['single', 'multiple'],
      'visualsEnabled': true,
      'visualTypes': ['CHART', 'DIAGRAM'],
    };
    if (knowledgeUnitId != null) {
      data['knowledgeUnitId'] = knowledgeUnitId;
    }

    final response = await _dio.post<Object?>(
      '/activities/next',
      data: data,
      options: await _authorizedOptions(),
    );

    return _ActivityJson(response.data).toActivity();
  }

  @override
  Future<DiagnosticQuizResult> submitResult({
    required String sessionId,
    required List<DiagnosticQuizAnswer> answers,
  }) async {
    final response = await _dio.post<Object?>(
      '/activities/$sessionId/result',
      data: {
        'answers': [for (final answer in answers) _AnswerJson(answer).toJson()],
      },
      options: await _authorizedOptions(),
    );

    return _ResultJson(response.data).toResult();
  }

  @override
  Future<OpenQuestionActivity> startOpenQuestion({
    required String subjectId,
    required String knowledgeUnitId,
  }) async {
    final response = await _dio.post<Object?>(
      '/activities/open-question',
      data: {'subjectId': subjectId, 'knowledgeUnitId': knowledgeUnitId},
      options: await _authorizedOptions(),
    );

    return _OpenQuestionActivityJson(response.data).toActivity();
  }

  @override
  Future<OpenAnswerSubmissionResult> submitOpenAnswer({
    required String sessionId,
    required String answerText,
  }) async {
    final response = await _dio.post<Object?>(
      '/activities/$sessionId/open-answer',
      data: {'answerText': answerText},
      options: await _authorizedOptions(),
    );

    return _OpenAnswerSubmissionJson(response.data).toResult();
  }

  Future<Options> _authorizedOptions() async {
    final token = (await _getIdToken()).trim();

    if (token.isEmpty) {
      throw StateError('A Firebase ID token is required for activities');
    }

    return Options(headers: {'Authorization': 'Bearer $token'});
  }
}

class _ActivityJson {
  const _ActivityJson(this.value);

  final Object? value;

  DiagnosticQuizActivity toActivity() {
    final json = value;

    if (json is! Map<String, Object?>) {
      throw const FormatException('Invalid activity response');
    }

    final sessionId = json['sessionId'];
    final type = json['type'];
    final version = json['version'];
    final title = json['title'];
    final documentId = json['documentId'];
    final subjectId = json['subjectId'];
    final questions = json['questions'];

    if (sessionId is! String || title is! String || questions is! List) {
      throw const FormatException('Invalid activity response');
    }

    return DiagnosticQuizActivity(
      sessionId: sessionId,
      type: type is String ? type : 'diagnostic_quiz',
      version: version is int ? version : null,
      title: title,
      documentId: documentId is String ? documentId : null,
      subjectId: subjectId is String ? subjectId : null,
      questions: questions
          .map((question) => _QuestionJson(question).toQuestion())
          .toList(growable: false),
    );
  }
}

class _QuestionJson {
  const _QuestionJson(this.value);

  final Object? value;

  DiagnosticQuizQuestion toQuestion() {
    final json = value;

    if (json is! Map<String, Object?>) {
      throw const FormatException('Invalid question response');
    }

    final id = json['id'];
    final knowledgeUnitId = json['knowledgeUnitId'];
    final prompt = json['prompt'];
    final difficulty = json['difficulty'];
    final choices = json['choices'];
    final sources = json['sources'];
    final visuals = json['visuals'];

    if (id is! String || prompt is! String || choices is! List) {
      throw const FormatException('Invalid question response');
    }

    final parsedChoices = choices
        .map((choice) => _ChoiceJson(choice).toChoice())
        .toList(growable: false);
    final selectionMode = _selectionMode(json['selectionMode']);
    final minSelections = _selectionCount(
      json['minSelections'],
      fallback: 1,
      fieldName: 'minSelections',
    );
    final maxSelections = _selectionCount(
      json['maxSelections'],
      fallback: selectionMode == DiagnosticQuizSelectionMode.multiple
          ? parsedChoices.length
          : 1,
      fieldName: 'maxSelections',
    );

    if (selectionMode == DiagnosticQuizSelectionMode.multiple &&
        (minSelections < 1 ||
            maxSelections < minSelections ||
            maxSelections > parsedChoices.length)) {
      throw const FormatException('Invalid question selection response');
    }

    final parsedVisuals = <DiagnosticQuizVisual>[];
    if (visuals is List) {
      parsedVisuals.addAll([
        for (final (index, visual) in visuals.indexed)
          _VisualJson(visual, index).toVisual(),
      ]);
      parsedVisuals.sort(
        (left, right) => left.displayOrder.compareTo(right.displayOrder),
      );
    }

    return DiagnosticQuizQuestion(
      id: id,
      knowledgeUnitId: knowledgeUnitId is String ? knowledgeUnitId : null,
      prompt: prompt,
      difficulty: difficulty is String ? difficulty : null,
      selectionMode: selectionMode,
      minSelections: selectionMode == DiagnosticQuizSelectionMode.multiple
          ? minSelections
          : 1,
      maxSelections: selectionMode == DiagnosticQuizSelectionMode.multiple
          ? maxSelections
          : 1,
      choices: parsedChoices,
      sources: sources is List
          ? sources
                .map((source) => _SourceRefJson(source).toSourceRef())
                .toList(growable: false)
          : const [],
      visuals: parsedVisuals,
    );
  }

  DiagnosticQuizSelectionMode _selectionMode(Object? value) {
    if (value == null || value == 'single') {
      return DiagnosticQuizSelectionMode.single;
    }

    if (value == 'multiple') {
      return DiagnosticQuizSelectionMode.multiple;
    }

    throw const FormatException('Invalid question selection response');
  }

  int _selectionCount(
    Object? value, {
    required int fallback,
    required String fieldName,
  }) {
    if (value == null) {
      return fallback;
    }

    if (value is int) {
      return value;
    }

    throw FormatException('Invalid question selection response: $fieldName');
  }
}

class _ChoiceJson {
  const _ChoiceJson(this.value);

  final Object? value;

  DiagnosticQuizChoice toChoice() {
    final json = value;

    if (json is! Map<String, Object?>) {
      throw const FormatException('Invalid choice response');
    }

    final id = json['id'];
    final label = json['label'];

    if (id is! String || label is! String) {
      throw const FormatException('Invalid choice response');
    }

    return DiagnosticQuizChoice(id: id, label: label);
  }
}

class _VisualJson {
  const _VisualJson(this.value, this.fallbackIndex);

  final Object? value;
  final int fallbackIndex;

  DiagnosticQuizVisual toVisual() {
    final json = value;

    if (json is! Map<String, Object?>) {
      return _unsupported('UNKNOWN');
    }

    final type = json['type'];
    if (type is! String) {
      return _unsupported('UNKNOWN', json: json);
    }

    return switch (type) {
      'CHART' => _chart(json),
      'DIAGRAM' => _diagram(json),
      _ => _unsupported(type, json: json),
    };
  }

  DiagnosticQuizVisual _chart(Map<String, Object?> json) {
    try {
      final id = _id(json);
      final displayOrder = _displayOrder(json);
      final chartType = _chartType(json['chartType']);
      final title = json['title'];
      final description = json['description'];
      final data = json['data'];
      final xKey = json['xKey'];
      final yKeys = json['yKeys'];
      final sources = json['sources'];

      if (title is! String || data is! List) {
        return _unsupported('CHART', json: json);
      }

      return DiagnosticQuizChartVisual(
        id: id,
        displayOrder: displayOrder,
        chartType: chartType,
        title: title,
        description: description is String ? description : null,
        data: data.map(_chartRow).toList(growable: false),
        xKey: xKey is String ? xKey : null,
        yKeys: yKeys is List ? _stringList(yKeys) : const [],
        sources: sources is List ? _sourceRefs(sources) : const [],
      );
    } on FormatException {
      return _unsupported('CHART', json: json);
    }
  }

  DiagnosticQuizVisual _diagram(Map<String, Object?> json) {
    try {
      final id = _id(json);
      final displayOrder = _displayOrder(json);
      final title = json['title'];
      final description = json['description'];
      final nodes = json['nodes'];
      final edges = json['edges'];
      final sources = json['sources'];

      if (title is! String || nodes is! List) {
        return _unsupported('DIAGRAM', json: json);
      }

      return DiagnosticQuizDiagramVisual(
        id: id,
        displayOrder: displayOrder,
        title: title,
        description: description is String ? description : null,
        nodes: nodes.map(_diagramNode).toList(growable: false),
        edges: edges is List
            ? edges.map(_diagramEdge).toList(growable: false)
            : const [],
        sources: sources is List ? _sourceRefs(sources) : const [],
      );
    } on FormatException {
      return _unsupported('DIAGRAM', json: json);
    }
  }

  DiagnosticQuizUnsupportedVisual _unsupported(
    String type, {
    Map<String, Object?>? json,
  }) {
    final sources = json?['sources'];

    return DiagnosticQuizUnsupportedVisual(
      id: json == null ? 'visual-$fallbackIndex' : _safeId(json),
      displayOrder: json == null ? fallbackIndex : _safeDisplayOrder(json),
      type: type,
      sources: sources is List ? _safeSourceRefs(sources) : const [],
    );
  }

  String _id(Map<String, Object?> json) {
    final id = json['id'];
    if (id is String && id.trim().isNotEmpty) {
      return id;
    }

    throw const FormatException('Invalid visual response');
  }

  String _safeId(Map<String, Object?> json) {
    final id = json['id'];
    return id is String && id.trim().isNotEmpty ? id : 'visual-$fallbackIndex';
  }

  int _displayOrder(Map<String, Object?> json) {
    final displayOrder = json['displayOrder'];
    if (displayOrder == null) {
      return fallbackIndex;
    }

    if (displayOrder is int) {
      return displayOrder;
    }

    throw const FormatException('Invalid visual response');
  }

  int _safeDisplayOrder(Map<String, Object?> json) {
    final displayOrder = json['displayOrder'];
    return displayOrder is int ? displayOrder : fallbackIndex;
  }

  DiagnosticQuizChartType _chartType(Object? value) {
    return switch (value) {
      'bar' => DiagnosticQuizChartType.bar,
      'line' => DiagnosticQuizChartType.line,
      'pie' => DiagnosticQuizChartType.pie,
      'scatter' => DiagnosticQuizChartType.scatter,
      _ => throw const FormatException('Invalid chart visual response'),
    };
  }

  Map<String, Object?> _chartRow(Object? value) {
    final json = value;
    if (json is! Map<String, Object?>) {
      throw const FormatException('Invalid chart visual response');
    }

    return json.map((key, value) {
      if (value == null || value is String || value is num) {
        return MapEntry(key, value);
      }

      throw const FormatException('Invalid chart visual response');
    });
  }

  DiagnosticQuizDiagramNode _diagramNode(Object? value) {
    final json = value;
    if (json is! Map<String, Object?>) {
      throw const FormatException('Invalid diagram visual response');
    }

    final id = json['id'];
    final label = json['label'];
    if (id is! String || label is! String) {
      throw const FormatException('Invalid diagram visual response');
    }

    return DiagnosticQuizDiagramNode(id: id, label: label);
  }

  DiagnosticQuizDiagramEdge _diagramEdge(Object? value) {
    final json = value;
    if (json is! Map<String, Object?>) {
      throw const FormatException('Invalid diagram visual response');
    }

    final from = json['from'];
    final to = json['to'];
    final label = json['label'];
    if (from is! String || to is! String) {
      throw const FormatException('Invalid diagram visual response');
    }

    return DiagnosticQuizDiagramEdge(
      from: from,
      to: to,
      label: label is String ? label : null,
    );
  }

  List<String> _stringList(List<Object?> values) {
    return values
        .map((value) {
          if (value is String) {
            return value;
          }

          throw const FormatException('Invalid visual response');
        })
        .toList(growable: false);
  }

  List<DiagnosticQuizSourceRef> _sourceRefs(List<Object?> values) {
    return values
        .map((source) => _SourceRefJson(source).toSourceRef())
        .toList(growable: false);
  }

  List<DiagnosticQuizSourceRef> _safeSourceRefs(List<Object?> values) {
    try {
      return _sourceRefs(values);
    } on FormatException {
      return const [];
    }
  }
}

class _SourceRefJson {
  const _SourceRefJson(this.value);

  final Object? value;

  DiagnosticQuizSourceRef toSourceRef() {
    final json = value;

    if (json is! Map<String, Object?>) {
      throw const FormatException('Invalid question source response');
    }

    final chunkId = json['chunkId'];
    final pageNumber = json['pageNumber'];
    final index = json['index'];

    if (chunkId is! String || index is! int) {
      throw const FormatException('Invalid question source response');
    }

    return DiagnosticQuizSourceRef(
      chunkId: chunkId,
      pageNumber: pageNumber is int ? pageNumber : null,
      index: index,
    );
  }
}

class _AnswerJson {
  const _AnswerJson(this.answer);

  final DiagnosticQuizAnswer answer;

  Map<String, Object?> toJson() {
    final choiceId = answer.choiceId;
    if (choiceId != null) {
      return {'questionId': answer.questionId, 'choiceId': choiceId};
    }

    return {'questionId': answer.questionId, 'choiceIds': answer.choiceIds};
  }
}

class _ResultJson {
  const _ResultJson(this.value);

  final Object? value;

  DiagnosticQuizResult toResult() {
    final json = value;

    if (json is! Map<String, Object?>) {
      throw const FormatException('Invalid activity result response');
    }

    final correctAnswers = json['correctAnswers'];
    final totalQuestions = json['totalQuestions'];
    final score = json['score'];
    final items = json['items'];

    if (correctAnswers is! int || totalQuestions is! int) {
      throw const FormatException('Invalid activity result response');
    }

    return DiagnosticQuizResult(
      correctAnswers: correctAnswers,
      totalQuestions: totalQuestions,
      score: score is num ? score.toDouble() : null,
      items: items is List
          ? items
                .map((item) => _CorrectionItemJson(item).toCorrectionItem())
                .toList(growable: false)
          : const [],
    );
  }
}

class _CorrectionItemJson {
  const _CorrectionItemJson(this.value);

  final Object? value;

  DiagnosticQuizCorrectionItem toCorrectionItem() {
    final json = value;

    if (json is! Map<String, Object?>) {
      throw const FormatException('Invalid correction item response');
    }

    final questionId = json['questionId'];
    final knowledgeUnitId = json['knowledgeUnitId'];
    final prompt = json['prompt'];
    final selectedChoiceId = json['selectedChoiceId'];
    final correctChoiceId = json['correctChoiceId'];
    final selectedChoiceIds = json['selectedChoiceIds'];
    final correctChoiceIds = json['correctChoiceIds'];
    final isCorrect = json['isCorrect'];
    final partialScore = json['partialScore'];
    final explanation = json['explanation'];
    final choiceFeedback = json['choiceFeedback'];
    final sources = json['sources'];

    if (questionId is! String ||
        prompt is! String ||
        isCorrect is! bool ||
        explanation is! String) {
      throw const FormatException('Invalid correction item response');
    }

    final parsedSelectedChoiceIds = selectedChoiceIds is List
        ? _stringList(selectedChoiceIds)
        : const <String>[];
    final parsedCorrectChoiceIds = correctChoiceIds is List
        ? _stringList(correctChoiceIds)
        : const <String>[];

    if (selectedChoiceId is! String &&
        correctChoiceId is! String &&
        (parsedSelectedChoiceIds.isEmpty || parsedCorrectChoiceIds.isEmpty)) {
      throw const FormatException('Invalid correction item response');
    }

    return DiagnosticQuizCorrectionItem(
      questionId: questionId,
      knowledgeUnitId: knowledgeUnitId is String ? knowledgeUnitId : null,
      prompt: prompt,
      selectedChoiceId: selectedChoiceId is String ? selectedChoiceId : null,
      correctChoiceId: correctChoiceId is String ? correctChoiceId : null,
      selectedChoiceIds: parsedSelectedChoiceIds,
      correctChoiceIds: parsedCorrectChoiceIds,
      isCorrect: isCorrect,
      partialScore: partialScore is num ? partialScore.toDouble() : null,
      explanation: explanation,
      choiceFeedback: choiceFeedback is List
          ? choiceFeedback
                .map(
                  (feedback) =>
                      _ChoiceFeedbackJson(feedback).toChoiceFeedback(),
                )
                .toList(growable: false)
          : const [],
      sources: sources is List
          ? sources
                .map((source) => _CorrectionSourceJson(source).toSource())
                .toList(growable: false)
          : const [],
    );
  }

  List<String> _stringList(List<Object?> values) {
    return values
        .map((value) {
          if (value is String) {
            return value;
          }

          throw const FormatException('Invalid correction item response');
        })
        .toList(growable: false);
  }
}

class _ChoiceFeedbackJson {
  const _ChoiceFeedbackJson(this.value);

  final Object? value;

  DiagnosticQuizChoiceFeedback toChoiceFeedback() {
    final json = value;

    if (json is! Map<String, Object?>) {
      throw const FormatException('Invalid choice feedback response');
    }

    final choiceId = json['choiceId'];
    final feedback = json['feedback'];

    if (choiceId is! String || feedback is! String) {
      throw const FormatException('Invalid choice feedback response');
    }

    return DiagnosticQuizChoiceFeedback(choiceId: choiceId, feedback: feedback);
  }
}

class _CorrectionSourceJson {
  const _CorrectionSourceJson(this.value);

  final Object? value;

  DiagnosticQuizCorrectionSource toSource() {
    final json = value;

    if (json is! Map<String, Object?>) {
      throw const FormatException('Invalid correction source response');
    }

    final chunkId = json['chunkId'];
    final text = json['text'];
    final pageNumber = json['pageNumber'];
    final index = json['index'];

    if (chunkId is! String || text is! String || index is! int) {
      throw const FormatException('Invalid correction source response');
    }

    return DiagnosticQuizCorrectionSource(
      chunkId: chunkId,
      text: text,
      pageNumber: pageNumber is int ? pageNumber : null,
      index: index,
    );
  }
}

class _OpenQuestionActivityJson {
  const _OpenQuestionActivityJson(this.value);

  final Object? value;

  OpenQuestionActivity toActivity() {
    final json = value;

    if (json is! Map<String, Object?>) {
      throw const FormatException('Invalid open question response');
    }

    final sessionId = json['sessionId'];
    final type = json['type'];
    final version = json['version'];
    final subjectId = json['subjectId'];
    final documentId = json['documentId'];
    final knowledgeUnitId = json['knowledgeUnitId'];
    final question = json['question'];

    if (sessionId is! String ||
        type != 'open_question' ||
        subjectId is! String ||
        knowledgeUnitId is! String ||
        question is! Map<String, Object?>) {
      throw const FormatException('Invalid open question response');
    }

    return OpenQuestionActivity(
      sessionId: sessionId,
      type: type as String,
      version: version is int ? version : null,
      subjectId: subjectId,
      documentId: documentId is String ? documentId : null,
      knowledgeUnitId: knowledgeUnitId,
      question: _OpenQuestionJson(question).toQuestion(),
    );
  }
}

class _OpenQuestionJson {
  const _OpenQuestionJson(this.value);

  final Map<String, Object?> value;

  OpenQuestion toQuestion() {
    final id = value['id'];
    final prompt = value['prompt'];
    final instructions = value['instructions'];
    final maxAnswerLength = value['maxAnswerLength'];
    final sources = value['sources'];

    if (id is! String || prompt is! String || maxAnswerLength is! int) {
      throw const FormatException('Invalid open question response');
    }

    return OpenQuestion(
      id: id,
      prompt: prompt,
      instructions: instructions is String ? instructions : null,
      maxAnswerLength: maxAnswerLength,
      sources: sources is List
          ? sources
                .map((source) => _OpenQuestionSourceJson(source).toSource())
                .toList(growable: false)
          : const [],
    );
  }
}

class _OpenQuestionSourceJson {
  const _OpenQuestionSourceJson(this.value);

  final Object? value;

  OpenQuestionSource toSource() {
    final json = value;

    if (json is! Map<String, Object?>) {
      throw const FormatException('Invalid open question source response');
    }

    final chunkId = json['chunkId'];
    final pageNumber = json['pageNumber'];
    final index = json['index'];

    if (chunkId is! String || index is! int) {
      throw const FormatException('Invalid open question source response');
    }

    return OpenQuestionSource(
      chunkId: chunkId,
      pageNumber: pageNumber is int ? pageNumber : null,
      index: index,
    );
  }
}

class _OpenAnswerSubmissionJson {
  const _OpenAnswerSubmissionJson(this.value);

  final Object? value;

  OpenAnswerSubmissionResult toResult() {
    final json = value;

    if (json is! Map<String, Object?>) {
      throw const FormatException('Invalid open answer response');
    }

    final sessionId = json['sessionId'];
    final type = json['type'];
    final status = json['status'];
    final evaluation = json['evaluation'];

    if (sessionId is! String ||
        type != 'open_question' ||
        status is! String ||
        evaluation is! Map<String, Object?>) {
      throw const FormatException('Invalid open answer response');
    }

    return OpenAnswerSubmissionResult(
      sessionId: sessionId,
      type: type as String,
      status: status,
      evaluation: _OpenAnswerEvaluationJson(evaluation).toEvaluation(),
    );
  }
}

class _OpenAnswerEvaluationJson {
  const _OpenAnswerEvaluationJson(this.value);

  final Map<String, Object?> value;

  OpenAnswerEvaluation toEvaluation() {
    final id = value['id'];
    final status = value['status'];
    final score = value['score'];
    final maxScore = value['maxScore'];
    final feedback = value['feedback'];
    final presentPoints = value['presentPoints'];
    final missingPoints = value['missingPoints'];
    final errors = value['errors'];
    final modelAnswer = value['modelAnswer'];
    final advice = value['advice'];
    final sources = value['sources'];

    if (id is! String || status is! String) {
      throw const FormatException('Invalid open answer evaluation response');
    }

    return OpenAnswerEvaluation(
      id: id,
      status: _openAnswerEvaluationStatus(status),
      score: score is num ? score.toDouble() : null,
      maxScore: maxScore is num ? maxScore.toDouble() : null,
      feedback: feedback is String ? feedback : null,
      presentPoints: presentPoints is List
          ? _stringList(presentPoints, 'Invalid open answer evaluation response')
          : const [],
      missingPoints: missingPoints is List
          ? _stringList(missingPoints, 'Invalid open answer evaluation response')
          : const [],
      errors: errors is List
          ? _stringList(errors, 'Invalid open answer evaluation response')
          : const [],
      modelAnswer: modelAnswer is String ? modelAnswer : null,
      advice: advice is String ? advice : null,
      sources: sources is List
          ? sources
                .map((source) => _OpenAnswerSourceJson(source).toSource())
                .toList(growable: false)
          : const [],
    );
  }

  OpenAnswerEvaluationStatus _openAnswerEvaluationStatus(String status) {
    return switch (status) {
      'PENDING' => OpenAnswerEvaluationStatus.pending,
      'READY' => OpenAnswerEvaluationStatus.ready,
      'FAILED' => OpenAnswerEvaluationStatus.failed,
      _ => throw const FormatException(
        'Invalid open answer evaluation response',
      ),
    };
  }
}

class _OpenAnswerSourceJson {
  const _OpenAnswerSourceJson(this.value);

  final Object? value;

  OpenAnswerCorrectionSource toSource() {
    final json = value;

    if (json is! Map<String, Object?>) {
      throw const FormatException('Invalid open answer source response');
    }

    final chunkId = json['chunkId'];
    final text = json['text'];
    final pageNumber = json['pageNumber'];
    final index = json['index'];

    if (chunkId is! String || text is! String || index is! int) {
      throw const FormatException('Invalid open answer source response');
    }

    return OpenAnswerCorrectionSource(
      chunkId: chunkId,
      text: text,
      pageNumber: pageNumber is int ? pageNumber : null,
      index: index,
    );
  }
}

List<String> _stringList(List<Object?> values, String errorMessage) {
  return values
      .map((value) {
        if (value is String) {
          return value;
        }

        throw FormatException(errorMessage);
      })
      .toList(growable: false);
}

````

### Modifié — `lib/features/activities/data/demo_activity_api.dart`

````dart
import '../application/activity_controller.dart';
import '../domain/diagnostic_quiz_activity.dart';
import '../domain/open_question_activity.dart';

class DemoActivityApi implements ActivityApi {
  static const DiagnosticQuizActivity _activity = DiagnosticQuizActivity(
    sessionId: 'demo-session-1',
    title: 'Diagnostic rapide',
    questions: [
      DiagnosticQuizQuestion(
        id: 'question-1',
        prompt:
            'Quelle structure est principalement responsable de la contraction cardiaque ?',
        choices: [
          DiagnosticQuizChoice(id: 'a', label: 'Myocarde'),
          DiagnosticQuizChoice(id: 'b', label: 'Pericarde'),
        ],
      ),
    ],
  );

  static const OpenQuestionActivity _openQuestionActivity =
      OpenQuestionActivity(
        sessionId: 'demo-open-session-1',
        type: 'open_question',
        version: 1,
        subjectId: 'demo-subject',
        documentId: null,
        knowledgeUnitId: 'demo-unit',
        question: OpenQuestion(
          id: 'demo-open-question-1',
          prompt:
              'Explique avec tes mots le point principal de cette notion.',
          instructions: 'Réponds en quelques phrases structurées.',
          maxAnswerLength: 4000,
        ),
      );

  @override
  Future<DiagnosticQuizActivity> startNextActivity({
    required String subjectId,
    String? knowledgeUnitId,
  }) async {
    return _activity;
  }

  @override
  Future<DiagnosticQuizResult> submitResult({
    required String sessionId,
    required List<DiagnosticQuizAnswer> answers,
  }) async {
    final correctAnswers = answers.where((answer) {
      return answer.questionId == 'question-1' && answer.choiceId == 'a';
    }).length;

    return DiagnosticQuizResult(
      correctAnswers: correctAnswers,
      totalQuestions: _activity.questions.length,
    );
  }

  @override
  Future<OpenQuestionActivity> startOpenQuestion({
    required String subjectId,
    required String knowledgeUnitId,
  }) async {
    return _openQuestionActivity;
  }

  @override
  Future<OpenAnswerSubmissionResult> submitOpenAnswer({
    required String sessionId,
    required String answerText,
  }) async {
    return const OpenAnswerSubmissionResult(
      sessionId: 'demo-open-session-1',
      type: 'open_question',
      status: 'submitted',
      evaluation: OpenAnswerEvaluation(
        id: 'demo-open-evaluation-1',
        status: OpenAnswerEvaluationStatus.ready,
        score: 14,
        maxScore: 20,
        feedback: 'Réponse claire pour une démonstration locale.',
        presentPoints: ['Idée principale identifiée'],
        missingPoints: ['Exemple précis à ajouter'],
        errors: [],
        modelAnswer: 'Une réponse complète définit la notion et l’illustre.',
        advice: 'Ajoute un exemple issu du cours.',
        sources: [],
      ),
    );
  }
}

````

### Modifié — `lib/presentation/pages/activities/activities_page.dart`

````dart
import 'package:flutter/material.dart';
import 'package:revision_app/features/activities/application/activity_controller.dart';
import 'package:revision_app/features/activities/domain/diagnostic_quiz_activity.dart';
import 'package:revision_app/features/activities/domain/open_question_activity.dart';
import 'package:revision_app/features/activities/genui/diagnostic_quiz_activity_validator.dart';
import 'package:revision_app/features/activities/genui/revision_activity_catalog.dart';
import 'package:revision_app/presentation/theme/app_spacing.dart';
import 'package:revision_app/presentation/widgets/revision_button.dart';
import 'package:revision_app/presentation/widgets/revision_message.dart';
import 'package:revision_app/presentation/widgets/revision_page.dart';
import 'package:revision_app/presentation/widgets/revision_panel.dart';

import 'diagnostic_quiz_page.dart';
import 'open_question_page.dart';

class ActivitiesPage extends StatefulWidget {
  const ActivitiesPage({
    required this.controller,
    required this.subjectId,
    this.knowledgeUnitId,
    super.key,
  });

  final ActivityController controller;
  final String? subjectId;
  final String? knowledgeUnitId;

  @override
  State<ActivitiesPage> createState() => _ActivitiesPageState();
}

class _ActivitiesPageState extends State<ActivitiesPage> {
  Future<_LoadedActivity>? _activity;
  _ActivityKind _selectedKind = _ActivityKind.diagnosticQuiz;
  final _catalog = buildRevisionActivityCatalog();

  @override
  void initState() {
    super.initState();
    final subjectId = widget.subjectId?.trim();
    if (subjectId != null && subjectId.isNotEmpty) {
      _activity = _loadDiagnosticQuiz(subjectId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return RevisionPage(
      title: 'Activites',
      subtitle: 'Diagnostics rapides et exercices adaptatifs.',
      children: [
        _ActivityActions(
          selectedKind: _selectedKind,
          canStartOpenQuestion: _canStartOpenQuestion,
          onDiagnosticSelected: _startDiagnosticQuiz,
          onOpenQuestionSelected: _startOpenQuestion,
        ),
        const SizedBox(height: AppSpacing.l),
        SizedBox(
          height: MediaQuery.sizeOf(context).height * 0.68,
          child: _activity == null
              ? const Center(child: Text('Aucune activite selectionnee'))
              : FutureBuilder<_LoadedActivity>(
                  future: _activity,
                  builder: (context, snapshot) {
                    final loadedActivity = snapshot.data;

                    if (snapshot.connectionState != ConnectionState.done) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError || loadedActivity == null) {
                      return const Center(
                        child: Text("Impossible de charger l'activite"),
                      );
                    }

                    return switch (loadedActivity) {
                      _LoadedDiagnosticQuiz(:final activity) =>
                        _DiagnosticQuizActivityPanel(
                          activity: activity,
                          controller: widget.controller,
                          catalogId: _catalog.catalogId ?? 'revisionActivityCatalog',
                        ),
                      _LoadedOpenQuestion(:final activity) =>
                        _OpenQuestionActivityPanel(
                          activity: activity,
                          controller: widget.controller,
                        ),
                    };
                  },
                ),
        ),
      ],
    );
  }

  bool get _canStartOpenQuestion {
    final subjectId = widget.subjectId?.trim();
    final knowledgeUnitId = widget.knowledgeUnitId?.trim();

    return subjectId != null &&
        subjectId.isNotEmpty &&
        knowledgeUnitId != null &&
        knowledgeUnitId.isNotEmpty;
  }

  String? get _trimmedKnowledgeUnitId {
    final knowledgeUnitId = widget.knowledgeUnitId?.trim();
    return knowledgeUnitId == null || knowledgeUnitId.isEmpty
        ? null
        : knowledgeUnitId;
  }

  Future<_LoadedActivity> _loadDiagnosticQuiz(String subjectId) async {
    final activity = await widget.controller.startNextActivity(
      subjectId: subjectId,
      knowledgeUnitId: _trimmedKnowledgeUnitId,
    );

    return _LoadedDiagnosticQuiz(activity);
  }

  Future<_LoadedActivity> _loadOpenQuestion({
    required String subjectId,
    required String knowledgeUnitId,
  }) async {
    final activity = await widget.controller.startOpenQuestion(
      subjectId: subjectId,
      knowledgeUnitId: knowledgeUnitId,
    );

    return _LoadedOpenQuestion(activity);
  }

  void _startDiagnosticQuiz() {
    final subjectId = widget.subjectId?.trim();
    if (subjectId == null || subjectId.isEmpty) {
      return;
    }

    setState(() {
      _selectedKind = _ActivityKind.diagnosticQuiz;
      _activity = _loadDiagnosticQuiz(subjectId);
    });
  }

  void _startOpenQuestion() {
    final subjectId = widget.subjectId?.trim();
    final knowledgeUnitId = _trimmedKnowledgeUnitId;
    if (subjectId == null ||
        subjectId.isEmpty ||
        knowledgeUnitId == null ||
        knowledgeUnitId.isEmpty) {
      return;
    }

    setState(() {
      _selectedKind = _ActivityKind.openQuestion;
      _activity = _loadOpenQuestion(
        subjectId: subjectId,
        knowledgeUnitId: knowledgeUnitId,
      );
    });
  }
}

enum _ActivityKind { diagnosticQuiz, openQuestion }

sealed class _LoadedActivity {
  const _LoadedActivity();
}

class _LoadedDiagnosticQuiz extends _LoadedActivity {
  const _LoadedDiagnosticQuiz(this.activity);

  final DiagnosticQuizActivity activity;
}

class _LoadedOpenQuestion extends _LoadedActivity {
  const _LoadedOpenQuestion(this.activity);

  final OpenQuestionActivity activity;
}

class _ActivityActions extends StatelessWidget {
  const _ActivityActions({
    required this.selectedKind,
    required this.canStartOpenQuestion,
    required this.onDiagnosticSelected,
    required this.onOpenQuestionSelected,
  });

  final _ActivityKind selectedKind;
  final bool canStartOpenQuestion;
  final VoidCallback onDiagnosticSelected;
  final VoidCallback onOpenQuestionSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: AppSpacing.s,
          runSpacing: AppSpacing.s,
          children: [
            RevisionButton(
              onPressed: onDiagnosticSelected,
              icon: Icons.quiz_outlined,
              label: 'QCM',
              style: selectedKind == _ActivityKind.diagnosticQuiz
                  ? RevisionButtonStyle.primary
                  : RevisionButtonStyle.ghost,
            ),
            RevisionButton(
              onPressed: canStartOpenQuestion ? onOpenQuestionSelected : null,
              icon: Icons.rate_review_outlined,
              label: 'Question ouverte',
              style: selectedKind == _ActivityKind.openQuestion
                  ? RevisionButtonStyle.primary
                  : RevisionButtonStyle.ghost,
            ),
          ],
        ),
        if (!canStartOpenQuestion) ...[
          const SizedBox(height: AppSpacing.s),
          RevisionMessage(
            message:
                'Question ouverte disponible depuis une notion précise du cours.',
            color: Theme.of(context).colorScheme.secondary,
            icon: Icons.info_outline,
          ),
        ],
      ],
    );
  }
}

class _DiagnosticQuizActivityPanel extends StatelessWidget {
  const _DiagnosticQuizActivityPanel({
    required this.activity,
    required this.controller,
    required this.catalogId,
  });

  final DiagnosticQuizActivity activity;
  final ActivityController controller;
  final String catalogId;

  @override
  Widget build(BuildContext context) {
    if (!isDiagnosticQuizActivityCatalogSafe(activity)) {
      return const Center(child: Text('Activite indisponible'));
    }

    return RevisionPanel(
      padding: const EdgeInsets.all(AppSpacing.l),
      child: Semantics(
        label: catalogId,
        child: DiagnosticQuizPage(
          activity: activity,
          onSubmit: (answers) {
            return controller.submitResult(
              sessionId: activity.sessionId,
              answers: answers,
            );
          },
        ),
      ),
    );
  }
}

class _OpenQuestionActivityPanel extends StatelessWidget {
  const _OpenQuestionActivityPanel({
    required this.activity,
    required this.controller,
  });

  final OpenQuestionActivity activity;
  final ActivityController controller;

  @override
  Widget build(BuildContext context) {
    return RevisionPanel(
      padding: const EdgeInsets.all(AppSpacing.l),
      child: OpenQuestionPage(
        activity: activity,
        onSubmit: (answerText) {
          return controller.submitOpenAnswer(
            sessionId: activity.sessionId,
            answerText: answerText,
          );
        },
      ),
    );
  }
}

````

### Créé — `lib/presentation/pages/activities/open_question_page.dart`

````dart
import 'package:flutter/material.dart';
import 'package:revision_app/features/activities/application/activity_controller.dart';
import 'package:revision_app/features/activities/domain/open_question_activity.dart';
import 'package:revision_app/presentation/theme/app_spacing.dart';
import 'package:revision_app/presentation/widgets/documents/document_source_excerpt.dart';
import 'package:revision_app/presentation/widgets/revision_button.dart';
import 'package:revision_app/presentation/widgets/revision_message.dart';
import 'package:revision_app/presentation/widgets/revision_panel.dart';
import 'package:revision_app/presentation/widgets/revision_status_pill.dart';

class OpenQuestionPage extends StatefulWidget {
  const OpenQuestionPage({required this.activity, this.onSubmit, super.key});

  final OpenQuestionActivity activity;
  final OpenAnswerSubmitter? onSubmit;

  @override
  State<OpenQuestionPage> createState() => _OpenQuestionPageState();
}

class _OpenQuestionPageState extends State<OpenQuestionPage> {
  late OpenQuestionSessionController _controller;
  late TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _controller = _createController();
    _textController = TextEditingController();
  }

  @override
  void didUpdateWidget(covariant OpenQuestionPage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.activity != widget.activity ||
        oldWidget.onSubmit != widget.onSubmit) {
      _controller = _createController();
      _textController.dispose();
      _textController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final result = _controller.result;
    final evaluation = result?.evaluation;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _OpenQuestionHeader(activity: widget.activity),
          const SizedBox(height: AppSpacing.l),
          if (_controller.submitErrorMessage != null) ...[
            RevisionMessage(
              message: _controller.submitErrorMessage!,
              color: Theme.of(context).colorScheme.error,
              icon: Icons.error_outline,
            ),
            const SizedBox(height: AppSpacing.l),
          ],
          _QuestionPanel(activity: widget.activity),
          const SizedBox(height: AppSpacing.l),
          if (evaluation == null)
            _AnswerPanel(
              activity: widget.activity,
              controller: _controller,
              textController: _textController,
              onChanged: _updateAnswer,
              onSubmit: _submit,
            ),
          if (_controller.isSubmitting) ...[
            const SizedBox(height: AppSpacing.l),
            const RevisionMessage(
              message: 'Correction en cours...',
              color: Colors.teal,
              icon: Icons.hourglass_top,
            ),
          ],
          if (evaluation != null) ...[
            _SubmittedAnswerPanel(answerText: _controller.answerText),
            const SizedBox(height: AppSpacing.l),
            _EvaluationPanel(evaluation: evaluation),
          ],
        ],
      ),
    );
  }

  OpenQuestionSessionController _createController() {
    return OpenQuestionSessionController(
      activity: widget.activity,
      submitter: widget.onSubmit,
    );
  }

  void _updateAnswer(String answerText) {
    setState(() {
      _controller.updateAnswer(answerText);
    });
  }

  Future<void> _submit() async {
    final submitFuture = _controller.submit();
    setState(() {});
    await submitFuture;

    if (mounted) {
      setState(() {});
    }
  }
}

class _OpenQuestionHeader extends StatelessWidget {
  const _OpenQuestionHeader({required this.activity});

  final OpenQuestionActivity activity;

  @override
  Widget build(BuildContext context) {
    return RevisionPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Question ouverte', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppSpacing.s),
          Wrap(
            spacing: AppSpacing.s,
            runSpacing: AppSpacing.s,
            children: [
              RevisionStatusPill(
                label: 'Correction sourcée',
                color: Theme.of(context).colorScheme.primary,
                icon: Icons.rate_review_outlined,
              ),
              RevisionStatusPill(
                label: '${activity.question.maxAnswerLength} caractères max',
                color: Theme.of(context).colorScheme.secondary,
                icon: Icons.edit_note,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuestionPanel extends StatelessWidget {
  const _QuestionPanel({required this.activity});

  final OpenQuestionActivity activity;

  @override
  Widget build(BuildContext context) {
    final question = activity.question;

    return RevisionPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(question.prompt, style: Theme.of(context).textTheme.titleMedium),
          if (question.instructions != null) ...[
            const SizedBox(height: AppSpacing.s),
            Text(question.instructions!),
          ],
          if (question.sources.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.l),
            Text(
              'Sources disponibles après correction',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: AppSpacing.s),
            Wrap(
              spacing: AppSpacing.s,
              runSpacing: AppSpacing.s,
              children: [
                for (final source in question.sources)
                  _SourceReference(source: source),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _SourceReference extends StatelessWidget {
  const _SourceReference({required this.source});

  final OpenQuestionSource source;

  @override
  Widget build(BuildContext context) {
    final pageLabel = source.pageNumber == null
        ? null
        : 'page ${source.pageNumber}';
    final label = pageLabel == null
        ? 'Source ${source.index + 1}'
        : 'Source ${source.index + 1} · $pageLabel';

    return RevisionStatusPill(
      label: label,
      color: Theme.of(context).colorScheme.secondary,
      icon: Icons.source_outlined,
    );
  }
}

class _AnswerPanel extends StatelessWidget {
  const _AnswerPanel({
    required this.activity,
    required this.controller,
    required this.textController,
    required this.onChanged,
    required this.onSubmit,
  });

  final OpenQuestionActivity activity;
  final OpenQuestionSessionController controller;
  final TextEditingController textController;
  final ValueChanged<String> onChanged;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final validationMessage = controller.answerText.isEmpty
        ? null
        : controller.validationMessage;

    return RevisionPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Ta réponse', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.s),
          Material(
            color: Colors.transparent,
            child: TextField(
              controller: textController,
              enabled: !controller.isSubmitting,
              minLines: 6,
              maxLines: 10,
              keyboardType: TextInputType.multiline,
              onChanged: onChanged,
              decoration: InputDecoration(
                labelText: 'Réponse',
                alignLabelWithHint: true,
                errorText: validationMessage,
                border: const OutlineInputBorder(),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.s),
          Text(
            '${controller.answerText.length} / ${activity.question.maxAnswerLength}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: AppSpacing.l),
          Align(
            alignment: Alignment.centerLeft,
            child: RevisionButton(
              onPressed: controller.canSubmit ? onSubmit : null,
              icon: Icons.check,
              label: controller.isSubmitting
                  ? 'Correction en cours...'
                  : 'Valider ma réponse',
            ),
          ),
        ],
      ),
    );
  }
}

class _SubmittedAnswerPanel extends StatelessWidget {
  const _SubmittedAnswerPanel({required this.answerText});

  final String answerText;

  @override
  Widget build(BuildContext context) {
    return RevisionPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Réponse envoyée', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: AppSpacing.s),
          Text(answerText),
        ],
      ),
    );
  }
}

class _EvaluationPanel extends StatelessWidget {
  const _EvaluationPanel({required this.evaluation});

  final OpenAnswerEvaluation evaluation;

  @override
  Widget build(BuildContext context) {
    return switch (evaluation.status) {
      OpenAnswerEvaluationStatus.ready => _ReadyEvaluationPanel(
        evaluation: evaluation,
      ),
      OpenAnswerEvaluationStatus.failed => _FailedEvaluationPanel(
        evaluation: evaluation,
      ),
      OpenAnswerEvaluationStatus.pending => const RevisionMessage(
        message: 'La correction est en attente.',
        color: Colors.teal,
        icon: Icons.hourglass_empty,
      ),
    };
  }
}

class _ReadyEvaluationPanel extends StatelessWidget {
  const _ReadyEvaluationPanel({required this.evaluation});

  final OpenAnswerEvaluation evaluation;

  @override
  Widget build(BuildContext context) {
    return RevisionPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Correction', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.s),
          Wrap(
            spacing: AppSpacing.s,
            runSpacing: AppSpacing.s,
            children: [
              if (evaluation.score != null && evaluation.maxScore != null)
                RevisionStatusPill(
                  label:
                      'Score ${_formatNumber(evaluation.score!)} / ${_formatNumber(evaluation.maxScore!)}',
                  color: Theme.of(context).colorScheme.primary,
                  icon: Icons.verified_outlined,
                ),
            ],
          ),
          if (evaluation.feedback != null) ...[
            const SizedBox(height: AppSpacing.l),
            Text(evaluation.feedback!),
          ],
          _PointSection(title: 'Points présents', items: evaluation.presentPoints),
          _PointSection(title: 'Points à compléter', items: evaluation.missingPoints),
          _PointSection(title: 'Erreurs ou confusions', items: evaluation.errors),
          if (evaluation.modelAnswer != null) ...[
            const SizedBox(height: AppSpacing.l),
            Text('Réponse modèle', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: AppSpacing.s),
            Text(evaluation.modelAnswer!),
          ],
          if (evaluation.advice != null) ...[
            const SizedBox(height: AppSpacing.l),
            Text('Conseil', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: AppSpacing.s),
            Text(evaluation.advice!),
          ],
          if (evaluation.sources.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.l),
            Text('Sources', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: AppSpacing.s),
            Column(
              spacing: AppSpacing.s,
              children: [
                for (final source in evaluation.sources)
                  DocumentSourceExcerpt(
                    text: source.text,
                    index: source.index,
                    pageNumber: source.pageNumber,
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _PointSection extends StatelessWidget {
  const _PointSection({required this.title, required this.items});

  final String title;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.l),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: AppSpacing.s),
          for (final item in items)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xs),
              child: Text('• $item'),
            ),
        ],
      ),
    );
  }
}

class _FailedEvaluationPanel extends StatelessWidget {
  const _FailedEvaluationPanel({required this.evaluation});

  final OpenAnswerEvaluation evaluation;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.error;

    return RevisionPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.error_outline, color: color, size: 18),
              const SizedBox(width: AppSpacing.s),
              Expanded(
                child: Text(
                  "La correction n'a pas pu être générée.",
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          if (evaluation.errors.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.s),
            for (final error in evaluation.errors)
              Text(error, style: Theme.of(context).textTheme.bodySmall),
          ],
        ],
      ),
    );
  }
}

String _formatNumber(double value) {
  if (value == value.roundToDouble()) {
    return value.round().toString();
  }

  return value.toStringAsFixed(1);
}

````

### Modifié — `lib/presentation/pages/documents/document_detail_page.dart`

````dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:revision_app/core/routing/route_paths.dart';
import 'package:revision_app/features/documents/application/documents_controller.dart';
import 'package:revision_app/features/documents/domain/revision_document.dart';
import 'package:revision_app/presentation/theme/app_colors.dart';
import 'package:revision_app/presentation/theme/app_spacing.dart';
import 'package:revision_app/presentation/widgets/documents/document_source_excerpt.dart';
import 'package:revision_app/presentation/widgets/revision_button.dart';
import 'package:revision_app/presentation/widgets/revision_page.dart';
import 'package:revision_app/presentation/widgets/revision_panel.dart';
import 'package:revision_app/presentation/widgets/revision_status_pill.dart';

class DocumentDetailPage extends StatefulWidget {
  const DocumentDetailPage({
    required this.documentId,
    required this.controller,
    super.key,
  });

  final String documentId;
  final DocumentsController controller;

  @override
  State<DocumentDetailPage> createState() => _DocumentDetailPageState();
}

class _DocumentDetailPageState extends State<DocumentDetailPage> {
  late Future<DocumentDetail> _detail;

  @override
  void initState() {
    super.initState();
    _detail = widget.controller.loadDocumentDetail(widget.documentId);
  }

  void _reload() {
    setState(() {
      _detail = widget.controller.loadDocumentDetail(widget.documentId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentDetail>(
      future: _detail,
      builder: (context, snapshot) {
        final detail = snapshot.data;

        if (snapshot.connectionState != ConnectionState.done) {
          return const RevisionPage(
            title: 'Document',
            children: [LinearProgressIndicator()],
          );
        }

        if (snapshot.hasError || detail == null) {
          return RevisionPage(
            title: 'Document',
            children: [
              Text(
                'Impossible de charger le document',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
              const SizedBox(height: AppSpacing.m),
              RevisionButton(
                onPressed: _reload,
                icon: Icons.refresh,
                label: 'Reessayer',
                style: RevisionButtonStyle.ghost,
              ),
            ],
          );
        }

        return RevisionPage(
          title: detail.document.fileName,
          subtitle: _documentKindLabel(detail.document.kind),
          children: [
            _DocumentHeader(document: detail.document, onRefresh: _reload),
            const SizedBox(height: AppSpacing.xl),
            _DocumentKnowledgeSection(detail: detail, onRefresh: _reload),
            if (detail.state == DocumentDetailLoadState.ready) ...[
              const SizedBox(height: AppSpacing.xl),
              _DocumentArtifactsSection(
                documentId: detail.document.id,
                controller: widget.controller,
              ),
            ],
          ],
        );
      },
    );
  }
}

class _DocumentHeader extends StatelessWidget {
  const _DocumentHeader({required this.document, required this.onRefresh});

  final RevisionDocument document;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return RevisionPanel(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RevisionStatusPill(
                  label: _documentStatusLabel(document),
                  color: _documentStatusColor(context, document.status),
                ),
                const SizedBox(height: AppSpacing.m),
                Text(
                  document.mimeType,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                if (document.status == 'FAILED' &&
                    document.errorCode != null) ...[
                  const SizedBox(height: AppSpacing.s),
                  Text(
                    _failedDocumentLabel(document.errorCode),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            onPressed: onRefresh,
            icon: const Icon(Icons.refresh),
            tooltip: 'Recharger',
          ),
        ],
      ),
    );
  }
}

class _DocumentKnowledgeSection extends StatelessWidget {
  const _DocumentKnowledgeSection({
    required this.detail,
    required this.onRefresh,
  });

  final DocumentDetail detail;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return switch (detail.state) {
      DocumentDetailLoadState.ready => _ReadyKnowledgeUnits(
        subjectId: detail.document.subjectId,
        units: detail.knowledgeUnits,
      ),
      DocumentDetailLoadState.notReady => _NotReadyState(
        status: detail.document.status,
      ),
      DocumentDetailLoadState.failed => _FailedState(
        errorCode: detail.document.errorCode,
        onRetry: onRefresh,
      ),
    };
  }
}

class _ReadyKnowledgeUnits extends StatelessWidget {
  const _ReadyKnowledgeUnits({
    required this.subjectId,
    required this.units,
  });

  final String subjectId;
  final List<DocumentKnowledgeUnit> units;

  @override
  Widget build(BuildContext context) {
    if (units.isEmpty) {
      return const Text('Aucune notion extraite');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: AppSpacing.itemGap,
      children: [
        Text(
          'Notions extraites',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        for (final unit in units)
          _KnowledgeUnitPanel(subjectId: subjectId, unit: unit),
      ],
    );
  }
}

class _KnowledgeUnitPanel extends StatelessWidget {
  const _KnowledgeUnitPanel({
    required this.subjectId,
    required this.unit,
  });

  final String subjectId;
  final DocumentKnowledgeUnit unit;

  @override
  Widget build(BuildContext context) {
    return RevisionPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: AppSpacing.s,
            runSpacing: AppSpacing.s,
            children: [
              if (unit.difficulty != null)
                RevisionStatusPill(
                  label: _difficultyLabel(unit.difficulty),
                  color: _difficultyColor(context, unit.difficulty),
                ),
              if (unit.confidence != null)
                RevisionStatusPill(
                  label: 'Confiance ${(unit.confidence! * 100).round()}%',
                  color: AppColors.aqua,
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.m),
          Text(unit.title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.s),
          Text(unit.summary, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: AppSpacing.l),
          Align(
            alignment: Alignment.centerLeft,
            child: RevisionButton(
              onPressed: () => context.go(
                Uri(
                  path: activitiesRoutePath,
                  queryParameters: {
                    'subjectId': subjectId,
                    'knowledgeUnitId': unit.id,
                  },
                ).toString(),
              ),
              icon: Icons.edit_note,
              label: 'Question ouverte',
              style: RevisionButtonStyle.ghost,
            ),
          ),
          if (unit.sources.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.l),
            Text('Sources', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: AppSpacing.s),
            Column(
              spacing: AppSpacing.s,
              children: [
                for (final source in unit.sources)
                  DocumentSourceExcerpt(
                    text: source.text,
                    index: source.index,
                    pageNumber: source.pageNumber,
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _DocumentArtifactsSection extends StatefulWidget {
  const _DocumentArtifactsSection({
    required this.documentId,
    required this.controller,
  });

  final String documentId;
  final DocumentsController controller;

  @override
  State<_DocumentArtifactsSection> createState() =>
      _DocumentArtifactsSectionState();
}

class _DocumentArtifactsSectionState extends State<_DocumentArtifactsSection> {
  var _isLoading = true;
  var _isGeneratingSummary = false;
  var _isGeneratingRevisionSheet = false;
  DocumentArtifacts? _artifacts;
  String? _loadError;
  String? _summaryError;
  String? _revisionSheetError;

  @override
  void initState() {
    super.initState();
    _loadArtifacts();
  }

  @override
  void didUpdateWidget(_DocumentArtifactsSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.documentId != widget.documentId) {
      _loadArtifacts();
    }
  }

  Future<void> _loadArtifacts() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });

    try {
      final artifacts = await widget.controller.loadDocumentArtifacts(
        widget.documentId,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _artifacts = artifacts;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _loadError = _artifactErrorLabel(error);
        _isLoading = false;
      });
    }
  }

  Future<void> _generateSummary() async {
    if (_isGeneratingSummary) {
      return;
    }

    setState(() {
      _isGeneratingSummary = true;
      _summaryError = null;
    });

    try {
      final summary = await widget.controller.generateDocumentSummary(
        widget.documentId,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _artifacts =
            (_artifacts ??
                    const DocumentArtifacts(summary: null, revisionSheet: null))
                .copyWith(summary: summary);
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _summaryError = _artifactErrorLabel(error);
      });
    } finally {
      if (mounted) {
        setState(() {
          _isGeneratingSummary = false;
        });
      }
    }
  }

  Future<void> _generateRevisionSheet() async {
    if (_isGeneratingRevisionSheet) {
      return;
    }

    setState(() {
      _isGeneratingRevisionSheet = true;
      _revisionSheetError = null;
    });

    try {
      final revisionSheet = await widget.controller.generateRevisionSheet(
        widget.documentId,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _artifacts =
            (_artifacts ??
                    const DocumentArtifacts(summary: null, revisionSheet: null))
                .copyWith(revisionSheet: revisionSheet);
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _revisionSheetError = _artifactErrorLabel(error);
      });
    } finally {
      if (mounted) {
        setState(() {
          _isGeneratingRevisionSheet = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final artifacts = _artifacts;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: AppSpacing.itemGap,
      children: [
        Text('Supports IA', style: Theme.of(context).textTheme.titleLarge),
        if (_isLoading)
          const RevisionPanel(child: LinearProgressIndicator())
        else if (_loadError != null)
          RevisionPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Impossible de charger les supports IA',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.s),
                Text(_loadError!),
                const SizedBox(height: AppSpacing.m),
                RevisionButton(
                  onPressed: _loadArtifacts,
                  icon: Icons.refresh,
                  label: 'Reessayer',
                  style: RevisionButtonStyle.ghost,
                ),
              ],
            ),
          )
        else ...[
          _SummaryArtifactPanel(
            summary: artifacts?.summary,
            isGenerating: _isGeneratingSummary,
            errorMessage: _summaryError,
            onGenerate: _generateSummary,
          ),
          _RevisionSheetArtifactPanel(
            revisionSheet: artifacts?.revisionSheet,
            isGenerating: _isGeneratingRevisionSheet,
            errorMessage: _revisionSheetError,
            onGenerate: _generateRevisionSheet,
          ),
        ],
      ],
    );
  }
}

class _SummaryArtifactPanel extends StatelessWidget {
  const _SummaryArtifactPanel({
    required this.summary,
    required this.isGenerating,
    required this.errorMessage,
    required this.onGenerate,
  });

  final DocumentSummary? summary;
  final bool isGenerating;
  final String? errorMessage;
  final VoidCallback onGenerate;

  @override
  Widget build(BuildContext context) {
    final summary = this.summary;

    return RevisionPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Resume', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.s),
          if (isGenerating) ...[
            const LinearProgressIndicator(),
            const SizedBox(height: AppSpacing.m),
            const Text('Generation du resume en cours'),
          ] else if (summary == null) ...[
            const Text('Aucun resume genere pour ce document.'),
            const SizedBox(height: AppSpacing.m),
            RevisionButton(
              onPressed: onGenerate,
              icon: Icons.auto_awesome,
              label: 'Generer le resume',
            ),
          ] else if (summary.status == 'FAILED') ...[
            Text(_artifactFailedLabel(summary.errorCode)),
            const SizedBox(height: AppSpacing.m),
            RevisionButton(
              onPressed: onGenerate,
              icon: Icons.refresh,
              label: 'Reessayer',
              style: RevisionButtonStyle.ghost,
            ),
          ] else ...[
            Text(summary.title, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: AppSpacing.s),
            Text(summary.content),
            if (summary.keyPoints.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.l),
              _TextList(title: 'Points cles', items: summary.keyPoints),
            ],
            if (summary.limits != null &&
                summary.limits!.trim().isNotEmpty) ...[
              const SizedBox(height: AppSpacing.l),
              Text('Limites', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: AppSpacing.s),
              Text(summary.limits!),
            ],
            if (summary.sources.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.l),
              _ArtifactSources(sources: summary.sources),
            ],
          ],
          if (errorMessage != null) ...[
            const SizedBox(height: AppSpacing.m),
            Text(
              errorMessage!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _RevisionSheetArtifactPanel extends StatelessWidget {
  const _RevisionSheetArtifactPanel({
    required this.revisionSheet,
    required this.isGenerating,
    required this.errorMessage,
    required this.onGenerate,
  });

  final RevisionSheet? revisionSheet;
  final bool isGenerating;
  final String? errorMessage;
  final VoidCallback onGenerate;

  @override
  Widget build(BuildContext context) {
    final revisionSheet = this.revisionSheet;

    return RevisionPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Fiche de revision',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.s),
          if (isGenerating) ...[
            const LinearProgressIndicator(),
            const SizedBox(height: AppSpacing.m),
            const Text('Generation de la fiche en cours'),
          ] else if (revisionSheet == null) ...[
            const Text('Aucune fiche generee pour ce document.'),
            const SizedBox(height: AppSpacing.m),
            RevisionButton(
              onPressed: onGenerate,
              icon: Icons.auto_stories,
              label: 'Generer la fiche',
            ),
          ] else if (revisionSheet.status == 'FAILED') ...[
            Text(_artifactFailedLabel(revisionSheet.errorCode)),
            const SizedBox(height: AppSpacing.m),
            RevisionButton(
              onPressed: onGenerate,
              icon: Icons.refresh,
              label: 'Reessayer',
              style: RevisionButtonStyle.ghost,
            ),
          ] else ...[
            Text(
              revisionSheet.title,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            if (revisionSheet.introduction != null &&
                revisionSheet.introduction!.trim().isNotEmpty) ...[
              const SizedBox(height: AppSpacing.s),
              Text(revisionSheet.introduction!),
            ],
            if (revisionSheet.sections.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.l),
              Column(
                spacing: AppSpacing.l,
                children: [
                  for (final section in revisionSheet.sections)
                    _RevisionSheetSectionBlock(section: section),
                ],
              ),
            ],
            if (revisionSheet.keyPoints.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.l),
              _TextList(title: 'A retenir', items: revisionSheet.keyPoints),
            ],
            if (revisionSheet.commonMistakes.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.l),
              _TextList(
                title: 'Pieges classiques',
                items: revisionSheet.commonMistakes,
              ),
            ],
            if (revisionSheet.mustKnow.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.l),
              _TextList(title: 'Indispensables', items: revisionSheet.mustKnow),
            ],
            if (revisionSheet.practiceSuggestions.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.l),
              _TextList(
                title: 'Suggestions de pratique',
                items: revisionSheet.practiceSuggestions,
              ),
            ],
          ],
          if (errorMessage != null) ...[
            const SizedBox(height: AppSpacing.m),
            Text(
              errorMessage!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _RevisionSheetSectionBlock extends StatelessWidget {
  const _RevisionSheetSectionBlock({required this.section});

  final RevisionSheetSection section;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Theme.of(
              context,
            ).colorScheme.outline.withValues(alpha: 0.18),
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: AppSpacing.m),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(section.title, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: AppSpacing.s),
            Text(section.content),
            if (section.sources.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.m),
              _ArtifactSources(sources: section.sources),
            ],
          ],
        ),
      ),
    );
  }
}

class _TextList extends StatelessWidget {
  const _TextList({required this.title, required this.items});

  final String title;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: AppSpacing.s),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: AppSpacing.xs,
          children: [
            for (final item in items)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• '),
                  Expanded(child: Text(item)),
                ],
              ),
          ],
        ),
      ],
    );
  }
}

class _ArtifactSources extends StatelessWidget {
  const _ArtifactSources({required this.sources});

  final List<DocumentArtifactSource> sources;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Sources', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: AppSpacing.s),
        Column(
          spacing: AppSpacing.s,
          children: [
            for (final source in sources)
              DocumentSourceExcerpt(
                text: source.text,
                index: source.index,
                pageNumber: source.pageNumber,
              ),
          ],
        ),
      ],
    );
  }
}

class _NotReadyState extends StatelessWidget {
  const _NotReadyState({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    return RevisionPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _notReadyTitle(status),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.s),
          const Text('Les notions apparaitront apres le traitement.'),
        ],
      ),
    );
  }
}

class _FailedState extends StatelessWidget {
  const _FailedState({required this.errorCode, required this.onRetry});

  final String? errorCode;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return RevisionPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Analyse echouee',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.s),
          Text(
            _failedDocumentLabel(errorCode),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.error,
            ),
          ),
          const SizedBox(height: AppSpacing.m),
          RevisionButton(
            onPressed: onRetry,
            icon: Icons.refresh,
            label: 'Reessayer',
            style: RevisionButtonStyle.ghost,
          ),
        ],
      ),
    );
  }
}

String _artifactFailedLabel(String? errorCode) {
  return switch (errorCode) {
    'SUMMARY_SOURCE_INVALID' => 'Sources du resume invalides',
    'REVISION_SHEET_SOURCE_INVALID' => 'Sources de la fiche invalides',
    'GENERATION_FAILED' => 'Generation impossible',
    _ => 'Support IA indisponible',
  };
}

String _artifactErrorLabel(Object error) {
  if (error is DocumentNotReadyException) {
    return 'Le document doit etre pret avant de generer un support.';
  }

  if (error is DocumentArtifactRequestException) {
    return switch (error.statusCode) {
      409 => 'Le document n est pas encore pret.',
      422 => 'La generation a produit un resultat invalide.',
      502 => 'Le service IA est indisponible.',
      _ => 'Erreur API ${error.statusCode}',
    };
  }

  return 'Erreur inattendue';
}

String _documentKindLabel(String kind) {
  return switch (kind) {
    'COURSE_PDF' => 'PDF de cours',
    'EXAM_PDF' => 'PDF examen',
    'EXAM_IMAGE' => 'Image examen',
    _ => kind,
  };
}

String _documentStatusLabel(RevisionDocument document) {
  return switch (document.status) {
    'UPLOADED' => 'Importe',
    'PROCESSING' => 'Analyse en cours',
    'READY' => 'Pret',
    'FAILED' => 'Analyse echouee',
    _ => document.status,
  };
}

Color _documentStatusColor(BuildContext context, String status) {
  final colorScheme = Theme.of(context).colorScheme;

  return switch (status) {
    'UPLOADED' => colorScheme.secondary,
    'PROCESSING' => colorScheme.primary,
    'READY' => colorScheme.tertiary,
    'FAILED' => colorScheme.error,
    _ => colorScheme.outline,
  };
}

String _notReadyTitle(String status) {
  return switch (status) {
    'UPLOADED' => 'Import en attente',
    'PROCESSING' => 'Analyse en cours',
    _ => 'Document en attente',
  };
}

String _failedDocumentLabel(String? errorCode) {
  return switch (errorCode) {
    'DOCUMENT_TEXT_EMPTY' => 'PDF sans texte',
    'DOCUMENT_TEXT_EXTRACTION_FAILED' => 'Lecture PDF impossible',
    'KNOWLEDGE_EXTRACTION_EMPTY' => 'Aucune notion',
    'KNOWLEDGE_SOURCE_INVALID' => 'Sources invalides',
    'KNOWLEDGE_EXTRACTION_FAILED' => 'Erreur IA',
    'DOCUMENT_UNSUPPORTED_MIME_TYPE' => 'Format invalide',
    _ => 'Echec',
  };
}

String _difficultyLabel(String? difficulty) {
  return switch (difficulty) {
    'LOW' => 'Difficulte faible',
    'MEDIUM' => 'Difficulte moyenne',
    'HIGH' => 'Difficulte elevee',
    _ => 'Difficulte inconnue',
  };
}

Color _difficultyColor(BuildContext context, String? difficulty) {
  return switch (difficulty) {
    'LOW' => AppColors.aqua,
    'MEDIUM' => AppColors.amber,
    'HIGH' => AppColors.coral,
    _ => Theme.of(context).colorScheme.outline,
  };
}

````

### Modifié — `test/fakes/in_memory_activity_api.dart`

````dart
import 'package:revision_app/features/activities/application/activity_controller.dart';
import 'package:revision_app/features/activities/domain/diagnostic_quiz_activity.dart';
import 'package:revision_app/features/activities/domain/open_question_activity.dart';

class InMemoryActivityApi implements ActivityApi {
  String? startedSubjectId;
  String? startedOpenQuestionSubjectId;
  String? startedOpenQuestionKnowledgeUnitId;
  List<DiagnosticQuizAnswer>? submittedAnswers;
  String? submittedOpenAnswerText;

  @override
  Future<DiagnosticQuizActivity> startNextActivity({
    required String subjectId,
    String? knowledgeUnitId,
  }) async {
    startedSubjectId = subjectId;

    return const DiagnosticQuizActivity(
      sessionId: 'session-1',
      title: 'Diagnostic rapide',
      questions: [
        DiagnosticQuizQuestion(
          id: 'question-1',
          prompt: 'Question test',
          choices: [
            DiagnosticQuizChoice(id: 'a', label: 'Reponse A'),
            DiagnosticQuizChoice(id: 'b', label: 'Reponse B'),
          ],
        ),
      ],
    );
  }

  @override
  Future<DiagnosticQuizResult> submitResult({
    required String sessionId,
    required List<DiagnosticQuizAnswer> answers,
  }) async {
    submittedAnswers = answers;

    return const DiagnosticQuizResult(correctAnswers: 1, totalQuestions: 1);
  }

  @override
  Future<OpenQuestionActivity> startOpenQuestion({
    required String subjectId,
    required String knowledgeUnitId,
  }) async {
    startedOpenQuestionSubjectId = subjectId;
    startedOpenQuestionKnowledgeUnitId = knowledgeUnitId;

    return const OpenQuestionActivity(
      sessionId: 'open-session-1',
      type: 'open_question',
      version: 1,
      subjectId: 'subject-1',
      documentId: null,
      knowledgeUnitId: 'unit-1',
      question: OpenQuestion(
        id: 'open-question-1',
        prompt: 'Question ouverte test',
        instructions: 'Réponds en quelques phrases.',
        maxAnswerLength: 4000,
      ),
    );
  }

  @override
  Future<OpenAnswerSubmissionResult> submitOpenAnswer({
    required String sessionId,
    required String answerText,
  }) async {
    submittedOpenAnswerText = answerText;

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
        presentPoints: ['Point présent'],
        missingPoints: ['Point manquant'],
        errors: [],
        modelAnswer: 'Réponse modèle.',
        advice: 'Conseil de révision.',
        sources: [],
      ),
    );
  }
}

````

### Modifié — `test/features/activities/http_activities_api_test.dart`

````dart
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:revision_app/features/activities/data/http_activities_api.dart';
import 'package:revision_app/features/activities/domain/diagnostic_quiz_activity.dart';
import 'package:revision_app/features/activities/domain/open_question_activity.dart';

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
  test('starts the next activity with subject id and bearer token', () async {
    final adapter = CapturingHttpClientAdapter(jsonResponse(activityJson()));
    final dio = Dio()..httpClientAdapter = adapter;
    final api = HttpActivitiesApi(
      dio: dio,
      getIdToken: () async => 'firebase-id-token',
    );

    final activity = await api.startNextActivity(subjectId: 'subject-1');

    expect(activity.sessionId, 'session-1');
    expect(adapter.lastOptions?.path, '/activities/next');
    expect(adapter.lastOptions?.data, {
      'subjectId': 'subject-1',
      'selectionModes': ['single', 'multiple'],
      'visualsEnabled': true,
      'visualTypes': ['CHART', 'DIAGRAM'],
    });
    expect(
      adapter.lastOptions?.headers['Authorization'],
      'Bearer firebase-id-token',
    );
  });

  test('starts an open question activity with subject and knowledge unit', () async {
    final adapter = CapturingHttpClientAdapter(
      jsonResponse(openQuestionStartJson()),
    );
    final dio = Dio()..httpClientAdapter = adapter;
    final api = HttpActivitiesApi(
      dio: dio,
      getIdToken: () async => 'firebase-id-token',
    );

    final activity = await api.startOpenQuestion(
      subjectId: 'subject-1',
      knowledgeUnitId: 'unit-1',
    );

    expect(activity.sessionId, 'open-session-1');
    expect(activity.type, 'open_question');
    expect(activity.version, 1);
    expect(activity.documentId, 'document-1');
    expect(activity.subjectId, 'subject-1');
    expect(activity.knowledgeUnitId, 'unit-1');
    expect(activity.question.id, 'open-question-1');
    expect(activity.question.prompt, 'Explique la séparation des pouvoirs.');
    expect(activity.question.instructions, 'Réponds en quelques phrases.');
    expect(activity.question.maxAnswerLength, 4000);
    expect(activity.question.sources.single.chunkId, 'chunk-1');
    expect(activity.question.sources.single.pageNumber, isNull);
    expect(activity.question.sources.single.index, 0);
    expect(adapter.lastOptions?.path, '/activities/open-question');
    expect(adapter.lastOptions?.data, {
      'subjectId': 'subject-1',
      'knowledgeUnitId': 'unit-1',
    });
  });

  test('parses an open question activity without document', () async {
    final adapter = CapturingHttpClientAdapter(
      jsonResponse(openQuestionStartJson(documentId: null)),
    );
    final dio = Dio()..httpClientAdapter = adapter;
    final api = HttpActivitiesApi(
      dio: dio,
      getIdToken: () async => 'firebase-id-token',
    );

    final activity = await api.startOpenQuestion(
      subjectId: 'subject-1',
      knowledgeUnitId: 'unit-1',
    );

    expect(activity.documentId, isNull);
    expect(activity.question.sources.single.chunkId, 'chunk-1');
  });

  test('ignores source text in open question pre-submit payload', () async {
    final adapter = CapturingHttpClientAdapter(
      jsonResponse(openQuestionStartJson(includeSourceText: true)),
    );
    final dio = Dio()..httpClientAdapter = adapter;
    final api = HttpActivitiesApi(
      dio: dio,
      getIdToken: () async => 'firebase-id-token',
    );

    final activity = await api.startOpenQuestion(
      subjectId: 'subject-1',
      knowledgeUnitId: 'unit-1',
    );

    expect(activity.question.sources.single, isA<OpenQuestionSource>());
    expect(activity.question.sources.single.chunkId, 'chunk-1');
  });

  test('submits an open answer and parses a READY evaluation', () async {
    final adapter = CapturingHttpClientAdapter(
      jsonResponse(openAnswerReadyJson()),
    );
    final dio = Dio()..httpClientAdapter = adapter;
    final api = HttpActivitiesApi(
      dio: dio,
      getIdToken: () async => 'firebase-id-token',
    );

    final result = await api.submitOpenAnswer(
      sessionId: 'open-session-1',
      answerText: 'La séparation des pouvoirs limite chaque autorité.',
    );
    final evaluation = result.evaluation;

    expect(result.sessionId, 'open-session-1');
    expect(result.type, 'open_question');
    expect(result.status, 'submitted');
    expect(evaluation.status, OpenAnswerEvaluationStatus.ready);
    expect(evaluation.score, 16);
    expect(evaluation.maxScore, 20);
    expect(evaluation.feedback, 'Réponse solide.');
    expect(evaluation.presentPoints, ['Définition correcte']);
    expect(evaluation.missingPoints, ['Exemple jurisprudentiel']);
    expect(evaluation.errors, isEmpty);
    expect(evaluation.modelAnswer, 'Modèle de réponse.');
    expect(evaluation.advice, 'Ajoute un exemple.');
    expect(evaluation.sources.single.text, 'Extrait source post-submit.');
    expect(adapter.lastOptions?.path, '/activities/open-session-1/open-answer');
    expect(adapter.lastOptions?.data, {
      'answerText': 'La séparation des pouvoirs limite chaque autorité.',
    });
  });

  test('submits an open answer and parses a FAILED evaluation', () async {
    final adapter = CapturingHttpClientAdapter(
      jsonResponse(openAnswerFailedJson()),
    );
    final dio = Dio()..httpClientAdapter = adapter;
    final api = HttpActivitiesApi(
      dio: dio,
      getIdToken: () async => 'firebase-id-token',
    );

    final result = await api.submitOpenAnswer(
      sessionId: 'open-session-1',
      answerText: 'La séparation des pouvoirs limite chaque autorité.',
    );

    expect(result.evaluation.status, OpenAnswerEvaluationStatus.failed);
    expect(result.evaluation.score, isNull);
    expect(result.evaluation.feedback, isNull);
    expect(result.evaluation.errors, ['OPEN_ANSWER_EVALUATION_FAILED']);
    expect(result.evaluation.sources, isEmpty);
  });

  test('maps null open answer lists to empty lists', () async {
    final readyJson = openAnswerReadyJson()
      ..['evaluation'] = {
        'id': 'evaluation-1',
        'status': 'READY',
        'score': 12,
        'maxScore': 20,
        'feedback': 'Réponse exploitable.',
        'presentPoints': null,
        'missingPoints': null,
        'errors': null,
        'modelAnswer': null,
        'advice': null,
        'sources': null,
      };
    final adapter = CapturingHttpClientAdapter(jsonResponse(readyJson));
    final dio = Dio()..httpClientAdapter = adapter;
    final api = HttpActivitiesApi(
      dio: dio,
      getIdToken: () async => 'firebase-id-token',
    );

    final result = await api.submitOpenAnswer(
      sessionId: 'open-session-1',
      answerText: 'La séparation des pouvoirs limite chaque autorité.',
    );

    expect(result.evaluation.presentPoints, isEmpty);
    expect(result.evaluation.missingPoints, isEmpty);
    expect(result.evaluation.errors, isEmpty);
    expect(result.evaluation.sources, isEmpty);
  });

  test('rejects unknown open question activity types', () async {
    final json = openQuestionStartJson()..['type'] = 'diagnostic_quiz';
    final adapter = CapturingHttpClientAdapter(jsonResponse(json));
    final dio = Dio()..httpClientAdapter = adapter;
    final api = HttpActivitiesApi(
      dio: dio,
      getIdToken: () async => 'firebase-id-token',
    );

    await expectLater(
      api.startOpenQuestion(subjectId: 'subject-1', knowledgeUnitId: 'unit-1'),
      throwsFormatException,
    );
  });

  test(
    'parses an enriched pre-submit quiz without correction fields',
    () async {
      final adapter = CapturingHttpClientAdapter(
        jsonResponse(enrichedActivityJsonWithAccidentalCorrection()),
      );
      final dio = Dio()..httpClientAdapter = adapter;
      final api = HttpActivitiesApi(
        dio: dio,
        getIdToken: () async => 'firebase-id-token',
      );

      final activity = await api.startNextActivity(subjectId: 'subject-1');
      final question = activity.questions.single;

      expect(activity.version, 2);
      expect(activity.documentId, 'document-1');
      expect(activity.subjectId, 'subject-1');
      expect(question.knowledgeUnitId, 'unit-1');
      expect(question.difficulty, 'MEDIUM');
      expect(question.sources.single.chunkId, 'chunk-1');
      expect(question.sources.single.pageNumber, isNull);
      expect(question.sources.single.index, 0);
      expect(question.choices.single.label, 'Réponse A');
    },
  );

  test(
    'parses a v3 quiz with multiple selection and bounded visuals',
    () async {
      final adapter = CapturingHttpClientAdapter(
        jsonResponse(v3ActivityJsonWithAccidentalCorrection()),
      );
      final dio = Dio()..httpClientAdapter = adapter;
      final api = HttpActivitiesApi(
        dio: dio,
        getIdToken: () async => 'firebase-id-token',
      );

      final activity = await api.startNextActivity(subjectId: 'subject-1');
      final question = activity.questions.single;
      final chart = question.visuals
          .whereType<DiagnosticQuizChartVisual>()
          .single;
      final diagram = question.visuals
          .whereType<DiagnosticQuizDiagramVisual>()
          .single;

      expect(activity.version, 3);
      expect(question.selectionMode, DiagnosticQuizSelectionMode.multiple);
      expect(question.minSelections, 1);
      expect(question.maxSelections, 2);
      expect(question.visuals, hasLength(3));
      expect(chart.title, 'Contrôles');
      expect(chart.chartType, DiagnosticQuizChartType.bar);
      expect(chart.data.single['value'], 2);
      expect(chart.sources.single.chunkId, 'chunk-1');
      expect(diagram.nodes.map((node) => node.label), ['Pouvoir', 'Contrôle']);
      expect(diagram.edges.single.label, 'limite');
      expect(
        question.visuals
            .whereType<DiagnosticQuizUnsupportedVisual>()
            .single
            .type,
        'IMAGE',
      );
      expect(question.choices.map((choice) => choice.label), [
        'Contrôle juridictionnel',
        'Pouvoir absolu',
        'Séparation des pouvoirs',
      ]);
    },
  );

  test('submits answers and maps the public score', () async {
    final adapter = CapturingHttpClientAdapter(
      jsonResponse({'correctAnswers': 1, 'totalQuestions': 2}),
    );
    final dio = Dio()..httpClientAdapter = adapter;
    final api = HttpActivitiesApi(
      dio: dio,
      getIdToken: () async => 'firebase-id-token',
    );

    final result = await api.submitResult(
      sessionId: 'session-1',
      answers: const [
        DiagnosticQuizAnswer(questionId: 'question-1', choiceId: 'a'),
      ],
    );

    expect(result.correctAnswers, 1);
    expect(result.items, isEmpty);
    expect(adapter.lastOptions?.path, '/activities/session-1/result');
    expect(adapter.lastOptions?.data, {
      'answers': [
        {'questionId': 'question-1', 'choiceId': 'a'},
      ],
    });
  });

  test(
    'submits single and multiple answers with distinct payload shapes',
    () async {
      final adapter = CapturingHttpClientAdapter(
        jsonResponse({'correctAnswers': 2, 'totalQuestions': 2}),
      );
      final dio = Dio()..httpClientAdapter = adapter;
      final api = HttpActivitiesApi(
        dio: dio,
        getIdToken: () async => 'firebase-id-token',
      );

      await api.submitResult(
        sessionId: 'session-1',
        answers: const [
          DiagnosticQuizAnswer(questionId: 'question-single', choiceId: 'a'),
          DiagnosticQuizAnswer(
            questionId: 'question-multiple',
            choiceIds: ['a', 'c'],
          ),
        ],
      );

      expect(adapter.lastOptions?.data, {
        'answers': [
          {'questionId': 'question-single', 'choiceId': 'a'},
          {
            'questionId': 'question-multiple',
            'choiceIds': ['a', 'c'],
          },
        ],
      });
    },
  );

  test(
    'parses enriched correction result with score feedback and sources',
    () async {
      final adapter = CapturingHttpClientAdapter(
        jsonResponse(enrichedResultJson()),
      );
      final dio = Dio()..httpClientAdapter = adapter;
      final api = HttpActivitiesApi(
        dio: dio,
        getIdToken: () async => 'firebase-id-token',
      );

      final result = await api.submitResult(
        sessionId: 'session-1',
        answers: const [
          DiagnosticQuizAnswer(questionId: 'question-1', choiceId: 'b'),
        ],
      );
      final item = result.items.single;

      expect(result.correctAnswers, 0);
      expect(result.totalQuestions, 1);
      expect(result.score, 0);
      expect(item.questionId, 'question-1');
      expect(item.knowledgeUnitId, 'unit-1');
      expect(item.selectedChoiceId, 'b');
      expect(item.correctChoiceId, 'a');
      expect(item.isCorrect, isFalse);
      expect(item.explanation, 'Le myocarde assure la contraction.');
      expect(item.choiceFeedback.single.choiceId, 'b');
      expect(item.sources.single.text, 'Le myocarde est le muscle cardiaque.');
    },
  );

  test('parses v3 multiple correction result', () async {
    final adapter = CapturingHttpClientAdapter(
      jsonResponse(v3MultipleResultJson()),
    );
    final dio = Dio()..httpClientAdapter = adapter;
    final api = HttpActivitiesApi(
      dio: dio,
      getIdToken: () async => 'firebase-id-token',
    );

    final result = await api.submitResult(
      sessionId: 'session-1',
      answers: const [
        DiagnosticQuizAnswer(
          questionId: 'question-multiple',
          choiceIds: ['a', 'c'],
        ),
      ],
    );
    final item = result.items.single;

    expect(item.selectedChoiceId, isNull);
    expect(item.correctChoiceId, isNull);
    expect(item.selectedChoiceIds, ['a', 'c']);
    expect(item.correctChoiceIds, ['a', 'b']);
    expect(item.partialScore, 0.5);
    expect(item.sources.single.text, 'Source textuelle après submit.');
  });

  test(
    'rejects invalid activity JSON with a controlled format error',
    () async {
      final adapter = CapturingHttpClientAdapter(jsonResponse({'bad': true}));
      final dio = Dio()..httpClientAdapter = adapter;
      final api = HttpActivitiesApi(
        dio: dio,
        getIdToken: () async => 'firebase-id-token',
      );

      await expectLater(
        api.startNextActivity(subjectId: 'subject-1'),
        throwsFormatException,
      );
    },
  );

  test('rejects blank Firebase ID tokens before calling the API', () async {
    final adapter = CapturingHttpClientAdapter(jsonResponse(activityJson()));
    final dio = Dio()..httpClientAdapter = adapter;
    final api = HttpActivitiesApi(dio: dio, getIdToken: () async => '  ');

    await expectLater(
      api.startNextActivity(subjectId: 'subject-1'),
      throwsStateError,
    );

    expect(adapter.fetchCallCount, 0);
  });
}

Map<String, Object?> activityJson() {
  return {
    'sessionId': 'session-1',
    'type': 'diagnostic_quiz',
    'title': 'Diagnostic rapide',
    'questions': [
      {
        'id': 'question-1',
        'prompt': 'Question test',
        'choices': [
          {'id': 'a', 'label': 'Reponse A'},
          {'id': 'b', 'label': 'Reponse B'},
        ],
      },
    ],
  };
}

Map<String, Object?> openQuestionStartJson({
  Object? documentId = 'document-1',
  bool includeSourceText = false,
}) {
  return {
    'sessionId': 'open-session-1',
    'type': 'open_question',
    'version': 1,
    'subjectId': 'subject-1',
    'documentId': documentId,
    'knowledgeUnitId': 'unit-1',
    'question': {
      'id': 'open-question-1',
      'prompt': 'Explique la séparation des pouvoirs.',
      'instructions': 'Réponds en quelques phrases.',
      'maxAnswerLength': 4000,
      'sources': [
        {
          'chunkId': 'chunk-1',
          'pageNumber': null,
          'index': 0,
          if (includeSourceText) 'text': 'Ne doit pas fuiter pré-submit.',
        },
      ],
    },
  };
}

Map<String, Object?> openAnswerReadyJson() {
  return {
    'sessionId': 'open-session-1',
    'type': 'open_question',
    'status': 'submitted',
    'evaluation': {
      'id': 'evaluation-1',
      'status': 'READY',
      'score': 16,
      'maxScore': 20,
      'feedback': 'Réponse solide.',
      'presentPoints': ['Définition correcte'],
      'missingPoints': ['Exemple jurisprudentiel'],
      'errors': [],
      'modelAnswer': 'Modèle de réponse.',
      'advice': 'Ajoute un exemple.',
      'sources': [
        {
          'chunkId': 'chunk-1',
          'text': 'Extrait source post-submit.',
          'pageNumber': null,
          'index': 0,
        },
      ],
    },
  };
}

Map<String, Object?> openAnswerFailedJson() {
  return {
    'sessionId': 'open-session-1',
    'type': 'open_question',
    'status': 'submitted',
    'evaluation': {
      'id': 'evaluation-1',
      'status': 'FAILED',
      'score': null,
      'maxScore': null,
      'feedback': null,
      'presentPoints': [],
      'missingPoints': [],
      'errors': ['OPEN_ANSWER_EVALUATION_FAILED'],
      'modelAnswer': null,
      'advice': null,
      'sources': [],
    },
  };
}

Map<String, Object?> enrichedActivityJsonWithAccidentalCorrection() {
  return {
    'sessionId': 'session-1',
    'type': 'diagnostic_quiz',
    'version': 2,
    'documentId': 'document-1',
    'subjectId': 'subject-1',
    'title': 'Diagnostic sourcé',
    'questions': [
      {
        'id': 'question-1',
        'knowledgeUnitId': 'unit-1',
        'prompt': 'Question test',
        'difficulty': 'MEDIUM',
        'correctChoiceId': 'a',
        'isCorrect': true,
        'explanation': 'Ne doit jamais être mappée avant submit.',
        'choices': [
          {
            'id': 'a',
            'label': 'Réponse A',
            'feedback': 'Ne doit jamais être mappé avant submit.',
          },
        ],
        'sources': [
          {
            'chunkId': 'chunk-1',
            'pageNumber': null,
            'index': 0,
            'text': 'Ne doit pas être lu avant submit.',
          },
        ],
      },
    ],
  };
}

Map<String, Object?> v3ActivityJsonWithAccidentalCorrection() {
  return {
    'sessionId': 'session-v3',
    'type': 'diagnostic_quiz',
    'version': 3,
    'documentId': 'document-1',
    'subjectId': 'subject-1',
    'title': 'Diagnostic v3',
    'questions': [
      {
        'id': 'question-multiple',
        'knowledgeUnitId': 'unit-1',
        'prompt': 'Quels éléments contrôlent le pouvoir ?',
        'difficulty': 'MEDIUM',
        'selectionMode': 'multiple',
        'minSelections': 1,
        'maxSelections': 2,
        'correctChoiceIds': ['a', 'c'],
        'explanation': 'Ne doit jamais être mappée avant submit.',
        'choices': [
          {
            'id': 'a',
            'label': 'Contrôle juridictionnel',
            'feedback': 'Ne doit jamais être mappé avant submit.',
          },
          {'id': 'b', 'label': 'Pouvoir absolu'},
          {'id': 'c', 'label': 'Séparation des pouvoirs'},
        ],
        'sources': [
          {
            'chunkId': 'chunk-1',
            'pageNumber': null,
            'index': 0,
            'text': 'Ne doit pas être lu avant submit.',
          },
        ],
        'visuals': [
          {
            'id': 'visual-chart',
            'type': 'CHART',
            'displayOrder': 0,
            'chartType': 'bar',
            'title': 'Contrôles',
            'description': 'Répartition des éléments',
            'data': [
              {'category': 'Contrôle', 'value': 2},
            ],
            'xKey': 'category',
            'yKeys': ['value'],
            'sources': [
              {'chunkId': 'chunk-1', 'pageNumber': null, 'index': 0},
            ],
          },
          {
            'id': 'visual-diagram',
            'type': 'DIAGRAM',
            'displayOrder': 1,
            'title': 'Relations',
            'nodes': [
              {'id': 'n1', 'label': 'Pouvoir'},
              {'id': 'n2', 'label': 'Contrôle'},
            ],
            'edges': [
              {'from': 'n1', 'to': 'n2', 'label': 'limite'},
            ],
            'sources': [
              {'chunkId': 'chunk-1', 'pageNumber': null, 'index': 0},
            ],
          },
          {
            'id': 'visual-image',
            'type': 'IMAGE',
            'displayOrder': 2,
            'sources': [
              {'chunkId': 'chunk-1', 'pageNumber': null, 'index': 0},
            ],
          },
        ],
      },
    ],
  };
}

Map<String, Object?> enrichedResultJson() {
  return {
    'correctAnswers': 0,
    'totalQuestions': 1,
    'score': 0.0,
    'items': [
      {
        'questionId': 'question-1',
        'knowledgeUnitId': 'unit-1',
        'prompt': 'Question test',
        'selectedChoiceId': 'b',
        'correctChoiceId': 'a',
        'isCorrect': false,
        'explanation': 'Le myocarde assure la contraction.',
        'choiceFeedback': [
          {'choiceId': 'b', 'feedback': 'Le péricarde protège le coeur.'},
        ],
        'sources': [
          {
            'chunkId': 'chunk-1',
            'text': 'Le myocarde est le muscle cardiaque.',
            'pageNumber': null,
            'index': 0,
          },
        ],
      },
    ],
  };
}

Map<String, Object?> v3MultipleResultJson() {
  return {
    'correctAnswers': 0,
    'totalQuestions': 1,
    'score': 0.0,
    'items': [
      {
        'questionId': 'question-multiple',
        'knowledgeUnitId': 'unit-1',
        'prompt': 'Quels éléments contrôlent le pouvoir ?',
        'selectedChoiceIds': ['a', 'c'],
        'correctChoiceIds': ['a', 'b'],
        'isCorrect': false,
        'partialScore': 0.5,
        'explanation': 'Explication post-submit.',
        'choiceFeedback': [
          {'choiceId': 'c', 'feedback': 'Feedback post-submit.'},
        ],
        'sources': [
          {
            'chunkId': 'chunk-1',
            'text': 'Source textuelle après submit.',
            'pageNumber': null,
            'index': 0,
          },
        ],
      },
    ],
  };
}

ResponseBody jsonResponse(Object body) {
  return ResponseBody.fromString(
    jsonEncode(body),
    200,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );
}

````

### Modifié — `test/features/activities/activity_controller_test.dart`

````dart
import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:revision_app/features/activities/application/activity_controller.dart';
import 'package:revision_app/features/activities/domain/diagnostic_quiz_activity.dart';
import 'package:revision_app/features/activities/domain/open_question_activity.dart';

class FakeActivityApi implements ActivityApi {
  String? startedSubjectId;
  List<DiagnosticQuizAnswer>? submittedAnswers;
  String? startedOpenQuestionSubjectId;
  String? startedOpenQuestionKnowledgeUnitId;
  String? submittedOpenAnswerText;
  int submitCallCount = 0;
  int openAnswerSubmitCallCount = 0;
  Completer<DiagnosticQuizResult>? submitCompleter;
  Completer<OpenAnswerSubmissionResult>? openAnswerSubmitCompleter;
  Object? submitError;
  Object? openAnswerSubmitError;

  @override
  Future<DiagnosticQuizActivity> startNextActivity({
    required String subjectId,
    String? knowledgeUnitId,
  }) async {
    startedSubjectId = subjectId;

    return const DiagnosticQuizActivity(
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
    );
  }

  @override
  Future<DiagnosticQuizResult> submitResult({
    required String sessionId,
    required List<DiagnosticQuizAnswer> answers,
  }) async {
    submitCallCount += 1;
    submittedAnswers = answers;

    if (submitError != null) {
      throw submitError!;
    }

    final completer = submitCompleter;
    if (completer != null) {
      return completer.future;
    }

    return const DiagnosticQuizResult(correctAnswers: 1, totalQuestions: 1);
  }

  @override
  Future<OpenQuestionActivity> startOpenQuestion({
    required String subjectId,
    required String knowledgeUnitId,
  }) async {
    startedOpenQuestionSubjectId = subjectId;
    startedOpenQuestionKnowledgeUnitId = knowledgeUnitId;

    return openQuestionActivity();
  }

  @override
  Future<OpenAnswerSubmissionResult> submitOpenAnswer({
    required String sessionId,
    required String answerText,
  }) async {
    openAnswerSubmitCallCount += 1;
    submittedOpenAnswerText = answerText;

    if (openAnswerSubmitError != null) {
      throw openAnswerSubmitError!;
    }

    final completer = openAnswerSubmitCompleter;
    if (completer != null) {
      return completer.future;
    }

    return openAnswerReadyResult();
  }
}

void main() {
  test('loads the next diagnostic activity', () async {
    final api = FakeActivityApi();
    final controller = ActivityController(api);

    final activity = await controller.startNextActivity(
      subjectId: ' subject-1 ',
    );

    expect(activity.sessionId, 'session-1');
    expect(activity.questions.single.choices, hasLength(2));
    expect(api.startedSubjectId, 'subject-1');
  });

  test('submits selected answers to the activity api', () async {
    final api = FakeActivityApi();
    final controller = ActivityController(api);

    final result = await controller.submitResult(
      sessionId: 'session-1',
      answers: const [
        DiagnosticQuizAnswer(questionId: 'question-1', choiceId: 'a'),
      ],
    );

    expect(api.submittedAnswers, hasLength(1));
    expect(api.submittedAnswers?.single.choiceId, 'a');
    expect(result.correctAnswers, 1);
  });

  test('loads an open question activity', () async {
    final api = FakeActivityApi();
    final controller = ActivityController(api);

    final activity = await controller.startOpenQuestion(
      subjectId: ' subject-1 ',
      knowledgeUnitId: ' unit-1 ',
    );

    expect(activity.sessionId, 'open-session-1');
    expect(activity.question.prompt, 'Explique la séparation des pouvoirs.');
    expect(api.startedOpenQuestionSubjectId, 'subject-1');
    expect(api.startedOpenQuestionKnowledgeUnitId, 'unit-1');
  });

  test('submits an open answer through the activity api', () async {
    final api = FakeActivityApi();
    final controller = ActivityController(api);

    final result = await controller.submitOpenAnswer(
      sessionId: 'open-session-1',
      answerText: ' La séparation des pouvoirs limite chaque autorité. ',
    );

    expect(api.submittedOpenAnswerText, 'La séparation des pouvoirs limite chaque autorité.');
    expect(result.evaluation.status, OpenAnswerEvaluationStatus.ready);
  });

  test('manages selected answers and enriched correction state', () async {
    final controller = DiagnosticQuizSessionController(
      activity: longActivity(questionCount: 2),
      submitter: (answers) async {
        return DiagnosticQuizResult(
          correctAnswers: 1,
          totalQuestions: 2,
          score: 0.5,
          items: [
            DiagnosticQuizCorrectionItem(
              questionId: 'question-1',
              knowledgeUnitId: 'unit-1',
              prompt: 'Question 1',
              selectedChoiceId: 'a',
              correctChoiceId: 'b',
              isCorrect: false,
              explanation: 'Explication sourcée.',
              choiceFeedback: const [
                DiagnosticQuizChoiceFeedback(
                  choiceId: 'a',
                  feedback: 'Distracteur plausible.',
                ),
              ],
              sources: const [
                DiagnosticQuizCorrectionSource(
                  chunkId: 'chunk-1',
                  text: 'Source après submit.',
                  pageNumber: null,
                  index: 0,
                ),
              ],
            ),
          ],
        );
      },
    );

    expect(controller.result, isNull);
    expect(controller.canSubmit, isFalse);

    controller.selectChoice(questionId: 'question-1', choiceId: 'a');
    controller.selectChoice(questionId: 'question-1', choiceId: 'b');
    controller.selectChoice(questionId: 'question-2', choiceId: 'a');

    expect(controller.selectedChoiceIdFor('question-1'), 'b');
    expect(controller.canSubmit, isTrue);

    await controller.submit();

    expect(controller.result?.score, 0.5);
    expect(controller.result?.items.single.explanation, 'Explication sourcée.');
  });

  test('manages multiple selections and submits choiceIds', () async {
    List<DiagnosticQuizAnswer>? submittedAnswers;
    final controller = DiagnosticQuizSessionController(
      activity: multipleActivity(),
      submitter: (answers) async {
        submittedAnswers = answers;

        return const DiagnosticQuizResult(correctAnswers: 1, totalQuestions: 1);
      },
    );

    expect(controller.canSubmit, isFalse);

    controller.selectChoice(questionId: 'question-multiple', choiceId: 'a');
    controller.selectChoice(questionId: 'question-multiple', choiceId: 'c');
    controller.selectChoice(questionId: 'question-multiple', choiceId: 'b');

    expect(controller.selectedChoiceIdsFor('question-multiple'), ['a', 'c']);
    expect(controller.canSubmit, isTrue);

    controller.selectChoice(questionId: 'question-multiple', choiceId: 'a');

    expect(controller.selectedChoiceIdsFor('question-multiple'), ['c']);
    expect(controller.canSubmit, isTrue);

    await controller.submit();

    expect(submittedAnswers?.single.choiceId, isNull);
    expect(submittedAnswers?.single.choiceIds, ['c']);
  });

  test('requires the minimum selection count for multiple questions', () async {
    final controller = DiagnosticQuizSessionController(
      activity: multipleActivity(minSelections: 2, maxSelections: 3),
      submitter: (_) async =>
          const DiagnosticQuizResult(correctAnswers: 1, totalQuestions: 1),
    );

    controller.selectChoice(questionId: 'question-multiple', choiceId: 'a');

    expect(controller.answeredCount, 0);
    expect(controller.canSubmit, isFalse);

    controller.selectChoice(questionId: 'question-multiple', choiceId: 'c');

    expect(controller.answeredCount, 1);
    expect(controller.canSubmit, isTrue);
  });

  test('prevents duplicate submit while a submission is running', () async {
    final completer = Completer<DiagnosticQuizResult>();
    var submitCount = 0;
    final controller = DiagnosticQuizSessionController(
      activity: longActivity(questionCount: 1),
      submitter: (answers) {
        submitCount += 1;
        return completer.future;
      },
    );

    controller.selectChoice(questionId: 'question-1', choiceId: 'a');

    final firstSubmit = controller.submit();
    final secondSubmit = controller.submit();

    expect(submitCount, 1);

    completer.complete(
      const DiagnosticQuizResult(correctAnswers: 1, totalQuestions: 1),
    );
    await Future.wait([firstSubmit, secondSubmit]);

    expect(controller.isSubmitting, isFalse);
    expect(controller.result?.correctAnswers, 1);
  });

  test('keeps submit errors visible and supports long quizzes', () async {
    final controller = DiagnosticQuizSessionController(
      activity: longActivity(questionCount: 15),
      submitter: (_) async => throw StateError('Activity already completed'),
    );

    for (var index = 1; index <= 15; index += 1) {
      controller.selectChoice(questionId: 'question-$index', choiceId: 'a');
    }

    expect(controller.answeredCount, 15);
    expect(controller.canSubmit, isTrue);

    await controller.submit();

    expect(controller.result, isNull);
    expect(controller.submitError, isA<StateError>());
  });

  test('manages open answer validation and READY correction state', () async {
    final controller = OpenQuestionSessionController(
      activity: openQuestionActivity(),
      submitter: (answerText) async => openAnswerReadyResult(),
    );

    expect(controller.canSubmit, isFalse);
    expect(controller.validationMessage, 'Réponse trop courte');

    controller.updateAnswer('Réponse assez longue.');

    expect(controller.canSubmit, isTrue);
    expect(controller.answerText, 'Réponse assez longue.');

    await controller.submit();

    expect(controller.result?.evaluation.status, OpenAnswerEvaluationStatus.ready);
    expect(controller.result?.evaluation.feedback, 'Réponse solide.');
    expect(controller.canSubmit, isFalse);
  });

  test('blocks open answers that exceed max length', () {
    final controller = OpenQuestionSessionController(
      activity: openQuestionActivity(maxAnswerLength: 20),
      submitter: (answerText) async => openAnswerReadyResult(),
    );

    controller.updateAnswer('Une réponse beaucoup trop longue pour la limite.');

    expect(controller.canSubmit, isFalse);
    expect(controller.validationMessage, 'Réponse trop longue');
  });

  test('stores FAILED open answer evaluations', () async {
    final controller = OpenQuestionSessionController(
      activity: openQuestionActivity(),
      submitter: (answerText) async => openAnswerFailedResult(),
    );

    controller.updateAnswer('Réponse assez longue.');

    await controller.submit();

    expect(controller.result?.evaluation.status, OpenAnswerEvaluationStatus.failed);
    expect(controller.submitError, isNull);
  });

  test('keeps the open answer text when submit fails', () async {
    final controller = OpenQuestionSessionController(
      activity: openQuestionActivity(),
      submitter: (_) async => throw StateError('network failed'),
    );

    controller.updateAnswer('Réponse assez longue.');

    await controller.submit();

    expect(controller.result, isNull);
    expect(controller.answerText, 'Réponse assez longue.');
    expect(controller.submitError, isA<StateError>());
    expect(controller.submitErrorMessage, contains('peut-être été enregistrée'));
  });

  test('prevents duplicate open answer submit while running', () async {
    final completer = Completer<OpenAnswerSubmissionResult>();
    var submitCount = 0;
    final controller = OpenQuestionSessionController(
      activity: openQuestionActivity(),
      submitter: (_) {
        submitCount += 1;
        return completer.future;
      },
    );

    controller.updateAnswer('Réponse assez longue.');

    final firstSubmit = controller.submit();
    final secondSubmit = controller.submit();

    expect(submitCount, 1);

    completer.complete(openAnswerReadyResult());
    await Future.wait([firstSubmit, secondSubmit]);

    expect(controller.isSubmitting, isFalse);
    expect(controller.result?.evaluation.status, OpenAnswerEvaluationStatus.ready);
  });
}

DiagnosticQuizActivity multipleActivity({
  int minSelections = 1,
  int maxSelections = 2,
}) {
  return DiagnosticQuizActivity(
    sessionId: 'session-multiple',
    title: 'Diagnostic multiple',
    questions: [
      DiagnosticQuizQuestion(
        id: 'question-multiple',
        prompt: 'Quels éléments contrôlent le pouvoir ?',
        selectionMode: DiagnosticQuizSelectionMode.multiple,
        minSelections: minSelections,
        maxSelections: maxSelections,
        choices: const [
          DiagnosticQuizChoice(id: 'a', label: 'Contrôle juridictionnel'),
          DiagnosticQuizChoice(id: 'b', label: 'Pouvoir absolu'),
          DiagnosticQuizChoice(id: 'c', label: 'Séparation des pouvoirs'),
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
          knowledgeUnitId: 'unit-$index',
          prompt: 'Question $index',
          difficulty: 'MEDIUM',
          choices: const [
            DiagnosticQuizChoice(id: 'a', label: 'Choix A'),
            DiagnosticQuizChoice(id: 'b', label: 'Choix B'),
          ],
          sources: [
            DiagnosticQuizSourceRef(
              chunkId: 'chunk-$index',
              pageNumber: null,
              index: index - 1,
            ),
          ],
        ),
    ],
  );
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
      errors: [],
      modelAnswer: 'Réponse modèle.',
      advice: 'Ajoute un exemple.',
      sources: [
        OpenAnswerCorrectionSource(
          chunkId: 'chunk-1',
          text: 'Source post-submit.',
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

````

### Créé — `test/features/activities/open_question_page_test.dart`

````dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:revision_app/features/activities/domain/open_question_activity.dart';
import 'package:revision_app/presentation/pages/activities/open_question_page.dart';
import 'package:revision_app/presentation/widgets/revision_button.dart';

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

````

### Modifié — `test/features/documents/document_detail_page_test.dart`

````dart
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:revision_app/features/documents/application/documents_controller.dart';
import 'package:revision_app/features/documents/domain/revision_document.dart';
import 'package:revision_app/presentation/pages/documents/document_detail_page.dart';

class DetailDocumentsApi implements DocumentsApi {
  DetailDocumentsApi({
    required this.document,
    this.knowledgeUnits = const [],
    this.summary,
    this.revisionSheet,
    this.generatedSummary,
    this.generatedRevisionSheet,
    this.error,
    this.summaryError,
    this.revisionSheetError,
  });

  final RevisionDocument document;
  final List<DocumentKnowledgeUnit> knowledgeUnits;
  DocumentSummary? summary;
  RevisionSheet? revisionSheet;
  final DocumentSummary? generatedSummary;
  final RevisionSheet? generatedRevisionSheet;
  final Object? error;
  final Object? summaryError;
  final Object? revisionSheetError;

  @override
  Future<RevisionDocument> getDocument({required String documentId}) async {
    final error = this.error;
    if (error != null) {
      throw error;
    }

    return document;
  }

  @override
  Future<void> deleteDocument({required String documentId}) async {}

  @override
  Future<DocumentKnowledgeUnitsResponse> listDocumentKnowledgeUnits({
    required String documentId,
  }) async {
    return DocumentKnowledgeUnitsResponse(
      documentId: documentId,
      items: knowledgeUnits,
    );
  }

  @override
  Future<DocumentSummary?> getDocumentSummary({
    required String documentId,
  }) async {
    final error = summaryError;
    if (error != null) {
      throw error;
    }

    return summary;
  }

  @override
  Future<DocumentSummary> generateDocumentSummary({
    required String documentId,
  }) async {
    final generated = generatedSummary ?? summary;
    if (generated == null) {
      throw StateError('summary generation failed');
    }
    summary = generated;
    return generated;
  }

  @override
  Future<RevisionSheet?> getRevisionSheet({required String documentId}) async {
    final error = revisionSheetError;
    if (error != null) {
      throw error;
    }

    return revisionSheet;
  }

  @override
  Future<RevisionSheet> generateRevisionSheet({
    required String documentId,
  }) async {
    final generated = generatedRevisionSheet ?? revisionSheet;
    if (generated == null) {
      throw StateError('revision sheet generation failed');
    }
    revisionSheet = generated;
    return generated;
  }

  @override
  Future<List<RevisionDocument>> listSubjectDocuments({
    required String subjectId,
  }) async {
    return [document];
  }

  @override
  Future<RevisionDocument> uploadCoursePdf({
    required String subjectId,
    required String fileName,
    required Uint8List bytes,
  }) {
    throw UnimplementedError();
  }
}

void main() {
  testWidgets('shows a waiting state for processing documents', (tester) async {
    await tester.pumpWidget(
      documentDetailApp(
        document: const RevisionDocument(
          id: 'document-1',
          subjectId: 'subject-1',
          kind: 'COURSE_PDF',
          fileName: 'cours.pdf',
          status: 'PROCESSING',
          mimeType: 'application/pdf',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('cours.pdf'), findsOneWidget);
    expect(find.text('Analyse en cours'), findsWidgets);
    expect(
      find.text('Les notions apparaitront apres le traitement.'),
      findsOneWidget,
    );
  });

  testWidgets('shows failed document errors', (tester) async {
    await tester.pumpWidget(
      documentDetailApp(
        document: const RevisionDocument(
          id: 'document-1',
          subjectId: 'subject-1',
          kind: 'COURSE_PDF',
          fileName: 'cours.pdf',
          status: 'FAILED',
          mimeType: 'application/pdf',
          errorCode: 'KNOWLEDGE_EXTRACTION_FAILED',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Analyse echouee'), findsWidgets);
    expect(find.text('Erreur IA'), findsWidgets);
  });

  testWidgets('shows ready knowledge units and source excerpts', (
    tester,
  ) async {
    await tester.pumpWidget(
      documentDetailApp(
        document: const RevisionDocument(
          id: 'document-1',
          subjectId: 'subject-1',
          kind: 'COURSE_PDF',
          fileName: 'cours.pdf',
          status: 'READY',
          mimeType: 'application/pdf',
        ),
        knowledgeUnits: const [
          DocumentKnowledgeUnit(
            id: 'unit-1',
            title: 'Séparation des pouvoirs',
            summary: 'Résumé court.',
            difficulty: 'MEDIUM',
            displayOrder: 1,
            confidence: 0.84,
            sources: [
              DocumentKnowledgeUnitSource(
                chunkId: 'chunk-1',
                text: 'Extrait source issu du chunk.',
                pageNumber: null,
                index: 0,
              ),
            ],
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Séparation des pouvoirs'), findsOneWidget);
    expect(find.text('Résumé court.'), findsOneWidget);
    expect(find.text('Difficulte moyenne'), findsOneWidget);
    expect(find.text('Confiance 84%'), findsOneWidget);
    expect(find.text('Question ouverte'), findsOneWidget);
    expect(find.text('Extrait source issu du chunk.'), findsOneWidget);
    expect(find.text('Supports IA'), findsOneWidget);
    expect(find.text('Generer le resume'), findsOneWidget);
    expect(find.text('Generer la fiche'), findsOneWidget);
  });

  testWidgets('generates and displays a document summary', (tester) async {
    await tester.pumpWidget(
      documentDetailApp(document: readyDocument(), generatedSummary: summary()),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Generer le resume'));
    await tester.pumpAndSettle();

    expect(find.text('Résumé du cours'), findsOneWidget);
    expect(find.text('Texte synthétique.'), findsOneWidget);
    expect(find.text('Point clé'), findsOneWidget);
    expect(find.text('Extrait summary.'), findsOneWidget);
  });

  testWidgets('generates and displays a revision sheet', (tester) async {
    await tester.pumpWidget(
      documentDetailApp(
        document: readyDocument(),
        generatedRevisionSheet: revisionSheet(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Generer la fiche'));
    await tester.pumpAndSettle();

    expect(find.text('Fiche de révision'), findsOneWidget);
    expect(find.text('Principe clé'), findsOneWidget);
    expect(find.text('Explication structurée.'), findsOneWidget);
    expect(find.text('Extrait fiche.'), findsOneWidget);
  });

  testWidgets('does not show artifact generation CTAs before ready', (
    tester,
  ) async {
    await tester.pumpWidget(
      documentDetailApp(
        document: const RevisionDocument(
          id: 'document-1',
          subjectId: 'subject-1',
          kind: 'COURSE_PDF',
          fileName: 'cours.pdf',
          status: 'PROCESSING',
          mimeType: 'application/pdf',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Generer le resume'), findsNothing);
    expect(find.text('Generer la fiche'), findsNothing);
  });

  testWidgets('shows artifact loading errors without hiding notions', (
    tester,
  ) async {
    await tester.pumpWidget(
      documentDetailApp(
        document: readyDocument(),
        knowledgeUnits: const [
          DocumentKnowledgeUnit(
            id: 'unit-1',
            title: 'Constitution',
            summary: 'Norme fondamentale.',
            sources: [],
          ),
        ],
        summaryError: StateError('summary failed'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Constitution'), findsOneWidget);
    expect(find.text('Impossible de charger les supports IA'), findsOneWidget);
  });

  testWidgets('shows API errors with retry action', (tester) async {
    await tester.pumpWidget(
      documentDetailApp(
        document: const RevisionDocument(
          id: 'document-1',
          subjectId: 'subject-1',
          kind: 'COURSE_PDF',
          fileName: 'cours.pdf',
          status: 'READY',
          mimeType: 'application/pdf',
        ),
        error: StateError('network failed'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Impossible de charger le document'), findsOneWidget);
    expect(find.text('Reessayer'), findsOneWidget);
  });
}

Widget documentDetailApp({
  required RevisionDocument document,
  List<DocumentKnowledgeUnit> knowledgeUnits = const [],
  DocumentSummary? summary,
  RevisionSheet? revisionSheet,
  DocumentSummary? generatedSummary,
  RevisionSheet? generatedRevisionSheet,
  Object? error,
  Object? summaryError,
  Object? revisionSheetError,
}) {
  return MaterialApp(
    home: Scaffold(
      body: DocumentDetailPage(
        documentId: document.id,
        controller: DocumentsController(
          DetailDocumentsApi(
            document: document,
            knowledgeUnits: knowledgeUnits,
            summary: summary,
            revisionSheet: revisionSheet,
            generatedSummary: generatedSummary,
            generatedRevisionSheet: generatedRevisionSheet,
            error: error,
            summaryError: summaryError,
            revisionSheetError: revisionSheetError,
          ),
        ),
      ),
    ),
  );
}

RevisionDocument readyDocument() {
  return const RevisionDocument(
    id: 'document-1',
    subjectId: 'subject-1',
    kind: 'COURSE_PDF',
    fileName: 'cours.pdf',
    status: 'READY',
    mimeType: 'application/pdf',
  );
}

DocumentSummary summary() {
  return const DocumentSummary(
    id: 'summary-1',
    documentId: 'document-1',
    subjectId: 'subject-1',
    status: 'READY',
    title: 'Résumé du cours',
    content: 'Texte synthétique.',
    keyPoints: ['Point clé'],
    limits: 'Limite.',
    errorCode: null,
    sources: [
      DocumentArtifactSource(
        chunkId: 'chunk-1',
        text: 'Extrait summary.',
        pageNumber: null,
        index: 0,
      ),
    ],
  );
}

RevisionSheet revisionSheet() {
  return const RevisionSheet(
    id: 'sheet-1',
    documentId: 'document-1',
    subjectId: 'subject-1',
    status: 'READY',
    title: 'Fiche de révision',
    introduction: "Vue d'ensemble.",
    sections: [
      RevisionSheetSection(
        id: 'section-1',
        displayOrder: 0,
        title: 'Principe clé',
        content: 'Explication structurée.',
        sources: [
          DocumentArtifactSource(
            chunkId: 'chunk-1',
            text: 'Extrait fiche.',
            pageNumber: null,
            index: 0,
          ),
        ],
      ),
    ],
    keyPoints: ['À retenir'],
    commonMistakes: [],
    mustKnow: ['Indispensable'],
    practiceSuggestions: ['Relire la section.'],
    errorCode: null,
  );
}

````

### Modifié — `docs/ROADMAP_EXECUTION_PLAN.md`

````markdown
# Roadmap Execution Plan — Revision App

## 1. But du document

Ce fichier transforme `docs/ROADMAP.md` en lots d'exécution atomiques, ordonnés et validables.

La roadmap existante donne une bonne direction produit et technique. Ce plan ajoute l'ordre d'attaque, les dépendances, les critères de stop, les validations futures et les zones probables à inspecter ou modifier. Il ne remplace pas la roadmap stratégique : il la rend exécutable par petits lots de 0,5 à 2 jours.

Ce document ne prescrit aucune implémentation immédiate. Les lots ci-dessous décrivent le travail futur à réaliser en conservant :

- la Clean Architecture NestJS ;
- les patterns Flutter, Riverpod et GoRouter existants ;
- Genkit côté backend comme moteur IA typé et validé ;
- GenUI côté frontend comme catalogue borné de composants, jamais comme interpréteur libre ;
- l'isolation stricte par `studentId`.

## 2. Lecture critique de la roadmap actuelle

### Ce qui est solide

- La vision produit est claire : importer un cours, extraire des notions, générer des supports, entraîner l'étudiant, corriger et adapter le plan.
- Le pipeline actuel existe déjà : upload PDF, job BullMQ, extraction texte, extraction Genkit, `KnowledgeUnit`, QCM, mastery, `GET /today`.
- L'architecture backend a déjà des ports applicatifs et adapters : repositories Prisma, `DocumentTextExtractor`, `DocumentKnowledgeExtractor`, `DiagnosticQuizGenerator`.
- Le frontend a déjà GoRouter, Riverpod, un shell par onglets persistants, des pages principales et des repositories HTTP.
- Genkit est déjà réellement utilisé, pas seulement installé.
- GenUI est déjà amorcé via un catalogue d'activité, même s'il reste très limité.
- La roadmap identifie bien les grandes fonctionnalités produit : fiches, QCM enrichi, question ouverte, session IA, plan du jour avancé.

### Ce qui est trop large

- Les phases de la roadmap sont trop grosses pour être exécutées telles quelles. Par exemple, “Documents et knowledge units enrichis” mélange extraction, schéma, persistance, API, UI et anti-hallucination.
- “Résumés et fiches” suppose des sources fiables, mais les sources ne sont pas encore stabilisées.
- “Session de révision IA avec GenUI” dépend de composants isolés qui ne sont pas encore conçus, validés ni testés.
- “Plan du jour adaptatif avancé” dépend de nouveaux types d'activités et d'un historique de maîtrise plus riche.
- La phase “Démo, qualité, sécurité et déploiement” arrive trop tard pour l'observabilité Genkit et les limites de coûts.

### Ce qui doit être déplacé plus tôt

- Les fondations documentaires doivent précéder les résumés : `DocumentChunk`, `SourceReference`, liens entre chunks et notions, stratégie anti-hallucination.
- L'observabilité Genkit doit arriver avant les nouveaux flows : nom du flow, provider, modèle, durée, taille input, statut, erreur, version de prompt, version de schéma.
- Le versioning des outputs IA doit être défini avant les nouvelles tables et les nouveaux endpoints.
- La stratégie des artefacts générés doit être décidée tôt : modèles spécialisés (`Summary`, `RevisionSheet`, `OpenAnswerEvaluation`) ou modèle transversal (`GeneratedArtifact`, `AiGenerationJob`) avec relations typées.
- Le golden demo path doit être préparé tôt, car il conditionne le PDF de test, les seeds, les validations manuelles et le récit de démonstration.

### Ce qui doit être repoussé

- La session coach complète doit être retardée. Elle ne doit venir qu'après stabilisation des composants isolés : résumé, source excerpt, QCM, correction et question ouverte.
- Le plan du jour multi-actions avancé doit attendre que les activités et mastery events soient plus riches.
- Les imports OCR, image et audio doivent rester hors MVP tant que les PDF texte ne sont pas robustes.
- La génération libre de widgets doit rester interdite.
- Une refonte UI totale non bornée doit être évitée : il faut avancer par primitives réutilisables et surfaces prioritaires.

### Ce qui manque pour sécuriser la démo

- Un PDF de démonstration connu, texte et stable.
- Un scénario reproductible avec états attendus.
- Des données de seed contrôlées.
- Des contrôles d'ownership sur chaque nouveau endpoint.
- Des tests anti-hallucination sur les références sources.
- Une validation GenUI stricte et testée.
- Des erreurs IA affichables côté produit.
- Des limites de coût, timeout et taille input dès les premiers flows enrichis.

### Points critiques à corriger dans l'ordre d'exécution

- Ne pas demander à l'IA de produire librement des `sourceExcerpt`. Le backend doit découper ou référencer des chunks existants, puis Genkit doit pointer vers ces références quand c'est possible.
- Ne pas laisser coexister deux chemins documentaires flous. Le plan doit trancher tôt entre upload direct backend, Firebase Storage lu par le backend, ou coexistence temporaire documentée.
- Ne pas construire `generateCoachNextActionFlow` avant d'avoir des contrats d'activité stables.
- Ne pas enrichir le QCM sans protéger la non-fuite de `correctChoiceId` avant submit.
- Ne pas rendre des payloads GenUI sans validation stricte côté Flutter.
- Ne pas exposer des contenus générés sans version de schéma et de prompt.

## 3. Principes d'exécution

- Chaque lot doit rester réalisable en environ 0,5 à 2 jours.
- Aucun lot ne doit contenir un refactor massif.
- Aucun commit Git ne doit être fait par défaut.
- Aucun `git commit`, `git amend`, `git merge`, `git rebase`, `git push`, `git tag` ou autre écriture Git ne doit être lancé sans demande explicite.
- Aucun objectif hors lot ne doit être ajouté pendant l'implémentation future.
- Toute modification de code future doit être accompagnée de tests pertinents ou d'une justification explicite.
- Le backend doit continuer à suivre la Clean Architecture NestJS : controller mince, use case applicatif, port, adapter.
- Le frontend doit continuer à utiliser Riverpod pour les états et GoRouter pour la navigation.
- Genkit doit produire des outputs typés, validés et versionnés.
- GenUI doit rester borné par un catalogue strict.
- L'ownership `studentId` doit être vérifié dans chaque nouveau chemin backend.
- Une UI de fallback doit exister quand GenUI ou l'IA échoue.
- Les erreurs IA doivent être explicites, journalisées et traduisibles côté produit.
- Aucun widget arbitraire ne doit être généré par l'IA.
- Les validations doivent être lancées depuis les racines réelles : `api` pour NestJS et `revision_app` pour Flutter.
- Les scripts qui écrivent automatiquement, comme `npm run lint` côté API avec `--fix`, ne doivent pas être utilisés comme validation non destructive ; préférer `npm run lint:check`.

## 4. Découpage macro recommandé

### Bloc A — Audit et vérité projet

Objectif : connaître précisément l'existant avant d'ajouter.

Ce bloc verrouille les contrats actuels, les scripts disponibles, les gaps entre roadmap et code réel, et les décisions structurantes.

### Bloc B — Design system minimal et surfaces premium

Objectif : sortir du Material brut sans refaire toute l'app.

Ce bloc stabilise les primitives Flutter réutilisables, puis les applique seulement aux surfaces prioritaires de la démo.

### Bloc C — Fondations documentaires et sources

Objectif : chunks, source references, knowledge units enrichies, anti-hallucination.

Ce bloc rend possible la génération de fiches et corrections sourcées sans demander à l'IA d'inventer des extraits.

### Bloc D — Détail document et notions côté front

Objectif : rendre le processing IA visible et utile.

Ce bloc expose les notions, statuts, erreurs et sources à l'utilisateur avant d'ajouter des artefacts avancés.

### Bloc E — Observabilité et versioning Genkit

Objectif : rendre les flows IA diagnostiquables dès les premières générations.

Ce bloc doit arriver tôt pour éviter de debuguer les fiches, QCM et corrections à l'aveugle.

### Bloc F — Résumés et fiches

Objectif : premier artefact IA exploitable.

Ce bloc ajoute les résumés et fiches après stabilisation des sources.

### Bloc G — QCM enrichi

Objectif : correction détaillée, feedback, maîtrise.

Ce bloc améliore l'activité existante sans changer tout le modèle d'activité d'un coup.

### Bloc H — Question ouverte corrigée

Objectif : fonctionnalité forte de démonstration.

Ce bloc ajoute l'activité la plus différenciante, mais seulement après les sources et l'observabilité.

### Bloc I — GenUI catalog isolé

Objectif : composants bornés avant la session coach.

Ce bloc stabilise les composants dynamiques un par un.

### Bloc J — Session de révision IA

Objectif : orchestration seulement après stabilisation des briques.

Ce bloc assemble les artefacts et activités existants dans une session coach contrôlée.

### Bloc K — Plan du jour avancé

Objectif : recommandations multi-actions déterministes.

Ce bloc élargit `TodayPlan` quand les actions existent déjà.

### Bloc L — Golden demo, qualité et déploiement

Objectif : rendre la démo reproductible.

Ce bloc ajoute seed, scénario, validations manuelles, runbooks et checks critiques.

## 5. Lots d'exécution ordonnés

### Suivi d'exécution des lots

Ce tableau doit être mis à jour à chaque lot réalisé. Cette règle est également inscrite dans `revision_app/AGENTS.md`.

| Lot | Titre | Statut | Rapport |
| --- | --- | --- | --- |
| LOT-001 | Audit des contrats actuels | Réalisé | `docs/ROADMAP_EXECUTION_LOT_001_001B.md` |
| LOT-001B | Décision stratégie upload et lecture document | Réalisé | `docs/ROADMAP_EXECUTION_LOT_001_001B.md` |
| LOT-002 | Décisions fondations IA et documentaire | Réalisé | `docs/ROADMAP_EXECUTION_LOT_002_002B_003.md` |
| LOT-002B | Revue de schéma avant migrations | Réalisé | `docs/ROADMAP_EXECUTION_LOT_002_002B_003.md` |
| LOT-003 | Golden demo baseline | Réalisé | `docs/ROADMAP_EXECUTION_LOT_002_002B_003.md` |
| LOT-004 | Port d'observabilité Genkit | Réalisé | `docs/ROADMAP_EXECUTION_LOT_004_005.md` |
| LOT-005 | Instrumentation des flows Genkit existants | Réalisé | `docs/ROADMAP_EXECUTION_LOT_004_005.md` |
| LOT-006 | Inventaire design system et surfaces prioritaires | À faire | À créer |
| LOT-007 | Primitives UI minimales pour la démo | À faire | À créer |
| LOT-008 | Application UI ciblée aux pages existantes | À faire | À créer |
| LOT-009 | Modèle documentaire cible détaillé | Réalisé | `docs/ROADMAP_EXECUTION_LOT_009_010_011.md` |
| LOT-010 | Persistance minimale des chunks et sources | Réalisé | `docs/ROADMAP_EXECUTION_LOT_009_010_011.md` |
| LOT-010B | Réparation migration Prisma DocumentChunk / KnowledgeUnitSource | Réalisé | `docs/ROADMAP_EXECUTION_LOT_010B.md` |
| LOT-011 | Chunking PDF dans le worker | Réalisé | `docs/ROADMAP_EXECUTION_LOT_009_010_011.md` |
| LOT-012 | Extraction Genkit v2 basée sur chunks | Réalisé | `docs/ROADMAP_EXECUTION_LOT_012_013.md` |
| LOT-013 | Persistance KnowledgeUnit enrichie | Réalisé | `docs/ROADMAP_EXECUTION_LOT_012_013.md` |
| LOT-014 | API détail document et notions sourcées | Réalisé | `docs/ROADMAP_EXECUTION_LOT_014_015_016.md` |
| LOT-015 | Data layer Flutter pour détail document | Réalisé | `docs/ROADMAP_EXECUTION_LOT_014_015_016.md` |
| LOT-016 | Page détail document et notions | Réalisé | `docs/ROADMAP_EXECUTION_LOT_014_015_016.md` |
| LOT-017 | Contrat artefacts générés | Réalisé | `docs/ROADMAP_EXECUTION_LOT_017.md` |
| LOT-018 | Persistance Summary et RevisionSheet | Réalisé | `docs/ROADMAP_EXECUTION_LOT_018.md` |
| LOT-019 | Flow Genkit résumé et fiche | Réalisé | `docs/ROADMAP_EXECUTION_LOT_019_020.md` |
| LOT-020 | API résumés et fiches | Réalisé | `docs/ROADMAP_EXECUTION_LOT_019_020.md` |
| LOT-021 | UI résumé et fiche | Réalisé | `docs/ROADMAP_EXECUTION_LOT_021_029.md` |
| LOT-022 | Contrat QCM v2 | Réalisé | `docs/ROADMAP_EXECUTION_LOT_022.md` |
| LOT-023 | Genkit QCM enrichi | Réalisé | `docs/ROADMAP_EXECUTION_LOT_023.md` |
| LOT-024 | Persistance et soumission QCM enrichies | Réalisé | `docs/ROADMAP_EXECUTION_LOT_024.md` |
| LOT-025 | UI QCM enrichi | Réalisé | `docs/ROADMAP_EXECUTION_LOT_025.md` |
| LOT-025B | QCM questionCount configurable et contrat média/multi-réponse | Réalisé | `docs/ROADMAP_EXECUTION_LOT_025B_QCM_QUESTION_COUNT_MEDIA_MULTI_CONTRACT.md` |
| LOT-025C | QCM média et multi-réponse : contrat backend | Réalisé | `docs/ROADMAP_EXECUTION_LOT_025C_QCM_MEDIA_MULTI_BACKEND_CONTRACT.md` |
| LOT-025D | QCM média et multi-réponse : backend | Réalisé | `docs/ROADMAP_EXECUTION_LOT_025D_QCM_MEDIA_MULTI_BACKEND.md` |
| LOT-025E | QCM média et multi-réponse : UI | Réalisé | `docs/ROADMAP_EXECUTION_LOT_025E_QCM_MEDIA_MULTI_UI.md` |
| LOT-025F | Validation DB/runtime QCM v3 | Réalisé | `docs/ROADMAP_EXECUTION_LOT_025F_QCM_V3_DB_RUNTIME_VALIDATION.md` |
| LOT-026 | Contrat question ouverte | Réalisé | `docs/ROADMAP_EXECUTION_LOT_026_OPEN_QUESTION_CONTRACT.md` |
| LOT-027 | Genkit question ouverte et correction | Réalisé | `docs/ROADMAP_EXECUTION_LOT_027_OPEN_QUESTION_GENKIT_CORRECTION.md` |
| LOT-028 | UI question ouverte corrigée | Réalisé | `docs/ROADMAP_EXECUTION_LOT_028_OPEN_QUESTION_UI.md` |
| LOT-029 | GenUI composants lecture sourcée | Réalisé | `docs/ROADMAP_EXECUTION_LOT_021_029.md` |
| LOT-030 | GenUI composants activité et correction | Réalisé | `docs/ROADMAP_EXECUTION_LOT_030_GENUI_ACTIVITY_CORRECTION.md` |
| LOT-031 | Session de révision IA minimale | À faire | À créer |
| LOT-032 | Écran Révision IA minimal | À faire | À créer |
| LOT-033 | Orchestration coach Genkit | À faire | À créer |
| LOT-034 | TodayPlan multi-actions backend | À faire | À créer |
| LOT-035 | TodayPage v2 frontend | À faire | À créer |
| LOT-036 | Seed et fixtures de démo | À faire | À créer |
| LOT-037 | Tests e2e critiques et smoke checks | À faire | À créer |
| LOT-038 | Runbook démo et déploiement | À faire | À créer |

### LOT-001 — Audit des contrats actuels

**Bloc :**
Bloc A — Audit et vérité projet.

**Objectif :**
Établir l'inventaire exact des routes, use cases, modèles, providers et tests existants.

**Pourquoi maintenant :**
Le plan doit partir du code réel, pas de la roadmap idéale.

**Périmètre inclus :**

- Cartographier les endpoints backend existants.
- Cartographier les pages et routes Flutter existantes.
- Cartographier les flows Genkit existants.
- Cartographier le catalogue GenUI actuel.
- Lister les tests déjà présents.

**Non-objectifs :**

- Modifier du code.
- Modifier Prisma.
- Ajouter des endpoints.
- Ajouter des composants UI.

**Fichiers ou zones probablement concernés :**

- `api/src/modules/**`
- `api/prisma/schema.prisma`
- `api/package.json`
- `revision_app/lib/app/router/app_router.dart`
- `revision_app/lib/features/**`
- `revision_app/lib/presentation/**`
- `revision_app/test/**`

**Backend :**
Lecture des modules `documents`, `jobs`, `ai`, `activities`, `revision`, `subjects`, `auth`.

**Frontend :**
Lecture des routes, providers, pages, APIs HTTP et composants partagés.

**Genkit :**
Identifier extraction de notions et génération QCM.

**GenUI :**
Identifier le catalogue `revision_activity_catalog.dart` et son validateur.

**Données / Prisma :**
Lecture seule du schéma.

**API :**
Inventaire uniquement.

**Tests futurs attendus :**
Validation documentaire par checklist.

**Commandes de validation futures :**

- `cd api && npm run lint:check`
- `cd api && npm test`
- `cd revision_app && dart analyze lib test`
- `cd revision_app && flutter test`

**Critères d'acceptation :**

- Les endpoints actuels sont listés.
- Les modèles Prisma actuels sont listés.
- Les flows Genkit actuels sont listés.
- Les composants GenUI actuels sont listés.

**Critère de stop :**
Ne pas passer au lot suivant si le schéma Prisma réel ou les routes actuelles n'ont pas été inspectés.

**Risques :**

- Partir sur des noms de modèles qui n'existent pas.
- Écrire un plan incompatible avec les providers actuels.

### LOT-001B — Décision stratégie upload et lecture document

**Bloc :**
Bloc A — Audit et vérité projet.

**Objectif :**
Choisir le chemin officiel de stockage et lecture des documents pour le MVP.

**Pourquoi maintenant :**
Le worker de chunks et d'extraction doit lire le PDF au bon endroit. Si le front upload dans Firebase Storage mais que le worker lit le stockage local backend, le pipeline échoue silencieusement ou part dans deux directions.

**Périmètre inclus :**

- Comparer upload direct backend via `POST /documents/course-pdf`.
- Comparer upload Firebase Storage puis `POST /documents` metadata.
- Vérifier l'implémentation actuelle `LocalDocumentFileStorage`.
- Vérifier le comportement actuel du front multipart.
- Choisir le chemin officiel MVP.
- Documenter le chemin secondaire si on le garde temporairement.

**Non-objectifs :**

- Modifier l'upload.
- Ajouter un adapter Firebase Storage backend.
- Supprimer un endpoint existant.
- Migrer les documents déjà uploadés.

**Fichiers ou zones probablement concernés :**

- `api/src/modules/documents/interfaces/documents.controller.ts`
- `api/src/modules/documents/infrastructure/local-document-file-storage.ts`
- `api/src/modules/jobs/infrastructure/document-processing.consumer.ts`
- `revision_app/lib/features/documents/data/documents_api.dart`
- `revision_app/lib/features/documents/presentation/document_import_button.dart`
- `revision_app/docs/ROADMAP_EXECUTION_PLAN.md`

**Backend :**
Décider quel `DocumentContentReader` est source de vérité pour le worker MVP.

**Frontend :**
Décider si l'upload officiel reste multipart backend ou redevient Firebase Storage.

**Genkit :**
Non concerné.

**GenUI :**
Non concerné.

**Données / Prisma :**
Aucune.

**API :**
Décider le statut de :

- `POST /documents/course-pdf`
- `POST /documents`

**Tests futurs attendus :**
Validation manuelle ou test d'intégration du chemin choisi.

**Commandes de validation futures :**

- `cd api && npm test -- documents`
- `cd revision_app && flutter test test/features/documents`

**Critères d'acceptation :**

- Le chemin officiel MVP est écrit.
- Le worker sait où lire le PDF.
- Le chemin non officiel est explicitement marqué comme legacy, secondaire ou futur.
- Aucun futur lot chunk/worker ne dépend d'une hypothèse implicite.

**Critère de stop :**
Ne pas modifier le pipeline chunks/worker tant que la stratégie de lecture document n'est pas tranchée.

**Risques :**

- Deux chemins d'upload divergents.
- Worker qui lit un fichier absent.
- Documentation contradictoire entre front et back.

### LOT-002 — Décisions fondations IA et documentaire

**Bloc :**
Bloc A — Audit et vérité projet.

**Objectif :**
Décider les options structurantes avant d'ajouter les résumés, fiches et corrections.

**Pourquoi maintenant :**
Les choix `DocumentChunk`, `SourceReference`, `GeneratedArtifact` et `AiGenerationJob` influencent presque tous les lots suivants.

**Périmètre inclus :**

- Comparer modèle spécialisé et modèle transversal pour les artefacts IA.
- Décider si `DocumentChunk` est nécessaire en MVP.
- Décider comment stocker ou référencer les sources.
- Décider si les générations sont synchrones ou asynchrones.
- Documenter les versions de prompt et de schéma.

**Non-objectifs :**

- Écrire la migration Prisma.
- Implémenter les modèles.
- Changer les flows existants.

**Fichiers ou zones probablement concernés :**

- `revision_app/docs/ROADMAP.md`
- `revision_app/docs/ROADMAP_EXECUTION_PLAN.md`
- Futur document ADR dans `docs/` si demandé.

**Backend :**
Définir les options d'architecture.

**Frontend :**
Identifier l'impact sur les DTO affichés.

**Genkit :**
Définir `promptVersion`, `schemaVersion`, provider et modèle comme métadonnées obligatoires.

**GenUI :**
Décider si les payloads GenUI sont stockés comme artefacts ou reconstruits depuis les données métier.

**Données / Prisma :**
Options à comparer :

- modèles spécialisés uniquement ;
- `GeneratedArtifact` transversal ;
- `AiGenerationJob` pour statut et observabilité ;
- combinaison légère : modèles métier + table d'observabilité.

**API :**
Aucun contrat public à ajouter.

**Tests futurs attendus :**
Revue d'architecture.

**Commandes de validation futures :**
Aucune commande obligatoire.

**Critères d'acceptation :**

- Une recommandation est écrite pour chunks, sources et artefacts IA.
- Les décisions reportées sont explicites.
- Les lots suivants savent quelle option suivre.

**Critère de stop :**
Ne pas créer de résumé ou correction IA avant d'avoir choisi une stratégie source et versioning.

**Risques :**

- Sur-modéliser trop tôt.
- Sous-modéliser et rendre les sources impossibles à vérifier.

### LOT-002B — Revue de schéma avant migrations

**Bloc :**
Bloc A — Audit et vérité projet.

**Objectif :**
Regrouper les décisions de schéma avant la première migration documentaire.

**Pourquoi maintenant :**
Les lots futurs peuvent sinon produire une suite de migrations Prisma trop nombreuses : chunks, sources, knowledge units enrichies, summaries, QCM v2, questions ouvertes et sessions.

**Périmètre inclus :**

- Relire les décisions du LOT-001B et du LOT-002.
- Lister les migrations indispensables au MVP Cut 1.
- Lister les migrations à reporter.
- Définir un découpage de migrations cohérent et réversible.
- Vérifier les impacts sur tests Prisma et repositories.

**Non-objectifs :**

- Écrire une migration.
- Modifier `schema.prisma`.
- Générer le client Prisma.
- Ajouter des modèles applicatifs.

**Fichiers ou zones probablement concernés :**

- `api/prisma/schema.prisma`
- `api/src/modules/documents`
- `api/src/modules/revision`
- `api/src/modules/activities`
- `api/src/modules/ai`

**Backend :**
Préparer une séquence de migrations, sans l'exécuter.

**Frontend :**
Identifier les DTO qui dépendront des champs nouveaux.

**Genkit :**
Vérifier que les schémas IA peuvent évoluer sans migration inutile.

**GenUI :**
Non concerné.

**Données / Prisma :**
Décider le minimum migratoire pour le premier cut :

- `DocumentChunk`
- lien notion-source
- champs enrichis `KnowledgeUnit`
- artefacts de fiche si inclus dans MVP Cut 1

**API :**
Aucun.

**Tests futurs attendus :**
Revue de schéma documentée.

**Commandes de validation futures :**
Aucune commande obligatoire.

**Critères d'acceptation :**

- La première migration future a un périmètre clair.
- Les migrations non indispensables sont reportées.
- Les dépendances entre modèles sont explicites.

**Critère de stop :**
Ne pas lancer LOT-010 tant que cette revue n'a pas validé le périmètre migratoire.

**Risques :**

- Trop de migrations successives.
- Coupler le MVP à des modèles de session ou open question trop tôt.

### LOT-003 — Golden demo baseline

**Bloc :**
Bloc L — Golden demo, qualité et déploiement.

**Objectif :**
Définir le PDF de démo, le scénario et les états attendus avant les fonctionnalités avancées.

**Pourquoi maintenant :**
Le PDF de démonstration pilote les tests manuels, les prompts et les exemples de sources.

**Périmètre inclus :**

- Choisir un PDF texte, court, légalement utilisable.
- Définir la matière de démo.
- Définir les états attendus du document.
- Définir les notions attendues approximatives.
- Définir la checklist de démonstration.

**Non-objectifs :**

- Ajouter un seed automatisé.
- Ajouter OCR ou support image.
- Ajouter des fixtures dans le code.

**Fichiers ou zones probablement concernés :**

- `revision_app/docs/`
- `api/README.md`
- Futurs fichiers de seed dans `api/prisma` si validé plus tard.

**Backend :**
Non concerné.

**Frontend :**
Non concerné.

**Genkit :**
Préparer les attentes de sortie pour tests manuels.

**GenUI :**
Non concerné.

**Données / Prisma :**
Aucune.

**API :**
Aucun.

**Tests futurs attendus :**
Checklist manuelle.

**Commandes de validation futures :**
Aucune commande obligatoire.

**Critères d'acceptation :**

- Le PDF de démo est identifié.
- Le scénario de démo initial est écrit.
- Les preuves visuelles attendues sont listées.

**Critère de stop :**
Ne pas écrire de seed ou test e2e de démo sans PDF cible.

**Risques :**

- PDF trop long.
- PDF scanné sans texte.
- Contenu difficile à valider.

### LOT-004 — Port d'observabilité Genkit

**Bloc :**
Bloc E — Observabilité et versioning Genkit.

**Objectif :**
Introduire une interface backend pour tracer les générations IA sans coupler les use cases à un provider.

**Pourquoi maintenant :**
Les prochains flows doivent être observables dès leur création.

**Périmètre inclus :**

- Définir un port applicatif d'observabilité IA.
- Définir les champs obligatoires : flow, provider, model, duration, inputSize, status, error, promptVersion, schemaVersion.
- Ajouter un adapter minimal de log structuré si aucune persistance n'est décidée.
- Préparer les tests unitaires du port.

**Non-objectifs :**

- Ajouter une table Prisma si la décision n'est pas prise.
- Changer tous les flows IA avancés.
- Ajouter un dashboard.

**Fichiers ou zones probablement concernés :**

- `api/src/modules/ai/application`
- `api/src/modules/ai/infrastructure`
- `api/src/modules/ai/ai.module.ts`

**Backend :**
Créer le port et l'adapter d'observabilité.

**Frontend :**
Non concerné.

**Genkit :**
Préparer l'enveloppe de mesure autour des appels `ai.generate`.

**GenUI :**
Non concerné.

**Données / Prisma :**
Aucune au départ, sauf décision contraire du LOT-002.

**API :**
Aucun.

**Tests futurs attendus :**

- Test unitaire de l'adapter.
- Test que les champs obligatoires sont acceptés.

**Commandes de validation futures :**

- `cd api && npm test -- ai`
- `cd api && npm run lint:check`

**Critères d'acceptation :**

- Le backend a un port d'observabilité IA injectable.
- Les champs obligatoires sont documentés.
- Le port interdit explicitement de logger le texte complet du cours, le prompt complet ou la réponse complète du modèle.
- Aucun flow existant n'est cassé.

**Critère de stop :**
Ne pas instrumenter les flows si le port n'est pas testable sans provider externe.

**Risques :**

- Logger des contenus de cours sensibles.
- Rendre le port trop spécifique à Genkit.

### LOT-005 — Instrumentation des flows Genkit existants

**Bloc :**
Bloc E — Observabilité et versioning Genkit.

**Objectif :**
Tracer l'extraction de notions et la génération QCM existantes.

**Pourquoi maintenant :**
Ces flows sont déjà critiques et servent de base aux futures générations.

**Périmètre inclus :**

- Instrumenter `GenkitDocumentKnowledgeExtractor`.
- Instrumenter `GenkitDiagnosticQuizGenerator`.
- Ajouter `promptVersion` et `schemaVersion` constants.
- Mesurer durée et taille d'input.
- Capturer statut succès/échec.

**Non-objectifs :**

- Changer les prompts métier.
- Changer les modèles Prisma.
- Ajouter des nouveaux flows.

**Fichiers ou zones probablement concernés :**

- `api/src/modules/ai/infrastructure/genkit-document-knowledge.extractor.ts`
- `api/src/modules/activities/infrastructure/genkit-diagnostic-quiz.generator.ts`
- `api/src/modules/ai/infrastructure/*.spec.ts`
- `api/src/modules/activities/infrastructure/*.spec.ts`

**Backend :**
Ajouter l'injection du port d'observabilité.

**Frontend :**
Non concerné.

**Genkit :**
Ajouter l'enveloppe de mesure autour de `generate`.

**GenUI :**
Non concerné.

**Données / Prisma :**
Aucune.

**API :**
Aucun.

**Tests futurs attendus :**

- Flow success loggé.
- Flow error loggé.
- Taille input calculée sans stocker le texte complet.

**Commandes de validation futures :**

- `cd api && npm test -- genkit`
- `cd api && npm run lint:check`

**Critères d'acceptation :**

- Les deux flows existants produisent une trace.
- Les traces ne contiennent pas le texte complet du cours, le prompt complet ou la completion complète.
- Les erreurs restent propagées comme avant.

**Critère de stop :**
Ne pas ajouter de nouveaux flows IA sans observabilité minimale.

**Risques :**

- Exposer des données personnelles dans les logs.
- Modifier involontairement le comportement IA.

### LOT-006 — Inventaire design system et surfaces prioritaires

**Bloc :**
Bloc B — Design system minimal et surfaces premium.

**Objectif :**
Identifier les primitives UI manquantes et les pages à traiter en priorité.

**Pourquoi maintenant :**
L'application a déjà des primitives, mais certaines surfaces restent trop Material-like.

**Périmètre inclus :**

- Auditer `presentation/widgets`.
- Auditer `presentation/pages`.
- Lister les usages restants de `Card`, `LinearProgressIndicator`, `CircularProgressIndicator`, états texte bruts.
- Définir les composants manquants prioritaires.

**Non-objectifs :**

- Refaire toutes les pages.
- Changer la navigation.
- Modifier les flows métier.

**Fichiers ou zones probablement concernés :**

- `revision_app/lib/presentation/widgets`
- `revision_app/lib/presentation/pages`
- `revision_app/lib/features/activities/genui/revision_activity_catalog.dart`

**Backend :**
Non concerné.

**Frontend :**
Audit des composants et pages.

**Genkit :**
Non concerné.

**GenUI :**
Identifier les composants qui doivent réutiliser les primitives.

**Données / Prisma :**
Aucune.

**API :**
Aucun.

**Tests futurs attendus :**
Tests widget à prévoir par composant modifié.

**Commandes de validation futures :**

- `cd revision_app && dart analyze lib test`
- `cd revision_app && flutter test`

**Critères d'acceptation :**

- La liste des composants manquants est claire.
- Les pages prioritaires sont ordonnées.
- Aucun changement visuel massif n'est lancé.

**Critère de stop :**
Ne pas modifier les pages si les composants réutilisables cibles ne sont pas définis.

**Risques :**

- Recréer des composants redondants.
- Transformer ce lot en refonte complète.

### LOT-007 — Primitives UI minimales pour la démo

**Bloc :**
Bloc B — Design system minimal et surfaces premium.

**Objectif :**
Ajouter les composants UI réutilisables nécessaires au golden path.

**Pourquoi maintenant :**
Les futures pages document, fiche, QCM et correction doivent partager une identité visuelle.

**Périmètre inclus :**

- `DocumentStatusCard`.
- `StudyActionCard`.
- `MasteryRing`.
- `AiSurface`.
- États loading/error/empty premium.
- Tests widget des composants non triviaux.

**Non-objectifs :**

- Refaire toutes les pages existantes.
- Ajouter logique métier.
- Modifier les routes.

**Fichiers ou zones probablement concernés :**

- `revision_app/lib/presentation/widgets`
- `revision_app/test/presentation/widgets`

**Backend :**
Non concerné.

**Frontend :**
Créer les primitives et tests.

**Genkit :**
Non concerné.

**GenUI :**
Préparer les composants GenUI à réutiliser ces primitives plus tard.

**Données / Prisma :**
Aucune.

**API :**
Aucun.

**Tests futurs attendus :**

- Rendu light/dark.
- Texte long ne déborde pas.
- États erreur et retry.

**Commandes de validation futures :**

- `cd revision_app && dart analyze lib test`
- `cd revision_app && flutter test`

**Critères d'acceptation :**

- Les composants sont disponibles sous `presentation/widgets`.
- Les pages futures peuvent les réutiliser.
- Les tests widget passent.

**Critère de stop :**
Ne pas refactorer les pages avant que les primitives soient stables.

**Risques :**

- Sur-design de composants avant usage réel.
- Tokens visuels incohérents.

### LOT-008 — Application UI ciblée aux pages existantes

**Bloc :**
Bloc B — Design system minimal et surfaces premium.

**Objectif :**
Remplacer les surfaces brutes dans les pages du golden path sans changer la logique.

**Pourquoi maintenant :**
Les pages existantes doivent être présentables avant d'ajouter plus de contenu IA.

**Périmètre inclus :**

- Page matières.
- Page détail matière.
- Page activités.
- Page aujourd'hui.
- États vides, loading et erreurs.

**Non-objectifs :**

- Modifier les DTO.
- Ajouter détail document.
- Ajouter résumés ou questions ouvertes.

**Fichiers ou zones probablement concernés :**

- `revision_app/lib/presentation/pages/subjects`
- `revision_app/lib/presentation/pages/activities`
- `revision_app/lib/presentation/pages/today`
- `revision_app/test/features/**`

**Backend :**
Non concerné.

**Frontend :**
Refactor UI ciblé vers primitives.

**Genkit :**
Non concerné.

**GenUI :**
Ne modifier que le rendu fallback si nécessaire.

**Données / Prisma :**
Aucune.

**API :**
Aucun.

**Tests futurs attendus :**

- Tests widget pages existantes.
- Tests navigation inchangée.

**Commandes de validation futures :**

- `cd revision_app && dart analyze lib test`
- `cd revision_app && flutter test`

**Critères d'acceptation :**

- Les pages principales utilisent les primitives.
- Les routes publiques restent identiques.
- Aucun comportement métier n'a changé.

**Critère de stop :**
Ne pas continuer si un test de navigation ou page existante casse.

**Risques :**

- Régression visuelle mobile.
- Changement involontaire de comportement.

### LOT-009 — Modèle documentaire cible détaillé

**Bloc :**
Bloc C — Fondations documentaires et sources.

**Objectif :**
Définir précisément `DocumentChunk`, `SourceReference` et les liens vers `KnowledgeUnit`.

**Pourquoi maintenant :**
Les sources doivent être stables avant de générer des résumés, fiches et corrections.

**Périmètre inclus :**

- Définir champs de `DocumentChunk`.
- Définir champs de `SourceReference`.
- Définir relations avec `Document`, `KnowledgeUnit`, futurs artefacts.
- Définir règles de chunking.
- Définir stratégie anti-hallucination : l'IA pointe vers des chunks existants.

**Non-objectifs :**

- Écrire migration.
- Modifier worker.
- Modifier prompts.

**Fichiers ou zones probablement concernés :**

- `api/prisma/schema.prisma`
- `api/src/modules/documents/domain`
- `api/src/modules/revision/domain`
- `api/src/modules/ai/application`

**Backend :**
Préparer le modèle cible.

**Frontend :**
Identifier les champs nécessaires à l'affichage.

**Genkit :**
Définir que les outputs retournent des `chunkId` ou références, pas des extraits libres seuls.

**GenUI :**
Préparer le futur `SourceExcerptCard`.

**Données / Prisma :**
Planifier un modèle minimal plutôt qu'un modèle documentaire trop générique.

Recommandation MVP :

- `DocumentChunk(id, documentId, index, text, charStart?, charEnd?, pageNumber?)`
- `KnowledgeUnitSource(knowledgeUnitId, chunkId, relevanceScore?)`
- `ArtifactSource(artifactId, chunkId, quoteStart?, quoteEnd?)` seulement si un modèle `GeneratedArtifact` est retenu

À éviter au départ :

- modèle polymorphe trop générique ;
- citations libres non vérifiées ;
- `pageNumber` obligatoire si l'extraction PDF ne le fournit pas proprement ;
- structure pensée pour OCR/image/audio avant que le PDF texte soit robuste.

**API :**
Planifier les DTO de notions sourcées.

**Tests futurs attendus :**
Revue de schéma avant migration.

**Commandes de validation futures :**
Aucune commande obligatoire.

**Critères d'acceptation :**

- Le modèle documentaire cible est validé.
- Les relations minimales sont connues.
- Les champs trop ambitieux sont reportés.
- Le modèle retenu permet de vérifier qu'une citation vient d'un chunk stocké.

**Critère de stop :**
Ne pas écrire de migration avant validation du modèle.

**Risques :**

- Overengineering.
- Relations trop polymorphes difficiles à maintenir.

### LOT-010 — Persistance minimale des chunks et sources

**Bloc :**
Bloc C — Fondations documentaires et sources.

**Objectif :**
Ajouter la persistance minimale nécessaire aux chunks et références sources.

**Pourquoi maintenant :**
Le worker doit pouvoir stocker des références vérifiables avant extraction IA v2.

**Périmètre inclus :**

- Migration Prisma pour `DocumentChunk`.
- Migration Prisma pour `SourceReference` si retenu.
- Mise à jour du client Prisma.
- Repositories minimaux.
- Tests repository.

**Non-objectifs :**

- Générer des résumés.
- Exposer l'UI.
- Ajouter GenUI.

**Fichiers ou zones probablement concernés :**

- `api/prisma/schema.prisma`
- `api/src/modules/documents/application`
- `api/src/modules/documents/infrastructure`
- `api/src/modules/revision/infrastructure`

**Backend :**
Ajouter ports et adapters minimaux.

**Frontend :**
Non concerné.

**Genkit :**
Non concerné.

**GenUI :**
Non concerné.

**Données / Prisma :**
Ajouter les modèles retenus.

**API :**
Aucun public.

**Tests futurs attendus :**

- Repository create/list chunks.
- Ownership par document.
- Suppression cascade si document supprimé.

**Commandes de validation futures :**

- `cd api && npm run prisma:generate`
- `cd api && npm test -- documents`
- `cd api && npm run lint:check`

**Critères d'acceptation :**

- Les chunks sont persistables.
- Les chunks restent liés à un document étudiant.
- Les tests repository passent.

**Critère de stop :**
Ne pas changer le worker si la persistance chunk n'est pas testée.

**Risques :**

- Migration incorrecte.
- Cascade de suppression mal définie.

### LOT-011 — Chunking PDF dans le worker

**Bloc :**
Bloc C — Fondations documentaires et sources.

**Objectif :**
Découper le texte extrait en chunks stables avant appel Genkit.

**Pourquoi maintenant :**
Les flows IA doivent recevoir des références de chunks existants.

**Périmètre inclus :**

- Ajouter un service de chunking déterministe.
- Stocker les chunks dans le worker.
- Limiter taille chunk et nombre de chunks.
- Conserver ordre et offsets si possible.
- Tests unitaires du chunker.

**Non-objectifs :**

- Page number parfaite.
- OCR.
- Résumés.
- Correction IA.

**Fichiers ou zones probablement concernés :**

- `api/src/modules/documents/application`
- `api/src/modules/documents/infrastructure`
- `api/src/modules/jobs/infrastructure/document-processing.consumer.ts`

**Backend :**
Créer et appeler le chunker.

**Frontend :**
Non concerné.

**Genkit :**
Préparer l'input chunké.

**GenUI :**
Non concerné.

**Données / Prisma :**
Utiliser `DocumentChunk`.

**API :**
Aucun public.

**Tests futurs attendus :**

- Texte court.
- Texte long.
- Texte avec paragraphes.
- Limites de taille.
- Worker stocke chunks avant extraction.

**Commandes de validation futures :**

- `cd api && npm test -- document-processing`
- `cd api && npm test -- documents`
- `cd api && npm run lint:check`

**Critères d'acceptation :**

- Chaque document texte produit des chunks ordonnés.
- Le worker échoue proprement si aucun chunk utile n'est produit.
- Les chunks ne dupliquent pas tout le document dans les logs.

**Critère de stop :**
Ne pas faire extraction v2 si les chunks ne sont pas stables.

**Risques :**

- Découpage trop naïf.
- Explosion du nombre de chunks.
- Perte de contexte.

### LOT-012 — Extraction Genkit v2 basée sur chunks

**Bloc :**
Bloc C — Fondations documentaires et sources.

**Objectif :**
Faire produire à Genkit des notions qui référencent des chunks existants.

**Pourquoi maintenant :**
Les notions enrichies doivent être sourcées sans hallucination d'extraits libres.

**Périmètre inclus :**

- Adapter le port `DocumentKnowledgeExtractor`.
- Fournir à Genkit une liste de chunks avec IDs courts.
- Demander des `sourceChunkIds`.
- Ajouter `difficulty`, `order`, `confidence`.
- Valider strictement les IDs retournés.
- Fallback si les IDs sont invalides.

**Non-objectifs :**

- Résumés.
- Fiches.
- Questions ouvertes.

**Fichiers ou zones probablement concernés :**

- `api/src/modules/ai/application/document-knowledge-extractor.ts`
- `api/src/modules/ai/infrastructure/document-knowledge-output.schema.ts`
- `api/src/modules/ai/infrastructure/genkit-document-knowledge.extractor.ts`
- `api/src/modules/ai/infrastructure/genkit-mistral-document-knowledge.extractor.ts`

**Backend :**
Adapter les DTO et validations.

**Frontend :**
Non concerné.

**Genkit :**
Créer extraction v2 sourcée.

**GenUI :**
Non concerné.

**Données / Prisma :**
Préparer les champs enrichis sur `KnowledgeUnit`.

**API :**
Aucun public.

**Tests futurs attendus :**

- Output avec chunks valides.
- Output avec chunk inconnu rejeté.
- Output sans notions.
- Document trop long.
- Provider Google et Mistral si supporté.

**Commandes de validation futures :**

- `cd api && npm test -- ai`
- `cd api && npm test -- document-processing`
- `cd api && npm run lint:check`

**Critères d'acceptation :**

- Les notions retournées référencent des chunks existants.
- Les sorties invalides sont rejetées.
- Les erreurs sont observées via le port Genkit.
- Les traces ne contiennent pas le texte complet du cours, le prompt complet ou la completion complète.

**Critère de stop :**
Ne pas persister les notions enrichies si les références chunks ne sont pas validées.

**Risques :**

- Le modèle retourne des IDs invalides.
- Prompt trop complexe.
- Trop de chunks fournis au modèle.

### LOT-013 — Persistance KnowledgeUnit enrichie

**Bloc :**
Bloc C — Fondations documentaires et sources.

**Objectif :**
Persister les notions enrichies et leurs références sources.

**Pourquoi maintenant :**
Le frontend et les futurs artefacts IA doivent lire des notions sourcées.

**Périmètre inclus :**

- Ajouter champs enrichis à `KnowledgeUnit`.
- Persister `difficulty`, `order`, `confidence`.
- Créer les liens sources vers chunks.
- Mettre à jour `markReadyWithKnowledgeUnits`.
- Tests repository et worker.

**Non-objectifs :**

- UI détail document.
- Résumés.
- QCM enrichi.

**Fichiers ou zones probablement concernés :**

- `api/prisma/schema.prisma`
- `api/src/modules/documents/application/documents.repository.ts`
- `api/src/modules/documents/infrastructure/prisma-documents.repository.ts`
- `api/src/modules/jobs/infrastructure/document-processing.consumer.ts`
- `api/src/modules/revision/domain/knowledge-unit.entity.ts`

**Backend :**
Mettre à jour domain, repository, worker.

**Frontend :**
Non concerné.

**Genkit :**
Consommer l'output v2.

**GenUI :**
Non concerné.

**Données / Prisma :**
Évolutions de `KnowledgeUnit` et liens source.

**API :**
Aucun public.

**Tests futurs attendus :**

- Persistence des champs enrichis.
- Liens sources créés.
- Document READY avec notions.
- Failure si source invalide.

**Commandes de validation futures :**

- `cd api && npm run prisma:generate`
- `cd api && npm test -- documents`
- `cd api && npm test -- jobs`
- `cd api && npm run lint:check`

**Critères d'acceptation :**

- Les notions enrichies sont persistées.
- Les références sources restent liées au bon document.
- Le worker conserve les statuts `READY` et `FAILED` correctement.

**Critère de stop :**
Ne pas exposer l'API notions tant que la persistance n'est pas fiable.

**Risques :**

- Incompatibilité avec tests existants.
- Données partielles si transaction mal découpée.

### LOT-014 — API détail document et notions sourcées

**Bloc :**
Bloc D — Détail document et notions côté front.

**Objectif :**
Exposer un contrat backend stable pour lire un document, ses notions et leurs sources.

**Pourquoi maintenant :**
Le frontend doit rendre visible le processing IA avant fiches et QCM avancés.

**Périmètre inclus :**

- Ajouter `GET /documents/:documentId/knowledge-units`.
- Enrichir `GET /documents/:documentId` si nécessaire.
- Retourner sources sans exposer `storagePath`.
- Trier les notions par `order` puis création.
- Tests controller et repository.

**Non-objectifs :**

- Génération de fiche.
- Modification upload.
- GenUI.

**Fichiers ou zones probablement concernés :**

- `api/src/modules/documents/interfaces/documents.controller.ts`
- `api/src/modules/documents/application`
- `api/src/modules/documents/infrastructure`
- `api/src/modules/revision/infrastructure`

**Backend :**
Créer use case et DTO.

**Frontend :**
Non concerné.

**Genkit :**
Non concerné.

**GenUI :**
Non concerné.

**Données / Prisma :**
Lecture des modèles ajoutés.

**API :**

- `GET /documents/:documentId/knowledge-units`
- `GET /documents/:documentId`

**Tests futurs attendus :**

- 401 sans token.
- 404 cross-student.
- Document non READY.
- Réponse triée.
- Sources filtrées.

**Commandes de validation futures :**

- `cd api && npm test -- documents`
- `cd api && npm run lint:check`

**Critères d'acceptation :**

- Le frontend peut charger les notions d'un document.
- Aucun chemin interne de stockage n'est exposé.
- L'ownership est vérifié.

**Critère de stop :**
Ne pas construire la page détail document si le contrat API n'est pas stable.

**Risques :**

- Réponse trop volumineuse.
- Fuite de données source.

### LOT-015 — Data layer Flutter pour détail document

**Bloc :**
Bloc D — Détail document et notions côté front.

**Objectif :**
Ajouter les modèles et repository HTTP Flutter pour lire le détail document et les notions.

**Pourquoi maintenant :**
La page UI doit dépendre d'un controller propre, pas de Dio directement.

**Périmètre inclus :**

- Modèle `KnowledgeUnit` côté Flutter.
- Modèle source reference léger.
- Méthodes dans `DocumentsApi` ou repository dédié.
- Controller/notifier Riverpod.
- Tests parsing JSON et erreurs.

**Non-objectifs :**

- Page complète.
- Résumés.
- GenUI.

**Fichiers ou zones probablement concernés :**

- `revision_app/lib/features/documents/domain`
- `revision_app/lib/features/documents/data/documents_api.dart`
- `revision_app/lib/features/documents/application`
- `revision_app/test/features/documents`

**Backend :**
Non concerné.

**Frontend :**
Ajouter domain, API et état.

**Genkit :**
Non concerné.

**GenUI :**
Non concerné.

**Données / Prisma :**
Aucune.

**API :**
Consommer `GET /documents/:documentId/knowledge-units`.

**Tests futurs attendus :**

- JSON valide.
- JSON invalide.
- Token manquant.
- Erreur API.

**Commandes de validation futures :**

- `cd revision_app && dart analyze lib test`
- `cd revision_app && flutter test test/features/documents`

**Critères d'acceptation :**

- Le frontend parse les notions sourcées.
- Les erreurs sont remontées au controller.
- Les tests data passent.

**Critère de stop :**
Ne pas créer l'écran si le modèle front ne correspond pas au contrat API.

**Risques :**

- Divergence DTO backend/frontend.
- Gestion insuffisante des champs optionnels.

### LOT-016 — Page détail document et notions

**Bloc :**
Bloc D — Détail document et notions côté front.

**Objectif :**
Afficher un document READY, ses notions, difficultés et sources.

**Pourquoi maintenant :**
C'est la première preuve utilisateur que l'IA a analysé le cours.

**Périmètre inclus :**

- Route ou navigation vers détail document.
- Page détail document.
- Cartes notions.
- Extraits sources.
- États upload, processing, ready, failed.
- Retry visuel si supporté par API.

**Non-objectifs :**

- Générer une fiche.
- Lancer QCM depuis chaque notion si non prévu.
- Session GenUI.

**Fichiers ou zones probablement concernés :**

- `revision_app/lib/app/router/app_router.dart`
- `revision_app/lib/core/routing/route_paths.dart`
- `revision_app/lib/presentation/pages/subjects`
- `revision_app/lib/presentation/pages/documents`
- `revision_app/lib/presentation/widgets`
- `revision_app/test/features/documents`
- `revision_app/test/app/router`

**Backend :**
Non concerné.

**Frontend :**
Créer la page et brancher la navigation.

**Genkit :**
Non concerné.

**GenUI :**
Non concerné.

**Données / Prisma :**
Aucune.

**API :**
Consommer les endpoints du LOT-014.

**Tests futurs attendus :**

- Tap document ouvre détail.
- Document READY affiche notions.
- Document FAILED affiche erreur.
- Document PROCESSING affiche attente.
- Cross-platform layout raisonnable.

**Commandes de validation futures :**

- `cd revision_app && dart analyze lib test`
- `cd revision_app && flutter test`

**Critères d'acceptation :**

- Un étudiant voit les notions extraites d'un document.
- Les sources sont affichées quand disponibles.
- Les états sont lisibles.

**Critère de stop :**
Ne pas lancer les fiches si l'utilisateur ne peut pas inspecter les notions sources.

**Risques :**

- Page trop chargée.
- Navigation profonde mal intégrée aux onglets.

### LOT-017 — Contrat artefacts générés

**Bloc :**
Bloc F — Résumés et fiches.

**Objectif :**
Définir comment stocker et exposer les artefacts IA générés.

**Pourquoi maintenant :**
Résumé, fiche, correction et blocs GenUI ont des besoins communs de versioning, statut et sources.

**Périmètre inclus :**

- Choisir entre modèles spécialisés et `GeneratedArtifact`.
- Définir statuts : pending, processing, ready, failed si asynchrone.
- Définir métadonnées : flow, provider, model, promptVersion, schemaVersion.
- Définir relation aux sources.

**Non-objectifs :**

- Écrire migration.
- Implémenter génération.
- Ajouter UI.

**Fichiers ou zones probablement concernés :**

- `api/prisma/schema.prisma`
- `api/src/modules/ai`
- `api/src/modules/documents`
- `api/src/modules/activities`

**Backend :**
Architecture du contrat.

**Frontend :**
Identifier les DTO à afficher.

**Genkit :**
Définir métadonnées communes.

**GenUI :**
Décider si les blocs GenUI sont persistés comme artefacts.

**Données / Prisma :**
Options :

- `Summary` + `RevisionSheet` + `OpenAnswerEvaluation`.
- `GeneratedArtifact` transversal avec `type`.
- `AiGenerationJob` séparé pour statut et observabilité.

**API :**
Aucun public.

**Tests futurs attendus :**
Revue de contrat.

**Commandes de validation futures :**
Aucune commande obligatoire.

**Critères d'acceptation :**

- Le stockage des artefacts est décidé.
- Les lots résumé et fiche peuvent avancer sans ambiguïté.

**Critère de stop :**
Ne pas créer `Summary` sans décider s'il dépend d'un artifact commun.

**Risques :**

- Modèle générique trop vague.
- Modèles spécialisés trop répétitifs.

### LOT-018 — Persistance Summary et RevisionSheet

**Bloc :**
Bloc F — Résumés et fiches.

**Objectif :**
Ajouter les modèles et repositories nécessaires aux fiches.

**Pourquoi maintenant :**
La génération doit persister des objets métier relisibles après redémarrage.

**Périmètre inclus :**

- Modèles `Summary` et `RevisionSheet` ou artefact retenu.
- Repository.
- Use cases `GetSummary` et stockage minimal.
- Ownership par `studentId`.

**Non-objectifs :**

- Flow Genkit.
- UI.
- GenUI.

**Fichiers ou zones probablement concernés :**

- `api/prisma/schema.prisma`
- `api/src/modules/summaries` ou `api/src/modules/documents`
- `api/src/modules/ai`

**Backend :**
Créer module/use cases/repository.

**Frontend :**
Non concerné.

**Genkit :**
Non concerné.

**GenUI :**
Non concerné.

**Données / Prisma :**
Ajouter les modèles retenus.

**API :**
Aucun ou endpoints de lecture si séparés.

**Tests futurs attendus :**

- Création.
- Lecture.
- Ownership.
- Source references liées.

**Commandes de validation futures :**

- `cd api && npm run prisma:generate`
- `cd api && npm test -- summaries`
- `cd api && npm run lint:check`

**Critères d'acceptation :**

- Les fiches sont persistables.
- Les sources sont associables.
- Aucun cross-student leak.

**Critère de stop :**
Ne pas appeler Genkit pour résumés si la persistance n'est pas prête.

**Risques :**

- Nouveau module mal intégré à `AppModule`.
- Duplication entre Summary et RevisionSheet.

### LOT-019 — Flow Genkit résumé et fiche

**Bloc :**
Bloc F — Résumés et fiches.

**Objectif :**
Créer des flows Genkit typés pour résumé et fiche, basés sur chunks et notions.

**Pourquoi maintenant :**
Le premier artefact IA visible doit être fiable et sourcé.

**Périmètre inclus :**

- `generateSummaryFlow`.
- `generateRevisionSheetFlow`.
- Schémas Zod stricts.
- Inputs avec chunks sélectionnés.
- Outputs avec références sources.
- Observabilité.

**Non-objectifs :**

- UI.
- GenUI.
- Question ouverte.

**Fichiers ou zones probablement concernés :**

- `api/src/modules/ai/application`
- `api/src/modules/ai/infrastructure`
- `api/src/modules/summaries`

**Backend :**
Ajouter ports et adapters Genkit.

**Frontend :**
Non concerné.

**Genkit :**
Créer flows et tests.

**GenUI :**
Non concerné.

**Données / Prisma :**
Consommer les sources et produire artefacts.

**API :**
Aucun public dans ce lot si isolé.

**Tests futurs attendus :**

- Output valide.
- Source inconnue rejetée.
- Document sans notion refusé.
- Erreur provider gérée.

**Commandes de validation futures :**

- `cd api && npm test -- ai`
- `cd api && npm test -- summaries`
- `cd api && npm run lint:check`

**Critères d'acceptation :**

- Les flows retournent des DTO validés.
- Les sources pointent vers des chunks existants.
- Les erreurs sont observées.
- Les traces ne contiennent pas le texte complet du cours, le prompt complet ou la completion complète.

**Critère de stop :**
Ne pas exposer endpoint génération si le flow peut halluciner des sources non validées.

**Risques :**

- Prompt trop long.
- Sortie trop verbeuse.
- Coût IA.

### LOT-020 — API résumés et fiches

**Bloc :**
Bloc F — Résumés et fiches.

**Objectif :**
Exposer la génération et la lecture des fiches depuis un document READY.

**Pourquoi maintenant :**
Le frontend a besoin d'un contrat stable pour afficher le premier artefact IA.

**Périmètre inclus :**

- `POST /documents/:documentId/summaries`.
- `GET /documents/:documentId/summaries`.
- Endpoint fiche si séparé.
- Validation document READY.
- Rate limit ou garde-fou minimal si disponible.
- Tests controller.

**Non-objectifs :**

- Génération asynchrone complexe si non décidée.
- UI.
- GenUI.

**Fichiers ou zones probablement concernés :**

- `api/src/modules/documents/interfaces`
- `api/src/modules/summaries`
- `api/src/modules/ai`

**Backend :**
Brancher use case, repository et flow.

**Frontend :**
Non concerné.

**Genkit :**
Appelé via use case.

**GenUI :**
Non concerné.

**Données / Prisma :**
Persisted summaries.

**API :**

- `POST /documents/:documentId/summaries`
- `GET /documents/:documentId/summaries`

**Tests futurs attendus :**

- 409 si document non READY.
- 404 cross-student.
- 422 output invalide.
- Résumé persisté.

**Commandes de validation futures :**

- `cd api && npm test -- summaries`
- `cd api && npm test -- documents`
- `cd api && npm run lint:check`

**Critères d'acceptation :**

- Un résumé peut être généré depuis un document READY.
- Le résumé est relisible.
- Les sources sont présentes si disponibles.

**Critère de stop :**
Ne pas construire l'écran fiche si les endpoints ne protègent pas l'ownership.

**Risques :**

- Endpoint trop lent si génération synchrone.
- Générations répétées coûteuses.

### LOT-021 — UI résumé et fiche

**Bloc :**
Bloc F — Résumés et fiches.

**Objectif :**
Permettre à l'utilisateur de générer et lire une fiche sourcée.

**Pourquoi maintenant :**
C'est le premier usage IA visible après l'import.

**Périmètre inclus :**

- Data layer Flutter pour summaries.
- CTA générer une fiche.
- Affichage résumé express, points clés, pièges.
- Affichage sources.
- États loading/error/empty.

**Non-objectifs :**

- GenUI dynamique.
- Question ouverte.
- Session coach.

**Fichiers ou zones probablement concernés :**

- `revision_app/lib/features/documents`
- `revision_app/lib/presentation/pages/documents`
- `revision_app/lib/presentation/widgets`
- `revision_app/test/features/documents`

**Backend :**
Non concerné.

**Frontend :**
Créer repository, controller et UI.

**Genkit :**
Non concerné côté front.

**GenUI :**
Non concerné dans ce lot.

**Données / Prisma :**
Aucune.

**API :**
Consommer endpoints LOT-020.

**Tests futurs attendus :**

- CTA appelle endpoint.
- Fiche existante affichée.
- Erreur génération affichée.
- Sources affichées.

**Commandes de validation futures :**

- `cd revision_app && dart analyze lib test`
- `cd revision_app && flutter test`

**Critères d'acceptation :**

- Depuis un document READY, l'utilisateur lit une fiche.
- La fiche reste visible après reload.
- Les erreurs sont compréhensibles.

**Critère de stop :**
Ne pas passer au QCM enrichi si le premier artefact IA n'est pas démontrable.

**Risques :**

- UI trop dense sur mobile.
- Confusion entre notion et fiche.

### LOT-022 — Contrat QCM v2

**Bloc :**
Bloc G — QCM enrichi.

**Objectif :**
Définir le contrat QCM enrichi sans fuite de correction avant submit.

**Pourquoi maintenant :**
Le QCM existe déjà, il faut l'améliorer sans casser l'activité actuelle.

**Périmètre inclus :**

- DTO QCM public sans `correctChoiceId`.
- DTO correction après submit.
- Nombre de questions configurable.
- Difficulty.
- Feedback par question.
- Compatibilité temporaire avec `/activities/next`.

**Non-objectifs :**

- Question ouverte.
- GenUI.
- Plan du jour avancé.

**Fichiers ou zones probablement concernés :**

- `api/src/modules/activities/application`
- `api/src/modules/activities/interfaces`
- `api/src/modules/activities/domain`
- `revision_app/lib/features/activities/domain`

**Backend :**
Définir use cases et DTO.

**Frontend :**
Préparer modèles.

**Genkit :**
Adapter output cible.

**GenUI :**
Préparer composant futur.

**Données / Prisma :**
Préparer extensions `Question` et `ActivityResult`.

**API :**

- `POST /activities/diagnostic-quiz`
- `POST /activities/:sessionId/result`

**Tests futurs attendus :**
Contrat de non-fuite de correction.

**Commandes de validation futures :**

- `cd api && npm test -- activities`
- `cd revision_app && flutter test test/features/activities`

**Critères d'acceptation :**

- Le contrat public ne révèle pas la bonne réponse avant submit.
- La correction après submit est structurée.

**Critère de stop :**
Ne pas changer le flow Genkit QCM sans contrat clair.

**Risques :**

- Régression de l'activité existante.
- Incompatibilité DTO front/back.

### LOT-023 — Genkit QCM enrichi

**Bloc :**
Bloc G — QCM enrichi.

**Objectif :**
Améliorer la génération QCM avec feedback et grounding sur sources.

**Pourquoi maintenant :**
Le contrat QCM v2 exige des explications et distracteurs plus fiables.

**Périmètre inclus :**

- Schéma QCM v2.
- Prompt basé sur notion et chunks.
- Feedback par choix si retenu.
- Difficulté.
- Observabilité.
- Validation de distracteurs.

**Non-objectifs :**

- UI.
- Question ouverte.
- GenUI.

**Fichiers ou zones probablement concernés :**

- `api/src/modules/activities/infrastructure/genkit-diagnostic-quiz.generator.ts`
- `api/src/modules/activities/application/diagnostic-quiz-generator.ts`
- `api/src/modules/activities/infrastructure/*.spec.ts`

**Backend :**
Adapter le generator.

**Frontend :**
Non concerné.

**Genkit :**
Flow QCM v2.

**GenUI :**
Non concerné.

**Données / Prisma :**
Aucune directe, sauf champs du LOT-024.

**API :**
Aucun nouveau.

**Tests futurs attendus :**

- Une seule bonne réponse.
- Choix uniques.
- Feedback présent.
- Sources valides.

**Commandes de validation futures :**

- `cd api && npm test -- genkit-diagnostic-quiz`
- `cd api && npm run lint:check`

**Critères d'acceptation :**

- Le flow produit un QCM v2 valide.
- Le QCM reste basé sur le cours.
- Les outputs invalides sont rejetés.
- Les traces ne contiennent pas le texte complet du cours, le prompt complet ou la completion complète.

**Critère de stop :**
Ne pas persister les corrections si le flow ne garantit pas les invariants.

**Risques :**

- Questions hors sujet.
- Distracteurs absurdes.

### LOT-024 — Persistance et soumission QCM enrichies

**Bloc :**
Bloc G — QCM enrichi.

**Objectif :**
Persister les métadonnées QCM v2 et renvoyer une correction détaillée après submit.

**Pourquoi maintenant :**
La maîtrise et la correction doivent être fiables côté backend avant UI avancée.

**Périmètre inclus :**

- Étendre `Question` et `ActivityResult`.
- Ajouter feedback par question.
- Ajouter score par notion.
- Ajouter `MasteryEvent` si retenu.
- Tests double submit, réponses inconnues, mastery.

**Non-objectifs :**

- UI correction.
- GenUI.
- Question ouverte.

**Fichiers ou zones probablement concernés :**

- `api/prisma/schema.prisma`
- `api/src/modules/activities/application`
- `api/src/modules/activities/infrastructure/prisma-activities.repository.ts`
- `api/src/modules/revision`

**Backend :**
Mettre à jour repository et use cases.

**Frontend :**
Non concerné.

**Genkit :**
Consommer output QCM v2.

**GenUI :**
Non concerné.

**Données / Prisma :**
Extensions activité/résultat/maîtrise.

**API :**
Réponse enrichie de `POST /activities/:sessionId/result`.

**Tests futurs attendus :**

- Correction détaillée.
- Mastery update.
- Double submit 409.
- Réponse inconnue 400.
- Cross-student interdit.

**Commandes de validation futures :**

- `cd api && npm run prisma:generate`
- `cd api && npm test -- activities`
- `cd api && npm test -- revision`
- `cd api && npm run lint:check`

**Critères d'acceptation :**

- La correction détaillée est renvoyée après submit.
- La maîtrise est mise à jour.
- Les protections existantes restent actives.

**Critère de stop :**
Ne pas refaire l'UI QCM tant que la correction backend n'est pas stable.

**Risques :**

- Calcul mastery opaque.
- Migration qui casse les sessions existantes.

### LOT-025 — UI QCM enrichi

**Bloc :**
Bloc G — QCM enrichi.

**Objectif :**
Afficher un QCM enrichi avec correction détaillée et feedback.

**Pourquoi maintenant :**
L'utilisateur doit comprendre pourquoi il a réussi ou échoué.

**Périmètre inclus :**

- Adapter `HttpActivitiesApi`.
- Adapter modèles domain Flutter.
- Refaire `DiagnosticQuizPage`.
- Afficher correction par question.
- Afficher score et feedback.

**Non-objectifs :**

- GenUI.
- Question ouverte.
- Plan du jour avancé.

**Fichiers ou zones probablement concernés :**

- `revision_app/lib/features/activities`
- `revision_app/lib/presentation/pages/activities`
- `revision_app/test/features/activities`

**Backend :**
Non concerné.

**Frontend :**
Mettre à jour data/domain/UI.

**Genkit :**
Non concerné.

**GenUI :**
Non concerné, fallback natif seulement.

**Données / Prisma :**
Aucune.

**API :**
Consommer les contrats LOT-022/024.

**Tests futurs attendus :**

- Parsing correction.
- Correction affichée après submit.
- Pas de correction avant submit.
- État erreur submit.

**Commandes de validation futures :**

- `cd revision_app && dart analyze lib test`
- `cd revision_app && flutter test test/features/activities`

**Critères d'acceptation :**

- L'utilisateur voit la correction détaillée.
- Les réponses correctes ne sont pas visibles avant validation.
- Le score est clair.

**Critère de stop :**
Ne pas ajouter GenUI QCM tant que le fallback natif n'est pas stable.

**Risques :**

- Régression mobile.
- UI trop longue pour plusieurs questions.

### LOT-026 — Contrat question ouverte

**Bloc :**
Bloc H — Question ouverte corrigée.

**Objectif :**
Ajouter les modèles et contrats pour une question ouverte corrigée.

**Pourquoi maintenant :**
C'est la feature démo forte, mais elle doit reposer sur sources et QCM/mastery stabilisés.

**Périmètre inclus :**

- Nouveau type activité `OPEN_QUESTION`.
- Modèle question ouverte.
- Modèle évaluation.
- Endpoints de démarrage et soumission.
- Ownership et statuts.

**Non-objectifs :**

- Flow Genkit complet.
- UI.
- GenUI.

**Fichiers ou zones probablement concernés :**

- `api/prisma/schema.prisma`
- `api/src/modules/activities`
- `api/src/modules/revision`

**Backend :**
Ajouter domain, use cases, repository.

**Frontend :**
Préparer DTO plus tard.

**Genkit :**
Définir interfaces seulement.

**GenUI :**
Non concerné.

**Données / Prisma :**
Ajouter modèles retenus.

**API :**

- `POST /activities/open-question`
- `POST /activities/:sessionId/open-answer`

**Tests futurs attendus :**

- Session créée.
- Réponse vide refusée.
- Double correction bloquée.
- Cross-student interdit.

**Commandes de validation futures :**

- `cd api && npm run prisma:generate`
- `cd api && npm test -- activities`
- `cd api && npm run lint:check`

**Critères d'acceptation :**

- Le backend peut représenter une question ouverte.
- Les endpoints sont protégés.
- Aucun flow IA non validé n'est requis pour les tests de contrat.

**Critère de stop :**
Ne pas brancher l'évaluation IA tant que les statuts et ownership ne sont pas testés.

**Risques :**

- Mélange trop fort avec QCM.
- Modèle d'activité trop rigide.

### LOT-027 — Genkit question ouverte et correction

**Bloc :**
Bloc H — Question ouverte corrigée.

**Objectif :**
Créer les flows de génération et correction de question ouverte.

**Pourquoi maintenant :**
Les contrats backend sont prêts et les sources sont vérifiables.

**Périmètre inclus :**

- `generateOpenQuestionFlow`.
- `evaluateOpenAnswerFlow`.
- Schémas stricts.
- Barème.
- Points présents/manquants.
- Erreurs.
- Réponse modèle.
- Conseils.
- Sources.
- Observabilité.

**Non-objectifs :**

- UI.
- GenUI.
- Session coach.

**Fichiers ou zones probablement concernés :**

- `api/src/modules/ai/application`
- `api/src/modules/ai/infrastructure`
- `api/src/modules/activities/application`
- `api/src/modules/activities/infrastructure`

**Backend :**
Brancher flows aux use cases.

**Frontend :**
Non concerné.

**Genkit :**
Créer et tester les flows.

**GenUI :**
Non concerné.

**Données / Prisma :**
Persisted evaluation.

**API :**
Utiliser endpoints LOT-026.

**Tests futurs attendus :**

- Bonne réponse.
- Réponse partielle.
- Réponse hors sujet.
- Sources invalides rejetées.
- Erreur IA explicite.

**Commandes de validation futures :**

- `cd api && npm test -- ai`
- `cd api && npm test -- activities`
- `cd api && npm run lint:check`

**Critères d'acceptation :**

- L'évaluation est structurée.
- Le score est séparé du feedback.
- Les sources sont référencées.
- Les traces ne contiennent pas le texte complet du cours, le prompt complet ou la completion complète.

**Critère de stop :**
Ne pas créer l'UI si la correction n'est pas stable et testée.

**Risques :**

- Correction trop vague.
- Coût IA.
- Hallucination de points non présents dans le cours.

### LOT-028 — UI question ouverte corrigée

**Bloc :**
Bloc H — Question ouverte corrigée.

**Objectif :**
Permettre à l'étudiant de répondre à une question ouverte et lire la correction.

**Pourquoi maintenant :**
Le backend peut générer et corriger l'activité.

**Périmètre inclus :**

- Modèles Flutter.
- Méthodes `HttpActivitiesApi`.
- Page ou mode d'activité question ouverte.
- Champ réponse long.
- État correction en cours.
- Affichage score, points manquants, réponse modèle.

**Non-objectifs :**

- GenUI.
- Coach.
- Plan du jour multi-actions.

**Fichiers ou zones probablement concernés :**

- `revision_app/lib/features/activities`
- `revision_app/lib/presentation/pages/activities`
- `revision_app/lib/presentation/widgets`
- `revision_app/test/features/activities`

**Backend :**
Non concerné.

**Frontend :**
Ajouter data/domain/UI.

**Genkit :**
Non concerné côté front.

**GenUI :**
Non concerné dans ce lot.

**Données / Prisma :**
Aucune.

**API :**
Consommer endpoints question ouverte.

**Tests futurs attendus :**

- Réponse vide non soumise.
- Correction affichée.
- Erreur correction affichée.
- Champ long utilisable.

**Commandes de validation futures :**

- `cd revision_app && dart analyze lib test`
- `cd revision_app && flutter test test/features/activities`

**Critères d'acceptation :**

- L'étudiant reçoit une correction argumentée.
- Le fallback natif est complet.
- Les erreurs sont lisibles.

**Critère de stop :**
Ne pas construire GenUI question ouverte avant fallback natif stable.

**Risques :**

- UX de rédaction pénible sur mobile.
- Correction trop longue à afficher.

### LOT-029 — GenUI composants lecture sourcée

**Bloc :**
Bloc I — GenUI catalog isolé.

**Objectif :**
Ajouter des composants GenUI isolés pour résumé et sources.

**Pourquoi maintenant :**
GenUI doit être validé composant par composant avant la session.

**Périmètre inclus :**

- `SummaryCard`.
- `KeyPointsList`.
- `SourceExcerptCard`.
- Schémas JSON.
- Validateur.
- Fallback natif.
- Tests catalogue.

**Non-objectifs :**

- Session coach.
- Génération libre de widgets.
- QCM GenUI.

**Fichiers ou zones probablement concernés :**

- `revision_app/lib/features/activities/genui`
- `revision_app/lib/presentation/widgets`
- `revision_app/test/features/activities`

**Backend :**
Non concerné.

**Frontend :**
Étendre catalogue et validators.

**Genkit :**
Non concerné.

**GenUI :**
Ajouter composants lecture sourcée.

**Données / Prisma :**
Aucune.

**API :**
Aucun.

**Tests futurs attendus :**

- Payload valide rendu.
- Payload invalide rejeté.
- Fallback affiché.
- Longueur texte limitée.

**Commandes de validation futures :**

- `cd revision_app && dart analyze lib test`
- `cd revision_app && flutter test test/features/activities/revision_activity_catalog_test.dart`

**Critères d'acceptation :**

- Les composants sont bornés.
- Le catalogue refuse les payloads inconnus.
- Les composants réutilisent les primitives UI.

**Critère de stop :**
Ne pas ajouter la session GenUI tant que les composants source/résumé ne sont pas testés.

**Risques :**

- Schémas trop permissifs.
- Retour à des widgets Material bruts.

### LOT-030 — GenUI composants activité et correction

**Bloc :**
Bloc I — GenUI catalog isolé.

**Objectif :**
Ajouter les composants GenUI pour QCM, question ouverte et correction.

**Pourquoi maintenant :**
Les activités natives sont stables et peuvent servir de fallback.

**Périmètre inclus :**

- `McqQuestionCard`.
- `McqCorrectionPanel`.
- `ActivityResultCard`.
- `OpenQuestionCard`.
- `CorrectionPanel`.
- `RubricCard`.
- Tests validators.

**Non-objectifs :**

- Coach complet.
- Widgets arbitraires.
- Modification de scoring.

**Fichiers ou zones probablement concernés :**

- `revision_app/lib/features/activities/genui`
- `revision_app/lib/presentation/widgets`
- `revision_app/test/features/activities`

**Backend :**
Non concerné.

**Frontend :**
Étendre catalogue et validators.

**Genkit :**
Non concerné.

**GenUI :**
Composants activité bornés.

**Données / Prisma :**
Aucune.

**API :**
Aucun.

**Tests futurs attendus :**

- Chaque composant accepte payload valide.
- Chaque composant rejette payload invalide.
- Fallback natif conservé.

**Commandes de validation futures :**

- `cd revision_app && dart analyze lib test`
- `cd revision_app && flutter test test/features/activities`

**Critères d'acceptation :**

- GenUI peut rendre une activité sans casser le fallback.
- Aucun composant inconnu n'est rendu.

**Critère de stop :**
Ne pas construire la session coach si les composants activité ne sont pas isolés et testés.

**Risques :**

- Couplage fort au format backend.
- Validation incomplète.

### LOT-031 — Session de révision IA minimale

**Bloc :**
Bloc J — Session de révision IA.

**Objectif :**
Créer une session IA minimale qui orchestre des actions déjà existantes.

**Pourquoi maintenant :**
Les briques isolées existent : fiches, QCM, question ouverte, GenUI components.

**Périmètre inclus :**

- Modèle `RevisionSession`.
- Endpoint `POST /revision-sessions`.
- Endpoint message si nécessaire.
- Première action déterministe, sans coach libre.
- Historique minimal.

**Non-objectifs :**

- Orchestration LLM complète.
- Chatbot libre.
- Plan du jour avancé.

**Fichiers ou zones probablement concernés :**

- `api/src/modules/revision`
- `api/src/modules/activities`
- `api/prisma/schema.prisma`

**Backend :**
Créer session et action initiale.

**Frontend :**
Non concerné dans ce lot.

**Genkit :**
Non concerné ou optionnel.

**GenUI :**
Payloads issus du catalogue existant seulement.

**Données / Prisma :**
Ajouter session si retenu.

**API :**

- `POST /revision-sessions`
- `POST /revision-sessions/:sessionId/message` si nécessaire.

**Tests futurs attendus :**

- Session appartient au student.
- Action initiale valide.
- Payload GenUI validé côté backend si stocké.

**Commandes de validation futures :**

- `cd api && npm test -- revision`
- `cd api && npm run lint:check`

**Critères d'acceptation :**

- Une session démarre et retourne une action existante.
- Aucune génération libre de widget.

**Critère de stop :**
Ne pas ajouter coach IA tant que la session déterministe ne fonctionne pas.

**Risques :**

- Modèle de session prématuré.
- Confusion entre session et activité.

### LOT-032 — Écran Révision IA minimal

**Bloc :**
Bloc J — Session de révision IA.

**Objectif :**
Afficher une session IA simple avec les composants GenUI validés.

**Pourquoi maintenant :**
Le backend fournit une session contrôlée.

**Périmètre inclus :**

- Route ou onglet si validé.
- Écran session.
- Chargement session.
- Rendu de blocs catalogue.
- Fallback bloc invalide.
- Historique simple.

**Non-objectifs :**

- Chat libre.
- Orchestration avancée.
- Nouvelle IA côté front.

**Fichiers ou zones probablement concernés :**

- `revision_app/lib/app/router/app_router.dart`
- `revision_app/lib/features/activities/genui`
- `revision_app/lib/presentation/pages`
- `revision_app/test/app/router`
- `revision_app/test/features/activities`

**Backend :**
Non concerné.

**Frontend :**
Créer data layer et page session.

**Genkit :**
Non concerné.

**GenUI :**
Rendre uniquement composants validés.

**Données / Prisma :**
Aucune.

**API :**
Consommer endpoints LOT-031.

**Tests futurs attendus :**

- Session démarre.
- Bloc valide rendu.
- Bloc invalide fallback.
- Route protégée par auth.

**Commandes de validation futures :**

- `cd revision_app && dart analyze lib test`
- `cd revision_app && flutter test`

**Critères d'acceptation :**

- La session simple est démontrable.
- Le fallback fonctionne.
- Aucun widget arbitraire.

**Critère de stop :**
Ne pas ajouter orchestration IA si les blocs de session ne sont pas robustes.

**Risques :**

- Trop ressembler à un chatbot.
- Routes trop tôt modifiées.

### LOT-033 — Orchestration coach Genkit

**Bloc :**
Bloc J — Session de révision IA.

**Objectif :**
Ajouter un flow Genkit qui choisit la prochaine action parmi une enum bornée.

**Pourquoi maintenant :**
La session déterministe fonctionne et les composants sont validés.

**Périmètre inclus :**

- `generateCoachNextActionFlow`.
- Input contexte étudiant limité.
- Output intention enum.
- Le backend transforme l'intention en action validée.
- Fallback déterministe.

**Non-objectifs :**

- Widget libre.
- Classement TodayPlan par IA.
- Chat généraliste.

**Fichiers ou zones probablement concernés :**

- `api/src/modules/ai`
- `api/src/modules/revision`
- `api/src/modules/activities`

**Backend :**
Brancher orchestration dans session.

**Frontend :**
Non concerné.

**Genkit :**
Créer flow coach.

**GenUI :**
Consommer uniquement composants existants.

**Données / Prisma :**
Éventuel stockage intention/action.

**API :**
Même endpoints session.

**Tests futurs attendus :**

- Intention valide.
- Intention inconnue rejetée.
- Fallback déterministe.
- Observabilité.

**Commandes de validation futures :**

- `cd api && npm test -- ai`
- `cd api && npm test -- revision`
- `cd api && npm run lint:check`

**Critères d'acceptation :**

- Le coach propose une action valide.
- L'IA ne contrôle pas directement l'UI.
- Le fallback fonctionne sans provider.

**Critère de stop :**
Ne pas utiliser ce flow dans la démo si le fallback déterministe n'est pas prêt.

**Risques :**

- Orchestration trop vague.
- Perte de testabilité.

### LOT-034 — TodayPlan multi-actions backend

**Bloc :**
Bloc K — Plan du jour avancé.

**Objectif :**
Étendre le plan du jour à plusieurs types d'actions déterministes.

**Pourquoi maintenant :**
Les actions existent déjà : fiche, QCM, question ouverte, review faible.

**Périmètre inclus :**

- Ajouter types d'action.
- Ranking déterministe.
- Prendre en compte priority, mastery, lastPracticedAt, objectif.
- Raisons pédagogiques.
- Tests domain.

**Non-objectifs :**

- Ranking par IA.
- UI avancée.
- Notifications.

**Fichiers ou zones probablement concernés :**

- `api/src/modules/revision/domain/adaptive-plan.service.ts`
- `api/src/modules/revision/application/get-today-plan.use-case.ts`
- `api/src/modules/revision/interfaces/today.controller.ts`
- `api/src/modules/revision/**/*.spec.ts`

**Backend :**
Étendre domain et DTO.

**Frontend :**
Non concerné.

**Genkit :**
Optionnel seulement pour phrase personnalisée, pas ranking.

**GenUI :**
Non concerné.

**Données / Prisma :**
Lire `MasteryEvent` ou résultats enrichis si ajoutés.

**API :**
Étendre `GET /today`.

**Tests futurs attendus :**

- Plan stable.
- Notions faibles prioritaires.
- Plusieurs actions.
- Cross-student impossible.

**Commandes de validation futures :**

- `cd api && npm test -- revision`
- `cd api && npm run lint:check`

**Critères d'acceptation :**

- `GET /today` retourne plusieurs types d'actions.
- Les raisons sont explicites.
- Le résultat est déterministe.

**Critère de stop :**
Ne pas faire UI Today v2 si le ranking backend n'est pas stable.

**Risques :**

- Heuristique trop complexe.
- Raisons peu pédagogiques.

### LOT-035 — TodayPage v2 frontend

**Bloc :**
Bloc K — Plan du jour avancé.

**Objectif :**
Afficher les actions du plan du jour et permettre de les lancer.

**Pourquoi maintenant :**
Le backend expose des actions réellement exploitables.

**Périmètre inclus :**

- Adapter `TodayPlan` Flutter.
- Cartes d'actions.
- Boutons démarrer.
- État vide sans document READY.
- Progression quotidienne simple.

**Non-objectifs :**

- Notifications.
- Calendrier complet.
- Ranking côté front.

**Fichiers ou zones probablement concernés :**

- `revision_app/lib/features/today`
- `revision_app/lib/presentation/pages/today/today_page.dart`
- `revision_app/test/features/today`

**Backend :**
Non concerné.

**Frontend :**
Data/domain/UI Today v2.

**Genkit :**
Non concerné.

**GenUI :**
Optionnel uniquement pour cartes validées, pas nécessaire au fallback.

**Données / Prisma :**
Aucune.

**API :**
Consommer `GET /today` enrichi.

**Tests futurs attendus :**

- Plusieurs actions affichées.
- Démarrage QCM.
- Démarrage question ouverte.
- État vide.
- Erreur API.

**Commandes de validation futures :**

- `cd revision_app && dart analyze lib test`
- `cd revision_app && flutter test test/features/today`

**Critères d'acceptation :**

- L'utilisateur sait quoi faire aujourd'hui.
- Il peut lancer une action depuis la page.
- Le front ne recalcule pas le ranking.

**Critère de stop :**
Ne pas utiliser Today comme démo si les actions ne lancent rien.

**Risques :**

- UX confuse avec trop d'actions.
- Divergence des types d'action front/back.

### LOT-036 — Seed et fixtures de démo

**Bloc :**
Bloc L — Golden demo, qualité et déploiement.

**Objectif :**
Rendre la démo reproductible avec des données connues.

**Pourquoi maintenant :**
Le golden path est complet et doit être rejouable.

**Périmètre inclus :**

- Seed matière.
- Seed document ou script d'import contrôlé.
- Seed mastery si utile.
- Données de test non sensibles.
- Documentation d'utilisation.

**Non-objectifs :**

- Seeder production.
- Contourner auth en production.
- Ajouter offline-first.

**Fichiers ou zones probablement concernés :**

- `api/prisma`
- `api/README.md`
- `revision_app/docs`

**Backend :**
Script ou documentation seed.

**Frontend :**
Non concerné sauf instructions demo.

**Genkit :**
Définir si les artefacts sont pré-générés ou générés pendant la démo.

**GenUI :**
Non concerné.

**Données / Prisma :**
Seed contrôlé.

**API :**
Aucun nouveau.

**Tests futurs attendus :**
Validation manuelle du seed.

**Commandes de validation futures :**
À confirmer après choix du mécanisme de seed.

**Critères d'acceptation :**

- Un développeur peut préparer la démo en suivant la documentation.
- Les données ne contiennent pas de secret.

**Critère de stop :**
Ne pas préparer captures ou scripts de présentation si le seed n'est pas reproductible.

**Risques :**

- Seed couplé à un utilisateur Firebase réel.
- Données de démo fragiles.

### LOT-037 — Tests e2e critiques et smoke checks

**Bloc :**
Bloc L — Golden demo, qualité et déploiement.

**Objectif :**
Protéger le parcours principal par tests et smoke checks.

**Pourquoi maintenant :**
Le produit a assez de briques pour mériter une validation bout en bout.

**Périmètre inclus :**

- E2E backend sur endpoints critiques.
- Tests worker document.
- Smoke API `/health`.
- Smoke upload metadata ou upload fichier selon environnement.
- Checklist manuelle front.

**Non-objectifs :**

- Couvrir tous les edge cases.
- Remplacer les tests unitaires.
- Déployer automatiquement.

**Fichiers ou zones probablement concernés :**

- `api/test`
- `api/src/**/*.spec.ts`
- `revision_app/test`
- `revision_app/docs`

**Backend :**
Ajouter e2e et smoke.

**Frontend :**
Checklist ou tests widget complémentaires.

**Genkit :**
Mocks ou fakes pour éviter coûts en CI.

**GenUI :**
Tests payload/fallback.

**Données / Prisma :**
DB test.

**API :**
Parcours complet.

**Tests futurs attendus :**

- Auth mock.
- Création matière.
- Upload document.
- Processing contrôlé.
- Activité.
- Today.

**Commandes de validation futures :**

- `cd api && npm test`
- `cd api && npm run test:e2e`
- `cd api && npm run build`
- `cd revision_app && flutter test`

**Critères d'acceptation :**

- Les tests critiques passent localement.
- Les flows IA peuvent être mockés.
- La checklist manuelle est claire.

**Critère de stop :**
Ne pas déclarer la démo stable sans smoke checks.

**Risques :**

- Tests e2e lents.
- Dépendance à Firebase réelle.

### LOT-038 — Runbook démo et déploiement

**Bloc :**
Bloc L — Golden demo, qualité et déploiement.

**Objectif :**
Documenter comment lancer, vérifier et présenter Revision App.

**Pourquoi maintenant :**
La valeur de la démo dépend autant de sa reproductibilité que du code.

**Périmètre inclus :**

- Variables d'environnement.
- Lancement API.
- Lancement worker.
- Redis/Postgres.
- Provider IA.
- Démarrage Flutter.
- Scénario de présentation.
- Troubleshooting erreurs IA et worker.

**Non-objectifs :**

- Ajouter infra nouvelle.
- Automatiser tous les déploiements.
- Modifier Dokploy.

**Fichiers ou zones probablement concernés :**

- `api/README.md`
- `revision_app/README.md`
- `revision_app/docs`

**Backend :**
Documentation runbook.

**Frontend :**
Documentation runbook.

**Genkit :**
Documenter provider, modèle, clés, timeouts.

**GenUI :**
Documenter catalogue et fallback.

**Données / Prisma :**
Documenter migrations et seed.

**API :**
Documenter smoke checks.

**Tests futurs attendus :**
Validation manuelle du runbook.

**Commandes de validation futures :**

- `cd api && npm run build`
- `cd revision_app && flutter build web`

**Critères d'acceptation :**

- Un développeur peut rejouer la démo.
- Les erreurs courantes sont documentées.
- Les commandes ne supposent pas de scripts inexistants.

**Critère de stop :**
Ne pas faire de présentation externe si le runbook n'a pas été rejoué.

**Risques :**

- Documentation obsolète.
- Variables sensibles exposées.

## 6. Ordre recommandé des 10 premiers lots

| Ordre | Lot | Justification |
| --- | --- | --- |
| 1 | LOT-001 | Il verrouille la vérité projet : routes, modèles, flows, tests. |
| 2 | LOT-001B | Il tranche le chemin officiel upload/lecture document avant de toucher au worker. |
| 3 | LOT-002 | Il tranche les décisions qui bloquent chunks, sources et artefacts IA. |
| 4 | LOT-002B | Il évite une rafale de migrations Prisma mal ordonnées. |
| 5 | LOT-003 | Il fixe le PDF et le scénario qui guideront les validations. |
| 6 | LOT-004 | L'observabilité Genkit doit exister avant les nouveaux flows. |
| 7 | LOT-005 | Les flows existants deviennent diagnostiquables avant enrichissement. |
| 8 | LOT-006 | Le design system doit être cadré avant d'ajouter de nouvelles pages. |
| 9 | LOT-009 | Le modèle documentaire cible doit précéder toute migration. |
| 10 | LOT-010 | La persistance chunks/sources débloque le worker et l'extraction v2. |

LOT-007 et LOT-008 peuvent être faits juste après LOT-006 si l'équipe veut améliorer vite le rendu visuel existant. Ils ne doivent pas bloquer les fondations documentaires si la priorité est l'IA sourcée.

### MVP Cut 1 — Démo minimale Genkit + GenUI

Objectif : obtenir rapidement une démo crédible sans attendre QCM v2, question ouverte complète, session coach et TodayPlan avancé.

À faire absolument :

- LOT-001 — Audit des contrats actuels.
- LOT-001B — Décision stratégie upload et lecture document.
- LOT-002 — Décisions fondations IA et documentaire.
- LOT-002B — Revue de schéma avant migrations.
- LOT-003 — Golden demo baseline.
- LOT-004 — Port d'observabilité Genkit.
- LOT-005 — Instrumentation des flows Genkit existants.
- LOT-009 — Modèle documentaire cible détaillé.
- LOT-010 — Persistance minimale des chunks et sources.
- LOT-011 — Chunking PDF dans le worker.
- LOT-012 — Extraction Genkit v2 basée sur chunks.
- LOT-013 — Persistance KnowledgeUnit enrichie.
- LOT-014 — API détail document et notions sourcées.
- LOT-015 — Data layer Flutter pour détail document.
- LOT-016 — Page détail document et notions.
- LOT-017 — Contrat artefacts générés.
- LOT-018 — Persistance Summary et RevisionSheet.
- LOT-019 — Flow Genkit résumé et fiche.
- LOT-020 — API résumés et fiches.
- LOT-021 — UI résumé et fiche.
- LOT-029 — GenUI composants lecture sourcée.

À reporter après ce cut :

- QCM enrichi complet.
- Question ouverte complète.
- Session coach complète.
- TodayPlan multi-actions.
- OCR/image/audio.

Ce cut montre déjà la valeur technique essentielle : PDF texte importé, chunks vérifiables, notions sourcées, fiche générée par Genkit, rendu GenUI borné pour fiche/source.

## 7. Matrice des dépendances

| Lot | Dépend de | Débloque | Risque principal | Validation clé |
| --- | --- | --- | --- | --- |
| LOT-001 | Aucun | LOT-001B, LOT-002, LOT-003 | Inventaire incomplet | Contrats réels listés |
| LOT-001B | LOT-001 | LOT-002, LOT-010, LOT-011 | Chemins upload divergents | Chemin officiel écrit |
| LOT-002 | LOT-001B | LOT-002B, LOT-009, LOT-017 | Décision trop générique | Options et recommandation écrites |
| LOT-002B | LOT-002 | LOT-010, LOT-018, LOT-024, LOT-026 | Trop de migrations successives | Périmètre migratoire validé |
| LOT-003 | LOT-001 | LOT-036, LOT-037 | PDF non représentatif | PDF texte validé |
| LOT-004 | LOT-002 | LOT-005 | Logs sensibles | Port testable sans provider |
| LOT-005 | LOT-004 | LOT-012, LOT-019, LOT-023 | Changement comportement IA | Logs sans texte complet |
| LOT-006 | LOT-001 | LOT-007 | Audit trop large | Composants manquants listés |
| LOT-007 | LOT-006 | LOT-008, LOT-016, LOT-021 | Sur-design | Tests widget |
| LOT-008 | LOT-007 | Démo visuelle | Régression UI | Tests pages existantes |
| LOT-009 | LOT-002B | LOT-010 | Overengineering | Modèle cible validé |
| LOT-010 | LOT-001B, LOT-002B, LOT-009 | LOT-011, LOT-013 | Migration fragile | Tests repository |
| LOT-011 | LOT-001B, LOT-010 | LOT-012 | Chunking pauvre | Tests chunker |
| LOT-012 | LOT-005, LOT-011 | LOT-013 | IDs source invalides | Output validé |
| LOT-013 | LOT-012 | LOT-014 | Transaction partielle | Worker tests |
| LOT-014 | LOT-013 | LOT-015 | Fuite source | Tests ownership |
| LOT-015 | LOT-014 | LOT-016 | DTO divergent | Tests parsing |
| LOT-016 | LOT-015, LOT-007 | LOT-021 | Page trop dense | Widget tests |
| LOT-017 | LOT-002B | LOT-018 | Modèle trop abstrait | Contrat choisi |
| LOT-018 | LOT-002B, LOT-017 | LOT-019 | Duplication modèle | Tests repository |
| LOT-019 | LOT-018, LOT-013 | LOT-020 | Hallucination sources | Sources validées |
| LOT-020 | LOT-019 | LOT-021 | Endpoint lent | Tests controller |
| LOT-021 | LOT-020, LOT-016 | LOT-029 | UX trop dense | Tests fiche |
| LOT-022 | LOT-001 | LOT-023, LOT-024 | Fuite correction | Contrat sans réponse |
| LOT-023 | LOT-022, LOT-013 | LOT-024 | Questions hors cours | Tests schema |
| LOT-024 | LOT-002B, LOT-023 | LOT-025, LOT-034 | Mastery opaque | Tests submit |
| LOT-025 | LOT-024 | LOT-030 | UI confuse | Widget tests |
| LOT-026 | LOT-002B, LOT-024 | LOT-027 | Modèle activité rigide | Tests endpoints |
| LOT-027 | LOT-026, LOT-013 | LOT-028 | Correction vague | Tests flow |
| LOT-028 | LOT-027 | LOT-030, LOT-034 | UX mobile | Widget tests |
| LOT-029 | LOT-021 | LOT-032 | Schéma permissif | Tests validator |
| LOT-030 | LOT-025, LOT-028 | LOT-032 | Payload invalide | Tests fallback |
| LOT-031 | LOT-029, LOT-030 | LOT-032, LOT-033 | Session prématurée | Session déterministe |
| LOT-032 | LOT-031 | LOT-033 | Chatbot générique | Fallback GenUI |
| LOT-033 | LOT-032 | Démo coach | Perte testabilité | Fallback déterministe |
| LOT-034 | LOT-024, LOT-028 | LOT-035 | Ranking opaque | Tests domain |
| LOT-035 | LOT-034 | Démo today | Divergence types | Widget tests |
| LOT-036 | LOT-003 | LOT-037, LOT-038 | Seed fragile | Rejeu manuel |
| LOT-037 | LOT-036 | Démo stable | Tests lents | E2E critiques |
| LOT-038 | LOT-036, LOT-037 | Présentation | Docs obsolètes | Runbook rejoué |

## 8. Lots à ne surtout pas lancer trop tôt

- Session GenUI complète : elle dépend de composants isolés, validation stricte et fallback natif.
- Plan du jour multi-actions avancé : il dépend de QCM enrichi, question ouverte, mastery events et actions lançables.
- Orchestration coach IA : elle doit venir après une session déterministe et des composants GenUI stables.
- Imports avancés OCR, image et audio : ils ajoutent un nouveau pipeline alors que le PDF texte doit d'abord être robuste.
- Génération libre de widgets : elle contredit le principe GenUI borné et crée un risque sécurité/UX.
- Refonte UI totale non bornée : elle consommerait du temps sans sécuriser la démo IA.
- Migration globale du modèle d'activité : elle risque de casser le QCM existant ; préférer extensions ciblées.
- Stockage générique de tous les artefacts sans cas d'usage validé : risque d'overengineering.
- Migrations Prisma en rafale sans revue de schéma : elles créent une dette difficile à corriger une fois les repositories et DTO branchés.

## 9. Golden demo path

| Étape | État initial | Action utilisateur | Résultat attendu | Preuve visuelle ou technique | Validation manuelle |
| --- | --- | --- | --- | --- | --- |
| 1. Login | App installée, backend disponible | Connexion Firebase | Routes privées accessibles | Profil affiché, token accepté | Se déconnecter puis vérifier `/sign-in` |
| 2. Création matière | Aucun sujet ou compte démo | Créer “Droit constitutionnel” | Matière persistée | Liste matières affiche la carte | Redémarrer app, matière présente |
| 3. Import PDF | Matière ouverte | Importer PDF texte de démo | Document `UPLOADED` puis `PROCESSING` | Carte document avec statut | Vérifier API liste documents |
| 4. Processing | Worker actif | Attendre traitement | Document `READY` | Statut prêt | Vérifier logs worker sans erreur |
| 5. Notions détectées | Document READY | Ouvrir détail document | Notions, difficulté, sources | Cartes notions + extraits | Comparer aux passages du PDF |
| 6. Fiche générée | Notions disponibles | Cliquer générer fiche | Fiche sourcée | Résumé, points clés, sources | Vérifier sources non inventées |
| 7. QCM enrichi | Notions prêtes | Lancer diagnostic | QCM sans correction visible | Questions et choix | Vérifier pas de bonne réponse exposée |
| 8. Question ouverte corrigée | Notion sélectionnée | Répondre en texte libre | Correction structurée | Score, points manquants, modèle | Vérifier feedback cohérent |
| 9. Plan du jour mis à jour | Activité soumise | Ouvrir Aujourd'hui | Recommandation adaptée | Carte action et raison | Comparer mastery avant/après |
| 10. Session GenUI simple | Composants validés | Démarrer Révision IA | Bloc dynamique rendu | Summary/QCM/correction dans AiSurface | Forcer payload invalide et voir fallback |

## 10. Stratégie de validation globale

### Backend

- Tests unitaires domain pour chunking, mastery, ranking Today.
- Tests application pour use cases documents, summaries, activities, revision sessions.
- Tests infrastructure Prisma pour ownership et persistance.
- Tests controller pour 401, 400, 404, 409, 422.
- Tests worker pour statuts `PROCESSING`, `READY`, `FAILED`.
- Commandes probables :
  - `cd api && npm run lint:check`
  - `cd api && npm test`
  - `cd api && npm run test:e2e`
  - `cd api && npm run build`

### Frontend

- Tests data pour parsing JSON et erreurs Dio.
- Tests controller/notifier Riverpod.
- Tests widget pour pages et composants.
- Tests router pour auth, onglets et deep links.
- Commandes probables :
  - `cd revision_app && dart analyze lib test`
  - `cd revision_app && flutter test`
  - `cd revision_app && flutter build web`

### Genkit

- Tests de schémas Zod.
- Tests de outputs invalides.
- Tests de source grounding.
- Tests d'observabilité succès/échec.
- Fakes ou mocks pour éviter les coûts IA en CI.
- Validation manuelle ponctuelle avec provider réel.

### GenUI

- Tests de catalogue.
- Tests de payload valide.
- Tests de payload invalide.
- Tests fallback.
- Interdiction de composant inconnu.
- Limites de longueur sur textes rendus.

### Validations manuelles

- Golden path complet.
- Import PDF réel.
- Worker réel.
- Fiche sourcée.
- QCM et correction.
- Question ouverte.
- Today après activité.
- Session GenUI simple.

### Contrôles sécurité

- Token obligatoire.
- Ownership par `studentId`.
- Aucun `storagePath` interne exposé.
- Pas de correction avant submit.
- Pas de source cross-document.

### Contrôles anti-hallucination

- Les sources affichées doivent venir de chunks stockés.
- Les outputs IA avec références inconnues doivent être rejetés.
- Les fiches et corrections doivent pointer vers des chunks ou notions.
- Les prompts doivent interdire le contenu externe.

### Contrôles coût et timeouts

- Limite taille input.
- Limite nombre chunks fournis.
- Timeout provider IA.
- Retry contrôlé.
- Rate limit génération si disponible.
- Observabilité durée et statut.

## 11. Risques transverses

| Risque | Probabilité | Impact | Mitigation | Lot traité |
| --- | --- | --- | --- | --- |
| Hallucination des sources | Élevée | Élevé | Chunks backend, validation IDs, rejet outputs invalides | LOT-009 à LOT-013 |
| PDF trop longs | Élevée | Moyen | Chunking, limite input, sélection chunks | LOT-011, LOT-012 |
| PDF scannés sans OCR | Moyenne | Moyen | Message erreur explicite, hors MVP | LOT-011, LOT-038 |
| Coût IA | Moyenne | Élevé | Observabilité, limites, fakes CI, rate limit | LOT-004, LOT-005, LOT-019 |
| Lenteur IA | Moyenne | Moyen | Timeouts, jobs async si retenu, UI loading | LOT-017, LOT-020, LOT-021 |
| Payload GenUI invalide | Élevée | Moyen | Catalogue strict, validators, fallback | LOT-029, LOT-030 |
| Fuite cross-student | Moyenne | Élevé | Tests ownership sur chaque endpoint | Tous lots API |
| Frontend trop Material-like | Moyenne | Moyen | Primitives premium ciblées | LOT-006 à LOT-008 |
| Overengineering documentaire | Moyenne | Élevé | Décision LOT-002, modèle minimal | LOT-009 |
| Dette si coach trop tôt | Élevée | Élevé | Retarder session complète | LOT-031 à LOT-033 |
| Correction ouverte trop vague | Moyenne | Élevé | Barème strict, sources, tests réponses types | LOT-027 |
| Ranking Today opaque | Moyenne | Moyen | Algorithme déterministe testé | LOT-034 |
| Logs contenant données sensibles | Moyenne | Élevé | Ne logger que tailles, IDs techniques et statuts | LOT-004, LOT-005 |
| Divergence upload/lecture document | Moyenne | Élevé | Choisir un chemin officiel MVP et documenter les chemins secondaires | LOT-001B |

## 12. Décisions à prendre avant implémentation

| Décision | Options | Recommandation | Impact | Moment où décider |
| --- | --- | --- | --- | --- |
| Quelle stratégie upload/lecture document officielle ? | Upload direct backend / Firebase Storage + reader backend / coexistence temporaire | Pour le MVP, garder `POST /documents/course-pdf` comme chemin officiel si le worker lit le stockage local ; garder `POST /documents` seulement comme compatibilité documentée ou futur Firebase Storage avec adapter backend dédié | Pipeline worker, sécurité stockage, tests d'import | LOT-001B |
| Faut-il ajouter `DocumentChunk` ? | Oui / Non / stockage temporaire | Oui, minimal, car nécessaire au grounding | Structure worker et Genkit | LOT-002 puis LOT-009 |
| Faut-il ajouter `SourceReference` ? | Table dédiée / JSON dans artefacts / relation directe | Table dédiée légère si plusieurs artefacts citent les mêmes chunks | API sources et anti-hallucination | LOT-002 puis LOT-009 |
| Faut-il ajouter `AiGenerationJob` ? | Non / logs seulement / table dédiée | Commencer par port observabilité, table si besoin de statuts async | Debug et coûts IA | LOT-002 puis LOT-004 |
| Faut-il ajouter `GeneratedArtifact` ? | Non / table générique / modèles spécialisés | Modèles métier spécialisés, avec métadonnées communes ; générique seulement si duplication forte | Simplicité Prisma | LOT-017 |
| Faut-il versionner les prompts en DB ? | Constantes code / DB / table config | Stocker `promptVersion` et `schemaVersion` sur artefacts générés | Reproductibilité | LOT-017, LOT-018 |
| Faut-il stocker les payloads GenUI ? | Non / oui pour session / oui partout | Stocker seulement en session si nécessaire ; reconstruire depuis objets métier pour fiches | Debug session | LOT-031 |
| Faut-il historiser les résumés ? | Écraser / versions multiples / latest + archived | Pour MVP, garder latest avec `regeneratedAt`, puis historiser si demandé | Coût et UX | LOT-018 |
| Faut-il faire les générations en job asynchrone ? | Synchrone / async par BullMQ / hybride | Synchrone pour résumé court MVP si timeout acceptable ; async pour traitements longs | UX et robustesse | LOT-017, LOT-020 |
| Quel est le premier PDF de démo ? | Cours droit constitutionnel / PDF synthétique / autre cours court | PDF texte court et maîtrisé, idéalement synthétique | Tests manuels | LOT-003 |
| Quels composants GenUI minimum ? | Summary + Source / QCM / Correction / all | SummaryCard, SourceExcerptCard, McqQuestionCard, CorrectionPanel | Démo GenUI réaliste | LOT-029, LOT-030 |

## 13. Définition de done pour les futurs lots

Un futur lot d'implémentation est terminé seulement si :

- le périmètre du lot est respecté ;
- aucun objectif hors lot n'a été ajouté ;
- les tests pertinents sont écrits ou explicitement justifiés ;
- les validations prévues sont lancées ;
- les erreurs sont gérées ;
- les données restent isolées par étudiant ;
- les outputs IA sont typés et validés si le lot touche Genkit ;
- les payloads GenUI sont validés et ont un fallback si le lot touche GenUI ;
- les états loading/error/empty sont présents si le lot touche le frontend ;
- les commandes lancées et leurs résultats sont rapportés ;
- aucun commit Git n'est effectué ;
- le rapport final mentionne fichiers modifiés, tests lancés, tests non lancés et risques restants.

## 14. Proposition de prochain lot concret

Le prochain lot à lancer après ce plan devrait être :

### LOT-001 — Audit des contrats actuels

Raison :

- Il est prudent.
- Il ne modifie pas le code.
- Il réduit le risque de construire sur une hypothèse fausse.
- Il prépare la décision upload/lecture document du LOT-001B.
- Il permettra ensuite de lancer LOT-002 avec des informations vérifiées.

Livrable attendu :

- Un court document d'audit ou une section ajoutée au plan avec les endpoints, modèles, flows, scripts et gaps confirmés.
- Aucune migration.
- Aucune dépendance.
- Aucun commit.

Le deuxième lot à lancer immédiatement après devrait être LOT-001B. Il doit trancher si le MVP utilise officiellement l'upload direct backend via `POST /documents/course-pdf`, Firebase Storage avec reader backend, ou une coexistence temporaire documentée. Sans cette décision, il ne faut pas toucher au worker, aux chunks ou aux migrations documentaires.

````
