# LOT V1-013 — Today integration V1

## 1. Résultat

V1-013 est réalisé côté Flutter app pour l'intégration Today. L'app parse maintenant l'action `rich_closed_exercise`, affiche une carte Today “Questions riches” et navigue vers `/activities/rich-closed` avec `subjectId`, `knowledgeUnitId` et `documentId` quand disponible.

Today ne lance pas d'API rich closed directement depuis le parser. La page `RichClosedExercisePage` existante démarre l'exercice après navigation.

## 2. Sources inspectées

- `lib/features/today/**`
- `lib/presentation/pages/today/today_page.dart`
- `lib/features/activities/domain/rich_closed_exercise.dart`
- `lib/presentation/pages/activities/rich_closed_exercise_page.dart`
- `lib/core/routing/route_paths.dart`
- `lib/app/router/app_routes.dart`
- `lib/app/router/app_router.dart`
- `lib/presentation/pages/activities/activities_page.dart`
- `test/features/today/**`
- `test/app/router/app_router_test.dart`
- fakes in-memory Today et Activity
- `docs/v1/ROADMAP_EXECUTION_PLAN_V1.md`

## 3. Préflight Git

- repo : `/Users/karim/Project/app-révision/revision_app`
- branche : `main`
- status initial : propre, `git status --short --untracked-files=all` vide
- derniers commits :
  - `644137b Fix frontend web cache busting`
  - `30e0a12 V1-012B — Ajout du rapport d'exécution du lot Page rich closed complète et flow submit local avec routes, contrôleurs et tests`
  - `9f4dc4a V1-012 — Ajout du rapport d'exécution du lot Scoring/correction UI V1-A avec widgets et présentateur`
  - `3f1bd89 V1-011 — Ajout du rapport d'exécution du lot Widgets Flutter matching/ordering et mise à jour du contrôleur`
  - `debe6f8 V1-010 — Ajout du rapport d'exécution du lot Widgets Flutter V1-A pour single/multiple/case/error et contrôleur de réponses`
- repo backend API : modifié dans son propre rapport V1-013 séparé
- aucun commit créé

## 4. Périmètre réalisé

Backend API : réalisé dans le rapport API séparé.

Frontend app :

- ajout de `TodayPlanActionType.richClosedExercise` ;
- ajout de `TodayPlanReasonCode.richClosedPractice` ;
- support `documentId` optionnel dans `TodayPlanItem` et `TodayPlanStartPayload` ;
- parser strict du nouveau type, avec rejet si `knowledgeUnitId` manque ;
- carte Today “Questions riches” avec raison, notion, durée, priorité et CTA ;
- navigation vers `richClosedExerciseRoutePathFor(...)` ;
- fakes et tests router renforcés.

## 5. Contrat Today

Le frontend lit le naming backend existant `action`.

Action supportée : `rich_closed_exercise`.

Champs consommés :

- `subjectId` ;
- `documentId` optionnel ;
- `knowledgeUnitId` obligatoire pour cette action ;
- `knowledgeUnitTitle` ;
- `estimatedMinutes` ;
- `priority` ;
- `reason` ;
- `reasonCode: RICH_CLOSED_PRACTICE` ;
- `startPayload.subjectId`, `startPayload.knowledgeUnitId`, `startPayload.documentId` optionnel.

Le parser rejette une action rich closed sans notion. Aucun payload de questions ni correction n'est rendu dans Today.

## 6. Algorithme de recommandation

L'algorithme est côté backend et reste déterministe. Côté app, aucun ranking IA n'est ajouté : l'app se contente de présenter l'action reçue et de naviguer vers la page rich closed.

## 7. Flow utilisateur

1. Today charge le plan.
2. Une carte “Questions riches” s'affiche pour la notion ciblée.
3. Le bouton “Commencer” construit `/activities/rich-closed?subjectId=...&knowledgeUnitId=...` et ajoute `documentId` s'il existe.
4. `RichClosedExercisePage` reçoit les paramètres et démarre l'exercice via le contrôleur existant.
5. La correction reste dans le flow rich closed post-submit.

## 8. Anti-fuite / sécurité

- pas de correction affichée dans Today ;
- pas de questions rich closed dans Today ;
- pas de JSON arbitraire rendu ;
- pas d'appel direct `submit` ou `result` depuis Today ;
- pas de passage par revision sessions ;
- pas d'ID hardcodé ;
- le router test vérifie qu'aucun QCM, aucune question ouverte et aucune session IA ne démarrent lors du tap Today rich closed.

## 9. Fichiers créés/modifiés/supprimés

Fichiers modifiés :

- `lib/features/today/data/http_today_repository.dart`
- `lib/features/today/domain/today_plan.dart`
- `lib/presentation/pages/today/today_page.dart`
- `test/app/router/app_router_test.dart`
- `test/fakes/in_memory_activity_api.dart`
- `test/features/today/http_today_repository_test.dart`
- `test/features/today/today_page_test.dart`
- `docs/v1/ROADMAP_EXECUTION_PLAN_V1.md`
- `docs/v1/ROADMAP_EXECUTION_LOT_V1_013_TODAY_INTEGRATION_V1.md` créé

Fichiers supprimés : aucun.

## 10. Tests ajoutés ou renforcés

- parser `HttpTodayRepository` : parse `rich_closed_exercise`, conserve `documentId`, conserve raison/durée, rejette une action sans `knowledgeUnitId` ;
- widget Today : affiche “Questions riches”, notion, raison, durée, CTA et navigation rich closed ;
- router : depuis Today, tap “Commencer” démarre rich closed avec subject/knowledge/document et ne démarre ni diagnostic, ni open question, ni revision session ;
- fake Activity : capture `documentId` rich closed.

## 11. Validations lancées avec résultats

- `dart format lib/features/today/domain/today_plan.dart lib/features/today/data/http_today_repository.dart lib/presentation/pages/today/today_page.dart test/features/today/http_today_repository_test.dart test/features/today/today_page_test.dart test/app/router/app_router_test.dart test/fakes/in_memory_activity_api.dart` : passé, 2 fichiers changés.
- `dart format test/features/today/today_page_test.dart` après correction de fixture : passé, 0 fichier changé.
- `flutter test test/features/today --reporter compact` : premier passage échoué sur fixture de test affichant deux “Maîtrise non mesurée”, corrigé ; relance passée, 18 tests.
- `flutter test test/app/router --reporter compact` : premier lancement en parallèle échoué sur verrou/copie Flutter, relancé seul ; passé, 10 tests.
- `dart analyze lib test` : passé, no issues found.
- `flutter test --reporter compact` : passé, 277 tests.
- `git diff --check` : passé.

## 12. Validations non lancées avec justification

