# UI-01 — Premium visual foundation + Home/Course/Sheet/Progress redesign

## 1. Résumé
UI-01 transforme les écrans Core principaux en direction visuelle premium sombre, proche des mockups fournis, sans réintroduire de données fictives. Les pages Accueil, Détail cours, Fiche, Progrès, Hub Révisions, la bottom navigation et les composants partagés ont été retravaillés. Après les captures utilisateur, un bug critique de navigation a aussi été corrigé : les routes de détail utilisent désormais une stack `push`/`pop` au lieu de recréer des entrées via `go`.

## 2. Audit initial
- Le design system contenait déjà des tokens couleur/spacing/typographie et des composants MVP (`RevisionGlassCard`, `RevisionMasteryRing`, `RevisionProgressLine`, états loading/error/empty).
- Les pages Core étaient déjà branchées sur les vraies données : subjects, courses, course detail, sources, sheet, progress, quick revision.
- Les écrans restaient trop utilitaires : accueil sans vraie hero, détail trop vertical, sources inline, fiche en empilement texte, progrès fonctionnel mais peu premium.
- Les références visuelles contiennent des métriques non disponibles (`12`, `870`, `7 jours`, `78%`) : elles ont été explicitement exclues du runtime réel.
- Marionette n’était pas disponible dans ce repo. L’exemple Grimaldi a été inspecté, mais l’intégrer aurait nécessité des dev_dependencies et un entrypoint dédié ; le bug de navigation a été verrouillé par tests GoRouter à la place.

## 3. Sub-agents / passes
- Design Audit Agent : inspection des composants existants, des pages Core et des écarts visuels.
- Design System Agent : extraction de composants premium partagés et thème matière.
- Feature UI Agent : application aux pages Home, Detail, Sheet, Progress et Revisions.
- QA Agent : validations ciblées, suite complète, anti-fixtures, anti-CourseSource.
- Reviewer Agent : correction de la navigation après captures utilisateur et ajout de tests de stack.

## 4. Références visuelles interprétées
- Accueil : matière active en pill, hero reprendre le cours, cartes de cours plus riches, navigation flottante.
- Détail : top bar avec actions, hero cours, stats triplet, progression réelle et modes distincts.
- Sources : bottom sheet avec cartes PDF et bouton `+` flottant.
- Fiche : tabs `Rapide / Complète / Examen`, cartes de sections, aucun contenu inventé.
- Progrès : ring principal, carte globale, cartes de cours et section “À surveiller” basée sur états réels.
- Révisions : trois modes visuels, rapide seulement si un cours prêt existe, deep/exam désactivés MVP+.

## 5. Modifications design system
- Ajout d’un thème visuel matière `RevisionSubjectVisualTheme`, utilisé uniquement pour la présentation.
- Extension des composants premium : header action pill, metric pill, bottom sheet frame, section card, mode card enrichie, source card enrichie.
- Bottom navigation rendue plus flottante/glass, avec rail responsive cohérent.
- Correction d’overflow potentiel dans les cartes de cours via ellipsis/flexible sur labels longs.

## 6. Modifications pages
- `CoursesHomePage` : accueil centré sur matière active, hero reprendre le cours, création cours en sheet premium, cartes cours riches.
- `CourseDetailPage` : top bar, fiche/sources, hero cours, stats strip, progression réelle premium, modes quick/deep/exam, sources en bottom sheet.
- `CourseRevisionSheetPage` : tabs rapides/complète/examen, rapide réel, modes non disponibles honnêtes.
- `SubjectProgressPage` : carte globale avec ring, métriques, cartes cours, section à surveiller.
- `RevisionsPendingPage` : hub visuel, quick actif si donnée réelle, deep/exam MVP+.
- `RevisionNavigation` : bottom nav/rail premium.

## 7. Correction navigation critique
Les captures utilisateur ont mis en évidence une peur légitime : le retour semblait recréer/avancer une page au lieu de dépiler. Audit fait : plusieurs entrées de détail utilisaient `context.go(...)`, adapté aux racines/onglets mais pas aux écrans empilés.

Décision :
- ouvrir les détails depuis Home/Progress/Révisions avec `context.push(...)` ;
- ouvrir la fiche depuis détail avec `context.push(...)` ;
- revenir depuis détail/fiche avec `_popOrGo(...)` : `pop` si possible, fallback `go` pour deep link direct ;
- conserver `go` pour les onglets/racines et certains CTA de retour global.

Tests ajoutés :
- détail cours : `push` -> bouton retour -> stack dépilée, `canPop == false` à l’accueil ;
- fiche cours : `push detail` -> `push sheet` -> retour fiche vers détail -> retour détail vers accueil sans duplication.

## 8. Comparaison visuelle avec captures utilisateur
Captures utilisateur analysées :
- `/Users/karim/Desktop/Screenshot 2026-06-19 at 12.36.31.png` : accueil avec matière active, hero et cartes cours.
- `/var/folders/b5/7gsfwzyd449_54n8l40h40gc0000gn/T/TemporaryItems/NSIRD_screencaptureui_7qM8zj/Screenshot 2026-06-19 at 12.36.39.png` : sheet choix matière.
- `/var/folders/b5/7gsfwzyd449_54n8l40h40gc0000gn/T/TemporaryItems/NSIRD_screencaptureui_wTpBdQ/Screenshot 2026-06-19 at 12.36.57.png` : progrès.
- `/var/folders/b5/7gsfwzyd449_54n8l40h40gc0000gn/T/TemporaryItems/NSIRD_screencaptureui_Jl6498/Screenshot 2026-06-19 at 12.37.02.png` : hub révisions.
- `/var/folders/b5/7gsfwzyd449_54n8l40h40gc0000gn/T/TemporaryItems/NSIRD_screencaptureui_rC4NUD/Screenshot 2026-06-19 at 12.37.06.png` : sources globales.
- `/var/folders/b5/7gsfwzyd449_54n8l40h40gc0000gn/T/TemporaryItems/NSIRD_screencaptureui_Wio63a/Screenshot 2026-06-19 at 12.37.16.png` : détail cours.
- `/var/folders/b5/7gsfwzyd449_54n8l40h40gc0000gn/T/TemporaryItems/NSIRD_screencaptureui_Uxezxs/Screenshot 2026-06-19 at 12.37.22.png` : erreur quick visible.

