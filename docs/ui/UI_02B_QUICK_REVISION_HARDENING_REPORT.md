# UI-02B — Quick Revision Hardening (Frontend)

## 1. Résumé

UI-02B côté Flutter durcit le quiz quick premium : les visuels QCM sont affichés dans `QuickRevisionQuizFlow`, une session ou action quick course-level déjà terminée ne rouvre plus le quiz et redirige vers le résultat, et les tests couvrent les choix multiples min/max, la conservation des réponses en previous/next, le retry de complétion sans double submit et l'abandon avec confirmation.

Aucun score n'est calculé côté client, aucun score n'est envoyé par le client, aucune fixture production n'a été réintroduite, et aucun deep/exam réel n'a été ajouté. Aucun commit n'a été fait.

## 2. Audit initial

Sources inspectées côté frontend :

- `docs/ui/UI_02_QUICK_REVISION_SESSION_RESULT_REPORT.md`
- `docs/ui/REVISION_PROJECT_UI_TARGET.md`
- `lib/features/revision_sessions/presentation/quick_revision_quiz_flow.dart`
- `lib/presentation/pages/revision_sessions/revision_session_page.dart`
- `lib/presentation/pages/revision_sessions/revision_session_result_page.dart`
- `lib/features/revision_sessions/domain/revision_session.dart`
- `lib/features/revision_sessions/data/http_revision_sessions_api.dart`
- `lib/features/revision_sessions/application/revision_session_controller.dart`
- `lib/features/activities/domain/diagnostic_quiz_activity.dart`
- `lib/presentation/pages/activities/diagnostic_quiz_page.dart`
- `test/features/revision_sessions/revision_session_page_test.dart`
- `test/features/revision_sessions/revision_session_result_page_test.dart`
- `test/features/revision_sessions/http_revision_sessions_api_test.dart`
- `test/app/router/app_router_test.dart`
- `test/app/revision_app_test.dart`
- `test/fakes/in_memory_revision_sessions_api.dart`
- `test/fakes/in_memory_activity_api.dart`

Constats :

- Le parser HTTP revision-session préservait déjà les visuels QCM dans le domaine Flutter.
- `QuickRevisionQuizFlow` n'affichait pas `question.visuals`.
- `RevisionSessionPage` savait lancer le flow premium mais ne redirigeait pas explicitement les sessions quick course-level déjà `COMPLETED`.
- `_premiumQuickActivity` devait être strict : session `STARTED`, mode `quick`, `courseId` présent, action diagnostic `READY`, payload complet et questions non vides.
- Les tests existants couvraient le happy path mais pas multiple choice, retry completion sans re-submit, abandon ou action déjà `COMPLETED`.

## 3. Sub-agents / passes utilisées

- Diagnostic Visuals Agent : identification de la perte d'affichage des visuels entre parser et UI.
- Quick UX Guard Agent : redirection des états terminaux, tests previous/next, retry, abandon.
- QA Agent : suites Flutter ciblées et complète, anti-fixtures, anti-`CourseSource`, `git diff --check`.
- Reviewer Agent : vérification que le client ne calcule pas de score et ne réouvre pas un quiz terminal.

## 4. Problèmes corrigés

- `QuickRevisionQuizFlow` affiche désormais les visuels QCM : chart, diagram, unsupported.
- `RevisionSessionPage` redirige vers la route résultat si la session quick course-level est `COMPLETED` ou si l'action diagnostic est déjà `COMPLETED`.
- `_premiumQuickActivity` refuse les sessions non `STARTED`, les actions non `READY`, les payloads minimaux et les questions vides.
- Le retry de finalisation backend ne réappelle pas `submitResult` si l'activité a déjà été soumise.
- L'abandon demande confirmation et renvoie vers le cours sans submit.

## 5. Contrat visuels QCM

Affichage minimal, volontairement sans nouveau moteur graphique :

- `DiagnosticQuizChartVisual` : carte premium avec titre, description et premières lignes de données compactes.
- `DiagnosticQuizDiagramVisual` : carte premium avec nodes et edges textuels.
- `DiagnosticQuizUnsupportedVisual` : carte sobre `Visuel non pris en charge`.

Aucun HTML/SVG/WebView/rendu arbitraire n'est ajouté.

## 6. Redirection session completed

Si `session.status == completed`, `mode == quick`, et `courseId != null`, la page utilise une navigation de remplacement vers `/revision-sessions/:sessionId/result` via post-frame callback. Même protection pour une action diagnostic déjà `COMPLETED`.

