# LOT-035 — TodayPage v2 frontend

## 1. Résultat

TodayPage consomme maintenant le contrat `GET /today` multi-actions de `LOT-034`.

Le frontend parse et affiche les actions :

* `diagnostic_quiz`;
* `open_question`;
* `revision_session`.

La page affiche plusieurs cartes d'actions, les raisons backend, la priorite, la duree estimee, la maitrise quand elle existe, et un etat distinct quand `masteryScore` vaut `null`.

## 2. Sources inspectées

Documentation :

* `docs/ROADMAP.md`
* `docs/ROADMAP_EXECUTION_PLAN.md`
* `docs/ROADMAP_EXECUTION_LOT_031_REVISION_SESSION_MINIMAL.md`
* `docs/ROADMAP_EXECUTION_LOT_032_REVISION_SESSION_SCREEN.md`
* `docs/ROADMAP_EXECUTION_HOTFIX_032B_REVISION_SESSION_ROUTE_ISOLATION.md`
* `docs/ROADMAP_EXECUTION_LOT_033_REVISION_COACH_GENKIT.md`
* `docs/ROADMAP_EXECUTION_LOT_034_TODAY_PLAN_MULTI_ACTIONS_BACKEND.md`
* `AGENTS.md`
* `codex_rule.md`

Backend en lecture seule :

* `api/src/modules/revision/domain/adaptive-plan.service.ts`
* `api/src/modules/revision/application/get-today-plan.use-case.ts`
* `api/src/modules/revision/interfaces/today.controller.ts`
* `api/src/modules/revision/**/*.spec.ts`
* `api/src/modules/activities/application/start-next-activity.use-case.ts`
* `api/src/modules/activities/application/start-open-question-activity.use-case.ts`
* `api/src/modules/revision-sessions/application/start-revision-session.use-case.ts`
* `api/src/modules/revision-sessions/application/request-next-revision-session-action.use-case.ts`
* `api/src/modules/revision-sessions/interfaces/revision-sessions.controller.ts`

Frontend :

* `lib/features/today/domain/today_plan.dart`
* `lib/features/today/data/http_today_repository.dart`
* `lib/features/today/application/today_controller.dart`
* `lib/features/today/application/today_notifier.dart`
* `lib/presentation/pages/today/today_page.dart`
* `lib/app/router/app_routes.dart`
* `lib/core/routing/route_paths.dart`
* `lib/presentation/pages/activities/activities_page.dart`
* `lib/presentation/pages/revision_sessions/revision_session_page.dart`
* `lib/presentation/widgets/revision_page.dart`
* `lib/presentation/widgets/revision_panel.dart`
* `lib/presentation/widgets/revision_button.dart`
* `lib/presentation/widgets/revision_message.dart`
* `lib/presentation/widgets/revision_status_pill.dart`
* `lib/presentation/widgets/revision_progress_bar.dart`
* `lib/presentation/widgets/revision_icon_badge.dart`
* `test/features/today/**`
* `test/app/router/**`
* `test/fakes/**`

## 3. Préflight Git

API initial :

```text
## main...origin/main
```

Frontend initial :

```text
## main...origin/main
```

Le workspace etait propre avant les modifications de ce lot.

## 4. Périmètre réalisé

* Adaptation du modele Flutter Today au contrat multi-actions.
* Adaptation du parser HTTP `/today`.
* Refactor de `TodayPage` en liste d'actions.
* Navigation par action vers les routes existantes.
* Tests data et widget Today v2.
* Mise a jour du fake Today.
* Mise a jour de la ligne `LOT-035` dans le plan.

## 5. Décisions d’architecture Flutter

Le ranking reste entierement backend. Le frontend ne trie pas, ne recalcule pas la priorite, ne modifie pas les raisons et ne cree pas de session directement.

La page lance les actions par navigation :

* QCM : route Activities avec `subjectId` seulement.
* Question ouverte : route Activities avec `subjectId` et `knowledgeUnitId`.
* Session IA : route `/activities/session` via le helper existant.

Le QCM n'envoie pas `knowledgeUnitId` afin d'eviter le comportement de `HOTFIX-028B`, ou `ActivitiesPage(subjectId + knowledgeUnitId)` demarre directement une question ouverte.

## 6. Contrat `GET /today` consommé

Le frontend consomme :

* `generatedAt`;
* `items`;
* `id`;
* `subjectId`;
* `subjectName`;
* `knowledgeUnitId`;
* `knowledgeUnitTitle`;
* `masteryScore`;
* `action`;
* `estimatedMinutes`;
* `priority`;
* `reasonCode`;
* `reason`;
* `startPayload.subjectId`;
* `startPayload.knowledgeUnitId`;
* `startPayload.preferredAction`.