Ressemblances obtenues : accueil beaucoup plus proche des mockups, hero visible, nav flottante, détail avec stats strip et actions, hub révisions coloré, progrès avec ring et cartes.
Écarts restants : pas de gamification réelle, pas de vrai résultat session final, page Sources globale encore informative, progression moins dense que le mockup faute de modèle “weak points” avancé.
Compromis : aucune valeur fictive n’a été copiée depuis les mockups. Les slots streak/gems restent vides tant que le produit n’a pas de données réelles.
Reporté à UI-02 : session de révision premium, résultat session, flow révision complet visuel.

## 9. Tests ajoutés/modifiés
- Tests course detail ajustés pour bottom sheet sources, upload/delete, quick revision, anti-fixtures.
- Tests app/router renforcés pour stack detail/sheet et absence de fallback fixture.
- Tests app ajustés sur nouvelle UI premium réelle.

## 10. Commandes exécutées
```bash
dart format lib/features/courses/presentation/course_detail_page.dart lib/features/courses/presentation/course_revision_sheet_page.dart lib/features/courses/presentation/subject_progress_page.dart lib/features/courses/presentation/revisions_pending_page.dart test/app/router/app_router_test.dart
flutter test test/app/router/app_router_test.dart --reporter compact
dart analyze lib test
flutter test test/features/courses --reporter compact
flutter test test/features/revision_sessions --reporter compact
flutter test test/app/revision_app_test.dart --reporter compact
flutter test test/app --reporter compact
flutter test --reporter compact
rg -n "MvpStudyController\.instance|mvpSubjects|mvpSessionQuestions|courseOrFallback|Loi normale|78%|4/5 bonnes|870|7 jours|🔥 12|💎 870" lib/app lib/features/courses lib/presentation/shell test/app test/features/courses || true
rg -n "CourseSource" lib/features/courses test/features/courses test/fakes test/app || true
git diff --check
```

Résultats :
- `dart analyze lib test` : OK, no issues found.
- `flutter test test/app/router/app_router_test.dart --reporter compact` : OK, 19 tests passed après correction navigation.
- `flutter test test/features/courses --reporter compact` : OK après relance séquentielle.
- `flutter test test/features/revision_sessions --reporter compact` : OK.
- `flutter test test/app/revision_app_test.dart --reporter compact` : OK.
- `flutter test test/app --reporter compact` : OK.
- `flutter test --reporter compact` : OK, 421 tests passed.
- `git diff --check` : OK, aucune sortie.

Note : un premier lancement parallèle de `flutter test test/features/courses` avec une autre commande Flutter a provoqué un crash outil `PathExistsException` dans `macos/Flutter/ephemeral/Packages/.packages/audioplayers_darwin-6.4.0`. Relancé séquentiellement, le test est passé. Aucun code applicatif n’était en cause.

## 11. Preuve anti-fixtures
Le grep anti-fixtures ne retourne que des assertions `findsNothing` dans les tests. Aucune occurrence runtime dans `lib/app`, `lib/features/courses` ou `lib/presentation/shell`.

## 12. Preuve anti-CourseSource
`rg -n "CourseSource" lib/features/courses test/features/courses test/fakes test/app || true` ne retourne aucune occurrence.

## 13. Préflight Git
- Branche : `main`
- Status au moment du rapport :
```text
M lib/features/courses/presentation/course_detail_page.dart
 M lib/features/courses/presentation/course_revision_sheet_page.dart
 M lib/features/courses/presentation/courses_home_page.dart
 M lib/features/courses/presentation/revisions_pending_page.dart
 M lib/features/courses/presentation/subject_progress_page.dart
 M lib/presentation/design_system/components/revision_mvp_components.dart
 M lib/presentation/widgets/revision_navigation.dart
 M test/app/revision_app_test.dart
 M test/app/router/app_router_test.dart
 M test/features/courses/course_detail_page_test.dart
?? docs/ui/
?? lib/presentation/design_system/tokens/revision_subject_visuals.dart
```
- Derniers commits :
```text
56b9f85 CORE-06C: Ajout du rapport d'alignement backend et suppression des sources durcies
6f8cda1 CORE-06B: Correction de la cohérence de rafraîchissement de la progression et runbook d'acceptance
a8934a9 Add course source deletion UI
```
- Aucun commit, amend, merge, rebase, push ou tag effectué.

## 14. Fichiers créés/modifiés/supprimés
Créés :
- `docs/ui/REVISION_PROJECT_UI_TARGET.md`
- `docs/ui/UI_01_PREMIUM_VISUAL_FOUNDATION_REPORT.md`
- `lib/presentation/design_system/tokens/revision_subject_visuals.dart`