- provider IA réel : non lancé, hors périmètre et interdit.
- migrations Prisma : non concerné côté app.
- `dart fix --apply` : non lancé, explicitement interdit.
- `dart format .` : non lancé, format ciblé seulement.

## 13. Risques restants

- L'app fait confiance au backend pour recommander une notion exploitable ; si le backend recommande une notion sans contexte source, la page rich closed affichera l'erreur contrôlée existante.
- Le libellé “Questions riches” est volontairement simple ; il pourra être ajusté après tests utilisateur.

## 14. Recommandation prochain lot

`V1-014 — Revision session integration V1`.

Pas besoin d'un mini-bis Today côté app sauf si l'on décide d'ajouter un état visuel dédié pour les notions sans sources rich closed.

## 15. Passes de review

- backend contract : traité dans le rapport API ;
- backend selection : traité dans le rapport API ;
- frontend parser : OK, strict et sans appel API ;
- frontend UI : OK, carte dédiée et CTA ;
- navigation : OK, route rich closed avec paramètres ;
- anti-fuite : OK, pas de questions/correction/JSON ;
- tests : OK, suites demandées passées.

## 16. Critique honnête du prompt initial

Le prompt est cohérent et bien borné : Today recommande, la page rich closed exécute. Le seul coût important est la section de contenu complet, qui rend le rapport très long. Techniquement, le point à surveiller reste l'exploitabilité source des notions recommandées, que ce lot ne vérifie pas côté app.

## 17. Contenu complet des fichiers créés/modifiés/supprimés

### Fichier modifié : `lib/features/today/data/http_today_repository.dart`