## 7. Tests frontend multiple/retry/abandon

Tests ajoutés dans `revision_session_page_test.dart` :

- visuels QCM affichés et pas de correction pré-submit ;
- session completed redirige vers result ;
- action completed ne rouvre pas le quiz ;
- multiple choice min/max : 0/1 choix ne soumet pas, 2/3 choix soumet, le 4e choix est bloqué ;
- previous/next conserve les réponses ;
- retry completion sans double submit ;
- abandon avec confirmation, `Continuer` reste sur le quiz, `Quitter` retourne au cours.

## 8. Commandes exécutées

- `dart format lib/presentation/pages/revision_sessions/revision_session_page.dart lib/features/revision_sessions/presentation/quick_revision_quiz_flow.dart test/features/revision_sessions/revision_session_page_test.dart` : OK, 3 fichiers formatés dont 1 modifié.
- `dart analyze lib test` : OK, No issues found.
- `flutter test test/features/revision_sessions/revision_session_page_test.dart --reporter compact` : premier passage KO sur action completed, bouton hors viewport et retry hors viewport; corrections appliquées; rerun OK, 15 tests.
- `flutter test test/features/revision_sessions --reporter compact` : OK, 35 tests.
- `flutter test test/features/courses --reporter compact` : OK.
- `flutter test test/app/router/app_router_test.dart --reporter compact` : OK, 19 tests.
- `flutter test test/app/revision_app_test.dart --reporter compact` : OK, 9 tests.
- `flutter test test/app --reporter compact` : OK.
- `flutter test --reporter compact` : OK, 436 tests.
- `rg -n "MvpStudyController\.instance|mvpSubjects|mvpSessionQuestions|courseOrFallback|Loi normale|78%|4/5 bonnes|870|7 jours|🔥 12|💎 870" ... || true` : occurrences uniquement dans assertions négatives de tests.
- `rg -n "CourseSource" lib test || true` : aucune occurrence.
- `git diff --check` : OK, aucune sortie.

## 9. Preuve anti-fixtures

La commande anti-fixtures ne retourne que des assertions `findsNothing` dans les tests. Aucune occurrence runtime dans `lib/app`, `lib/features/courses`, `lib/features/revision_sessions`, `lib/presentation/pages/revision_sessions` ou `lib/presentation/shell`.

## 10. Preuve anti-CourseSource

Commande : `rg -n "CourseSource" lib test || true`.

Résultat : aucune occurrence.

## 11. Limites restantes

- Les visuels restent textuels/compacts; aucun rendu chart avancé n'est introduit.
- La redirection action completed suppose que l'état terminal doit ouvrir le résultat; si le backend renvoie un état contradictoire sans résultat, la page résultat affichera l'erreur backend.
- Les tests widget utilisent un viewport plus haut pour certains CTA afin de tester la logique métier plutôt que le scroll.

## 12. Risques

- Le fallback legacy reste disponible pour payload minimal; il faudra peut-être le supprimer quand tous les contrats quick seront stabilisés.
- Si deep/exam réutilisent ce composant plus tard, il faudra éviter d'étendre `QuickRevisionQuizFlow` au-delà de son rôle single-action.

## 13. Ce qui reste pour deep/exam

- Hub deep/exam réel ;
- session multi-action ;
- résultat multi-action ;
- visuels plus riches si nécessaire ;
- éventuel mapper visuel partagé côté Flutter.

## 14. Auto-review

- Visuels QCM affichés : oui.
- Session completed redirige : oui.
- Action completed ne rouvre pas le quiz : oui.
- Multiple choice min/max testé : oui.
- Previous/next conserve les réponses : oui.
- Retry completion ne re-submit pas : oui.
- Abandon demande confirmation : oui.
- Aucun score client : oui.
- Aucune correction pré-submit : oui.
- Aucun deep/exam : oui.
- Aucune fixture production : oui.
- Aucun `CourseSource` : oui.
- Aucun commit : oui.

## 15. Points discutables du prompt

- Rediriger une action completed vers le résultat côté frontend est pratique, mais un état backend strictement cohérent devrait idéalement renvoyer aussi la session completed.
- Les visuels pourraient vivre dans un composant partagé avec l'ancien `DiagnosticQuizPage`; je suis resté local pour éviter de refactorer l'ancien flow legacy.
- Le fallback legacy pour payload minimal est utile aujourd'hui mais pourrait devenir une porte de sortie trop permissive à terme.
- Les tests widget de CTA longs nécessitent parfois un viewport haut; un test d'intégration mobile réel serait complémentaire.

