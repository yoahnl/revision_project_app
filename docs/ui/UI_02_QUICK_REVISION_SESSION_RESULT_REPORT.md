# UI-02 — Quick revision session result report

## 1. Résumé

UI-02 remplace le parcours quick course-level utilitaire par une expérience réelle et premium : une question à la fois, progression locale lisible, submit diagnostic réel, complétion backend réelle, navigation vers un résultat réel, puis affichage des notions maîtrisées et à retravailler.

Le flow ne réintroduit aucune fixture métier et ne calcule pas de score côté Flutter. Le score affiché vient uniquement de `RevisionSessionResult.summary.score` renvoyé par le backend.

## 2. Audit initial

- `RevisionSessionPage` utilisait encore une page générique capable d'afficher IDs techniques et payloads peu adaptés au quick product.
- `RevisionSessionsApi` ne gérait que start/get ; aucun complete/result n'était disponible côté front.
- `CourseDetailPage` lançait la quick revision sur l'ancien chemin activité direct.
- La route `/revision-sessions/:sessionId/result` était encore un écran pending.
- Les pages legacy diagnostic/open/rich closed devaient rester disponibles.

## 3. Passes utilisées

- Backend Lifecycle Agent : vérifié côté app que la session quick utilise `mode`, `courseId`, `currentAction` et un payload diagnostic borné.
- Result Read Model Agent : ajout des modèles `RevisionSessionResult` et parsing strict.
- Quick Session UX Agent : création de `QuickRevisionQuizFlow` une-question-à-la-fois.
- Premium Result UI Agent : création de `RevisionSessionResultPage` avec ring, maîtrises, à retravailler et CTA.
- QA Agent : tests repository, widget, router, app, anti-fixtures.
- Reviewer Agent : contrôle navigation, absence de score fictif, absence d'ID technique affiché.

## 4. Modifications frontend

- Modèles : ajout `RevisionSessionMode`, `RevisionSessionResult`, summary et KnowledgeUnit result.
- API HTTP : ajout `completeRevisionSession` et `getRevisionSessionResult`.
- Controller : ajout `completeSession` et `loadResult`.
- Flow session : `QuickRevisionQuizFlow` affiche une seule question, supporte single/multiple choice et soumet toutes les réponses au backend.
- Résultat : `RevisionSessionResultPage` affiche score réel, ratio réel, unités maîtrisées/à retravailler et CTA.
- Routing : `/revision-sessions/:sessionId` charge le flow quick premium quand le payload est compatible ; sinon conserve les fallbacks legacy. `/revision-sessions/:sessionId/result` affiche le résultat réel.
- Course detail : le démarrage quick route vers le vrai chemin session v2.

## 5. Navigation

Après submit et complétion, le flow utilise `context.go` vers le résultat. Cela remplace la session consommée au lieu d'empiler un écran résultat par-dessus, ce qui limite la duplication de pages et répond au souci de stack déjà remonté pendant UI-01.

## 6. Données et anti-fixtures

- Aucun `78%`, `4/5 bonnes`, `870`, `7 jours` ou `Loi normale` n'est affiché par le runtime ajouté.
- Les occurrences grep restantes sont des assertions `findsNothing` dans les tests anti-fixtures.
- `CourseSource` est absent des fichiers `lib/features/courses`, `lib/features/revision_sessions`, `test/features/*`, `test/fakes` et `test/app`.

## 7. Tests ajoutés ou renforcés

- HTTP revision sessions : complete empty body, get result, 404/409 mapping.
- Quick session page : question unique, navigation question suivante, submit réel, completion réelle, route result.
- Result page : score réel et erreur not-ready.
- Router : route result réelle.
- App anti-fallback : route résultat ne retombe pas sur des valeurs fictives.
- Courses : quick start route vers `/revision-sessions/:sessionId`.

## 8. Commandes exécutées

- `dart format ...` sur les fichiers touchés : OK.
- `dart analyze lib test` : OK, no issues found.
- `flutter test test/features/courses --reporter compact` : OK, all tests passed.
- `flutter test test/features/revision_sessions --reporter compact` : OK, all tests passed.
- `flutter test test/app/revision_app_test.dart --reporter compact` : OK, all tests passed.
- `flutter test test/app/router/app_router_test.dart --reporter compact` : OK, all tests passed.
- `flutter test test/app --reporter compact` : OK, all tests passed.
- `flutter test --reporter compact` : OK, all tests passed.
- `git diff --check` : OK.

Note : un premier lancement parallèle de deux commandes Flutter ciblées a échoué sur un verrou/cleanup natif `ios/Flutter/ephemeral/Packages/.packages`. Les mêmes suites ont été relancées ensuite une par une et sont passées.

## 9. Preuve anti-fixtures

Commande : `rg -n "MvpStudyController\.instance|mvpSubjects|mvpSessionQuestions|courseOrFallback|Loi normale|78%|4/5 bonnes|870|7 jours|🔥 12|💎 870" lib/app lib/features/courses lib/features/revision_sessions lib/presentation/shell test/app test/features/courses test/features/revision_sessions || true`.

Résultat : aucune occurrence runtime dans `lib/app`, `lib/features/courses`, `lib/features/revision_sessions` ou `lib/presentation/shell`. Les occurrences restantes sont uniquement des assertions `findsNothing` dans les tests anti-fixtures.

## 10. Preuve anti-CourseSource

Commande : `rg -n "CourseSource" lib/features/courses lib/features/revision_sessions test/features/courses test/features/revision_sessions test/fakes test/app || true`.

Résultat : aucune occurrence.

## 11. Limites connues

- Le quick MVP reste une seule action diagnostic quiz.
- Pas de résultat session final pour deep/exam.
- Pas de coach multi-action.
- Le résultat affiche les KnowledgeUnits agrégées disponibles ; il ne crée pas encore une analyse pédagogique avancée.

## 12. Risques restants

- Une session quick avec payload incomplet conserve le fallback legacy au lieu de bloquer toute la route.
- La gestion de l'abandon est volontairement simple : confirmation puis retour cours/home.
- Les erreurs de complétion après submit sont récupérables par retry, mais il faudra surveiller les cas réseau réels.

## 13. Ce qui reste pour UI-03 / PLUS

- Deep revision premium.
- Exam mode.
- Résultat multi-action.
- Recommandations post-session avancées.
- Coach/next-action réel au-delà du quick MVP.

## 14. Auto-review

- Une seule question à la fois : oui.
- Pas d'ID technique visible : contrôlé par tests et par l'UI.
- Pas de correction pré-submit : oui.
- Score réel backend : oui.
- Navigation sans duplication après completion : `go` vers result.
- Routes legacy conservées : oui.
- Aucun backend modifié depuis le repo Flutter : oui.
- Aucun commit effectué.

## 15. Points discutables du prompt

- `QuickRevisionQuizFlow` vit dans `features/revision_sessions/presentation` alors que l'ancienne page principale reste sous `presentation/pages`; c'est une transition acceptable mais à harmoniser plus tard.
- Le fallback legacy dans `RevisionSessionPage` protège les anciens flows, mais rend la page plus polymorphe que souhaitable à long terme.
- Les CTA résultat restent simples ; une vraie recommandation post-session devra attendre un contrat produit plus riche.

## 16. Fichiers créés

- `lib/features/revision_sessions/presentation/quick_revision_quiz_flow.dart`
- `lib/presentation/pages/revision_sessions/revision_session_result_page.dart`
- `test/features/revision_sessions/revision_session_result_page_test.dart`
- `docs/ui/UI_02_QUICK_REVISION_SESSION_RESULT_REPORT.md`

## 17. Fichiers modifiés

- `docs/ui/REVISION_PROJECT_UI_TARGET.md`
- `lib/app/router/app_router.dart`
- `lib/features/courses/presentation/course_detail_page.dart`
- `lib/features/revision_sessions/application/revision_session_controller.dart`
- `lib/features/revision_sessions/data/http_revision_sessions_api.dart`
- `lib/features/revision_sessions/data/revision_sessions_api.dart`
- `lib/features/revision_sessions/domain/revision_session.dart`
- `lib/presentation/pages/revision_sessions/revision_session_page.dart`
- `test/app/revision_app_test.dart`
- `test/app/router/app_router_test.dart`
- `test/fakes/in_memory_activity_api.dart`
- `test/fakes/in_memory_courses_repository.dart`
- `test/fakes/in_memory_revision_sessions_api.dart`
- `test/features/courses/course_detail_page_test.dart`
- `test/features/courses/http_courses_repository_test.dart`
- `test/features/revision_sessions/http_revision_sessions_api_test.dart`
- `test/features/revision_sessions/revision_session_page_test.dart`

## 18. Fichiers supprimés

- Aucun.

## 19. Contenu complet des fichiers créés/modifiés/supprimés

Le présent rapport est listé comme fichier créé mais n'est pas auto-inclus dans son propre appendice pour éviter une récursion infinie.

### `lib/features/revision_sessions/presentation/quick_revision_quiz_flow.dart`

````text
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_routes.dart';
import '../../activities/application/activity_controller.dart';
import '../../activities/domain/diagnostic_quiz_activity.dart';
import '../../courses/application/courses_providers.dart';
import '../../courses/domain/course_models.dart';
import '../application/revision_session_controller.dart';
import '../domain/revision_session.dart';
import '../../../presentation/design_system/components/revision_mvp_components.dart';
import '../../../presentation/design_system/tokens/revision_colors.dart';
import '../../../presentation/design_system/tokens/revision_spacing.dart';
import '../../../presentation/design_system/tokens/revision_typography.dart';

class QuickRevisionQuizFlow extends ConsumerStatefulWidget {
  const QuickRevisionQuizFlow({
    required this.response,
    required this.activity,
    required this.activityController,
    required this.revisionSessionController,
    super.key,
  });

  final RevisionSessionResponse response;
  final DiagnosticQuizActivity activity;
  final ActivityController activityController;
  final RevisionSessionController revisionSessionController;

  @override
  ConsumerState<QuickRevisionQuizFlow> createState() =>
      _QuickRevisionQuizFlowState();
}

class _QuickRevisionQuizFlowState extends ConsumerState<QuickRevisionQuizFlow> {
  final Map<String, Set<String>> _selectedChoiceIds = {};
  int _questionIndex = 0;
  bool _isSubmitting = false;
  bool _activitySubmitted = false;
  Object? _submitError;

  List<DiagnosticQuizQuestion> get _questions => widget.activity.questions;