## 7. Modèles Today v2

Ajout de :

* `TodayPlanActionType`;
* `TodayPlanReasonCode`;
* `TodayPlanPreferredAction`;
* `TodayPlanStartPayload`.

`TodayPlanItem` porte maintenant les champs enrichis du backend.

## 8. Parsing HTTP

`HttpTodayRepository` rejette :

* `generatedAt` invalide;
* `items` non-liste;
* action inconnue;
* reason code inconnu;
* preferred action inconnue;
* `startPayload.subjectId` absent ou vide.

`masteryScore`, `knowledgeUnitId` et `knowledgeUnitTitle` peuvent etre `null`.

## 9. Gestion des actions

Types supportes :

* `diagnostic_quiz` -> `TodayPlanActionType.diagnosticQuiz`;
* `open_question` -> `TodayPlanActionType.openQuestion`;
* `revision_session` -> `TodayPlanActionType.revisionSession`.

Les actions inconnues sont rejetees au parsing pour eviter un bouton impossible a router.

## 10. Navigation par action

* `diagnosticQuiz` : `/activities?subjectId=...`
* `openQuestion` : `/activities?subjectId=...&knowledgeUnitId=...`
* `revisionSession` : `/activities/session?subjectId=...&knowledgeUnitId=...&preferredAction=...` si les champs sont fournis.

Une action ouverte sans `knowledgeUnitId` affiche un bouton desactive `Action indisponible`.

## 11. UI TodayPage v2

La page affiche :

* titre et sous-titre;
* bouton refresh;
* compteur d'actions;
* duree totale;
* cartes par action;
* icone par action;
* matiere et notion si disponible;
* raison backend;
* duree estimee;
* priorite;
* reason code lisible;
* bouton d'action.

## 12. États loading / error / empty

* Loading : indicateur centre.
* Error : `RevisionMessage` + bouton `Reessayer`.
* Empty : message propre + bouton `Voir mes matieres`.

## 13. Gestion `masteryScore: null`

Quand `masteryScore` est `null`, la page affiche `Maitrise non mesuree` et ne rend pas de barre de progression.

Quand `masteryScore` est numerique, l'affichage visuel est borne entre 0 et 1.

## 14. Non-recalcul du ranking côté front

La page affiche les items dans l'ordre retourne par le backend. Elle ne trie pas et ne recalcule pas `priority`, `reasonCode`, `reason` ni `estimatedMinutes`.

## 15. GenUI : ce qui est explicitement non fait

* Aucun composant GenUI cree.
* Aucun catalogue GenUI modifie.
* Aucun payload GenUI ajoute.

## 16. Backend : ce qui est explicitement non modifié

* Aucun fichier `api/**` modifie.
* Aucun Prisma modifie.
* Aucun Genkit modifie.
* Aucun endpoint modifie.

## 17. Tests créés ou modifiés

* `test/features/today/http_today_repository_test.dart`
* `test/features/today/today_page_test.dart`
* `test/fakes/in_memory_today_repository.dart`

Les tests couvrent :

* parsing multi-actions;
* parsing `masteryScore: null`;
* parsing `startPayload`;
* rejet des actions/reason codes inconnus;
* rejet des payloads invalides;
* etats loading, error, empty;
* affichage des trois actions;
* navigation QCM, question ouverte et session IA;
* bouton desactive pour question ouverte sans notion.

## 18. Validations lancées avec résultats

```bash
cd revision_app
dart analyze lib test
```

Resultat : OK, no issues found.

```bash
cd revision_app
flutter test test/features/today --reporter compact
```

Resultat : OK, all tests passed.

```bash
cd revision_app
flutter test test/features/activities --reporter compact
```

Resultat : OK, all tests passed.

```bash
cd revision_app
flutter test test/features/revision_sessions --reporter compact
```

Resultat : OK, all tests passed.

```bash
cd revision_app
flutter test test/app/router --reporter compact
```

Resultat : OK, all tests passed.

```bash
cd revision_app
flutter test --reporter compact
```

Resultat : OK, all tests passed.

```bash
cd revision_app
git diff --check
```

Resultat : OK.

```bash
cd api
git diff --check
```

Resultat : OK.

## 19. Validations non lancées avec justification

* Tests backend : non lances, backend hors scope.
* `flutter pub upgrade` / `flutter pub add` : interdits et inutiles.
* `dart format .` : interdit.
* Genkit/provider IA : hors scope.

## 20. Risques restants

* Le QCM Today cible seulement la matiere dans la navigation, car `ActivitiesPage(subjectId + knowledgeUnitId)` demarre une question ouverte par defaut.
* Une evolution future pourrait ajouter `preferredAction=diagnostic_quiz` a `ActivitiesPage` pour lancer un QCM notion-level sans ambiguite.
* La localisation des reason codes reste dans la page; une couche i18n dediee pourra venir plus tard.