Modifiés :
- `lib/presentation/design_system/components/revision_mvp_components.dart`
- `lib/presentation/widgets/revision_navigation.dart`
- `lib/features/courses/presentation/courses_home_page.dart`
- `lib/features/courses/presentation/course_detail_page.dart`
- `lib/features/courses/presentation/course_revision_sheet_page.dart`
- `lib/features/courses/presentation/subject_progress_page.dart`
- `lib/features/courses/presentation/revisions_pending_page.dart`
- `test/app/revision_app_test.dart`
- `test/app/router/app_router_test.dart`
- `test/features/courses/course_detail_page_test.dart`

Supprimés : aucun.

Diff stat :
```text
.../courses/presentation/course_detail_page.dart   | 777 ++++++++++++---------
 .../presentation/course_revision_sheet_page.dart   | 177 +++--
 .../courses/presentation/courses_home_page.dart    | 457 ++++++------
 .../presentation/revisions_pending_page.dart       | 191 +++--
 .../presentation/subject_progress_page.dart        | 175 +++--
 .../components/revision_mvp_components.dart        | 314 ++++++++-
 lib/presentation/widgets/revision_navigation.dart  |  97 ++-
 test/app/revision_app_test.dart                    |  12 +-
 test/app/router/app_router_test.dart               | 154 +++-
 test/features/courses/course_detail_page_test.dart |  95 ++-
 10 files changed, 1597 insertions(+), 852 deletions(-)
```

## 15. Limites
- Les écrans session/résultat ne sont pas redesinés dans UI-01.
- Les métriques gamifiées restent absentes, volontairement.
- La page Sources globale reste informative.
- Les points faibles sont approximés avec les états de progression disponibles, pas avec un modèle pédagogique dédié.
- Marionette n’a pas été intégré pour éviter d’ajouter des dépendances dev et un entrypoint hors périmètre UI-01.

## 16. Risques
- Certains écrans sont visuellement plus riches mais peuvent nécessiter une passe responsive fine sur petits appareils très contraints.
- La navigation impérative `push` dans un `StatefulShellRoute` est désormais testée côté stack, mais un vrai harnais Marionette serait utile dans un lot QA mobile dédié.
- Le hub Révisions ouvre le cours prêt au lieu de démarrer directement la session, par prudence produit.

## 17. Ce qui reste pour UI-02
- Redesign de la session de révision.
- Redesign du résultat de session réel quand le contrat produit est disponible.
- Animations fines et transitions.
- Accessibilité visuelle plus poussée sur les modes/tabs.
- Éventuelle intégration Marionette dev-only si le projet choisit d’ajouter les dépendances.

## 18. Auto-review
- Direction visuelle plus proche des mockups : oui.
- Home redesigned : oui.
- Course detail redesigned : oui.
- Sources bottom sheet premium : oui.
- Course sheet redesigned : oui.
- Progress page redesigned : oui.
- Hub Révisions traité de façon bornée : oui.
- Deep/exam non implémentés : oui, désactivés MVP+.
- Aucun backend modifié : oui.
- Pas de fake `12`, `870`, `7 jours`, `78%` : oui.
- Pas de `CourseSource` : oui.
- Navigation stack corrigée : oui, tests ajoutés.
- Tests verts : oui.
- Aucun commit réalisé : oui.

## 19. Points discutables du prompt
- UI-01 couvre beaucoup d’écrans ; le scope est large, mais les changements restent front-only et bornés aux pages Core.
- Le hub Révisions aurait pu attendre UI-02 ; il a été traité minimalement parce que le rendu précédent était encore trop explicatif.
- Les mockups incluent des données non disponibles ; elles ont été ignorées plutôt que simulées.
- Un vrai setup Marionette serait utile, mais l’ajouter ici aurait violé l’esprit “pas de dépendance / pas de scope creep”.
- La page Sources globale pourrait rester très sobre jusqu’à une vraie API catalogue.

## 20. Contenu complet des fichiers créés/modifiés/supprimés
Le rapport courant n’est pas inclus dans lui-même pour éviter une récursion infinie.

### `docs/ui/REVISION_PROJECT_UI_TARGET.md`
~~~md
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

## Hors scope UI-01

À reporter :

- écran session de révision premium ;
- résultat session final ;
- deep revision réelle ;
- préparation examen réelle ;
- gamification réelle ;
- catalogue global de sources ;
- points faibles avancés.


~~~

### `lib/presentation/design_system/tokens/revision_subject_visuals.dart`
~~~dart
import 'package:flutter/material.dart';

import 'revision_colors.dart';

class RevisionSubjectVisualTheme {
  const RevisionSubjectVisualTheme({
    required this.accent,
    required this.secondary,
    required this.icon,
  });

  final Color accent;
  final Color secondary;
  final IconData icon;

  LinearGradient get gradient => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accent, secondary],
  );
}

RevisionSubjectVisualTheme revisionSubjectVisualThemeFor(String label) {
  final normalized = label.toLowerCase();

  // The label is used only as a real-data visual hint. It must never create a
  // fake subject, course, score, streak, or any other production content.
  if (normalized.contains('philo')) {
    return const RevisionSubjectVisualTheme(
      accent: RevisionColors.pink,
      secondary: RevisionColors.pinkDeep,
      icon: Icons.psychology_alt_rounded,
    );
  }

  if (normalized.contains('droit') || normalized.contains('jurid')) {
    return const RevisionSubjectVisualTheme(
      accent: RevisionColors.violet,
      secondary: RevisionColors.blueDeep,
      icon: Icons.account_balance_rounded,
    );
  }

  if (normalized.contains('stat') ||
      normalized.contains('math') ||
      normalized.contains('prob')) {
    return const RevisionSubjectVisualTheme(
      accent: RevisionColors.blue,
      secondary: RevisionColors.cyan,
      icon: Icons.functions_rounded,
    );
  }

  if (normalized.contains('eco') || normalized.contains('finance')) {
    return const RevisionSubjectVisualTheme(
      accent: RevisionColors.mint,
      secondary: RevisionColors.green,
      icon: Icons.trending_up_rounded,
    );
  }

  return const RevisionSubjectVisualTheme(
    accent: RevisionColors.blue,
    secondary: RevisionColors.violet,
    icon: Icons.auto_stories_outlined,
  );
}