~~~dart
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
    final documentId = json['documentId'];
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
        (documentId != null && documentId is! String) ||
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

    final parsedAction = _parseAction(action);
    final parsedDocumentId = documentId as String?;
    final parsedKnowledgeUnitId = knowledgeUnitId as String?;
    final parsedKnowledgeUnitTitle = knowledgeUnitTitle as String?;
    final parsedMasteryScore = masteryScore as num?;
    final parsedStartPayload = _TodayPlanStartPayloadJson(
      startPayload,
    ).toPayload();

    if (parsedAction == TodayPlanActionType.richClosedExercise &&
        (parsedKnowledgeUnitId == null ||
            parsedKnowledgeUnitId.trim().isEmpty ||
            parsedStartPayload.knowledgeUnitId == null ||
            parsedStartPayload.knowledgeUnitId!.trim().isEmpty)) {
      throw const FormatException('Invalid today rich closed action');
    }

    return TodayPlanItem(
      id: id,
      subjectId: subjectId,
      subjectName: subjectName,
      documentId: _trimOptionalString(parsedDocumentId),
      knowledgeUnitId: parsedKnowledgeUnitId,
      knowledgeUnitTitle: parsedKnowledgeUnitTitle,
      masteryScore: parsedMasteryScore?.toDouble(),
      action: parsedAction,
      estimatedMinutes: estimatedMinutes,
      priority: priority,
      reasonCode: _parseReasonCode(reasonCode),
      reason: reason,
      startPayload: parsedStartPayload,
    );
  }

  TodayPlanActionType _parseAction(String value) {
    return switch (value) {
      'diagnostic_quiz' => TodayPlanActionType.diagnosticQuiz,
      'open_question' => TodayPlanActionType.openQuestion,
      'rich_closed_exercise' => TodayPlanActionType.richClosedExercise,
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
      'RICH_CLOSED_PRACTICE' => TodayPlanReasonCode.richClosedPractice,
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
    final documentId = json['documentId'];
    final knowledgeUnitId = json['knowledgeUnitId'];
    final preferredAction = json['preferredAction'];

    if (subjectId is! String ||
        subjectId.trim().isEmpty ||
        (documentId != null && documentId is! String) ||
        (knowledgeUnitId != null && knowledgeUnitId is! String) ||
        (preferredAction != null && preferredAction is! String)) {
      throw const FormatException('Invalid today start payload');
    }

    final parsedDocumentId = documentId as String?;
    final parsedKnowledgeUnitId = knowledgeUnitId as String?;
    final parsedPreferredAction = preferredAction as String?;

    return TodayPlanStartPayload(
      subjectId: subjectId.trim(),
      documentId: _trimOptionalString(parsedDocumentId),
      knowledgeUnitId: _trimOptionalString(parsedKnowledgeUnitId),
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

String? _trimOptionalString(String? value) {
  final trimmedValue = value?.trim();
  return trimmedValue == null || trimmedValue.isEmpty ? null : trimmedValue;
}

~~~

### Fichier modifié : `lib/features/today/domain/today_plan.dart`

~~~dart
class TodayPlan {
  const TodayPlan({required this.generatedAt, required this.items});

  final DateTime generatedAt;
  final List<TodayPlanItem> items;

  int get totalEstimatedMinutes {
    return items.fold(0, (total, item) => total + item.estimatedMinutes);
  }
}

enum TodayPlanActionType {
  diagnosticQuiz,
  openQuestion,
  richClosedExercise,
  revisionSession,
}

enum TodayPlanReasonCode {
  lowMastery,
  stalePractice,
  highPrioritySubject,
  mixActivityType,
  richClosedPractice,
  startRevisionSession,
  continueProgress,
}

enum TodayPlanPreferredAction { diagnosticQuiz, openQuestion }

class TodayPlanStartPayload {
  const TodayPlanStartPayload({
    required this.subjectId,
    this.documentId,
    this.knowledgeUnitId,
    this.preferredAction,
  });

  final String subjectId;
  final String? documentId;
  final String? knowledgeUnitId;
  final TodayPlanPreferredAction? preferredAction;
}

class TodayPlanItem {
  const TodayPlanItem({
    required this.id,
    required this.subjectId,
    required this.subjectName,
    this.documentId,
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
  final String? documentId;
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

~~~

### Fichier modifié : `lib/presentation/pages/today/today_page.dart`

~~~dart
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
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
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

    if (item.action == TodayPlanActionType.openQuestion ||
        item.action == TodayPlanActionType.richClosedExercise) {
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
      TodayPlanActionType.richClosedExercise => richClosedExerciseRoutePathFor(
        subjectId: payload.subjectId,
        documentId: payload.documentId ?? item.documentId,
        knowledgeUnitId: payload.knowledgeUnitId,
      ),
      TodayPlanActionType.revisionSession => revisionSessionRoutePathFor(
        subjectId: payload.subjectId,
        documentId: payload.documentId ?? item.documentId,
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
      TodayPlanReasonCode.richClosedPractice => 'Exercice structuré',
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
      TodayPlanActionType.richClosedExercise => const _TodayActionPresentation(
        title: 'Questions riches',
        buttonLabel: 'Commencer',
        icon: Icons.fact_check,
        color: AppColors.amber,
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

~~~

### Fichier modifié : `test/app/router/app_router_test.dart`

~~~dart
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
import 'package:revision_app/features/documents/application/documents_controller.dart';
import 'package:revision_app/features/onboarding/application/revision_goals_controller.dart';
import 'package:revision_app/features/revision_sessions/application/revision_session_controller.dart';
import 'package:revision_app/features/subjects/application/subjects_controller.dart';
import 'package:revision_app/features/today/application/today_controller.dart';
import 'package:revision_app/features/today/domain/today_plan.dart';
import 'package:revision_app/presentation/widgets/revision_button.dart';

import '../../fakes/in_memory_activity_api.dart';
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
      expect(
        router.routeInformationProvider.value.uri.path,
        AppRoutes.subjects,
      );
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
      subjectsController = SubjectsController(InMemorySubjectsRepository()),
      revisionGoalsController = RevisionGoalsController(
        InMemoryRevisionGoalsRepository(),
      ),
      documentsController = DocumentsController(InMemoryDocumentsApi()),
      activityApi = InMemoryActivityApi(),
      revisionSessionsApi = InMemoryRevisionSessionsApi() {
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
  final SubjectsController subjectsController;
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
        subjectsControllerProvider.overrideWithValue(subjectsController),
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

~~~

### Fichier modifié : `test/fakes/in_memory_activity_api.dart`

~~~dart
import 'package:revision_app/features/activities/application/activity_controller.dart';
import 'package:revision_app/features/activities/domain/diagnostic_quiz_activity.dart';
import 'package:revision_app/features/activities/domain/open_question_activity.dart';
import 'package:revision_app/features/activities/domain/rich_closed_exercise.dart';

import '../features/activities/fixtures/rich_closed_exercise_fixtures.dart';

class InMemoryActivityApi implements ActivityApi {
  String? startedSubjectId;
  String? startedKnowledgeUnitId;
  String? startedOpenQuestionSubjectId;
  String? startedOpenQuestionKnowledgeUnitId;
  String? startedRichClosedSubjectId;
  String? startedRichClosedKnowledgeUnitId;
  String? startedRichClosedDocumentId;
  String? loadedRichClosedSessionId;
  String? submittedRichClosedSessionId;
  int startedDiagnosticQuizCount = 0;
  int startedOpenQuestionCount = 0;
  int startedRichClosedCount = 0;
  int submittedRichClosedCount = 0;
  List<DiagnosticQuizAnswer>? submittedAnswers;
  List<RichClosedAnswer>? submittedRichClosedAnswers;
  String? submittedOpenAnswerText;

  @override
  Future<DiagnosticQuizActivity> startNextActivity({
    required String subjectId,
    String? knowledgeUnitId,
  }) async {
    startedSubjectId = subjectId;
    startedKnowledgeUnitId = knowledgeUnitId;
    startedDiagnosticQuizCount += 1;

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
    startedOpenQuestionCount += 1;

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

  @override
  Future<RichClosedExercise> startRichClosedExercise({
    required String subjectId,
    required String knowledgeUnitId,
    String? documentId,
    int questionCount = 6,
    RichClosedComplexityProfile complexityProfile =
        RichClosedComplexityProfile.exam,
    Map<RichClosedQuestionKind, int>? questionTypeMix,
  }) async {
    startedRichClosedSubjectId = subjectId;
    startedRichClosedKnowledgeUnitId = knowledgeUnitId;
    startedRichClosedDocumentId = documentId;
    startedRichClosedCount += 1;

    return RichClosedExercise.fromJson(richClosedExerciseJson());
  }

  @override
  Future<RichClosedExercise> getRichClosedExercise(String sessionId) async {
    loadedRichClosedSessionId = sessionId;

    return RichClosedExercise.fromJson(richClosedExerciseJson());
  }

  @override
  Future<RichClosedExerciseResult> submitRichClosedExercise({
    required String sessionId,
    required List<RichClosedAnswer> answers,
  }) async {
    submittedRichClosedSessionId = sessionId;
    submittedRichClosedAnswers = answers;
    submittedRichClosedCount += 1;

    return RichClosedExerciseResult.fromJson(richClosedResultJson());
  }

  @override
  Future<RichClosedExerciseResult> getRichClosedExerciseResult(
    String sessionId,
  ) async {
    return RichClosedExerciseResult.fromJson(richClosedResultJson());
  }
}

~~~

### Fichier modifié : `test/features/today/http_today_repository_test.dart`

~~~dart
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

    expect(plan.items, hasLength(4));
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
    expect(plan.items[2].documentId, 'document-1');
    expect(plan.items[2].action, TodayPlanActionType.richClosedExercise);
    expect(plan.items[2].reasonCode, TodayPlanReasonCode.richClosedPractice);
    expect(plan.items[2].startPayload.documentId, 'document-1');
    expect(plan.items[2].startPayload.knowledgeUnitId, 'unit-2');
    expect(plan.items[3].knowledgeUnitId, isNull);
    expect(plan.items[3].knowledgeUnitTitle, isNull);
    expect(plan.items[3].action, TodayPlanActionType.revisionSession);
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

  test('rejects rich closed actions without a knowledge unit id', () async {
    final body = todayJson();
    final items = body['items']! as List<Object?>;
    final richClosedItem = Map<String, Object?>.from(
      items[2]! as Map<String, Object?>,
    );
    richClosedItem['knowledgeUnitId'] = null;
    richClosedItem['startPayload'] = {'subjectId': 'subject-1'};
    items[2] = richClosedItem;
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
        'id': 'subject-1:unit-2:rich_closed_exercise',
        'subjectId': 'subject-1',
        'subjectName': 'Anatomie',
        'documentId': 'document-1',
        'knowledgeUnitId': 'unit-2',
        'knowledgeUnitTitle': 'Valves',
        'masteryScore': null,
        'action': 'rich_closed_exercise',
        'estimatedMinutes': 8,
        'priority': 585,
        'reasonCode': 'RICH_CLOSED_PRACTICE',
        'reason': 'Questions riches recommandées.',
        'startPayload': {
          'subjectId': 'subject-1',
          'documentId': 'document-1',
          'knowledgeUnitId': 'unit-2',
        },
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

~~~

### Fichier modifié : `test/features/today/today_page_test.dart`

~~~dart
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

~~~

### Fichier modifié : `docs/v1/ROADMAP_EXECUTION_PLAN_V1.md`

~~~md
# Plan d'exécution V1 — Questions riches fermées

## Introduction

Ce plan découpe la V1 “questions riches fermées” en lots atomiques. La règle directrice est d'éviter le big bang : on stabilise d'abord le contrat, puis les quality gates, puis un sous-ensemble V1-A très rentable pédagogiquement, avant d'étendre progressivement Today, les sessions IA, les fixtures et les types plus complexes.

Tous les rapports V1 doivent être créés dans `docs/v1`.

## Principes d'exécution

- Lots de 0,5 à 2 jours quand possible.
- Aucun type de question n'est ajouté sans contrat backend, parser frontend, tests anti-fuite et fallback.
- Le QCM v3 V0 reste compatible jusqu'à migration explicite.
- La réponse libre reste exclusivement dans `open_question`.
- Genkit ne choisit jamais de widget libre.
- Flutter ne rend jamais un payload arbitraire.
- Les corrections restent post-submit.
- Chaque lot doit documenter les validations lancées et les validations non lancées.

## Tableau des lots V1

| Lot | Titre | Statut | Rapport |
| --- | --- | --- | --- |
| V1-001 | Roadmap et catalogue questions riches fermées | Réalisé | docs/v1/ROADMAP_EXECUTION_LOT_V1_001_RICH_QUESTIONS_ROADMAP.md |
| V1-002 | ADR contrat rich closed questions | Réalisé | docs/v1/ROADMAP_EXECUTION_LOT_V1_002_RICH_CLOSED_QUESTIONS_ADR.md |
| V1-003 | Audit Prisma/DTO et décision versioning | Réalisé | docs/v1/ROADMAP_EXECUTION_LOT_V1_003_PRISMA_DTO_VERSIONING_AUDIT.md |
| V1-004 | Contrat backend rich question kinds | Réalisé | docs/v1/ROADMAP_EXECUTION_LOT_V1_004_BACKEND_RICH_QUESTION_KINDS.md |
| V1-005 | Quality gates pédagogiques backend | Réalisé | docs/v1/ROADMAP_EXECUTION_LOT_V1_005_PEDAGOGICAL_QUALITY_GATES.md |
| V1-005B | Hardening contrat public et validators rich closed questions | Réalisé | docs/v1/ROADMAP_EXECUTION_LOT_V1_005B_RICH_CLOSED_CONTRACT_HARDENING.md |
| V1-006 | Génération Genkit rich closed questions V1-A | Réalisé | docs/v1/ROADMAP_EXECUTION_LOT_V1_006_GENKIT_RICH_CLOSED_V1A.md |
| V1-007 | Persistance minimale V1-A | Réalisé | docs/v1/ROADMAP_EXECUTION_LOT_V1_007_PERSISTENCE_V1A.md |
| V1-008 | API publique pré-submit/post-submit V1-A | Réalisé | docs/v1/ROADMAP_EXECUTION_LOT_V1_008_PUBLIC_API_V1A.md |
| V1-008B | Hardening API/scoring rich closed V1-A | Réalisé | docs/v1/ROADMAP_EXECUTION_LOT_V1_008B_RICH_CLOSED_API_SCORING_HARDENING.md |
| V1-009 | Domain models Flutter V1-A | Réalisé | docs/v1/ROADMAP_EXECUTION_LOT_V1_009_FLUTTER_DOMAIN_V1A.md |
| V1-010 | Widgets Flutter V1-A single/multiple/case/error | Réalisé | docs/v1/ROADMAP_EXECUTION_LOT_V1_010_FLUTTER_WIDGETS_CORE_V1A.md |
| V1-011 | Widgets Flutter matching/ordering | Réalisé | docs/v1/ROADMAP_EXECUTION_LOT_V1_011_FLUTTER_MATCHING_ORDERING.md |
| V1-012 | Scoring/correction UI V1-A | Réalisé | docs/v1/ROADMAP_EXECUTION_LOT_V1_012_SCORING_CORRECTION_UI_V1A.md |
| V1-012B | Page rich closed complète et flow submit local | Réalisé | docs/v1/ROADMAP_EXECUTION_LOT_V1_012B_RICH_CLOSED_PAGE_FLOW.md |
| V1-013 | Today integration V1 | Réalisé | docs/v1/ROADMAP_EXECUTION_LOT_V1_013_TODAY_INTEGRATION_V1.md |
| V1-014 | Revision session integration V1 | À faire | À créer |
| V1-015 | Seed V1 rich demo fixtures | À faire | À créer |
| V1-016 | E2E/smoke V1 rich questions | À faire | À créer |
| V1-017 | Timeline/date slider V1-B | À faire | À créer |
| V1-018 | True/false grid + cause/consequence V1-B | À faire | À créer |
| V1-019 | Institution matrix V1-C | À faire | À créer |
| V1-020 | Diagram labeling V1-C | À faire | À créer |
| V1-021 | Calculation MCQ modes de scrutin V1-C | À faire | À créer |
| V1-022 | Image choice/personnages historiques V1-D | À faire | À créer |
| V1-023 | Runbook demo V1 | À faire | À créer |
| V1-024 | Polish UI/accessibilité/performance | À faire | À créer |
| V1-025 | Revue finale V1 et readiness audit | À faire | À créer |

## Lots détaillés

### V1-001 — Roadmap et catalogue questions riches fermées

- Objectif : créer la vision V1, le catalogue, les exemples et le plan d'exécution.
- Pourquoi maintenant : la V0 est stable, mais les QCM restent trop basiques.
- Périmètre inclus : documentation stratégique dans `docs/v1`.
- Non-objectifs : runtime, Prisma, Genkit, Flutter, tests.
- Fichiers probablement concernés : `docs/v1/*`.
- Backend : audit seulement.
- Frontend : audit seulement.
- Genkit : audit seulement.
- GenUI : audit seulement.
- Prisma : audit seulement.
- API : aucune modification.
- Tests attendus : aucun test applicatif.
- Validations à lancer : `git diff --check` depuis `revision_app`.
- Critères d'acceptation : docs V1 créées, aucun runtime modifié.
- Critère de stop : si les repos complets ne sont pas accessibles.
- Risques : plan trop large ou trop proche d'une implémentation.
- Rapport attendu : `docs/v1/ROADMAP_EXECUTION_LOT_V1_001_RICH_QUESTIONS_ROADMAP.md`.

### V1-002 — ADR contrat rich closed questions

- Objectif : trancher le modèle de contrat : QCM v4, nouvelle activité `RICH_CLOSED_EXERCISE`, JSON typé ou tables spécialisées.
- Pourquoi maintenant : toutes les implémentations futures dépendent de cette décision.
- Périmètre inclus : ADR, alternatives, décision recommandée, impacts.
- Non-objectifs : migration ou code runtime.
- Fichiers probablement concernés : `docs/v1/ADR_RICH_CLOSED_QUESTIONS_CONTRACT.md`, rapport V1-002.
- Backend : définir discriminant `questionKind`, `answerShape`, `interactionPayload`, `correctionPayload`.
- Frontend : définir besoins de parser discriminé.
- Genkit : définir nom de schema version.
- GenUI : définir place du catalogue borné.
- Prisma : comparer stratégie JSON typé et tables dédiées.
- API : définir endpoints futurs.
- Tests attendus : aucun test runtime, checklist ADR.
- Validations à lancer : `git diff --check`.
- Critères d'acceptation : une décision claire et réversible.
- Critère de stop : si l'ADR demande une migration destructive.
- Risques : sous-estimer la dette du modèle `Question`.
- Rapport attendu : `docs/v1/ROADMAP_EXECUTION_LOT_V1_002_RICH_CLOSED_QUESTIONS_ADR.md`.

### V1-003 — Audit Prisma/DTO et décision versioning

- Objectif : auditer précisément les modèles, DTO publics, serializers et mappings nécessaires à la décision V1.
- Pourquoi maintenant : éviter une migration ou un contrat incomplet.
- Périmètre inclus : documentation technique, diagrammes de mapping, risques DB.
- Non-objectifs : création de migration.
- Fichiers probablement concernés : docs V1 uniquement.
- Backend : `ActivitySession`, `Question`, `QuestionAnswer`, `QuestionVisual`, `RevisionSessionAction`.
- Frontend : modèles QCM actuels et parsers sessions.
- Genkit : versions de prompts et schemas.
- GenUI : validators existants.
- Prisma : inventaire des colonnes et contraintes.
- API : inventaire pré-submit/post-submit.
- Tests attendus : aucun test runtime.
- Validations à lancer : `git diff --check`.
- Critères d'acceptation : table claire des champs réutilisables vs manquants.
- Critère de stop : si l'audit révèle un besoin de refonte plus large.
- Risques : ambiguïté entre `DIAGNOSTIC_QUIZ` et nouveau type.
- Rapport attendu : `docs/v1/ROADMAP_EXECUTION_LOT_V1_003_PRISMA_DTO_VERSIONING_AUDIT.md`.

### V1-004 — Contrat backend rich question kinds

- Objectif : ajouter les types applicatifs backend V1-A sans Genkit réel.
- Pourquoi maintenant : stabiliser les invariants avant génération.
- Périmètre inclus : union discriminée V1-A, validators purs, tests unitaires.
- Non-objectifs : persistance complète ou UI.
- Fichiers probablement concernés : `api/src/modules/activities/application/**`.
- Backend : `single_choice`, `multiple_choice`, `matching`, `ordering`, `case_qualification`, `error_detection`.
- Frontend : aucun.
- Genkit : aucun flow.
- GenUI : aucun.
- Prisma : aucune migration si possible.
- API : pas encore exposée publiquement sauf helpers internes.
- Tests attendus : validators et anti-fuite.
- Validations à lancer : `npm test -- activities --runInBand`, `npm run lint:check`, `npm run build`.
- Critères d'acceptation : types fermés validés et corrections séparées.
- Critère de stop : si l'ADR n'est pas validée.
- Risques : contrat trop abstrait.
- Rapport attendu : `docs/v1/ROADMAP_EXECUTION_LOT_V1_004_BACKEND_RICH_QUESTION_KINDS.md`.

### V1-005 — Quality gates pédagogiques backend

- Objectif : refuser les exercices trop basiques ou incohérents.
- Pourquoi maintenant : éviter que Genkit V1-A produise un QCM classique.
- Périmètre inclus : règles de mix, sources, correction, tailles minimales.
- Non-objectifs : régénération IA complexe.
- Fichiers probablement concernés : générateurs/validators activities.
- Backend : quality gate pur et testé.
- Frontend : aucun.
- Genkit : prépare l'intégration.
- GenUI : aucun.
- Prisma : aucun.
- API : erreurs contrôlées.
- Tests attendus : mix insuffisant, type interdit, correction pré-submit, source invalide.
- Validations à lancer : tests activities, lint check, build.
- Critères d'acceptation : une sortie 100 % QCM simple est rejetée.
- Critère de stop : gates trop stricts pour données pauvres.
- Risques : faux négatifs sur petits documents.
- Rapport attendu : `docs/v1/ROADMAP_EXECUTION_LOT_V1_005_PEDAGOGICAL_QUALITY_GATES.md`.

### V1-005B — Hardening contrat public et validators rich closed questions

- Objectif : durcir le contrat public, les validators et les gates avant Genkit.
- Pourquoi maintenant : éviter que V1-006 produise ou accepte des payloads ambigus ou semi-privés.
- Périmètre inclus : types publics sans feedback, validation stricte de `cognitiveSkill`, bornes `multiple_choice`, scan anti-fuite renforcé.
- Non-objectifs : Genkit réel, Prisma, API publique, Flutter UI.
- Rapport attendu : `docs/v1/ROADMAP_EXECUTION_LOT_V1_005B_RICH_CLOSED_CONTRACT_HARDENING.md`.

### V1-006 — Génération Genkit rich closed questions V1-A

- Objectif : générer les types V1-A via Genkit avec quotas stricts.
- Pourquoi maintenant : le contrat et les gates existent.
- Périmètre inclus : prompt, schema Zod, observer metadata-only, fallback contrôlé.
- Non-objectifs : images, matrices, timeline.
- Fichiers probablement concernés : `api/src/modules/activities/infrastructure/genkit-*`.
- Backend : adapter generator V1-A.
- Frontend : aucun.
- Genkit : nouveau flow ou nouveau mode selon ADR.
- GenUI : aucun.
- Prisma : aucun.
- API : pas encore public si persistance absente.
- Note V1-006 réalisé : le générateur reste non public, non persisté et non branché API.
- Tests attendus : mock Genkit, schema strict, error codes whitelistés.
- Validations à lancer : tests ai/activities, lint check, build.
- Critères d'acceptation : le prompt impose `questionTypeMix`.
- Critère de stop : provider réel requis dans tests.
- Risques : prompts trop longs.
- Rapport attendu : `docs/v1/ROADMAP_EXECUTION_LOT_V1_006_GENKIT_RICH_CLOSED_V1A.md`.

### V1-007 — Persistance minimale V1-A

- Objectif : persister les questions riches V1-A.
- Pourquoi maintenant : génération utile seulement si relue et soumise.
- Périmètre inclus : modèle choisi par ADR, migration si nécessaire, repository.
- Non-objectifs : UI Flutter.
- Fichiers probablement concernés : Prisma, repository activities.
- Backend : adapter Prisma.
- Frontend : aucun.
- Genkit : aucun changement fonctionnel.
- GenUI : aucun.
- Prisma : migration non destructive si nécessaire.
- API : mapping interne.
- Note V1-007 réalisé : persistance dédiée `RichClosedExercisePayload` et `RichClosedExerciseResult`, payload interne JSON typé, relecture pré-submit via mapper public.
- Tests attendus : persistance, relecture pré-submit, anti-fuite.
- Validations à lancer : `npx prisma validate`, `npm run prisma:generate`, tests activities, migration sur DB jetable si créée.
- Critères d'acceptation : données privées jamais exposées pré-submit.
- Critère de stop : migration destructive.
- Risques : JSON difficile à requêter.
- Rapport attendu : `docs/v1/ROADMAP_EXECUTION_LOT_V1_007_PERSISTENCE_V1A.md`.

### V1-008 — API publique pré-submit/post-submit V1-A

- Objectif : exposer un contrat public pour démarrer et soumettre un exercice riche fermé.
- Pourquoi maintenant : la persistance existe.
- Périmètre inclus : endpoints ou extension contrôlée, DTO, error mapping.
- Non-objectifs : Flutter UI.
- Fichiers probablement concernés : controller activities, use cases.
- Backend : pré-submit sans correction, post-submit avec correction.
- Frontend : lecture seule du contrat.
- Genkit : aucun.
- GenUI : aucun.
- Prisma : aucun.
- API : nouveau type d'activité ou version selon ADR.
- Note V1-008 réalisé : endpoints `/activities/rich-closed/start`, `/activities/rich-closed/:sessionId`, `/activities/rich-closed/:sessionId/submit` et `/activities/rich-closed/:sessionId/result`.
- Tests attendus : e2e critiques, 400/404/409/422, anti-fuite.
- Validations à lancer : tests e2e, activities, lint check, build.
- Critères d'acceptation : endpoints exploitables par Flutter.
- Critère de stop : contrat public ambigu.
- Risques : casser QCM v3.
- Rapport attendu : `docs/v1/ROADMAP_EXECUTION_LOT_V1_008_PUBLIC_API_V1A.md`.

### V1-008B — Hardening API/scoring rich closed V1-A

- Objectif : corriger les validations de soumission et le cas `documentId: null` avant l’intégration Flutter.
- Pourquoi maintenant : éviter que V1-009 consomme un contrat qui accepte des IDs inconnus ou rejette artificiellement un document nul.
- Périmètre inclus : scorer rich closed, use case de démarrage, tests module/use case/scorer.
- Non-objectifs : Prisma, Genkit, Flutter, Today, revision sessions, seed.
- Rapport attendu : `docs/v1/ROADMAP_EXECUTION_LOT_V1_008B_RICH_CLOSED_API_SCORING_HARDENING.md`.

### V1-009 — Domain models Flutter V1-A

- Objectif : ajouter les modèles Flutter discriminés pour V1-A.
- Pourquoi maintenant : le contrat API est public.
- Périmètre inclus : domain, parsers data, fakes, tests.
- Non-objectifs : widgets complets.
- Fichiers probablement concernés : `lib/features/activities/domain/**`, data, tests.
- Backend : aucun.
- Frontend : sealed classes par `questionKind`.
- Note V1-009 réalisé : modèles discriminés, parsers stricts, API client préparée, aucune UI branchée.
- Genkit : aucun.
- GenUI : aucun.
- Prisma : aucun.
- API : consommation stricte.
- Tests attendus : parse valide/invalide, correction pré-submit rejetée.
- Validations à lancer : `dart analyze lib test`, tests activities.
- Critères d'acceptation : parser discriminé strict.
- Critère de stop : contrat backend instable.
- Risques : duplication avec QCM v3.
- Rapport attendu : `docs/v1/ROADMAP_EXECUTION_LOT_V1_009_FLUTTER_DOMAIN_V1A.md`.

### V1-010 — Widgets Flutter V1-A single/multiple/case/error

- Objectif : rendre les premiers types V1-A natifs.
- Pourquoi maintenant : modèles Flutter disponibles.
- Périmètre inclus : choix unique, multiple, cas, détection d'erreur.
- Non-objectifs : matching/ordering.
- Note V1-010 réalisé : widgets core V1-A ajoutés pour single/multiple/case/error, matching/ordering non inclus, correction UI complète reportée à V1-012, aucune intégration Today/session.
- Fichiers probablement concernés : pages/widgets activities.
- Backend : aucun.
- Frontend : widgets natifs accessibles.
- Genkit : aucun.
- GenUI : aucun.
- Prisma : aucun.
- API : aucun.
- Tests attendus : pré-submit, sélection, submit, correction.
- Validations à lancer : analyze, widget tests, full flutter test si possible.
- Critères d'acceptation : aucune correction visible avant submit.
- Critère de stop : overflow mobile non résolu.
- Risques : UX trop proche du QCM actuel.
- Rapport attendu : `docs/v1/ROADMAP_EXECUTION_LOT_V1_010_FLUTTER_WIDGETS_CORE_V1A.md`.

### V1-011 — Widgets Flutter matching/ordering

- Objectif : ajouter association et remise en ordre.
- Pourquoi maintenant : ce sont les interactions V1-A les plus nouvelles.
- Périmètre inclus : matching, ordering, validations locales.
- Non-objectifs : timeline complète.
- Note V1-011 réalisé : widgets matching/ordering ajoutés avec interactions accessibles sans drag-only, correction UI complète reportée à V1-012, aucune intégration Today/session.
- Fichiers probablement concernés : widgets activities, tests.
- Backend : aucun.
- Frontend : menus/dropdowns ou reordering accessible.
- Genkit : aucun.
- GenUI : aucun.
- Prisma : aucun.
- API : aucun.
- Tests attendus : associations, ordre, correction, accessibilité minimale.
- Validations à lancer : analyze, tests activities.
- Critères d'acceptation : interactions utilisables sans drag-only obligatoire.
- Critère de stop : interaction inaccessible.
- Risques : ergonomie mobile.
- Rapport attendu : `docs/v1/ROADMAP_EXECUTION_LOT_V1_011_FLUTTER_MATCHING_ORDERING.md`.

### V1-012 — Scoring/correction UI V1-A

- Objectif : unifier affichage des corrections et scores V1-A.
- Pourquoi maintenant : plusieurs widgets existent.
- Périmètre inclus : panels correction, score par type, sources post-submit.
- Non-objectifs : recalcul frontend.
- Note V1-012 réalisé : summary/result UI et correction cards V1-A ajoutées, aucun recalcul frontend, aucune intégration Today/session.
- Fichiers probablement concernés : widgets correction activities.
- Backend : aucun sauf bug de contrat.
- Frontend : affichage post-submit.
- Genkit : aucun.
- GenUI : aucun.
- Prisma : aucun.
- API : consommation.
- Tests attendus : aucune correction pré-submit, rendu post-submit.
- Validations à lancer : analyze, tests activities.
- Critères d'acceptation : correction lisible pour chaque type V1-A.
- Critère de stop : score frontend inventé.
- Risques : incohérence visuelle.
- Rapport attendu : `docs/v1/ROADMAP_EXECUTION_LOT_V1_012_SCORING_CORRECTION_UI_V1A.md`.

### V1-012B — Page rich closed complète et flow submit local

- Objectif : assembler les widgets pré-submit/post-submit rich closed en une page utilisable.
- Pourquoi maintenant : les widgets existent mais ne sont pas encore visibles dans l’app.
- Périmètre inclus : page Flutter, controller global, renderer six types, submit API, affichage correction.
- Non-objectifs : Today, revision sessions, backend, GenUI.
- Rapport attendu : `docs/v1/ROADMAP_EXECUTION_LOT_V1_012B_RICH_CLOSED_PAGE_FLOW.md`.

### V1-013 — Today integration V1

- Objectif : permettre à Today de recommander un exercice riche fermé.
- Pourquoi maintenant : runtime V1-A complet.
- Périmètre inclus : action type, start payload, routing.
- Non-objectifs : ranking IA.
- Fichiers probablement concernés : backend revision Today, Flutter Today.
- Backend : action déterministe `rich_closed_exercise`.
- Frontend : navigation vers activité V1.
- Genkit : aucun.
- GenUI : aucun.
- Prisma : aucun.
- API : Today DTO enrichi.
- Tests attendus : ranking stable, navigation.
- Validations à lancer : backend revision tests, flutter today tests.
- Critères d'acceptation : Today peut lancer un exercice riche ciblé.
- Critère de stop : ambiguïté avec open question.
- Risques : route Activities actuelle.
- Rapport attendu : `docs/v1/ROADMAP_EXECUTION_LOT_V1_013_TODAY_INTEGRATION_V1.md`.

### V1-014 — Revision session integration V1

- Objectif : orchestrer les exercices riches dans la session IA.
- Pourquoi maintenant : Today et activité V1 sont prêts.
- Périmètre inclus : action kind fermée, next-action bornée.
- Non-objectifs : widget libre ou chat libre.
- Fichiers probablement concernés : revision-sessions backend, Flutter session.
- Backend : `RICH_CLOSED_EXERCISE` action.
- Frontend : rendu payload métier.
- Genkit : coach choisit une enum, pas un widget.
- GenUI : aucun widget arbitraire.
- Prisma : migration possible si enum action.
- API : session response.
- Tests attendus : action, anti-fuite, routing.
- Validations à lancer : tests revision-sessions, activities, flutter revision sessions.
- Critères d'acceptation : session peut enchaîner rich closed exercise.
- Critère de stop : action coach non bornée.
- Risques : migration enum.
- Rapport attendu : `docs/v1/ROADMAP_EXECUTION_LOT_V1_014_REVISION_SESSION_INTEGRATION_V1.md`.

### V1-015 — Seed V1 rich demo fixtures

- Objectif : préparer une démo stable d'exercices riches.
- Pourquoi maintenant : intégrations principales prêtes.
- Périmètre inclus : fixtures synthétiques, dry-run, docs.
- Non-objectifs : provider IA réel.
- Fichiers probablement concernés : demo-seed API, docs demo.
- Backend : seed fixtures.
- Frontend : aucun.
- Genkit : aucun appel.
- GenUI : aucun.
- Prisma : aucun schéma si possible.
- API : aucun endpoint.
- Tests attendus : fixtures sans secret, IDs stables.
- Validations à lancer : demo-seed tests, revision/activities si impact.
- Critères d'acceptation : golden demo V1 rejouable.
- Critère de stop : besoin de données propriétaires.
- Risques : seed trop couplé au schéma.
- Rapport attendu : `docs/v1/ROADMAP_EXECUTION_LOT_V1_015_RICH_DEMO_FIXTURES.md`.

### V1-016 — E2E/smoke V1 rich questions

- Objectif : protéger les chemins critiques V1.
- Pourquoi maintenant : seed V1 disponible.
- Périmètre inclus : e2e API, smoke docs.
- Non-objectifs : couverture exhaustive.
- Fichiers probablement concernés : tests e2e API, docs demo.
- Backend : tests endpoints V1.
- Frontend : smoke manuel.
- Genkit : mocké.
- GenUI : anti-widget libre.
- Prisma : DB mockée ou test safe.
- API : contrats critiques.
- Tests attendus : pré-submit, submit, anti-fuite, error mapping.
- Validations à lancer : e2e, activities, build.
- Critères d'acceptation : régression démo détectée.
- Critère de stop : test dépendant d'un provider réel.
- Risques : flakiness.
- Rapport attendu : `docs/v1/ROADMAP_EXECUTION_LOT_V1_016_E2E_SMOKE_RICH_QUESTIONS.md`.

### V1-017 — Timeline/date slider V1-B

- Objectif : ajouter chronologie et date slider.
- Pourquoi maintenant : V1-A stabilisé.
- Périmètre inclus : backend contrat, Flutter widgets, tests.
- Non-objectifs : matrices.
- Fichiers probablement concernés : activities backend/frontend.
- Backend : validation bornes.
- Frontend : timeline responsive, slider accessible.
- Genkit : schema V1-B.
- GenUI : optionnel catalogué.
- Prisma : selon ADR.
- API : type V1-B.
- Tests attendus : ordre, bornes, correction.
- Validations à lancer : backend + Flutter targeted.
- Critères d'acceptation : dates bornées et accessibles.
- Critère de stop : slider inaccessible.
- Risques : dates discutables.
- Rapport attendu : `docs/v1/ROADMAP_EXECUTION_LOT_V1_017_TIMELINE_DATE_SLIDER.md`.

### V1-018 — True/false grid + cause/consequence V1-B

- Objectif : ajouter grille et relations cause/conséquence.
- Pourquoi maintenant : interactions comparatives avancées.
- Périmètre inclus : contrats, widgets, correction.
- Non-objectifs : matrix institutionnelle complète.
- Fichiers probablement concernés : activities.
- Backend : validations lignes/paires.
- Frontend : grille accessible et matching spécialisé.
- Genkit : quotas V1-B.
- GenUI : optionnel.
- Prisma : selon ADR.
- API : types V1-B.
- Tests attendus : lignes complètes, paires univoques.
- Validations à lancer : tests ciblés.
- Critères d'acceptation : pas de grille trop large.
- Critère de stop : UX mobile illisible.
- Risques : surcharge cognitive.
- Rapport attendu : `docs/v1/ROADMAP_EXECUTION_LOT_V1_018_TRUE_FALSE_GRID_CAUSE_CONSEQUENCE.md`.

### V1-019 — Institution matrix V1-C

- Objectif : ajouter matrice institutionnelle.
- Pourquoi maintenant : base des grids disponible.
- Périmètre inclus : contrat borné, widget table.
- Non-objectifs : diagram labeling.
- Fichiers probablement concernés : activities.
- Backend : dimensions bornées.
- Frontend : table scrollable accessible.
- Genkit : schema V1-C.
- GenUI : non principal.
- Prisma : selon ADR.
- API : type matrix.
- Tests attendus : dimensions, cellules, correction.
- Validations à lancer : targeted backend/flutter.
- Critères d'acceptation : matrice lisible mobile.
- Critère de stop : table inaccessible.
- Risques : complexité UI.
- Rapport attendu : `docs/v1/ROADMAP_EXECUTION_LOT_V1_019_INSTITUTION_MATRIX.md`.

### V1-020 — Diagram labeling V1-C

- Objectif : compléter des schémas institutionnels bornés.
- Pourquoi maintenant : type coûteux mais différenciant.
- Périmètre inclus : slots, labels, correction.
- Non-objectifs : SVG/Mermaid libre.
- Fichiers probablement concernés : activities widgets/validators.
- Backend : schéma de diagramme strict.
- Frontend : rendu Flutter natif.
- Genkit : payload borné.
- GenUI : éventuellement composant catalogué.
- Prisma : selon ADR.
- API : type diagram_labeling.
- Tests attendus : pas de rendu arbitraire, slots complets.
- Validations à lancer : tests ciblés.
- Critères d'acceptation : aucun HTML/SVG/Mermaid.
- Critère de stop : payload libre requis.
- Risques : tentation de Mermaid.
- Rapport attendu : `docs/v1/ROADMAP_EXECUTION_LOT_V1_020_DIAGRAM_LABELING.md`.

### V1-021 — Calculation MCQ modes de scrutin V1-C

- Objectif : gérer des calculs fermés.
- Pourquoi maintenant : utile mais nécessite validation forte.
- Périmètre inclus : mini-données, choix, étapes post-submit.
- Non-objectifs : réponse de calcul libre.
- Fichiers probablement concernés : activities.
- Backend : vérification déterministe si possible.
- Frontend : tableau + choix.
- Genkit : génération bornée.
- GenUI : aucun libre.
- Prisma : selon ADR.
- API : type calculation_mcq.
- Tests attendus : résultats déterministes.
- Validations à lancer : tests unitaires calcul.
- Critères d'acceptation : pas de calcul IA non vérifié.
- Critère de stop : impossibilité de valider les résultats.
- Risques : erreurs de calcul.
- Rapport attendu : `docs/v1/ROADMAP_EXECUTION_LOT_V1_021_CALCULATION_MCQ.md`.

### V1-022 — Image choice/personnages historiques V1-D

- Objectif : ajouter choix d'image avec assets contrôlés.
- Pourquoi maintenant : après stabilisation de la chaîne d'assets.
- Périmètre inclus : allowlist assets, alt text, droits.
- Non-objectifs : URL image libre générée par IA.
- Fichiers probablement concernés : storage/assets, activities.
- Backend : asset refs.
- Frontend : grille image accessible.
- Genkit : référence uniquement des assets autorisés.
- GenUI : aucun asset libre.
- Prisma : table asset possible.
- API : image_choice.
- Tests attendus : droits/allowlist, alt text obligatoire.
- Validations à lancer : tests targeted.
- Critères d'acceptation : aucun asset non allowlisté.
- Critère de stop : droits non clarifiés.
- Risques : copyright.
- Rapport attendu : `docs/v1/ROADMAP_EXECUTION_LOT_V1_022_IMAGE_CHOICE.md`.

### V1-023 — Runbook demo V1

- Objectif : documenter démo V1 de bout en bout.
- Pourquoi maintenant : fonctionnalités et seed V1 prêts.
- Périmètre inclus : runbook, smoke, scénario.
- Non-objectifs : déploiement prod.
- Fichiers probablement concernés : docs demo V1.
- Backend : commandes confirmées.
- Frontend : commandes confirmées.
- Genkit : config provider documentée.
- GenUI : limites documentées.
- Prisma : commandes non destructives.
- API : smoke.
- Tests attendus : docs diff check.
- Validations à lancer : git diff check, validations non destructives.
- Critères d'acceptation : démo rejouable.
- Critère de stop : commande non vérifiable présentée comme certaine.
- Risques : drift documentaire.
- Rapport attendu : `docs/v1/ROADMAP_EXECUTION_LOT_V1_023_DEMO_RUNBOOK_V1.md`.

### V1-024 — Polish UI/accessibilité/performance

- Objectif : rendre l'expérience V1 robuste et agréable.
- Pourquoi maintenant : les types principaux existent.
- Périmètre inclus : accessibilité, petits écrans, performance, états vides.
- Non-objectifs : nouveaux types.
- Fichiers probablement concernés : Flutter widgets activities.
- Backend : aucun sauf bug.
- Frontend : UI polish.
- Genkit : aucun.
- GenUI : aucun arbitraire.
- Prisma : aucun.
- API : aucun.
- Tests attendus : widget tests, screenshots si possible.
- Validations à lancer : analyze, flutter test.
- Critères d'acceptation : pas d'overflow, interactions accessibles.
- Critère de stop : refactor massif requis.
- Risques : dérive design.
- Rapport attendu : `docs/v1/ROADMAP_EXECUTION_LOT_V1_024_UI_ACCESSIBILITY_PERFORMANCE.md`.

### V1-025 — Revue finale V1 et readiness audit

- Objectif : auditer la readiness V1.
- Pourquoi maintenant : clôturer la roadmap.
- Périmètre inclus : audit produit, sécurité, tests, docs, démo.
- Non-objectifs : nouvelle feature.
- Fichiers probablement concernés : docs V1, tests smoke.
- Backend : vérification.
- Frontend : vérification.
- Genkit : vérification logs et prompts.
- GenUI : vérification catalogue borné.
- Prisma : migration status.
- API : e2e.
- Tests attendus : suite non destructive complète selon contexte.
- Validations à lancer : backend + frontend ciblés, build, diff check.
- Critères d'acceptation : V1 présentable et sûre.
- Critère de stop : fuite de correction, widget libre, tests critiques rouges.
- Risques : dette non documentée.
- Rapport attendu : `docs/v1/ROADMAP_EXECUTION_LOT_V1_025_READINESS_AUDIT.md`.

~~~

### Fichier créé : `docs/v1/ROADMAP_EXECUTION_LOT_V1_013_TODAY_INTEGRATION_V1.md`

Le présent fichier est le rapport créé pour V1-013 côté app. Son contenu complet correspond au document affiché ici. Il n'est pas recopié récursivement dans lui-même, car cela créerait une expansion infinie.