## 16. Fichiers créés/modifiés/supprimés

Créés :

- `docs/ui/UI_02B_QUICK_REVISION_HARDENING_REPORT.md`

Modifiés :

- `lib/features/revision_sessions/presentation/quick_revision_quiz_flow.dart`
- `lib/presentation/pages/revision_sessions/revision_session_page.dart`
- `test/features/revision_sessions/revision_session_page_test.dart`

Supprimés : aucun.

Note préflight : le repo contenait déjà `ios/ci_scripts/` non suivi; ce lot ne l'a pas modifié.

## 17. Contenu complet des fichiers créés/modifiés/supprimés

Le rapport courant ne s'inclut pas lui-même pour éviter la récursion.

### lib/features/revision_sessions/presentation/quick_revision_quiz_flow.dart

```dart
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
                if (question.visuals.isNotEmpty) ...[
                  const SizedBox(height: RevisionSpacing.m),
                  _QuestionVisualsPreview(visuals: question.visuals),
                ],
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

class _QuestionVisualsPreview extends StatelessWidget {
  const _QuestionVisualsPreview({required this.visuals});

  final List<DiagnosticQuizVisual> visuals;

  @override
  Widget build(BuildContext context) {
    final sorted = [...visuals]
      ..sort((a, b) => a.displayOrder.compareTo(b.displayOrder));

    return Column(
      children: [
        for (final visual in sorted) ...[
          _QuestionVisualPreview(visual: visual),
          if (visual != sorted.last) const SizedBox(height: RevisionSpacing.s),
        ],
      ],
    );
  }
}

class _QuestionVisualPreview extends StatelessWidget {
  const _QuestionVisualPreview({required this.visual});

  final DiagnosticQuizVisual visual;

  @override
  Widget build(BuildContext context) {
    return switch (visual) {
      DiagnosticQuizChartVisual chart => _ChartVisualPreview(chart: chart),
      DiagnosticQuizDiagramVisual diagram => _DiagramVisualPreview(
        diagram: diagram,
      ),
      DiagnosticQuizUnsupportedVisual unsupported => _UnsupportedVisualPreview(
        visual: unsupported,
      ),
    };
  }
}

class _VisualPreviewFrame extends StatelessWidget {
  const _VisualPreviewFrame({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(RevisionSpacing.m),
      decoration: BoxDecoration(
        color: RevisionColors.ink2.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: RevisionColors.border),
      ),
      child: child,
    );
  }
}

class _ChartVisualPreview extends StatelessWidget {
  const _ChartVisualPreview({required this.chart});

  final DiagnosticQuizChartVisual chart;

  @override
  Widget build(BuildContext context) {
    return _VisualPreviewFrame(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(chart.title, style: RevisionTypography.sectionTitle),
          if (chart.description != null) ...[
            const SizedBox(height: RevisionSpacing.xs),
            Text(chart.description!, style: RevisionTypography.caption),
          ],
          const SizedBox(height: RevisionSpacing.s),
          for (final row in chart.data.take(4))
            Text(_compactChartRow(row), style: RevisionTypography.caption),
        ],
      ),
    );
  }
}

class _DiagramVisualPreview extends StatelessWidget {
  const _DiagramVisualPreview({required this.diagram});

  final DiagnosticQuizDiagramVisual diagram;

  @override
  Widget build(BuildContext context) {
    return _VisualPreviewFrame(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(diagram.title, style: RevisionTypography.sectionTitle),
          if (diagram.description != null) ...[
            const SizedBox(height: RevisionSpacing.xs),
            Text(diagram.description!, style: RevisionTypography.caption),
          ],
          const SizedBox(height: RevisionSpacing.s),
          for (final node in diagram.nodes.take(5))
            Text('• ${node.label}', style: RevisionTypography.caption),
          for (final edge in diagram.edges.take(5))
            Text(
              '${edge.from} → ${edge.to}${edge.label == null ? '' : ' · ${edge.label}'}',
              style: RevisionTypography.caption,
            ),
        ],
      ),
    );
  }
}

class _UnsupportedVisualPreview extends StatelessWidget {
  const _UnsupportedVisualPreview({required this.visual});

  final DiagnosticQuizUnsupportedVisual visual;

  @override
  Widget build(BuildContext context) {
    return _VisualPreviewFrame(
      child: Text(
        'Visuel non pris en charge',
        style: RevisionTypography.caption.copyWith(color: RevisionColors.text),
      ),
    );
  }
}

String _compactChartRow(Map<String, Object?> row) {
  return row.entries
      .map((entry) => '${entry.key}: ${entry.value ?? '-'}')
      .join(' · ');
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

```