~~~

### `lib/presentation/design_system/components/revision_mvp_components.dart`
~~~dart
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
    this.padding = const EdgeInsets.fromLTRB(
      RevisionSpacing.pageX,
      RevisionSpacing.pageTop,
      RevisionSpacing.pageX,
      110,
    ),
    this.maxWidth = 520,
    super.key,
  });

  final List<Widget> children;
  final EdgeInsetsGeometry padding;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: padding,
              sliver: SliverList.list(
                children: [
                  for (final child in children) ...[
                    child,
                    if (child != children.last)
                      const SizedBox(height: RevisionSpacing.l),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
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
    super.key,
  });

  final String title;
  final String subtitle;
  final String progressLabel;
  final double progress;
  final Color accent;
  final IconData icon;
  final VoidCallback onContinue;

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
                      child: RevisionProgressLine(
                        value: progress,
                        color: RevisionColors.cyan,
                      ),
                    ),
                    const SizedBox(width: RevisionSpacing.s),
                    Text(
                      progressLabel,
                      style: RevisionTypography.caption.copyWith(
                        color: RevisionColors.text,
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
            child: const Text(
              'Continuer',
              style: TextStyle(fontWeight: FontWeight.w900),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: RevisionTypography.sectionTitle),
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
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.schedule_rounded,
                color: RevisionColors.textMuted,
                size: 15,
              ),
              const SizedBox(width: RevisionSpacing.xs),
              Text(durationLabel, style: RevisionTypography.caption),
            ],
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

class RevisionConfettiStrip extends StatelessWidget {
  const RevisionConfettiStrip({super.key});

  @override
  Widget build(BuildContext context) {
    const colors = [
      RevisionColors.blue,
      RevisionColors.green,
      RevisionColors.pink,
      RevisionColors.amber,
      RevisionColors.violet,
      RevisionColors.mint,
    ];

    return SizedBox(
      height: 36,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          for (var index = 0; index < 18; index++)
            Transform.rotate(
              angle: (index % 5 - 2) * math.pi / 8,
              child: Container(
                width: index.isEven ? 4 : 3,
                height: index.isEven ? 8 : 6,
                decoration: BoxDecoration(
                  color: colors[index % colors.length],
                  borderRadius: RevisionRadius.radiusS,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

~~~

### `lib/presentation/widgets/revision_navigation.dart`
~~~dart
import 'package:flutter/material.dart';

import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../design_system/tokens/revision_colors.dart';
import '../design_system/tokens/revision_shadows.dart';

class RevisionNavigationDestination {
  const RevisionNavigationDestination({
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
}

class RevisionBottomNavigation extends StatelessWidget {
  const RevisionBottomNavigation({
    required this.destinations,
    required this.selectedIndex,
    required this.onDestinationSelected,
    super.key,
  });

  final List<RevisionNavigationDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: RevisionColors.glassStrong,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: RevisionColors.borderBright),
            boxShadow: RevisionShadows.nav,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.s,
              vertical: AppSpacing.s,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                for (var index = 0; index < destinations.length; index++)
                  Expanded(
                    child: _NavigationItem(
                      destination: destinations[index],
                      isSelected: selectedIndex == index,
                      onTap: () => onDestinationSelected(index),
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

class RevisionNavigationRail extends StatelessWidget {
  const RevisionNavigationRail({
    required this.destinations,
    required this.selectedIndex,
    required this.onDestinationSelected,
    super.key,
  });

  final List<RevisionNavigationDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.l),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: RevisionColors.glassStrong,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: RevisionColors.borderBright),
          boxShadow: RevisionShadows.nav,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.s,
            vertical: AppSpacing.l,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var index = 0; index < destinations.length; index++) ...[
                _NavigationItem(
                  destination: destinations[index],
                  isSelected: selectedIndex == index,
                  onTap: () => onDestinationSelected(index),
                  isRail: true,
                ),
                if (index != destinations.length - 1)
                  const SizedBox(height: AppSpacing.s),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _NavigationItem extends StatelessWidget {
  const _NavigationItem({
    required this.destination,
    required this.isSelected,
    required this.onTap,
    this.isRail = false,
  });

  final RevisionNavigationDestination destination;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isRail;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const activeColor = RevisionColors.blue;
    final inactiveColor = theme.colorScheme.onSurface.withValues(alpha: 0.58);
    final foreground = isSelected ? activeColor : inactiveColor;

    final content = AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: EdgeInsets.symmetric(
        horizontal: isRail ? AppSpacing.l : AppSpacing.s,
        vertical: AppSpacing.s,
      ),
      decoration: BoxDecoration(
        gradient: isSelected
            ? LinearGradient(
                colors: [
                  activeColor.withValues(alpha: 0.26),
                  RevisionColors.blueDeep.withValues(alpha: 0.18),
                ],
              )
            : null,
        borderRadius: AppRadius.radiusPill,
        boxShadow: isSelected ? RevisionShadows.soft(activeColor) : null,
      ),
      child: isRail
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _NavigationIcon(
                  icon: isSelected
                      ? destination.selectedIcon
                      : destination.icon,
                  color: foreground,
                  glow: isSelected,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  destination.label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: foreground,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ],
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _NavigationIcon(
                  icon: isSelected
                      ? destination.selectedIcon
                      : destination.icon,
                  color: foreground,
                  glow: isSelected,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  destination.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: foreground,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ],
            ),
    );

    return Semantics(
      selected: isSelected,
      button: true,
      label: destination.label,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: content,
      ),
    );
  }
}

class _NavigationIcon extends StatelessWidget {
  const _NavigationIcon({
    required this.icon,
    required this.color,
    required this.glow,
  });

  final IconData icon;
  final Color color;
  final bool glow;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          if (glow)
            BoxShadow(
              color: RevisionColors.blue.withValues(alpha: 0.38),
              blurRadius: 18,
              spreadRadius: 1,
            ),
        ],
      ),
      child: Icon(icon, color: color, size: 22),
    );
  }
}

~~~

### `lib/features/courses/presentation/courses_home_page.dart`
~~~dart
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

class CoursesHomePage extends ConsumerWidget {
  const CoursesHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subjects = ref.watch(subjectsNotifierProvider);
    final notifier = ref.read(subjectsNotifierProvider.notifier);