## 21. Recommandation prochain lot

Le prochain lot recommande est `LOT-036 — Seed et fixtures de demo`, afin d'avoir des donnees realistes pour verifier le TodayPlan multi-actions en demo produit.

## 22. Passes de review

* Verification anti-scope : aucun backend, Prisma, Genkit, GenUI ou pubspec modifie.
* Verification navigation : TodayPage navigue uniquement vers des routes existantes.
* Verification anti-ranking front : aucun tri ni scoring local ajoute.
* Verification `masteryScore: null` : pas de progress bar trompeuse.

## 23. Code complet créé/modifié/supprimé pour review

Les fichiers source et tests crees/modifies sont reproduits integralement ci-dessous.

Pour `docs/ROADMAP_EXECUTION_PLAN.md`, le fichier complet fait 3563 lignes; la seule ligne modifiee est reproduite integralement ici :

```markdown
| LOT-035 | TodayPage v2 frontend | Réalisé | `docs/ROADMAP_EXECUTION_LOT_035_TODAY_PAGE_V2_FRONTEND.md` |
```

### `lib/features/today/domain/today_plan.dart`

```dart
class TodayPlan {
  const TodayPlan({required this.generatedAt, required this.items});

  final DateTime generatedAt;
  final List<TodayPlanItem> items;

  int get totalEstimatedMinutes {
    return items.fold(0, (total, item) => total + item.estimatedMinutes);
  }
}

enum TodayPlanActionType { diagnosticQuiz, openQuestion, revisionSession }

enum TodayPlanReasonCode {
  lowMastery,
  stalePractice,
  highPrioritySubject,
  mixActivityType,
  startRevisionSession,
  continueProgress,
}

enum TodayPlanPreferredAction { diagnosticQuiz, openQuestion }

class TodayPlanStartPayload {
  const TodayPlanStartPayload({
    required this.subjectId,
    this.knowledgeUnitId,
    this.preferredAction,
  });

  final String subjectId;
  final String? knowledgeUnitId;
  final TodayPlanPreferredAction? preferredAction;
}

class TodayPlanItem {
  const TodayPlanItem({
    required this.id,
    required this.subjectId,
    required this.subjectName,
    required this.knowledgeUnitId,
    required this.knowledgeUnitTitle,
    required this.masteryScore,
    required this.action,
    required this.estimatedMinutes,
    required this.priority,
    required this.reasonCode,
    required this.reason,
    required this.startPayload,
  });

  final String id;
  final String subjectId;
  final String subjectName;
  final String? knowledgeUnitId;
  final String? knowledgeUnitTitle;
  final double? masteryScore;
  final TodayPlanActionType action;
  final int estimatedMinutes;
  final int priority;
  final TodayPlanReasonCode reasonCode;
  final String reason;
  final TodayPlanStartPayload startPayload;
}
```

### `lib/features/today/data/http_today_repository.dart`