  @override
  Widget build(BuildContext context) {
    final courseId = widget.response.session.courseId;
    final course = courseId == null
        ? const AsyncValue<CourseDetail?>.data(null)
        : ref
              .watch(courseDetailProvider(courseId))
              .whenData((detail) => detail);
    final question = _questions[_questionIndex];
    final selected = _selectedChoiceIds[question.id] ?? <String>{};
    final canContinue = _isQuestionAnswered(question);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          _confirmExit(context);
        }
      },
      child: RevisionPageScaffold(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => _confirmExit(context),
                icon: const Icon(
                  Icons.arrow_back_rounded,
                  color: RevisionColors.text,
                ),
              ),
              const Expanded(
                child: Text(
                  'Révision rapide',
                  textAlign: TextAlign.center,
                  style: RevisionTypography.sectionTitle,
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
          course.when(
            data: (detail) => _QuickHeader(
              courseTitle: detail?.course.title ?? widget.activity.title,
              subjectName: detail?.subject.name,
              sourceName: _sourceName(detail, widget.response.currentAction),
            ),
            loading: () => _QuickHeader(
              courseTitle: widget.activity.title,
              subjectName: null,
              sourceName: null,
            ),
            error: (_, _) => _QuickHeader(
              courseTitle: widget.activity.title,
              subjectName: null,
              sourceName: null,
            ),
          ),
          _QuestionProgress(
            current: _questionIndex + 1,
            total: _questions.length,
          ),
          RevisionGlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(question.prompt, style: RevisionTypography.sectionTitle),
                const SizedBox(height: RevisionSpacing.l),
                for (final entry in question.choices.indexed) ...[
                  _AnswerChoiceCard(
                    label: _choiceLetter(entry.$1),
                    text: entry.$2.label,
                    selected: selected.contains(entry.$2.id),
                    onTap: () => _toggleChoice(question, entry.$2.id),
                  ),
                  if (entry.$1 != question.choices.length - 1)
                    const SizedBox(height: RevisionSpacing.s),
                ],
                if (question.selectionMode ==
                    DiagnosticQuizSelectionMode.multiple)
                  Padding(
                    padding: const EdgeInsets.only(top: RevisionSpacing.m),
                    child: Text(
                      '${question.minSelections} à ${question.maxSelections} réponses',
                      style: RevisionTypography.caption,
                    ),
                  ),
              ],
            ),
          ),
          Row(
            children: [
              Expanded(
                child: RevisionGradientButton(
                  label: 'Précédent',
                  icon: Icons.chevron_left_rounded,
                  onPressed: _questionIndex == 0 || _isSubmitting
                      ? null
                      : () => setState(() => _questionIndex -= 1),
                  gradient: const LinearGradient(
                    colors: [RevisionColors.glassStrong, RevisionColors.ink3],
                  ),
                ),
              ),
              const SizedBox(width: RevisionSpacing.m),
              Expanded(
                child: RevisionGradientButton(
                  label: _questionIndex == _questions.length - 1
                      ? (_isSubmitting ? 'Validation...' : 'Terminer')
                      : 'Suivant',
                  icon: _questionIndex == _questions.length - 1
                      ? Icons.check_rounded
                      : Icons.chevron_right_rounded,
                  onPressed: canContinue && !_isSubmitting ? _continue : null,
                ),
              ),
            ],
          ),
          if (_submitError != null)
            RevisionGlassCard(
              borderColor: RevisionColors.red,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _activitySubmitted
                        ? 'La session est soumise, mais pas encore finalisée.'
                        : 'Impossible de soumettre la session.',
                    style: RevisionTypography.sectionTitle.copyWith(
                      color: RevisionColors.red,
                    ),
                  ),
                  const SizedBox(height: RevisionSpacing.s),
                  Text(
                    _activitySubmitted
                        ? 'Relance uniquement la finalisation côté backend.'
                        : 'Tes réponses restent sur cet écran.',
                    style: RevisionTypography.body,
                  ),
                  const SizedBox(height: RevisionSpacing.m),
                  RevisionGradientButton(
                    label: _activitySubmitted
                        ? 'Finaliser la session'
                        : 'Réessayer',
                    icon: Icons.refresh_rounded,
                    onPressed: _isSubmitting ? null : _submit,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  bool _isQuestionAnswered(DiagnosticQuizQuestion question) {
    final selected = _selectedChoiceIds[question.id] ?? <String>{};

    return selected.length >= question.minSelections &&
        selected.length <= question.maxSelections;
  }

  void _toggleChoice(DiagnosticQuizQuestion question, String choiceId) {
    setState(() {
      final current = {...?_selectedChoiceIds[question.id]};
      if (question.selectionMode == DiagnosticQuizSelectionMode.single) {
        _selectedChoiceIds[question.id] = {choiceId};
        return;
      }

      if (current.contains(choiceId)) {
        current.remove(choiceId);
      } else if (current.length < question.maxSelections) {
        current.add(choiceId);
      }

      _selectedChoiceIds[question.id] = current;
    });
  }

  void _continue() {
    if (_questionIndex < _questions.length - 1) {
      setState(() => _questionIndex += 1);
      return;
    }

    _submit();
  }

  Future<void> _submit() async {
    setState(() {
      _isSubmitting = true;
      _submitError = null;
    });

    try {
      if (!_activitySubmitted) {
        await widget.activityController.submitResult(
          sessionId: widget.activity.sessionId,
          answers: _buildAnswers(),
        );
        _activitySubmitted = true;
      }

      await widget.revisionSessionController.completeSession(
        sessionId: widget.response.session.id,
      );

      _invalidateCourseState();

      if (!mounted) {
        return;
      }

      context.go(
        AppRoutes.revisionSessionResultV2(
          sessionId: widget.response.session.id,
          courseId: widget.response.session.courseId,
          mode: 'quick',
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _submitError = error;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  List<DiagnosticQuizAnswer> _buildAnswers() {
    return _questions
        .map((question) {
          final selected = _selectedChoiceIds[question.id] ?? <String>{};
          final ordered = question.choices
              .map((choice) => choice.id)
              .where(selected.contains)
              .toList(growable: false);

          if (question.selectionMode == DiagnosticQuizSelectionMode.single) {
            return DiagnosticQuizAnswer(
              questionId: question.id,
              choiceId: ordered.first,
            );
          }

          return DiagnosticQuizAnswer(
            questionId: question.id,
            choiceIds: ordered,
          );
        })
        .toList(growable: false);
  }

  void _invalidateCourseState() {
    final courseId = widget.response.session.courseId;
    if (courseId == null) {
      return;
    }

    ref.invalidate(courseDetailProvider(courseId));
    ref.invalidate(courseProgressProvider(courseId));
    ref.invalidate(subjectProgressProvider(widget.response.session.subjectId));
  }

  Future<void> _confirmExit(BuildContext context) async {
    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Quitter la session ?'),
        content: const Text('Les réponses non soumises seront perdues.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Continuer'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Quitter'),
          ),
        ],
      ),
    );

    if (shouldExit != true || !context.mounted) {
      return;
    }

    final courseId = widget.response.session.courseId;
    if (courseId != null) {
      context.go(AppRoutes.course(courseId));
      return;
    }

    context.go(AppRoutes.revisions);
  }

  String? _sourceName(CourseDetail? detail, RevisionSessionAction? action) {
    final documentId = action?.documentId;
    if (detail == null || documentId == null) {
      return null;
    }

    for (final source in detail.sources) {
      if (source.documentId == documentId || source.id == documentId) {
        return source.fileName;
      }
    }

    return null;
  }
}

class _QuickHeader extends StatelessWidget {
  const _QuickHeader({
    required this.courseTitle,
    required this.subjectName,
    required this.sourceName,
  });

  final String courseTitle;
  final String? subjectName;
  final String? sourceName;

  @override
  Widget build(BuildContext context) {
    return RevisionGlassCard(
      gradient: const LinearGradient(
        colors: [RevisionColors.blue, RevisionColors.blueDeep],
      ),
      child: Row(
        children: [
          const RevisionIconTile(
            icon: Icons.flash_on_rounded,
            accent: RevisionColors.cyan,
          ),
          const SizedBox(width: RevisionSpacing.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (subjectName != null)
                  Text(
                    subjectName!,
                    style: RevisionTypography.caption.copyWith(
                      color: RevisionColors.cyan,
                    ),
                  ),
                Text(courseTitle, style: RevisionTypography.pageTitle),
                if (sourceName != null) ...[
                  const SizedBox(height: RevisionSpacing.xs),
                  Text('Source : $sourceName', style: RevisionTypography.body),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuestionProgress extends StatelessWidget {
  const _QuestionProgress({required this.current, required this.total});

  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Question $current sur $total',
          style: RevisionTypography.body.copyWith(color: RevisionColors.text),
        ),
        const SizedBox(height: RevisionSpacing.s),
        RevisionProgressLine(
          value: current / total,
          color: RevisionColors.blue,
        ),
      ],
    );
  }
}

class _AnswerChoiceCard extends StatelessWidget {
  const _AnswerChoiceCard({
    required this.label,
    required this.text,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String text;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return RevisionGlassCard(
      selected: selected,
      onTap: onTap,
      padding: const EdgeInsets.all(RevisionSpacing.m),
      borderColor: selected ? RevisionColors.blue : RevisionColors.border,
      backgroundColor: selected
          ? RevisionColors.blue.withValues(alpha: 0.18)
          : RevisionColors.glassSoft,
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: selected
                ? RevisionColors.blue.withValues(alpha: 0.8)
                : RevisionColors.ink3,
            child: Text(
              label,
              style: RevisionTypography.caption.copyWith(
                color: RevisionColors.text,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: RevisionSpacing.m),
          Expanded(
            child: Text(
              text,
              style: RevisionTypography.body.copyWith(
                color: RevisionColors.text,
              ),
            ),
          ),
          if (selected)
            const Icon(Icons.check_circle_rounded, color: RevisionColors.cyan),
        ],
      ),
    );
  }
}

String _choiceLetter(int index) {
  const letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  if (index < letters.length) {
    return letters[index];
  }

  return '${index + 1}';
}

````

### `lib/presentation/pages/revision_sessions/revision_session_result_page.dart`

````text
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_routes.dart';
import '../../../features/revision_sessions/application/revision_session_controller.dart';
import '../../../features/revision_sessions/data/revision_sessions_api.dart';
import '../../../features/revision_sessions/domain/revision_session.dart';
import '../../design_system/components/revision_mvp_components.dart';
import '../../design_system/components/revision_states.dart';
import '../../design_system/tokens/revision_colors.dart';
import '../../design_system/tokens/revision_spacing.dart';
import '../../design_system/tokens/revision_typography.dart';

class RevisionSessionResultPage extends StatefulWidget {
  const RevisionSessionResultPage({
    required this.sessionId,
    required this.controller,
    super.key,
  });

  final String sessionId;
  final RevisionSessionController controller;

  @override
  State<RevisionSessionResultPage> createState() =>
      _RevisionSessionResultPageState();
}

class _RevisionSessionResultPageState extends State<RevisionSessionResultPage> {
  late Future<RevisionSessionResult> _result;

  @override
  void initState() {
    super.initState();
    _result = _load();
  }

  @override
  void didUpdateWidget(covariant RevisionSessionResultPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.sessionId != widget.sessionId) {
      _result = _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<RevisionSessionResult>(
      future: _result,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const RevisionPageScaffold(
            children: [
              RevisionProcessingState(
                title: 'Chargement du résultat',
                message: 'Le backend prépare le bilan réel de la session.',
              ),
            ],
          );
        }

        final result = snapshot.data;
        if (snapshot.hasError || result == null) {
          return RevisionPageScaffold(
            children: [
              Text('Résultat', style: RevisionTypography.pageTitle),
              RevisionErrorState(
                title: _errorTitle(snapshot.error),
                message: _errorMessage(snapshot.error),
                actionLabel: 'Réessayer',
                onAction: () => setState(() => _result = _load()),
              ),
            ],
          );
        }

        return _ResultContent(result: result);
      },
    );
  }

  Future<RevisionSessionResult> _load() {
    return widget.controller.loadResult(sessionId: widget.sessionId);
  }
}

class _ResultContent extends StatelessWidget {
  const _ResultContent({required this.result});

  final RevisionSessionResult result;

  @override
  Widget build(BuildContext context) {
    final mastered = result.knowledgeUnits
        .where(
          (unit) =>
              unit.state == RevisionSessionKnowledgeUnitResultState.mastered,
        )
        .toList(growable: false);
    final toReview = result.knowledgeUnits
        .where(
          (unit) =>
              unit.state == RevisionSessionKnowledgeUnitResultState.toReview,
        )
        .toList(growable: false);
    final courseId = result.session.courseId;

    return RevisionPageScaffold(
      children: [
        const RevisionConfettiStrip(),
        Text(
          'Session terminée',
          textAlign: TextAlign.center,
          style: RevisionTypography.sectionTitle,
        ),
        RevisionGlassCard(
          child: Column(
            children: [
              RevisionMasteryRing(
                value: result.summary.score,
                label: '${(result.summary.score * 100).round()}%',
                caption: 'global',
                size: 112,
                color: _scoreColor(result.summary.score),
              ),
              const SizedBox(height: RevisionSpacing.m),
              Text(
                _resultMessage(result.summary.score),
                style: RevisionTypography.sectionTitle,
              ),
              const SizedBox(height: RevisionSpacing.xs),
              Text(
                '${result.summary.correctAnswers}/${result.summary.totalQuestions} bonnes réponses',
                style: RevisionTypography.body,
              ),
            ],
          ),
        ),
        if (mastered.isNotEmpty)
          _ResultSection(
            title: 'Tu maîtrises',
            icon: Icons.check_circle_rounded,
            color: RevisionColors.green,
            units: mastered,
          ),
        if (toReview.isNotEmpty)
          _ResultSection(
            title: 'À retravailler',
            icon: Icons.error_rounded,
            color: RevisionColors.amber,
            units: toReview,
          ),
        RevisionGlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Prochaine étape', style: RevisionTypography.sectionTitle),
              const SizedBox(height: RevisionSpacing.m),
              if (courseId != null) ...[
                RevisionGradientButton(
                  label: 'Voir la fiche',
                  icon: Icons.description_rounded,
                  expanded: true,
                  gradient: const LinearGradient(
                    colors: [RevisionColors.glassStrong, RevisionColors.ink3],
                  ),
                  onPressed: () =>
                      context.push(AppRoutes.courseSheet(courseId)),
                ),
                const SizedBox(height: RevisionSpacing.m),
                RevisionGradientButton(
                  label: 'Retour au cours',
                  icon: Icons.arrow_back_rounded,
                  expanded: true,
                  onPressed: () => context.go(AppRoutes.course(courseId)),
                ),
              ] else
                RevisionGradientButton(
                  label: 'Retour aux révisions',
                  icon: Icons.arrow_back_rounded,
                  expanded: true,
                  onPressed: () => context.go(AppRoutes.revisions),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ResultSection extends StatelessWidget {
  const _ResultSection({
    required this.title,
    required this.icon,
    required this.color,
    required this.units,
  });

  final String title;
  final IconData icon;
  final Color color;
  final List<RevisionSessionKnowledgeUnitResult> units;

  @override
  Widget build(BuildContext context) {
    return RevisionGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color),
              const SizedBox(width: RevisionSpacing.s),
              Text(title, style: RevisionTypography.sectionTitle),
            ],
          ),
          const SizedBox(height: RevisionSpacing.m),
          for (final unit in units)
            Padding(
              padding: const EdgeInsets.only(bottom: RevisionSpacing.s),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      unit.title,
                      style: RevisionTypography.body.copyWith(
                        color: RevisionColors.text,
                      ),
                    ),
                  ),
                  Text(
                    '${(unit.score * 100).round()}%',
                    style: RevisionTypography.caption.copyWith(color: color),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

String _resultMessage(double score) {
  if (score >= 0.85) {
    return 'Très belle maîtrise.';
  }
  if (score >= 0.65) {
    return 'Bonne progression.';
  }
  if (score >= 0.40) {
    return 'Les bases prennent forme.';
  }

  return 'Cette notion mérite une nouvelle passe.';
}

Color _scoreColor(double score) {
  if (score >= 0.8) {
    return RevisionColors.green;
  }
  if (score >= 0.4) {
    return RevisionColors.amber;
  }

  return RevisionColors.red;
}

String _errorTitle(Object? error) {
  if (error is RevisionSessionNotFoundException) {
    return 'Session introuvable';
  }
  if (error is RevisionSessionResultNotReadyException) {
    return 'Résultat indisponible';
  }

  return 'Impossible de charger le résultat';
}

String _errorMessage(Object? error) {
  if (error is RevisionSessionResultNotReadyException) {
    return error.message;
  }

  return 'Le résultat sera affiché uniquement depuis un calcul backend réel.';
}

````

### `test/features/revision_sessions/revision_session_result_page_test.dart`

````text
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:revision_app/features/revision_sessions/application/revision_session_controller.dart';
import 'package:revision_app/features/revision_sessions/data/revision_sessions_api.dart';
import 'package:revision_app/presentation/pages/revision_sessions/revision_session_result_page.dart';

import '../../fakes/in_memory_revision_sessions_api.dart';

void main() {
  testWidgets(
    'displays real revision session result without static MVP score',
    (tester) async {
      final api = InMemoryRevisionSessionsApi();

      await tester.pumpWidget(_Harness(api: api));
      await tester.pumpAndSettle();

      expect(api.loadResultCount, 1);
      expect(api.loadedResultSessionId, 'revision-session-1');
      expect(find.text('Session terminée'), findsOneWidget);
      expect(find.text('67%'), findsWidgets);
      expect(find.text('4/6 bonnes réponses'), findsOneWidget);
      expect(find.text('À retravailler'), findsOneWidget);
      expect(find.text('Séparation des pouvoirs'), findsOneWidget);
      expect(find.text('78%'), findsNothing);
      expect(find.text('4/5 bonnes'), findsNothing);
    },
  );

  testWidgets('displays a not-ready error from backend result contract', (
    tester,
  ) async {
    final api = InMemoryRevisionSessionsApi()
      ..loadResultError = const RevisionSessionResultNotReadyException(
        'Revision session not completed',
      );

    await tester.pumpWidget(_Harness(api: api));
    await tester.pumpAndSettle();

    expect(find.text('Résultat indisponible'), findsOneWidget);
    expect(find.text('Revision session not completed'), findsOneWidget);
    expect(find.text('78%'), findsNothing);
  });
}

class _Harness extends StatelessWidget {
  const _Harness({required this.api});

  final InMemoryRevisionSessionsApi api;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: RevisionSessionResultPage(
        sessionId: 'revision-session-1',
        controller: RevisionSessionController(api),
      ),
    );
  }
}

````

### `docs/ui/REVISION_PROJECT_UI_TARGET.md`

````text
# Revision Project UI Target

## Direction

Revision Project vise une interface mobile premium, sombre et centrée sur une matière active. Les références fournies servent de direction visuelle, pas de source de données fictives.

La cible visuelle repose sur :

- fond bleu nuit profond ;
- surfaces glass avec bordures subtiles ;
- gradients bleu, cyan, violet et rose selon le contexte ;
- accent matière stable mais non bloquant ;
- titres forts, sous-titres courts ;
- cartes riches, lisibles et tap targets confortables ;
- bottom navigation flottante et arrondie ;
- aucune gamification inventée tant qu’elle n’existe pas côté produit.

## Matière active

L’accueil reste centré sur une seule matière active. Le sélecteur de matière est une pill en haut de page, avec icône et accent visuel. Les couleurs peuvent s’inspirer du nom réel de la matière, mais ne doivent jamais créer une matière fictive.

Exemples de direction :

- Math ou statistiques : bleu/cyan ;
- Philosophie : rose/violet ;
- Droit : violet ;
- fallback : bleu/cyan.

## Accueil

L’accueil doit ressembler à un vrai hub d’apprentissage :

- sélecteur de matière en haut ;
- titre avec la matière active ;
- sous-titre court ;
- hero card “Reprendre le cours” si un cours réel existe ;
- liste “Tes cours de …” avec cartes de cours réelles ;
- bouton de création de cours ;
- empty states premium mais honnêtes.

Les cartes peuvent afficher :

- titre réel ;
- chapitre réel si disponible ;
- durée estimée réelle si disponible ;
- nombre de sources réelles ;
- nombre de sources prêtes ;
- progression dérivée uniquement de données déjà disponibles sans N+1 massif.

Interdit :

- streak inventé ;
- gems inventés ;
- anneau “7 jours” fictif ;
- score “78%” fictif ;
- cours ou matière de mockup en production.

## Détail cours

Le détail cours doit présenter une hiérarchie proche des références :

- top bar avec retour, fiche et sources ;
- hero cours avec matière, titre et méta ;
- stats strip progression, temps estimé, difficulté ;
- bloc progression réelle ;
- modes de révision distincts.

La révision rapide est le seul mode réellement branché dans le MVP Core. Révision approfondie et préparation examen peuvent être visibles comme modes premium/MVP+, mais doivent rester désactivées tant que le backend n’existe pas.

## Sources

Les sources d’un cours sont accessibles depuis le détail via une bottom sheet premium :

- titre “Sources” ;
- sous-titre cours ;
- liste de PDF réels ;
- statuts visibles ;
- bouton rond `+` pour ajouter une source ;
- action de suppression avec confirmation ;
- refresh manuel.

La page globale Sources peut rester informative tant qu’un catalogue centralisé n’est pas disponible.

## Fiche de cours

La fiche course-level doit être lisible et structurée :

- header simple ;
- tabs `Rapide`, `Complète`, `Examen` ;
- seul `Rapide` affiche le contenu réel actuel ;
- `Complète` et `Examen` restent MVP+ ;
- cartes pour résumé, points clés, pièges fréquents, à connaître, sections et suggestions.

La fiche ne doit jamais inventer un résumé ou une formule si l’API ne la fournit pas.

## Progrès

La page Progrès doit rendre les métriques réelles plus visibles :

- titre fort ;
- description courte ;
- carte principale avec ring de maîtrise globale ;
- métriques de cours prêts / pratiqués ;
- cartes de cours compactes ;
- section “À surveiller” basée uniquement sur les états réels.

Les “points faibles” avancés nécessitent un vrai modèle produit plus tard. En MVP Core, ils peuvent être approximés par les cours non pratiqués, en erreur ou en traitement, mais cette limite doit rester documentée.

## Hub Révisions

Le hub Révisions présente trois modes :

- Révision rapide : active seulement si un cours réel avec source prête existe ;
- Révision approfondie : MVP+ ;
- Préparation examen : MVP+.

Le hub ne doit pas générer de recommandation fictive. Si aucun cours prêt n’existe, il affiche un état/action honnête.

## Navigation

Les onglets racine utilisent une navigation de branche. Les écrans de détail (`/courses/:courseId`, `/courses/:courseId/sheet`) doivent être empilés avec `push` et revenir avec `pop` quand c’est possible, avec fallback `go` uniquement pour les deep links directs.

Objectif : éviter qu’un retour utilisateur recrée une page ou laisse une entrée fantôme dans la stack.

## Session quick et résultat

La révision rapide course-level est le premier flow complet du MVP Core. La cible UI-02 est :

- une question affichée à la fois ;
- une progression claire `Question X sur Y` ;
- aucune correction avant submit ;
- pas d’ID technique visible ;
- abandon contrôlé avec confirmation ;
- résultat réel issu du backend ;
- ring de score basé uniquement sur `ActivityResult`;
- sections `Tu maîtrises` et `À retravailler` basées sur les KnowledgeUnits agrégées ;
- CTA vers la fiche ou le cours réel.

Le passage session -> résultat utilise une navigation de remplacement quand la session est terminée, pour éviter d’empiler un écran de résultat au-dessus d’une session déjà consommée.

## Hors scope UI-01/UI-02

À reporter :

- deep revision réelle ;
- préparation examen réelle ;
- gamification réelle ;
- catalogue global de sources ;
- points faibles avancés.

````

### `lib/app/router/app_router.dart`

````text
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/activities/application/activity_controller.dart';
import '../../features/auth/application/auth_controller.dart';
import '../../features/courses/presentation/course_detail_page.dart';
import '../../features/courses/presentation/course_revision_sheet_page.dart';
import '../../features/courses/presentation/courses_home_page.dart';
import '../../features/courses/presentation/revisions_pending_page.dart';
import '../../features/courses/presentation/subject_progress_page.dart';
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
import '../../presentation/pages/revision_sessions/revision_session_result_page.dart';
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
                builder: (context, state) => const SubjectProgressPage(),
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
                builder: (context, state) => RevisionSessionPage(
                  revisionSessionController: revisionSessionController,
                  activityController: activityController,
                  sessionId: state.pathParameters['sessionId'] ?? '',
                ),
              ),
              GoRoute(
                path: AppRoutes.revisionSessionResultV2Path,
                builder: (context, state) => RevisionSessionResultPage(
                  sessionId: state.pathParameters['sessionId'] ?? '',
                  controller: revisionSessionController,
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

````

### `lib/features/courses/presentation/course_detail_page.dart`

````text
import 'dart:async';

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
    final visual = revisionSubjectVisualThemeFor(
      '${detail.subject.name} ${course.title}',
    );
    final progress = ref.watch(courseProgressProvider(course.id));
    final hasReadySource = detail.sources.any(
      (source) => source.status == CourseDocumentStatus.ready,
    );

    return RevisionPageScaffold(
      children: [
        _CourseTopBar(
          detail: detail,
          visual: visual,
          hasReadySource: hasReadySource,
        ),
        _CourseHero(detail: detail, visual: visual),
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
        message: 'Les métriques réelles ne sont pas disponibles pour ce cours.',
        actionLabel: 'Réessayer',
        onAction: onRetry,
      ),
      data: (progress) => RevisionGlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Progression réelle', style: RevisionTypography.sectionTitle),
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
          trailingLabel: hasReadySource ? null : 'Bientôt',
          enabled: hasReadySource && !isStartingQuickRevision,
          onTap: () => _startQuickRevision(context, ref, detail),
        ),
        const SizedBox(height: RevisionSpacing.m),
        RevisionModeCard(
          title: 'Révision approfondie',
          description: 'Cours complet et exemples détaillés.',
          icon: Icons.menu_book_rounded,
          accent: RevisionColors.violet,
          trailingLabel: 'MVP+',
          enabled: false,
        ),
        const SizedBox(height: RevisionSpacing.m),
        RevisionModeCard(
          title: 'Préparation examen',
          description: 'Entraînements et sujets corrigés.',
          icon: Icons.gps_fixed_rounded,
          accent: RevisionColors.pink,
          trailingLabel: 'MVP+',
          enabled: false,
        ),
        if (quickRevisionState.hasError) ...[
          const SizedBox(height: RevisionSpacing.s),
          Text(
            'Révision rapide indisponible pour ce cours.',
            style: RevisionTypography.caption.copyWith(
              color: RevisionColors.red,
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _startQuickRevision(
    BuildContext context,
    WidgetRef ref,
    CourseDetail detail,
  ) async {
    try {
      final response = await ref
          .read(startCourseQuickRevisionControllerProvider.notifier)
          .start(detail: detail);

      if (!context.mounted) {
        return;
      }

      context.go(
        AppRoutes.revisionSessionV2(
          sessionId: response.session.id,
          courseId: detail.course.id,
          mode: 'quick',
        ),
      );
    } catch (error) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_quickRevisionErrorLabel(error))));
    }
  }
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
            message: 'La source est envoyée au backend.',
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
    return 'Synthèse essentielle depuis une source prête.';
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

String _quickRevisionErrorLabel(Object error) {
  if (error is CourseQuickRevisionUnavailableException) {
    return error.message;
  }

  if (error is CourseNotFoundException) {
    return 'Cours introuvable.';
  }

  return 'Impossible de démarrer la révision rapide.';
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
    CourseProgressState.practiced =>
      'Progression réelle basée sur tes réponses.',
    CourseProgressState.unknown => 'Progression réelle disponible.',
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

````

### `lib/features/revision_sessions/application/revision_session_controller.dart`

````text
import '../data/revision_sessions_api.dart';
import '../domain/revision_session.dart';

class RevisionSessionController {
  const RevisionSessionController(this._api);

  final RevisionSessionsApi _api;

  Future<RevisionSessionResponse> startSession({
    required String subjectId,
    String? documentId,
    String? knowledgeUnitId,
    RevisionSessionPreferredAction? preferredAction,
  }) {
    final trimmedSubjectId = subjectId.trim();
    final trimmedDocumentId = _trimOptionalId(documentId);
    final trimmedKnowledgeUnitId = _trimOptionalId(knowledgeUnitId);

    if (trimmedSubjectId.isEmpty) {
      throw ArgumentError('Subject id is required');
    }

    return _api.startRevisionSession(
      subjectId: trimmedSubjectId,
      documentId: trimmedDocumentId,
      knowledgeUnitId: trimmedKnowledgeUnitId,
      preferredAction: preferredAction,
    );
  }

  Future<RevisionSessionResponse> loadSession({required String sessionId}) {
    final trimmedSessionId = sessionId.trim();

    if (trimmedSessionId.isEmpty) {
      throw ArgumentError('Revision session id is required');
    }

    return _api.getRevisionSession(sessionId: trimmedSessionId);
  }

  Future<RevisionSessionResult> completeSession({required String sessionId}) {
    final trimmedSessionId = sessionId.trim();

    if (trimmedSessionId.isEmpty) {
      throw ArgumentError('Revision session id is required');
    }

    return _api.completeRevisionSession(sessionId: trimmedSessionId);
  }

  Future<RevisionSessionResult> loadResult({required String sessionId}) {
    final trimmedSessionId = sessionId.trim();

    if (trimmedSessionId.isEmpty) {
      throw ArgumentError('Revision session id is required');
    }

    return _api.getRevisionSessionResult(sessionId: trimmedSessionId);
  }

  String? _trimOptionalId(String? value) {
    final trimmed = value?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }
}

````

### `lib/features/revision_sessions/data/http_revision_sessions_api.dart`

````text
import 'package:dio/dio.dart';

import '../../activities/domain/diagnostic_quiz_activity.dart';
import '../../activities/domain/open_question_activity.dart';
import '../domain/revision_session.dart';
import 'revision_sessions_api.dart';

class HttpRevisionSessionsApi implements RevisionSessionsApi {
  HttpRevisionSessionsApi({
    required Dio dio,
    required Future<String> Function() getIdToken,
  }) : this._(dio, getIdToken);

  const HttpRevisionSessionsApi._(this._dio, this._getIdToken);

  final Dio _dio;
  final Future<String> Function() _getIdToken;

  @override
  Future<RevisionSessionResponse> startRevisionSession({
    required String subjectId,
    String? documentId,
    String? knowledgeUnitId,
    RevisionSessionPreferredAction? preferredAction,
  }) async {
    final data = <String, Object?>{'subjectId': subjectId};
    if (documentId != null) {
      data['documentId'] = documentId;
    }
    if (knowledgeUnitId != null) {
      data['knowledgeUnitId'] = knowledgeUnitId;
    }
    if (preferredAction != null) {
      data['preferredAction'] = _preferredActionJson(preferredAction);
    }

    final response = await _dio.post<Object?>(
      '/revision-sessions',
      data: data,
      options: await _authorizedOptions(),
    );

    return RevisionSessionResponseJson(response.data).toResponse();
  }

  @override
  Future<RevisionSessionResponse> getRevisionSession({
    required String sessionId,
  }) async {
    try {
      final response = await _dio.get<Object?>(
        '/revision-sessions/$sessionId',
        options: await _authorizedOptions(),
      );

      return RevisionSessionResponseJson(response.data).toResponse();
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        throw const RevisionSessionNotFoundException(
          'Revision session not found',
        );
      }
      rethrow;
    }
  }

  @override
  Future<RevisionSessionResult> completeRevisionSession({
    required String sessionId,
  }) async {
    try {
      final response = await _dio.post<Object?>(
        '/revision-sessions/$sessionId/complete',
        data: const <String, Object?>{},
        options: await _authorizedOptions(),
      );

      return RevisionSessionResultJson(response.data).toResult();
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        throw const RevisionSessionNotFoundException(
          'Revision session not found',
        );
      }
      if (error.response?.statusCode == 409) {
        throw RevisionSessionResultNotReadyException(
          _responseMessage(error) ?? 'Revision session is not ready',
        );
      }
      rethrow;
    }
  }

  @override
  Future<RevisionSessionResult> getRevisionSessionResult({
    required String sessionId,
  }) async {
    try {
      final response = await _dio.get<Object?>(
        '/revision-sessions/$sessionId/result',
        options: await _authorizedOptions(),
      );

      return RevisionSessionResultJson(response.data).toResult();
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        throw const RevisionSessionNotFoundException(
          'Revision session not found',
        );
      }
      if (error.response?.statusCode == 409) {
        throw RevisionSessionResultNotReadyException(
          _responseMessage(error) ?? 'Revision session result is not ready',
        );
      }
      rethrow;
    }
  }

  Future<Options> _authorizedOptions() async {
    final token = (await _getIdToken()).trim();

    if (token.isEmpty) {
      throw StateError('A Firebase ID token is required for revision sessions');
    }

    return Options(headers: {'Authorization': 'Bearer $token'});
  }

  String _preferredActionJson(RevisionSessionPreferredAction action) {
    return switch (action) {
      RevisionSessionPreferredAction.diagnosticQuiz => 'diagnostic_quiz',
      RevisionSessionPreferredAction.openQuestion => 'open_question',
      RevisionSessionPreferredAction.richClosedExercise =>
        'rich_closed_exercise',
    };
  }
}

String? _responseMessage(DioException error) {
  final data = error.response?.data;
  if (data is Map<String, Object?>) {
    final message = data['message'];
    if (message is String) {
      return message;
    }
  }

  return null;
}

class RevisionSessionResponseJson {
  const RevisionSessionResponseJson(this.value);

  final Object? value;

  RevisionSessionResponse toResponse() {
    final json = value;

    if (json is! Map<String, Object?>) {
      throw const FormatException('Invalid revision session response');
    }

    final session = json['session'];
    final currentAction = json['currentAction'];
    final history = json['history'];

    if (session is! Map<String, Object?> || history is! List) {
      throw const FormatException('Invalid revision session response');
    }

    return RevisionSessionResponse(
      session: _RevisionSessionJson(session).toSession(),
      currentAction: currentAction == null
          ? null
          : _RevisionSessionActionJson(
              currentAction,
              allowPayload: true,
            ).toAction(),
      history: history
          .map(
            (action) => _RevisionSessionActionJson(
              action,
              allowPayload: false,
            ).toAction(),
          )
          .toList(growable: false),
    );
  }
}

class RevisionSessionResultJson {
  const RevisionSessionResultJson(this.value);

  final Object? value;

  RevisionSessionResult toResult() {
    final json = value;

    if (json is! Map<String, Object?>) {
      throw const FormatException('Invalid revision session result response');
    }

    final session = json['session'];
    final summary = json['summary'];
    final knowledgeUnits = json['knowledgeUnits'];

    if (session is! Map<String, Object?> ||
        summary is! Map<String, Object?> ||
        knowledgeUnits is! List) {
      throw const FormatException('Invalid revision session result response');
    }

    return RevisionSessionResult(
      session: _RevisionSessionResultSessionJson(session).toSession(),
      summary: _RevisionSessionResultSummaryJson(summary).toSummary(),
      knowledgeUnits: knowledgeUnits
          .map((unit) => _RevisionSessionKnowledgeUnitJson(unit).toResult())
          .toList(growable: false),
    );
  }
}

class _RevisionSessionResultSessionJson {
  const _RevisionSessionResultSessionJson(this.value);

  final Map<String, Object?> value;

  RevisionSessionResultSession toSession() {
    final id = value['id'];
    final subjectId = value['subjectId'];
    final courseId = value['courseId'];
    final mode = value['mode'];
    final status = value['status'];
    final createdAt = value['createdAt'];
    final completedAt = value['completedAt'];

    if (id is! String ||
        subjectId is! String ||
        mode is! String ||
        status is! String ||
        createdAt is! String ||
        completedAt is! String) {
      throw const FormatException('Invalid revision session result response');
    }

    return RevisionSessionResultSession(
      id: id,
      subjectId: subjectId,
      courseId: courseId is String ? courseId : null,
      mode: _revisionSessionMode(mode),
      status: _revisionSessionStatus(status),
      createdAt: DateTime.parse(createdAt),
      completedAt: DateTime.parse(completedAt),
    );
  }
}

class _RevisionSessionResultSummaryJson {
  const _RevisionSessionResultSummaryJson(this.value);

  final Map<String, Object?> value;

  RevisionSessionResultSummary toSummary() {
    final correctAnswers = value['correctAnswers'];
    final totalQuestions = value['totalQuestions'];
    final score = value['score'];
    final durationSeconds = value['durationSeconds'];

    if (correctAnswers is! int ||
        totalQuestions is! int ||
        score is! num ||
        durationSeconds is! int) {
      throw const FormatException('Invalid revision session result response');
    }

    return RevisionSessionResultSummary(
      correctAnswers: correctAnswers,
      totalQuestions: totalQuestions,
      score: score.toDouble(),
      durationSeconds: durationSeconds,
    );
  }
}

class _RevisionSessionKnowledgeUnitJson {
  const _RevisionSessionKnowledgeUnitJson(this.value);

  final Object? value;

  RevisionSessionKnowledgeUnitResult toResult() {
    final json = value;

    if (json is! Map<String, Object?>) {
      throw const FormatException('Invalid revision session result response');
    }

    final knowledgeUnitId = json['knowledgeUnitId'];
    final title = json['title'];
    final correctAnswers = json['correctAnswers'];
    final totalQuestions = json['totalQuestions'];
    final score = json['score'];
    final state = json['state'];

    if (knowledgeUnitId is! String ||
        title is! String ||
        correctAnswers is! int ||
        totalQuestions is! int ||
        score is! num ||
        state is! String) {
      throw const FormatException('Invalid revision session result response');
    }

    return RevisionSessionKnowledgeUnitResult(
      knowledgeUnitId: knowledgeUnitId,
      title: title,
      correctAnswers: correctAnswers,
      totalQuestions: totalQuestions,
      score: score.toDouble(),
      state: _knowledgeUnitResultState(state),
    );
  }
}

RevisionSessionStatus _revisionSessionStatus(String status) {
  return switch (status) {
    'STARTED' => RevisionSessionStatus.started,
    'COMPLETED' => RevisionSessionStatus.completed,
    'ABANDONED' => RevisionSessionStatus.abandoned,
    _ => RevisionSessionStatus.unknown,
  };
}

RevisionSessionMode _revisionSessionMode(String mode) {
  return switch (mode) {
    'QUICK' => RevisionSessionMode.quick,
    'DEEP' => RevisionSessionMode.deep,
    'EXAM' => RevisionSessionMode.exam,
    _ => RevisionSessionMode.unknown,
  };
}

RevisionSessionKnowledgeUnitResultState _knowledgeUnitResultState(
  String state,
) {
  return switch (state) {
    'MASTERED' => RevisionSessionKnowledgeUnitResultState.mastered,
    'TO_REVIEW' => RevisionSessionKnowledgeUnitResultState.toReview,
    _ => RevisionSessionKnowledgeUnitResultState.unknown,
  };
}

class _RevisionSessionJson {
  const _RevisionSessionJson(this.value);

  final Map<String, Object?> value;

  RevisionSession toSession() {
    final id = value['id'];
    final status = value['status'];
    final mode = value['mode'];
    final subjectId = value['subjectId'];
    final courseId = value['courseId'];
    final documentId = value['documentId'];
    final knowledgeUnitId = value['knowledgeUnitId'];
    final createdAt = value['createdAt'];
    final completedAt = value['completedAt'];

    if (id is! String ||
        status is! String ||
        mode is! String ||
        subjectId is! String ||
        createdAt is! String) {
      throw const FormatException('Invalid revision session response');
    }

    return RevisionSession(
      id: id,
      status: _sessionStatus(status),
      mode: _sessionMode(mode),
      subjectId: subjectId,
      courseId: courseId is String ? courseId : null,
      documentId: documentId is String ? documentId : null,
      knowledgeUnitId: knowledgeUnitId is String ? knowledgeUnitId : null,
      createdAt: DateTime.parse(createdAt),
      completedAt: completedAt is String ? DateTime.parse(completedAt) : null,
    );
  }

  RevisionSessionStatus _sessionStatus(String status) {
    return switch (status) {
      'STARTED' => RevisionSessionStatus.started,
      'COMPLETED' => RevisionSessionStatus.completed,
      'ABANDONED' => RevisionSessionStatus.abandoned,
      _ => RevisionSessionStatus.unknown,
    };
  }

  RevisionSessionMode _sessionMode(String mode) {
    return switch (mode) {
      'QUICK' => RevisionSessionMode.quick,
      'DEEP' => RevisionSessionMode.deep,
      'EXAM' => RevisionSessionMode.exam,
      _ => RevisionSessionMode.unknown,
    };
  }
}

class _RevisionSessionActionJson {
  const _RevisionSessionActionJson(this.value, {required this.allowPayload});

  final Object? value;
  final bool allowPayload;

  RevisionSessionAction toAction() {
    final json = value;

    if (json is! Map<String, Object?>) {
      throw const FormatException('Invalid revision session action response');
    }

    final id = json['id'];
    final kind = json['kind'];
    final status = json['status'];
    final displayOrder = json['displayOrder'];
    final activitySessionId = json['activitySessionId'];
    final documentId = json['documentId'];
    final knowledgeUnitId = json['knowledgeUnitId'];

    if (id is! String ||
        kind is! String ||
        status is! String ||
        displayOrder is! int) {
      throw const FormatException('Invalid revision session action response');
    }

    return RevisionSessionAction(
      id: id,
      kind: _actionKind(kind),
      status: _actionStatus(status),
      displayOrder: displayOrder,
      activitySessionId: activitySessionId is String ? activitySessionId : null,
      documentId: documentId is String ? documentId : null,
      knowledgeUnitId: knowledgeUnitId is String ? knowledgeUnitId : null,
      payload: allowPayload
          ? _ActionPayloadJson(json['payload']).toPayload()
          : null,
    );
  }

  RevisionSessionActionKind _actionKind(String kind) {
    return switch (kind) {
      'DIAGNOSTIC_QUIZ' => RevisionSessionActionKind.diagnosticQuiz,
      'OPEN_QUESTION' => RevisionSessionActionKind.openQuestion,
      'RICH_CLOSED_EXERCISE' => RevisionSessionActionKind.richClosedExercise,
      _ => RevisionSessionActionKind.unknown,
    };
  }

  RevisionSessionActionStatus _actionStatus(String status) {
    return switch (status) {
      'READY' => RevisionSessionActionStatus.ready,
      'COMPLETED' => RevisionSessionActionStatus.completed,
      'FAILED' => RevisionSessionActionStatus.failed,
      _ => RevisionSessionActionStatus.unknown,
    };
  }
}

class _ActionPayloadJson {
  const _ActionPayloadJson(this.value);

  final Object? value;

  RevisionSessionActionPayload? toPayload() {
    final json = value;
    if (json == null) {
      return null;
    }

    if (json is! Map<String, Object?>) {
      return const RevisionSessionUnknownPayload();
    }

    final type = json['type'];
    if (type == 'diagnostic_quiz') {
      return _diagnosticQuizPayload(json);
    }
    if (type == 'open_question') {
      return _openQuestionPayload(json);
    }
    if (type == 'rich_closed_exercise') {
      return _richClosedExercisePayload(json);
    }

    return const RevisionSessionUnknownPayload();
  }

  RevisionSessionActionPayload _diagnosticQuizPayload(
    Map<String, Object?> json,
  ) {
    if (json['questions'] is List && json['title'] is String) {
      try {
        return RevisionSessionDiagnosticQuizPayload(
          _DiagnosticQuizActivityJson(json).toActivity(),
        );
      } on FormatException {
        return const RevisionSessionUnknownPayload();
      }
    }

    return RevisionSessionMinimalPayload(
      type: 'diagnostic_quiz',
      sessionId: json['sessionId'] is String
          ? json['sessionId'] as String
          : null,
    );
  }

  RevisionSessionActionPayload _openQuestionPayload(Map<String, Object?> json) {
    if (json['question'] is Map<String, Object?>) {
      try {
        return RevisionSessionOpenQuestionPayload(
          _OpenQuestionActivityJson(json).toActivity(),
        );
      } on FormatException {
        return const RevisionSessionUnknownPayload();
      }
    }

    return RevisionSessionMinimalPayload(
      type: 'open_question',
      sessionId: json['sessionId'] is String
          ? json['sessionId'] as String
          : null,
    );
  }

  RevisionSessionActionPayload _richClosedExercisePayload(
    Map<String, Object?> json,
  ) {
    if (_containsRichClosedExerciseContent(json)) {
      return const RevisionSessionUnknownPayload();
    }

    final subjectId = json['subjectId'];
    final documentId = json['documentId'];
    final knowledgeUnitId = json['knowledgeUnitId'];
    final knowledgeUnitTitle = json['knowledgeUnitTitle'];
    final reason = json['reason'];
    final estimatedMinutes = json['estimatedMinutes'];
    final preferredAction = json['preferredAction'];

    if (subjectId is! String || knowledgeUnitId is! String) {
      return const RevisionSessionUnknownPayload();
    }

    return RevisionSessionRichClosedExercisePayload(
      subjectId: subjectId,
      documentId: documentId is String ? documentId : null,
      knowledgeUnitId: knowledgeUnitId,
      knowledgeUnitTitle: knowledgeUnitTitle is String
          ? knowledgeUnitTitle
          : null,
      reason: reason is String ? reason : 'Questions riches recommandées.',
      estimatedMinutes: estimatedMinutes is int ? estimatedMinutes : 8,
      preferredAction: preferredAction is String ? preferredAction : null,
    );
  }

  bool _containsRichClosedExerciseContent(Map<String, Object?> json) {
    return json.containsKey('questions') ||
        json.containsKey('answers') ||
        json.containsKey('correction') ||
        json.containsKey('correctAnswers') ||
        json.containsKey('score');
  }
}

class _DiagnosticQuizActivityJson {
  const _DiagnosticQuizActivityJson(this.value);

  final Map<String, Object?> value;

  DiagnosticQuizActivity toActivity() {
    final sessionId = value['sessionId'];
    final type = value['type'];
    final version = value['version'];
    final title = value['title'];
    final documentId = value['documentId'];
    final subjectId = value['subjectId'];
    final questions = value['questions'];

    if (sessionId is! String || title is! String || questions is! List) {
      throw const FormatException('Invalid revision quiz payload');
    }

    return DiagnosticQuizActivity(
      sessionId: sessionId,
      type: type is String ? type : 'diagnostic_quiz',
      version: version is int ? version : null,
      title: title,
      documentId: documentId is String ? documentId : null,
      subjectId: subjectId is String ? subjectId : null,
      questions: questions
          .map((question) => _DiagnosticQuizQuestionJson(question).toQuestion())
          .toList(growable: false),
    );
  }
}

class _DiagnosticQuizQuestionJson {
  const _DiagnosticQuizQuestionJson(this.value);

  final Object? value;

  DiagnosticQuizQuestion toQuestion() {
    final json = value;

    if (json is! Map<String, Object?>) {
      throw const FormatException('Invalid revision quiz payload');
    }

    final id = json['id'];
    final knowledgeUnitId = json['knowledgeUnitId'];
    final prompt = json['prompt'];
    final difficulty = json['difficulty'];
    final choices = json['choices'];
    final sources = json['sources'];
    final visuals = json['visuals'];

    if (id is! String || prompt is! String || choices is! List) {
      throw const FormatException('Invalid revision quiz payload');
    }

    final parsedChoices = choices
        .map((choice) => _DiagnosticQuizChoiceJson(choice).toChoice())
        .toList(growable: false);
    final selectionMode = _selectionMode(json['selectionMode']);
    final minSelections = _selectionCount(json['minSelections'], fallback: 1);
    final maxSelections = _selectionCount(
      json['maxSelections'],
      fallback: selectionMode == DiagnosticQuizSelectionMode.multiple
          ? parsedChoices.length
          : 1,
    );

    if (selectionMode == DiagnosticQuizSelectionMode.multiple &&
        (minSelections < 1 ||
            maxSelections < minSelections ||
            maxSelections > parsedChoices.length)) {
      throw const FormatException('Invalid revision quiz payload');
    }

    final parsedVisuals = <DiagnosticQuizVisual>[];
    if (visuals is List) {
      parsedVisuals.addAll([
        for (final (index, visual) in visuals.indexed)
          _DiagnosticQuizVisualJson(visual, index).toVisual(),
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
                .map(
                  (source) =>
                      _DiagnosticQuizSourceRefJson(source).toSourceRef(),
                )
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

    throw const FormatException('Invalid revision quiz payload');
  }

  int _selectionCount(Object? value, {required int fallback}) {
    if (value == null) {
      return fallback;
    }

    if (value is int) {
      return value;
    }

    throw const FormatException('Invalid revision quiz payload');
  }
}

class _DiagnosticQuizChoiceJson {
  const _DiagnosticQuizChoiceJson(this.value);

  final Object? value;

  DiagnosticQuizChoice toChoice() {
    final json = value;

    if (json is! Map<String, Object?>) {
      throw const FormatException('Invalid revision quiz payload');
    }

    final id = json['id'];
    final label = json['label'];

    if (id is! String || label is! String) {
      throw const FormatException('Invalid revision quiz payload');
    }

    return DiagnosticQuizChoice(id: id, label: label);
  }
}

class _DiagnosticQuizVisualJson {
  const _DiagnosticQuizVisualJson(this.value, this.fallbackIndex);

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

    throw const FormatException('Invalid revision quiz payload');
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

    throw const FormatException('Invalid revision quiz payload');
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
      _ => throw const FormatException('Invalid revision quiz payload'),
    };
  }

  Map<String, Object?> _chartRow(Object? value) {
    final json = value;
    if (json is! Map<String, Object?>) {
      throw const FormatException('Invalid revision quiz payload');
    }

    return json.map((key, value) {
      if (value == null || value is String || value is num) {
        return MapEntry(key, value);
      }

      throw const FormatException('Invalid revision quiz payload');
    });
  }

  DiagnosticQuizDiagramNode _diagramNode(Object? value) {
    final json = value;
    if (json is! Map<String, Object?>) {
      throw const FormatException('Invalid revision quiz payload');
    }

    final id = json['id'];
    final label = json['label'];
    if (id is! String || label is! String) {
      throw const FormatException('Invalid revision quiz payload');
    }

    return DiagnosticQuizDiagramNode(id: id, label: label);
  }

  DiagnosticQuizDiagramEdge _diagramEdge(Object? value) {
    final json = value;
    if (json is! Map<String, Object?>) {
      throw const FormatException('Invalid revision quiz payload');
    }

    final from = json['from'];
    final to = json['to'];
    final label = json['label'];
    if (from is! String || to is! String) {
      throw const FormatException('Invalid revision quiz payload');
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

          throw const FormatException('Invalid revision quiz payload');
        })
        .toList(growable: false);
  }

  List<DiagnosticQuizSourceRef> _sourceRefs(List<Object?> values) {
    return values
        .map((source) => _DiagnosticQuizSourceRefJson(source).toSourceRef())
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

class _DiagnosticQuizSourceRefJson {
  const _DiagnosticQuizSourceRefJson(this.value);

  final Object? value;

  DiagnosticQuizSourceRef toSourceRef() {
    final json = value;

    if (json is! Map<String, Object?>) {
      throw const FormatException('Invalid revision quiz source payload');
    }

    final chunkId = json['chunkId'];
    final pageNumber = json['pageNumber'];
    final index = json['index'];

    if (chunkId is! String || index is! int) {
      throw const FormatException('Invalid revision quiz source payload');
    }

    return DiagnosticQuizSourceRef(
      chunkId: chunkId,
      pageNumber: pageNumber is int ? pageNumber : null,
      index: index,
    );
  }
}

class _OpenQuestionActivityJson {
  const _OpenQuestionActivityJson(this.value);

  final Map<String, Object?> value;

  OpenQuestionActivity toActivity() {
    final sessionId = value['sessionId'];
    final type = value['type'];
    final version = value['version'];
    final subjectId = value['subjectId'];
    final documentId = value['documentId'];
    final knowledgeUnitId = value['knowledgeUnitId'];
    final question = value['question'];

    if (sessionId is! String ||
        type != 'open_question' ||
        subjectId is! String ||
        knowledgeUnitId is! String ||
        question is! Map<String, Object?>) {
      throw const FormatException('Invalid revision open question payload');
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
      throw const FormatException('Invalid revision open question payload');
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
      throw const FormatException(
        'Invalid revision open question source payload',
      );
    }

    final chunkId = json['chunkId'];
    final pageNumber = json['pageNumber'];
    final index = json['index'];

    if (chunkId is! String || index is! int) {
      throw const FormatException(
        'Invalid revision open question source payload',
      );
    }

    return OpenQuestionSource(
      chunkId: chunkId,
      pageNumber: pageNumber is int ? pageNumber : null,
      index: index,
    );
  }
}

````

### `lib/features/revision_sessions/data/revision_sessions_api.dart`

````text
import '../domain/revision_session.dart';

enum RevisionSessionPreferredAction {
  diagnosticQuiz,
  openQuestion,
  richClosedExercise,
}

abstract interface class RevisionSessionsApi {
  Future<RevisionSessionResponse> startRevisionSession({
    required String subjectId,
    String? documentId,
    String? knowledgeUnitId,
    RevisionSessionPreferredAction? preferredAction,
  });

  Future<RevisionSessionResponse> getRevisionSession({
    required String sessionId,
  });

  Future<RevisionSessionResult> completeRevisionSession({
    required String sessionId,
  });

  Future<RevisionSessionResult> getRevisionSessionResult({
    required String sessionId,
  });
}

class RevisionSessionNotFoundException implements Exception {
  const RevisionSessionNotFoundException(this.message);

  final String message;

  @override
  String toString() => message;
}

class RevisionSessionResultNotReadyException implements Exception {
  const RevisionSessionResultNotReadyException(this.message);

  final String message;

  @override
  String toString() => message;
}

````

### `lib/features/revision_sessions/domain/revision_session.dart`

````text
import '../../activities/domain/diagnostic_quiz_activity.dart';
import '../../activities/domain/open_question_activity.dart';

class RevisionSession {
  const RevisionSession({
    required this.id,
    required this.status,
    required this.mode,
    required this.subjectId,
    required this.courseId,
    required this.documentId,
    required this.knowledgeUnitId,
    required this.createdAt,
    required this.completedAt,
  });

  final String id;
  final RevisionSessionStatus status;
  final RevisionSessionMode mode;
  final String subjectId;
  final String? courseId;
  final String? documentId;
  final String? knowledgeUnitId;
  final DateTime createdAt;
  final DateTime? completedAt;
}

enum RevisionSessionStatus { started, completed, abandoned, unknown }

enum RevisionSessionMode { quick, deep, exam, unknown }

class RevisionSessionAction {
  const RevisionSessionAction({
    required this.id,
    required this.kind,
    required this.status,
    required this.displayOrder,
    required this.activitySessionId,
    required this.documentId,
    required this.knowledgeUnitId,
    required this.payload,
  });

  final String id;
  final RevisionSessionActionKind kind;
  final RevisionSessionActionStatus status;
  final int displayOrder;
  final String? activitySessionId;
  final String? documentId;
  final String? knowledgeUnitId;
  final RevisionSessionActionPayload? payload;
}

enum RevisionSessionActionKind {
  diagnosticQuiz,
  openQuestion,
  richClosedExercise,
  unknown,
}

enum RevisionSessionActionStatus { ready, completed, failed, unknown }

class RevisionSessionResponse {
  const RevisionSessionResponse({
    required this.session,
    required this.currentAction,
    required this.history,
  });

  final RevisionSession session;
  final RevisionSessionAction? currentAction;
  final List<RevisionSessionAction> history;
}

sealed class RevisionSessionActionPayload {
  const RevisionSessionActionPayload();
}

class RevisionSessionDiagnosticQuizPayload
    extends RevisionSessionActionPayload {
  const RevisionSessionDiagnosticQuizPayload(this.activity);

  final DiagnosticQuizActivity activity;
}

class RevisionSessionOpenQuestionPayload extends RevisionSessionActionPayload {
  const RevisionSessionOpenQuestionPayload(this.activity);

  final OpenQuestionActivity activity;
}

class RevisionSessionRichClosedExercisePayload
    extends RevisionSessionActionPayload {
  const RevisionSessionRichClosedExercisePayload({
    required this.subjectId,
    required this.knowledgeUnitId,
    required this.reason,
    required this.estimatedMinutes,
    this.documentId,
    this.knowledgeUnitTitle,
    this.preferredAction,
  });

  final String subjectId;
  final String? documentId;
  final String knowledgeUnitId;
  final String? knowledgeUnitTitle;
  final String reason;
  final int estimatedMinutes;
  final String? preferredAction;
}

class RevisionSessionMinimalPayload extends RevisionSessionActionPayload {
  const RevisionSessionMinimalPayload({required this.type, this.sessionId});

  final String type;
  final String? sessionId;
}

class RevisionSessionUnknownPayload extends RevisionSessionActionPayload {
  const RevisionSessionUnknownPayload();
}

class RevisionSessionResult {
  const RevisionSessionResult({
    required this.session,
    required this.summary,
    required this.knowledgeUnits,
  });

  final RevisionSessionResultSession session;
  final RevisionSessionResultSummary summary;
  final List<RevisionSessionKnowledgeUnitResult> knowledgeUnits;
}

class RevisionSessionResultSession {
  const RevisionSessionResultSession({
    required this.id,
    required this.subjectId,
    required this.mode,
    required this.status,
    required this.createdAt,
    required this.completedAt,
    this.courseId,
  });

  final String id;
  final String subjectId;
  final String? courseId;
  final RevisionSessionMode mode;
  final RevisionSessionStatus status;
  final DateTime createdAt;
  final DateTime completedAt;
}

class RevisionSessionResultSummary {
  const RevisionSessionResultSummary({
    required this.correctAnswers,
    required this.totalQuestions,
    required this.score,
    required this.durationSeconds,
  });

  final int correctAnswers;
  final int totalQuestions;
  final double score;
  final int durationSeconds;
}

class RevisionSessionKnowledgeUnitResult {
  const RevisionSessionKnowledgeUnitResult({
    required this.knowledgeUnitId,
    required this.title,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.score,
    required this.state,
  });

  final String knowledgeUnitId;
  final String title;
  final int correctAnswers;
  final int totalQuestions;
  final double score;
  final RevisionSessionKnowledgeUnitResultState state;
}

enum RevisionSessionKnowledgeUnitResultState { mastered, toReview, unknown }

````

### `lib/presentation/pages/revision_sessions/revision_session_page.dart`

````text
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:revision_app/features/activities/application/activity_controller.dart';
import 'package:revision_app/features/activities/domain/diagnostic_quiz_activity.dart';
import 'package:revision_app/features/revision_sessions/application/revision_session_controller.dart';
import 'package:revision_app/features/revision_sessions/data/revision_sessions_api.dart';
import 'package:revision_app/features/revision_sessions/domain/revision_session.dart';
import 'package:revision_app/features/revision_sessions/presentation/quick_revision_quiz_flow.dart';
import 'package:revision_app/core/routing/route_paths.dart';
import 'package:revision_app/presentation/pages/activities/diagnostic_quiz_page.dart';
import 'package:revision_app/presentation/pages/activities/open_question_page.dart';
import 'package:revision_app/presentation/theme/app_spacing.dart';
import 'package:revision_app/presentation/widgets/revision_button.dart';
import 'package:revision_app/presentation/widgets/revision_message.dart';
import 'package:revision_app/presentation/widgets/revision_page.dart';
import 'package:revision_app/presentation/widgets/revision_panel.dart';
import 'package:revision_app/presentation/widgets/revision_status_pill.dart';

class RevisionSessionPage extends StatefulWidget {
  const RevisionSessionPage({
    required this.revisionSessionController,
    required this.activityController,
    this.sessionId,
    this.subjectId,
    this.documentId,
    this.knowledgeUnitId,
    this.preferredAction,
    super.key,
  });

  final RevisionSessionController revisionSessionController;
  final ActivityController activityController;
  final String? sessionId;
  final String? subjectId;
  final String? documentId;
  final String? knowledgeUnitId;
  final RevisionSessionPreferredAction? preferredAction;

  @override
  State<RevisionSessionPage> createState() => _RevisionSessionPageState();
}

class _RevisionSessionPageState extends State<RevisionSessionPage> {
  Future<RevisionSessionResponse>? _session;

  @override
  void initState() {
    super.initState();
    _session = _loadFromParams();
  }

  @override
  void didUpdateWidget(covariant RevisionSessionPage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (_normalizeId(oldWidget.sessionId) != _trimmedSessionId ||
        _normalizeId(oldWidget.subjectId) != _trimmedSubjectId ||
        _normalizeId(oldWidget.documentId) != _trimmedDocumentId ||
        _normalizeId(oldWidget.knowledgeUnitId) != _trimmedKnowledgeUnitId ||
        oldWidget.preferredAction != widget.preferredAction) {
      setState(() {
        _session = _loadFromParams();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = _session;

    if (session == null) {
      return const RevisionPage(
        title: 'Révision IA',
        subtitle: 'Une session contrôlée à partir de tes activités existantes.',
        children: [_EmptyRevisionSessionState()],
      );
    }

    return FutureBuilder<RevisionSessionResponse>(
      future: session,
      builder: (context, snapshot) {
        final response = snapshot.data;

        if (snapshot.connectionState != ConnectionState.done) {
          return const RevisionPage(
            title: 'Révision rapide',
            subtitle: 'Préparation de ta session.',
            children: [Center(child: CircularProgressIndicator())],
          );
        }

        if (snapshot.hasError || response == null) {
          return RevisionPage(
            title: 'Révision IA',
            subtitle:
                'Une session contrôlée à partir de tes activités existantes.',
            children: [_RevisionSessionErrorState(onRetry: _retry)],
          );
        }

        final premiumActivity = _premiumQuickActivity(response);
        if (premiumActivity != null) {
          return QuickRevisionQuizFlow(
            response: response,
            activity: premiumActivity,
            activityController: widget.activityController,
            revisionSessionController: widget.revisionSessionController,
          );
        }

        return RevisionPage(
          title: 'Révision IA',
          subtitle:
              'Une session contrôlée à partir de tes activités existantes.',
          children: [
            _RevisionSessionContent(
              response: response,
              activityController: widget.activityController,
            ),
          ],
        );
      },
    );
  }

  String? get _trimmedSessionId => _normalizeId(widget.sessionId);
  String? get _trimmedSubjectId => _normalizeId(widget.subjectId);
  String? get _trimmedDocumentId => _normalizeId(widget.documentId);
  String? get _trimmedKnowledgeUnitId => _normalizeId(widget.knowledgeUnitId);

  Future<RevisionSessionResponse>? _loadFromParams() {
    final sessionId = _trimmedSessionId;
    if (sessionId != null) {
      return widget.revisionSessionController.loadSession(sessionId: sessionId);
    }

    final subjectId = _trimmedSubjectId;
    if (subjectId == null) {
      return null;
    }

    return widget.revisionSessionController.startSession(
      subjectId: subjectId,
      documentId: _trimmedDocumentId,
      knowledgeUnitId: _trimmedKnowledgeUnitId,
      preferredAction: widget.preferredAction,
    );
  }

  String? _normalizeId(String? value) {
    final trimmedValue = value?.trim();
    return trimmedValue == null || trimmedValue.isEmpty ? null : trimmedValue;
  }

  void _retry() {
    setState(() {
      _session = _loadFromParams();
    });
  }
}

DiagnosticQuizActivity? _premiumQuickActivity(
  RevisionSessionResponse response,
) {
  final action = response.currentAction;
  final payload = action?.payload;
  if (response.session.mode != RevisionSessionMode.quick ||
      response.session.courseId == null ||
      action?.kind != RevisionSessionActionKind.diagnosticQuiz ||
      payload is! RevisionSessionDiagnosticQuizPayload) {
    return null;
  }

  if (payload.activity.questions.isEmpty) {
    return null;
  }

  return payload.activity;
}

class _EmptyRevisionSessionState extends StatelessWidget {
  const _EmptyRevisionSessionState();

  @override
  Widget build(BuildContext context) {
    return RevisionMessage(
      message: 'Choisis une matière pour lancer une session de révision IA.',
      color: Theme.of(context).colorScheme.secondary,
      icon: Icons.info_outline,
    );
  }
}

class _RevisionSessionErrorState extends StatelessWidget {
  const _RevisionSessionErrorState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RevisionMessage(
          message: 'Impossible de charger la session de révision.',
          color: Theme.of(context).colorScheme.error,
          icon: Icons.error_outline,
        ),
        const SizedBox(height: AppSpacing.m),
        RevisionButton(
          label: 'Réessayer',
          icon: Icons.refresh,
          onPressed: onRetry,
          style: RevisionButtonStyle.ghost,
        ),
      ],
    );
  }
}

class _RevisionSessionContent extends StatelessWidget {
  const _RevisionSessionContent({
    required this.response,
    required this.activityController,
  });

  final RevisionSessionResponse response;
  final ActivityController activityController;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SessionSummaryPanel(session: response.session),
        const SizedBox(height: AppSpacing.l),
        _CurrentActionPanel(action: response.currentAction),
        const SizedBox(height: AppSpacing.l),
        _CurrentActionRenderer(
          action: response.currentAction,
          activityController: activityController,
        ),
        const SizedBox(height: AppSpacing.l),
        _HistoryPanel(actions: response.history),
      ],
    );
  }
}

class _SessionSummaryPanel extends StatelessWidget {
  const _SessionSummaryPanel({required this.session});

  final RevisionSession session;

  @override
  Widget build(BuildContext context) {
    return RevisionPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Session', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.s),
          Wrap(
            spacing: AppSpacing.s,
            runSpacing: AppSpacing.s,
            children: [
              RevisionStatusPill(
                label: _sessionStatusLabel(session.status),
                color: Theme.of(context).colorScheme.primary,
                icon: Icons.play_circle_outline,
              ),
              RevisionStatusPill(
                label: 'Matière ${session.subjectId}',
                color: Theme.of(context).colorScheme.secondary,
                icon: Icons.menu_book_outlined,
              ),
              if (session.documentId != null)
                RevisionStatusPill(
                  label: 'Document ${session.documentId}',
                  color: Theme.of(context).colorScheme.secondary,
                  icon: Icons.description_outlined,
                ),
              if (session.knowledgeUnitId != null)
                RevisionStatusPill(
                  label: 'Notion ${session.knowledgeUnitId}',
                  color: Theme.of(context).colorScheme.tertiary,
                  icon: Icons.psychology_outlined,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CurrentActionPanel extends StatelessWidget {
  const _CurrentActionPanel({required this.action});

  final RevisionSessionAction? action;

  @override
  Widget build(BuildContext context) {
    final action = this.action;

    if (action == null) {
      return const RevisionMessage(
        message: 'Aucune action courante dans cette session.',
        color: Colors.teal,
        icon: Icons.info_outline,
      );
    }

    return RevisionPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Action courante',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.s),
          Wrap(
            spacing: AppSpacing.s,
            runSpacing: AppSpacing.s,
            children: [
              RevisionStatusPill(
                label: _actionKindLabel(action.kind),
                color: Theme.of(context).colorScheme.primary,
                icon: _actionKindIcon(action.kind),
              ),
              RevisionStatusPill(
                label: _actionStatusLabel(action.status),
                color: Theme.of(context).colorScheme.secondary,
                icon: Icons.check_circle_outline,
              ),
              RevisionStatusPill(
                label: 'Ordre ${action.displayOrder + 1}',
                color: Theme.of(context).colorScheme.tertiary,
                icon: Icons.format_list_numbered,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CurrentActionRenderer extends StatelessWidget {
  const _CurrentActionRenderer({
    required this.action,
    required this.activityController,
  });

  final RevisionSessionAction? action;
  final ActivityController activityController;

  @override
  Widget build(BuildContext context) {
    final action = this.action;
    final payload = action?.payload;

    if (action == null || payload == null) {
      return const _MinimalPayloadFallback();
    }

    return switch (payload) {
      RevisionSessionDiagnosticQuizPayload(:final activity) => SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.68,
        child: DiagnosticQuizPage(
          activity: activity,
          onSubmit: (answers) {
            return activityController.submitResult(
              sessionId: activity.sessionId,
              answers: answers,
            );
          },
        ),
      ),
      RevisionSessionOpenQuestionPayload(:final activity) => SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.68,
        child: OpenQuestionPage(
          activity: activity,
          onSubmit: (answerText) {
            return activityController.submitOpenAnswer(
              sessionId: activity.sessionId,
              answerText: answerText,
            );
          },
        ),
      ),
      RevisionSessionRichClosedExercisePayload() => _RichClosedLauncher(
        payload: payload,
      ),
      RevisionSessionMinimalPayload(:final type, :final sessionId) =>
        _MinimalPayloadFallback(type: type, sessionId: sessionId),
      RevisionSessionUnknownPayload() => const _UnknownPayloadFallback(),
    };
  }
}

class _RichClosedLauncher extends StatelessWidget {
  const _RichClosedLauncher({required this.payload});

  final RevisionSessionRichClosedExercisePayload payload;

  @override
  Widget build(BuildContext context) {
    return RevisionPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Questions riches',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.s),
          Text(_contextLabel),
          const SizedBox(height: AppSpacing.s),
          Text(payload.reason),
          const SizedBox(height: AppSpacing.s),
          RevisionStatusPill(
            label: '${payload.estimatedMinutes} min',
            color: Theme.of(context).colorScheme.tertiary,
            icon: Icons.timer_outlined,
          ),
          const SizedBox(height: AppSpacing.m),
          RevisionButton(
            label: 'Commencer',
            icon: Icons.play_arrow,
            onPressed: () {
              context.go(
                richClosedExerciseRoutePathFor(
                  subjectId: payload.subjectId,
                  documentId: payload.documentId,
                  knowledgeUnitId: payload.knowledgeUnitId,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  String get _contextLabel {
    final title = payload.knowledgeUnitTitle?.trim();
    if (title != null && title.isNotEmpty) {
      return 'Notion: $title';
    }

    return 'Notion ${payload.knowledgeUnitId}';
  }
}

class _MinimalPayloadFallback extends StatelessWidget {
  const _MinimalPayloadFallback({this.type, this.sessionId});

  final String? type;
  final String? sessionId;

  @override
  Widget build(BuildContext context) {
    return RevisionPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Action à reprendre',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.s),
          const Text(
            "Cette action existe déjà, mais son détail complet n'est pas encore rechargeable.",
          ),
          const SizedBox(height: AppSpacing.s),
          if (type != null) Text('Type: $type'),
          if (sessionId != null) Text("Session d'activité: $sessionId"),
        ],
      ),
    );
  }
}

class _UnknownPayloadFallback extends StatelessWidget {
  const _UnknownPayloadFallback();

  @override
  Widget build(BuildContext context) {
    return const RevisionMessage(
      message: 'Cette action ne peut pas encore être affichée.',
      color: Colors.teal,
      icon: Icons.widgets_outlined,
    );
  }
}

class _HistoryPanel extends StatelessWidget {
  const _HistoryPanel({required this.actions});

  final List<RevisionSessionAction> actions;

  @override
  Widget build(BuildContext context) {
    return RevisionPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Historique', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.s),
          if (actions.isEmpty)
            const Text('Aucune action enregistrée.')
          else
            for (final action in actions)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.s),
                child: Wrap(
                  spacing: AppSpacing.s,
                  runSpacing: AppSpacing.s,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    RevisionStatusPill(
                      label: '#${action.displayOrder + 1}',
                      color: Theme.of(context).colorScheme.tertiary,
                    ),
                    Text(_actionKindLabel(action.kind)),
                    Text(_actionStatusLabel(action.status)),
                  ],
                ),
              ),
        ],
      ),
    );
  }
}

String _sessionStatusLabel(RevisionSessionStatus status) {
  return switch (status) {
    RevisionSessionStatus.started => 'Démarrée',
    RevisionSessionStatus.completed => 'Terminée',
    RevisionSessionStatus.abandoned => 'Abandonnée',
    RevisionSessionStatus.unknown => 'Statut inconnu',
  };
}

String _actionKindLabel(RevisionSessionActionKind kind) {
  return switch (kind) {
    RevisionSessionActionKind.diagnosticQuiz => 'QCM',
    RevisionSessionActionKind.openQuestion => 'Question ouverte',
    RevisionSessionActionKind.richClosedExercise => 'Questions riches',
    RevisionSessionActionKind.unknown => 'Action inconnue',
  };
}

IconData _actionKindIcon(RevisionSessionActionKind kind) {
  return switch (kind) {
    RevisionSessionActionKind.diagnosticQuiz => Icons.quiz_outlined,
    RevisionSessionActionKind.openQuestion => Icons.rate_review_outlined,
    RevisionSessionActionKind.richClosedExercise => Icons.extension_outlined,
    RevisionSessionActionKind.unknown => Icons.help_outline,
  };
}

String _actionStatusLabel(RevisionSessionActionStatus status) {
  return switch (status) {
    RevisionSessionActionStatus.ready => 'Prête',
    RevisionSessionActionStatus.completed => 'Terminée',
    RevisionSessionActionStatus.failed => 'Échouée',
    RevisionSessionActionStatus.unknown => 'Statut inconnu',
  };
}

````

### `test/app/revision_app_test.dart`

````text
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
    expect(find.text('Aucune matière réelle'), findsOneWidget);
    expect(find.text('Math'), findsNothing);
    expect(find.text('Loi normale'), findsNothing);
    expect(find.text('78%'), findsNothing);
    expect(find.text('12'), findsNothing);
    expect(find.text('870'), findsNothing);
    expect(find.text('7 jours'), findsNothing);
    expect(find.text('Progrès'), findsOneWidget);
    expect(find.text('Révisions'), findsOneWidget);
    expect(find.text('Sources'), findsOneWidget);
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

    await tester.tap(find.text('Révisions'));
    await tester.pumpAndSettle();

    expect(find.text('Choisis ton mode de travail'), findsOneWidget);
    expect(find.text('Aucune matière disponible'), findsOneWidget);
    expect(find.textContaining('CORE-05 branchera'), findsNothing);
    expect(find.textContaining('à brancher en CORE-05'), findsNothing);

    await tester.tap(find.text('Sources'));
    await tester.pumpAndSettle();

    expect(find.text('Sources depuis les cours'), findsOneWidget);
    expect(find.textContaining('Ajouter une source'), findsOneWidget);
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
    expect(find.text('Aucun cours réel'), findsOneWidget);
    expect(find.text('Loi normale'), findsNothing);
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
    expect(find.text('Reprendre le cours'), findsOneWidget);
    expect(find.text('Cours 12'), findsNothing);

    await tester.scrollUntilVisible(
      find.text('Cours 12'),
      600,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.pumpAndSettle();

    expect(find.text('Droits'), findsWidgets);
    expect(find.text('Continue ton progrès'), findsOneWidget);
    expect(find.text('Reprendre le cours'), findsOneWidget);
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

    await tester.tap(find.text('Révisions'));
    await tester.pumpAndSettle();

    expect(find.text('Révisions'), findsWidgets);
    expect(find.text('Choisis ton mode de travail'), findsOneWidget);
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

````

### `test/app/router/app_router_test.dart`

````text
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

````

### `test/fakes/in_memory_activity_api.dart`

````text
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
  int submittedDiagnosticQuizCount = 0;
  int submittedRichClosedCount = 0;
  String? submittedDiagnosticSessionId;
  List<DiagnosticQuizAnswer>? submittedAnswers;
  List<RichClosedAnswer>? submittedRichClosedAnswers;
  String? submittedOpenAnswerText;
  Object? submitDiagnosticQuizError;

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
    submittedDiagnosticQuizCount += 1;
    submittedDiagnosticSessionId = sessionId;
    submittedAnswers = answers;
    final error = submitDiagnosticQuizError;
    if (error != null) {
      throw error;
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

````

### `test/fakes/in_memory_courses_repository.dart`

````text
import 'dart:typed_data';

import 'package:revision_app/features/courses/domain/course_models.dart';
import 'package:revision_app/features/courses/domain/courses_repository.dart';
import 'package:revision_app/features/documents/domain/revision_document.dart';
import 'package:revision_app/features/revision_sessions/domain/revision_session.dart';

class InMemoryCoursesRepository implements CoursesRepository {
  final Map<String, List<CourseListItem>> coursesBySubject = {};
  final Map<String, CourseDetail> detailsByCourse = {};
  final Map<String, CourseProgress> progressByCourse = {};
  final Map<String, SubjectProgress> progressBySubject = {};
  final Map<String, RevisionSheet?> revisionSheetsByCourse = {};
  final Map<String, RevisionSheet> generatedRevisionSheetsByCourse = {};
  final Map<String, Object> revisionSheetErrorsByCourse = {};
  int createCount = 0;
  int listCoursesCount = 0;
  int getCourseCount = 0;
  int getCourseProgressCount = 0;
  int getSubjectProgressCount = 0;
  int getRevisionSheetCount = 0;
  int generateRevisionSheetCount = 0;
  int uploadCount = 0;
  int deleteDocumentCount = 0;
  int startQuickRevisionCount = 0;
  String? lastUploadedCourseId;
  String? lastUploadedFileName;
  Uint8List? lastUploadedBytes;
  String? lastDeletedCourseId;
  String? lastDeletedDocumentId;
  String? lastQuickRevisionCourseId;
  Object? uploadError;
  Object? deleteDocumentError;
  Object? quickRevisionError;
  RevisionSessionResponse? quickRevisionResponse;
  Duration uploadDelay = Duration.zero;
  Duration quickRevisionDelay = Duration.zero;

  @override
  Future<List<CourseListItem>> listCourses({required String subjectId}) async {
    listCoursesCount += 1;
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
  Future<void> deleteCourseDocument({
    required String courseId,
    required String documentId,
  }) async {
    final error = deleteDocumentError;
    if (error != null) {
      throw error;
    }

    final detail = detailsByCourse[courseId];
    if (detail == null) {
      throw const CourseNotFoundException('Course not found');
    }

    final remainingSources = detail.sources
        .where((source) => source.documentId != documentId)
        .toList(growable: false);
    if (remainingSources.length == detail.sources.length) {
      throw const CourseNotFoundException('Course source not found');
    }

    deleteDocumentCount += 1;
    lastDeletedCourseId = courseId;
    lastDeletedDocumentId = documentId;
    detailsByCourse[courseId] = CourseDetail(
      course: detail.course,
      subject: detail.subject,
      sources: remainingSources,
      progress: detail.progress,
    );
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
  Future<RevisionSessionResponse> startCourseQuickRevision({
    required String courseId,
  }) async {
    if (quickRevisionDelay > Duration.zero) {
      await Future<void>.delayed(quickRevisionDelay);
    }

    final error = quickRevisionError;
    if (error != null) {
      throw error;
    }

    if (!detailsByCourse.containsKey(courseId)) {
      throw const CourseNotFoundException('Course not found');
    }

    startQuickRevisionCount += 1;
    lastQuickRevisionCourseId = courseId;

    return quickRevisionResponse ?? quickRevisionSessionResponse(courseId);
  }

  @override
  Future<CourseProgress> getCourseProgress({required String courseId}) {
    getCourseProgressCount += 1;
    final progress = progressByCourse[courseId];

    if (progress == null) {
      throw const CourseNotFoundException('Course not found');
    }

    return Future.value(progress);
  }

  @override
  Future<SubjectProgress> getSubjectProgress({required String subjectId}) {
    getSubjectProgressCount += 1;
    final progress = progressBySubject[subjectId];

    if (progress == null) {
      throw const CourseNotFoundException('Course subject not found');
    }

    return Future.value(progress);
  }
}

RevisionSessionResponse quickRevisionSessionResponse(String courseId) {
  return RevisionSessionResponse(
    session: RevisionSession(
      id: 'revision-session-1',
      status: RevisionSessionStatus.started,
      mode: RevisionSessionMode.quick,
      subjectId: 'subject-1',
      courseId: courseId,
      documentId: 'document-1',
      knowledgeUnitId: 'knowledge-unit-1',
      createdAt: DateTime.utc(2026, 6, 18, 12),
      completedAt: null,
    ),
    currentAction: const RevisionSessionAction(
      id: 'action-1',
      kind: RevisionSessionActionKind.diagnosticQuiz,
      status: RevisionSessionActionStatus.ready,
      displayOrder: 0,
      activitySessionId: 'activity-session-1',
      documentId: 'document-1',
      knowledgeUnitId: 'knowledge-unit-1',
      payload: null,
    ),
    history: const [],
  );
}

````

### `test/fakes/in_memory_revision_sessions_api.dart`

````text
import 'package:revision_app/features/activities/domain/diagnostic_quiz_activity.dart';
import 'package:revision_app/features/activities/domain/open_question_activity.dart';
import 'package:revision_app/features/revision_sessions/data/revision_sessions_api.dart';
import 'package:revision_app/features/revision_sessions/domain/revision_session.dart';

class InMemoryRevisionSessionsApi implements RevisionSessionsApi {
  String? startedSubjectId;
  String? startedDocumentId;
  String? startedKnowledgeUnitId;
  RevisionSessionPreferredAction? startedPreferredAction;
  String? loadedSessionId;
  String? completedSessionId;
  String? loadedResultSessionId;
  int startCount = 0;
  int loadCount = 0;
  int completeCount = 0;
  int loadResultCount = 0;
  Object? startError;
  Object? loadError;
  Object? completeError;
  Object? loadResultError;
  RevisionSessionResponse startResponse = openQuestionRevisionSessionResponse();
  RevisionSessionResponse loadResponse = minimalRevisionSessionResponse();
  RevisionSessionResult completeResponse = revisionSessionResult();
  RevisionSessionResult resultResponse = revisionSessionResult();

  @override
  Future<RevisionSessionResponse> startRevisionSession({
    required String subjectId,
    String? documentId,
    String? knowledgeUnitId,
    RevisionSessionPreferredAction? preferredAction,
  }) async {
    startCount += 1;
    startedSubjectId = subjectId;
    startedDocumentId = documentId;
    startedKnowledgeUnitId = knowledgeUnitId;
    startedPreferredAction = preferredAction;
    final error = startError;
    if (error != null) {
      throw error;
    }
    return startResponse;
  }

  @override
  Future<RevisionSessionResponse> getRevisionSession({
    required String sessionId,
  }) async {
    loadCount += 1;
    loadedSessionId = sessionId;
    final error = loadError;
    if (error != null) {
      throw error;
    }
    return loadResponse;
  }

  @override
  Future<RevisionSessionResult> completeRevisionSession({
    required String sessionId,
  }) async {
    completeCount += 1;
    completedSessionId = sessionId;
    final error = completeError;
    if (error != null) {
      throw error;
    }
    return completeResponse;
  }

  @override
  Future<RevisionSessionResult> getRevisionSessionResult({
    required String sessionId,
  }) async {
    loadResultCount += 1;
    loadedResultSessionId = sessionId;
    final error = loadResultError;
    if (error != null) {
      throw error;
    }
    return resultResponse;
  }
}

RevisionSessionResponse diagnosticQuizRevisionSessionResponse() {
  return RevisionSessionResponse(
    session: revisionSession(),
    currentAction: RevisionSessionAction(
      id: 'action-quiz-1',
      kind: RevisionSessionActionKind.diagnosticQuiz,
      status: RevisionSessionActionStatus.ready,
      displayOrder: 0,
      activitySessionId: 'quiz-session-1',
      documentId: null,
      knowledgeUnitId: null,
      payload: const RevisionSessionDiagnosticQuizPayload(
        DiagnosticQuizActivity(
          sessionId: 'quiz-session-1',
          title: 'QCM de session',
          subjectId: 'subject-1',
          questions: [
            DiagnosticQuizQuestion(
              id: 'question-1',
              prompt: 'Question test',
              choices: [
                DiagnosticQuizChoice(id: 'choice-1', label: 'Réponse A'),
                DiagnosticQuizChoice(id: 'choice-2', label: 'Réponse B'),
              ],
            ),
          ],
        ),
      ),
    ),
    history: [
      RevisionSessionAction(
        id: 'action-quiz-1',
        kind: RevisionSessionActionKind.diagnosticQuiz,
        status: RevisionSessionActionStatus.ready,
        displayOrder: 0,
        activitySessionId: 'quiz-session-1',
        documentId: null,
        knowledgeUnitId: null,
        payload: null,
      ),
    ],
  );
}

RevisionSessionResponse courseQuickRevisionSessionResponse({
  String courseId = 'course-1',
}) {
  return RevisionSessionResponse(
    session: RevisionSession(
      id: 'revision-session-1',
      status: RevisionSessionStatus.started,
      mode: RevisionSessionMode.quick,
      subjectId: 'subject-1',
      courseId: courseId,
      documentId: 'document-1',
      knowledgeUnitId: 'unit-1',
      createdAt: DateTime.parse('2026-06-15T12:00:00.000Z'),
      completedAt: null,
    ),
    currentAction: const RevisionSessionAction(
      id: 'action-quiz-1',
      kind: RevisionSessionActionKind.diagnosticQuiz,
      status: RevisionSessionActionStatus.ready,
      displayOrder: 0,
      activitySessionId: 'quiz-session-1',
      documentId: 'document-1',
      knowledgeUnitId: 'unit-1',
      payload: RevisionSessionDiagnosticQuizPayload(
        DiagnosticQuizActivity(
          sessionId: 'quiz-session-1',
          title: 'Révision rapide réelle',
          subjectId: 'subject-1',
          documentId: 'document-1',
          questions: [
            DiagnosticQuizQuestion(
              id: 'question-1',
              prompt: 'Quel principe organise les pouvoirs ?',
              knowledgeUnitId: 'unit-1',
              choices: [
                DiagnosticQuizChoice(
                  id: 'choice-1',
                  label: 'La séparation des pouvoirs',
                ),
                DiagnosticQuizChoice(
                  id: 'choice-2',
                  label: 'La confusion des pouvoirs',
                ),
              ],
            ),
            DiagnosticQuizQuestion(
              id: 'question-2',
              prompt: 'Quelle institution vote la loi ?',
              knowledgeUnitId: 'unit-1',
              choices: [
                DiagnosticQuizChoice(id: 'choice-3', label: 'Le Parlement'),
                DiagnosticQuizChoice(id: 'choice-4', label: 'Le Préfet'),
              ],
            ),
          ],
        ),
      ),
    ),
    history: const [
      RevisionSessionAction(
        id: 'action-quiz-1',
        kind: RevisionSessionActionKind.diagnosticQuiz,
        status: RevisionSessionActionStatus.ready,
        displayOrder: 0,
        activitySessionId: 'quiz-session-1',
        documentId: 'document-1',
        knowledgeUnitId: 'unit-1',
        payload: null,
      ),
    ],
  );
}

RevisionSessionResponse openQuestionRevisionSessionResponse() {
  return RevisionSessionResponse(
    session: revisionSession(knowledgeUnitId: 'unit-1'),
    currentAction: RevisionSessionAction(
      id: 'action-open-1',
      kind: RevisionSessionActionKind.openQuestion,
      status: RevisionSessionActionStatus.ready,
      displayOrder: 0,
      activitySessionId: 'open-session-1',
      documentId: null,
      knowledgeUnitId: 'unit-1',
      payload: const RevisionSessionOpenQuestionPayload(
        OpenQuestionActivity(
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
        ),
      ),
    ),
    history: [
      RevisionSessionAction(
        id: 'action-open-1',
        kind: RevisionSessionActionKind.openQuestion,
        status: RevisionSessionActionStatus.ready,
        displayOrder: 0,
        activitySessionId: 'open-session-1',
        documentId: null,
        knowledgeUnitId: 'unit-1',
        payload: null,
      ),
    ],
  );
}

RevisionSessionResponse richClosedRevisionSessionResponse() {
  return RevisionSessionResponse(
    session: revisionSession(knowledgeUnitId: 'unit-1'),
    currentAction: const RevisionSessionAction(
      id: 'action-rich-1',
      kind: RevisionSessionActionKind.richClosedExercise,
      status: RevisionSessionActionStatus.ready,
      displayOrder: 0,
      activitySessionId: null,
      documentId: 'document-1',
      knowledgeUnitId: 'unit-1',
      payload: RevisionSessionRichClosedExercisePayload(
        subjectId: 'subject-1',
        documentId: 'document-1',
        knowledgeUnitId: 'unit-1',
        knowledgeUnitTitle: 'Institutions politiques',
        reason: 'Questions riches recommandées.',
        estimatedMinutes: 8,
        preferredAction: 'rich_closed_exercise',
      ),
    ),
    history: const [
      RevisionSessionAction(
        id: 'action-rich-1',
        kind: RevisionSessionActionKind.richClosedExercise,
        status: RevisionSessionActionStatus.ready,
        displayOrder: 0,
        activitySessionId: null,
        documentId: 'document-1',
        knowledgeUnitId: 'unit-1',
        payload: null,
      ),
    ],
  );
}

RevisionSessionResponse minimalRevisionSessionResponse() {
  return RevisionSessionResponse(
    session: revisionSession(),
    currentAction: const RevisionSessionAction(
      id: 'action-minimal-1',
      kind: RevisionSessionActionKind.openQuestion,
      status: RevisionSessionActionStatus.ready,
      displayOrder: 0,
      activitySessionId: 'open-session-1',
      documentId: null,
      knowledgeUnitId: 'unit-1',
      payload: RevisionSessionMinimalPayload(
        type: 'open_question',
        sessionId: 'open-session-1',
      ),
    ),
    history: const [
      RevisionSessionAction(
        id: 'action-minimal-1',
        kind: RevisionSessionActionKind.openQuestion,
        status: RevisionSessionActionStatus.ready,
        displayOrder: 0,
        activitySessionId: 'open-session-1',
        documentId: null,
        knowledgeUnitId: 'unit-1',
        payload: null,
      ),
    ],
  );
}

RevisionSession revisionSession({String? knowledgeUnitId}) {
  return RevisionSession(
    id: 'revision-session-1',
    status: RevisionSessionStatus.started,
    mode: RevisionSessionMode.quick,
    subjectId: 'subject-1',
    courseId: null,
    documentId: null,
    knowledgeUnitId: knowledgeUnitId,
    createdAt: DateTime.parse('2026-06-15T12:00:00.000Z'),
    completedAt: null,
  );
}

RevisionSessionResult revisionSessionResult() {
  return RevisionSessionResult(
    session: RevisionSessionResultSession(
      id: 'revision-session-1',
      subjectId: 'subject-1',
      courseId: 'course-1',
      mode: RevisionSessionMode.quick,
      status: RevisionSessionStatus.completed,
      createdAt: DateTime.parse('2026-06-15T12:00:00.000Z'),
      completedAt: DateTime.parse('2026-06-15T12:04:12.000Z'),
    ),
    summary: const RevisionSessionResultSummary(
      correctAnswers: 4,
      totalQuestions: 6,
      score: 4 / 6,
      durationSeconds: 252,
    ),
    knowledgeUnits: const [
      RevisionSessionKnowledgeUnitResult(
        knowledgeUnitId: 'unit-1',
        title: 'Séparation des pouvoirs',
        correctAnswers: 4,
        totalQuestions: 6,
        score: 4 / 6,
        state: RevisionSessionKnowledgeUnitResultState.toReview,
      ),
    ],
  );
}

````

### `test/features/courses/course_detail_page_test.dart`

````text
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

    expect(find.text('Progression réelle'), findsOneWidget);
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
    expect(
      find.text('Progression réelle basée sur tes réponses.'),
      findsOneWidget,
    );
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
    await tester.pump();

    expect(find.text('Démarrage...'), findsOneWidget);

    await tester.pumpAndSettle();

    expect(repository.startQuickRevisionCount, 1);
    expect(repository.lastQuickRevisionCourseId, 'course-1');
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

````

### `test/features/courses/http_courses_repository_test.dart`

````text
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
    'deletes a course source through the encoded course-scoped endpoint',
    () async {
      final adapter = CapturingHttpClientAdapter(
        jsonResponse(null, statusCode: 204),
      );
      final repository = HttpCoursesRepository(
        dio: Dio()..httpClientAdapter = adapter,
        getIdToken: () async => 'firebase-id-token',
      );

      await repository.deleteCourseDocument(
        courseId: 'course id/1',
        documentId: 'document id/1',
      );

      expect(adapter.lastOptions?.method, 'DELETE');
      expect(
        adapter.lastOptions?.path,
        '/courses/course%20id%2F1/sources/document%20id%2F1',
      );
      expect(adapter.lastOptions?.data, isNull);
      expect(
        adapter.lastOptions?.headers['Authorization'],
        'Bearer firebase-id-token',
      );
    },
  );

  test('maps course source delete 404 to CourseNotFoundException', () async {
    final adapter = CapturingHttpClientAdapter(
      jsonResponse({'message': 'Course source not found'}, statusCode: 404),
    );
    final repository = HttpCoursesRepository(
      dio: Dio()..httpClientAdapter = adapter,
      getIdToken: () async => 'firebase-id-token',
    );

    await expectLater(
      repository.deleteCourseDocument(
        courseId: 'course-1',
        documentId: 'missing-document',
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

      final missingCourseRepository = HttpCoursesRepository(
        dio: Dio()
          ..httpClientAdapter = CapturingHttpClientAdapter(
            jsonResponse({'message': 'Course not found'}, statusCode: 404),
          ),
        getIdToken: () async => 'firebase-id-token',
      );

      await expectLater(
        missingCourseRepository.getCourseRevisionSheet(courseId: 'course-1'),
        throwsA(isA<CourseNotFoundException>()),
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

  test('starts a course quick revision without client-owned ids', () async {
    final adapter = CapturingHttpClientAdapter(
      jsonResponse(revisionSessionJson(courseId: 'course-1')),
    );
    final repository = HttpCoursesRepository(
      dio: Dio()..httpClientAdapter = adapter,
      getIdToken: () async => 'firebase-id-token',
    );

    final response = await repository.startCourseQuickRevision(
      courseId: 'course-1',
    );

    expect(response.session.id, 'revision-session-1');
    expect(response.session.courseId, 'course-1');
    expect(response.currentAction?.kind.name, 'diagnosticQuiz');
    expect(adapter.lastOptions?.method, 'POST');
    expect(
      adapter.lastOptions?.path,
      '/courses/course-1/revision-sessions/quick',
    );
    expect(adapter.lastOptions?.data, isNull);
    expect(
      adapter.lastOptions?.headers['Authorization'],
      'Bearer firebase-id-token',
    );
  });

  test('loads course progress from the course progress endpoint', () async {
    final adapter = CapturingHttpClientAdapter(
      jsonResponse(courseProgressJson()),
    );
    final repository = HttpCoursesRepository(
      dio: Dio()..httpClientAdapter = adapter,
      getIdToken: () async => 'firebase-id-token',
    );

    final progress = await repository.getCourseProgress(courseId: 'course-1');

    expect(progress.knowledgeUnitCount, 12);
    expect(progress.practicedKnowledgeUnitCount, 3);
    expect(progress.coverage, 0.25);
    expect(progress.mastery, 0.72);
    expect(progress.estimatedGlobalMastery, 0.18);
    expect(progress.state, CourseProgressState.practiced);
    expect(adapter.lastOptions?.method, 'GET');
    expect(adapter.lastOptions?.path, '/courses/course-1/progress');
    expect(
      adapter.lastOptions?.headers['Authorization'],
      'Bearer firebase-id-token',
    );
  });

  test('loads subject progress and maps unknown course state safely', () async {
    final adapter = CapturingHttpClientAdapter(
      jsonResponse(
        subjectProgressJson(
          courses: [subjectCourseProgressJson(state: 'FUTURE_STATE')],
        ),
      ),
    );
    final repository = HttpCoursesRepository(
      dio: Dio()..httpClientAdapter = adapter,
      getIdToken: () async => 'firebase-id-token',
    );

    final progress = await repository.getSubjectProgress(
      subjectId: 'subject-1',
    );

    expect(progress.courseCount, 1);
    expect(progress.readyCourseCount, 1);
    expect(progress.courses.single.state, CourseProgressState.unknown);
    expect(adapter.lastOptions?.method, 'GET');
    expect(adapter.lastOptions?.path, '/subjects/subject-1/progress');
  });

  test('parses nullable mastery and progress 404 errors', () async {
    final noMasteryRepository = HttpCoursesRepository(
      dio: Dio()
        ..httpClientAdapter = CapturingHttpClientAdapter(
          jsonResponse(courseProgressJson(mastery: null)),
        ),
      getIdToken: () async => 'firebase-id-token',
    );

    final progress = await noMasteryRepository.getCourseProgress(
      courseId: 'course-1',
    );

    expect(progress.mastery, isNull);

    final missingCourseRepository = HttpCoursesRepository(
      dio: Dio()
        ..httpClientAdapter = CapturingHttpClientAdapter(
          jsonResponse({'message': 'Course not found'}, statusCode: 404),
        ),
      getIdToken: () async => 'firebase-id-token',
    );

    await expectLater(
      missingCourseRepository.getCourseProgress(courseId: 'missing'),
      throwsA(isA<CourseNotFoundException>()),
    );
  });

  test('maps course quick revision 404 and 409 to typed exceptions', () async {
    final missingCourseRepository = HttpCoursesRepository(
      dio: Dio()
        ..httpClientAdapter = CapturingHttpClientAdapter(
          jsonResponse({'message': 'Course not found'}, statusCode: 404),
        ),
      getIdToken: () async => 'firebase-id-token',
    );

    await expectLater(
      missingCourseRepository.startCourseQuickRevision(courseId: 'missing'),
      throwsA(isA<CourseNotFoundException>()),
    );

    final notReadyRepository = HttpCoursesRepository(
      dio: Dio()
        ..httpClientAdapter = CapturingHttpClientAdapter(
          jsonResponse({
            'message': 'Course has no ready knowledge unit',
          }, statusCode: 409),
        ),
      getIdToken: () async => 'firebase-id-token',
    );

    await expectLater(
      notReadyRepository.startCourseQuickRevision(courseId: 'course-1'),
      throwsA(
        isA<CourseQuickRevisionUnavailableException>().having(
          (error) => error.message,
          'message',
          'Course has no ready knowledge unit',
        ),
      ),
    );
  });

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

Map<String, Object?> revisionSessionJson({required String courseId}) {
  return {
    'session': {
      'id': 'revision-session-1',
      'status': 'STARTED',
      'mode': 'QUICK',
      'subjectId': 'subject-1',
      'courseId': courseId,
      'documentId': 'document-1',
      'knowledgeUnitId': 'knowledge-unit-1',
      'createdAt': '2026-06-18T10:00:00.000Z',
      'completedAt': null,
    },
    'currentAction': {
      'id': 'action-1',
      'kind': 'DIAGNOSTIC_QUIZ',
      'status': 'READY',
      'displayOrder': 0,
      'activitySessionId': 'activity-session-1',
      'documentId': 'document-1',
      'knowledgeUnitId': 'knowledge-unit-1',
      'payload': null,
    },
    'history': [],
  };
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

Map<String, Object?> courseProgressJson({Object? mastery = 0.72}) {
  return {
    'courseId': 'course-1',
    'subjectId': 'subject-1',
    'knowledgeUnitCount': 12,
    'practicedKnowledgeUnitCount': 3,
    'coverage': 0.25,
    'mastery': mastery,
    'estimatedGlobalMastery': 0.18,
    'readySourceCount': 1,
    'processingSourceCount': 0,
    'failedSourceCount': 0,
    'lastPracticedAt': '2026-06-18T12:00:00.000Z',
    'state': 'PRACTICED',
  };
}

Map<String, Object?> subjectProgressJson({
  List<Map<String, Object?>>? courses,
}) {
  return {
    'subjectId': 'subject-1',
    'knowledgeUnitCount': 12,
    'practicedKnowledgeUnitCount': 3,
    'coverage': 0.25,
    'mastery': 0.72,
    'estimatedGlobalMastery': 0.18,
    'courseCount': 1,
    'readyCourseCount': 1,
    'lastPracticedAt': '2026-06-18T12:00:00.000Z',
    'courses': courses ?? [subjectCourseProgressJson()],
  };
}

Map<String, Object?> subjectCourseProgressJson({String state = 'PRACTICED'}) {
  return {
    'courseId': 'course-1',
    'title': 'Droit constitutionnel',
    'knowledgeUnitCount': 12,
    'practicedKnowledgeUnitCount': 3,
    'coverage': 0.25,
    'mastery': 0.72,
    'estimatedGlobalMastery': 0.18,
    'state': state,
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

````

### `test/features/revision_sessions/http_revision_sessions_api_test.dart`

````text
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:revision_app/features/revision_sessions/data/http_revision_sessions_api.dart';
import 'package:revision_app/features/revision_sessions/data/revision_sessions_api.dart';
import 'package:revision_app/features/revision_sessions/domain/revision_session.dart';

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
  test('starts a revision session with preferred action payload', () async {
    final adapter = CapturingHttpClientAdapter(
      jsonResponse(revisionSessionJson(payload: diagnosticQuizPayloadJson())),
    );
    final dio = Dio()..httpClientAdapter = adapter;
    final api = HttpRevisionSessionsApi(
      dio: dio,
      getIdToken: () async => 'firebase-id-token',
    );

    final response = await api.startRevisionSession(
      subjectId: 'subject-1',
      documentId: 'document-1',
      knowledgeUnitId: 'unit-1',
      preferredAction: RevisionSessionPreferredAction.openQuestion,
    );

    expect(adapter.lastOptions?.path, '/revision-sessions');
    expect(adapter.lastOptions?.data, {
      'subjectId': 'subject-1',
      'documentId': 'document-1',
      'knowledgeUnitId': 'unit-1',
      'preferredAction': 'open_question',
    });
    expect(
      adapter.lastOptions?.headers['Authorization'],
      'Bearer firebase-id-token',
    );
    expect(response.session.id, 'revision-session-1');
    expect(
      response.currentAction?.kind,
      RevisionSessionActionKind.diagnosticQuiz,
    );
    expect(
      response.currentAction?.payload,
      isA<RevisionSessionDiagnosticQuizPayload>(),
    );
  });

  test('parses courseId for course-level revision sessions', () async {
    final adapter = CapturingHttpClientAdapter(
      jsonResponse(
        revisionSessionJson(
          payload: diagnosticQuizPayloadJson(),
          courseId: 'course-1',
        ),
      ),
    );
    final dio = Dio()..httpClientAdapter = adapter;
    final api = HttpRevisionSessionsApi(
      dio: dio,
      getIdToken: () async => 'firebase-id-token',
    );

    final response = await api.getRevisionSession(
      sessionId: 'revision-session-1',
    );

    expect(response.session.courseId, 'course-1');
  });

  test('starts and parses a rich closed launcher payload', () async {
    final adapter = CapturingHttpClientAdapter(
      jsonResponse(revisionSessionJson(payload: richClosedPayloadJson())),
    );
    final dio = Dio()..httpClientAdapter = adapter;
    final api = HttpRevisionSessionsApi(
      dio: dio,
      getIdToken: () async => 'firebase-id-token',
    );

    final response = await api.startRevisionSession(
      subjectId: 'subject-1',
      documentId: 'document-1',
      knowledgeUnitId: 'unit-1',
      preferredAction: RevisionSessionPreferredAction.richClosedExercise,
    );

    expect(adapter.lastOptions?.data, {
      'subjectId': 'subject-1',
      'documentId': 'document-1',
      'knowledgeUnitId': 'unit-1',
      'preferredAction': 'rich_closed_exercise',
    });
    expect(
      response.currentAction?.kind,
      RevisionSessionActionKind.richClosedExercise,
    );
    expect(response.currentAction?.activitySessionId, isNull);
    final payload = response.currentAction?.payload;
    expect(payload, isA<RevisionSessionRichClosedExercisePayload>());
    final launcher = payload as RevisionSessionRichClosedExercisePayload;
    expect(launcher.subjectId, 'subject-1');
    expect(launcher.documentId, 'document-1');
    expect(launcher.knowledgeUnitId, 'unit-1');
    expect(launcher.knowledgeUnitTitle, 'Institutions politiques');
    expect(launcher.estimatedMinutes, 8);
  });

  test('omits null fields from start request', () async {
    final adapter = CapturingHttpClientAdapter(
      jsonResponse(revisionSessionJson(payload: diagnosticQuizPayloadJson())),
    );
    final dio = Dio()..httpClientAdapter = adapter;
    final api = HttpRevisionSessionsApi(
      dio: dio,
      getIdToken: () async => 'firebase-id-token',
    );

    await api.startRevisionSession(subjectId: 'subject-1');

    expect(adapter.lastOptions?.data, {'subjectId': 'subject-1'});
  });

  test('gets a revision session with minimal payload', () async {
    final adapter = CapturingHttpClientAdapter(
      jsonResponse(revisionSessionJson(payload: minimalPayloadJson())),
    );
    final dio = Dio()..httpClientAdapter = adapter;
    final api = HttpRevisionSessionsApi(
      dio: dio,
      getIdToken: () async => 'firebase-id-token',
    );

    final response = await api.getRevisionSession(
      sessionId: 'revision-session-1',
    );

    expect(adapter.lastOptions?.path, '/revision-sessions/revision-session-1');
    final payload = response.currentAction?.payload;
    expect(payload, isA<RevisionSessionMinimalPayload>());
    expect((payload as RevisionSessionMinimalPayload).type, 'open_question');
    expect(payload.sessionId, 'open-session-1');
  });

  test(
    'parses an open question full payload without correction leaks',
    () async {
      final adapter = CapturingHttpClientAdapter(
        jsonResponse(revisionSessionJson(payload: openQuestionPayloadJson())),
      );
      final dio = Dio()..httpClientAdapter = adapter;
      final api = HttpRevisionSessionsApi(
        dio: dio,
        getIdToken: () async => 'firebase-id-token',
      );

      final response = await api.startRevisionSession(
        subjectId: 'subject-1',
        knowledgeUnitId: 'unit-1',
      );

      final payload = response.currentAction?.payload;
      expect(payload, isA<RevisionSessionOpenQuestionPayload>());
      final activity = (payload as RevisionSessionOpenQuestionPayload).activity;
      expect(activity.question.prompt, 'Explique la séparation des pouvoirs.');
      expect(activity.question.sources.single.chunkId, 'chunk-1');
    },
  );

  test('parses currentAction null and history', () async {
    final json = revisionSessionJson(payload: null)..['currentAction'] = null;
    final adapter = CapturingHttpClientAdapter(jsonResponse(json));
    final dio = Dio()..httpClientAdapter = adapter;
    final api = HttpRevisionSessionsApi(
      dio: dio,
      getIdToken: () async => 'firebase-id-token',
    );

    final response = await api.getRevisionSession(
      sessionId: 'revision-session-1',
    );

    expect(response.currentAction, isNull);
    expect(response.history, hasLength(1));
    expect(
      response.history.single.kind,
      RevisionSessionActionKind.openQuestion,
    );
  });

  test('rejects rich closed payloads that contain exercise content', () async {
    final payload = richClosedPayloadJson()
      ..['questions'] = [
        {'id': 'question-1'},
      ]
      ..['correction'] = {'correctChoiceId': 'choice-1'};
    final adapter = CapturingHttpClientAdapter(
      jsonResponse(revisionSessionJson(payload: payload)),
    );
    final dio = Dio()..httpClientAdapter = adapter;
    final api = HttpRevisionSessionsApi(
      dio: dio,
      getIdToken: () async => 'firebase-id-token',
    );

    final response = await api.getRevisionSession(
      sessionId: 'revision-session-1',
    );

    expect(
      response.currentAction?.payload,
      isA<RevisionSessionUnknownPayload>(),
    );
  });

  test('refuses an empty token before network call', () async {
    final adapter = CapturingHttpClientAdapter(
      jsonResponse(revisionSessionJson(payload: minimalPayloadJson())),
    );
    final dio = Dio()..httpClientAdapter = adapter;
    final api = HttpRevisionSessionsApi(dio: dio, getIdToken: () async => ' ');

    await expectLater(
      api.getRevisionSession(sessionId: 'revision-session-1'),
      throwsStateError,
    );
    expect(adapter.fetchCallCount, 0);
  });

  test('completes a revision session with an empty body', () async {
    final adapter = CapturingHttpClientAdapter(
      jsonResponse(revisionSessionResultJson()),
    );
    final dio = Dio()..httpClientAdapter = adapter;
    final api = HttpRevisionSessionsApi(
      dio: dio,
      getIdToken: () async => 'firebase-id-token',
    );

    final result = await api.completeRevisionSession(
      sessionId: 'revision-session-1',
    );

    expect(
      adapter.lastOptions?.path,
      '/revision-sessions/revision-session-1/complete',
    );
    expect(adapter.lastOptions?.data, const <String, Object?>{});
    expect(result.summary.correctAnswers, 4);
    expect(result.summary.totalQuestions, 6);
    expect(result.knowledgeUnits.single.state.name, 'toReview');
  });

  test('gets a revision session result', () async {
    final adapter = CapturingHttpClientAdapter(
      jsonResponse(revisionSessionResultJson()),
    );
    final dio = Dio()..httpClientAdapter = adapter;
    final api = HttpRevisionSessionsApi(
      dio: dio,
      getIdToken: () async => 'firebase-id-token',
    );

    final result = await api.getRevisionSessionResult(
      sessionId: 'revision-session-1',
    );

    expect(
      adapter.lastOptions?.path,
      '/revision-sessions/revision-session-1/result',
    );
    expect(result.session.courseId, 'course-1');
    expect(result.session.mode, RevisionSessionMode.quick);
    expect(result.summary.durationSeconds, 252);
  });

  test('maps result 404 and 409 responses', () async {
    final adapter = CapturingHttpClientAdapter(
      ResponseBody.fromString(
        jsonEncode({'message': 'Revision session not found'}),
        404,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      ),
    );
    final dio = Dio()..httpClientAdapter = adapter;
    final api = HttpRevisionSessionsApi(
      dio: dio,
      getIdToken: () async => 'firebase-id-token',
    );

    await expectLater(
      api.getRevisionSessionResult(sessionId: 'missing-session'),
      throwsA(isA<RevisionSessionNotFoundException>()),
    );

    adapter.response = ResponseBody.fromString(
      jsonEncode({'message': 'Revision session not completed'}),
      409,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );

    await expectLater(
      api.completeRevisionSession(sessionId: 'revision-session-1'),
      throwsA(isA<RevisionSessionResultNotReadyException>()),
    );
  });

  test('rejects invalid revision session responses', () async {
    final adapter = CapturingHttpClientAdapter(
      jsonResponse({'session': null, 'currentAction': null, 'history': []}),
    );
    final dio = Dio()..httpClientAdapter = adapter;
    final api = HttpRevisionSessionsApi(
      dio: dio,
      getIdToken: () async => 'firebase-id-token',
    );

    await expectLater(
      api.getRevisionSession(sessionId: 'revision-session-1'),
      throwsFormatException,
    );
  });
}

ResponseBody jsonResponse(Object? payload) {
  return ResponseBody.fromString(
    jsonEncode(payload),
    200,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );
}

Map<String, Object?> revisionSessionJson({
  required Object? payload,
  String? courseId,
}) {
  final actionKind = payload == null ? 'OPEN_QUESTION' : actionKindFor(payload);
  final isRichClosed = actionKind == 'RICH_CLOSED_EXERCISE';

  return {
    'session': {
      'id': 'revision-session-1',
      'status': 'STARTED',
      'mode': 'QUICK',
      'subjectId': 'subject-1',
      'courseId': courseId,
      'documentId': null,
      'knowledgeUnitId': 'unit-1',
      'createdAt': '2026-06-15T12:00:00.000Z',
      'completedAt': null,
    },
    'currentAction': {
      'id': 'action-1',
      'kind': actionKind,
      'status': 'READY',
      'displayOrder': 0,
      'activitySessionId': isRichClosed ? null : 'activity-session-1',
      'documentId': null,
      'knowledgeUnitId': 'unit-1',
      'payload': payload,
    },
    'history': [
      {
        'id': 'action-1',
        'kind': actionKind,
        'status': 'READY',
        'displayOrder': 0,
        'activitySessionId': isRichClosed ? null : 'activity-session-1',
        'documentId': null,
        'knowledgeUnitId': 'unit-1',
      },
    ],
  };
}

Map<String, Object?> revisionSessionResultJson({
  String? state = 'TO_REVIEW',
  String? courseId = 'course-1',
}) {
  return {
    'session': {
      'id': 'revision-session-1',
      'subjectId': 'subject-1',
      'courseId': courseId,
      'mode': 'QUICK',
      'status': 'COMPLETED',
      'createdAt': '2026-06-15T12:00:00.000Z',
      'completedAt': '2026-06-15T12:04:12.000Z',
    },
    'summary': {
      'correctAnswers': 4,
      'totalQuestions': 6,
      'score': 0.6666666667,
      'durationSeconds': 252,
    },
    'knowledgeUnits': [
      {
        'knowledgeUnitId': 'unit-1',
        'title': 'Séparation des pouvoirs',
        'correctAnswers': 4,
        'totalQuestions': 6,
        'score': 0.6666666667,
        'state': state,
      },
    ],
  };
}

String actionKindFor(Object payload) {
  if (payload is Map && payload['type'] == 'diagnostic_quiz') {
    return 'DIAGNOSTIC_QUIZ';
  }
  if (payload is Map && payload['type'] == 'rich_closed_exercise') {
    return 'RICH_CLOSED_EXERCISE';
  }
  return 'OPEN_QUESTION';
}

Map<String, Object?> minimalPayloadJson() {
  return {'type': 'open_question', 'sessionId': 'open-session-1'};
}

Map<String, Object?> diagnosticQuizPayloadJson() {
  return {
    'sessionId': 'quiz-session-1',
    'type': 'diagnostic_quiz',
    'version': 3,
    'title': 'QCM de session',
    'documentId': null,
    'subjectId': 'subject-1',
    'questions': [
      {
        'id': 'question-1',
        'knowledgeUnitId': 'unit-1',
        'prompt': 'Question test',
        'difficulty': 'MEDIUM',
        'correctChoiceId': 'choice-1',
        'explanation': 'Ne doit pas être mappé.',
        'sources': [
          {
            'chunkId': 'chunk-1',
            'pageNumber': null,
            'index': 0,
            'text': 'Texte source complet interdit.',
          },
        ],
        'choices': [
          {'id': 'choice-1', 'label': 'Réponse A', 'feedback': 'Interdit'},
          {'id': 'choice-2', 'label': 'Réponse B'},
        ],
      },
    ],
  };
}

Map<String, Object?> openQuestionPayloadJson() {
  return {
    'sessionId': 'open-session-1',
    'type': 'open_question',
    'version': 1,
    'subjectId': 'subject-1',
    'documentId': null,
    'knowledgeUnitId': 'unit-1',
    'score': 20,
    'feedback': 'Interdit avant submit.',
    'modelAnswer': 'Interdit avant submit.',
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
          'text': 'Texte source complet interdit.',
        },
      ],
    },
  };
}

Map<String, Object?> richClosedPayloadJson() {
  return {
    'type': 'rich_closed_exercise',
    'subjectId': 'subject-1',
    'documentId': 'document-1',
    'knowledgeUnitId': 'unit-1',
    'knowledgeUnitTitle': 'Institutions politiques',
    'reason': 'Questions riches recommandées.',
    'estimatedMinutes': 8,
    'preferredAction': 'rich_closed_exercise',
  };
}

````

### `test/features/revision_sessions/revision_session_page_test.dart`

````text
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:revision_app/app/router/app_routes.dart';
import 'package:revision_app/features/activities/application/activity_controller.dart';
import 'package:revision_app/features/courses/application/courses_providers.dart';
import 'package:revision_app/features/courses/domain/course_models.dart';
import 'package:revision_app/features/revision_sessions/application/revision_session_controller.dart';
import 'package:revision_app/presentation/pages/revision_sessions/revision_session_page.dart';
import 'package:revision_app/presentation/widgets/revision_button.dart';

import '../../fakes/in_memory_activity_api.dart';
import '../../fakes/in_memory_courses_repository.dart';
import '../../fakes/in_memory_revision_sessions_api.dart';

void main() {
  testWidgets(
    'start mode starts a revision session and renders open question',
    (tester) async {
      final api = InMemoryRevisionSessionsApi();

      await tester.pumpWidget(
        _Harness(api: api, subjectId: 'subject-1', knowledgeUnitId: 'unit-1'),
      );
      await tester.pumpAndSettle();

      expect(api.startCount, 1);
      expect(api.startedSubjectId, 'subject-1');
      expect(find.text('Révision IA'), findsOneWidget);
      expect(find.text('Question ouverte test'), findsOneWidget);
      expect(find.text('Historique'), findsOneWidget);
    },
  );

  testWidgets('start mode renders diagnostic quiz full payload', (
    tester,
  ) async {
    final api = InMemoryRevisionSessionsApi()
      ..startResponse = diagnosticQuizRevisionSessionResponse();

    await tester.pumpWidget(_Harness(api: api, subjectId: 'subject-1'));
    await tester.pumpAndSettle();

    expect(api.startCount, 1);
    expect(find.text('QCM de session'), findsOneWidget);
    expect(find.text('Question test'), findsOneWidget);
  });

  testWidgets(
    'start mode renders rich closed launcher without exercise content',
    (tester) async {
      final api = InMemoryRevisionSessionsApi()
        ..startResponse = richClosedRevisionSessionResponse();

      await tester.pumpWidget(
        _Harness(api: api, subjectId: 'subject-1', knowledgeUnitId: 'unit-1'),
      );
      await tester.pumpAndSettle();

      expect(api.startCount, 1);
      expect(find.text('Questions riches'), findsWidgets);
      expect(find.text('Notion: Institutions politiques'), findsOneWidget);
      expect(find.text('Questions riches recommandées.'), findsOneWidget);
      expect(find.text('Commencer'), findsOneWidget);
      expect(find.text('question-1'), findsNothing);
      expect(find.text('correctChoiceId'), findsNothing);
    },
  );

  testWidgets('load mode loads existing session and renders minimal fallback', (
    tester,
  ) async {
    final api = InMemoryRevisionSessionsApi();

    await tester.pumpWidget(
      _Harness(api: api, sessionId: 'revision-session-1'),
    );
    await tester.pumpAndSettle();

    expect(api.loadCount, 1);
    expect(api.loadedSessionId, 'revision-session-1');
    expect(
      find.textContaining("détail complet n'est pas encore rechargeable"),
      findsOneWidget,
    );
    expect(find.textContaining('open-session-1'), findsOneWidget);
  });

  testWidgets('empty state is shown without subject or session id', (
    tester,
  ) async {
    final api = InMemoryRevisionSessionsApi();

    await tester.pumpWidget(_Harness(api: api));
    await tester.pumpAndSettle();

    expect(api.startCount, 0);
    expect(api.loadCount, 0);
    expect(find.textContaining('Choisis une matière'), findsOneWidget);
  });

  testWidgets('error state keeps retry action', (tester) async {
    final api = InMemoryRevisionSessionsApi()..startError = StateError('boom');

    await tester.pumpWidget(_Harness(api: api, subjectId: 'subject-1'));
    await tester.pumpAndSettle();

    expect(
      find.text('Impossible de charger la session de révision.'),
      findsOneWidget,
    );

    api.startError = null;
    await tester.tap(find.widgetWithText(RevisionButton, 'Réessayer'));
    await tester.pumpAndSettle();

    expect(api.startCount, 2);
    expect(find.text('Question ouverte test'), findsOneWidget);
  });

  testWidgets('does not show sensitive correction fields before submit', (
    tester,
  ) async {
    final api = InMemoryRevisionSessionsApi()
      ..startResponse = diagnosticQuizRevisionSessionResponse();

    await tester.pumpWidget(_Harness(api: api, subjectId: 'subject-1'));
    await tester.pumpAndSettle();

    expect(find.text('correctChoiceId'), findsNothing);
    expect(find.text('feedback'), findsNothing);
    expect(find.text('modelAnswer'), findsNothing);
    expect(find.text('score'), findsNothing);
  });

  testWidgets(
    'course quick session renders one question at a time and completes remotely',
    (tester) async {
      final revisionApi = InMemoryRevisionSessionsApi()
        ..loadResponse = courseQuickRevisionSessionResponse();
      final activityApi = InMemoryActivityApi();
      final coursesRepository = InMemoryCoursesRepository()
        ..detailsByCourse['course-1'] = _courseDetail();
      final router = GoRouter(
        initialLocation: AppRoutes.revisionSessionV2(
          sessionId: 'revision-session-1',
        ),
        routes: [
          GoRoute(
            path: AppRoutes.revisionSessionV2Path,
            builder: (context, state) => RevisionSessionPage(
              revisionSessionController: RevisionSessionController(revisionApi),
              activityController: ActivityController(activityApi),
              sessionId: state.pathParameters['sessionId'],
            ),
          ),
          GoRoute(
            path: AppRoutes.revisionSessionResultV2Path,
            builder: (context, state) => const Text('Result route'),
          ),
          GoRoute(
            path: AppRoutes.coursePath,
            builder: (context, state) => const Text('Course route'),
          ),
        ],
      );
      addTearDown(router.dispose);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            coursesRepositoryProvider.overrideWithValue(coursesRepository),
          ],
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Révision rapide'), findsOneWidget);
      expect(find.text('Question 1 sur 2'), findsOneWidget);
      expect(
        find.text('Quel principe organise les pouvoirs ?'),
        findsOneWidget,
      );
      expect(find.text('Quelle institution vote la loi ?'), findsNothing);
      expect(find.text('quiz-session-1'), findsNothing);
      expect(find.text('correctChoiceId'), findsNothing);

      await tester.tap(find.text('La séparation des pouvoirs'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Suivant'));
      await tester.pumpAndSettle();

      expect(find.text('Question 2 sur 2'), findsOneWidget);
      expect(find.text('Quelle institution vote la loi ?'), findsOneWidget);

      await tester.tap(find.text('Le Parlement'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Terminer'));
      await tester.pumpAndSettle();

      expect(activityApi.submittedDiagnosticQuizCount, 1);
      expect(activityApi.submittedDiagnosticSessionId, 'quiz-session-1');
      expect(activityApi.submittedAnswers, hasLength(2));
      expect(revisionApi.completeCount, 1);
      expect(revisionApi.completedSessionId, 'revision-session-1');
      expect(
        router.routeInformationProvider.value.uri.path,
        '/revision-sessions/revision-session-1/result',
      );
      expect(find.text('Result route'), findsOneWidget);
    },
  );
}

class _Harness extends StatelessWidget {
  const _Harness({
    required this.api,
    this.sessionId,
    this.subjectId,
    this.knowledgeUnitId,
  });

  final InMemoryRevisionSessionsApi api;
  final String? sessionId;
  final String? subjectId;
  final String? knowledgeUnitId;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: RevisionSessionPage(
        revisionSessionController: RevisionSessionController(api),
        activityController: ActivityController(InMemoryActivityApi()),
        sessionId: sessionId,
        subjectId: subjectId,
        knowledgeUnitId: knowledgeUnitId,
      ),
    );
  }
}

CourseDetail _courseDetail() {
  const course = CourseListItem(
    id: 'course-1',
    subjectId: 'subject-1',
    title: 'Droit constitutionnel',
    sourceCount: 1,
    readySourceCount: 1,
  );

  return const CourseDetail(
    course: course,
    subject: CourseSubjectSummary(id: 'subject-1', name: 'Droits'),
    sources: [
      CourseDocument(
        id: 'document-1',
        courseId: 'course-1',
        documentId: 'document-1',
        fileName: 'source.pdf',
        status: CourseDocumentStatus.ready,
      ),
    ],
  );
}

````