    return RevisionPageScaffold(
      children: [
        subjects.when(
          loading: () =>
              const RevisionLoadingState(label: 'Chargement des matières'),
          error: (error, stackTrace) => RevisionErrorState(
            title: 'Impossible de charger les matières',
            message:
                'Vérifie la connexion puis réessaie. Aucun cours fictif ne sera affiché.',
            actionLabel: 'Réessayer',
            onAction: notifier.reload,
          ),
          data: (subjects) => _CoursesHomeContent(subjects: subjects),
        ),
      ],
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
        title: 'Aucune matière réelle',
        message:
            'Crée une matière pour construire tes cours, ajouter tes PDF et suivre ta progression.',
        icon: Icons.school_outlined,
        actionLabel: 'Ouvrir les matières',
        onAction: () => context.go(AppRoutes.subjects),
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
        courses.when(
          loading: () =>
              const RevisionLoadingState(label: 'Chargement des cours'),
          error: (error, stackTrace) => RevisionErrorState(
            title: 'Impossible de charger les cours',
            message:
                'Aucun cours fictif ne sera affiché. Vérifie la connexion puis réessaie.',
            actionLabel: 'Réessayer',
            onAction: () => ref.invalidate(coursesProvider(activeSubject.id)),
          ),
          data: (courses) => _CourseList(
            subject: activeSubject,
            visual: visual,
            courses: courses,
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
          onTap: () => _showSubjectPicker(context, ref, subjects, subject.id),
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

class _CourseList extends StatelessWidget {
  const _CourseList({
    required this.subject,
    required this.visual,
    required this.courses,
  });

  final Subject subject;
  final RevisionSubjectVisualTheme visual;
  final List<CourseListItem> courses;

  @override
  Widget build(BuildContext context) {
    if (courses.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RevisionEmptyState(
            title: 'Aucun cours réel',
            message:
                'Crée un cours, ajoute une source PDF, puis reviens ici pour reprendre ton apprentissage.',
            icon: Icons.layers_outlined,
            actionLabel: 'Créer un cours',
            onAction: () => _showCreateCourseSheet(context, subject),
          ),
          const SizedBox(height: RevisionSpacing.l),
          _CourseCreationHint(subject: subject, visual: visual),
        ],
      );
    }

    final resumeCourse = courses.first;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RevisionResumeCourseCard(
          title: resumeCourse.title,
          subtitle: 'Reprendre le cours',
          progressLabel: _courseProgressLabel(resumeCourse),
          progress: _courseProgressValue(resumeCourse),
          accent: visual.accent,
          icon: visual.icon,
          onContinue: () => context.push(AppRoutes.course(resumeCourse.id)),
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
        for (final course in courses) ...[
          RevisionCourseCard(
            title: course.title,
            progressLabel: _courseProgressLabel(course),
            durationLabel: _courseMeta(course),
            progress: _courseProgressValue(course),
            accent: visual.accent,
            icon: visual.icon,
            onTap: () => context.push(AppRoutes.course(course.id)),
          ),
          const SizedBox(height: RevisionSpacing.m),
        ],
      ],
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

Subject _activeSubject(List<Subject> subjects, String? activeSubjectId) {
  for (final subject in subjects) {
    if (subject.id == activeSubjectId) {
      return subject;
    }
  }

  return subjects.first;
}

void _showSubjectPicker(
  BuildContext context,
  WidgetRef ref,
  List<Subject> subjects,
  String activeSubjectId,
) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (context) => RevisionBottomSheetFrame(
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
      ],
    ),
  );
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

~~~

### `lib/features/courses/presentation/course_detail_page.dart`
~~~dart
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

      context.go(AppRoutes.revisionSession(sessionId: response.session.id));
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

~~~

### `lib/features/courses/presentation/course_revision_sheet_page.dart`
~~~dart
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

class CourseRevisionSheetPage extends ConsumerStatefulWidget {
  const CourseRevisionSheetPage({required this.courseId, super.key});

  final String courseId;

  @override
  ConsumerState<CourseRevisionSheetPage> createState() =>
      _CourseRevisionSheetPageState();
}

class _CourseRevisionSheetPageState
    extends ConsumerState<CourseRevisionSheetPage> {
  _SheetMode _mode = _SheetMode.fast;

  @override
  Widget build(BuildContext context) {
    final sheet = ref.watch(courseRevisionSheetProvider(widget.courseId));

    return RevisionPageScaffold(
      children: [
        Row(
          children: [
            IconButton(
              tooltip: 'Retour au cours',
              onPressed: () =>
                  _popOrGo(context, AppRoutes.course(widget.courseId)),
              icon: const Icon(Icons.arrow_back_rounded),
            ),
            const Spacer(),
            RevisionHeaderActionPill(
              label: 'Sources',
              icon: Icons.description_outlined,
              onTap: () => _popOrGo(context, AppRoutes.course(widget.courseId)),
            ),
          ],
        ),
        RevisionSegmentedControl<_SheetMode>(
          values: _SheetMode.values,
          selected: _mode,
          labelOf: _sheetModeLabel,
          onChanged: (mode) => setState(() => _mode = mode),
        ),
        sheet.when(
          loading: () =>
              const RevisionLoadingState(label: 'Chargement de la fiche'),
          error: (error, stackTrace) =>
              _SheetErrorState(error: error, courseId: widget.courseId),
          data: (sheet) {
            if (sheet == null) {
              return _GenerateSheetCard(courseId: widget.courseId);
            }

            if (_mode != _SheetMode.fast) {
              return RevisionEmptyState(
                title: '${_sheetModeLabel(_mode)} bientôt',
                message:
                    'Ce format de fiche est prévu plus tard. Le contenu rapide ci-dessus reste le format réel disponible aujourd’hui.',
                icon: Icons.lock_outline_rounded,
              );
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
          // renders a domain-specific message if the backend rejected it.
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
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              RevisionColors.blue.withValues(alpha: 0.30),
              RevisionColors.glassStrong,
            ],
          ),
          borderColor: RevisionColors.blue.withValues(alpha: 0.32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const RevisionIconTile(
                    icon: Icons.article_rounded,
                    accent: RevisionColors.blue,
                    size: 36,
                    iconSize: 20,
                  ),
                  const SizedBox(width: RevisionSpacing.s),
                  Text('Fiche de cours', style: RevisionTypography.caption),
                ],
              ),
              const SizedBox(height: RevisionSpacing.m),
              Text(sheet.title, style: RevisionTypography.pageTitle),
            ],
          ),
        ),
        if (sheet.introduction != null)
          RevisionSheetSectionCard(
            title: 'Résumé',
            icon: Icons.summarize_rounded,
            accent: RevisionColors.blue,
            children: [
              Text(sheet.introduction!, style: RevisionTypography.body),
            ],
          ),
        if (sheet.keyPoints.isNotEmpty)
          _TextListCard(
            title: 'Points clés',
            icon: Icons.check_circle_rounded,
            accent: RevisionColors.green,
            items: sheet.keyPoints,
          ),
        if (sheet.commonMistakes.isNotEmpty)
          _TextListCard(
            title: 'Pièges fréquents',
            icon: Icons.warning_amber_rounded,
            accent: RevisionColors.coral,
            items: sheet.commonMistakes,
          ),
        if (sheet.mustKnow.isNotEmpty)
          _TextListCard(
            title: 'À connaître',
            icon: Icons.school_rounded,
            accent: RevisionColors.violet,
            items: sheet.mustKnow,
          ),
        for (final section in sheet.sections) _SectionCard(section: section),
        if (sheet.practiceSuggestions.isNotEmpty)
          _TextListCard(
            title: 'S’entraîner',
            icon: Icons.fitness_center_rounded,
            accent: RevisionColors.pink,
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
    required this.accent,
    required this.items,
  });

  final String title;
  final IconData icon;
  final Color accent;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return RevisionSheetSectionCard(
      title: title,
      icon: icon,
      accent: accent,
      children: [
        for (final item in items)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('•', style: RevisionTypography.body.copyWith(color: accent)),
              const SizedBox(width: RevisionSpacing.s),
              Expanded(child: Text(item, style: RevisionTypography.body)),
            ],
          ),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.section});