```dart
import 'package:dio/dio.dart';

import '../application/today_controller.dart';
import '../domain/today_plan.dart';

class HttpTodayRepository implements TodayRepository {
  HttpTodayRepository({
    required Dio dio,
    required Future<String> Function() getIdToken,
  }) : this._(dio, getIdToken);

  const HttpTodayRepository._(this._dio, this._getIdToken);

  final Dio _dio;
  final Future<String> Function() _getIdToken;

  @override
  Future<TodayPlan> getTodayPlan() async {
    final response = await _dio.get<Object?>(
      '/today',
      options: await _authorizedOptions(),
    );

    return _TodayPlanJson(response.data).toPlan();
  }

  Future<Options> _authorizedOptions() async {
    final token = (await _getIdToken()).trim();

    if (token.isEmpty) {
      throw StateError('A Firebase ID token is required for today plan');
    }

    return Options(headers: {'Authorization': 'Bearer $token'});
  }
}

class _TodayPlanJson {
  const _TodayPlanJson(this.value);

  final Object? value;

  TodayPlan toPlan() {
    final json = value;

    if (json is! Map<String, Object?>) {
      throw const FormatException('Invalid today response');
    }

    final generatedAt = json['generatedAt'];
    final items = json['items'];

    if (generatedAt is! String || items is! List) {
      throw const FormatException('Invalid today response');
    }

    final parsedGeneratedAt = DateTime.tryParse(generatedAt);
    if (parsedGeneratedAt == null) {
      throw const FormatException('Invalid today response');
    }

    return TodayPlan(
      generatedAt: parsedGeneratedAt,
      items: items
          .map((item) => _TodayPlanItemJson(item).toItem())
          .toList(growable: false),
    );
  }
}

class _TodayPlanItemJson {
  const _TodayPlanItemJson(this.value);

  final Object? value;

  TodayPlanItem toItem() {
    final json = value;

    if (json is! Map<String, Object?>) {
      throw const FormatException('Invalid today item response');
    }

    final id = json['id'];
    final subjectId = json['subjectId'];
    final subjectName = json['subjectName'];
    final knowledgeUnitId = json['knowledgeUnitId'];
    final knowledgeUnitTitle = json['knowledgeUnitTitle'];
    final masteryScore = json['masteryScore'];
    final action = json['action'];
    final estimatedMinutes = json['estimatedMinutes'];
    final priority = json['priority'];
    final reasonCode = json['reasonCode'];
    final reason = json['reason'];
    final startPayload = json['startPayload'];

    if (id is! String ||
        subjectId is! String ||
        subjectName is! String ||
        (knowledgeUnitId != null && knowledgeUnitId is! String) ||
        (knowledgeUnitTitle != null && knowledgeUnitTitle is! String) ||
        (masteryScore != null && masteryScore is! num) ||
        action is! String ||
        estimatedMinutes is! int ||
        priority is! int ||
        reasonCode is! String ||
        reason is! String) {
      throw const FormatException('Invalid today item response');
    }

    final parsedKnowledgeUnitId = knowledgeUnitId as String?;
    final parsedKnowledgeUnitTitle = knowledgeUnitTitle as String?;
    final parsedMasteryScore = masteryScore as num?;

    return TodayPlanItem(
      id: id,
      subjectId: subjectId,
      subjectName: subjectName,
      knowledgeUnitId: parsedKnowledgeUnitId,
      knowledgeUnitTitle: parsedKnowledgeUnitTitle,
      masteryScore: parsedMasteryScore?.toDouble(),
      action: _parseAction(action),
      estimatedMinutes: estimatedMinutes,
      priority: priority,
      reasonCode: _parseReasonCode(reasonCode),
      reason: reason,
      startPayload: _TodayPlanStartPayloadJson(startPayload).toPayload(),
    );
  }

  TodayPlanActionType _parseAction(String value) {
    return switch (value) {
      'diagnostic_quiz' => TodayPlanActionType.diagnosticQuiz,
      'open_question' => TodayPlanActionType.openQuestion,
      'revision_session' => TodayPlanActionType.revisionSession,
      _ => throw const FormatException('Invalid today action'),
    };
  }

  TodayPlanReasonCode _parseReasonCode(String value) {
    return switch (value) {
      'LOW_MASTERY' => TodayPlanReasonCode.lowMastery,
      'STALE_PRACTICE' => TodayPlanReasonCode.stalePractice,
      'HIGH_PRIORITY_SUBJECT' => TodayPlanReasonCode.highPrioritySubject,
      'MIX_ACTIVITY_TYPE' => TodayPlanReasonCode.mixActivityType,
      'START_REVISION_SESSION' => TodayPlanReasonCode.startRevisionSession,
      'CONTINUE_PROGRESS' => TodayPlanReasonCode.continueProgress,
      _ => throw const FormatException('Invalid today reason code'),
    };
  }
}

class _TodayPlanStartPayloadJson {
  const _TodayPlanStartPayloadJson(this.value);

  final Object? value;

  TodayPlanStartPayload toPayload() {
    final json = value;

    if (json is! Map<String, Object?>) {
      throw const FormatException('Invalid today start payload');
    }

    final subjectId = json['subjectId'];
    final knowledgeUnitId = json['knowledgeUnitId'];
    final preferredAction = json['preferredAction'];

    if (subjectId is! String ||
        subjectId.trim().isEmpty ||
        (knowledgeUnitId != null && knowledgeUnitId is! String) ||
        (preferredAction != null && preferredAction is! String)) {
      throw const FormatException('Invalid today start payload');
    }

    final parsedKnowledgeUnitId = knowledgeUnitId as String?;
    final parsedPreferredAction = preferredAction as String?;
    final trimmedKnowledgeUnitId = parsedKnowledgeUnitId?.trim();

    return TodayPlanStartPayload(
      subjectId: subjectId.trim(),
      knowledgeUnitId: trimmedKnowledgeUnitId == null ||
              trimmedKnowledgeUnitId.isEmpty
          ? null
          : trimmedKnowledgeUnitId,
      preferredAction: parsedPreferredAction == null
          ? null
          : _parsePreferredAction(parsedPreferredAction),
    );
  }

  TodayPlanPreferredAction _parsePreferredAction(String value) {
    return switch (value) {
      'diagnostic_quiz' => TodayPlanPreferredAction.diagnosticQuiz,
      'open_question' => TodayPlanPreferredAction.openQuestion,
      _ => throw const FormatException('Invalid today preferred action'),
    };
  }
}
```