### lib/presentation/pages/revision_sessions/revision_session_page.dart

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:revision_app/app/router/app_routes.dart';
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

        if (_isCompletedCourseQuickSession(response) ||
            _isCompletedCourseQuickAction(response)) {
          return _CompletedCourseQuickSessionRedirect(response: response);
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
  if (response.session.status != RevisionSessionStatus.started ||
      response.session.mode != RevisionSessionMode.quick ||
      response.session.courseId == null ||
      action?.kind != RevisionSessionActionKind.diagnosticQuiz ||
      action?.status != RevisionSessionActionStatus.ready ||
      payload is! RevisionSessionDiagnosticQuizPayload) {
    return null;
  }

  if (payload.activity.questions.isEmpty) {
    return null;
  }

  return payload.activity;
}

bool _isCompletedCourseQuickSession(RevisionSessionResponse response) {
  return response.session.status == RevisionSessionStatus.completed &&
      response.session.mode == RevisionSessionMode.quick &&
      response.session.courseId != null;
}

bool _isCompletedCourseQuickAction(RevisionSessionResponse response) {
  final action = response.currentAction;
  return response.session.mode == RevisionSessionMode.quick &&
      response.session.courseId != null &&
      action?.kind == RevisionSessionActionKind.diagnosticQuiz &&
      action?.status == RevisionSessionActionStatus.completed;
}

class _CompletedCourseQuickSessionRedirect extends StatefulWidget {
  const _CompletedCourseQuickSessionRedirect({required this.response});

  final RevisionSessionResponse response;

  @override
  State<_CompletedCourseQuickSessionRedirect> createState() =>
      _CompletedCourseQuickSessionRedirectState();
}

class _CompletedCourseQuickSessionRedirectState
    extends State<_CompletedCourseQuickSessionRedirect> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
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
    });
  }

  @override
  Widget build(BuildContext context) {
    return const RevisionPage(
      title: 'Révision terminée',
      subtitle: 'Ouverture du résultat réel.',
      children: [Center(child: CircularProgressIndicator())],
    );
  }
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