  final RevisionSheetSection section;

  @override
  Widget build(BuildContext context) {
    return RevisionSheetSectionCard(
      title: section.title,
      icon: Icons.notes_rounded,
      accent: RevisionColors.mint,
      children: [
        Text(section.content, style: RevisionTypography.body),
        if (section.sources.isNotEmpty) ...[
          const SizedBox(height: RevisionSpacing.s),
          Text('Sources', style: RevisionTypography.caption),
          for (final source in section.sources)
            Text(
              'p. ${source.pageNumber ?? '-'} · ${source.text}',
              style: RevisionTypography.caption,
            ),
        ],
      ],
    );
  }
}

enum _SheetMode { fast, complete, exam }

String _sheetModeLabel(_SheetMode mode) {
  return switch (mode) {
    _SheetMode.fast => 'Rapide',
    _SheetMode.complete => 'Complète',
    _SheetMode.exam => 'Examen',
  };
}

void _popOrGo(BuildContext context, String fallbackLocation) {
  // The sheet is normally stacked above course detail; direct URLs still need a
  // deterministic fallback because there may be nothing to pop.
  if (context.canPop()) {
    context.pop();
    return;
  }

  context.go(fallbackLocation);
}

~~~

### `lib/features/courses/presentation/subject_progress_page.dart`
~~~dart
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

class SubjectProgressPage extends ConsumerWidget {
  const SubjectProgressPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeSubject = ref.watch(activeSubjectProvider);