### `test/fakes/in_memory_today_repository.dart`

```dart
import 'package:revision_app/features/today/application/today_controller.dart';
import 'package:revision_app/features/today/domain/today_plan.dart';

class InMemoryTodayRepository implements TodayRepository {
  TodayPlan plan = TodayPlan(
    generatedAt: DateTime.utc(2026, 6, 13),
    items: const [],
  );
  Object? error;
  int getTodayPlanCalls = 0;

  @override
  Future<TodayPlan> getTodayPlan() async {
    getTodayPlanCalls += 1;
    final currentError = error;
    if (currentError != null) {
      throw currentError;
    }

    return plan;
  }
}
```

### `lib/presentation/pages/today/today_page.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:revision_app/core/routing/route_paths.dart';
import 'package:revision_app/features/today/application/today_notifier.dart';
import 'package:revision_app/features/today/domain/today_plan.dart';
import 'package:revision_app/presentation/theme/app_colors.dart';
import 'package:revision_app/presentation/theme/app_spacing.dart';
import 'package:revision_app/presentation/widgets/revision_button.dart';
import 'package:revision_app/presentation/widgets/revision_icon_badge.dart';
import 'package:revision_app/presentation/widgets/revision_message.dart';
import 'package:revision_app/presentation/widgets/revision_page.dart';
import 'package:revision_app/presentation/widgets/revision_panel.dart';
import 'package:revision_app/presentation/widgets/revision_progress_bar.dart';
import 'package:revision_app/presentation/widgets/revision_status_pill.dart';

class TodayPage extends ConsumerWidget {
  const TodayPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plan = ref.watch(todayNotifierProvider);
    final notifier = ref.read(todayNotifierProvider.notifier);

    return RevisionPage(
      title: 'Plan du jour',
      subtitle: 'Actions prioritaires pour avancer sans te disperser.',
      trailing: IconButton(
        onPressed: notifier.reload,
        icon: const Icon(Icons.refresh),
        tooltip: 'Recharger',
      ),
      children: [
        plan.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) =>
              _TodayErrorState(onRetry: notifier.reload),
          data: (plan) {
            if (plan.items.isEmpty) {
              return const _TodayEmptyState();
            }

            return _TodayPlanContent(plan: plan);
          },
        ),
      ],
    );
  }
}

class _TodayPlanContent extends StatelessWidget {
  const _TodayPlanContent({required this.plan});

  final TodayPlan plan;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: AppSpacing.itemGap,
      children: [
        RevisionPanel(
          child: Wrap(
            spacing: AppSpacing.s,
            runSpacing: AppSpacing.s,
            children: [
              RevisionStatusPill(
                label: '${plan.items.length} actions',
                icon: Icons.playlist_add_check,
                color: AppColors.primaryDark,
              ),
              RevisionStatusPill(
                label: '${plan.totalEstimatedMinutes} min',
                icon: Icons.schedule,
                color: AppColors.aqua,
              ),
            ],
          ),
        ),
        for (final item in plan.items) _TodayPlanItemCard(item: item),
      ],
    );
  }
}

class _TodayPlanItemCard extends StatelessWidget {
  const _TodayPlanItemCard({required this.item});

  final TodayPlanItem item;

  @override
  Widget build(BuildContext context) {
    final action = _TodayActionPresentation.from(item.action);
    final canStart = _canStartAction(item);
    final masteryScore = item.masteryScore;

    return RevisionPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RevisionIconBadge(icon: action.icon, color: action.color),
              const SizedBox(width: AppSpacing.l),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      action.title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      _targetLabel(item),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.l),
          Text(
            item.reason,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.m),
          Wrap(
            spacing: AppSpacing.s,
            runSpacing: AppSpacing.s,
            children: [
              RevisionStatusPill(
                label: '${item.estimatedMinutes} min',
                icon: Icons.schedule,
                color: AppColors.aqua,
              ),
              RevisionStatusPill(
                label: 'Priorité ${item.priority}',
                icon: Icons.flag,
                color: AppColors.amber,
              ),
              RevisionStatusPill(
                label: _reasonCodeLabel(item.reasonCode),
                icon: Icons.lightbulb_outline,
                color: AppColors.violet,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.l),
          if (masteryScore == null)
            Text(
              'Maîtrise non mesurée',
              style: Theme.of(context).textTheme.bodyMedium,
            )
          else ...[
            RevisionProgressBar(value: masteryScore),
            const SizedBox(height: AppSpacing.s),
            Text(
              'Maîtrise ${(_clampMastery(masteryScore) * 100).round()} %',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
          const SizedBox(height: AppSpacing.l),
          Align(
            alignment: Alignment.centerLeft,
            child: RevisionButton(
              onPressed: canStart ? () => context.go(_routeFor(item)) : null,
              icon: canStart ? action.icon : Icons.lock_outline,
              label: canStart ? action.buttonLabel : 'Action indisponible',
            ),
          ),
        ],
      ),
    );
  }