```

### test/features/revision_sessions/revision_session_page_test.dart

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:revision_app/app/router/app_routes.dart';
import 'package:revision_app/features/activities/application/activity_controller.dart';
import 'package:revision_app/features/activities/domain/diagnostic_quiz_activity.dart';
import 'package:revision_app/features/courses/application/courses_providers.dart';
import 'package:revision_app/features/courses/domain/course_models.dart';
import 'package:revision_app/features/revision_sessions/application/revision_session_controller.dart';
import 'package:revision_app/features/revision_sessions/domain/revision_session.dart';
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

  testWidgets('course quick session renders diagnostic question visuals', (
    tester,
  ) async {
    final revisionApi = InMemoryRevisionSessionsApi()
      ..loadResponse = _courseQuickRevisionSessionWithVisuals();
    final coursesRepository = InMemoryCoursesRepository()
      ..detailsByCourse['course-1'] = _courseDetail();
    final router = _quickRouter(
      revisionApi: revisionApi,
      activityApi: InMemoryActivityApi(),
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

    expect(find.text('Répartition des pouvoirs'), findsOneWidget);
    expect(find.textContaining('Exécutif'), findsOneWidget);
    expect(find.text('Visuel non pris en charge'), findsOneWidget);
    expect(find.text('correctChoiceId'), findsNothing);
  });

  testWidgets('completed course quick session redirects to result route', (
    tester,
  ) async {
    final revisionApi = InMemoryRevisionSessionsApi()
      ..loadResponse = _completedCourseQuickRevisionSessionResponse();
    final router = _quickRouter(
      revisionApi: revisionApi,
      activityApi: InMemoryActivityApi(),
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          coursesRepositoryProvider.overrideWithValue(
            InMemoryCoursesRepository()
              ..detailsByCourse['course-1'] = _courseDetail(),
          ),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Result route'), findsOneWidget);
    expect(find.text('Quel principe organise les pouvoirs ?'), findsNothing);
  });

  testWidgets('completed quick action does not reopen the premium quiz', (
    tester,
  ) async {
    final revisionApi = InMemoryRevisionSessionsApi()
      ..loadResponse = _courseQuickRevisionSessionWithCompletedAction();
    final router = _quickRouter(
      revisionApi: revisionApi,
      activityApi: InMemoryActivityApi(),
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          coursesRepositoryProvider.overrideWithValue(
            InMemoryCoursesRepository()
              ..detailsByCourse['course-1'] = _courseDetail(),
          ),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Quel principe organise les pouvoirs ?'), findsNothing);
    expect(find.text('Result route'), findsOneWidget);
  });

  testWidgets('multiple choice respects min and max selections', (
    tester,
  ) async {
    _useTallSurface(tester);
    final revisionApi = InMemoryRevisionSessionsApi()
      ..loadResponse = _multipleChoiceQuickRevisionSession();
    final activityApi = InMemoryActivityApi();
    final router = _quickRouter(
      revisionApi: revisionApi,
      activityApi: activityApi,
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          coursesRepositoryProvider.overrideWithValue(
            InMemoryCoursesRepository()
              ..detailsByCourse['course-1'] = _courseDetail(),
          ),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Contrôle parlementaire'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Terminer', skipOffstage: false));
    await tester.tap(find.text('Terminer'), warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(activityApi.submittedDiagnosticQuizCount, 0);

    await tester.tap(find.text('Responsabilité du gouvernement'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Dissolution'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Motion de censure'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Terminer', skipOffstage: false));
    await tester.tap(find.text('Terminer'));
    await tester.pumpAndSettle();

    expect(activityApi.submittedDiagnosticQuizCount, 1);
    expect(activityApi.submittedAnswers, hasLength(1));
    expect(activityApi.submittedAnswers!.single.choiceIds, [
      'choice-a',
      'choice-b',
      'choice-c',
    ]);
    expect(revisionApi.completeCount, 1);
  });

  testWidgets('previous and next keep selected answers before submit', (
    tester,
  ) async {
    final revisionApi = InMemoryRevisionSessionsApi()
      ..loadResponse = courseQuickRevisionSessionResponse();
    final activityApi = InMemoryActivityApi();
    final router = _quickRouter(
      revisionApi: revisionApi,
      activityApi: activityApi,
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          coursesRepositoryProvider.overrideWithValue(
            InMemoryCoursesRepository()
              ..detailsByCourse['course-1'] = _courseDetail(),
          ),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('La séparation des pouvoirs'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Suivant'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Le Parlement'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Précédent'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Suivant'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Terminer'));
    await tester.pumpAndSettle();

    expect(
      activityApi.submittedAnswers
          ?.map((answer) => '${answer.questionId}:${answer.choiceId}')
          .toList(),
      ['question-1:choice-1', 'question-2:choice-3'],
    );
  });

  testWidgets(
    'retry completion does not submit the diagnostic activity twice',
    (tester) async {
      _useTallSurface(tester);
      final revisionApi = InMemoryRevisionSessionsApi()
        ..loadResponse = courseQuickRevisionSessionResponse()
        ..completeError = StateError('complete failed');
      final activityApi = InMemoryActivityApi();
      final router = _quickRouter(
        revisionApi: revisionApi,
        activityApi: activityApi,
      );
      addTearDown(router.dispose);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            coursesRepositoryProvider.overrideWithValue(
              InMemoryCoursesRepository()
                ..detailsByCourse['course-1'] = _courseDetail(),
            ),
          ],
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('La séparation des pouvoirs'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Suivant'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Le Parlement'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Terminer'));
      await tester.pumpAndSettle();

      expect(activityApi.submittedDiagnosticQuizCount, 1);
      expect(revisionApi.completeCount, 1);
      expect(find.text('Finaliser la session'), findsOneWidget);

      revisionApi.completeError = null;
      await tester.ensureVisible(
        find.text('Finaliser la session', skipOffstage: false),
      );
      await tester.tap(find.text('Finaliser la session'));
      await tester.pumpAndSettle();

      expect(activityApi.submittedDiagnosticQuizCount, 1);
      expect(revisionApi.completeCount, 2);
      expect(find.text('Result route'), findsOneWidget);
    },
  );

  testWidgets('back button asks for confirmation before abandoning the quiz', (
    tester,
  ) async {
    final revisionApi = InMemoryRevisionSessionsApi()
      ..loadResponse = courseQuickRevisionSessionResponse();
    final activityApi = InMemoryActivityApi();
    final router = _quickRouter(
      revisionApi: revisionApi,
      activityApi: activityApi,
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          coursesRepositoryProvider.overrideWithValue(
            InMemoryCoursesRepository()
              ..detailsByCourse['course-1'] = _courseDetail(),
          ),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.arrow_back_rounded).first);
    await tester.pumpAndSettle();

    expect(find.text('Quitter la session ?'), findsOneWidget);

    await tester.tap(find.widgetWithText(TextButton, 'Continuer'));
    await tester.pumpAndSettle();

    expect(find.text('Quel principe organise les pouvoirs ?'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_back_rounded).first);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Quitter'));
    await tester.pumpAndSettle();

    expect(find.text('Course route'), findsOneWidget);
    expect(activityApi.submittedDiagnosticQuizCount, 0);
    expect(revisionApi.completeCount, 0);
  });
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

void _useTallSurface(WidgetTester tester) {
  tester.view.physicalSize = const Size(900, 1200);
  tester.view.devicePixelRatio = 1;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
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

GoRouter _quickRouter({
  required InMemoryRevisionSessionsApi revisionApi,
  required InMemoryActivityApi activityApi,
}) {
  return GoRouter(
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
}

RevisionSessionResponse _courseQuickRevisionSessionWithVisuals() {
  final base = courseQuickRevisionSessionResponse();
  return RevisionSessionResponse(
    session: base.session,
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
              visuals: [
                DiagnosticQuizChartVisual(
                  id: 'visual-1',
                  displayOrder: 0,
                  chartType: DiagnosticQuizChartType.bar,
                  title: 'Répartition des pouvoirs',
                  description: 'Lecture synthétique du cours.',
                  xKey: 'branche',
                  yKeys: ['poids'],
                  data: [
                    {'branche': 'Exécutif', 'poids': 2},
                    {'branche': 'Législatif', 'poids': 3},
                  ],
                ),
                DiagnosticQuizUnsupportedVisual(
                  id: 'visual-2',
                  displayOrder: 1,
                  type: 'MAP',
                ),
              ],
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
          ],
        ),
      ),
    ),
    history: base.history,
  );
}

RevisionSessionResponse _completedCourseQuickRevisionSessionResponse() {
  final base = courseQuickRevisionSessionResponse();
  return RevisionSessionResponse(
    session: RevisionSession(
      id: base.session.id,
      status: RevisionSessionStatus.completed,
      mode: RevisionSessionMode.quick,
      subjectId: base.session.subjectId,
      courseId: base.session.courseId,
      documentId: base.session.documentId,
      knowledgeUnitId: base.session.knowledgeUnitId,
      createdAt: base.session.createdAt,
      completedAt: DateTime.parse('2026-06-15T12:04:12.000Z'),
    ),
    currentAction: base.currentAction,
    history: base.history,
  );
}

RevisionSessionResponse _courseQuickRevisionSessionWithCompletedAction() {
  final base = courseQuickRevisionSessionResponse();
  return RevisionSessionResponse(
    session: base.session,
    currentAction: RevisionSessionAction(
      id: base.currentAction!.id,
      kind: base.currentAction!.kind,
      status: RevisionSessionActionStatus.completed,
      displayOrder: base.currentAction!.displayOrder,
      activitySessionId: base.currentAction!.activitySessionId,
      documentId: base.currentAction!.documentId,
      knowledgeUnitId: base.currentAction!.knowledgeUnitId,
      payload: base.currentAction!.payload,
    ),
    history: base.history,
  );
}

RevisionSessionResponse _multipleChoiceQuickRevisionSession() {
  final base = courseQuickRevisionSessionResponse();
  return RevisionSessionResponse(
    session: base.session,
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
              id: 'question-multiple',
              prompt: 'Quels mécanismes relèvent du contrôle parlementaire ?',
              knowledgeUnitId: 'unit-1',
              selectionMode: DiagnosticQuizSelectionMode.multiple,
              minSelections: 2,
              maxSelections: 3,
              choices: [
                DiagnosticQuizChoice(
                  id: 'choice-a',
                  label: 'Contrôle parlementaire',
                ),
                DiagnosticQuizChoice(
                  id: 'choice-b',
                  label: 'Responsabilité du gouvernement',
                ),
                DiagnosticQuizChoice(id: 'choice-c', label: 'Dissolution'),
                DiagnosticQuizChoice(
                  id: 'choice-d',
                  label: 'Motion de censure',
                ),
              ],
            ),
          ],
        ),
      ),
    ),
    history: base.history,
  );
}

```