    return RevisionPageScaffold(
      children: [
        Text('Progrès', style: RevisionTypography.hero),
        Text(
          'Ta progression vient des notions générées depuis tes sources prêtes et de tes réponses.',
          style: RevisionTypography.body,
        ),
        activeSubject.when(
          loading: () =>
              const RevisionLoadingState(label: 'Chargement des matières'),
          error: (error, stackTrace) => RevisionErrorState(
            title: 'Impossible de charger les matières',
            message:
                'La progression réelle ne peut pas être calculée sans matière chargée.',
            actionLabel: 'Réessayer',
            onAction: () =>
                ref.read(subjectsNotifierProvider.notifier).reload(),
          ),
          data: (subject) {
            if (subject == null) {
              return RevisionEmptyState(
                title: 'Aucune matière réelle',
                message:
                    'Crée une matière puis ajoute des cours et sources pour suivre ta progression.',
                icon: Icons.trending_up_rounded,
                actionLabel: 'Ouvrir les matières',
                onAction: () => context.go(AppRoutes.subjects),
              );
            }

            return _SubjectProgressContent(subject: subject);
          },
        ),
      ],
    );
  }
}

class _SubjectProgressContent extends ConsumerWidget {
  const _SubjectProgressContent({required this.subject});

  final Subject subject;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(subjectProgressProvider(subject.id));

    return progress.when(
      loading: () =>
          const RevisionLoadingState(label: 'Chargement de la progression'),
      error: (error, stackTrace) => RevisionErrorState(
        title: 'Progression indisponible',
        message:
            'Impossible de charger les métriques réelles de cette matière.',
        actionLabel: 'Réessayer',
        onAction: () => ref.invalidate(subjectProgressProvider(subject.id)),
      ),
      data: (progress) =>
          _SubjectProgressLoaded(subject: subject, progress: progress),
    );
  }
}

class _SubjectProgressLoaded extends StatelessWidget {
  const _SubjectProgressLoaded({required this.subject, required this.progress});

  final Subject subject;
  final SubjectProgress progress;

  @override
  Widget build(BuildContext context) {
    final visual = revisionSubjectVisualThemeFor(subject.name);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RevisionGlassCard(
          padding: const EdgeInsets.all(RevisionSpacing.xl),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              visual.accent.withValues(alpha: 0.26),
              RevisionColors.glassStrong,
            ],
          ),
          borderColor: visual.accent.withValues(alpha: 0.36),
          child: Row(
            children: [
              RevisionMasteryRing(
                value: progress.estimatedGlobalMastery,
                label: _percent(progress.estimatedGlobalMastery),
                caption: 'global',
                color: progress.mastery == null
                    ? visual.accent
                    : RevisionColors.green,
                size: 104,
              ),
              const SizedBox(width: RevisionSpacing.l),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(subject.name, style: RevisionTypography.sectionTitle),
                    const SizedBox(height: RevisionSpacing.s),
                    Text(
                      '${progress.practicedKnowledgeUnitCount}/${progress.knowledgeUnitCount} notions travaillées',
                      style: RevisionTypography.sectionTitle.copyWith(
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: RevisionSpacing.s),
                    RevisionProgressLine(
                      value: progress.coverage,
                      color: visual.accent,
                      height: 8,
                    ),
                    const SizedBox(height: RevisionSpacing.s),
                    Text(
                      _masteryLabel(progress.mastery),
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
        ),
        const SizedBox(height: RevisionSpacing.l),
        _SubjectProgressMeta(progress: progress, visual: visual),
        const SizedBox(height: RevisionSpacing.l),
        if (progress.courses.isEmpty)
          RevisionEmptyState(
            title: 'Aucun cours réel à suivre',
            message:
                'Crée un cours, ajoute une source PDF, puis révise pour faire progresser ces métriques.',
            icon: Icons.layers_outlined,
            actionLabel: 'Retour à l’accueil',
            onAction: () => context.go(AppRoutes.home),
          )
        else ...[
          Text('Tes cours', style: RevisionTypography.sectionTitle),
          const SizedBox(height: RevisionSpacing.m),
          for (final course in progress.courses) ...[
            _SubjectCourseProgressCard(course: course, visual: visual),
            const SizedBox(height: RevisionSpacing.m),
          ],
          _WeakPointSummary(courses: progress.courses),
        ],
      ],
    );
  }
}

class _SubjectProgressMeta extends StatelessWidget {
  const _SubjectProgressMeta({required this.progress, required this.visual});

  final SubjectProgress progress;
  final RevisionSubjectVisualTheme visual;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: RevisionSpacing.s,
      runSpacing: RevisionSpacing.s,
      children: [
        RevisionMetricPill(
          label: '${progress.courseCount} cours',
          icon: Icons.layers_rounded,
          accent: visual.accent,
        ),
        RevisionMetricPill(
          label: '${progress.readyCourseCount} prêts',
          icon: Icons.check_circle_rounded,
          accent: RevisionColors.green,
        ),
        RevisionMetricPill(
          label: progress.lastPracticedAt == null
              ? 'Pas encore pratiqué'
              : 'Déjà pratiqué',
          icon: Icons.history_rounded,
          accent: RevisionColors.amber,
        ),
      ],
    );
  }
}

class _SubjectCourseProgressCard extends StatelessWidget {
  const _SubjectCourseProgressCard({
    required this.course,
    required this.visual,
  });

  final SubjectCourseProgressItem course;
  final RevisionSubjectVisualTheme visual;