  bool _canStartAction(TodayPlanItem item) {
    final subjectId = item.startPayload.subjectId.trim();
    if (subjectId.isEmpty) {
      return false;
    }

    if (item.action == TodayPlanActionType.openQuestion) {
      return item.startPayload.knowledgeUnitId?.trim().isNotEmpty ?? false;
    }

    return true;
  }

  String _routeFor(TodayPlanItem item) {
    final payload = item.startPayload;

    return switch (item.action) {
      TodayPlanActionType.diagnosticQuiz => Uri(
        path: activitiesRoutePath,
        queryParameters: {'subjectId': payload.subjectId},
      ).toString(),
      TodayPlanActionType.openQuestion => Uri(
        path: activitiesRoutePath,
        queryParameters: {
          'subjectId': payload.subjectId,
          'knowledgeUnitId': payload.knowledgeUnitId!,
        },
      ).toString(),
      TodayPlanActionType.revisionSession => revisionSessionRoutePathFor(
        subjectId: payload.subjectId,
        knowledgeUnitId: payload.knowledgeUnitId,
        preferredAction: _preferredActionValue(payload.preferredAction),
      ),
    };
  }

  String _targetLabel(TodayPlanItem item) {
    final knowledgeUnitTitle = item.knowledgeUnitTitle?.trim();
    if (knowledgeUnitTitle == null || knowledgeUnitTitle.isEmpty) {
      return item.subjectName;
    }

    return '${item.subjectName} • $knowledgeUnitTitle';
  }

  String _reasonCodeLabel(TodayPlanReasonCode reasonCode) {
    return switch (reasonCode) {
      TodayPlanReasonCode.lowMastery => 'Maîtrise fragile',
      TodayPlanReasonCode.stalePractice => 'À entretenir',
      TodayPlanReasonCode.highPrioritySubject => 'Matière prioritaire',
      TodayPlanReasonCode.mixActivityType => 'Format varié',
      TodayPlanReasonCode.startRevisionSession => 'Session guidée',
      TodayPlanReasonCode.continueProgress => 'Progression',
    };
  }

  String? _preferredActionValue(TodayPlanPreferredAction? preferredAction) {
    return switch (preferredAction) {
      TodayPlanPreferredAction.diagnosticQuiz => 'diagnostic_quiz',
      TodayPlanPreferredAction.openQuestion => 'open_question',
      null => null,
    };
  }

  double _clampMastery(double score) {
    return score.clamp(0, 1).toDouble();
  }
}

class _TodayActionPresentation {
  const _TodayActionPresentation({
    required this.title,
    required this.buttonLabel,
    required this.icon,
    required this.color,
  });

  final String title;
  final String buttonLabel;
  final IconData icon;
  final Color color;

  static _TodayActionPresentation from(TodayPlanActionType action) {
    return switch (action) {
      TodayPlanActionType.diagnosticQuiz => const _TodayActionPresentation(
        title: 'QCM ciblé',
        buttonLabel: 'Démarrer le QCM',
        icon: Icons.quiz,
        color: AppColors.primaryDark,
      ),
      TodayPlanActionType.openQuestion => const _TodayActionPresentation(
        title: 'Question ouverte',
        buttonLabel: 'Répondre à la question',
        icon: Icons.edit_note,
        color: AppColors.aqua,
      ),
      TodayPlanActionType.revisionSession => const _TodayActionPresentation(
        title: 'Session de révision IA',
        buttonLabel: 'Lancer la session',
        icon: Icons.auto_awesome,
        color: AppColors.violet,
      ),
    };
  }
}

class _TodayEmptyState extends StatelessWidget {
  const _TodayEmptyState();

  @override
  Widget build(BuildContext context) {
    return RevisionPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Aucune action prioritaire pour aujourd’hui.',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.s),
          Text(
            'Ajoute une matière, importe un document ou définis un objectif pour générer ton plan.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.l),
          RevisionButton(
            onPressed: () => context.go(subjectsRoutePath),
            icon: Icons.menu_book,
            label: 'Voir mes matières',
            style: RevisionButtonStyle.ghost,
          ),
        ],
      ),
    );
  }
}

