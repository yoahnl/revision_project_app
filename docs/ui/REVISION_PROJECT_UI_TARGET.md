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