  @override
  Widget build(BuildContext context) {
    final color = _stateColor(course.state, visual);

    return RevisionGlassCard(
      onTap: () => context.push(AppRoutes.course(course.courseId)),
      padding: const EdgeInsets.all(RevisionSpacing.m),
      child: Row(
        children: [
          RevisionIconTile(
            icon: visual.icon,
            accent: color,
            size: 48,
            iconSize: 26,
          ),
          const SizedBox(width: RevisionSpacing.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(course.title, style: RevisionTypography.sectionTitle),
                const SizedBox(height: RevisionSpacing.xs),
                Text(
                  '${course.practicedKnowledgeUnitCount}/${course.knowledgeUnitCount} notions travaillées',
                  style: RevisionTypography.body,
                ),
                const SizedBox(height: RevisionSpacing.s),
                RevisionProgressLine(
                  value: course.coverage,
                  color: color,
                  height: 6,
                ),
                const SizedBox(height: RevisionSpacing.s),
                Text(
                  _stateLabel(course.state),
                  style: RevisionTypography.caption,
                ),
              ],
            ),
          ),
          const SizedBox(width: RevisionSpacing.s),
          Text(
            _percent(course.estimatedGlobalMastery),
            style: RevisionTypography.sectionTitle.copyWith(
              color: RevisionColors.text,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}

class _WeakPointSummary extends StatelessWidget {
  const _WeakPointSummary({required this.courses});

  final List<SubjectCourseProgressItem> courses;

  @override
  Widget build(BuildContext context) {
    final weakCourses = courses
        .where((course) => course.state != CourseProgressState.practiced)
        .take(3)
        .toList(growable: false);

    if (weakCourses.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: RevisionSpacing.s),
        Text('À surveiller', style: RevisionTypography.sectionTitle),
        const SizedBox(height: RevisionSpacing.m),
        for (final course in weakCourses) ...[
          RevisionGlassCard(
            onTap: () => context.push(AppRoutes.course(course.courseId)),
            padding: const EdgeInsets.all(RevisionSpacing.m),
            child: Row(
              children: [
                const RevisionIconTile(
                  icon: Icons.priority_high_rounded,
                  accent: RevisionColors.amber,
                  size: 36,
                  iconSize: 20,
                ),
                const SizedBox(width: RevisionSpacing.m),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        course.title,
                        style: RevisionTypography.sectionTitle,
                      ),
                      const SizedBox(height: RevisionSpacing.xs),
                      Text(
                        _stateLabel(course.state),
                        style: RevisionTypography.caption,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: RevisionSpacing.s),
        ],
      ],
    );
  }
}

String _masteryLabel(double? mastery) {
  if (mastery == null) {
    return 'Maîtrise travaillée : en attente';
  }

  return 'Maîtrise travaillée : ${_percent(mastery)}';
}

String _stateLabel(CourseProgressState state) {
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

Color _stateColor(
  CourseProgressState state,
  RevisionSubjectVisualTheme visual,
) {
  return switch (state) {
    CourseProgressState.practiced => RevisionColors.green,
    CourseProgressState.readyNotPracticed => visual.accent,
    CourseProgressState.processing => RevisionColors.amber,
    CourseProgressState.failedOnly => RevisionColors.red,
    CourseProgressState.noKnowledgeUnits => RevisionColors.violet,
    CourseProgressState.noSource => visual.accent,
    CourseProgressState.unknown => RevisionColors.mint,
  };
}

String _percent(double value) {
  return '${(value.clamp(0, 1) * 100).round()}%';
}

~~~

### `lib/features/courses/presentation/revisions_pending_page.dart`
~~~dart
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

class RevisionsPendingPage extends ConsumerWidget {
  const RevisionsPendingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeSubject = ref.watch(activeSubjectProvider);

    return RevisionPageScaffold(
      children: [
        Text('Révisions', style: RevisionTypography.hero),
        Text('Choisis ton mode de travail', style: RevisionTypography.body),
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
                    'Crée une matière et un cours avec source prête pour lancer une révision rapide.',
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

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RevisionModeCard(
              title: 'Révision rapide',
              description: readyCourse == null
                  ? 'Ajoute une source prête dans un cours pour réviser.'
                  : 'Session courte depuis ${readyCourse.title}.',
              icon: Icons.flash_on_rounded,
              accent: RevisionColors.blue,
              enabled: readyCourse != null,
              trailingLabel: readyCourse == null ? 'À préparer' : null,
              onTap: readyCourse == null
                  ? null
                  : () => context.push(AppRoutes.course(readyCourse.id)),
            ),
            const SizedBox(height: RevisionSpacing.m),
            RevisionModeCard(
              title: 'Révision approfondie',
              description: 'Cours complet et exemples détaillés.',
              icon: Icons.menu_book_rounded,
              accent: visual.accent,
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
            const SizedBox(height: RevisionSpacing.l),
            RevisionGlassCard(
              child: Row(
                children: [
                  RevisionIconTile(
                    icon: visual.icon,
                    accent: visual.accent,
                    size: 42,
                  ),
                  const SizedBox(width: RevisionSpacing.m),
                  Expanded(
                    child: Text(
                      readyCourse == null
                          ? 'Les révisions rapides se lancent depuis un cours avec une source prête.'
                          : 'Ouvre le cours recommandé puis démarre la révision rapide.',
                      style: RevisionTypography.body,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
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

~~~

### `test/app/revision_app_test.dart`
~~~dart
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

  testWidgets('home can create a real course and open its detail', (
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

    await tester.drag(find.byType(CustomScrollView), const Offset(0, -180));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Créer un cours'));
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

    expect(find.text('Résultat réel indisponible'), findsOneWidget);
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

~~~

### `test/app/router/app_router_test.dart`
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

~~~

### `test/features/courses/course_detail_page_test.dart`
~~~dart
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
        path: AppRoutes.revisionSessionPath,
        builder: (context, state) => Scaffold(
          body: Text(
            state.uri.queryParameters['sessionId'] == 'revision-session-1'
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

~~~