class _TodayErrorState extends StatelessWidget {
  const _TodayErrorState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RevisionMessage(
          message: 'Impossible de charger le plan',
          icon: Icons.error_outline,
          color: AppColors.danger,
        ),
        const SizedBox(height: AppSpacing.m),
        RevisionButton(
          onPressed: onRetry,
          icon: Icons.refresh,
          label: 'Réessayer',
          style: RevisionButtonStyle.ghost,
        ),
      ],
    );
  }
}
```

### `test/features/today/http_today_repository_test.dart`

```dart
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:revision_app/features/today/data/http_today_repository.dart';
import 'package:revision_app/features/today/domain/today_plan.dart';

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
  test('loads today plan with a Firebase bearer token', () async {
    final adapter = CapturingHttpClientAdapter(jsonResponse(todayJson()));
    final dio = Dio()..httpClientAdapter = adapter;
    final repository = HttpTodayRepository(
      dio: dio,
      getIdToken: () async => 'firebase-id-token',
    );

    final plan = await repository.getTodayPlan();

    expect(plan.items, hasLength(3));
    expect(plan.items.first.id, 'subject-1:unit-1:diagnostic_quiz');
    expect(plan.items.first.subjectName, 'Anatomie');
    expect(plan.items.first.knowledgeUnitId, 'unit-1');
    expect(plan.items.first.knowledgeUnitTitle, 'Cycle cardiaque');
    expect(plan.items.first.masteryScore, 0.2);
    expect(plan.items.first.action, TodayPlanActionType.diagnosticQuiz);
    expect(plan.items.first.reasonCode, TodayPlanReasonCode.lowMastery);
    expect(plan.items.first.reason, 'À revoir en priorité.');
    expect(plan.items.first.priority, 610);
    expect(plan.items.first.startPayload.subjectId, 'subject-1');
    expect(plan.items.first.startPayload.knowledgeUnitId, 'unit-1');
    expect(
      plan.items.first.startPayload.preferredAction,
      TodayPlanPreferredAction.diagnosticQuiz,
    );
    expect(plan.items[1].masteryScore, isNull);
    expect(plan.items[1].action, TodayPlanActionType.openQuestion);
    expect(plan.items[1].startPayload.preferredAction, isNull);
    expect(plan.items[2].knowledgeUnitId, isNull);
    expect(plan.items[2].knowledgeUnitTitle, isNull);
    expect(plan.items[2].action, TodayPlanActionType.revisionSession);
    expect(adapter.lastOptions?.path, '/today');
    expect(
      adapter.lastOptions?.headers['Authorization'],
      'Bearer firebase-id-token',
    );
  });

  test('rejects unknown today action values', () async {
    final body = todayJson();
    final items = body['items']! as List<Object?>;
    final firstItem = Map<String, Object?>.from(
      items.first! as Map<String, Object?>,
    );
    firstItem['action'] = 'flashcards';
    items[0] = firstItem;
    final adapter = CapturingHttpClientAdapter(jsonResponse(body));
    final dio = Dio()..httpClientAdapter = adapter;
    final repository = HttpTodayRepository(
      dio: dio,
      getIdToken: () async => 'firebase-id-token',
    );

    await expectLater(repository.getTodayPlan(), throwsFormatException);
  });

  test('rejects unknown today reason code values', () async {
    final body = todayJson();
    final items = body['items']! as List<Object?>;
    final firstItem = Map<String, Object?>.from(
      items.first! as Map<String, Object?>,
    );
    firstItem['reasonCode'] = 'RANDOM';
    items[0] = firstItem;
    final adapter = CapturingHttpClientAdapter(jsonResponse(body));
    final dio = Dio()..httpClientAdapter = adapter;
    final repository = HttpTodayRepository(
      dio: dio,
      getIdToken: () async => 'firebase-id-token',
    );

    await expectLater(repository.getTodayPlan(), throwsFormatException);
  });

  test('rejects today items without start payload subject id', () async {
    final body = todayJson();
    final items = body['items']! as List<Object?>;
    final firstItem = Map<String, Object?>.from(
      items.first! as Map<String, Object?>,
    );
    firstItem['startPayload'] = {'knowledgeUnitId': 'unit-1'};
    items[0] = firstItem;
    final adapter = CapturingHttpClientAdapter(jsonResponse(body));
    final dio = Dio()..httpClientAdapter = adapter;
    final repository = HttpTodayRepository(
      dio: dio,
      getIdToken: () async => 'firebase-id-token',
    );

    await expectLater(repository.getTodayPlan(), throwsFormatException);
  });

  test('rejects invalid generatedAt and items shape', () async {
    final invalidGeneratedAt = CapturingHttpClientAdapter(
      jsonResponse({'generatedAt': 'not-a-date', 'items': []}),
    );
    final invalidItems = CapturingHttpClientAdapter(
      jsonResponse({'generatedAt': '2026-06-13T10:00:00.000Z', 'items': {}}),
    );

    await expectLater(
      HttpTodayRepository(
        dio: Dio()..httpClientAdapter = invalidGeneratedAt,
        getIdToken: () async => 'firebase-id-token',
      ).getTodayPlan(),
      throwsFormatException,
    );
    await expectLater(
      HttpTodayRepository(
        dio: Dio()..httpClientAdapter = invalidItems,
        getIdToken: () async => 'firebase-id-token',
      ).getTodayPlan(),
      throwsFormatException,
    );
  });

  test('rejects blank Firebase ID tokens before calling the API', () async {
    final adapter = CapturingHttpClientAdapter(jsonResponse(todayJson()));
    final dio = Dio()..httpClientAdapter = adapter;
    final repository = HttpTodayRepository(
      dio: dio,
      getIdToken: () async => '  ',
    );

    await expectLater(repository.getTodayPlan(), throwsStateError);

    expect(adapter.fetchCallCount, 0);
  });
}

Map<String, Object?> todayJson() {
  return {
    'generatedAt': '2026-06-13T10:00:00.000Z',
    'items': [
      {
        'subjectId': 'subject-1',
        'subjectName': 'Anatomie',
        'knowledgeUnitId': 'unit-1',
        'knowledgeUnitTitle': 'Cycle cardiaque',
        'masteryScore': 0.2,
        'action': 'diagnostic_quiz',
        'estimatedMinutes': 12,
        'id': 'subject-1:unit-1:diagnostic_quiz',
        'priority': 610,
        'reasonCode': 'LOW_MASTERY',
        'reason': 'À revoir en priorité.',
        'startPayload': {
          'subjectId': 'subject-1',
          'knowledgeUnitId': 'unit-1',
          'preferredAction': 'diagnostic_quiz',
        },
      },
      {
        'id': 'subject-1:unit-2:open_question',
        'subjectId': 'subject-1',
        'subjectName': 'Anatomie',
        'knowledgeUnitId': 'unit-2',
        'knowledgeUnitTitle': 'Valves',
        'masteryScore': null,
        'action': 'open_question',
        'estimatedMinutes': 18,
        'priority': 590,
        'reasonCode': 'MIX_ACTIVITY_TYPE',
        'reason': 'Change de format.',
        'startPayload': {'subjectId': 'subject-1', 'knowledgeUnitId': 'unit-2'},
      },
      {
        'id': 'subject-2:null:revision_session',
        'subjectId': 'subject-2',
        'subjectName': 'Droit',
        'knowledgeUnitId': null,
        'knowledgeUnitTitle': null,
        'masteryScore': 0.7,
        'action': 'revision_session',
        'estimatedMinutes': 25,
        'priority': 500,
        'reasonCode': 'START_REVISION_SESSION',
        'reason': 'Lance une session guidée.',
        'startPayload': {'subjectId': 'subject-2'},
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
```

### `test/features/today/today_page_test.dart`

```dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:revision_app/app/di/providers.dart';
import 'package:revision_app/features/today/domain/today_plan.dart';
import 'package:revision_app/presentation/pages/today/today_page.dart';

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

    expect(find.text('Aucune action prioritaire pour aujourd’hui.'), findsOneWidget);
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

    expect(find.text('3 actions'), findsOneWidget);
    expect(find.text('55 min'), findsOneWidget);
    expect(find.text('QCM ciblé'), findsOneWidget);
    expect(find.text('Question ouverte'), findsOneWidget);
    expect(find.text('Session de révision IA'), findsOneWidget);
    expect(find.text('À revoir en priorité.'), findsOneWidget);
    expect(find.text('Change de format.'), findsOneWidget);
    expect(find.text('Lance une session guidée.'), findsOneWidget);
    expect(find.text('12 min'), findsOneWidget);
    expect(find.text('Priorité 610'), findsOneWidget);
    expect(find.text('Maîtrise 20 %'), findsOneWidget);
    expect(find.text('Maîtrise non mesurée'), findsOneWidget);
    expect(find.text('Démarrer le QCM'), findsOneWidget);
    expect(find.text('Répondre à la question'), findsOneWidget);
    expect(find.text('Lancer la session'), findsOneWidget);
  });

  testWidgets('ne montre pas de barre de progression pour maîtrise non mesurée', (
    tester,
  ) async {
    final repository = InMemoryTodayRepository()
      ..plan = TodayPlan(
        generatedAt: DateTime.parse('2026-06-15T10:00:00.000Z'),
        items: [openQuestionItem()],
      );

    await tester.pumpWidget(_buildApp(repository: repository));
    await tester.pump();

    expect(find.text('Maîtrise non mesurée'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsNothing);
  });

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

    expect(router.routeInformationProvider.value.uri.toString(), '/activities?subjectId=subject-1');
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
```
